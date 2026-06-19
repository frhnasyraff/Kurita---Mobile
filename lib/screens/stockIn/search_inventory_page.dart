import 'package:flutter/material.dart';
import '../dashboard_page.dart';
import '../material_verification_page.dart';
import '../pre_production_page.dart';
import '../widgets/bottom_nav_bar.dart';
import 'change_location_page.dart';
import 'stockIn_page.dart';

class InventorySearchResult {
  final String name;
  final String lotNumber;
  final String batchNumber;
  final String location;
  final String quantity;
  final String status;

  const InventorySearchResult({
    required this.name,
    required this.lotNumber,
    required this.batchNumber,
    required this.location,
    required this.quantity,
    required this.status,
  });
}

class SearchInventoryPage extends StatefulWidget {
  const SearchInventoryPage({super.key});

  @override
  State<SearchInventoryPage> createState() => _SearchInventoryPageState();
}

class _SearchInventoryPageState extends State<SearchInventoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final int _selectedNavBar = 1;
  String _query = '';

  final List<InventorySearchResult> _items = const [
    InventorySearchResult(
      name: 'Industrial Disinfectant X1',
      lotNumber: 'CHM-24-012-A',
      batchNumber: 'BT-9920-A',
      location: 'Lane 04 - Sector B',
      quantity: '520 kg',
      status: 'ACTIVE',
    ),
    InventorySearchResult(
      name: 'Sodium Hypochlorite',
      lotNumber: 'LOT-CHM-992',
      batchNumber: 'BT-8273-X',
      location: 'Rack A-12',
      quantity: '515 kg',
      status: 'ACTIVE',
    ),
    InventorySearchResult(
      name: 'PVC Granules',
      lotNumber: 'LOT-PLY-182',
      batchNumber: 'BT-1820-C',
      location: 'Rack E-03',
      quantity: '300 kg',
      status: 'QC HOLD',
    ),
  ];

  List<InventorySearchResult> get _filteredItems {
    if (_query.trim().isEmpty) return _items;
    final search = _query.toLowerCase();
    return _items.where((item) {
      return item.name.toLowerCase().contains(search) ||
          item.lotNumber.toLowerCase().contains(search) ||
          item.batchNumber.toLowerCase().contains(search) ||
          item.location.toLowerCase().contains(search);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredItems;

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
        onItemTapped: _navigateTo,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              const Text(
                'SEARCH',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF17335C),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Search by input text, scan UHF or scan QR code.',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              _buildSearchField(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildScanCard(
                      icon: Icons.sensors_outlined,
                      label: 'SCAN UHF TAG',
                      onTap: () => _showMessage('Ready to scan UHF tag'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildScanCard(
                      icon: Icons.qr_code_scanner_outlined,
                      label: 'SCAN QR CODE',
                      onTap: () => _showMessage('Ready to scan QR code'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Text(
                    'RESULTS / RECENT SEARCHES',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF6B7280),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${results.length} MATCH FOUND',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF17335C),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (results.isEmpty) _buildEmptyState() else ...results.map(_buildResultCard),
              const SizedBox(height: 20),
              const Center(
                child: Column(
                  children: [
                    Icon(Icons.history, size: 18, color: Color(0xFFB9C2D0)),
                    SizedBox(height: 6),
                    Text(
                      'End of Search Results',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF17335C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Workwise',
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
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _query = value),
      decoration: InputDecoration(
        hintText: 'Search Product, Job Sheet, Lot or PO',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _query.isEmpty
            ? null
            : IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
                icon: const Icon(Icons.close, size: 18),
              ),
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
    );
  }

  Widget _buildScanCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 108,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF17335C), size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF17335C),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(InventorySearchResult item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4EAF2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF17335C)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.2,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF17335C),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildStatusBadge(item.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildTinyLine('LOT', item.lotNumber),
                      _buildTinyLine('BATCH', item.batchNumber),
                      _buildTinyLine('QTY', item.quantity),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF6B7280)),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'Loc: ${item.location}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF17335C),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        label: 'CHANGE LOCATION',
                        icon: Icons.swap_horiz_outlined,
                        filled: false,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeLocationPage(
                              initialItem: item.name,
                              currentLocation: item.location,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        label: 'STOCK IN',
                        icon: Icons.move_to_inbox_outlined,
                        filled: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StockInPage()),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final isActive = status == 'ACTIVE';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFDDEBFF) : const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: isActive ? const Color(0xFF17335C) : const Color(0xFFB45309),
        ),
      ),
    );
  }

  Widget _buildTinyLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF4B5563),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 44,
      child: FilledButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 15),
        label: FittedBox(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: filled ? const Color(0xFF17335C) : Colors.white,
          foregroundColor: filled ? Colors.white : const Color(0xFF17335C),
          side: const BorderSide(color: Color(0xFF17335C)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: const Column(
        children: [
          Icon(Icons.search_off_outlined, color: Color(0xFF98A6B7), size: 32),
          SizedBox(height: 10),
          Text(
            'No matching stock found',
            style: TextStyle(
              color: Color(0xFF17335C),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => page));
  }
}
