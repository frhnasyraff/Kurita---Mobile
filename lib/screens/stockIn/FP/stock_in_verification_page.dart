import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'product_stock_in_page.dart';

class StockInVerificationPage extends StatefulWidget {
  final ProductStockInJob job;
  // Called when SUBMIT STOCK IN is tapped. Lets the parent list page
  // promote the job from NEW -> IN PROGRESS (LABELLED).
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

  final List<String> _units = ["Kilograms (KG)", "Litres (L)", "Pieces (PCS)"];
  final List<String> _packagingTypes = ["IBC", "Drum", "Pallet", "Carton"];

  @override
  void initState() {
    super.initState();
    final numericQty = widget.job.quantity.replaceAll(RegExp(r'[^0-9]'), '');
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
    setState(() {
      _qrGenerated = true;
      _traceabilityId =
          "#QR-${widget.job.jobSheetNo.replaceFirst('JOB-', '')}-001X";
    });
  }

  void _submitStockIn() {
    if (!_qrGenerated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please generate QR code first")),
      );
      return;
    }

    final qtyValue = _qtyController.text.trim();
    final unitShort = _selectedUnit.split(" ").first;
    final promotedJob = widget.job.copyWith(
      status: "IN PROGRESS",
      isLabelled: true,
      packagingType: _selectedPackaging.toUpperCase(),
      quantity: qtyValue.isEmpty ? widget.job.quantity : "$qtyValue $unitShort",
    );

    widget.onSubmitted?.call(promotedJob);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Stock In Submitted"),
        content: Text(
          "${widget.job.productName} has been labelled and moved to In Progress.",
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
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              const Text(
                "STOCK IN VERIFICATION",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                "#${job.jobSheetNo}",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF17335C),
                ),
              ),
              const SizedBox(height: 8),
              if (job.queueNumber > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFE4E6),
                    borderRadius: BorderRadius.circular(20),
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
                      const Text(
                        "UNLABELLED",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                          letterSpacing: 0.4,
                        ),
                      ),
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
                    const Text(
                      "QUANTITY (KG)",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9CA3AF),
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF17335C),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF5F6F8),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
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
                  label: const Text(
                    "GENERATE QR CODE",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17335C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                  onPressed: _submitStockIn,
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text(
                    "SUBMIT STOCK IN",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _qrGenerated
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

  Widget _buildCard({
    required String title,
    required IconData titleIcon,
    required Widget child,
  }) {
    return Container(
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF17335C),
                  letterSpacing: 0.3,
                ),
              ),
              Icon(titleIcon, size: 22, color: const Color(0xFF17335C)),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF17335C),
            ),
          ),
        ],
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

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
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
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, size: 18),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF17335C),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              border: Border.all(
                color: _qrGenerated
                    ? const Color(0xFF17335C)
                    : const Color(0xFFD1D5DB),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _qrGenerated ? Icons.qr_code_2 : Icons.qr_code_2_outlined,
              size: 56,
              color: _qrGenerated
                  ? const Color(0xFF17335C)
                  : const Color(0xFFD1D5DB),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _qrGenerated ? "UNIQUE TRACEABILITY ID" : "NO QR CODE GENERATED",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: _qrGenerated
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFFD1D5DB),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _qrGenerated ? _traceabilityId : "GENERATE QR CODE ABOVE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _qrGenerated
                  ? const Color(0xFF17335C)
                  : const Color(0xFFD1D5DB),
            ),
          ),
          if (_qrGenerated) ...[
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print_outlined, size: 16),
              label: const Text("PRINT QR LABEL"),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF17335C),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
