import 'package:flutter/material.dart';
import '../delivery/theme.dart';
import '../delivery/widgets/bottom_nav.dart';
import '../delivery/navigation.dart';
import '../delivery/models/delivery_models.dart';
import '../services/delivery_api_service.dart';
import 'pallet_details.dart';
import 'delivery_summary.dart';

class PalletLoadingScreen extends StatefulWidget {
  final DeliveryVehicle vehicle;
  const PalletLoadingScreen({super.key, required this.vehicle});

  @override
  State<PalletLoadingScreen> createState() => _PalletLoadingScreenState();
}

class _PalletLoadingScreenState extends State<PalletLoadingScreen> {
  final _api = DeliveryApiService();
  int _tabIndex = 0; // 0 = New, 1 = Holding Area, 2 = Loaded

  List<PalletItem> get _new =>
      widget.vehicle.pallets.where((p) => p.status == PalletStatus.new_).toList();
  List<PalletItem> get _holding =>
      widget.vehicle.pallets.where((p) => p.status == PalletStatus.holding).toList();
  List<PalletItem> get _loaded =>
      widget.vehicle.pallets.where((p) => p.status == PalletStatus.loaded).toList();

  double get _fulfillment {
    final total = widget.vehicle.pallets.fold<int>(0, (a, p) => a + p.palletsRequired);
    final done = widget.vehicle.pallets.fold<int>(
        0, (a, p) => a + (p.status == PalletStatus.new_ ? 0 : p.palletsRequired));
    return total == 0 ? 0 : done / total;
  }

  Future<void> _openDetails(PalletItem item) async {
    try {
      final detail = item.apiId == 0 ? null : await _api.fetchPalletDetail(item.apiId);
      if (!mounted) return;
      final detailedItem = detail == null
          ? item
          : PalletItem(
              apiId: item.apiId,
              id: item.id,
              name: detail.name,
              batch: detail.batch,
              weight: double.tryParse(RegExp(r'[0-9]+(?:\.[0-9]+)?')
                          .firstMatch(detail.netWeight)
                          ?.group(0) ??
                      '') ??
                  item.weight,
              weightUnit: detail.netWeight.replaceAll(RegExp(r'[0-9.\s]'), ''),
              container: detail.containerType,
              palletsRequired: item.palletsRequired,
              palletsScanned: item.palletsScanned,
              status: item.status,
              scanTime: item.scanTime,
              warehouseLane: detail.zone,
              warehouseBay: detail.rack,
              warehouseRow: detail.level,
              warehouseCol: detail.bay,
            );
      final scanned = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => DeliveryTheme(
            child: PalletDetailsScreen(item: detailedItem),
          ),
        ),
      );
      if (scanned == true && mounted) {
        setState(() {
          item.status = PalletStatus.holding;
          item.palletsScanned = item.palletsRequired;
          item.scanTime = TimeOfDay.now().format(context);
        });
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open pallet: $error')),
      );
    }
  }

  Future<void> _scanNewPallet(PalletItem item) async {
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
      if (item.apiId != 0) await _api.scanPallet(item.apiId);
      if (!mounted) return;
      Navigator.pop(context);
      setState(() {
        item.status = PalletStatus.holding;
        item.palletsScanned = item.palletsRequired;
        item.scanTime = TimeOfDay.now().format(context);
        _tabIndex = 1;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.id} moved to Holding Area')),
      );
    } catch (error) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not scan pallet: $error')),
      );
    }
  }

  Future<void> _confirmLoaded(PalletItem item) async {
    try {
      if (item.apiId != 0) await _api.scanPallet(item.apiId);
      if (!mounted) return;
      setState(() {
        item.status = PalletStatus.loaded;
        _tabIndex = 2;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${item.id} marked as loaded')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load pallet: $error')),
      );
    }
  }

  Future<void> _viewSummary({bool confirmDelivery = false}) async {
    try {
      if (widget.vehicle.jobId != 0) {
        if (confirmDelivery) {
          await _api.confirmLoaded(widget.vehicle.jobId);
        }
        final summary = await _api.fetchPackingSummary(widget.vehicle.jobId);
        widget.vehicle
          ..clientLocation = summary.clientLocation
          ..packingList = summary.packingList
          ..grossWeight = summary.grossWeight
          ..fulfilledItems = summary.items
              .map(
                (item) => FulfilledDeliveryItem(
                  sku: item.sku,
                  name: item.name,
                  quantity: item.quantity,
                  pallets: item.pallets,
                ),
              )
              .toList(growable: false);
      }
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DeliveryTheme(
            child: DeliverySummaryScreen(vehicle: widget.vehicle),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not prepare packing summary: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final allLoaded = widget.vehicle.pallets.isNotEmpty &&
        widget.vehicle.pallets.every((p) => p.status == PalletStatus.loaded);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('TECHNICAL PANEL'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('PALLET LOADING', style: AppTextStyles.screenTitle),
                  const SizedBox(height: 4),
                  Text(
                    'Vehicle: ${widget.vehicle.id} | Bay: ${widget.vehicle.bay} | Customer: ${widget.vehicle.customer}',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('FULFILLMENT STATUS', style: AppTextStyles.cardLabel),
                      Text(
                          '${(_fulfillment * 100).round()}% (${widget.vehicle.palletsDone}/${widget.vehicle.palletsTotal} Pallets)',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _fulfillment,
                      minHeight: 6,
                      backgroundColor: AppColors.lightGrey,
                      valueColor: const AlwaysStoppedAnimation(AppColors.navy),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _LoadingTab(
                          label: 'New',
                          count: _new.length,
                          selected: _tabIndex == 0,
                          onTap: () => setState(() => _tabIndex = 0),
                        ),
                      ),
                      Expanded(
                        child: _LoadingTab(
                          label: 'Holding Area',
                          count: _holding.length,
                          selected: _tabIndex == 1,
                          onTap: () => setState(() => _tabIndex = 1),
                        ),
                      ),
                      Expanded(
                        child: _LoadingTab(
                          label: 'Loaded',
                          count: _loaded.length,
                          selected: _tabIndex == 2,
                          onTap: () => setState(() => _tabIndex = 2),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  if (_tabIndex == 0)
                    for (final item in _new) ...[
                      _PalletCard(
                        item: item,
                        actionLabel: 'SCAN',
                        onTap: () => _openDetails(item),
                        onAction: () => _scanNewPallet(item),
                      ),
                      const SizedBox(height: 10),
                    ]
                  else if (_tabIndex == 1)
                    for (final item in _holding) ...[
                      _PalletCard(
                        item: item,
                        actionLabel: 'CONFIRM LOADED',
                        isPrimary: true,
                        onAction: () => _confirmLoaded(item),
                      ),
                      const SizedBox(height: 10),
                    ]
                  else
                    for (final item in _loaded) ...[
                      _PalletCard(
                        item: item,
                        onTap: () => _viewSummary(),
                      ),
                      const SizedBox(height: 10),
                    ],
                  if (_tabIndex == 2 && allLoaded) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _viewSummary(confirmDelivery: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.task_alt, color: Colors.white),
                        label: const Text('VIEW PACKING SUMMARY',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5)),
                      ),
                    ),
                  ],
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

class _LoadingTab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _LoadingTab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('$label${count > 0 ? ' ($count)' : ''}',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected ? AppColors.textDark : AppColors.grey)),
          const SizedBox(height: 4),
          if (selected)
            Container(width: 24, height: 2, color: AppColors.navy),
        ],
      ),
    );
  }
}

