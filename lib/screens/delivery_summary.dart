import 'package:flutter/material.dart';
import '../delivery/theme.dart';
import '../delivery/widgets/bottom_nav.dart';
import '../delivery/navigation.dart';
import '../delivery/models/delivery_models.dart';
import '../services/delivery_api_service.dart';
import 'delivery_dashboard.dart';

class DeliverySummaryScreen extends StatelessWidget {
  final DeliveryVehicle vehicle;
  const DeliverySummaryScreen({super.key, required this.vehicle});

  static const fallbackItems = [
    FulfilledDeliveryItem(
        sku: 'CP-982-X', name: 'Premium Catalyst RM', quantity: '450 KG', pallets: '4'),
    FulfilledDeliveryItem(
        sku: 'RS-118-A', name: 'Resin Compound Base', quantity: '1,200 Units', pallets: '3'),
    FulfilledDeliveryItem(
        sku: 'TX-084-B', name: 'Textile Fiber Filler', quantity: '85 LTR / 6 Cans', pallets: '2'),
    FulfilledDeliveryItem(
        sku: 'ZV-772-K', name: 'Zinc Nitrate Industrial', quantity: '12 PLT', pallets: '3'),
  ];

  void _submit(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Delivery'),
        content: Text(
            'Confirm dispatch of ${vehicle.id} to ${vehicle.customer}? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
            onPressed: () async {
              try {
                if (vehicle.jobId != 0) {
                  await DeliveryApiService().submitDelivery(vehicle.jobId);
                }
                if (!context.mounted) return;
                Navigator.pop(ctx);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const DeliveryTheme(
                      child: DeliveryDashboardScreen(),
                    ),
                  ),
                  (route) => false,
                );
              } catch (error) {
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not submit delivery: $error')),
                );
              }
            },
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = vehicle.fulfilledItems.isEmpty
        ? fallbackItems
        : vehicle.fulfilledItems;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Workwise',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17)),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('VEHICLE ID', style: AppTextStyles.cardLabel),
                      const SizedBox(height: 4),
                      Text(vehicle.id,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('DO NUMBER', style: AppTextStyles.cardLabel),
                    const SizedBox(height: 4),
                    Text(vehicle.doNumber,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check,
                            color: AppColors.green, size: 16),
                      ),
                      const SizedBox(width: 10),
                      const Text('PACKING COMPLETE',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('VERIFIED',
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DELIVERY CONTEXT', style: AppTextStyles.cardLabel),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CLIENT NAME',
                                style: TextStyle(
                                    fontSize: 9, color: AppColors.grey)),
                            const SizedBox(height: 3),
                            Text(vehicle.customer,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CLIENT LOCATION',
                                style: TextStyle(
                                    fontSize: 9, color: AppColors.grey)),
                            const SizedBox(height: 3),
                            Text(vehicle.clientLocation,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.blueAccent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('TOTAL PALLETS',
                                style: TextStyle(
                                    fontSize: 9, color: AppColors.grey)),
                            const SizedBox(height: 3),
                            Text('${vehicle.palletsTotal} Pallets',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('PACKING LIST',
                                style: TextStyle(
                                    fontSize: 9, color: AppColors.grey)),
                            const SizedBox(height: 3),
                            Text(vehicle.packingList,
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.blueAccent)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('FULFILLED ITEMS',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800)),
                    SizedBox(height: 2),
                    Text('04 BATCHES | DETAILED BREAKDOWN',
                        style: TextStyle(fontSize: 9, color: AppColors.grey)),
                  ],
                ),
                const Icon(Icons.receipt_long_outlined,
                    size: 18, color: AppColors.grey),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 3,
                            child: Text('PRODUCT (SKU / NAME)',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.w700))),
                        Expanded(
                            flex: 2,
                            child: Text('QTY & UNIT',
                                style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  for (final item in items) ...[
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.sku,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.blueAccent)),
                                Text(item.name,
                                    style: const TextStyle(
                                        fontSize: 11, color: AppColors.grey)),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(item.quantity,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    if (!identical(item, items.last)) const Divider(height: 1),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('GROSS WEIGHT',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                  Text(vehicle.grossWeight,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submit(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.textDark,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
                child: const Text('SUBMIT',
                    style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: WorkwiseBottomNav(
        currentIndex: 3,
        onTap: (i) => goToModule(context, i),
      ),
    );
  }
}
