import 'package:flutter/material.dart';

class AdjustmentItem {
  String rmCode;
  double qty;
  AdjustmentItem({required this.rmCode, required this.qty});
}

class AdjustmentPage extends StatefulWidget {
  final String jobSheetNumber;
  final String productName;

  const AdjustmentPage({
    super.key,
    this.jobSheetNumber = '#JOB-2024-012',
    this.productName = 'Industrial Disinfectant X1',
  });

  @override
  State<AdjustmentPage> createState() => _AdjustmentPageState();
}

class _AdjustmentPageState extends State<AdjustmentPage> {
  static const Color _navy       = Color(0xFF17335C);
  static const Color _surface    = Color(0xFFF4F7FB);
  static const Color _border     = Color(0xFFE4EAF2);
  static const Color _textMuted  = Color(0xFF8A99AD);
  static const Color _textDark   = Color(0xFF1A2A3A);
  static const Color _navInactive = Color(0xFF98A6B7);
  static const Color _red        = Color(0xFFDC2626);
  static const Color _redBg      = Color(0xFFFEF2F2);

  final _remarkController = TextEditingController(
    text: 'Added 2.5kg of Thickening Agent T-400 to compensate for viscosity deviation. Batch re-mixed for 15 minutes at 450 RPM.',
  );
  final _materialNameController = TextEditingController();
  final _sapCodeController = TextEditingController(text: 'RM-T400-X');
  final _batchNoController = TextEditingController(text: 'B-XXXX');
  final _netWtController = TextEditingController(text: '2.50');
  final _grossWtController = TextEditingController(text: '2.75');
  final _qcRefController = TextEditingController(text: '9942');

  DateTime _reTestDate = DateTime(2024, 5, 24, 14, 30);
  late List<AdjustmentItem> _items;

  @override
  void initState() {
    super.initState();
    _items = [
      AdjustmentItem(rmCode: 'RM-T400-X', qty: 2.500),
      AdjustmentItem(rmCode: 'SOLV-ETH-04', qty: 1.250),
    ];
  }

  @override
  void dispose() {
    _remarkController.dispose();
    _materialNameController.dispose();
    _sapCodeController.dispose();
    _batchNoController.dispose();
    _netWtController.dispose();
    _grossWtController.dispose();
    _qcRefController.dispose();
    super.dispose();
  }

