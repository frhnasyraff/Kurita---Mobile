import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../../services/api_client.dart';
import 'product_stock_in_page.dart';

// ─────────────────────────────────────────
// THEME (matches product_stock_in_page.dart)
// ─────────────────────────────────────────
class _Palette {
  static const primary = Color(0xFF002046);
  static const primaryContainer = Color(0xFF1B365D);
  static const onPrimaryContainer = Color(0xFF87A0CD);
  static const onPrimary = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF8F9FA);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F4F5);
  static const outline = Color(0xFF74777F);
  static const outlineVariant = Color(0xFFC4C6CF);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF44474E);
}

class StockInVerificationPage extends StatefulWidget {
  final ProductStockInJob job;
  final ValueChanged<ProductStockInJob>? onSubmitted;

  const StockInVerificationPage({
    super.key,
    required this.job,
    this.onSubmitted,
  });

  @override
  State<StockInVerificationPage> createState() =>
      _StockInVerificationPageState();
}

class _StockInVerificationPageState extends State<StockInVerificationPage> {
  late TextEditingController _qtyController;
  String _selectedUnit = "Kilograms (KG)";
  String _selectedPackaging = "IBC";
  bool _qrGenerated = false;
  String _traceabilityId = "";
  String _qrData = "";
  bool _isSubmitting = false;

  final List<String> _units = ["Kilograms (KG)", "Litres (L)", "Pieces (PCS)"];
  final List<String> _packagingTypes = ["IBC", "Drum", "Pallet", "Carton"];

  @override
  void initState() {
    super.initState();
    final numericQty = widget.job.quantity.replaceAll(RegExp(r'[^0-9.]'), '');
    _qtyController = TextEditingController(text: numericQty);
    if (widget.job.packagingType.isNotEmpty) {
      final match = _packagingTypes.firstWhere(
        (p) => p.toLowerCase() == widget.job.packagingType.toLowerCase(),
        orElse: () => _selectedPackaging,
      );
      _selectedPackaging = match;
    }
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _generateQrCode() {
    final qtyText = _qtyController.text.trim();
    final unitShort = _selectedUnit.split(" ").first;

    setState(() {
      _qrGenerated = true;
      _traceabilityId =
          "#QR-${widget.job.jobSheetNo.replaceFirst('JOB-', '')}-001X";

      _qrData = jsonEncode({
        "job_sheet_no": widget.job.jobSheetNo,
        "batch_id": widget.job.batchId,
        "product_name": widget.job.productName,
        "quantity": qtyText,
        "unit": unitShort,
        "packaging_type": _selectedPackaging,
        "traceability_id": _traceabilityId,
      });
    });
  }

  Future<void> _submitStockIn() async {
    if (!_qrGenerated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please generate QR code first")),
      );
      return;
    }

    final qtyText = _qtyController.text.trim();
    final qty = double.tryParse(qtyText);

    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid quantity")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ApiClient.instance.submitProductStockIn(
        productionJobId: widget.job.productionJobId,
        quantityKg: qty,
        batchNumber: widget.job.batchId,
        notes: 'Packaging: $_selectedPackaging | Label: $_traceabilityId',
      );

      final unitShort = _selectedUnit.split(" ").first;
      final promotedJob = widget.job.copyWith(
        status: "IN PROGRESS",
        isLabelled: true,
        packagingType: _selectedPackaging.toUpperCase(),
        quantity: "$qtyText $unitShort",
      );

