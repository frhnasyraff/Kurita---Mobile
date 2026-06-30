import 'package:flutter/material.dart';

import 'package:workwise/app_router.dart';
import '../widgets/bottom_nav_bar.dart';

const _navy = Color(0xFF0C2D63);
const _navy2 = Color(0xFF163A72);
const _line = Color(0xFFD8DEE7);
const _muted = Color(0xFF7E8BA0);
const _text = Color(0xFF101A2D);
const _bg = Color(0xFFF7F8FA);
const _green = Color(0xFF4AA246);
const _lightBlue = Color(0xFFE9F0FF);
const _veryLight = Color(0xFFF1F3F7);

const _fs6 = 7.0;
const _fs7 = 8.0;
const _fs8 = 9.0;
const _fs9 = 10.0;
const _fs10 = 11.0;
const _fs11 = 12.0;
const _fs12 = 13.0;
const _fs13 = 14.0;
const _fs18 = 20.0;
const _fs20 = 22.0;

// Shared bottom navigation definition used across the delivery pages.
// `selectedIndex` mirrors the previous `AppBottomNav(currentIndex: ...)` usage.
List<(IconData icon, String label, bool selected)> _navItems(int selectedIndex) {
  const labels = <(IconData, String)>[
    (Icons.verified_outlined, 'Quality'),
    (Icons.inventory_2_outlined, 'Inventory'),
    (Icons.precision_manufacturing_outlined, 'Production'),
    (Icons.local_shipping_outlined, 'Delivery'),
    (Icons.more_horiz, 'Others'),
  ];
  return List.generate(labels.length, (index) {
    final (icon, label) = labels[index];
    return (icon, label, index == selectedIndex);
  });
}

void _onNavItemTapped(BuildContext context, int index) {
  // Hook up real navigation routes here as needed.
}

enum _LoadingStage { newItems, holdingArea, loaded }

class DeliveryJob {
  const DeliveryJob({
    required this.id,
    required this.vehicleId,
    required this.bay,
    required this.customer,
    required this.doNumber,
    required this.totalPallets,
    required this.packingList,
    required this.progressText,
    required this.progress,
    required this.clientName,
    required this.clientLocation,
    required this.productRows,
  });

  final String id;
  final String vehicleId;
  final String bay;
  final String customer;
  final String doNumber;
  final String totalPallets;
  final String packingList;
  final String progressText;
  final double progress;
  final String clientName;
  final String clientLocation;
  final List<DeliveryProductRow> productRows;
}

class DeliveryProductRow {
  const DeliveryProductRow({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.pallets,
  });

  final String sku;
  final String name;
  final String quantity;
  final String pallets;
}

class DeliveryPallet {
  const DeliveryPallet({
    required this.code,
    required this.itemName,
    required this.meta,
    required this.progressCurrent,
    required this.progressTotal,
    required this.stage,
    required this.badge,
    required this.badgeColor,
    this.timestamp,
    this.canScan = true,
  });

  final String code;
  final String itemName;
  final String meta;
  final int progressCurrent;
  final int progressTotal;
  final _LoadingStage stage;
  final String badge;
  final Color badgeColor;
  final String? timestamp;
  final bool canScan;

  String get progressText => '$progressCurrent/$progressTotal';
}

const _job = DeliveryJob(
  id: 'BPL 1982',
  vehicleId: 'BPL 1982',
  bay: '04',
  customer: 'Global Logistics',
  doNumber: 'D-2024-088',
  totalPallets: '15 Pallets',
  packingList: '12',
  progressText: '75% (12/15 Pallets)',
  progress: .75,
  clientName: 'Global Logistics',
  clientLocation: 'Shah Alam',
  productRows: [
    DeliveryProductRow(
      sku: 'CP-902-X',
      name: 'Premium Catalyst Pdr',
      quantity: '456 KG / 15 Units',
      pallets: '4',
    ),
    DeliveryProductRow(
      sku: 'RS-118-A',
      name: 'Resin Compound Seal',
      quantity: '1,200 Units',
      pallets: '3',
    ),
    DeliveryProductRow(
      sku: 'TX-804-B',
      name: 'Textile Dye Blue-B',
      quantity: '85 LTR / 4 Cans',
      pallets: '2',
    ),
    DeliveryProductRow(
      sku: 'ZV-772-K',
      name: 'Zinc-Verified Industrial',
      quantity: '12 PLT',
      pallets: '3',
    ),
  ],
);

