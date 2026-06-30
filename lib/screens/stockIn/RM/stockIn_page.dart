import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../../services/api_client.dart';
import '../../QualityControl/dashboard_page.dart';
import '../../preproduct/material_verification_page.dart';
import '../../PreProduct/pre_production_page.dart';
import 'stockIn_comfirmation_page.dart';
import 'stockIn_inprogress_page.dart';
import 'stockIn_completed_detail_page.dart';
import '../../../models/stockIn_models.dart';
export '../../../models/stockIn_models.dart';

class StockInPage extends StatefulWidget {
  const StockInPage({super.key});

  @override
  State<StockInPage> createState() => _StockInPageState();
}

class _StockInPageState extends State<StockInPage> {
  static const primary = Color(0xFF17335C);

  final _api = ApiClient.instance;
  final _searchController = TextEditingController();

  bool _loading = true;
  String? _error;
  String _searchQuery = '';
  int _selectedTab = 0;
  int _selectedNavBar = 1;

  List<StockInBatch> _newItems = [];
  List<StockInBatch> _inProgressItems = [];
  List<StockInBatch> _completedItems = [];
  List<int> _tabCounts = [0, 0, 0];

  // QC completion % per PO number, fetched lazily from
  // getStockInProgress(poNumber) as each group renders. Cached here so we
  // don't re-fetch on every rebuild; cleared on pull-to-refresh via _load.
  final Map<String, int?> _qcPercentByPo = {};

  // Full progress payload per PO (materials_checked/materials_total),
  // used by the IN PROGRESS tab's card. Cached separately from the percent
  // map above since callers may want one or both — but both ultimately
  // hit the same getStockInProgress endpoint.
  final Map<String, Map<String, dynamic>?> _progressByPo = {};

