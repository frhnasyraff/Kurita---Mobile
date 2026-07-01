import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../../services/api_client.dart';
import 'stock_in_verification_page.dart';
import 'stock_in_scan_verification_page.dart';

// ─────────────────────────────────────────
// THEME (from JSON Authority / Tailwind config)
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

// ─────────────────────────────────────────
// MODEL
// ─────────────────────────────────────────
class ProductStockInJob {
  final int productionJobId;
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
  final String? locationCode;

  const ProductStockInJob({
    required this.productionJobId,
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
    this.locationCode,
  });

  // Shared helper so all three factories read the lane consistently.
  // Lane_id is a plain column on the production job (not a foreign key),
  // so we read it directly. If a given endpoint instead sends a
  // human-readable `lane_name`, prefer that when present.
  static String _resolveLane(Map<String, dynamic> json) {
    return json['lane_name']?.toString() ??
        json['lane_id']?.toString() ??
        '-';
  }

  factory ProductStockInJob.fromApi(Map<String, dynamic> json, {int queueNumber = 0}) {
    final qty = json['produced_qty']?.toString() ?? '0';
    final unit = json['unit']?.toString() ?? '';
    return ProductStockInJob(
      productionJobId: json['production_job_id'] as int,
      jobSheetNo: json['job_sheet_no']?.toString() ?? '-',
      productName: json['product_name']?.toString() ?? '-',
      laneNumber: _resolveLane(json),
      quantity: '$qty $unit'.trim(),
      lotNumber: json['lot_number']?.toString() ?? '-',
      status: "NEW",
      batchId: json['sap_batch_no']?.toString() ?? '-',
      queueNumber: queueNumber,
    );
  }

  factory ProductStockInJob.fromInProgressApi(Map<String, dynamic> json) {
    final qty = json['quantity_kg']?.toString() ?? '0';
    final unit = json['unit']?.toString() ?? '';
    return ProductStockInJob(
      productionJobId: json['production_job_id'] as int,
      jobSheetNo: json['job_sheet_no']?.toString() ?? '-',
      productName: json['product_name']?.toString() ?? '-',
      laneNumber: _resolveLane(json),
      quantity: '$qty $unit'.trim(),
      lotNumber: json['lot_number']?.toString() ?? '-',
      status: "IN PROGRESS",
      batchId: json['sap_batch_no']?.toString() ?? '-',
    );
  }

  factory ProductStockInJob.fromCompleteApi(Map<String, dynamic> json) {
    final qty = json['quantity_kg']?.toString() ?? '0';
    final unit = json['unit']?.toString() ?? '';
    return ProductStockInJob(
      productionJobId: json['production_job_id'] as int,
      jobSheetNo: json['job_sheet_no']?.toString() ?? '-',
      productName: json['product_name']?.toString() ?? '-',
      laneNumber: _resolveLane(json),
      quantity: '$qty $unit'.trim(),
      lotNumber: json['lot_number']?.toString() ?? '-',
      status: "COMPLETE",
      batchId: json['sap_batch_no']?.toString() ?? '-',
      locationCode: json['location_code']?.toString(),
    );
  }

