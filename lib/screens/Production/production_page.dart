import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../PreProduct/pre_production_page.dart';
import '../PreProduct/material_verification_page.dart';
import 'production_detail_page.dart';

// ── Shared Constants ──────────────────────────────────────────────────────────

const _primary     = Color(0xFF17335C);
const _surface     = Color(0xFFF4F7FB);
const _border      = Color(0xFFD6DEE8);
const _textMuted   = Color(0xFF8A99AD);
const _textDark    = Color(0xFF1A2A3A);
const _navInactive = Color(0xFF98A6B7);

// ── Data model ────────────────────────────────────────────────────────────────

class JobSheet {
  const JobSheet({
    required this.jobNumber,
    required this.productName,
    required this.lane,
    required this.quantity,
    required this.codeBadge,
    required this.status,
  });

  final String jobNumber;
  final String productName;
  final String lane;
  final String quantity;
  final String codeBadge;
  final String status;

  factory JobSheet.fromSnapshot(String key, Map<dynamic, dynamic> data) {
    // Normalise status → lowercase snake_case
    final rawStatus = (data['status'] ?? 'new').toString().toLowerCase().trim();
    final String status;
    if (rawStatus == 'in progress' || rawStatus == 'in_progress') {
      status = 'in_progress';
    } else if (rawStatus == 'completed' || rawStatus == 'done') {
      status = 'completed';
    } else {
      status = 'new';
    }

    // Volume + unit → "2,000 L"
    final volume     = data['volume']      ?? data['quantity'] ?? '';
    final volumeUnit = data['volume_unit'] ?? data['volumeUnit'] ?? 'L';
    final qty = volume.toString().isNotEmpty
        ? '${_formatNumber(volume.toString())} $volumeUnit'
        : '—';

    return JobSheet(
      jobNumber  : data['id']           ??
          data['job_number']   ??
          data['jobNumber']    ?? key,
      productName: data['name']         ??
          data['product_name'] ??
          data['productName']  ??
          data['description']  ?? 'Unnamed Job',
      lane       : data['lane']         ??
          data['lane_id']      ?? '—',
      quantity   : qty,
      codeBadge  : data['code']         ??
          data['product_code'] ??
          data['productCode']  ??
          data['sku']          ?? '',
      status     : status,
    );
  }

  static String _formatNumber(String raw) {
    final n = num.tryParse(raw.replaceAll(',', ''));
    if (n == null) return raw;
    return n.toInt().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  }
}

// ── Firebase fetch ────────────────────────────────────────────────────────────

Future<List<JobSheet>> fetchJobSheets() async {
  final ref = FirebaseDatabase.instance.ref('job_sheets');
  final snapshot = await ref.get();

  if (!snapshot.exists || snapshot.value == null) return [];

  final raw = Map<dynamic, dynamic>.from(snapshot.value as Map);
  return raw.entries.map((e) {
    final data = Map<dynamic, dynamic>.from(e.value as Map);
    return JobSheet.fromSnapshot(e.key.toString(), data);
  }).toList();
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
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(23, 51, 92, 0.08),
                        borderRadius: BorderRadius.circular(16),
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
                        borderRadius: BorderRadius.circular(10),
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
          borderRadius: BorderRadius.circular(16),
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
                borderRadius: BorderRadius.circular(12),
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
  late Future<List<JobSheet>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = fetchJobSheets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      final matchesFilter = job.status == _filter;
      final matchesSearch = _searchQuery.isEmpty ||
          _matchesSearch(job.jobNumber, _searchQuery) ||
          _matchesSearch(job.productName, _searchQuery) ||
          _matchesSearch(job.lane, _searchQuery);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  int _countByStatus(List<JobSheet> jobs, String status) =>
      jobs.where((j) => j.status == status).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      bottomNavigationBar: const _ProductionNavBar(selectedLabel: 'Production'),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(23, 51, 92, 0.08),
                      borderRadius: BorderRadius.circular(16),
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
                      borderRadius: BorderRadius.circular(10),
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
                        borderRadius: BorderRadius.circular(10),
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
                      style: TextStyle(color: _textDark, fontSize: 28,
                          fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                  SizedBox(height: 3),
                  Text('Select a job sheet to manage production tasks.',
                      style: TextStyle(color: _textMuted, fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Search ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: _textDark, fontSize: 13,
                    fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'Search Job Sheet, Product or Lane',
                  hintStyle: const TextStyle(color: _textMuted, fontSize: 12),
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
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _border)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _primary, width: 1.4)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── FutureBuilder: tabs + list ──
            Expanded(
              child: FutureBuilder<List<JobSheet>>(
                future: _jobsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: _primary));
                  }

                  if (snapshot.hasError) {
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
                              'Could not load job sheets.\n${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: _textMuted, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () => setState(
                                      () => _jobsFuture = fetchJobSheets()),
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

                  final jobs = snapshot.data ?? [];
                  final filtered = _filtered(jobs);

                  return Column(
                    children: [
                      // ── Tabs ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            _Tab(
                              label: 'NEW',
                              count: _countByStatus(jobs, 'new'),
                              active: _filter == 'new',
                              onTap: () => setState(() => _filter = 'new'),
                            ),
                            _Tab(
                              label: 'IN PROGRESS',
                              count: _countByStatus(jobs, 'in_progress'),
                              active: _filter == 'in_progress',
                              onTap: () =>
                                  setState(() => _filter = 'in_progress'),
                            ),
                            _Tab(
                              label: 'COMPLETED',
                              count: _countByStatus(jobs, 'completed'),
                              active: _filter == 'completed',
                              onTap: () =>
                                  setState(() => _filter = 'completed'),
                            ),
                          ],
                        ),
                      ),

                      const Divider(color: _border, height: 1),

                      // ── List ──
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
                                onPressed: () => setState(
                                        () => _jobsFuture = fetchJobSheets()),
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
                          onRefresh: () async => setState(
                                  () => _jobsFuture = fetchJobSheets()),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                                20, 12, 20, 12),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) =>
                                _JobCard(job: filtered[index]),
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
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5)),
              const SizedBox(height: 2),
              Text('($count)',
                  style: TextStyle(
                      color: active ? _primary : _textMuted,
                      fontSize: 9,
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
  const _JobCard({required this.job});

  final JobSheet job;

  Color get _badgeColor {
    switch (job.status) {
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
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductionDetailPage(
            jobSheetNumber: job.jobNumber,
            productName: job.productName,
            lane: job.lane,
            quantity: job.quantity,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
                  Text(job.jobNumber,
                      style: const TextStyle(
                          color: _primary, fontSize: 12,
                          fontWeight: FontWeight.w800, letterSpacing: 0.2)),
                  const SizedBox(height: 3),
                  Text(job.productName,
                      style: const TextStyle(
                          color: Color(0xFF1A2A3A), fontSize: 14,
                          fontWeight: FontWeight.w700, height: 1.2)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.apps_rounded,
                          size: 13, color: _textMuted),
                      const SizedBox(width: 4),
                      Text(job.lane,
                          style: const TextStyle(color: _textMuted,
                              fontSize: 11, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 14),
                      const Icon(Icons.opacity_rounded,
                          size: 13, color: _textMuted),
                      const SizedBox(width: 4),
                      Text(job.quantity,
                          style: const TextStyle(color: _textMuted,
                              fontSize: 11, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 14),
                      if (job.codeBadge.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _badgeColor.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: _badgeColor.withOpacity(0.35),
                                width: 0.8),
                          ),
                          child: Text(job.codeBadge,
                              style: TextStyle(
                                  color: _badgeColor, fontSize: 10,
                                  fontWeight: FontWeight.w700)),
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