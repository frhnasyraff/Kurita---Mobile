import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'stock_in_verification_page.dart';
import 'stock_in_scan_verification_page.dart';

// ─────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────
class ProductStockInJob {
  final String jobSheetNo;
  final String productName;
  final String laneNumber;
  final String quantity;
  final String lotNumber;
  final String status; // "NEW" | "IN PROGRESS" | "COMPLETE"
  final String batchId;
  final int queueNumber;
  final bool isLabelled;
  final String packagingType;

  const ProductStockInJob({
    required this.jobSheetNo,
    required this.productName,
    required this.laneNumber,
    required this.quantity,
    required this.lotNumber,
    required this.status,
    this.batchId = "",
    this.queueNumber = 0,
    this.isLabelled = false,
    this.packagingType = "",
  });

  ProductStockInJob copyWith({
    String? jobSheetNo,
    String? productName,
    String? laneNumber,
    String? quantity,
    String? lotNumber,
    String? status,
    String? batchId,
    int? queueNumber,
    bool? isLabelled,
    String? packagingType,
  }) {
    return ProductStockInJob(
      jobSheetNo: jobSheetNo ?? this.jobSheetNo,
      productName: productName ?? this.productName,
      laneNumber: laneNumber ?? this.laneNumber,
      quantity: quantity ?? this.quantity,
      lotNumber: lotNumber ?? this.lotNumber,
      status: status ?? this.status,
      batchId: batchId ?? this.batchId,
      queueNumber: queueNumber ?? this.queueNumber,
      isLabelled: isLabelled ?? this.isLabelled,
      packagingType: packagingType ?? this.packagingType,
    );
  }
}

// ─────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────
class ProductStockInPage extends StatefulWidget {
  const ProductStockInPage({super.key});

  @override
  State<ProductStockInPage> createState() => _ProductStockInPageState();
}

class _ProductStockInPageState extends State<ProductStockInPage> {
  int _selectedTab = 0; // 0=NEW, 1=IN PROGRESS, 2=COMPLETE
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedPackagingFilter = "ALL";

  List<ProductStockInJob> _allJobs = [
    const ProductStockInJob(
      jobSheetNo: "JOB-2024-055",
      productName: "Industrial Disinfectant X1",
      laneNumber: "Lane 04",
      quantity: "1,500 L",
      lotNumber: "CHM-24-012-A",
      status: "NEW",
      batchId: "BT-9928-A",
      queueNumber: 1,
    ),
    const ProductStockInJob(
      jobSheetNo: "JOB-2024-056",
      productName: "Heavy Duty Degreaser G4",
      laneNumber: "Lane 02",
      quantity: "2,400 L",
      lotNumber: "CHM-24-014-B",
      status: "NEW",
      batchId: "BT-9929-B",
      queueNumber: 2,
    ),
    const ProductStockInJob(
      jobSheetNo: "JOB-2024-058",
      productName: "Caustic Soda Solution",
      laneNumber: "Lane 07",
      quantity: "850 L",
      lotNumber: "CHM-24-015-D",
      status: "NEW",
      batchId: "BT-9930-C",
      queueNumber: 3,
    ),
    const ProductStockInJob(
      jobSheetNo: "JOB-2024-056",
      productName: "Solvent Cleaner Grade-B",
      laneNumber: "Lane 02",
      quantity: "850 KG",
      lotNumber: "CHM-24-014-B",
      status: "IN PROGRESS",
      batchId: "BT-9929-B",
      isLabelled: true,
      packagingType: "DRUM",
    ),
    const ProductStockInJob(
      jobSheetNo: "JOB-2024-058",
      productName: "Polymer Resin - Alpha",
      laneNumber: "Lane 07",
      quantity: "2200 KG",
      lotNumber: "CHM-24-015-D",
      status: "IN PROGRESS",
      batchId: "BT-9930-C",
      isLabelled: true,
      packagingType: "BULK",
    ),
    const ProductStockInJob(
      jobSheetNo: "JOB-2024-061",
      productName: "Coating Agent W-9",
      laneNumber: "Lane 01",
      quantity: "500 KG",
      lotNumber: "CHM-24-018-A",
      status: "IN PROGRESS",
      batchId: "BT-9931-A",
      isLabelled: true,
      packagingType: "IBC",
    ),
    const ProductStockInJob(
      jobSheetNo: "JOB-2024-021",
      productName: "Glass Cleaner Pro",
      laneNumber: "Lane 01",
      quantity: "900 L",
      lotNumber: "CHM-24-002-A",
      status: "COMPLETE",
      batchId: "BT-9870-A",
    ),
  ];

  final List<String> _tabLabels = ["NEW", "IN PROGRESS", "COMPLETE"];
  final List<String> _packagingFilters = ["ALL", "IBL", "DRUM", "BULK", "IBC", "PALLET"];