  ProductStockInJob copyWith({
    int? productionJobId,
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
    String? locationCode,
  }) {
    return ProductStockInJob(
      productionJobId: productionJobId ?? this.productionJobId,
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
      locationCode: locationCode ?? this.locationCode,
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

  bool _isLoading = true;
  String? _error;

  // All three tabs are backed by real backend data, fetched together on
  // load / pull-to-refresh, so nothing is lost on hot restart.
  List<ProductStockInJob> _allJobs = [];

  final List<String> _tabLabels = ["NEW", "IN PROGRESS", "COMPLETE"];
  final List<String> _packagingFilters = ["ALL", "IBL", "DRUM", "BULK", "IBC", "PALLET"];

  @override
  void initState() {
    super.initState();
    _loadAllJobs();
  }

  Future<void> _loadAllJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final pending = await ApiClient.instance.getPendingProductStockIn();
      final inProgress = await ApiClient.instance.getInProgressProductStockIn();
      final complete = await ApiClient.instance.getCompleteProductStockIn();

      final newJobs = <ProductStockInJob>[];
      for (var i = 0; i < pending.length; i++) {
        newJobs.add(ProductStockInJob.fromApi(
          pending[i] as Map<String, dynamic>,
          queueNumber: i + 1,
        ));
      }

      // TEMP DEBUG — remove after confirming field names
      if (inProgress.isNotEmpty) {
        debugPrint('IN-PROGRESS RAW JSON SAMPLE: ${inProgress.first}');
      }

      final inProgressJobs = inProgress
          .map((j) => ProductStockInJob.fromInProgressApi(j as Map<String, dynamic>))
          .toList();

      final completeJobs = complete
          .map((j) => ProductStockInJob.fromCompleteApi(j as Map<String, dynamic>))
          .toList();

      setState(() {
        _allJobs = [...newJobs, ...inProgressJobs, ...completeJobs];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

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

  void _promoteToInProgress(ProductStockInJob promoted) {
    _loadAllJobs();
  }

  void _moveJobToComplete(ProductStockInJob job) {
    _loadAllJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
    final jobs = _filteredJobs;

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
        child: RefreshIndicator(
          onRefresh: _loadAllJobs,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                    const Icon(Icons.account_circle_outlined,
                        color: _Palette.primary, size: 24),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  "PRODUCT STOCK IN",
                  style: GoogleFonts.montserrat(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _Palette.primary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Inventory Intake Management System",
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: _Palette.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: GoogleFonts.montserrat(fontSize: 14, color: _Palette.onSurface),
                  decoration: InputDecoration(
                    hintText: "Job Sheet or Batch Number",
                    hintStyle: GoogleFonts.montserrat(color: _Palette.outline),
                    prefixIcon: const Icon(Icons.search, color: _Palette.outline),
                    filled: true,
                    fillColor: _Palette.surfaceContainerLowest,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: _Palette.outlineVariant),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: _Palette.outlineVariant),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4),
                      borderSide: const BorderSide(color: _Palette.primary, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                _buildTabBar(),

                const SizedBox(height: 20),

                if (_selectedTab == 1) ...[
                  _buildFilterButton(),
                  const SizedBox(height: 16),
                ],

                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_error != null)
                  _buildErrorState()
                else if (jobs.isEmpty)
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
      ),
    );
  }

    Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _Palette.outlineVariant)),
      ),
      child: Row(
        children: List.generate(_tabLabels.length, (index) {
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                alignment: Alignment.center,
                margin: EdgeInsets.zero,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? _Palette.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  _tabLabels[index],
                  textAlign: TextAlign.center,
                  style: _labelCaps(
                    color: isSelected ? _Palette.primary : _Palette.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

    Widget _buildFilterButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setModalState) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Packaging Type",
                          style: _labelCaps(size: 12),
                        ),
                        const SizedBox(height: 12),

                        ..._packagingFilters.map((filter) {
                          return RadioListTile<String>(
                            title: Text(filter),
                            value: filter,
                            groupValue: _selectedPackagingFilter,
                            onChanged: (value) {
                              setModalState(() {
                                _selectedPackagingFilter = value!;
                              });
                            },
                          );
                        }),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {});
                              Navigator.pop(context);
                            },
                            child: const Text("APPLY"),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _Palette.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          backgroundColor: Colors.white,
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.filter_list,
              size: 18,
              color: _Palette.onSurface,
            ),
            const SizedBox(width: 8),
            Text(
              "FILTERS",
              style: _labelCaps(
                size: 11,
                color: _Palette.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobCard(ProductStockInJob job) {
    final isComplete = job.status == "COMPLETE";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Palette.surfaceContainerLowest,
        border: Border.all(color: _Palette.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _Palette.outlineVariant)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("JOB SHEET NO.", style: _labelCaps(size: 9)),
                    Text(
                      "#${job.jobSheetNo}",
                      style: _mono(color: _Palette.primary, weight: FontWeight.w700),
                    ),
                  ],
                ),
                if (isComplete)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD8F3E8),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle, size: 12, color: Color(0xFF16A34A)),
                        const SizedBox(width: 4),
                        Text(
                          "COMPLETE",
                          style: _labelCaps(size: 9, color: const Color(0xFF16A34A)),
                        ),
                      ],
                    ),
                  )
                else if (job.queueNumber > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _Palette.primaryContainer,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      "QUEUE: ${job.queueNumber}",
                      style: _labelCaps(size: 9, color: _Palette.onPrimaryContainer),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Text("PRODUCT NAME", style: _labelCaps(size: 9)),
          Text(
            job.productName,
            style: GoogleFonts.montserrat(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: _Palette.primary,
              height: 28 / 20,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(child: _miniInfoBox("LANE NUMBER", job.laneNumber)),
              const SizedBox(width: 16),
              Expanded(child: _miniInfoBox("QUANTITY", job.quantity)),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("LOT NUMBER", style: _labelCaps(size: 9)),
                    Text(job.lotNumber, style: _mono(size: 13)),
                  ],
                ),
              ),
              if (isComplete)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("LOCATION", style: _labelCaps(size: 9)),
                      Text(
                        job.locationCode ?? "-",
                        style: _mono(size: 13),
                      ),
                    ],
                  ),
                )
              else
                ElevatedButton(
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
                    backgroundColor: _Palette.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("PROCESS", style: _labelCaps(size: 11, color: Colors.white)),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

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
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _Palette.surfaceContainerLowest,
        border: Border.all(color: _Palette.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "#${job.jobSheetNo}",
            style: _mono(color: _Palette.primary, weight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            job.productName,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _Palette.primary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check, size: 12, color: Colors.white),
                const SizedBox(width: 6),
                Text("LABELLED", style: _labelCaps(size: 10, color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("LANE: ", style: _labelCaps(size: 11, color: _Palette.onSurfaceVariant)),
              Text(job.laneNumber, style: _mono(size: 12, weight: FontWeight.w700, color: _Palette.primary)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text("QTY: ", style: _labelCaps(size: 11, color: _Palette.onSurfaceVariant)),
              Text(job.quantity, style: _mono(size: 12, weight: FontWeight.w700, color: _Palette.primary)),
              const Spacer(),
              if (job.packagingType.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: _Palette.outlineVariant),
                  ),
                  child: Text(job.packagingType, style: _labelCaps(size: 10, color: _Palette.onSurfaceVariant)),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Text("PKG: ", style: _labelCaps(size: 11, color: _Palette.onSurfaceVariant)),
            ],
          ),
        ],
      ),
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text("No records found",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              )),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade200),
          const SizedBox(height: 12),
          Text(
            _error ?? "Something went wrong",
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 13, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loadAllJobs,
            child: const Text("RETRY"),
          ),
        ],
      ),
    );
  }
}