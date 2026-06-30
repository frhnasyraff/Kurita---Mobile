import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

// ── Shared Constants ──────────────────────────────────────────────────────────

const _primary     = Color(0xFF17335C);
const _surface     = Color(0xFFF4F7FB);
const _border      = Color(0xFFD6DEE8);
const _textMuted   = Color(0xFF8A99AD);
const _textDark    = Color(0xFF1A2A3A);
const _navInactive = Color(0xFF98A6B7);

// ── Data model ────────────────────────────────────────────────────────────────

class InspectionSheet {
  const InspectionSheet({
    required this.jobSheetId,
    required this.product,
    required this.prodDate,
    required this.status,
  });

  final String jobSheetId;
  final String product;
  final String prodDate;
  final String status; // 'new' | 'in_progress' | 'completed'

  factory InspectionSheet.fromSnapshot(String key, Map<dynamic, dynamic> data) {
    final rawStatus =
    (data['status'] ?? 'new').toString().toLowerCase().trim();
    final String status;
    if (rawStatus == 'in progress' || rawStatus == 'in_progress') {
      status = 'in_progress';
    } else if (rawStatus == 'completed' || rawStatus == 'done') {
      status = 'completed';
    } else {
      status = 'new';
    }

    return InspectionSheet(
      jobSheetId: data['id']           ??
          data['job_sheet_id'] ??
          data['jobSheetId']   ?? key,
      product   : data['product']      ??
          data['product_name'] ??
          data['productName']  ??
          data['name']         ?? '—',
      prodDate  : data['prod_date']    ??
          data['prodDate']     ??
          data['date']         ?? '—',
      status    : status,
    );
  }
}

// ── Firebase fetch ────────────────────────────────────────────────────────────

Future<List<InspectionSheet>> fetchInspectionSheets() async {
  final ref = FirebaseDatabase.instance.ref('job_sheets');
  final snapshot = await ref.get();
  if (!snapshot.exists || snapshot.value == null) return [];
  final raw = Map<dynamic, dynamic>.from(snapshot.value as Map);
  return raw.entries.map((e) {
    final data = Map<dynamic, dynamic>.from(e.value as Map);
    return InspectionSheet.fromSnapshot(e.key.toString(), data);
  }).toList();
}

// ── Quality Inspection Page ───────────────────────────────────────────────────

class QualityInspectionPage extends StatefulWidget {
  const QualityInspectionPage({super.key});

  @override
  State<QualityInspectionPage> createState() => _QualityInspectionPageState();
}

class _QualityInspectionPageState extends State<QualityInspectionPage> {
  late Future<List<InspectionSheet>> _future;
  String _statusFilter = 'All Sheets';

  // Date range (display only — wire up a real picker if needed)
  String _dateRangeLabel = 'Oct 24, 2023';

  final List<String> _statusOptions = [
    'All Sheets',
    'New',
    'In Progress',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    _future = fetchInspectionSheets();
  }

