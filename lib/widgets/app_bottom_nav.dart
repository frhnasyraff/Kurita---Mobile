import 'package:flutter/material.dart';
import 'package:workwise/screens/delivery_pages.dart';
import 'package:workwise/screens/dashboard_page.dart';
import 'package:workwise/screens/others_page.dart';
import 'package:workwise/screens/pre_production_page.dart';
import 'package:workwise/screens/stock_count_dashboard_page.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;

  const AppBottomNav({super.key, required this.currentIndex});

  static const Color navy = Color(0xFF17335C);
  static const Color textGrey = Color(0xFF8A99AD);

  void _onTap(BuildContext context, int index) {
    if (index == currentIndex) return;

    switch (index) {
      case 0: // Quality
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
        break;
      case 1: // Inventory
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StockCountDashboardPage()),
        );
        break;
      case 2: // Production
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PreProductionPage()),
        );
        break;
      case 3: // Delivery
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DeliveryOverviewPage()),
        );
        break;
      case 4: // Others
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OthersPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.verified_outlined, 'Quality'),
      (Icons.inventory_2_outlined, 'Inventory'),
      (Icons.precision_manufacturing_outlined, 'Production'),
      (Icons.local_shipping_outlined, 'Delivery'),
      (Icons.more_horiz_outlined, 'Others'),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4EAF2))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final selected = index == currentIndex;
            return GestureDetector(
              onTap: () => _onTap(context, index),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: selected ? 12 : 0,
                  vertical: selected ? 8 : 0,
                ),
                decoration: BoxDecoration(
                  color: selected ? navy : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.$1,
                      size: 22,
                      color: selected ? Colors.white : textGrey,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$2,
                      style: TextStyle(
                        color: selected ? Colors.white : textGrey,
                        fontSize: 11,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
