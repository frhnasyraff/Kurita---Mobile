import 'package:flutter/material.dart';

// ─── Data Models ─────────────────────────────────────────────────────────────

enum MaterialStatus { pending, approved, rejected, discrepancy, overridden }

class MaterialItem {
  final String ref;
  final String name;
  final String subtitle;
  MaterialStatus status;
  String quantity;
  String? discrepancyNote;

  MaterialItem({
    required this.ref,
    required this.name,
    required this.subtitle,
    this.status = MaterialStatus.pending,
    this.quantity = "0.00",
    this.discrepancyNote,
  });
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class MaterialVerificationPage extends StatefulWidget {
  final String jobId;
  final String lane;
  final String productionDate;

  const MaterialVerificationPage({
    super.key,
    required this.jobId,
    this.lane = "ASSEMBLY_LN_04B",
    this.productionDate = "24 OCT 2023 - SHIFT A",
  });

  @override
  State<MaterialVerificationPage> createState() =>
      _MaterialVerificationPageState();
}

class _MaterialVerificationPageState
    extends State<MaterialVerificationPage> {
  // ── Colours ──────────────────────────────────────────────────────────────
  static const Color navy = Color(0xFF17335C);
  static const Color bgLight = Color(0xFFF5F6F8);
  static const Color approveGreen = Color(0xFF1A6B3C);
  static const Color rejectRed = Color(0xFFCC2936);
  static const Color discrepancyBg = Color(0xFFFFF3F3);
  static const Color verifiedBg = Color(0xFFD8F3E8);
  static const Color verifiedText = Color(0xFF1A6B3C);

  late List<MaterialItem> _items;

  @override
  void initState() {
    super.initState();
    _items = [
      MaterialItem(
        ref: "AL-6061",
        name: "Alloy 6061-T6",
        subtitle: "Batch #8812-X | Source: Alcoa Prime",
        status: MaterialStatus.approved,
      ),
      MaterialItem(
        ref: "SS-304-B",
        name: "Stainless 304 Bolt",
        subtitle: "M12 x1.75 Grade A2-70",
      ),
      MaterialItem(
        ref: "LUBE-LITH",
        name: "Lithium Grease",
        subtitle: "EP2 High Pressure Industrial Cartridge",
      ),
      MaterialItem(
        ref: "CLNT-C",
        name: "Coolant Concentrate",
        subtitle: "Synthetic Water-Soluble Coolant (Drum)",
        status: MaterialStatus.discrepancy,
        discrepancyNote: "Expected: 2 Drums | Scanned: 1 Drum",
      ),
      MaterialItem(
        ref: "PREC-SHIM",
        name: "Precision Shims",
        subtitle: "0.5mm Stainless Steel Assorted Pack",
      ),
    ];
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _approve(int i) => setState(() => _items[i].status = MaterialStatus.approved);
  void _reject(int i) => setState(() => _items[i].status = MaterialStatus.rejected);
  void _override(int i) => setState(() => _items[i].status = MaterialStatus.overridden);

  void _scanUHF(int i) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Scanning ${_items[i].ref}…"),
      backgroundColor: navy,
      duration: const Duration(seconds: 1),
    ));
  }

  void _submit() {
    final pending = _items.where((m) => m.status == MaterialStatus.pending).length;
    if (pending > 0) {
      _showDialog(
        "Incomplete Verification",
        "$pending item(s) still pending. Please approve or reject all items.",
        onOk: null,
      );
    } else {
      _showDialog(
        "Submitted ✓",
        "Material verification for ${widget.jobId} submitted successfully.",
        onOk: () => Navigator.pop(context),
      );
    }
  }

  void _showDialog(String title, String body, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onOk?.call();
            },
            child: const Text("OK", style: TextStyle(color: navy)),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Color _badgeColor(MaterialStatus s) {
    switch (s) {
      case MaterialStatus.approved:   return verifiedBg;
      case MaterialStatus.rejected:   return rejectRed.withOpacity(0.12);
      case MaterialStatus.overridden: return Colors.orange.withOpacity(0.12);
      default:                        return Colors.transparent;
    }
  }

  Color _badgeTextColor(MaterialStatus s) {
    switch (s) {
      case MaterialStatus.approved:   return verifiedText;
      case MaterialStatus.rejected:   return rejectRed;
      case MaterialStatus.overridden: return Colors.orange[800]!;
      default:                        return Colors.transparent;
    }
  }

  String _badgeLabel(MaterialStatus s) {
    switch (s) {
      case MaterialStatus.approved:   return "VERIFIED";
      case MaterialStatus.rejected:   return "REJECTED";
      case MaterialStatus.overridden: return "OVERRIDDEN";
      default:                        return "";
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      bottomNavigationBar: _bottomNav(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _header(),
                    const SizedBox(height: 20),
                    const Text(
                      "MATERIAL\nVERIFICATION",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: navy,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Review and validate material integrity before final\nproduction sequence.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    _infoRow("LANE", widget.lane),
                    const SizedBox(height: 10),
                    _infoRow("PRODUCTION DATE", widget.productionDate),
                    const SizedBox(height: 24),
                    ..._items.asMap().entries.map((e) => _card(e.key, e.value)),
                    const SizedBox(height: 16),
                    _submitBtn(),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _header() => Row(
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
      const Text(
        "Workwise",
        style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: navy),
      ),
      const Spacer(),
      IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new, color: navy, size: 18),
      ),
    ],
  );

  Widget _infoRow(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label,
          style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 2),
      Text(value,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: navy)),
    ],
  );

  Widget _card(int i, MaterialItem item) {
    final isDiscrep = item.status == MaterialStatus.discrepancy;
    final showBadge = item.status != MaterialStatus.pending &&
        item.status != MaterialStatus.discrepancy;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDiscrep ? discrepancyBg : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDiscrep
              ? rejectRed
              : item.status == MaterialStatus.rejected
              ? rejectRed.withOpacity(0.4)
              : item.status == MaterialStatus.approved ||
              item.status == MaterialStatus.overridden
              ? approveGreen.withOpacity(0.3)
              : const Color(0xFFE5E7EB),
          width: isDiscrep ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Discrepancy banner
            if (isDiscrep) ...[
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: rejectRed,
                    borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text("DISCREPANCY DETECTED",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Ref + status badge
            Row(children: [
              Text("REF: ${item.ref}",
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              if (showBadge)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: _badgeColor(item.status),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(_badgeLabel(item.status),
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _badgeTextColor(item.status))),
                ),
            ]),

            const SizedBox(height: 4),

            Text(item.name,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: navy)),

            const SizedBox(height: 2),

            Text(item.subtitle,
                style:
                const TextStyle(fontSize: 12, color: Colors.grey)),

            if (item.discrepancyNote != null) ...[
              const SizedBox(height: 6),
              Row(children: [
                Icon(Icons.info_outline, size: 14, color: rejectRed),
                const SizedBox(width: 4),
                Text(item.discrepancyNote!,
                    style: TextStyle(
                        fontSize: 12,
                        color: rejectRed,
                        fontWeight: FontWeight.w500)),
              ]),
            ],

            const SizedBox(height: 14),

            // Step 1 & 2
            Row(children: [
              Expanded(child: _stepScan(i, item)),
              const SizedBox(width: 12),
              Expanded(child: _stepQty(i, item)),
            ]),

            const SizedBox(height: 12),

            // Step 3
            const Text("STEP 3: STATUS",
                style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5)),
            const SizedBox(height: 8),

            Row(children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isDiscrep ? () => _override(i) : () => _approve(i),
                  icon: Icon(
                      isDiscrep
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      size: 16,
                      color: Colors.white),
                  label: Text(isDiscrep ? "OVERRIDE" : "APPROVE",
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    isDiscrep ? Colors.orange[800] : approveGreen,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _reject(i),
                  icon: Icon(Icons.cancel_outlined,
                      size: 16, color: rejectRed),
                  label: Text("REJECT",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: rejectRed)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: rejectRed),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _stepScan(int i, MaterialItem item) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("STEP 1: SCAN",
          style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5)),
      const SizedBox(height: 6),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _scanUHF(i),
          icon: const Icon(Icons.wifi_tethering, size: 16, color: navy),
          label: const Text("SCAN UHF",
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: navy)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: navy),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    ],
  );

  Widget _stepQty(int i, MaterialItem item) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("STEP 2: UPDATE QUANTITY (KG)",
          style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5)),
      const SizedBox(height: 6),
      TextFormField(
        initialValue: item.quantity,
        keyboardType:
        const TextInputType.numberWithOptions(decimal: true),
        onChanged: (v) => setState(() => item.quantity = v),
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
              const BorderSide(color: Color(0xFFE5E7EB))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
              const BorderSide(color: Color(0xFFE5E7EB))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: navy)),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    ],
  );

  Widget _submitBtn() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: navy,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      child: const Text("SUBMIT",
          style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1)),
    ),
  );

  Widget _bottomNav() => BottomNavigationBar(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: navy,
    unselectedItemColor: Colors.grey,
    currentIndex: 2,
    items: const [
      BottomNavigationBarItem(
          icon: Icon(Icons.star_outline), label: 'Quality'),
      BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
      BottomNavigationBarItem(
          icon: Icon(Icons.precision_manufacturing_outlined),
          label: 'Production'),
      BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping_outlined), label: 'Delivery'),
    ],
  );
}
