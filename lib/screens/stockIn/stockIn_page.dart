import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../dashboard_page.dart';
import '../material_verification_page.dart';
import '../pre_production_page.dart';
import 'stockIn_comfirmation_page.dart';
import 'stockIn_inProgress_page.dart';

class StockInPage extends StatefulWidget {
  const StockInPage({super.key});

  @override
  State<StockInPage> createState() => _StockInPageState();
}

class StockInItem {
  final String poNumber;
  final String lotNumber;
  final String supplier;
  final DateTime receivedDate;
  final int qcPercent;
  final String qcStatus;
  final double totalWeightKg;
  final int materialsChecked;
  final int materialsTotal;

  const StockInItem({
    required this.poNumber,
    required this.lotNumber,
    required this.supplier,
    required this.receivedDate,
    required this.qcPercent,
    required this.qcStatus,
    this.totalWeightKg = 0,
    this.materialsChecked = 0,
    this.materialsTotal = 0,
  });
}

class _StockInPageState extends State<StockInPage> {
  int _selectedTab = 1; // 0=NEW, 1=IN PROGRESS, 2=COMPLETE
  int _selectedNavBar = 1;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<StockInItem> _allItems = [
    StockInItem(
      poNumber: "PO-2024-0812",
      lotNumber: "LOT-CHM-992",
      supplier: "Global Chem Co.",
      receivedDate: DateTime(2026, 10, 24),
      qcPercent: 66,
      qcStatus: "IN PROGRESS",
      totalWeightKg: 1250,
      materialsChecked: 2,
      materialsTotal: 3,
    ),
    StockInItem(
      poNumber: "PO-2024-0815",
      lotNumber: "LOT-MET-441",
      supplier: "Apex Logistics Intl",
      receivedDate: DateTime(2026, 10, 25),
      qcPercent: 30,
      qcStatus: "IN PROGRESS",
      totalWeightKg: 4800,
      materialsChecked: 3,
      materialsTotal: 10,
    ),
    StockInItem(
      poNumber: "PO-2024-0799",
      lotNumber: "LOT-PLY-182",
      supplier: "Industrial Plastics Ltd.",
      receivedDate: DateTime(2026, 10, 25),
      qcPercent: 92,
      qcStatus: "IN PROGRESS",
      totalWeightKg: 850,
      materialsChecked: 5,
      materialsTotal: 6,
    ),
    StockInItem(
      poNumber: "PO-2024-0805",
      lotNumber: "LOT-CHM-998",
      supplier: "Precision Parts Co.",
      receivedDate: DateTime(2026, 10, 26),
      qcPercent: 15,
      qcStatus: "IN PROGRESS",
      totalWeightKg: 2100,
      materialsChecked: 1,
      materialsTotal: 7,
    ),
  ];

  final List<StockInItem> _newItems = [
    StockInItem(
      poNumber: "PO-2024-0830",
      lotNumber: "LOT-CHM-001",
      supplier: "ChemTech Sdn Bhd",
      receivedDate: DateTime(2026, 10, 27),
      qcPercent: 0,
      qcStatus: "NEW",
      totalWeightKg: 500,
      materialsChecked: 0,
      materialsTotal: 5,
    ),
    StockInItem(
      poNumber: "PO-2024-0831",
      lotNumber: "LOT-MET-002",
      supplier: "Metal Works Co.",
      receivedDate: DateTime(2026, 10, 27),
      qcPercent: 0,
      qcStatus: "NEW",
      totalWeightKg: 3200,
      materialsChecked: 0,
      materialsTotal: 8,
    ),
  ];

  final List<StockInItem> _completedItems = [
    StockInItem(
      poNumber: "PO-2024-0790",
      lotNumber: "LOT-CHM-880",
      supplier: "Global Chem Co.",
      receivedDate: DateTime(2026, 10, 20),
      qcPercent: 100,
      qcStatus: "PASS",
      totalWeightKg: 1100,
      materialsChecked: 4,
      materialsTotal: 4,
    ),
  ];

  final List<String> _tabLabels = ["NEW", "IN PROGRESS", "COMPLETE"];
  final List<int> _tabCounts = [12, 8, 45];

