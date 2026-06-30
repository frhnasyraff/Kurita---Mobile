import 'package:flutter/material.dart';

import 'package:workwise/app_router.dart';
import '../widgets/bottom_nav_bar.dart';

class OthersPage extends StatelessWidget {
  const OthersPage({super.key});

  static const _primary = Color(0xFF17335C);
  static const _textDark = Color(0xFF1A2A3A);
  static const _textMuted = Color(0xFF8A99AD);
  static const _border = Color(0xFFE4EAF2);
  static const _danger = Color(0xFFE85D5D);

  void _navigateBottomNav(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.popUntil(context, (route) => route.isFirst);
        break;
      case 1:
        // TODO: navigate to Inventory page.
        break;
      case 2:
        // TODO: navigate to Production page.
        break;
      case 3:
        // TODO: navigate to Delivery page.
        break;
      case 4:
        // Already on Others.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(
        items: const [
          (Icons.verified_outlined, 'Quality', false),
          (Icons.inventory_2_outlined, 'Inventory', false),
          (Icons.precision_manufacturing_outlined, 'Production', false),
          (Icons.local_shipping_outlined, 'Delivery', false),
          (Icons.more_horiz, 'Others', true),
        ],
        onItemTapped: (index) => _navigateBottomNav(context, index),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.blur_on_rounded,
                          color: _primary,
                          size: 12,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Workwise',
                        style: TextStyle(
                          color: _primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.settings_outlined,
                        color: _textMuted,
                        size: 16,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(height: 1, color: _border),
                  const SizedBox(height: 18),
                  const Text(
                    'OTHERS',
                    style: TextStyle(
                      color: _primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _OthersCard(
                    lineLabel: 'LINE 03',
                    title: 'PRE-SAMPLING',
                    badgeText: '2 WAITING',
                    onTap: () => Navigator.pushNamed(
                      context,
                      Routes.preSamplingNew,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _OthersCard(
                    lineLabel: 'LINE 02',
                    title: 'SAMPLING',
                    badgeText: '1 WAITING',
                    onTap: () => Navigator.pushNamed(
                      context,
                      Routes.samplingNew,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OthersCard extends StatelessWidget {
  const _OthersCard({
    required this.lineLabel,
    required this.title,
    required this.badgeText,
    required this.onTap,
  });

  final String lineLabel;
  final String title;
  final String badgeText;
  final VoidCallback onTap;

  static const _primary = OthersPage._primary;
  static const _textDark = OthersPage._textDark;
  static const _textMuted = OthersPage._textMuted;
  static const _border = OthersPage._border;
  static const _danger = OthersPage._danger;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lineLabel,
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        color: _textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _danger.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: const TextStyle(
                          color: _danger,
                          fontSize: 7,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: _primary,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}