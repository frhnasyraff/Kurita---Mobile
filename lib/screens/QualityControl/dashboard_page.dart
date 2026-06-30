// lib/pages/dashboard_page.dart
import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import 'inspection_details_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _api = ApiClient.instance;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _orders = [];
  int _expectedToday = 0;
  int _completedToday = 0;
  String _searchPo = '';
  DateTime _selectedDate = DateTime.now();

  // Status filter shown in the "All" dropdown. null/'all' = no filter.
  String _statusFilter = 'all';

  static const Map<String, String> _statusFilterLabels = {
    'all': 'All',
    'new': 'New',
    'partial': 'In Progress',
    'passed': 'Completed',
  };

  String get _selectedDateIso =>
      _selectedDate.toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _api.init();
      final stats = await _api.getDailyStats(date: _selectedDateIso);
      final summary = await _api.getReceivingSummary(
        date: _selectedDateIso,
        po: _searchPo.isEmpty ? null : _searchPo,
        // getReceivingSummary's `status` param is non-nullable and already
        // treats 'all' as "no filter" internally, so pass it through as-is.
        status: _statusFilter,
      );
      setState(() {
        _expectedToday = stats['expected_today'] as int? ?? 0;
        _completedToday = stats['completed_today'] as int? ?? 0;
        // /receiving/summary returns ONE entry per PO (grouped across
        // all its materials/batches), not one entry per material. Each
        // entry carries `batch_count` (= number of SKUs/materials on that
        // PO) and `overall_status` (new/partial/passed/failed) instead of
        // a single line item's `inspection_status`.
        _orders = List<Map<String, dynamic>>.from(summary['data'] as List);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _load();
    }
  }

  Future<void> _pickStatusFilter() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _statusFilterLabels.entries.map((e) {
              return ListTile(
                title: Text(e.value),
                trailing: _statusFilter == e.key
                    ? const Icon(Icons.check, color: Color(0xFF17335C))
                    : null,
                onTap: () => Navigator.pop(ctx, e.key),
              );
            }).toList(),
          ),
        );
      },
    );
    if (picked != null && picked != _statusFilter) {
      setState(() => _statusFilter = picked);
      _load();
    }
  }

  /// Maps the PO-level `overall_status` (computed across all materials on
  /// that PO) to the badge label shown on the dashboard card.
  String _statusLabel(String overallStatus) {
    return switch (overallStatus) {
      'new' => 'NEW',
      'partial' => 'IN PROGRESS',
      'passed' => 'COMPLETED',
      _ => overallStatus.toUpperCase(),
    };
  }

  Color _statusColor(String overallStatus) {
    return switch (overallStatus) {
      'new' => const Color(0xFF67A8F4),
      'partial' => const Color(0xFF5AB87A),
      'passed' => const Color(0xFF16A34A),
      _ => Colors.grey,
    };
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF17335C);

    return Scaffold(
      backgroundColor: Colors.white,
      // Top app bar with brand + avatar + settings — matches target design.
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.white,
        titleSpacing: 16,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFE9EDF3),
              child: Icon(Icons.person, size: 18, color: primary),
            ),
            const SizedBox(width: 10),
            const Text(
              'Workwise',
              style: TextStyle(
                color: primary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: primary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!, textAlign: TextAlign.center))
                : RefreshIndicator(
                    onRefresh: _load,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'RECEIVING SUMMARY',
                            style: TextStyle(
                              color: primary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Operational status and logistics tracking.',
                            style: TextStyle(
                              color: Color(0xFF7C8CA0),
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Date picker + status filter row
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: _PillButton(
                                  icon: Icons.calendar_today_outlined,
                                  label: _formatDate(_selectedDate),
                                  onTap: _pickDate,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 2,
                                child: _PillButton(
                                  label: _statusFilterLabels[_statusFilter] ??
                                      'All',
                                  trailingIcon:
                                      Icons.keyboard_arrow_down_rounded,
                                  onTap: _pickStatusFilter,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Search PO
                          TextField(
                            decoration: InputDecoration(
                              hintText: 'Search by PO Number',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: const Color(0xFFF5F7FA),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (v) {
                              _searchPo = v.trim();
                              _load();
                            },
                          ),
                          const SizedBox(height: 16),

                          // Cards — one per PO (grouped across its materials/batches)
                          ..._orders.map((po) {
                            final overallStatus =
                                po['overall_status'] as String? ?? 'new';
                            final batchCount = po['batch_count'] as int? ?? 0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InspectionDetailsPage(
                                      poNumber: po['po_number'] as String,
                                      companyName:
                                          po['supplier_name'] as String,
                                    ),
                                  ),
                                ),
                                child: _ShipmentCard(
                                  poNumber: po['po_number'] as String? ?? '',
                                  company: po['supplier_name'] as String,
                                  skuCount: batchCount,
                                  date:
                                      po['expected_receive_date'] as String? ??
                                          '',
                                  status: _statusLabel(overallStatus),
                                  statusColor: _statusColor(overallStatus),
                                ),
                              ),
                            );
                          }),

                          const SizedBox(height: 12),
                          const Divider(color: Color(0xFFE3E8EF)),
                          const SizedBox(height: 12),

                          const Text(
                            'DAILY STATISTICS',
                            style: TextStyle(
                              color: primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _StatsCard(
                                  label: 'EXPECTED TODAY',
                                  value:
                                      _expectedToday.toString().padLeft(2, '0'),
                                  accent: primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatsCard(
                                  label: 'TOTAL COMPLETED',
                                  value: _completedToday
                                      .toString()
                                      .padLeft(2, '0'),
                                  accent: const Color(0xFF5AB87A),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}

/// Rounded pill-shaped filter control used for the date picker and the
/// status dropdown row above the search box.
class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    this.icon,
    this.trailingIcon,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFDCE4EE)),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: const Color(0xFF6F8096)),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF17335C),
                ),
              ),
            ),
            if (trailingIcon != null)
              Icon(trailingIcon, size: 18, color: const Color(0xFF6F8096)),
          ],
        ),
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  const _ShipmentCard({
    required this.poNumber,
    required this.company,
    required this.skuCount,
    required this.date,
    required this.status,
    required this.statusColor,
  });

  final String poNumber, company, date, status;
  final int skuCount;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE4EE)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: PO number chip + status chip side by side
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9EDF3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        poNumber,
                        style: const TextStyle(
                          color: Color(0xFF6F8096),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  company,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        size: 14, color: Color(0xFF7C8CA0)),
                    const SizedBox(width: 4),
                    Text(
                      '$skuCount SKU${skuCount == 1 ? '' : 's'}',
                      style: const TextStyle(
                          color: Color(0xFF7C8CA0), fontSize: 12),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: Color(0xFF7C8CA0)),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(
                          color: Color(0xFF7C8CA0), fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF7C8CA0)),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard(
      {required this.label, required this.value, required this.accent});
  final String label, value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDCE4EE)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey)),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w300, color: accent)),
        ],
      ),
    );
  }
}