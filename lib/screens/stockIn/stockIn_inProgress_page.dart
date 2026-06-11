import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';

// ─────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────
enum MaterialScanStatus { scanned, pendingScan }

class StockInMaterial {
  final String name;
  final String assignedRack;
  final String qty;
  final String uhfCode;
  final MaterialScanStatus status;

  const StockInMaterial({
    required this.name,
    required this.assignedRack,
    required this.qty,
    required this.uhfCode,
    required this.status,
  });
}

// ─────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────
class StockInDetailPage extends StatefulWidget {
  final String poNumber;
  final String supplier;
  final int qcPercent;
  final int materialsChecked;
  final int materialsTotal;
  final List<StockInMaterial> materials;

  const StockInDetailPage({
    super.key,
    required this.poNumber,
    required this.supplier,
    required this.qcPercent,
    required this.materialsChecked,
    required this.materialsTotal,
    required this.materials,
  });

  @override
  State<StockInDetailPage> createState() => _StockInDetailPageState();
}

class _StockInDetailPageState extends State<StockInDetailPage> {
  int _selectedNavBar = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      bottomNavigationBar: BottomNavBar(
        items: [
          (Icons.verified_outlined, 'Quality', _selectedNavBar == 0),
          (Icons.inventory_2_outlined, 'Inventory', _selectedNavBar == 1),
          (Icons.precision_manufacturing_outlined, 'Production', _selectedNavBar == 2),
          (Icons.local_shipping_outlined, 'Delivery', _selectedNavBar == 3),
          (Icons.more_horiz, 'Others', _selectedNavBar == 4),
        ],
        onItemTapped: (index) => setState(() => _selectedNavBar = index),
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
                    onTap: () => Navigator.pop(context),
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
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Title ──
              const Text(
                "STOCK IN - IN PROGRESS",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF17335C),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.receipt_long_outlined,
                      size: 13, color: Color(0xFF6B7280)),
                  const SizedBox(width: 4),
                  Text(
                    "${widget.poNumber}  |  ${widget.supplier}",
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── PO Progress Summary ──
              _buildProgressCard(),

              const SizedBox(height: 20),

              // ── Material List Label ──
              const Text(
                "MATERIAL LIST",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.8,
                ),
              ),

              const SizedBox(height: 12),

              // ── Material Cards ──
              ...widget.materials.map((m) => _buildMaterialCard(m)),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // PO PROGRESS SUMMARY CARD
  // ─────────────────────────────────────────
  Widget _buildProgressCard() {
    final progress = widget.qcPercent / 100.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PO PROGRESS SUMMARY",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFF6B7280),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // % + COMPLETE
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${widget.qcPercent}%",
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF17335C),
                      height: 1.0,
                    ),
                  ),
                  const Text(
                    "COMPLETE",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF17335C),
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Materials scanned
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${widget.materialsChecked}/${widget.materialsTotal}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF17335C),
                      height: 1.0,
                    ),
                  ),
                  const Text(
                    "MATERIALS\nSCANNED",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF17335C)),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // MATERIAL CARD
  // ─────────────────────────────────────────
  Widget _buildMaterialCard(StockInMaterial material) {
    final isScanned = material.status == MaterialScanStatus.scanned;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Name + badge ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  material.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF17335C),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isScanned
                      ? const Color(0xFFD8F3E8)
                      : const Color(0xFFFFF3CD),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isScanned ? "SCANNED" : "PENDING SCAN",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isScanned
                        ? const Color(0xFF16A34A)
                        : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Rack ──
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 13, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 6),
              Text(
                "ASSIGNED: ${material.assignedRack}",
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // ── QTY + UHF ──
          Row(
            children: [
              const Icon(Icons.inventory_2_outlined,
                  size: 13, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 6),
              Text(
                "QTY: ${material.qty}   # UHF: ${material.uhfCode}",
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Scanned tick OR scan button ──
          if (isScanned)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFD8F3E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check,
                      size: 16, color: Color(0xFF16A34A)),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Scan complete",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF16A34A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: trigger QR scan
                },
                icon: const Icon(Icons.qr_code_scanner, size: 16),
                label: const Text(
                  "SCAN QR LOCATION",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF17335C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