  final List<String> _tabLabels = ['NEW', 'IN PROGRESS', 'COMPLETE'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _api.init();
      final results = await Future.wait([
        _api.getStockIn(tab: 'new', search: _searchQuery),
        _api.getStockIn(tab: 'in_progress', search: _searchQuery),
        _api.getStockIn(tab: 'complete', search: _searchQuery),
      ]);

      final newRes = results[0];
      final inProgressRes = results[1];
      final completeRes = results[2];

      final counts = newRes['counts'] as Map<String, dynamic>? ?? {};

      setState(() {
        _newItems = ((newRes['data'] as List?) ?? [])
            .map((e) => StockInBatch.fromJson(e as Map<String, dynamic>))
            .toList();
        _inProgressItems = ((inProgressRes['data'] as List?) ?? [])
            .map((e) => StockInBatch.fromJson(e as Map<String, dynamic>))
            .toList();
        _completedItems = ((completeRes['data'] as List?) ?? [])
            .map((e) => StockInBatch.fromJson(e as Map<String, dynamic>))
            .toList();
        _tabCounts = [
          counts['new'] as int? ?? _newItems.length,
          counts['in_progress'] as int? ?? _inProgressItems.length,
          counts['complete'] as int? ?? _completedItems.length,
        ];
        _qcPercentByPo.clear();
        _progressByPo.clear();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Lazily fetches and caches the QC completion percentage for a PO,
  /// via ApiClient.getStockInProgress(poNumber) (field: `qc_percent`).
  Future<int?> _qcPercentFor(String poNumber) async {
    if (_qcPercentByPo.containsKey(poNumber)) {
      return _qcPercentByPo[poNumber];
    }
    try {
      final json = await _api.getStockInProgress(poNumber);
      final percent = json['qc_percent'] as int?;
      _qcPercentByPo[poNumber] = percent;
      return percent;
    } catch (_) {
      _qcPercentByPo[poNumber] = null;
      return null;
    }
  }

  /// Lazily fetches and caches the full progress payload for a PO via
  /// ApiClient.getStockInProgress(poNumber) — includes `materials_checked`
  /// and `materials_total`, used by the IN PROGRESS tab's card.
  Future<Map<String, dynamic>?> _progressFor(String poNumber) async {
    if (_progressByPo.containsKey(poNumber)) {
      return _progressByPo[poNumber];
    }
    try {
      final json = await _api.getStockInProgress(poNumber);
      _progressByPo[poNumber] = json;
      // Piggyback the percent cache too, so _qcPercentFor doesn't refetch.
      _qcPercentByPo[poNumber] = json['qc_percent'] as int?;
      return json;
    } catch (_) {
      _progressByPo[poNumber] = null;
      return null;
    }
  }

  List<StockInBatch> get _currentBatches {
    List<StockInBatch> source;
    switch (_selectedTab) {
      case 0:
        source = _newItems;
        break;
      case 1:
        source = _inProgressItems;
        break;
      default:
        source = _completedItems;
    }

    if (_searchQuery.isEmpty) return source;
    final q = _searchQuery.toLowerCase();
    return source.where((b) {
      return b.poNumber.toLowerCase().contains(q) ||
          b.lotNumber.toLowerCase().contains(q);
    }).toList();
  }

  /// Group the current tab's flat batch list by PO number.
  List<StockInPoGroup> get _currentGroups {
    final batches = _currentBatches;
    final byPo = <String, List<StockInBatch>>{};
    for (final b in batches) {
      byPo.putIfAbsent(b.poNumber, () => []).add(b);
    }

    return byPo.entries.map((entry) {
      final batchesForPo = entry.value;
      final earliest = batchesForPo
          .map((b) => b.receivedDate)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      return StockInPoGroup(
        poNumber: entry.key,
        supplier: batchesForPo.first.supplier,
        receivedDate: earliest,
        batches: batchesForPo,
      );
    }).toList()
      ..sort((a, b) => b.receivedDate.compareTo(a.receivedDate));
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _navigateTo(int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const MaterialVerificationPage(jobId: 'JOB-001');
        break;
      case 1:
        return; // already here
      case 2:
        page = const PreProductionPage();
        break;
      case 3:
        page = const DashboardPage();
        break;
      default:
        return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  /// NEW tab → Confirm Stock In page (quantity / UHF scan / approve).
  /// IN PROGRESS tab → Stock In Detail page (per-material rack/location
  /// assignment via QR scan). COMPLETE tab → read-only detail page showing
  /// quantity + assigned location per material.
  Future<void> _openGroup(StockInPoGroup group) async {
    if (_selectedTab == 2) {
      // COMPLETE — read-only detail view (qty + location per material).
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StockInCompletedDetailPage(
            poNumber: group.poNumber,
            supplier: group.supplier,
            batches: group.batches,
          ),
        ),
      );
      return;
    }

    if (_selectedTab == 1) {
      // IN PROGRESS — go straight to the detail/location-assignment screen.
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StockInProgressPage(poNumber: group.poNumber),
        ),
      );
      _load();
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StockInConfirmationPage(
          poNumber: group.poNumber,
          supplier: group.supplier,
          batches: group.batches,
        ),
      ),
    );
    if (result == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      drawer: _buildDrawer(),
      bottomNavigationBar: BottomNavBar(
        items: [
          (Icons.verified_outlined, 'Quality', _selectedNavBar == 0),
          (Icons.inventory_2_outlined, 'Inventory', _selectedNavBar == 1),
          (Icons.precision_manufacturing_outlined, 'Production', _selectedNavBar == 2),
          (Icons.local_shipping_outlined, 'Delivery', _selectedNavBar == 3),
          (Icons.more_horiz, 'Others', _selectedNavBar == 4),
        ],
        onItemTapped: _navigateTo,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _buildBody(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // DRAWER (hamburger menu)
  // ─────────────────────────────────────────
  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: primary,
                    ),
                    child: const Icon(Icons.inventory_2_outlined,
                        color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Workwise',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined, color: primary),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DashboardPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined, color: primary),
              title: const Text('Settings'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: primary),
              title: const Text('Help & Support'),
              onTap: () => Navigator.pop(context),
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFCC2936)),
              title: const Text('Log Out',
                  style: TextStyle(color: Color(0xFFCC2936))),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final groups = _currentGroups;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: hamburger + Workwise + avatar + settings ──
          Row(
            children: [
              Builder(
                builder: (innerContext) => GestureDetector(
                  onTap: () => Scaffold.of(innerContext).openDrawer(),
                  child: const Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Icon(Icons.menu, color: primary, size: 26),
                  ),
                ),
              ),
              const Text(
                'Workwise',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const Spacer(),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1E1F4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_outline, color: primary, size: 20),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings_outlined, color: primary),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'STOCK IN',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: primary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'INVENTORY MANAGEMENT / STOCK INTAKE SELECTION',
            style: TextStyle(
              color: Color.fromARGB(255, 58, 58, 58),
              fontSize: 12,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 20),
          _buildTabBar(),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search PO or Lot Number',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide.none,
              ),
              enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color(0xFFE5E7EB)),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: primary),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (groups.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No PO in ${_tabLabels[_selectedTab]}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...groups.map((g) => _selectedTab == 1
                ? _buildInProgressCard(g)
                : _buildPoGroupCard(g)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: List.generate(_tabLabels.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? primary : Colors.transparent,
                ),
                child: Column(
                  children: [
                    Text(
                      _tabLabels[index],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '(${_tabCounts[index]})',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Badge color/label depends on the currently selected tab — NOT on the
  /// percentage value itself:
  ///   NEW tab          → blue badge
  ///   IN PROGRESS tab  → grey badge, label "IN PROGRESS"
  ///   COMPLETE tab     → green badge, label "PASS"
  ({Color bg, Color fg, String label}) _qcBadgeStyleForCurrentTab() {
    switch (_selectedTab) {
      case 0: // NEW
        return (
          bg: const Color(0xFFEEF2FF),
          fg: const Color(0xFF3B5BDB),
          label: 'NEW',
        );
      case 1: // IN PROGRESS
        return (
          bg: const Color(0xFFE5E7EB),
          fg: const Color(0xFF4B5563),
          label: 'IN PROGRESS',
        );
      default: // COMPLETE
        return (
          bg: const Color(0xFFD8F3E8),
          fg: const Color(0xFF16A34A),
          label: 'PASS',
        );
    }
  }

  Widget _buildPoGroupCard(StockInPoGroup group) {
    final badgeStyle = _qcBadgeStyleForCurrentTab();

    return GestureDetector(
      onTap: () => _openGroup(group),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _labelValue('PO NUMBER', group.poNumber),
            const SizedBox(height: 10),

            // ── LOT NUMBER row, with QC STATUS + chevron beside it ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _labelValue(
                      'LOT NUMBER', group.batches.first.lotNumber),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'QC STATUS',
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<int?>(
                      future: _qcPercentFor(group.poNumber),
                      builder: (context, snapshot) {
                        final percent = snapshot.data;

                        // In the COMPLETE tab, a PO sitting at less
                        // than 100% (including 0%, i.e. not yet
                        // scanned) should not show as "PASS" — fall
                        // back to the IN PROGRESS badge style instead.
                        final effectiveBadge =
                            (_selectedTab == 2 &&
                                    (percent == null || percent < 100))
                                ? (
                                    bg: const Color(0xFFE5E7EB),
                                    fg: const Color(0xFF4B5563),
                                    label: 'IN PROGRESS',
                                  )
                                : badgeStyle;

                        // Show the percent whenever we have real data from
                        // the API (including 0%) — only hide it if the
                        // fetch hasn't resolved yet or failed (null).
                        final showPercent = percent != null;

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (showPercent) ...[
                              Text(
                                '$percent%',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: primary,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: effectiveBadge.bg,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                effectiveBadge.label,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: effectiveBadge.fg,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                const Padding(
                  padding: EdgeInsets.only(top: 17),
                  child: Icon(Icons.chevron_right,
                      color: Colors.grey, size: 18),
                ),
              ],
            ),

            const SizedBox(height: 10),
            _labelValue('SUPPLIER', group.supplier, bold: true),
            const SizedBox(height: 10),
            _labelValue('RECEIVED DATE', _formatDate(group.receivedDate)),
          ],
        ),
      ),
    );
  }

  /// IN PROGRESS tab card — matches the reference HTML's industrial-style
  /// card: PO number + supplier, a % badge, a square progress bar, and
  /// total weight / materials-scanned rows. Total weight is summed from
  /// this PO's own batches (quantityReceivedKg), since the backend has no
  /// dedicated total-weight field.
  Widget _buildInProgressCard(StockInPoGroup group) {
    final totalWeight = group.batches.fold<double>(
      0,
      (sum, b) => sum + (b.quantityReceivedKg ?? 0),
    );
    final weightLabel = totalWeight % 1 == 0
        ? totalWeight.toStringAsFixed(0)
        : totalWeight.toStringAsFixed(2);

    return GestureDetector(
      onTap: () => _openGroup(group),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F5), // surface-container-low
          border: Border.all(color: const Color(0xFFC4C6CF)), // outline-variant
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.poNumber,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF191C1D), // on-surface
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              group.supplier,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF44474E), // on-surface-variant
                              ),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<Map<String, dynamic>?>(
                        future: _progressFor(group.poNumber),
                        builder: (context, snapshot) {
                          final percent =
                              snapshot.data?['qc_percent'] as int? ?? 0;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD5E3FC), // secondary-container
                              border: Border.all(
                                  color: const Color(0xFFC4C6CF)),
                            ),
                            child: Text(
                              '$percent%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF57657A), // on-secondary-container
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // ── Progress bar (square, no radius) ──
                  FutureBuilder<Map<String, dynamic>?>(
                    future: _progressFor(group.poNumber),
                    builder: (context, snapshot) {
                      final percent =
                          (snapshot.data?['qc_percent'] as int? ?? 0) / 100.0;
                      return ClipRect(
                        child: SizedBox(
                          height: 8,
                          child: Stack(
                            children: [
                              Container(
                                  color: const Color(0xFFE1E3E4)), // surface-container-highest
                              FractionallySizedBox(
                                widthFactor: percent.clamp(0.0, 1.0),
                                child: Container(color: primary),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // ── Total weight + materials scanned ──
                  Wrap(
                    spacing: 20,
                    runSpacing: 6,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.scale_outlined,
                              size: 16, color: Color(0xFF74777F)),
                          const SizedBox(width: 4),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF44474E),
                              ),
                              children: [
                                const TextSpan(text: 'Total Weight: '),
                                TextSpan(
                                  text: '$weightLabel kg',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF191C1D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      FutureBuilder<Map<String, dynamic>?>(
                        future: _progressFor(group.poNumber),
                        builder: (context, snapshot) {
                          final checked =
                              snapshot.data?['materials_checked'] as int? ??
                                  0;
                          final total =
                              snapshot.data?['materials_total'] as int? ??
                                  group.batches.length;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.inventory_2_outlined,
                                  size: 16, color: Color(0xFF74777F)),
                              const SizedBox(width: 4),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF44474E),
                                  ),
                                  children: [
                                    const TextSpan(text: 'Materials: '),
                                    TextSpan(
                                      text: '$checked/$total',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF191C1D),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.chevron_right, color: Color(0xFF74777F)),
          ],
        ),
      ),
    );
  }

  Widget _labelValue(String label, String value, {bool bold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: primary,
          ),
        ),
      ],
    );
  }
}