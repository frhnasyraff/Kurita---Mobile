import 'package:flutter/material.dart';
import 'pre_production_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF17335C);
    const secondaryText = Color(0xFF6F8096);

    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const _DashboardNavBar(),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: const Icon(
                          Icons.inventory_2_rounded,
                          color: primary,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Workwise',
                        style: TextStyle(
                          color: primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'RECEIVING SUMMARY',
                    style: TextStyle(
                      color: primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Operational status and logistics tracking.',
                    style: TextStyle(color: secondaryText, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _FilterChip(
                          icon: Icons.calendar_today_outlined,
                          label: 'Oct 24, 2023',
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: _FilterChip(
                          icon: Icons.keyboard_arrow_down_rounded,
                          label: 'All',
                          trailingOnly: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD9E2ED)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.search_rounded,
                            color: secondaryText, size: 18),
                        SizedBox(width: 10),
                        Text(
                          'Search by PO Number',
                          style:
                          TextStyle(color: secondaryText, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Shipment cards — tap to go to Pre-Production
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PreProductionPage()),
                    ),
                    child: const _ShipmentCard(
                      company: 'Industrial Alloys Inc.',
                      skuCount: '12 SKUs',
                      date: 'Oct 24',
                      status: 'PENDING',
                      statusColor: Color(0xFF67A8F4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PreProductionPage()),
                    ),
                    child: const _ShipmentCard(
                      company: 'Global Logistics Corp',
                      skuCount: '48 SKUs',
                      date: 'Oct 25',
                      status: 'IN PROCESS',
                      statusColor: Color(0xFF5AB87A),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'DAILY STATISTICS',
                    style: TextStyle(
                      color: primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: _StatsCard(
                          label: 'EXPECTED TODAY',
                          value: '08',
                          accent: Color(0xFF17335C),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _StatsCard(
                          label: 'TOTAL COMPLETED',
                          value: '12',
                          accent: Color(0xFF5AB87A),
                        ),
                      ),
                    ],
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    this.trailingOnly = false,
  });

  final IconData icon;
  final String label;
  final bool trailingOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD9E2ED)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (!trailingOnly) ...[
            Icon(icon, size: 16, color: const Color(0xFF6F8096)),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF42546B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (trailingOnly)
            Icon(icon, size: 18, color: const Color(0xFF6F8096)),
        ],
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  const _ShipmentCard({
    required this.company,
    required this.skuCount,
    required this.date,
    required this.status,
    required this.statusColor,
  });

  final String company;
  final String skuCount;
  final String date;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE4EE)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D18304D),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  company,
                  style: const TextStyle(
                    color: Color(0xFF233A5B),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.widgets_outlined,
                        size: 14, color: Color(0xFF91A0B2)),
                    const SizedBox(width: 4),
                    Text(skuCount,
                        style: const TextStyle(
                            color: Color(0xFF7C8CA0), fontSize: 12)),
                    const SizedBox(width: 12),
                    const Icon(Icons.schedule_outlined,
                        size: 14, color: Color(0xFF91A0B2)),
                    const SizedBox(width: 4),
                    Text(date,
                        style: const TextStyle(
                            color: Color(0xFF7C8CA0), fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right_rounded,
              color: Color(0xFF8697AC)),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFDCE4EE)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF8A99AD),
                  fontSize: 10,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  color: accent,
                  fontSize: 32,
                  fontWeight: FontWeight.w300)),
        ],
      ),
    );
  }
}

class _DashboardNavBar extends StatelessWidget {
  const _DashboardNavBar();

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.verified_outlined, 'Quality', false),
      (Icons.inventory_2_outlined, 'Inventory', false),
      (Icons.precision_manufacturing_outlined, 'Production', false),
      (Icons.local_shipping_outlined, 'Delivery', true),
    ];

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
          children: items.map((item) {
            final (icon, label, selected) = item;
            return GestureDetector(
              onTap: () {
                if (label == 'Production') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PreProductionPage()),
                  );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon,
                      size: 20,
                      color: selected
                          ? const Color(0xFF17335C)
                          : const Color(0xFF98A6B7)),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFF17335C)
                          : const Color(0xFF98A6B7),
                      fontSize: 10,
                      fontWeight: selected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}