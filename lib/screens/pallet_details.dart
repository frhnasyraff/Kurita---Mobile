import 'package:flutter/material.dart';
import '../delivery/theme.dart';
import '../delivery/widgets/bottom_nav.dart';
import '../delivery/navigation.dart';
import '../delivery/models/delivery_models.dart';
import '../services/delivery_api_service.dart';

class PalletDetailsScreen extends StatefulWidget {
  final PalletItem item;
  const PalletDetailsScreen({super.key, required this.item});

  @override
  State<PalletDetailsScreen> createState() => _PalletDetailsScreenState();
}

class _PalletDetailsScreenState extends State<PalletDetailsScreen> {
  final _api = DeliveryApiService();
  bool _scanned = false;

  Future<void> _scanPallet() async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const AlertDialog(
        content: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 16),
            Text('Scanning pallet...'),
          ],
        ),
      ),
    );
    try {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (widget.item.apiId != 0) {
        await _api.scanPallet(widget.item.apiId);
      }
      if (!mounted) return;
      Navigator.pop(context);
      setState(() => _scanned = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dummy scanner completed successfully')),
      );
    } catch (error) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not scan pallet: $error')),
      );
    }
  }

  void _verifyInHolding() {
    if (!_scanned) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Scan the pallet before verifying it in holding.')),
      );
      return;
    }
    widget.item.status = PalletStatus.holding;
    widget.item.palletsScanned = widget.item.palletsRequired;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        titleSpacing: 4,
        leadingWidth: 40,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Icon(Icons.local_shipping_outlined, color: Colors.white, size: 20),
        ),
        title: const Text('WORKWISE',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                children: [
                  const Text('PALLET DETAILS',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Container(width: 44, height: 3, color: AppColors.navy),
                  const SizedBox(height: 18),

                  // Current lifecycle status
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('CURRENT LIFECYCLE STATUS',
                            style: AppTextStyles.cardLabel),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.navy,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(_scanned ? 'SCANNED' : 'NEW',
                              style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Product card (name + batch + net weight / container)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name,
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.navy)),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGrey,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text('BATCH: ${item.batch}',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.grey)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.inventory_2_outlined,
                                size: 18, color: AppColors.grey),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('NET WEIGHT',
                                      style: AppTextStyles.cardLabel),
                                  const SizedBox(height: 4),
                                  Text(
                                      '${item.weight.toStringAsFixed(0)} ${item.weightUnit}',
                                      style: const TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('CONTAINER TYPE',
                                      style: AppTextStyles.cardLabel),
                                  const SizedBox(height: 4),
                                  Text(item.container,
                                      style: const TextStyle(
                                          fontSize: 14, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Warehouse storage coordinates
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textDark),
                      const SizedBox(width: 6),
                      const Text('WAREHOUSE STORAGE COORDINATES',
                          style: AppTextStyles.cardLabel),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _CoordCell(label: 'ZONE', value: item.warehouseLane ?? '--'),
                            ),
                            Container(width: 1, height: 62, color: AppColors.border),
                            Expanded(
                              child: _CoordCell(label: 'RACK', value: item.warehouseBay ?? '--'),
                            ),
                          ],
                        ),
                        Container(height: 1, color: AppColors.border),
                        Row(
                          children: [
                            Expanded(
                              child: _CoordCell(label: 'LEVEL', value: item.warehouseRow ?? '--'),
                            ),
                            Container(width: 1, height: 62, color: AppColors.border),
                            Expanded(
                              child: _CoordCell(label: 'BAY', value: item.warehouseCol ?? '--'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom action buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _scanned ? null : _scanPallet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        disabledBackgroundColor: AppColors.navy.withOpacity(0.5),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.qr_code_scanner,
                          color: Colors.white, size: 18),
                      label: Text(_scanned ? 'PALLET SCANNED' : 'SCAN PALLET',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 0.4)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: _verifyInHolding,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: Icon(Icons.check_circle_outline,
                          size: 16,
                          color: _scanned ? AppColors.navy : AppColors.grey),
                      label: Text('VERIFY IN HOLDING AREA',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 0.4,
                              color: _scanned ? AppColors.navy : AppColors.grey)),
                    ),
                  ),
                ],
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

class _CoordCell extends StatelessWidget {
  final String label;
  final String value;
  const _CoordCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 9, color: AppColors.grey, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
