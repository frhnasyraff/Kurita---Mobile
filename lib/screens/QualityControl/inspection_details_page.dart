// lib/pages/inspection_details_page.dart
import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../widgets/bottom_nav_bar.dart';
import 'quality_control_page.dart';
import '../stockIn/inventory_dashboard_page.dart';
import '../preproduct/pre_production_page.dart';
import '../stockIn/RM/stockIn_page.dart';

enum QCStatus { none, pass, fail }

class InspectionBatch {
  final int id;
  final String name;
  final String spec;
  final String unit;
  QCStatus status;
  String nominal;
  String remarks;

  InspectionBatch({
    required this.id,
    required this.name,
    required this.spec,
    this.unit = 'kg',
    this.status = QCStatus.none,
    this.nominal = '',
    this.remarks = '',
  });
}

class InspectionDetailsPage extends StatefulWidget {
  final String poNumber;
  final String companyName;

  const InspectionDetailsPage({
    super.key,
    required this.poNumber,
    required this.companyName,
  });

  @override
  State<InspectionDetailsPage> createState() => _InspectionDetailsPageState();
}

class _InspectionDetailsPageState extends State<InspectionDetailsPage> {
  static const navy = Color(0xFF17335C);
  static const passGreen = Color(0xFF1A6B3C);
  static const failRed = Color(0xFFCC2936);
  static const captionGrey = Color(0xFF8A99AD);
  static const skuBlue = Color(0xFF5B7FA6);
  static const fieldBorder = Color(0xFFE0E0E0);

  // ── Matches the palette used on Quality Control / Operational Hub ──
  static const primary = navy;
  static const secondaryContainer = Color(0xFFD1E1F4);
  static const outlineVariant = Color(0xFFC4C6CF);

  final _api = ApiClient.instance;
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  List<InspectionBatch> _batches = [];

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _api.init();
      final res = await _api.getPoBatches(widget.poNumber);
      final batches = List<Map<String, dynamic>>.from(res['batches'] as List);

      _batches = batches.map((b) {
        final statusStr = b['inspection_status'] as String?;
        QCStatus status = QCStatus.none;
        if (statusStr == 'passed') status = QCStatus.pass;
        if (statusStr == 'failed') status = QCStatus.fail;

        return InspectionBatch(
          id: b['id'] as int,
          name: b['raw_material_name'] as String,
          spec: b['specification'] as String? ?? b['sap_code'] as String? ?? '-',
          status: status,
          nominal: b['quantity_received_kg']?.toString() ?? '',
          remarks: b['qc_remarks'] as String? ?? '',
        );
      }).toList();

      setState(() => _loading = false);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _completeInspection() async {
    final pending = _batches.where((b) => b.status == QCStatus.none).length;
    if (pending > 0) {
      _showDialog('Incomplete', '$pending batch(es) belum PASS/FAIL.');
      return;
    }

    setState(() => _submitting = true);
    try {
      for (final batch in _batches) {
        if (batch.status == QCStatus.none) continue;

        await _api.startInspection(batch.id);

        await _api.completeInspection(
          batch.id,
          quantityKg: double.tryParse(batch.nominal) ?? 0,
          qcResult: batch.status == QCStatus.pass ? 'pass' : 'fail',
          qcRemarks: batch.status == QCStatus.pass ? batch.remarks : null,
          failureReason: batch.status == QCStatus.fail ? batch.remarks : null,
        );
      }

      if (!mounted) return;
      _showDialog('Done', 'Inspection submitted.', onOk: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StockInPage()),
        );
      });
    } catch (e) {
      _showDialog('Error', e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _showDialog(String title, String msg,
      {bool isError = false, VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
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

  void _navigateBottomNav(int index) {
    Widget? page;
    switch (index) {
      case 0:
        page = const QualityControlPage();
        break;
      case 1:
        page = const InventoryDashboardPage();
        break;
      case 2:
        page = const PreProductionPage();
        break;
      case 3:
        // Delivery — already part of the Receiving/Delivery flow this
        // page belongs to, so just pop back rather than re-pushing.
        Navigator.of(context).pop();
        return;
      default:
        return;
    }
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => page!));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_error != null) {
      return Scaffold(body: Center(child: Text(_error!)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.white,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: secondaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: outlineVariant),
              ),
              child: const Icon(Icons.account_circle_outlined,
                  color: primary, size: 24),
            ),
            const SizedBox(width: 10),
            const Text(
              'Workwise',
              style: TextStyle(
                color: navy,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: navy),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        items: const [
          (Icons.verified_outlined, 'Quality', true),
          (Icons.inventory_2_outlined, 'Inventory', false),
          (Icons.precision_manufacturing_outlined, 'Production', false),
          (Icons.local_shipping_outlined, 'Delivery', false),
          (Icons.more_horiz, 'Others', false),
        ],
        onItemTapped: _navigateBottomNav,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('INSPECTION DETAILS',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: navy)),
                    Text('${widget.poNumber} – ${widget.companyName}',
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    ..._batches.map(_buildCard),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _completeInspection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: navy,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: _submitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('COMPLETE INSPECTION',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800)),
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

  Widget _caption(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          color: captionGrey,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  InputDecoration _boxDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: captionGrey, fontWeight: FontWeight.normal),
      filled: true,
      fillColor: const Color(0xFFF6F6F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: fieldBorder),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: fieldBorder),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: navy),
      ),
    );
  }

  Widget _buildCard(InspectionBatch batch) {
    final isPass = batch.status == QCStatus.pass;
    final isFail = batch.status == QCStatus.fail;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isPass
              ? passGreen.withOpacity(0.4)
              : isFail
                  ? failRed.withOpacity(0.4)
                  : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(batch.name,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: navy, fontSize: 16)),
          const SizedBox(height: 2),
          Text('SKU: ${batch.spec}',
              style: const TextStyle(
                  color: skuBlue, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),

          _caption('QTY (${batch.unit.toUpperCase()})'),
          TextFormField(
            initialValue: batch.nominal,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _boxDecoration(),
            onChanged: (v) => batch.nominal = v,
          ),

          const SizedBox(height: 14),
          _caption('QC STATUS'),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => batch.status = QCStatus.fail),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: isFail ? failRed : Colors.white,
                      border: Border.all(color: isFail ? failRed : Colors.grey.shade400),
                    ),
                    child: Center(
                      child: Text('FAIL',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isFail ? Colors.white : failRed)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => batch.status = QCStatus.pass),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    decoration: BoxDecoration(
                      color: isPass ? passGreen : Colors.white,
                      border:
                          Border.all(color: isPass ? passGreen : Colors.grey.shade400),
                    ),
                    child: Center(
                      child: Text('PASS',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: isPass ? Colors.white : passGreen)),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          _caption('REMARKS'),
          TextFormField(
            initialValue: batch.remarks,
            decoration: _boxDecoration(hintText: 'Add remarks...'),
            onChanged: (v) => batch.remarks = v,
          ),
        ],
      ),
    );
  }
}