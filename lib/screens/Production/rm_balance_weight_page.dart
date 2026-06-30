import 'package:flutter/material.dart';
import '../QualityControl/dashboard_page.dart';
import '../PreProduct/pre_production_page.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────

class RMItem {
  final String name;
  final String lot;
  String qty;
  bool scanned;

  RMItem({
    required this.name,
    required this.lot,
    this.qty = '',
    this.scanned = false,
  });
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class RmBalanceWeightPage extends StatefulWidget {
  final String jobId;
  final String poNumber;
  final String allCode;

  const RmBalanceWeightPage({
    super.key,
    this.jobId = 'JOB-2024-052',
    this.poNumber = 'PO-8826-052',
    this.allCode = 'ALL: A12',
  });

  @override
  State<RmBalanceWeightPage> createState() => _RmBalanceWeightPageState();
}

class _RmBalanceWeightPageState extends State<RmBalanceWeightPage> {
  static const Color navy       = Color(0xFF17335C);
  static const Color bgLight    = Color(0xFFF4F7FB);
  static const Color cardWhite  = Colors.white;
  static const Color borderGrey = Color(0xFFE5E7EB);
  static const Color scanBlue   = Color(0xFF1A56DB);
  static const Color textDark   = Color(0xFF17335C);
  static const Color textGrey   = Color(0xFF8A99AD);
  static const Color inputBg    = Color(0xFFF9FAFB);

  int _currentNavIndex = 2;

  late List<RMItem> _items;
  final Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _items = [
      RMItem(name: 'Sodium Hypochlorite', lot: 'LOT: SH-2024-09-A12'),
      RMItem(name: 'Thickener T-400',     lot: 'LOT: TK-400-991-8'),
      RMItem(name: 'Fragrance (Ocean Mist)', lot: 'LOT: FR-05-364-A'),
    ];
    for (int i = 0; i < _items.length; i++) {
      _controllers[i] = TextEditingController(text: _items[i].qty);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    super.dispose();
  }

