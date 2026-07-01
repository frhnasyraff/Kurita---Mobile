import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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

class StockInScanVerificationPage extends StatefulWidget {
  final ProductStockInJob job;
  final String? expectedQrData;
  final VoidCallback? onComplete;

  const StockInScanVerificationPage({
    super.key,
    required this.job,
    this.expectedQrData,
    this.onComplete,
  });

  @override
  State<StockInScanVerificationPage> createState() =>
      _StockInScanVerificationPageState();
}

class _StockInScanVerificationPageState
    extends State<StockInScanVerificationPage> {
  bool _productScanned = false;
  Map<String, dynamic>? _scannedDetails;

  int? _selectedLocationId;
  String? _selectedLocationLabel;
  bool _isLoadingLocations = false;
  bool _isSubmitting = false;
  List<dynamic> _locations = [];

  bool get _locationScanned => _selectedLocationId != null;
  bool get _canComplete => _productScanned && _locationScanned;

  Future<void> _scanProductQr() async {
    final scannedValue = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _QrScannerScreen()),
    );

    if (scannedValue == null || !mounted) return;

    Map<String, dynamic>? parsed;
    try {
      parsed = jsonDecode(scannedValue) as Map<String, dynamic>;
    } catch (_) {
      parsed = {"raw": scannedValue};
    }

    final scannedBatch = parsed['batch_id']?.toString();
    if (scannedBatch != null &&
        widget.job.batchId.isNotEmpty &&
        scannedBatch != widget.job.batchId) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "QR mismatch: scanned batch ($scannedBatch) does not match this job (${widget.job.batchId})",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _productScanned = true;
      _scannedDetails = parsed;
    });

    if (!mounted) return;
    _showScannedDetailsSheet(parsed);
  }

  void _showScannedDetailsSheet(Map<String, dynamic> details) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _Palette.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF16A34A)),
                const SizedBox(width: 8),
                Text("PRODUCT VERIFIED", style: _labelCaps(size: 13, color: const Color(0xFF16A34A))),
              ],
            ),
            const SizedBox(height: 16),
            if (details['product_name'] != null)
              _detailRow("Product", details['product_name'].toString()),
            if (details['batch_id'] != null)
              _detailRow("Batch ID", details['batch_id'].toString()),
            if (details['quantity'] != null)
              _detailRow("Quantity", "${details['quantity']} ${details['unit'] ?? ''}"),
            if (details['packaging_type'] != null)
              _detailRow("Packaging", details['packaging_type'].toString()),
            if (details['traceability_id'] != null)
              _detailRow("Trace ID", details['traceability_id'].toString()),
            if (details['raw'] != null)
              _detailRow("Scanned value", details['raw'].toString()),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _Palette.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  elevation: 0,
                ),
                child: Text("CONTINUE", style: _labelCaps(size: 12, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: _labelCaps(size: 11)),
          ),
          Expanded(
            child: Text(value, style: _mono(size: 13, weight: FontWeight.w700, color: _Palette.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _scanLocationQr() async {
    setState(() => _isLoadingLocations = true);
    try {
      final locations = await ApiClient.instance.getWarehouseLocations();
      setState(() {
        _locations = locations;
        _isLoadingLocations = false;
      });
      if (!mounted) return;
      _showLocationPicker();
    } catch (e) {
      setState(() => _isLoadingLocations = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load locations: $e")),
      );
    }
  }

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _Palette.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
      ),
      builder: (_) {
        if (_locations.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              "No warehouse locations available.",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 13, color: _Palette.onSurfaceVariant),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: _locations.length,
          itemBuilder: (context, index) {
            final loc = _locations[index] as Map<String, dynamic>;
            final label = (loc['display_code'] ?? loc['code'] ?? loc['name'] ?? 'Location ${loc['id']}').toString();
            return ListTile(
              leading: const Icon(Icons.location_on_outlined, color: _Palette.primary),
              title: Text(label, style: GoogleFonts.montserrat(fontSize: 14, color: _Palette.onSurface)),
              onTap: () {
                setState(() {
                  _selectedLocationId = int.parse(loc['id'].toString());
                  _selectedLocationLabel = label;
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _completeStockIn() async {
    if (!_canComplete || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      await ApiClient.instance.setProductStockInLocation(
        widget.job.productionJobId,
        warehouseLocationId: _selectedLocationId!,
      );

      widget.onComplete?.call();

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          title: Text("Stock In Complete", style: GoogleFonts.montserrat(fontWeight: FontWeight.w700)),
          content: Text(
            "${widget.job.productName} has been successfully stocked in at $_selectedLocationLabel.",
            style: GoogleFonts.montserrat(fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text("OK", style: GoogleFonts.montserrat(color: _Palette.primary, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to assign location: $e")));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  TextStyle _mono({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = _Palette.onSurface,
  }) {
    return GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: weight, color: color, height: 20 / 14);
  }

  TextStyle _labelCaps({double size = 10, Color color = _Palette.onSurfaceVariant}) {
    return GoogleFonts.montserrat(fontSize: size, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: color);
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
                    style: GoogleFonts.montserrat(fontSize: 20, fontWeight: FontWeight.w600, color: _Palette.primary),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text(
                "STOCK IN VERIFICATION",
                style: GoogleFonts.montserrat(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: _Palette.primary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 16),

              Container(
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
                        Text("SESSION DETAILS", style: _labelCaps(size: 11)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD8F3E8),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Text("ACTIVE_FLOW", style: _labelCaps(size: 9, color: const Color.fromARGB(255, 3, 42, 119))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _fieldLabelValue("JOB SHEET", "#${job.jobSheetNo}"),
                    const SizedBox(height: 12),
                    _fieldLabelValue("MATERIAL", job.productName),
                    const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _fieldLabelValue("BATCH ID", job.batchId),
                      const SizedBox(height: 12),
                      _fieldLabelValue("QUANTITY", job.quantity),
                    ],
                  ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _buildScanStep(
                stepNumber: 1,
                title: "SCAN PRODUCT QR",
                icon: Icons.qr_code_scanner,
                isDone: _productScanned,
                idleLabel: "TAP TO SCAN UNIT",
                doneLabel: "Product verified",
                statusLabel: _productScanned ? "Scan complete" : "Waiting for scan...",
                onTap: _scanProductQr,
              ),

              const SizedBox(height: 16),

              _buildScanStep(
                stepNumber: 2,
                title: "SCAN LOCATION QR",
                icon: Icons.location_on_outlined,
                isDone: _locationScanned,
                idleLabel: "TAP TO SCAN RACK LOCATION",
                doneLabel: _selectedLocationLabel ?? "Location verified",
                statusLabel: _locationScanned ? "Scan complete" : "Waiting for scan...",
                onTap: _scanLocationQr,
                enabled: _productScanned,
                isLoading: _isLoadingLocations,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_canComplete && !_isSubmitting) ? _completeStockIn : null,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.check_circle_outline, size: 18),
                  label: Text(
                    _isSubmitting ? "COMPLETING..." : "COMPLETE STOCK IN",
                    style: _labelCaps(size: 13, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canComplete ? _Palette.primary : _Palette.outline,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
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

  Widget _buildScanStep({
    required int stepNumber,
    required String title,
    required IconData icon,
    required bool isDone,
    required String idleLabel,
    required String doneLabel,
    required String statusLabel,
    required VoidCallback onTap,
    bool enabled = true,
    bool isLoading = false,
  }) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFF16A34A) : _Palette.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : Text("$stepNumber",
                          style: GoogleFonts.montserrat(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 8),
              Text(title, style: _labelCaps(size: 11)),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: (enabled && !isLoading) ? onTap : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: _Palette.surfaceContainerLowest,
                border: Border.all(
                  color: isDone ? const Color(0xFF16A34A) : _Palette.outlineVariant,
                ),
              ),
              child: Column(
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(
                      isDone ? Icons.check_circle : icon,
                      size: 40,
                      color: isDone ? const Color(0xFF16A34A) : _Palette.primary,
                    ),
                  const SizedBox(height: 10),
                  Text(
                    isDone ? doneLabel : idleLabel,
                    textAlign: TextAlign.center,
                    style: _labelCaps(
                      size: 12,
                      color: isDone ? const Color(0xFF16A34A) : _Palette.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isDone ? const Color(0xFFD8F3E8) : _Palette.surfaceContainerLow,
            ),
            child: Text(
              statusLabel,
              textAlign: TextAlign.center,
              style: _labelCaps(
                size: 11,
                color: isDone ? const Color(0xFF16A34A) : _Palette.outline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Full-screen QR scanner using device camera ──
class _QrScannerScreen extends StatefulWidget {
  const _QrScannerScreen();

  @override
  State<_QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<_QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final barcode = capture.barcodes.firstOrNull;
    final value = barcode?.rawValue;
    if (value == null) return;

    _handled = true;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: _Palette.primary,
        title: Text("Scan Product QR", style: GoogleFonts.montserrat(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: Border.all(color: Colors.white, width: 3).toDecoration(),
            ),
          ),
        ],
      ),
    );
  }
}

extension on Border {
  BoxDecoration toDecoration() => BoxDecoration(border: this);
}