class _PalletCard extends StatelessWidget {
  final PalletItem item;
  final VoidCallback? onTap;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool isPrimary;

  const _PalletCard({
    required this.item,
    this.onTap,
    this.actionLabel,
    this.onAction,
    this.isPrimary = false,
  });

  Color get _badgeColor {
    switch (item.status) {
      case PalletStatus.new_:
        return item.palletsScanned == 0 ? AppColors.grey : const Color(0xFFB07A16);
      case PalletStatus.holding:
        return AppColors.blueAccent;
      case PalletStatus.loaded:
        return AppColors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
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
                    Row(
                      children: [
                        Text(item.id,
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.grey,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _badgeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(item.statusLabel,
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: _badgeColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(item.name,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                        '${item.weight.toStringAsFixed(0)} ${item.weightUnit} - ${item.container}',
                        style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                    const SizedBox(height: 2),
                    Text(
                        '${item.status == PalletStatus.new_ ? item.palletsScanned : item.palletsRequired}/${item.palletsRequired} Pallets',
                        style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                  ],
                ),
              ),
              if (item.scanTime != null)
                Text(item.scanTime!,
                    style: const TextStyle(fontSize: 10, color: AppColors.grey)),
            ],
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: isPrimary
                  ? ElevatedButton(
                      onPressed: onAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.navy,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(actionLabel!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
                    )
                  : OutlinedButton.icon(
                      onPressed: onAction,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.qr_code_scanner,
                          size: 15, color: AppColors.navy),
                      label: Text(actionLabel!,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                    ),
            ),
          ],
        ],
        ),
      ),
    );
  }
}
