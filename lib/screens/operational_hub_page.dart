import 'package:flutter/material.dart';
import 'widgets/bottom_nav_bar.dart';
import 'PreProduct/material_verification_page.dart';
import 'stockIn/inventory_dashboard_page.dart';
import 'PreProduct/pre_production_page.dart';
import 'QualityControl/dashboard_page.dart';
import 'QualityControl/quality_control_page.dart';
import 'Production/production_page.dart';
import 'delivery_dashboard.dart';
import '../delivery/theme.dart';

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// MODEL
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class HubAlert {
  final String title;
  final String subtitle;
  final AlertSeverity severity;

  const HubAlert({
    required this.title,
    required this.subtitle,
    required this.severity,
  });
}

enum AlertSeverity { critical, info }

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// PAGE
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class OperationalHubPage extends StatefulWidget {
  const OperationalHubPage({super.key});

  @override
  State<OperationalHubPage> createState() => _OperationalHubPageState();
}

class _OperationalHubPageState extends State<OperationalHubPage> {
  // â”€â”€ Theme palette (light, from HTML tailwind config) â”€â”€
  static const Color primary = Color(0xFF002046);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surfaceLowest = Color(0xFFFFFFFF);
  static const Color outlineVariant = Color(0xFFC4C6CF);
  static const Color secondary = Color(0xFF515F74);
  static const Color primaryContainer = Color(0xFF1B365D);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color secondaryContainer = Color(0xFFD5E3FC);

  final List<HubAlert> _alerts = const [
    HubAlert(
      title: "Low Coolant Level - Lane 4",
      subtitle: "Critical: Action Required Immediately",
      severity: AlertSeverity.critical,
    ),
    HubAlert(
      title: "Calibration Required - Unit T-02",
      subtitle: "Scheduled maintenance window: 2:00 PM",
      severity: AlertSeverity.info,
    ),
    HubAlert(
      title: "Unscheduled Downtime - Packer 1",
      subtitle: "System sensor failure detected",
      severity: AlertSeverity.critical,
    ),
  ];

  void _navigateToModule(String label) {
    Widget? page;
    switch (label) {
      case "QUALITY":
        page = const QualityControlPage();
        break;
      case "INVENTORY":
        page = const InventoryDashboardPage();
        break;
      case "PRODUCTION":
        page = const ProductionPage();
        break;
      case "DELIVERY":
        page = const DeliveryTheme(child: DeliveryDashboardScreen());
        break;
      case "OTHERS":
        // TODO: Others / Settings page
        return;
    }
    if (page != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      bottomNavigationBar: BottomNavBar(
        items: const [
          (Icons.verified_outlined, 'Quality', false),
          (Icons.inventory_2_outlined, 'Inventory', false),
          (Icons.precision_manufacturing_outlined, 'Production', false),
          (Icons.local_shipping_outlined, 'Delivery', false),
          (Icons.more_horiz, 'Others', false),
        ],
        onItemTapped: (index) {
          const labels = [
            "QUALITY",
            "INVENTORY",
            "PRODUCTION",
            "DELIVERY",
            "OTHERS"
          ];
          _navigateToModule(labels[index]);
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // â”€â”€ Header â”€â”€
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
                      color: primary,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_outlined,
                          color: primary),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // â”€â”€ Title â”€â”€
              const Text(
                "OPERATIONAL HUB",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: primary,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Select a module to begin your tasks.",
                style: TextStyle(
                  fontSize: 13,
                  color: secondary,
                ),
              ),

              const SizedBox(height: 20),

              // â”€â”€ Module list â”€â”€
              _buildModuleTile(
                icon: Icons.verified_outlined,
                label: "QUALITY",
                description: "Compliance & Safety Protocols",
              ),
              const SizedBox(height: 12),
              _buildModuleTile(
                icon: Icons.inventory_2_outlined,
                label: "INVENTORY",
                description: "Assets & Warehouse Logistics",
              ),
              const SizedBox(height: 12),
              _buildModuleTile(
                icon: Icons.precision_manufacturing_outlined,
                label: "PRODUCTION",
                description: "Efficiency & Work Orders",
              ),
              const SizedBox(height: 12),
              _buildModuleTile(
                icon: Icons.local_shipping_outlined,
                label: "DELIVERY",
                description: "Fleet Dispatch & Tracking",
              ),
              const SizedBox(height: 12),
              _buildModuleTile(
                icon: Icons.more_horiz,
                label: "OTHERS",
                description: "System Utilities & Settings",
              ),

              const SizedBox(height: 24),

              // â”€â”€ Active Alerts â”€â”€
              const Text(
                "ACTIVE ALERTS",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFBA1A1A),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              ..._alerts.map((alert) => _buildAlertCard(alert)),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // MODULE TILE
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildModuleTile({
    required IconData icon,
    required String label,
    required String description,
  }) {
    return GestureDetector(
      onTap: () => _navigateToModule(label),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceLowest,
          border: Border.all(color: outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(color: primaryContainer),
              child: Icon(icon, color: const Color(0xFF87A0CD), size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            "LAUNCH",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: primary,
                              letterSpacing: 0.6,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 14, color: primary),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // ALERT CARD
  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  Widget _buildAlertCard(HubAlert alert) {
    final isCritical = alert.severity == AlertSeverity.critical;
    final bgColor = isCritical ? errorContainer : secondaryContainer;
    final iconColor = isCritical ? const Color(0xFFBA1A1A) : primary;
    final textColor = isCritical ? onErrorContainer : primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: iconColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCritical ? Icons.warning_amber_rounded : Icons.info_outline,
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: textColor.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
