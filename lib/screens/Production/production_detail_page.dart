import 'package:flutter/material.dart';

import '../PreProduct/wash_tank_page.dart';
import 'rm_balance_weight_page.dart';
import 'adjustment_page.dart';
import '../../services/api_client.dart';

// ── Shared Constants ────────────────────────────────────────────────────────

const Color _navy        = Color(0xFF17335C);
const Color _surface     = Color(0xFFF4F7FB);
const Color _border      = Color(0xFFE4EAF2);
const Color _textMuted   = Color(0xFF8A99AD);
const Color _textDark    = Color(0xFF1A2A3A);
const Color _navInactive = Color(0xFF98A6B7);

// ── Data Models ──────────────────────────────────────────────────────────────

class FormulaItem {
  final String name;
  final String ref;
  final String lotQty;
  final String weight;

  const FormulaItem({
    required this.name,
    required this.ref,
    required this.lotQty,
    required this.weight,
  });

  factory FormulaItem.fromJson(Map<String, dynamic> json) {
    final qty  = json['quantity'] ?? '';
    final unit = json['unit'] ?? '';
    final lot  = json['lot_number'] ?? '';
    return FormulaItem(
      name: (json['material_name'] ?? json['name'] ?? '—').toString(),
      ref: (json['material_code'] ?? json['ref'] ?? '—').toString(),
      lotQty: lot.toString().isNotEmpty ? '$lot, $qty $unit'.trim() : '$qty $unit'.trim(),
      weight: '${json['weight'] ?? qty} ${json['weight_unit'] ?? unit}'.trim(),
    );
  }
}

class ProductionDetail {
  final String jobSheetNumber;
  final String lane;
  final String productName;
  final String sapCode;
  final String quantity;
  final String lotNumber;
  final String printDate;
  final String prodDate;
  final String customerLocation;
  final String formulaVersion;
  final List<FormulaItem> formulaItems;

  const ProductionDetail({
    required this.jobSheetNumber,
    required this.lane,
    required this.productName,
    required this.sapCode,
    required this.quantity,
    required this.lotNumber,
    required this.printDate,
    required this.prodDate,
    required this.customerLocation,
    required this.formulaVersion,
    required this.formulaItems,
  });

  factory ProductionDetail.fromJson(Map<String, dynamic> json) {
    final qty  = json['produced_qty'] ?? json['planned_qty'];
    final unit = json['unit'] ?? '';
    final materials = (json['materials'] as List? ?? [])
        .map((e) => FormulaItem.fromJson(e as Map<String, dynamic>))
        .toList();

    return ProductionDetail(
      jobSheetNumber: (json['job_sheet_no'] ?? '—').toString(),
      lane: (json['lane'] ?? '—').toString(),
      productName: (json['product_name'] ?? 'Unnamed Job').toString(),
      sapCode: (json['sap_batch_no'] ?? json['item_id']?.toString() ?? '—').toString(),
      quantity: qty != null ? '$qty $unit'.trim() : '—',
      lotNumber: (json['lot_number'] ?? '—').toString(),
      printDate: (json['label_printed_at'] ?? '—').toString(),
      prodDate: (json['manufacturing_date'] ?? '—').toString(),
      customerLocation: (json['customer_location'] ?? '—').toString(),
      formulaVersion: (json['formula_version'] ?? '—').toString(),
      formulaItems: materials,
    );
  }
}

// ── API fetch ─────────────────────────────────────────────────────────────────

Future<ProductionDetail> fetchProductionDetail(int jobId) async {
  final json = await ApiClient.instance.get('/production/$jobId');
  final data = json['data'] as Map<String, dynamic>? ?? json;
  return ProductionDetail.fromJson(data);
}

// ── Page ──────────────────────────────────────────────────────────────────────

class ProductionDetailPage extends StatefulWidget {
  const ProductionDetailPage({super.key, required this.jobId});

  final int jobId;

  @override
  State<ProductionDetailPage> createState() => _ProductionDetailPageState();
}

