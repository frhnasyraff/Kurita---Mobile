import 'package:flutter/material.dart';

import '../PreProduct/pre_production_page.dart';
import '../PreProduct/material_verification_page.dart';
import 'production_detail_page.dart';
import '../../services/api_client.dart';

// ── Shared Constants ──────────────────────────────────────────────────────────

const _primary     = Color(0xFF17335C);
const _surface     = Color(0xFFF4F7FB);
const _border      = Color(0xFFD6DEE8);
const _textMuted   = Color(0xFF8A99AD);
const _textDark    = Color(0xFF1A2A3A);
const _navInactive = Color(0xFF98A6B7);

// ── Data model ────────────────────────────────────────────────────────────────
//
// Maps 1:1 onto ProductionController::jobSummary() in the Laravel API:
// id, job_sheet_no, sap_batch_no, product_name, item_id, lot_number, lane,
// planned_qty, produced_qty, unit, priority, current_status,
// manufacturing_date, label_printed_at.

class JobSheet {
  const JobSheet({
    required this.id,
    required this.jobSheetNo,
    required this.productName,
    required this.lane,
    required this.quantityLabel,
    required this.lotNumber,
    required this.status,
  });

  final int id;
  final String jobSheetNo;
  final String productName;
  final String lane;
  final String quantityLabel;
  final String lotNumber;

  /// One of: new, in_progress, pending_qc, pending_adjustment, completed.
  final String status;

  factory JobSheet.fromJson(Map<String, dynamic> json) {
    final qty  = json['produced_qty'] ?? json['planned_qty'];
    final unit = json['unit'] ?? '';
    final quantityLabel = qty != null
        ? '${_formatNumber(qty.toString())} $unit'.trim()
        : '—';

    return JobSheet(
      id           : json['id'] as int,
      jobSheetNo   : (json['job_sheet_no'] ?? '—').toString(),
      productName  : (json['product_name'] ?? 'Unnamed Job').toString(),
      lane         : (json['lane'] ?? '—').toString(),
      quantityLabel: quantityLabel,
      lotNumber    : (json['lot_number'] ?? '').toString(),
      status       : (json['current_status'] ?? 'new').toString(),
    );
  }

  /// Collapses the API's finer-grained statuses (pending_qc,
  /// pending_adjustment) into the three tabs the UI shows.
  String get tabBucket {
    switch (status) {
      case 'new':
        return 'new';
      case 'completed':
        return 'completed';
      default: // in_progress, pending_qc, pending_adjustment
        return 'in_progress';
    }
  }

  static String _formatNumber(String raw) {
    final n = num.tryParse(raw.replaceAll(',', ''));
    if (n == null) return raw;
    return n.toInt().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  }
}

class JobSheetPage {
  const JobSheetPage({required this.jobs, required this.counts});

  final List<JobSheet> jobs;
  final Map<String, int> counts; // {new, in_progress, completed}
}

// ── API fetch ─────────────────────────────────────────────────────────────────

Future<JobSheetPage> fetchJobSheets({String? tab, String? search}) async {
  final query = <String, String>{
    if (tab != null && tab != 'all') 'tab': tab,
    if (search != null && search.isNotEmpty) 'search': search,
  };

  final json = await ApiClient.instance.get('/production', query: query);
  final data = (json['data'] as List? ?? [])
      .map((e) => JobSheet.fromJson(e as Map<String, dynamic>))
      .toList();

  final countsJson = json['counts'] as Map? ?? {};
  final counts = {
    'new'        : (countsJson['new'] ?? 0) as int,
    'in_progress': (countsJson['in_progress'] ?? 0) as int,
    'completed'  : (countsJson['completed'] ?? 0) as int,
  };

  return JobSheetPage(jobs: data, counts: counts);
}

// ── Production Hub Page ───────────────────────────────────────────────────────