      widget.onSubmitted?.call(promotedJob);

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: Text("Stock In Submitted",
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
          content: Text(
            "${widget.job.productName} has been labelled and moved to In Progress.",
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text("OK",
                  style: GoogleFonts.montserrat(
                      color: _Palette.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit: $e")),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  TextStyle _mono({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = _Palette.onSurface,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 20 / 14,
    );
  }

  TextStyle _labelCaps({
    double size = 10,
    Color color = _Palette.onSurfaceVariant,
  }) {
    return GoogleFonts.montserrat(
      fontSize: size,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      backgroundColor: _Palette.surface,
      bottomNavigationBar: BottomNavBar(
        items: const [
          (Icons.verified_outlined, 'Quality', false),
          (Icons.inventory_2_outlined, 'Inventory', true),
          (Icons.precision_manufacturing_outlined, 'Production', false),
          (Icons.local_shipping_outlined, 'Delivery', false),
          (Icons.more_horiz, 'Others', false),
        ],
        onItemTapped: (index) {
          if (index == 1) return;
          Navigator.of(context).pop();
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.menu, color: _Palette.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Workwise",
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _Palette.primary,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.notifications_outlined, color: _Palette.primary, size: 22),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                "STOCK IN VERIFICATION",
                style: _labelCaps(size: 12),
              ),
              const SizedBox(height: 2),
              Text(
                "#${job.jobSheetNo}",
                style: GoogleFonts.montserrat(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _Palette.primary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text("UNLABELLED", style: _labelCaps(size: 9, color: const Color(0xFFDC2626))),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildCard(
                title: "CONFIRM PRODUCT & QTY",
                titleIcon: Icons.inventory_2_outlined,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: _fieldLabelValue("MATERIAL", job.productName),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: _miniInfoBox("BATCH ID", job.batchId),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text("QUANTITY (KG)", style: _labelCaps()),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _qtyController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _Palette.primary,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: _Palette.surfaceContainerLow,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: _Palette.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(color: _Palette.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: _Palette.primary, width: 1.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            label: "UNITS",
                            value: _selectedUnit,
                            items: _units,
                            onChanged: (v) =>
                                setState(() => _selectedUnit = v!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDropdown(
                            label: "PACKAGING TYPE",
                            value: _selectedPackaging,
                            items: _packagingTypes,
                            onChanged: (v) =>
                                setState(() => _selectedPackaging = v!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _generateQrCode,
                  icon: const Icon(Icons.qr_code_2, size: 18),
                  label: Text("GENERATE QR CODE", style: _labelCaps(size: 13, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _Palette.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _buildQrPreview(),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitStockIn,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(
                    _isSubmitting ? "SUBMITTING..." : "SUBMIT STOCK IN",
                    style: _labelCaps(size: 13, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (_qrGenerated && !_isSubmitting)
                        ? _Palette.primary
                        : _Palette.outline,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData titleIcon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Palette.surfaceContainerLowest,
        border: Border.all(color: _Palette.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _Palette.primary,
                ),
              ),
              Icon(titleIcon, size: 20, color: _Palette.primary),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _miniInfoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _Palette.surfaceContainerLow,
        border: Border.all(color: _Palette.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _labelCaps(size: 9)),
          Text(value, style: _mono(size: 13, weight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _fieldLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelCaps()),
        const SizedBox(height: 4),
        Text(value, style: _mono(size: 14, weight: FontWeight.w700, color: _Palette.primary)),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: _labelCaps()),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: _Palette.surfaceContainerLow,
            border: Border.all(color: _Palette.outlineVariant),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
              style: GoogleFonts.montserrat(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _Palette.primary,
              ),
              items: items
                  .map((item) =>
                      DropdownMenuItem(value: item, child: Text(item)))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: _Palette.surfaceContainerLowest,
        border: Border.all(color: _Palette.outlineVariant),
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: Border.all(
                color: _qrGenerated ? _Palette.primary : _Palette.outlineVariant,
              ),
            ),
            child: _qrGenerated
                ? QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: _Palette.primary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: _Palette.primary,
                    ),
                  )
                : Icon(
                    Icons.qr_code_2_outlined,
                    size: 56,
                    color: _Palette.outlineVariant,
                  ),
          ),
          const SizedBox(height: 14),
          Text(
            _qrGenerated ? "UNIQUE TRACEABILITY ID" : "NO QR CODE GENERATED",
            style: _labelCaps(size: 10, color: _Palette.outline),
          ),
          const SizedBox(height: 4),
          Text(
            _qrGenerated ? _traceabilityId : "GENERATE QR CODE ABOVE",
            style: _mono(size: 12, weight: FontWeight.w700, color: _Palette.primary),
          ),
          if (_qrGenerated) ...[
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print_outlined, size: 16),
              label: Text("PRINT QR LABEL", style: _labelCaps(size: 11, color: _Palette.primary)),
              style: TextButton.styleFrom(foregroundColor: _Palette.primary),
            ),
          ],
        ],
      ),
    );
  }
}