class _ProductionDetailPageState extends State<ProductionDetailPage> {
  late Future<ProductionDetail> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = fetchProductionDetail(widget.jobId);
  }

  void _reload() => setState(() => _detailFuture = fetchProductionDetail(widget.jobId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      bottomNavigationBar: const _NavBar(),
      body: SafeArea(
        child: FutureBuilder<ProductionDetail>(
          future: _detailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: _navy));
            }

            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Could not load job details.';
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.cloud_off_rounded, color: _textMuted, size: 40),
                      const SizedBox(height: 12),
                      Text(message, textAlign: TextAlign.center,
                          style: const TextStyle(color: _textMuted, fontSize: 13)),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _reload,
                        icon: const Icon(Icons.refresh_rounded, color: _navy),
                        label: const Text('Retry', style: TextStyle(color: _navy)),
                      ),
                    ],
                  ),
                ),
              );
            }

            final detail = snapshot.data!;

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Header ──
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _navy,
                              ),
                              child: const Icon(Icons.inventory_2_outlined,
                                  color: Colors.white, size: 18),
                            ),
                            const SizedBox(width: 10),
                            const Text('Workwise',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: _navy)),
                            const Spacer(),
                            Container(
                              width: 36,
                              height: 36,
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
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: _border),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: _navy,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'PRODUCTION DETAIL',
                          style: TextStyle(
                            color: _textDark,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                          ),
                        ),

                        const SizedBox(height: 16),

                       Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: _border),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A18304D),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // ================= HEADER =================

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: const BoxDecoration(
                                    color: _navy,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(2),
                                      topRight: Radius.circular(2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text(
                                        "JOB SHEET NUMBER",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1,
                                        ),
                                      ),

                                      const Spacer(),

                                      Text(
                                        detail.jobSheetNumber.startsWith('#')
                                            ? detail.jobSheetNumber
                                            : '#${detail.jobSheetNumber}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [

                                      /// PRODUCT NAME
                                      const Text(
                                        "PRODUCT NAME",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: _textMuted,
                                          letterSpacing: 1,
                                        ),
                                      ),

                                      const SizedBox(height: 6),

                                      Text(
                                        detail.productName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: _textDark,
                                        ),
                                      ),

                                      const SizedBox(height: 18),

                                      Row(
                                        children: [

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                const Text(
                                                  "SAP CODE",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: _textMuted,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 1,
                                                  ),
                                                ),

                                                const SizedBox(height: 4),

                                                Text(
                                                  detail.sapCode,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                const Text(
                                                  "LANE",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: _textMuted,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 1,
                                                  ),
                                                ),

                                                const SizedBox(height: 4),

                                                Text(
                                                  detail.lane,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 18),

                                      Row(
                                        children: [

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                const Text(
                                                  "QUANTITY",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: _textMuted,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 1,
                                                  ),
                                                ),

                                                const SizedBox(height: 4),

                                                Text(
                                                  detail.quantity,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                const Text(
                                                  "LOT NUMBER",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: _textMuted,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 1,
                                                  ),
                                                ),

                                                const SizedBox(height: 4),

                                                Text(
                                                  detail.lotNumber,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 16),

                                      const Divider(),

                                      const SizedBox(height: 12),

                                      Row(
                                        children: [

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                const Text(
                                                  "PRINT DATE",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: _textMuted,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 1,
                                                  ),
                                                ),

                                                const SizedBox(height: 4),

                                                Text(
                                                  detail.printDate,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [

                                                const Text(
                                                  "PROD. DATE",
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: _textMuted,
                                                    fontWeight: FontWeight.w700,
                                                    letterSpacing: 1,
                                                  ),
                                                ),

                                                const SizedBox(height: 4),

                                                Text(
                                                  detail.prodDate,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 16),

                                      const Divider(),

                                      const SizedBox(height: 12),

                                      const Text(
                                        "CUSTOMER & LOCATION",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: _textMuted,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1,
                                        ),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        detail.customerLocation,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: _textDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 16),

                        _SectionHeader(
                          title: 'FORMULA DETAILS',
                          badge: detail.formulaVersion,
                        ),
                        const SizedBox(height: 8),
                        _InfoCard(
                          children: detail.formulaItems.isEmpty
                              ? [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Text('No formula items available.',
                                        style: TextStyle(
                                            color: _textMuted, fontSize: 12)),
                                  ),
                                ]
                              : detail.formulaItems
                                  .asMap()
                                  .entries
                                  .map((e) => Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (e.key > 0) const _Divider(),
                                          _FormulaRow(item: e.value),
                                        ],
                                      ))
                                  .toList(),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'OPERATIONAL ACTIONS',
                          style: TextStyle(
                            color: _textDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),

                        _ActionButton(
                          icon: Icons.water_outlined,
                          label: 'WASH TANK',
                          filled: true,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WashTankPage(
                                jobSheetId: detail.jobSheetNumber,
                                productName: detail.productName,
                                laneNumber: detail.lane,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        _ActionButton(
                          icon: Icons.science_outlined,
                          label: 'QC TESTING RESULTS',
                          onTap: () {},
                        ),
                        const SizedBox(height: 10),

                        _ActionButton(
                          icon: Icons.tune_rounded,
                          label: 'ADJUSTMENT',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdjustmentPage(
                                jobSheetNumber: detail.jobSheetNumber,
                                productName: detail.productName,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        _ActionButton(
                          icon: Icons.scale_outlined,
                          label: 'RM BALANCE WEIGHT',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RmBalanceWeightPage(
                                jobId: detail.jobSheetNumber,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Reusable widgets (unchanged) ──────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(color: Color(0x0A18304D), blurRadius: 6, offset: Offset(0, 2))
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _InfoRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

class _InfoCell extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;
  final bool large;

  const _InfoCell({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 9,
                  color: _textMuted,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8)),
          const SizedBox(height: 3),
          Text(value,
              style: TextStyle(
                  fontSize: large ? 16 : 13,
                  fontWeight: bold || large ? FontWeight.w800 : FontWeight.w600,
                  color: valueColor ?? _textDark)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Divider(color: _border, height: 1),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? badge;
  const _SectionHeader({required this.title, this.badge});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _textDark,
                letterSpacing: 0.5)),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color.fromRGBO(23, 51, 92, 0.08),
            ),
            child: Text(badge!,
                style: const TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w800, color: _navy)),
          ),
        ],
      ],
    );
  }
}