class ProductionPage extends StatelessWidget {
  const ProductionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      bottomNavigationBar: const _ProductionNavBar(selectedLabel: 'Production'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(23, 51, 92, 0.08),
                      ),
                      child: const Icon(Icons.inventory_2_rounded,
                          color: _primary, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text('Workwise',
                        style: TextStyle(color: _primary, fontSize: 18,
                            fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _border),
                      ),
                      child: const Icon(Icons.settings_outlined,
                          color: _textMuted, size: 18),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PRODUCTION',
                        style: TextStyle(color: _textDark, fontSize: 28,
                            fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    SizedBox(height: 4),
                    Text('Select a production module to continue.',
                        style: TextStyle(color: _textMuted, fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _ModuleCard(
                      icon: Icons.playlist_add_check_rounded,
                      title: 'Pre-Production',
                      subtitle:
                      'Job sheet inspection, tank cleaning\nand material verification',
                      color: const Color(0xFF1A56DB),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const PreProductionPage())),
                    ),
                    const SizedBox(height: 16),
                    _ModuleCard(
                      icon: Icons.precision_manufacturing_rounded,
                      title: 'Production',
                      subtitle:
                      'Manage job sheets, track progress\nand update production status',
                      color: const Color(0xFF0F766E),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const ProductionJobSheetPage())),
                    ),
                    const SizedBox(height: 16),
                    _ModuleCard(
                      icon: Icons.fact_check_outlined,
                      title: 'Material Verification',
                      subtitle:
                      'Review and validate material integrity\nbefore final production sequence',
                      color: const Color(0xFF7C3AED),
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => MaterialVerificationPage(jobId: 'JOB-2024-052'))),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Module Card ───────────────────────────────────────────────────────────────

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4EAF2)),
          boxShadow: const [
            BoxShadow(color: Color(0x0A18304D), blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(color: _textDark, fontSize: 15,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: const TextStyle(color: _textMuted, fontSize: 11,
                          height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                color: color.withOpacity(0.6), size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Production Job Sheet Page ─────────────────────────────────────────────────

class ProductionJobSheetPage extends StatefulWidget {
  const ProductionJobSheetPage({super.key});

  @override
  State<ProductionJobSheetPage> createState() => _ProductionJobSheetPageState();
}

class _ProductionJobSheetPageState extends State<ProductionJobSheetPage> {
  String _filter = 'new';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  late Future<JobSheetPage> _pageFuture;

  @override
  void initState() {
    super.initState();
    _pageFuture = fetchJobSheets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reload() => setState(() => _pageFuture = fetchJobSheets());

  bool _matchesSearch(String text, String query) {
    if (query.isEmpty) return true;
    final q = query.trim().toLowerCase();
    final queryWords = q.split(RegExp(r'\s+'));
    if (queryWords.length > 1) {
      return queryWords.every((qw) {
        final textWords = text.toLowerCase().split(RegExp(r'[\s\-_#]+'));
        return textWords.any((tw) => tw.startsWith(qw));
      });
    }
    final textWords = text.toLowerCase().split(RegExp(r'[\s\-_#]+'));
    return textWords.any((word) => word.startsWith(q));
  }

  List<JobSheet> _filtered(List<JobSheet> jobs) {
    return jobs.where((job) {
      final matchesFilter = job.tabBucket == _filter;
      final matchesSearch = _searchQuery.isEmpty ||
          _matchesSearch(job.jobSheetNo, _searchQuery) ||
          _matchesSearch(job.productName, _searchQuery) ||
          _matchesSearch(job.lane, _searchQuery);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      bottomNavigationBar: const _ProductionNavBar(selectedLabel: 'Production'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(23, 51, 92, 0.08),
                    ),
                    child: const Icon(Icons.inventory_2_rounded,
                        color: _primary, size: 16),
                  ),
                  const SizedBox(width: 8),
                  const Text('Workwise',
                      style: TextStyle(color: _primary, fontSize: 18,
                          fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: _border),
                    ),
                    child: const Icon(Icons.settings_outlined,
                        color: _textMuted, size: 18),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _border),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: _primary, size: 16),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PRODUCTION',
                      style: TextStyle(color: _textDark, fontSize: 30,
                          fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  SizedBox(height: 3),
                  Text('Select a job sheet to manage production tasks.',
                      style: TextStyle(color: _textMuted, fontSize: 15,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: _textDark, fontSize: 13,
                    fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Search Job Sheet, Product or Lane',
                  hintStyle: const TextStyle(color: _textMuted, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: _textMuted, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: _textMuted, size: 16),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                      borderSide: const BorderSide(color: _border)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: _border)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: _primary, width: 1.4)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: FutureBuilder<JobSheetPage>(
                future: _pageFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: _primary));
                  }

                  if (snapshot.hasError) {
                    final message = snapshot.error is ApiException
                        ? (snapshot.error as ApiException).message
                        : 'Could not load job sheets.';
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.cloud_off_rounded,
                                color: _textMuted, size: 40),
                            const SizedBox(height: 12),
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: _textMuted, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: _reload,
                              icon: const Icon(Icons.refresh_rounded,
                                  color: _primary),
                              label: const Text('Retry',
                                  style: TextStyle(color: _primary)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final page = snapshot.data ?? const JobSheetPage(jobs: [], counts: {});
                  final filtered = _filtered(page.jobs);

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _Tab(
                              label: 'NEW',
                              count: page.counts['new'] ?? 0,
                              active: _filter == 'new',
                              onTap: () => setState(() => _filter = 'new'),
                            ),
                            _Tab(
                              label: 'IN PROGRESS',
                              count: page.counts['in_progress'] ?? 0,
                              active: _filter == 'in_progress',
                              onTap: () =>
                                  setState(() => _filter = 'in_progress'),
                            ),
                            _Tab(
                              label: 'COMPLETED',
                              count: page.counts['completed'] ?? 0,
                              active: _filter == 'completed',
                              onTap: () =>
                                  setState(() => _filter = 'completed'),
                            ),
                          ],
                        ),
                      ),

                      const Divider(color: _border, height: 1),

                      Expanded(
                        child: filtered.isEmpty
                            ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.inbox_outlined,
                                  color: _textMuted, size: 36),
                              const SizedBox(height: 10),
                              const Text('No job sheets found.',
                                  style: TextStyle(
                                      color: _textMuted,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              const SizedBox(height: 6),
                              TextButton.icon(
                                onPressed: _reload,
                                icon: const Icon(Icons.refresh_rounded,
                                    color: _primary, size: 16),
                                label: const Text('Refresh',
                                    style: TextStyle(
                                        color: _primary, fontSize: 12)),
                              ),
                            ],
                          ),
                        )
                            : RefreshIndicator(
                          color: _primary,
                          onRefresh: () async => _reload(),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                                20, 12, 20, 12),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) =>
                                _JobCard(
                                  job: filtered[index],
                                  onChanged: _reload,
                                ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter Tab ────────────────────────────────────────────────────────────────

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: active ? _primary : Colors.transparent,
                width: 2.5,
              ),
            ),
          ),
          child: Column(
            children: [
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: active ? _primary : _textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text('($count)',
                  style: TextStyle(
                      color: active ? _primary : _textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Job Card ──────────────────────────────────────────────────────────────────

class _JobCard extends StatelessWidget {
  const _JobCard({required this.job, required this.onChanged});

  final JobSheet job;
  final VoidCallback onChanged;

  Color get _badgeColor {
    switch (job.tabBucket) {
      case 'in_progress':
        return const Color(0xFFF59E0B);
      case 'completed':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF4A90D9);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // ProductionDetailPage now fetches its own data from
        // GET /api/production/{id} using just the job id, so the full
        // detail (materials, qc_results, adjustments) is always fresh.
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductionDetailPage(jobId: job.id),
          ),
        );
        onChanged();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(18, 18, 14, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE4EAF2)),
          boxShadow: const [
            BoxShadow(color: Color(0x0A18304D), blurRadius: 6,
                offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  job.jobSheetNo.startsWith('#')
                      ? job.jobSheetNo
                      : '#${job.jobSheetNo}',
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
                  const SizedBox(height: 10),
                  Text(
                    job.productName,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.2,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 25,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.apps_rounded,
                            size: 15,
                            color: _textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job.lane,
                            style: const TextStyle(
                              color: _textMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.opacity_outlined,
                            size: 15,
                            color: _textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            job.quantityLabel,
                            style: const TextStyle(
                              color: _textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),

                      if (job.lotNumber.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F0FE),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            job.lotNumber,
                            style: const TextStyle(
                              color: Color(0xFF4B5EAA),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFB0BEC5), size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Nav Bar ────────────────────────────────────────────────────────────

class _ProductionNavBar extends StatelessWidget {
  const _ProductionNavBar({required this.selectedLabel});

  final String selectedLabel;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.verified_outlined, 'Quality'),
      (Icons.inventory_2_outlined, 'Inventory'),
      (Icons.precision_manufacturing_outlined, 'Production'),
      (Icons.local_shipping_outlined, 'Delivery'),
      (Icons.more_horiz_rounded, 'Others'),
    ];

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE4EAF2))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            final (icon, label) = item;
            final selected = label == selectedLabel;
            return GestureDetector(
              onTap: () {
                if (label == 'Production' && !selected) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ProductionPage()),
                  );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 22,
                      color: selected ? _primary : _navInactive),
                  const SizedBox(height: 4),
                  Text(label,
                      style: TextStyle(
                          color: selected ? _primary : _navInactive,
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w600)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}