  // ── Fake Scan (for emulator testing) ─────────────────────────────────────
  void _onScan(int index) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final fakeResult = 'UNF-${_items[index].lot.replaceAll('LOT: ', '')}';
    setState(() => _items[index].scanned = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Scanned: $fakeResult'),
        backgroundColor: scanBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  void _onSubmit() {
    final unscanned = _items.where((i) => !i.scanned).length;
    final emptyQty  = _items.where((i) => i.qty.trim().isEmpty).length;

    if (unscanned > 0) {
      _showDialog('⚠️ Scan Required',
          '$unscanned item(s) have not been scanned yet.');
      return;
    }
    if (emptyQty > 0) {
      _showDialog('⚠️ Quantity Required',
          '$emptyQty item(s) are missing quantity.');
      return;
    }
    _showDialog(
      '✅ Submitted',
      'RM Balance Weight for ${widget.jobId} submitted successfully.',
      onOk: () => Navigator.pop(context),
    );
  }

  void _showDialog(String title, String message, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onOk?.call();
            },
            child: const Text('OK',
                style: TextStyle(
                    color: navy, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  void _onNavTap(int index) {
    if (index == _currentNavIndex) return;
    setState(() => _currentNavIndex = index);
    if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PreProductionPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardPage()),
      );
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final allFilled = _items.every((i) => i.scanned && i.qty.trim().isNotEmpty);

    return Scaffold(
      backgroundColor: bgLight,
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 14),
              _buildBadgeRow(),
              const SizedBox(height: 10),
              _buildTitleBlock(),
              const SizedBox(height: 18),
              ..._items.asMap().entries.map(
                    (e) => _buildItemCard(e.key, e.value),
              ),
              const SizedBox(height: 12),
              _buildSubmitButton(allFilled),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: navy,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.table_chart_outlined,
            color: Colors.white, size: 16),
      ),
      const SizedBox(width: 8),
      const Text('Workwise',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textDark)),
      const Spacer(),
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderGrey),
          ),
          child: const Icon(Icons.chevron_left, color: navy, size: 18),
        ),
      ),
      const SizedBox(width: 10),
      Icon(Icons.settings_outlined, color: textGrey, size: 20),
    ],
  );

  // ── Badge Row ─────────────────────────────────────────────────────────────
  Widget _buildBadgeRow() => Wrap(
    spacing: 6,
    children: [
      _badge(Icons.work_outline, widget.jobId),
      _badge(Icons.receipt_outlined, widget.poNumber),
      _badge(Icons.label_outline, widget.allCode),
    ],
  );

  Widget _badge(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: navy.withOpacity(0.07),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: navy),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: navy,
                fontWeight: FontWeight.w600)),
      ],
    ),
  );

  // ── Title Block ───────────────────────────────────────────────────────────
  Widget _buildTitleBlock() => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'RM BALANCE WEIGHT',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: textDark,
          letterSpacing: 0.3,
        ),
      ),
      SizedBox(height: 4),
      Text(
        'Update remaining raw material stock levels\nafter batch processing completion.',
        style: TextStyle(
          fontSize: 11,
          color: textGrey,
          height: 1.5,
        ),
      ),
    ],
  );

  // ── Item Card ─────────────────────────────────────────────────────────────
  Widget _buildItemCard(int index, RMItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(
            color: item.scanned ? Colors.green : navy,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name + scanned badge
            Row(
              children: [
                Expanded(
                  child: Text(item.name,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: textDark)),
                ),
                if (item.scanned)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('SCANNED',
                        style: TextStyle(
                            fontSize: 9,
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(item.lot,
                style: const TextStyle(fontSize: 11, color: textGrey)),
            const SizedBox(height: 12),

            // QTY + SCAN row
            Row(
              children: [
                // QTY
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('QTY',
                          style: TextStyle(
                              fontSize: 9,
                              color: textGrey,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _controllers[index],
                        onChanged: (v) => setState(() => item.qty = v),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                            color: textDark, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: const TextStyle(
                              color: textGrey, fontSize: 12),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          filled: true,
                          fillColor: inputBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                            const BorderSide(color: borderGrey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                            const BorderSide(color: borderGrey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: navy),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // SCAN
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SCAN',
                          style: TextStyle(
                              fontSize: 9,
                              color: textGrey,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1)),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _onScan(index),
                          icon: const Icon(Icons.qr_code_scanner,
                              size: 14, color: Colors.white),
                          label: const Text('SCAN UNF CODE',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: item.scanned
                                ? Colors.green[700]
                                : scanBlue,
                            padding: const EdgeInsets.symmetric(
                                vertical: 11),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit Button ─────────────────────────────────────────────────────────
  Widget _buildSubmitButton(bool allFilled) => SizedBox(
    width: double.infinity,
    child: ElevatedButton.icon(
      onPressed: _onSubmit,
      icon: const Icon(Icons.send, color: Colors.white, size: 16),
      label: const Text('SUBMIT',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.2)),
      style: ElevatedButton.styleFrom(
        backgroundColor: allFilled ? navy : Colors.grey[400],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    ),
  );

  // ── Bottom Nav ────────────────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      (Icons.verified_outlined, 'Quality'),
      (Icons.inventory_2_outlined, 'Inventory'),
      (Icons.precision_manufacturing_outlined, 'Production'),
      (Icons.local_shipping_outlined, 'Delivery'),
      (Icons.more_horiz_outlined, 'Others'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4EAF2))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final selected = index == _currentNavIndex;
            return GestureDetector(
              onTap: () => _onNavTap(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.$1,
                      size: 20,
                      color: selected ? navy : textGrey),
                  const SizedBox(height: 4),
                  Text(item.$2,
                      style: TextStyle(
                          color: selected ? navy : textGrey,
                          fontSize: 10,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500)),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}