class _FormulaRow extends StatelessWidget {
  final FormulaItem item;
  const _FormulaRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
                const SizedBox(height: 2),
                Text(item.ref,
                    style: const TextStyle(
                        fontSize: 10, color: _textMuted, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('LOT & QTY',
                        style: TextStyle(
                            fontSize: 9, color: _textMuted, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Text(item.lotQty,
                        style: const TextStyle(
                            fontSize: 11, color: _textDark, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('WEIGHT',
                  style: TextStyle(
                      fontSize: 9, color: _textMuted, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(item.weight,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, color: _navy)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: filled ? _navy : Colors.white,
          border: Border.all(color: filled ? _navy : _border),
          boxShadow: filled
              ? [
                  BoxShadow(
                      color: const Color.fromRGBO(23, 51, 92, 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ]
              : [
                  const BoxShadow(
                      color: Color(0x0A18304D), blurRadius: 4, offset: Offset(0, 2))
                ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: filled ? Colors.white : _navy),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: filled ? Colors.white : _textDark,
                      letterSpacing: 0.3)),
            ),
            Icon(Icons.chevron_right_rounded,
                color: filled ? Colors.white.withOpacity(0.7) : _textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Bottom Nav ────────────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.verified_outlined, 'Quality', false),
      (Icons.inventory_2_outlined, 'Inventory', false),
      (Icons.precision_manufacturing_outlined, 'Production', true),
      (Icons.local_shipping_outlined, 'Delivery', false),
      (Icons.more_horiz_rounded, 'Others', false),
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
            final (icon, label, selected) = item;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 22, color: selected ? _navy : _navInactive),
                const SizedBox(height: 4),
                Text(label,
                    style: TextStyle(
                        color: selected ? _navy : _navInactive,
                        fontSize: 10,
                        fontWeight: selected ? FontWeight.w800 : FontWeight.w600)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

