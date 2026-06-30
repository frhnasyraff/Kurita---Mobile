import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../QualityControl/dashboard_page.dart';
import '../preproduct/material_verification_page.dart';
import '../preproduct/pre_production_page.dart';
import 'change_location_page.dart';
import 'search_inventory_page.dart';
import 'RM/stockIn_page.dart';
import 'FP/product_stock_in_page.dart';

class InventoryDashboardPage extends StatefulWidget {
  const InventoryDashboardPage({super.key});

  @override
  State<InventoryDashboardPage> createState() => _InventoryDashboardPage();
}

class _InventoryDashboardPage extends State<InventoryDashboardPage> {
  final int _selectedNavBar = 1;

  void _navigateTo(int index) {
    if (index == 1) return;
    Widget page;
    switch (index) {
      case 0:
        page = const MaterialVerificationPage(jobId: 'JOB-001');
        break;
      case 2:
        page = const PreProductionPage();
        break;
      case 3:
        page = const DashboardPage();
        break;
      default:
        return;
    }
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (_) => page));
  }

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
        onItemTapped: _navigateTo,
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF17335C),
                    ),
                    child: const Icon(Icons.precision_manufacturing_outlined,
                        color: Colors.white, size: 18),
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
                  _buildHeaderIconButton(
                    icon: Icons.search_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SearchInventoryPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  _buildHeaderIconButton(
                    icon: Icons.account_circle_outlined,
                    onTap: () {},
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Title ──
              const Text(
                "INVENTORY",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF17335C),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Select a category to manage stock.",
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),

              const SizedBox(height: 28),

              // ── RAW MATERIAL Section ──
              _buildSectionHeader(
                icon: Icons.change_history,
                label: "RAW MATERIAL",
              ),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMenuCard(
                        icon: Icons.location_on_outlined,
                        label: "CHANGE\nLOCATION",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChangeLocationPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMenuCard(
                        icon: Icons.move_to_inbox_outlined,
                        label: "STOCK IN",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StockInPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── PRODUCT Section ──
              _buildSectionHeader(
                icon: Icons.inventory_2,
                label: "PRODUCT",
              ),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMenuCard(
                        icon: Icons.location_on_outlined,
                        label: "CHANGE\nLOCATION",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ChangeLocationPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMenuCard(
                        icon: Icons.inventory_2_outlined,
                        label: "STOCK IN",
                        onTap: () {
                          // ← UPDATED: navigate to Product Stock In
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProductStockInPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Search by Lot / Batch Button ──
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchInventoryPage(),
                    ),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF17335C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Text(
                        "SEARCH BY LOT / BATCH NUMBER",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
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

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        icon: Icon(icon, size: 20, color: const Color(0xFF17335C)),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: const Color(0xFF17335C)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF17335C),
                letterSpacing: 0.5,
                fontFamily: 'Inter',

              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(height: 1, color: const Color(0xFFE5E7EB)),
      ],
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF17335C),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28, color: Colors.white),
            ),
            const SizedBox(height: 14),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF17335C),
                letterSpacing: 0.5,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}