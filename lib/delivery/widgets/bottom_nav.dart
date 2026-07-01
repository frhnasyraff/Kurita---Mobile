import 'package:flutter/material.dart';
import '../theme.dart';

/// Bottom navigation bar matching the 5-tab layout in every screenshot:
/// Quality, Inventory, Production, Delivery, Others.
/// "Inventory" is the active module for this whole flow, shown as a
/// dark rounded pill, same as in the mockups.
class WorkwiseBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const WorkwiseBottomNav({super.key, this.currentIndex = 1, this.onTap});

  static const _items = [
    _NavItem('Quality', Icons.verified_outlined),
    _NavItem('Inventory', Icons.inventory_2_outlined),
    _NavItem('Production', Icons.precision_manufacturing_outlined),
    _NavItem('Delivery', Icons.local_shipping_outlined),
    _NavItem('Others', Icons.more_horiz),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_items.length, (i) {
            final selected = i == currentIndex;
            final item = _items[i];
            return Expanded(
              child: InkWell(
                onTap: () => onTap?.call(i),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.navy : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          item.icon,
                          size: 20,
                          color: selected ? Colors.white : AppColors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: selected ? AppColors.navy : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  const _NavItem(this.label, this.icon);
}

