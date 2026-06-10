import 'package:flutter/material.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────

enum QCStatus { none, pass, fail }

class InspectionItem {
  final String name;
  final String spec;
  final String unit;
  QCStatus status;
  String nominal;
  String remarks;

  InspectionItem({
    required this.name,
    required this.spec,
    required this.unit,
    this.status = QCStatus.none,
    this.nominal = '',
    this.remarks = '',
  });
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class InspectionDetailsPage extends StatefulWidget {
  final String poNumber;
  final String companyName;

  const InspectionDetailsPage({
    super.key,
    this.poNumber = 'PO-8842',
    this.companyName = 'Industrial Alloys Inc.',
  });

  @override
  State<InspectionDetailsPage> createState() => _InspectionDetailsPageState();
}

class _InspectionDetailsPageState extends State<InspectionDetailsPage> {
  // ── Colours ──────────────────────────────────────────────────────────────
  static const Color navy       = Color(0xFF17335C);
  static const Color bgLight    = Color(0xFFF5F6F8);
  static const Color passGreen  = Color(0xFF1A6B3C);
  static const Color failRed    = Color(0xFFCC2936);
  static const Color borderGrey = Color(0xFFE5E7EB);

  late List<InspectionItem> _items;
  final Map<int, TextEditingController> _nominalControllers = {};
  final Map<int, TextEditingController> _remarksControllers = {};

  @override
  void initState() {
    super.initState();
    _items = [
      InspectionItem(
        name: 'Aluminum Grade A',
        spec: '6061-T6 | 2.5mm thick',
        unit: 'kg',
        status: QCStatus.pass,
        nominal: '24.5',
        remarks: 'Within tolerance',
      ),
      InspectionItem(
        name: 'Steel Coil 304',
        spec: '1.2mm | Cold Rolled',
        unit: 'kg/m²',
      ),
      InspectionItem(
        name: 'Copper Rods',
        spec: 'C110 | 10mm dia',
        unit: 'pcs',
        status: QCStatus.fail,
        remarks: 'Surface oxidation detected',
      ),
      InspectionItem(
        name: 'Zinc Ingots',
        spec: 'ZN-001 | 99.9% pure',
        unit: 'kg',
        status: QCStatus.pass,
      ),
      InspectionItem(
        name: 'Nickel Plate',
        spec: 'NI-200 | 3mm thick',
        unit: 'sheets',
      ),
    ];

    // Init controllers
    for (int i = 0; i < _items.length; i++) {
      _nominalControllers[i] =
          TextEditingController(text: _items[i].nominal);
      _remarksControllers[i] =
          TextEditingController(text: _items[i].remarks);
    }
  }

  @override
  void dispose() {
    for (final c in _nominalControllers.values) c.dispose();
    for (final c in _remarksControllers.values) c.dispose();
    super.dispose();
  }

  // ── Validation & Submit ───────────────────────────────────────────────────

  void _completeInspection() {
    final pending = _items.where((i) => i.status == QCStatus.none).length;
    if (pending > 0) {
      _showDialog(
        '⚠️ Incomplete Inspection',
        '$pending item(s) have no QC status set. Please PASS or FAIL all items before completing.',
        isError: true,
      );
      return;
    }

    final failed = _items.where((i) => i.status == QCStatus.fail).length;
    final passed = _items.where((i) => i.status == QCStatus.pass).length;

    _showDialog(
      '✅ Inspection Complete',
      'Summary:\n• Passed: $passed item(s)\n• Failed: $failed item(s)\n\nInspection submitted successfully.',
      isError: false,
      onOk: () => Navigator.pop(context),
    );
  }

  void _showDialog(String title, String message,
      {bool isError = false, VoidCallback? onOk}) {
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
            child: Text('OK',
                style: TextStyle(
                    color: isError ? failRed : navy,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildTitle(),
                    const SizedBox(height: 20),
                    ..._items.asMap().entries.map((e) => _buildCard(e.key, e.value)),
                    const SizedBox(height: 16),
                    _buildCompleteButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: navy,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.inventory_2_outlined,
            color: Colors.white, size: 18),
      ),
      const SizedBox(width: 10),
      const Text('Workwise',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: navy)),
      const Spacer(),
      IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new, color: navy, size: 18),
      ),
    ],
  );

  // ── Title Block ───────────────────────────────────────────────────────────

  Widget _buildTitle() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('INSPECTION DETAILS',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: navy,
              letterSpacing: 0.5)),
      const SizedBox(height: 4),
      Text('${widget.poNumber} – ${widget.companyName}',
          style: const TextStyle(fontSize: 13, color: Colors.grey)),
    ],
  );

  // ── Material Card ─────────────────────────────────────────────────────────

  Widget _buildCard(int index, InspectionItem item) {
    final isPass = item.status == QCStatus.pass;
    final isFail = item.status == QCStatus.fail;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPass
              ? passGreen.withOpacity(0.4)
              : isFail
              ? failRed.withOpacity(0.4)
              : borderGrey,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Material name
            Text(item.name,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: navy)),
            const SizedBox(height: 2),
            Text(item.spec,
                style:
                const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 14),

            // QTY SPEC & QTY UNIT row
            Row(
              children: [
                Expanded(child: _labelField('QTY SPEC', item.spec)),
                const SizedBox(width: 12),
                Expanded(child: _labelField('QTY (UNIT)', item.unit)),
              ],
            ),
            const SizedBox(height: 12),

            // QC STATUS
            _sectionLabel('QC STATUS'),
            const SizedBox(height: 8),
            Row(
              children: [
                // FAIL button
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                            () => item.status = QCStatus.fail),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: isFail ? failRed : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isFail ? failRed : borderGrey,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'FAIL',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isFail ? Colors.white : failRed,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // PASS button
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(
                            () => item.status = QCStatus.pass),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        color: isPass ? passGreen : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isPass ? passGreen : borderGrey,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'PASS',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: isPass ? Colors.white : passGreen,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // NOMINAL
            _sectionLabel('NOMINAL'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _nominalControllers[index],
              onChanged: (v) => item.nominal = v,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              decoration: _inputDecoration('Enter nominal value'),
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 12),

            // REMARKS
            _sectionLabel('REMARKS'),
            const SizedBox(height: 6),
            TextFormField(
              controller: _remarksControllers[index],
              onChanged: (v) => item.remarks = v,
              maxLines: 2,
              decoration: _inputDecoration('Add remarks...'),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ── Complete Button ───────────────────────────────────────────────────────

  Widget _buildCompleteButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _completeInspection,
      style: ElevatedButton.styleFrom(
        backgroundColor: navy,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: const Text(
        'COMPLETE INSPECTION',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    ),
  );

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) => Text(
    label,
    style: const TextStyle(
      fontSize: 10,
      color: Colors.grey,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.2,
    ),
  );

  Widget _labelField(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2)),
      const SizedBox(height: 6),
      Container(
        width: double.infinity,
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderGrey),
        ),
        child: Text(value,
            style: const TextStyle(fontSize: 13, color: navy)),
      ),
    ],
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
    contentPadding:
    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    filled: true,
    fillColor: const Color(0xFFF9FAFB),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: borderGrey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: borderGrey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: navy),
    ),
  );
}