  List<StockInItem> get _currentItems {
    List<StockInItem> source;
    if (_selectedTab == 0) {
      source = _newItems;
    } else if (_selectedTab == 1) {
      source = _allItems;
    } else {
      source = _completedItems;
    }

    if (_searchQuery.isEmpty) return source;
    final q = _searchQuery.toLowerCase();
    return source.where((item) {
      return item.poNumber.toLowerCase().contains(q) ||
          item.lotNumber.toLowerCase().contains(q);
    }).toList();
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _currentItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF17335C),
        onPressed: () {},
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavBar(
        items: [
          (Icons.verified_outlined, 'Quality', _selectedNavBar == 0),
          (Icons.inventory_2_outlined, 'Inventory', _selectedNavBar == 1),
          (Icons.precision_manufacturing_outlined, 'Production', _selectedNavBar == 2),
          (Icons.local_shipping_outlined, 'Delivery', _selectedNavBar == 3),
          (Icons.more_horiz, 'Others', _selectedNavBar == 4),
        ],
        onItemTapped: _navigateTo,
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
                    // ── Header ──
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF17335C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            color: Colors.white,
                            size: 18,
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
                          icon: const Icon(Icons.search_outlined),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // ── Title ──
                    const Text(
                      "STOCK IN",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF17335C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "INVENTORY MANAGEMENT / STOCK INTAKE SELECTION",
                      style: TextStyle(
                        color: Color.fromARGB(255, 58, 58, 58),
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Tab Bar ──
                    _buildTabBar(),

                    const SizedBox(height: 16),

                    // ── Search Bar ──
                    TextField(
                      controller: _searchController,
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: "Search PO or Lot Number",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = "");
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFF17335C)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Active Queue Label + Sort ──
                    if (_selectedTab == 1) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "ACTIVE PO QUEUE (${items.length})",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.5,
                            ),
                          ),
                          Row(
                            children: const [
                              Text(
                                "SORT: LATEST",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF17335C),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down,
                                  size: 16, color: Color(0xFF17335C)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ] else
                      const SizedBox(height: 4),

                    // ── Cards ──
                    ...items.map((item) => _selectedTab == 1
                        ? _buildInProgressCard(item)
                        : _buildPoCard(item)),

                    const SizedBox(height: 12),

                    // ── Load More Button ──
                    _buildLoadMoreButton(),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const MaterialVerificationPage(jobId: 'JOB-001');
        break;
      case 1:
        return;
      case 2:
        page = const PreProductionPage();
        break;
      case 3:
        page = const DashboardPage();
        break;
      default:
        return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  // ── Tab Bar Widget ──
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
                child: Column(
                  children: [
                    Text(
                      _tabLabels[index],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "(${_tabCounts[index]})",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── IN PROGRESS Card ──
  Widget _buildInProgressCard(StockInItem item) {
    final progress = item.qcPercent / 100.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StockInDetailPage(
              poNumber: item.poNumber,
              supplier: item.supplier,
              qcPercent: item.qcPercent,
              materialsChecked: item.materialsChecked,
              materialsTotal: item.materialsTotal,
              materials: _dummyMaterialsFor(item.poNumber),
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: all content ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.poNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF17335C),
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.supplier,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: const Color(0xFFE5E7EB),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF17335C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Total Weight
                      Row(
                        children: [
                          const Icon(Icons.scale_outlined,
                              size: 14, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Total Weight:",
                                style: TextStyle(
                                    fontSize: 10, color: Color(0xFF6B7280)),
                              ),
                              Text(
                                "${_formatWeight(item.totalWeightKg)} kg",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF17335C),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 24),
                      // Materials
                      Row(
                        children: [
                          const Icon(Icons.inventory_outlined,
                              size: 14, color: Color(0xFF6B7280)),
                          const SizedBox(width: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Materials:",
                                style: TextStyle(
                                    fontSize: 10, color: Color(0xFF6B7280)),
                              ),
                              Text(
                                "${item.materialsChecked}/${item.materialsTotal}",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF17335C),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Right: % badge + arrow ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${item.qcPercent}%",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3B5BDB),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatWeight(double kg) {
    if (kg >= 1000) {
      return "${(kg / 1000).toStringAsFixed(1).replaceAll('.0', '')}k";
    }
    return kg.toInt().toString();
  }

  // ── NEW / COMPLETE Card ──
  Widget _buildPoCard(StockInItem item) {
    final isPass = item.qcStatus == "PASS";
    final badgeColor =
        isPass ? const Color(0xFFD8F3E8) : const Color(0xFFDDEBFF);
    final badgeTextColor =
        isPass ? const Color(0xFF16A34A) : const Color(0xFF2563EB);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StockInConfirmationPage(
              poNumber: item.poNumber,
              supplier: item.supplier,
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
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _labelValue("PO NUMBER", item.poNumber),
                  const SizedBox(height: 10),
                  _labelValue("LOT NUMBER", item.lotNumber),
                  const SizedBox(height: 10),
                  _labelValue("SUPPLIER", item.supplier, bold: true),
                  const SizedBox(height: 10),
                  _labelValue("RECEIVED DATE", _formatDate(item.receivedDate)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "QC STATUS",
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      "${item.qcPercent}%",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF17335C),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        item.qcStatus,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: badgeTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelValue(String label, String value, {bool bold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: const Color(0xFF17335C),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "LOAD MORE PENDING ORDERS",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF17335C),
              fontSize: 13,
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.add, size: 18, color: Color(0xFF17335C)),
        ],
      ),
    );
  }

  // ── Dummy materials data — replace with API later ──
  List<StockInMaterial> _dummyMaterialsFor(String poNumber) {
    switch (poNumber) {
      case "PO-2024-0812":
        return const [
          StockInMaterial(
            name: "Sodium Hypochlorite",
            assignedRack: "Rack A-12",
            qty: "515 kg",
            uhfCode: "8273-X",
            status: MaterialScanStatus.scanned,
          ),
          StockInMaterial(
            name: "Hydrochloric Acid (37%)",
            assignedRack: "Rack B-04",
            qty: "428 kg",
            uhfCode: "9104-Y",
            status: MaterialScanStatus.scanned,
          ),
          StockInMaterial(
            name: "Industrial Degreaser X-P",
            assignedRack: "Pending scan...",
            qty: "Pending",
            uhfCode: "Pending",
            status: MaterialScanStatus.pendingScan,
          ),
        ];
      case "PO-2024-0815":
        return const [
          StockInMaterial(
            name: "Steel Rod 10mm",
            assignedRack: "Rack D-01",
            qty: "1200 kg",
            uhfCode: "4421-A",
            status: MaterialScanStatus.scanned,
          ),
          StockInMaterial(
            name: "Steel Rod 20mm",
            assignedRack: "Rack D-02",
            qty: "800 kg",
            uhfCode: "4422-B",
            status: MaterialScanStatus.scanned,
          ),
          StockInMaterial(
            name: "Aluminium Sheet",
            assignedRack: "Pending scan...",
            qty: "Pending",
            uhfCode: "Pending",
            status: MaterialScanStatus.pendingScan,
          ),
          StockInMaterial(
            name: "Copper Wire",
            assignedRack: "Pending scan...",
            qty: "Pending",
            uhfCode: "Pending",
            status: MaterialScanStatus.pendingScan,
          ),
        ];
      case "PO-2024-0799":
        return const [
          StockInMaterial(
            name: "PVC Granules",
            assignedRack: "Rack E-03",
            qty: "300 kg",
            uhfCode: "1820-C",
            status: MaterialScanStatus.scanned,
          ),
          StockInMaterial(
            name: "ABS Plastic",
            assignedRack: "Rack E-04",
            qty: "250 kg",
            uhfCode: "1821-D",
            status: MaterialScanStatus.scanned,
          ),
          StockInMaterial(
            name: "Polypropylene",
            assignedRack: "Rack E-05",
            qty: "180 kg",
            uhfCode: "1822-E",
            status: MaterialScanStatus.scanned,
          ),
          StockInMaterial(
            name: "Nylon Pellets",
            assignedRack: "Rack E-06",
            qty: "120 kg",
            uhfCode: "1823-F",
            status: MaterialScanStatus.scanned,
          ),
          StockInMaterial(
            name: "Rubber Compound",
            assignedRack: "Pending scan...",
            qty: "Pending",
            uhfCode: "Pending",
            status: MaterialScanStatus.pendingScan,
          ),
        ];
      case "PO-2024-0805":
        return const [
          StockInMaterial(
            name: "Precision Bearing 6204",
            assignedRack: "Rack F-01",
            qty: "500 pcs",
            uhfCode: "9981-G",
            status: MaterialScanStatus.scanned,
          ),
          StockInMaterial(
            name: "Shaft Seal 30x50",
            assignedRack: "Pending scan...",
            qty: "Pending",
            uhfCode: "Pending",
            status: MaterialScanStatus.pendingScan,
          ),
          StockInMaterial(
            name: "O-Ring Kit",
            assignedRack: "Pending scan...",
            qty: "Pending",
            uhfCode: "Pending",
            status: MaterialScanStatus.pendingScan,
          ),
          StockInMaterial(
            name: "Hex Bolt M10",
            assignedRack: "Pending scan...",
            qty: "Pending",
            uhfCode: "Pending",
            status: MaterialScanStatus.pendingScan,
          ),
        ];
      default:
        return const [
          StockInMaterial(
            name: "Material A",
            assignedRack: "Rack Z-01",
            qty: "100 kg",
            uhfCode: "0001-Z",
            status: MaterialScanStatus.scanned,
          ),
          StockInMaterial(
            name: "Material B",
            assignedRack: "Pending scan...",
            qty: "Pending",
            uhfCode: "Pending",
            status: MaterialScanStatus.pendingScan,
          ),
        ];
    }
  }
}