const _pallets = [
  DeliveryPallet(
    code: '#PAL-7829',
    itemName: 'Industrial Disinfectant X1',
    meta: '500 KG · IBC Tank',
    progressCurrent: 1,
    progressTotal: 5,
    stage: _LoadingStage.newItems,
    badge: 'VERIFIED',
    badgeColor: _lightBlue,
  ),
  DeliveryPallet(
    code: '#PAL-7830',
    itemName: 'Corrosive Compound B-4',
    meta: '250 KG · Steel Drum',
    progressCurrent: 0,
    progressTotal: 2,
    stage: _LoadingStage.newItems,
    badge: 'NEW',
    badgeColor: _veryLight,
  ),
  DeliveryPallet(
    code: '#PAL-7831',
    itemName: 'Base Solvent Alpha',
    meta: '800 KG · IBC Tank',
    progressCurrent: 3,
    progressTotal: 3,
    stage: _LoadingStage.holdingArea,
    badge: 'VERIFIED',
    badgeColor: _lightBlue,
  ),
  DeliveryPallet(
    code: '#PAL-7835',
    itemName: 'Organic Peroxide Type F',
    meta: '150 KG · Specialized Crating',
    progressCurrent: 0,
    progressTotal: 1,
    stage: _LoadingStage.holdingArea,
    badge: 'NEW',
    badgeColor: _veryLight,
  ),
  DeliveryPallet(
    code: '#PAL-7829',
    itemName: 'Industrial Disinfectant X1',
    meta: '500 KG · IBC Tank',
    progressCurrent: 1,
    progressTotal: 5,
    stage: _LoadingStage.loaded,
    badge: 'LOADED',
    badgeColor: _lightBlue,
    timestamp: '14:22 PM',
    canScan: false,
  ),
  DeliveryPallet(
    code: '#PAL-7832',
    itemName: 'Heavy-Duty Degreaser G4',
    meta: '420 KG · Steel Drum',
    progressCurrent: 2,
    progressTotal: 5,
    stage: _LoadingStage.loaded,
    badge: 'SCANNED',
    badgeColor: _veryLight,
    canScan: false,
  ),
  DeliveryPallet(
    code: '#PAL-7840',
    itemName: 'Sanitizing Agent S2',
    meta: '380 KG · Plastic Drums',
    progressCurrent: 3,
    progressTotal: 5,
    stage: _LoadingStage.loaded,
    badge: '',
    badgeColor: _veryLight,
  ),
  DeliveryPallet(
    code: '#PAL-7845',
    itemName: 'Ethanol Concentrate 99%',
    meta: '450 KG · IBC Tank',
    progressCurrent: 4,
    progressTotal: 5,
    stage: _LoadingStage.loaded,
    badge: 'LOADED',
    badgeColor: _lightBlue,
    timestamp: '14:15 PM',
    canScan: false,
  ),
];

class DeliveryOverviewPage extends StatefulWidget {
  const DeliveryOverviewPage({super.key});

  @override
  State<DeliveryOverviewPage> createState() => _DeliveryOverviewPageState();
}

class _DeliveryOverviewPageState extends State<DeliveryOverviewPage> {
  final TextEditingController _searchController = TextEditingController();
  _LoadingStage _selectedStage = _LoadingStage.holdingArea;
  bool _showOnlyVerified = false;