  List<InspectionSheet> _applyFilter(List<InspectionSheet> all) {
    if (_statusFilter == 'All Sheets') return all;
    final map = {
      'New': 'new',
      'In Progress': 'in_progress',
      'Completed': 'completed',
    };
    final key = map[_statusFilter] ?? 'new';
    return all.where((s) => s.status == key).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      bottomNavigationBar: const _QualityNavBar(selectedLabel: 'Quality'),
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
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: _primary,
                    child: const Text('WW',
                        style: TextStyle(color: Colors.white, fontSize: 10,
                            fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Title ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PRODUCT INSPECTION',
                      style: TextStyle(color: _textDark, fontSize: 24,
                          fontWeight: FontWeight.w900, letterSpacing: -0.3)),
                  SizedBox(height: 3),
                  Text('Select a job sheet to begin final QA.',
                      style: TextStyle(color: _textMuted, fontSize: 12,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Filters row ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  // Date range
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('DATE RANGE',
                            style: TextStyle(color: _textMuted, fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8)),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime(2023, 10, 24),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              builder: (ctx, child) => Theme(
                                data: Theme.of(ctx).copyWith(
                                  colorScheme: const ColorScheme.light(
                                      primary: _primary),
                                ),
                                child: child!,
                              ),
                            );
                            if (picked != null) {
                              setState(() {
                                _dateRangeLabel =
                                '${_monthName(picked.month)} ${picked.day}, ${picked.year}';
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _border),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 14, color: _primary),
                                const SizedBox(width: 6),
                                Text(_dateRangeLabel,
                                    style: const TextStyle(
                                        color: _textDark, fontSize: 12,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Status filter
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('STATUS FILTER',
                            style: TextStyle(color: _textMuted, fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8)),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _border),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _statusFilter,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                  color: _textMuted, size: 18),
                              style: const TextStyle(
                                  color: _textDark, fontSize: 12,
                                  fontWeight: FontWeight.w600),
                              items: _statusOptions
                                  .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s),
                              ))
                                  .toList(),
                              onChanged: (val) =>
                                  setState(() => _statusFilter = val!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── List ──
            Expanded(
              child: FutureBuilder<List<InspectionSheet>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(color: _primary));
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_off_rounded,
                              color: _textMuted, size: 40),
                          const SizedBox(height: 12),
                          Text('${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: _textMuted, fontSize: 13)),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () => setState(
                                    () => _future = fetchInspectionSheets()),
                            icon: const Icon(Icons.refresh_rounded,
                                color: _primary),
                            label: const Text('Retry',
                                style: TextStyle(color: _primary)),
                          ),
                        ],
                      ),
                    );
                  }

                  final filtered = _applyFilter(snapshot.data ?? []);

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.inbox_outlined,
                              color: _textMuted, size: 36),
                          const SizedBox(height: 10),
                          const Text('No inspection sheets found.',
                              style: TextStyle(color: _textMuted,
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextButton.icon(
                            onPressed: () => setState(
                                    () => _future = fetchInspectionSheets()),
                            icon: const Icon(Icons.refresh_rounded,
                                color: _primary, size: 16),
                            label: const Text('Refresh',
                                style: TextStyle(
                                    color: _primary, fontSize: 12)),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: _primary,
                    onRefresh: () async =>
                        setState(() => _future = fetchInspectionSheets()),
                    child: ListView.builder(
                      padding:
                      const EdgeInsets.fromLTRB(20, 4, 20, 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) =>
                          _InspectionCard(sheet: filtered[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) => const [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ][m];
}

// ── Inspection Card ───────────────────────────────────────────────────────────

class _InspectionCard extends StatelessWidget {
  const _InspectionCard({required this.sheet});
  final InspectionSheet sheet;

  Color get _statusColor {
    switch (sheet.status) {
      case 'in_progress':
        return const Color(0xFF0F766E);
      case 'completed':
        return const Color(0xFF10B981);
      default:
        return _textMuted;
    }
  }

  Color get _statusBg {
    switch (sheet.status) {
      case 'in_progress':
        return const Color(0xFFE6FAF8);
      case 'completed':
        return const Color(0xFFD1FAE5);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  String get _statusLabel {
    switch (sheet.status) {
      case 'in_progress':
        return 'IN PROGRESS';
      case 'completed':
        return 'COMPLETED';
      default:
        return 'NEW';
    }
  }

  // Left accent colour per status
  Color get _accentBar {
    switch (sheet.status) {
      case 'in_progress':
        return const Color(0xFF0F766E);
      case 'completed':
        return const Color(0xFF10B981);
      default:
        return _primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE4EAF2)),
        boxShadow: const [
          BoxShadow(color: Color(0x0A18304D), blurRadius: 6,
              offset: Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Left accent bar
              Container(width: 4, color: _accentBar),

              // Card body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Job Sheet ID label + status badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('JOB SHEET ID',
                                    style: TextStyle(color: _textMuted,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6)),
                                const SizedBox(height: 2),
                                Text(sheet.jobSheetId,
                                    style: const TextStyle(
                                        color: _primary,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.3)),
                              ],
                            ),
                          ),

                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _statusColor.withOpacity(0.3),
                                  width: 0.8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (sheet.status == 'new') ...[
                                  Icon(Icons.radio_button_unchecked_rounded,
                                      size: 10, color: _statusColor),
                                  const SizedBox(width: 4),
                                ] else if (sheet.status == 'in_progress') ...[
                                  Icon(Icons.timelapse_rounded,
                                      size: 10, color: _statusColor),
                                  const SizedBox(width: 4),
                                ] else ...[
                                  Icon(Icons.check_circle_rounded,
                                      size: 10, color: _statusColor),
                                  const SizedBox(width: 4),
                                ],
                                Text(_statusLabel,
                                    style: TextStyle(
                                        color: _statusColor,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4)),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFEDF2F7), height: 1),
                      const SizedBox(height: 12),

                      // Row 2: Product + Prod. Date
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('PRODUCT',
                                    style: TextStyle(color: _textMuted,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6)),
                                const SizedBox(height: 3),
                                Text(sheet.product,
                                    style: const TextStyle(
                                        color: _textDark,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('PROD. DATE',
                                    style: TextStyle(color: _textMuted,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6)),
                                const SizedBox(height: 3),
                                Text(sheet.prodDate,
                                    style: const TextStyle(
                                        color: _textDark,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom Nav Bar ────────────────────────────────────────────────────────────

class _QualityNavBar extends StatelessWidget {
  const _QualityNavBar({required this.selectedLabel});
  final String selectedLabel;

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.verified_outlined, 'Quality'),
      (Icons.inventory_2_outlined, 'Inventory'),
      (Icons.precision_manufacturing_outlined, 'Production'),
      (Icons.local_shipping_outlined, 'Delivery'),
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
            return Column(
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
            );
          }).toList(),
        ),
      ),
    );
  }
}