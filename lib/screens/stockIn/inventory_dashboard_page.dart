import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../dashboard_page.dart';
import '../material_verification_page.dart';
import '../pre_production_page.dart';
import 'change_location_page.dart';
import 'search_inventory_page.dart';
import 'stockIn_page.dart';
import 'product_stock_in_page.dart';

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
                    decoration: BoxDecoration(
                      color: const Color(0xFF17335C),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.inventory_2_outlined,
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
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SearchInventoryPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.search_outlined),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.account_circle_outlined),
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
                icon: Icons.science_outlined,
                label: "RAW MATERIAL",
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      icon: Icons.swap_horiz_outlined,
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

              const SizedBox(height: 28),

              // ── PRODUCT Section ──
              _buildSectionHeader(
                icon: Icons.category_outlined,
                label: "PRODUCT",
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMenuCard(
                      icon: Icons.swap_horiz_outlined,
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
                      icon: Icons.output_outlined,
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
                    borderRadius: BorderRadius.circular(14),
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

  Widget _buildSectionHeader({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF17335C)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Color(0xFF17335C),
            letterSpacing: 0.5,
          ),
        ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 28, color: const Color(0xFF17335C)),
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