  List<DeliveryPallet> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();
    return _pallets.where((item) {
      if (item.stage != _selectedStage) return false;
      if (_showOnlyVerified && item.badge != 'VERIFIED') return false;
      if (query.isEmpty) return true;
      return '${item.code} ${item.itemName} ${item.meta}'.toLowerCase().contains(query);
    }).toList(growable: false);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Pallets',
                  style: TextStyle(
                    color: _navy,
                    fontSize: _fs12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _FilterOption(
                  label: 'Show all pallets',
                  selected: !_showOnlyVerified,
                  onTap: () {
                    setState(() => _showOnlyVerified = false);
                    Navigator.pop(context);
                  },
                ),
                _FilterOption(
                  label: 'Verified only',
                  selected: _showOnlyVerified,
                  onTap: () {
                    setState(() => _showOnlyVerified = true);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: BottomNavBar(
        items: _navItems(3),
        onItemTapped: (index) => _onNavItemTapped(context, index),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: 'TECHNICAL PANEL',
              brandMode: false,
              onLeftTap: () => Navigator.popUntil(context, (route) => route.isFirst),
              onRightTap: () => _showSnack('Technical panel settings opened'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PALLET LOADING',
                      style: TextStyle(
                        color: _navy,
                        fontSize: _fs18,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    _VehicleMeta(job: _job),
                    const SizedBox(height: 10),
                    const _StatusBarCard(),
                    const SizedBox(height: 10),
                    _StageTabs(
                      selected: _selectedStage,
                      onSelected: (stage) => setState(() => _selectedStage = stage),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _SearchField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _FilterButton(
                          active: _showOnlyVerified,
                          onTap: _openFilterSheet,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (items.isEmpty)
                      const _EmptyCard(message: 'No pallets match this filter')
                    else
                      ...items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _LoadingItemCard(
                            pallet: item,
                            onCardTap: () => Navigator.pushNamed(
                              context,
                              Routes.deliveryPalletLoading,
                              arguments: {'job': _job},
                            ),
                            onScanTap: () => _showSnack('Scanning ${item.code}'),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryPalletLoadingPage extends StatefulWidget {
  const DeliveryPalletLoadingPage({super.key, required this.job});

  final DeliveryJob job;

  @override
  State<DeliveryPalletLoadingPage> createState() => _DeliveryPalletLoadingPageState();
}

class _DeliveryPalletLoadingPageState extends State<DeliveryPalletLoadingPage> {
  _LoadingStage _selectedStage = _LoadingStage.loaded;
  int _selectedIndex = 1;
  bool _showScannableOnly = false;

  List<DeliveryPallet> get _filteredItems {
    final stageItems = _pallets.where((item) => item.stage == _selectedStage);
    final filtered = _showScannableOnly
        ? stageItems.where((item) => item.canScan)
        : stageItems;
    return filtered.toList(growable: false);
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Loaded Pallets',
                  style: TextStyle(
                    color: _navy,
                    fontSize: _fs12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _FilterOption(
                  label: 'Show all',
                  selected: !_showScannableOnly,
                  onTap: () {
                    setState(() => _showScannableOnly = false);
                    Navigator.pop(context);
                  },
                ),
                _FilterOption(
                  label: 'Scannable only',
                  selected: _showScannableOnly,
                  onTap: () {
                    setState(() => _showScannableOnly = true);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _selectStage(_LoadingStage stage) {
    setState(() {
      _selectedStage = stage;
      _selectedIndex = 0;
    });
  }

  void _confirmLoaded() {
    Navigator.pushNamed(
      context,
      Routes.deliveryPalletDetails,
      arguments: {'job': widget.job},
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filteredItems;
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: BottomNavBar(
        items: _navItems(3),
        onItemTapped: (index) => _onNavItemTapped(context, index),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: 'TECHNICAL PANEL',
              brandMode: false,
              onLeftTap: () => Navigator.pop(context),
              onRightTap: () => _showSnack('Technical panel settings opened'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PALLET LOADING',
                      style: TextStyle(
                        color: _navy,
                        fontSize: _fs18,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    _VehicleMeta(job: widget.job),
                    const SizedBox(height: 10),
                    _StatusBarCard(
                      progressText: widget.job.progressText,
                      progress: widget.job.progress,
                    ),
                    const SizedBox(height: 10),
                    _StageTabs(
                      selected: _selectedStage,
                      onSelected: _selectStage,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Spacer(),
                        _FilterButton(
                          active: _showScannableOnly,
                          onTap: _openFilterSheet,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (items.isEmpty)
                      const _EmptyCard(message: 'No pallets available')
                    else
                      ...items.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final selected = _selectedStage == _LoadingStage.loaded && index == _selectedIndex;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _LoadingItemCard(
                            pallet: item,
                            compact: true,
                            selected: selected,
                            showConfirmButton: selected,
                            onCardTap: () => setState(() => _selectedIndex = index),
                            onScanTap: item.canScan ? () => _showSnack('Scanning ${item.code}') : null,
                            onConfirmTap: _confirmLoaded,
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryPalletDetailsPage extends StatefulWidget {
  const DeliveryPalletDetailsPage({super.key, required this.job});

  final DeliveryJob job;

  @override
  State<DeliveryPalletDetailsPage> createState() => _DeliveryPalletDetailsPageState();
}

class _DeliveryPalletDetailsPageState extends State<DeliveryPalletDetailsPage> {
  bool _submitted = false;

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _submit() {
    setState(() => _submitted = true);
    _showSnack('Packing complete submitted');
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: BottomNavBar(
        items: _navItems(3),
        onItemTapped: (index) => _onNavItemTapped(context, index),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: 'Workwise',
              brandMode: true,
              onLeftTap: () => Navigator.pop(context),
              onRightTap: () => _showSnack('Workwise settings opened'),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _VehicleDoCard(job: job),
                    const SizedBox(height: 6),
                    _PackingCompleteCard(
                      onTap: () => _showSnack('Packing complete status opened'),
                    ),
                    const SizedBox(height: 8),
                    _ContextCard(job: job),
                    const SizedBox(height: 8),
                    _FulfilledItemsCard(
                      rows: job.productRows,
                      onBreakdownTap: () => _showSnack('Detailed breakdown opened'),
                    ),
                    const SizedBox(height: 8),
                    _GrossWeightCard(
                      submitted: _submitted,
                      onSubmit: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.brandMode,
    this.onLeftTap,
    this.onRightTap,
  });

  final String title;
  final bool brandMode;
  final VoidCallback? onLeftTap;
  final VoidCallback? onRightTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onLeftTap,
            child: Icon(
              brandMode ? Icons.menu_rounded : Icons.science_outlined,
              color: _navy,
              size: 14,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: _navy,
              fontSize: _fs11,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: onRightTap,
            child: const Icon(Icons.settings_outlined, color: _navy, size: 14),
          ),
        ],
      ),
    );
  }
}

class _VehicleMeta extends StatelessWidget {
  const _VehicleMeta({required this.job});

  final DeliveryJob job;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: _muted,
              fontSize: _fs9,
              fontWeight: FontWeight.w500,
            ),
            children: [
              const TextSpan(text: 'Vehicle: '),
              TextSpan(
                text: job.vehicleId,
                style: const TextStyle(color: _text, fontWeight: FontWeight.w800),
              ),
              TextSpan(text: ' | Bay: ${job.bay} | Customer:'),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          job.customer,
          style: const TextStyle(
            color: _text,
            fontSize: _fs11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _StatusBarCard extends StatelessWidget {
  const _StatusBarCard({
    this.progressText = '75% (12/15 Pallets)',
    this.progress = .75,
  });

  final String progressText;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'FULFILLMENT STATUS',
                style: TextStyle(
                  color: _text,
                  fontSize: _fs8,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                progressText,
                style: const TextStyle(
                  color: _navy2,
                  fontSize: _fs8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            height: 4,
            color: const Color(0xFFE7ECF2),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(color: _navy),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageTabs extends StatelessWidget {
  const _StageTabs({
    required this.selected,
    required this.onSelected,
  });

  final _LoadingStage selected;
  final ValueChanged<_LoadingStage> onSelected;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, _LoadingStage stage) {
      final isSelected = selected == stage;
      return Expanded(
        child: InkWell(
          onTap: () => onSelected(stage),
          child: Container(
            padding: const EdgeInsets.only(top: 2, bottom: 6),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? _navy : const Color(0xFFDADFE6),
                  width: isSelected ? 1.3 : 1,
                ),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? _navy : _muted,
                  fontSize: _fs8,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        tab('New', _LoadingStage.newItems),
        tab('Holding Area', _LoadingStage.holdingArea),
        tab('Loaded', _LoadingStage.loaded),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(Icons.search, size: 14, color: _muted),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlignVertical: TextAlignVertical.center,
              style: const TextStyle(
                color: _text,
                fontSize: _fs10,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: 'Search pallet',
                hintStyle: TextStyle(
                  color: _muted,
                  fontSize: _fs10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.active,
    this.onTap,
  });

  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: active ? _lightBlue : Colors.white,
          border: Border.all(color: _line),
        ),
        child: Icon(
          Icons.tune_rounded,
          size: 16,
          color: active ? _navy : _muted,
        ),
      ),
    );
  }
}

class _LoadingItemCard extends StatelessWidget {
  const _LoadingItemCard({
    required this.pallet,
    required this.onCardTap,
    this.onScanTap,
    this.onConfirmTap,
    this.compact = false,
    this.selected = false,
    this.showConfirmButton = false,
  });

  final DeliveryPallet pallet;
  final VoidCallback onCardTap;
  final VoidCallback? onScanTap;
  final VoidCallback? onConfirmTap;
  final bool compact;
  final bool selected;
  final bool showConfirmButton;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onCardTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: selected ? _navy : _line),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF3F8),
                    border: Border.all(color: _line),
                  ),
                  child: const Icon(Icons.inventory_2_outlined, size: 10, color: _navy),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              runSpacing: 2,
                              children: [
                                Text(
                                  pallet.code,
                                  style: const TextStyle(
                                    color: _navy,
                                    fontSize: _fs8,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (pallet.badge.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    color: pallet.badgeColor,
                                    child: Text(
                                      pallet.badge,
                                      style: const TextStyle(
                                        color: _navy,
                                        fontSize: _fs7,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (pallet.timestamp != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Text(
                                pallet.timestamp!,
                                style: const TextStyle(
                                  color: _muted,
                                  fontSize: _fs8,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        pallet.itemName,
                        style: TextStyle(
                          color: _navy,
                          fontSize: compact ? _fs11 : _fs12,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pallet.meta,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: _fs9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Row(
                        children: [
                          Text(
                            '${pallet.progressCurrent}/${pallet.progressTotal}',
                            style: const TextStyle(
                              color: _navy,
                              fontSize: _fs11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            'Pallets',
                            style: TextStyle(
                              color: _navy,
                              fontSize: _fs9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (pallet.canScan)
                  Padding(
                    padding: const EdgeInsets.only(left: 6, top: 10),
                    child: _MiniActionButton(
                      label: 'SCAN',
                      onTap: onScanTap,
                    ),
                  ),
              ],
            ),
            if (showConfirmButton) ...[
              const SizedBox(height: 9),
              InkWell(
                onTap: onConfirmTap,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  color: _navy,
                    child: const Center(
                      child: Text(
                        'CONFIRM LOADED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _fs9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  const _MiniActionButton({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_scanner, size: 10, color: _navy),
            const SizedBox(width: 2),
            Text(
              label,
              style: const TextStyle(
                color: _navy,
                fontSize: _fs6,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleDoCard extends StatelessWidget {
  const _VehicleDoCard({required this.job});

  final DeliveryJob job;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Expanded(
                  child: Text(
                    'VEHICLE ID',
                    style: TextStyle(color: _muted, fontSize: _fs6, fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  child: Text(
                    'DO NUMBER',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: _muted, fontSize: _fs6, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.vehicleId,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: _fs13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    job.doNumber,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: _navy,
                      fontSize: _fs11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PackingCompleteCard extends StatelessWidget {
  const _PackingCompleteCard({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        color: _green,
        child: Row(
          children: [
            const Icon(Icons.inventory_2_outlined, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'PACKING\nCOMPLETE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _fs10,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              color: Colors.white.withOpacity(.18),
              child: const Text(
                'VERIFIED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _fs8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextCard extends StatelessWidget {
  const _ContextCard({required this.job});

  final DeliveryJob job;

  @override
  Widget build(BuildContext context) {
    Widget item(String label, String value) {
      return Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _muted,
                fontSize: _fs6,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: _navy,
                fontSize: _fs9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DELIVERY CONTEXT',
              style: TextStyle(
                color: _muted,
                fontSize: _fs8,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                item('CLIENT NAME', job.clientName),
                const SizedBox(width: 8),
                item('CLIENT LOCATION', job.clientLocation),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                item('TOTAL PALLETS', job.totalPallets),
                const SizedBox(width: 8),
                item('PACKING LIST', job.packingList),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FulfilledItemsCard extends StatelessWidget {
  const _FulfilledItemsCard({
    required this.rows,
    this.onBreakdownTap,
  });

  final List<DeliveryProductRow> rows;
  final VoidCallback? onBreakdownTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
            child: Row(
              children: [
                const Text(
                  'FULFILLED ITEMS',
                  style: TextStyle(
                    color: _navy,
                    fontSize: _fs10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: onBreakdownTap,
                  child: const Icon(Icons.receipt_long_outlined, size: 12, color: _navy),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 6),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '04 BATCHES | DETAILED BREAKDOWN',
                style: TextStyle(
                  color: _muted,
                  fontSize: _fs6,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Container(
            color: _veryLight,
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: const Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'PRODUCT (SKU /\nNAME)',
                    style: TextStyle(color: _muted, fontSize: _fs6, fontWeight: FontWeight.w800),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'QTY & UNIT',
                    style: TextStyle(color: _muted, fontSize: _fs6, fontWeight: FontWeight.w800),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'PAL',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: _muted, fontSize: _fs6, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          ...rows.map(
            (row) => Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: _line)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.sku,
                          style: const TextStyle(
                            color: _navy,
                            fontSize: _fs8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          row.name,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: _fs6,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      row.quantity,
                      style: const TextStyle(
                        color: _text,
                        fontSize: _fs8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      row.pallets,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: _fs8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrossWeightCard extends StatelessWidget {
  const _GrossWeightCard({
    required this.submitted,
    this.onSubmit,
  });

  final bool submitted;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _navy,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        children: [
          const Row(
            children: [
              Text(
                'GROSS WEIGHT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _fs8,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Spacer(),
              Text(
                '4,128.45 KG',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _fs13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onSubmit,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 11),
              child: Center(
                child: Text(
                  submitted ? 'SUBMITTED' : 'SUBMIT',
                  style: const TextStyle(
                    color: _navy,
                    fontSize: _fs12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: _muted,
          fontSize: _fs10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _FilterOption extends StatelessWidget {
  const _FilterOption({
    required this.label,
    required this.selected,
    this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      title: Text(
        label,
        style: TextStyle(
          color: selected ? _navy : _text,
          fontSize: _fs11,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
      trailing: selected ? const Icon(Icons.check_rounded, color: _navy, size: 18) : null,
    );
  }
}