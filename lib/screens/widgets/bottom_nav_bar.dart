import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final List<(IconData icon, String label, bool selected)> items;
  final Function(int)? onItemTapped;

  const BottomNavBar({
    super.key,
    required this.items,
    this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE4EAF2))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final (icon, label, isSelected) = items[index];

            return GestureDetector(
              onTap: () => onItemTapped?.call(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? const Color(0xFF17335C)
                        : const Color(0xFF98A6B7),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF17335C)
                          : const Color(0xFF98A6B7),
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