  List<ProductStockInJob> get _filteredJobs {
    var byTab = _allJobs.where((j) => j.status == _tabLabels[_selectedTab]).toList();

    if (_selectedTab == 1 && _selectedPackagingFilter != "ALL") {
      byTab = byTab.where((j) => j.packagingType == _selectedPackagingFilter).toList();
    }

    if (_searchQuery.isEmpty) return byTab;
    final q = _searchQuery.toLowerCase();
    return byTab
        .where((j) =>
            j.jobSheetNo.toLowerCase().contains(q) ||
            j.lotNumber.toLowerCase().contains(q))
        .toList();
  }

  // Promote a NEW job to IN PROGRESS (LABELLED) after the user generates QR
  // and submits on the verification page. Replaces the NEW record in place.
  void _promoteToInProgress(ProductStockInJob promoted) {
    setState(() {
      final index = _allJobs.indexWhere(
        (j) =>
            j.jobSheetNo == promoted.jobSheetNo &&
            j.batchId == promoted.batchId &&
            j.status == "NEW",
      );
      if (index != -1) {
        _allJobs[index] = promoted.copyWith(queueNumber: 0);
      } else {
        // Already not in NEW (e.g. re-opened) - just ensure presence.
        final existingIdx = _allJobs.indexWhere(
          (j) =>
              j.jobSheetNo == promoted.jobSheetNo &&
              j.batchId == promoted.batchId &&
              j.status == "IN PROGRESS",
        );
        if (existingIdx == -1) {
          _allJobs.add(promoted.copyWith(queueNumber: 0));
        }
      }
    });
  }

  void _moveJobToComplete(ProductStockInJob job) {
    setState(() {
      final index = _allJobs.indexWhere(
        (j) => j.jobSheetNo == job.jobSheetNo &&
            j.batchId == job.batchId &&
            j.status == "IN PROGRESS",
      );
      if (index != -1) {
        _allJobs[index] = _allJobs[index].copyWith(status: "COMPLETE");
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jobs = _filteredJobs;

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
                      child: const Icon(Icons.menu,
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

              const Text(
                "PRODUCT STOCK IN",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF17335C),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Inventory Intake Management System",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: "Job Sheet or Batch Number",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF17335C)),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              _buildTabBar(),

              const SizedBox(height: 16),

              if (_selectedTab == 1) ...[
                _buildPackagingFilter(),
                const SizedBox(height: 16),
              ],

              if (jobs.isEmpty)
                _buildEmptyState()
              else
                ...jobs.map((job) => _selectedTab == 1
                    ? _buildInProgressCard(job)
                    : _buildJobCard(job)),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // TAB BAR
  // ─────────────────────────────────────────
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: List.generate(_tabLabels.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF17335C)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _tabLabels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────
  // PACKAGING TYPE FILTER
  // ─────────────────────────────────────────
  Widget _buildPackagingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "FILTER BY PACKAGING TYPE",
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9CA3AF),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _packagingFilters.map((filter) {
              final isSelected = _selectedPackagingFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPackagingFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF17335C)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF17335C)
                            : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // JOB CARD (NEW + COMPLETE)
  // ─────────────────────────────────────────
  Widget _buildJobCard(ProductStockInJob job) {
    final isComplete = job.status == "COMPLETE";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "JOB SHEET NO:",
                    style: TextStyle(
                      fontSize: 9,
                      color: Color(0xFF9CA3AF),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  Text(
                    "#${job.jobSheetNo}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF17335C),
                    ),
                  ),
                ],
              ),
              if (job.queueNumber > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "QUEUE ${job.queueNumber}",
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3B5BDB),
                    ),
                  ),
                ),
              if (isComplete)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8F3E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle, size: 12, color: Color(0xFF16A34A)),
                      SizedBox(width: 4),
                      Text(
                        "COMPLETE",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            "PRODUCT NAME",
            style: TextStyle(
              fontSize: 9,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          Text(
            job.productName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF17335C),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _miniInfoBox("LANE NUMBER", job.laneNumber)),
              const SizedBox(width: 10),
              Expanded(child: _miniInfoBox("QUANTITY", job.quantity)),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _miniInfoBox("LOT NUMBER", job.lotNumber),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: isComplete
                    ? Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "COMPLETED",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StockInVerificationPage(
                                job: job,
                                onSubmitted: _promoteToInProgress,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF17335C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "PROCESS",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // IN PROGRESS CARD — LABELLED, tap to scan-verify
  // ─────────────────────────────────────────
  Widget _buildInProgressCard(ProductStockInJob job) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StockInScanVerificationPage(
              job: job,
              onComplete: () => _moveJobToComplete(job),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            Text(
              "#${job.jobSheetNo}",
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17335C),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              job.productName,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF17335C),
              ),
            ),
            const SizedBox(height: 8),
            if (job.isLabelled)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD8F3E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF16A34A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "LABELLED",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16A34A),
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on_outlined,
                    size: 13, color: const Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text(
                  "LANE ${job.laneNumber.replaceAll('Lane ', '')}",
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF6B7280)),
                ),
                const SizedBox(width: 14),
                Icon(Icons.scale_outlined,
                    size: 13, color: const Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Text(
                  "QTY: ${job.quantity}",
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF6B7280)),
                ),
                const Spacer(),
                if (job.packagingType.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF17335C),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      job.packagingType,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            "No records found",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