  InputDecoration get _inputDeco => InputDecoration(
    filled: true,
    fillColor: _surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _border)),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _border)),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _navy, width: 1.4)),
    hintStyle: const TextStyle(color: _textMuted, fontSize: 12),
  );

  String _formatDateTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'pm' : 'am';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}, $h:$min $ampm';
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reTestDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reTestDate));
    if (time == null || !mounted) return;
    setState(() => _reTestDate =
        DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  void _addToList() {
    final code = _sapCodeController.text.trim();
    final qty = double.tryParse(_netWtController.text.trim()) ?? 0;
    if (code.isEmpty || qty == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Please enter SAP code and net weight.'),
          backgroundColor: _navy));
      return;
    }
    setState(() {
      _items.add(AdjustmentItem(rmCode: code, qty: qty));
      _sapCodeController.clear();
      _batchNoController.clear();
      _netWtController.clear();
      _grossWtController.clear();
      _materialNameController.clear();
    });
  }

  void _complete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adjustment Complete'),
        content: Text('Adjustment for ${widget.jobSheetNumber} submitted successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK',
                style: TextStyle(color: _navy, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      bottomNavigationBar: _buildNavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildTitle(),
              const SizedBox(height: 16),
              _buildBanner(),
              const SizedBox(height: 16),
              _buildRemarkCard(),
              const SizedBox(height: 16),
              _buildRMCard(),
              const SizedBox(height: 16),
              _buildRetestCard(),
              const SizedBox(height: 24),
              _buildButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: _navy, borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 18),
      ),
      const SizedBox(width: 10),
      const Text('Workwise',
          style: TextStyle(color: _navy, fontSize: 18, fontWeight: FontWeight.w800)),
      const Spacer(),
      _iconBtn(Icons.settings_outlined, _textMuted, () {}),
      const SizedBox(width: 8),
      _iconBtn(Icons.arrow_back_ios_new_rounded, _navy, () => Navigator.pop(context)),
    ],
  );

  Widget _iconBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _border)),
          child: Icon(icon, color: color, size: 16),
        ),
      );

  Widget _buildTitle() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('ADJUSTMENT',
          style: TextStyle(color: _textDark, fontSize: 26,
              fontWeight: FontWeight.w900, letterSpacing: -0.5)),
      const SizedBox(height: 4),
      Text('JOB SHEET: ${widget.jobSheetNumber}',
          style: const TextStyle(color: _textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
      Text(widget.productName,
          style: const TextStyle(color: _textMuted, fontSize: 11, fontWeight: FontWeight.w600)),
    ],
  );

  Widget _buildBanner() => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
        color: _redBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _red.withOpacity(0.3))),
    child: Row(
      children: [
        const Icon(Icons.warning_amber_rounded, color: _red, size: 20),
        const SizedBox(width: 10),
        const Expanded(
          child: Text('ADJUSTMENT\nREQUIRED',
              style: TextStyle(color: _red, fontSize: 12,
                  fontWeight: FontWeight.w800, height: 1.3)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('QC-REF:',
                  style: TextStyle(fontSize: 9, color: _textMuted, fontWeight: FontWeight.w600)),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _qcRefController,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _navy),
                  decoration: const InputDecoration(
                      isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildRemarkCard() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(children: [
          Icon(Icons.edit_note_rounded, color: _navy, size: 18),
          SizedBox(width: 6),
          Text('REMARK', style: TextStyle(fontSize: 11,
              fontWeight: FontWeight.w800, color: _navy, letterSpacing: 0.4)),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: _remarkController,
          maxLines: 4,
          style: const TextStyle(fontSize: 13, color: _textDark, height: 1.5),
          decoration: _inputDeco.copyWith(hintText: 'Enter remark...'),
        ),
      ],
    ),
  );

  Widget _buildRMCard() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text('RAW MATERIAL ADDITIONS',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                  color: _textDark, letterSpacing: 0.4)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: _navy.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
            child: Text('${_items.length} ITEMS LOGGED',
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _navy)),
          ),
        ]),
        const SizedBox(height: 14),
        _label('MATERIAL NAME'),
        const SizedBox(height: 6),
        TextField(controller: _materialNameController,
            style: const TextStyle(fontSize: 13, color: _textDark),
            decoration: _inputDeco.copyWith(hintText: 'Search RM Inventory...')),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('SAP CODE'), const SizedBox(height: 6),
            TextField(controller: _sapCodeController,
                style: const TextStyle(fontSize: 13, color: _textDark),
                decoration: _inputDeco.copyWith(hintText: 'RM-T400-X')),
          ])),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('BATCH NO'), const SizedBox(height: 6),
            TextField(controller: _batchNoController,
                style: const TextStyle(fontSize: 13, color: _textDark),
                decoration: _inputDeco.copyWith(hintText: 'B-XXXX')),
          ])),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('NET WT (KG)'), const SizedBox(height: 6),
            TextField(controller: _netWtController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 13, color: _textDark),
                decoration: _inputDeco),
          ])),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _label('GROSS WT (KG)'), const SizedBox(height: 6),
            TextField(controller: _grossWtController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 13, color: _textDark),
                decoration: _inputDeco),
          ])),
        ]),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _addToList,
            icon: const Icon(Icons.add, color: Colors.white, size: 16),
            label: const Text('ADD TO ADJUSTMENT LIST',
                style: TextStyle(color: Colors.white, fontSize: 12,
                    fontWeight: FontWeight.w800, letterSpacing: 0.3)),
            style: ElevatedButton.styleFrom(
              backgroundColor: _navy,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ),
        if (_items.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(color: _border),
          const SizedBox(height: 8),
          const Row(children: [
            Expanded(child: Text('RM CODE',
                style: TextStyle(fontSize: 9, color: _textMuted,
                    fontWeight: FontWeight.w700, letterSpacing: 0.6))),
            Text('QTY (KG)',
                style: TextStyle(fontSize: 9, color: _textMuted,
                    fontWeight: FontWeight.w700, letterSpacing: 0.6)),
            SizedBox(width: 32),
          ]),
          const SizedBox(height: 8),
          ..._items.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(children: [
              Expanded(child: Text(e.value.rmCode,
                  style: const TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w700, color: _textDark))),
              Text(e.value.qty.toStringAsFixed(3),
                  style: const TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w600, color: _textDark)),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => setState(() => _items.removeAt(e.key)),
                child: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                      color: _red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.delete_outline, color: _red, size: 14),
                ),
              ),
            ]),
          )),
        ],
      ],
    ),
  );

  Widget _buildRetestCard() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('RETEST SCHEDULING',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                color: _textDark, letterSpacing: 0.4)),
        const SizedBox(height: 12),
        _label('RETEST DATE/TIME'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _pickDateTime,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _border)),
            child: Row(children: [
              Expanded(child: Text(_formatDateTime(_reTestDate),
                  style: const TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w600, color: _textDark))),
              const Icon(Icons.calendar_today_outlined, size: 16, color: _textMuted),
              const SizedBox(width: 6),
              const Icon(Icons.access_time, size: 16, color: _textMuted),
            ]),
          ),
        ),
      ],
    ),
  );

  Widget _buildButtons() => Row(
    children: [
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, size: 16, color: _textDark),
          label: const Text('BACK',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _textDark)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: const BorderSide(color: _border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: ElevatedButton.icon(
          onPressed: _complete,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 16),
          label: const Text('COMPLETED',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _navy,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ),
    ],
  );

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
        boxShadow: const [BoxShadow(
            color: Color(0x0A18304D), blurRadius: 6, offset: Offset(0, 2))]),
    child: child,
  );

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 9, color: _textMuted,
          fontWeight: FontWeight.w600, letterSpacing: 0.8));

  Widget _buildNavBar() {
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
            border: Border(top: BorderSide(color: Color(0xFFE4EAF2)))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            final (icon, label, selected) = item;
            return Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 22, color: selected ? _navy : _navInactive),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(
                  color: selected ? _navy : _navInactive,
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600)),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}