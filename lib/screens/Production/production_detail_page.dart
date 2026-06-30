import 'package:flutter/material.dart';

import '../PreProduct/wash_tank_page.dart';
import 'rm_balance_weight_page.dart';
import 'adjustment_page.dart';

// ── Shared Constants (top-level so all widgets can access) ────────────────────

const Color _navy        = Color(0xFF17335C);
const Color _surface     = Color(0xFFF4F7FB);
const Color _border      = Color(0xFFE4EAF2);
const Color _textMuted   = Color(0xFF8A99AD);
const Color _textDark    = Color(0xFF1A2A3A);
const Color _navInactive = Color(0xFF98A6B7);

// ── Data Model ────────────────────────────────────────────────────────────────

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
}

// ── Page ──────────────────────────────────────────────────────────────────────

class ProductionDetailPage extends StatelessWidget {
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

  const ProductionDetailPage({
    super.key,
    this.jobSheetNumber = '#JOB-2024-012',
    this.lane = 'Lane 04',
    this.productName = 'Industrial Disinfectant X1',
    this.sapCode = 'SAP-99821-QC',
    this.quantity = '1,500 L',
    this.lotNumber = 'CHM-24-012-A',
    this.printDate = 'Oct 24, 2023',
    this.prodDate = 'Oct 25, 2023',
    this.customerLocation = 'Global Logistics - Warehouse A',
    this.formulaVersion = 'V11',
    this.formulaItems = const [
      FormulaItem(
        name: 'Sodium Hypochlorite',
        ref: 'RM-SH-001',
        lotQty: 'L2401, 508L',
        weight: '515kg',
      ),
      FormulaItem(
        name: 'Thickener T-400',
        ref: 'RM-TK-005',
        lotQty: 'L2402, 2.5kg',
        weight: '2.8kg',
      ),
      FormulaItem(
        name: 'Fragrance',
        ref: 'RM-FR-009',
        lotQty: 'L2403, 18L',
        weight: '18.5kg',
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      bottomNavigationBar: const _NavBar(),
      body: SafeArea(
        child: Column(
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
                            borderRadius: BorderRadius.circular(10),
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

                    // ── Title ──
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

                    // ── Job Sheet Info Card ──
                    _InfoCard(
                      children: [
                        _InfoRow(
                          left: _InfoCell(
                              label: 'JOB SHEET NUMBER',
                              value: jobSheetNumber,
                              valueColor: _navy,
                              bold: true),
                          right: _InfoCell(
                              label: 'LANE', value: lane),
                        ),
                        const _Divider(),
                        _InfoCell(
                            label: 'PRODUCT NAME',
                            value: productName,
                            large: true),
                        const _Divider(),
                        _InfoRow(
                          left: _InfoCell(
                              label: 'SAP CODE', value: sapCode),
                          right: _InfoCell(
                              label: 'LANE', value: lane),
                        ),
                        const _Divider(),
                        _InfoRow(
                          left: _InfoCell(
                              label: 'QUANTITY', value: quantity),
                          right: _InfoCell(
                              label: 'LOT NUMBER', value: lotNumber),
                        ),
                        const _Divider(),
                        _InfoRow(
                          left: _InfoCell(
                              label: 'PRINT DATE', value: printDate),
                          right: _InfoCell(
                              label: 'PROD. DATE', value: prodDate),
                        ),
                        const _Divider(),
                        _InfoCell(
                            label: 'CUSTOMER & LOCATION',
                            value: customerLocation),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Formula Details ──
                    _SectionHeader(
                      title: 'FORMULA DETAILS',
                      badge: formulaVersion,
                    ),
                    const SizedBox(height: 8),
                    _InfoCard(
                      children: formulaItems
                          .asMap()
                          .entries
                          .map((e) => Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          if (e.key > 0) const _Divider(),
                          _FormulaRow(item: e.value),
                        ],
                      ))
                          .toList(),
                    ),

                    const SizedBox(height: 16),

                    // ── Operational Actions ──
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

                    // Wash Tank — filled/primary
                    _ActionButton(
                      icon: Icons.water_outlined,
                      label: 'WASH TANK',
                      filled: true,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WashTankPage(
                            jobSheetId: jobSheetNumber,
                            productName: productName,
                            laneNumber: lane,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // QC Testing Results
                    _ActionButton(
                      icon: Icons.science_outlined,
                      label: 'QC TESTING RESULTS',
                      onTap: () {},
                    ),
                    const SizedBox(height: 10),

                    // Adjustment
                    _ActionButton(
                      icon: Icons.tune_rounded,
                      label: 'ADJUSTMENT',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdjustmentPage(
                            jobSheetNumber: jobSheetNumber,
                            productName: productName,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // RM Balance Weight
                    _ActionButton(
                      icon: Icons.scale_outlined,
                      label: 'RM BALANCE WEIGHT',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RmBalanceWeightPage(
                            jobId: jobSheetNumber,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Reusable widgets ──────────────────────────────────────────────────────────

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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A18304D),
              blurRadius: 6,
              offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
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
                  fontWeight:
                  bold || large ? FontWeight.w800 : FontWeight.w600,
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
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Color.fromRGBO(23, 51, 92, 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(badge!,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _navy)),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _textDark)),
                const SizedBox(height: 2),
                Text(item.ref,
                    style: const TextStyle(
                        fontSize: 10,
                        color: _textMuted,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('LOT & QTY',
                        style: TextStyle(
                            fontSize: 9,
                            color: _textMuted,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Text(item.lotQty,
                        style: const TextStyle(
                            fontSize: 11,
                            color: _textDark,
                            fontWeight: FontWeight.w600)),
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
                      fontSize: 9,
                      color: _textMuted,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(item.weight,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: _navy)),
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
        padding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: filled ? _navy : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: filled ? _navy : _border),
          boxShadow: filled
              ? [
            BoxShadow(
                color: Color.fromRGBO(23, 51, 92, 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3))
          ]
              : [
            const BoxShadow(
                color: Color(0x0A18304D),
                blurRadius: 4,
                offset: Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: filled ? Colors.white : _navy),
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
                color: filled
                    ? Colors.white.withOpacity(0.7)
                    : _textMuted,
                size: 20),
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
                Icon(icon,
                    size: 22,
                    color: selected ? _navy : _navInactive),
                const SizedBox(height: 4),
                Text(label,
                    style: TextStyle(
                        color: selected ? _navy : _navInactive,
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