import 'package:flutter/material.dart';
import '../widgets/bottom_nav_bar.dart';
import '../preproduct/material_verification_page.dart';
import '../stockIn/inventory_dashboard_page.dart';
import '../preproduct/pre_production_page.dart';
import 'dashboard_page.dart';

// ─────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────
//
// Rebuilt to match the reference HTML/Tailwind design exactly:
//  - bg-surface-container (#EDEEEF) cards, no border-radius
//  - icon sits in a primary-container (#1B365D) box ABOVE the title,
//    icon itself is plain white (on-primary), not pale blue
//  - title + description, then an internal divider (border-t), then a
//    bottom row with the QC code (monospace) + a forward arrow
//  - cards use flex-grow equivalent (Expanded) so the column of 4 cards
//    always fills the available height down to the bottom nav — matches
//    `flex-grow grid ... min-h-0` behavior in the HTML, using a single
//    column since this is a phone-width layout (HTML's grid-cols-1
//    breakpoint, not the md:grid-cols-2 one)
class QualityControlPage extends StatefulWidget {
  const QualityControlPage({super.key});

  @override
  State<QualityControlPage> createState() => _QualityControlPageState();
}

class _QualityControlPageState extends State<QualityControlPage> {
  // ── Theme palette — taken directly from the HTML tailwind.config colors ──
  static const Color primary = Color(0xFF002046);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surfaceContainer = Color(0xFFEDEEEF);
  static const Color outlineVariant = Color(0xFFC4C6CF);
  static const Color outline = Color(0xFF74777F);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF44474E);
  static const Color primaryContainer = Color(0xFF1B365D);
  static const Color secondaryContainer = Color(0xFFD1E1F4);

  void _navigateToCategory(String code) {
    Widget? page;
    switch (code) {
      case "QC-01": // Receiving
        page = const DashboardPage();
        break;
      case "QC-02": // Pre-Production
        page = const PreProductionPage();
        break;
      case "QC-03": // Product — shares the Pre-Production page for now
        page = const PreProductionPage();
        break;
      case "QC-04": // Others
        // TODO: Others QC page
        return;
    }
    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }

  void _navigateBottomNav(int index) {
    Widget? page;
    switch (index) {
      case 0: // Quality — already here
        return;
      case 1:
        page = const InventoryDashboardPage();
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
        .pushReplacement(MaterialPageRoute(builder: (_) => page!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      bottomNavigationBar: BottomNavBar(
        items: const [
          (Icons.verified_outlined, 'Quality', true),
          (Icons.inventory_2_outlined, 'Inventory', false),
          (Icons.precision_manufacturing_outlined, 'Production', false),
          (Icons.local_shipping_outlined, 'Delivery', false),
          (Icons.more_horiz, 'Others', false),
        ],
        onItemTapped: _navigateBottomNav,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header (TopAppBar in the HTML) ──
              Row(
                children: [
                   Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: outlineVariant),
                    ),
                    child: const Icon(Icons.account_circle_outlined,
                        color: primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Workwise",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined, color: primary),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Hero / Title section ──
              const Text(
                "QUALITY CONTROL",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: onSurface,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Select a category to begin inspections.",
                style: TextStyle(
                  fontSize: 13,
                  color: onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 16),

              // ── Category cards — fill remaining height when there's
              // room; fall back to a scrollable compact list if the
              // viewport is too short to fit all 4 cards without
              // squeezing their content (prevents RenderFlex overflow).
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    const minCardHeight = 132.0;
                    const gap = 12.0;
                    final minNeeded = (minCardHeight * 4) + (gap * 3);

                    final cards = [
                      _buildCategoryTile(
                        icon: Icons.inventory_2,
                        title: "RECEIVING",
                        description: "Inbound Material Verification",
                        code: "QC-01",
                      ),
                      _buildCategoryTile(
                        icon: Icons.precision_manufacturing,
                        title: "PRE-PRODUCTION",
                        description: "Line Setup & Validation",
                        code: "QC-02",
                      ),
                      _buildCategoryTile(
                        icon: Icons.verified,
                        title: "PRODUCT",
                        description: "Final Goods Quality Assurance",
                        code: "QC-03",
                      ),
                      _buildCategoryTile(
                        icon: Icons.more_horiz,
                        title: "OTHERS",
                        description: "System Utilities & Settings",
                        code: "QC-04",
                      ),
                    ];

                    if (constraints.maxHeight >= minNeeded) {
                      // Enough room — fill the screen, equal heights.
                      return Column(
                        children: [
                          for (var i = 0; i < cards.length; i++) ...[
                            if (i != 0) const SizedBox(height: gap),
                            Expanded(child: cards[i]),
                          ],
                        ],
                      );
                    }

                    // Not enough room — scroll instead of overflowing.
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var i = 0; i < cards.length; i++) ...[
                            if (i != 0) const SizedBox(height: gap),
                            SizedBox(height: minCardHeight, child: cards[i]),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // CATEGORY CARD
  // Layout per the HTML: icon box on top, then title + description,
  // then an internal divider, then a bottom row with the QC code and
  // a forward arrow — all stacked vertically inside the card.
  // ─────────────────────────────────────────
  Widget _buildCategoryTile({
    required IconData icon,
    required String title,
    required String description,
    required String code,
  }) {
    return GestureDetector(
      onTap: () => _navigateToCategory(code),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: surfaceContainer,
          border: Border.fromBorderSide(
            BorderSide(color: outlineVariant, width: 1),
          ),
          // no borderRadius, no boxShadow — flat, square card per reference
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ── Icon box ──
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: primaryContainer,
                border: Border.fromBorderSide(
                  BorderSide(color: outlineVariant, width: 1),
                ),
              ),
              child: Icon(icon, color: onPrimary, size: 22),
            ),

            // ── Title + description ──
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: onSurface,
                      letterSpacing: 0.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // ── Divider + bottom row (code + arrow) ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 6),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: outlineVariant, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'Courier Prime',
                      fontWeight: FontWeight.w600,
                      color: primary,
                      letterSpacing: 0.05,
                    ),
                  ),
                  const Icon(Icons.arrow_forward,
                      color: onSurfaceVariant, size: 18),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}