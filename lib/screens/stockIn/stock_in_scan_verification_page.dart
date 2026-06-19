import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import 'product_stock_in_page.dart';

// ─────────────────────────────────────────
// PAGE — Scan-based Stock In Verification
// (used for IN PROGRESS items that already have a Lot/QR assigned)
// ─────────────────────────────────────────
class StockInScanVerificationPage extends StatefulWidget {
  final ProductStockInJob job;
  final VoidCallback? onComplete;

  const StockInScanVerificationPage({
    super.key,
    required this.job,
    this.onComplete,
  });

  @override
  State<StockInScanVerificationPage> createState() =>
      _StockInScanVerificationPageState();
}

class _StockInScanVerificationPageState
    extends State<StockInScanVerificationPage> {
  bool _productScanned = false;
  bool _locationScanned = false;

  bool get _canComplete => _productScanned && _locationScanned;

  void _scanProductQr() {
    // TODO: integrate actual QR/UHF scanner
    setState(() => _productScanned = true);
  }

  void _scanLocationQr() {
    // TODO: integrate actual QR scanner
    setState(() => _locationScanned = true);
  }

  void _completeStockIn() {
    if (!_canComplete) return;

    // Call the onComplete callback to move item to COMPLETE tab
    widget.onComplete?.call();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Stock In Complete"),
        content: Text(
          "${widget.job.productName} has been successfully stocked in.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // close dialog
              Navigator.of(context).pop(); // back to list
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
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
              // ── Header ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF17335C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Workwise",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF17335C),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Title ──
              const Text(
                "STOCK IN VERIFICATION",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF17335C),
                ),
              ),

              const SizedBox(height: 16),

              // ── Session Details ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "SESSION DETAILS",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9CA3AF),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD8F3E8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            "ACTIVE_FLOW",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF16A34A),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _fieldLabelValue("JOB SHEET", "#${job.jobSheetNo}"),
                    const SizedBox(height: 12),
                    _fieldLabelValue("MATERIAL", job.productName),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _fieldLabelValue("BATCH ID", job.batchId),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _fieldLabelValue("QUANTITY", job.quantity),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Step 1: Scan Product QR ──
              _buildScanStep(
                stepNumber: 1,
                title: "SCAN PRODUCT QR",
                icon: Icons.qr_code_scanner,
                isDone: _productScanned,
                idleLabel: "TAP TO SCAN UNIT",
                doneLabel: "Product verified",
                statusLabel: _productScanned
                    ? "Scan complete"
                    : "Waiting for scan...",
                onTap: _scanProductQr,
              ),

              const SizedBox(height: 16),

              // ── Step 2: Scan Location QR ──
              _buildScanStep(
                stepNumber: 2,
                title: "SCAN LOCATION QR",
                icon: Icons.location_on_outlined,
                isDone: _locationScanned,
                idleLabel: "TAP TO SCAN BUND",
                doneLabel: "Location verified",
                statusLabel: _locationScanned
                    ? "Scan complete"
                    : "Waiting for scan...",
                onTap: _scanLocationQr,
                enabled: _productScanned,
              ),

              const SizedBox(height: 24),

              // ── Complete Stock In Button ──
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _canComplete ? _completeStockIn : null,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text(
                    "COMPLETE STOCK IN",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canComplete
                        ? const Color(0xFF17335C)
                        : const Color(0xFF9CA3AF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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

  Widget _fieldLabelValue(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9CA3AF),
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF17335C),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // SCAN STEP CARD
  // ─────────────────────────────────────────
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
                  color: isDone
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF17335C),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : Text(
                          "$stepNumber",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: enabled ? onTap : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDone
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    isDone ? Icons.check_circle : icon,
                    size: 40,
                    color: isDone
                        ? const Color(0xFF16A34A)
                        : const Color(0xFF17335C),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isDone ? doneLabel : idleLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDone
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF17335C),
                      letterSpacing: 0.4,
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
              color: isDone
                  ? const Color(0xFFD8F3E8)
                  : const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDone
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF9CA3AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
