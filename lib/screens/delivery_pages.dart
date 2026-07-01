import 'package:flutter/material.dart';

import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:workwise/services/delivery_api_service.dart';
import 'package:workwise/widgets/app_bottom_nav.dart';

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

enum _LoadingStage { newItems, holdingArea, loaded }
enum _DeliveryOverviewTab { readyToLoad, inProgress, completed }

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

  int get numericId => int.tryParse(id) ?? 0;
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

class DeliveryFlowPallet {
  DeliveryFlowPallet({
    required this.id,
    required this.code,
    required this.itemName,
    required this.meta,
    required this.progressCurrent,
    required this.progressTotal,
    required this.batchCode,
    required this.netWeight,
    required this.containerType,
    required this.lane,
    required this.rack,
    required this.level,
    required this.bay,
    this.stage = _LoadingStage.newItems,
    this.badge = 'NEW',
    this.badgeColor = _veryLight,
    this.timestamp,
    this.canScan = true,
  });

  final int id;
  final String code;
  final String itemName;
  final String meta;
  final int progressCurrent;
  final int progressTotal;
  final String batchCode;
  final String netWeight;
  final String containerType;
  final String lane;
  final String rack;
  final String level;
  final String bay;
  _LoadingStage stage;
  String badge;
  Color badgeColor;
  String? timestamp;
  bool canScan;

  DeliveryPallet get view => DeliveryPallet(
    code: code,
    itemName: itemName,
    meta: meta,
    progressCurrent: progressCurrent,
    progressTotal: progressTotal,
    stage: stage,
    badge: badge,
    badgeColor: badgeColor,
    timestamp: timestamp,
    canScan: canScan,
  );
}

class DeliveryFlowController {
  DeliveryFlowController({
    required this.job,
    required List<DeliveryFlowPallet> pallets,
  }) : pallets = pallets;

  final DeliveryJob job;
  final List<DeliveryFlowPallet> pallets;

  factory DeliveryFlowController.seeded(DeliveryJob job) {
    return DeliveryFlowController(
      job: job,
      pallets: [
        DeliveryFlowPallet(
          id: 101,
          code: '#PAL-7829',
          itemName: 'Industrial Disinfectant X1',
          meta: '500 KG · IBC Tank',
          progressCurrent: 1,
          progressTotal: 5,
          batchCode: '#B-2024-501',
          netWeight: '500 KG',
          containerType: 'IBC Tank',
          lane: 'LANE 04',
          rack: 'R-12',
          level: '03',
          bay: '04',
          badge: 'VERIFIED',
          badgeColor: _lightBlue,
        ),
        DeliveryFlowPallet(
          id: 102,
          code: '#PAL-7830',
          itemName: 'Corrosive Compound B-4',
          meta: '250 KG · Steel Drum',
          progressCurrent: 0,
          progressTotal: 2,
          batchCode: '#B-2024-502',
          netWeight: '250 KG',
          containerType: 'Steel Drum',
          lane: 'LANE 02',
          rack: 'A-1',
          level: '02',
          bay: '04',
        ),
        DeliveryFlowPallet(
          id: 103,
          code: '#PAL-7831',
          itemName: 'Base Solvent Alpha',
          meta: '800 KG · IBC Tank',
          progressCurrent: 3,
          progressTotal: 3,
          batchCode: '#B-2024-503',
          netWeight: '800 KG',
          containerType: 'IBC Tank',
          lane: 'LANE 03',
          rack: 'B-4',
          level: '01',
          bay: '04',
          badge: 'VERIFIED',
          badgeColor: _lightBlue,
        ),
        DeliveryFlowPallet(
          id: 104,
          code: '#PAL-7835',
          itemName: 'Organic Peroxide Type F',
          meta: '150 KG · Specialized Crating',
          progressCurrent: 0,
          progressTotal: 1,
          batchCode: '#B-2024-505',
          netWeight: '150 KG',
          containerType: 'Specialized Crating',
          lane: 'LANE 01',
          rack: 'C-2',
          level: '01',
          bay: '04',
        ),
        DeliveryFlowPallet(
          id: 105,
          code: '#PAL-7832',
          itemName: 'Heavy-Duty Degreaser G4',
          meta: '420 KG · Steel Drum',
          progressCurrent: 2,
          progressTotal: 5,
          batchCode: '#B-2024-504',
          netWeight: '420 KG',
          containerType: 'Steel Drum',
          lane: 'LANE 05',
          rack: 'D-3',
          level: '02',
          bay: '04',
          stage: _LoadingStage.loaded,
          badge: 'SCANNED',
          badgeColor: _veryLight,
          canScan: false,
        ),
        DeliveryFlowPallet(
          id: 106,
          code: '#PAL-7845',
          itemName: 'Ethanol Concentrate 99%',
          meta: '450 KG · IBC Tank',
          progressCurrent: 4,
          progressTotal: 5,
          batchCode: '#B-2024-506',
          netWeight: '450 KG',
          containerType: 'IBC Tank',
          lane: 'LANE 06',
          rack: 'E-1',
          level: '02',
          bay: '04',
          stage: _LoadingStage.loaded,
          badge: 'LOADED',
          badgeColor: _lightBlue,
          timestamp: '14:15 PM',
          canScan: false,
        ),
      ],
    );
  }

  factory DeliveryFlowController.fromApi({
    required DeliveryJob job,
    required List<DeliveryPalletSummaryResponse> pallets,
  }) {
    return DeliveryFlowController(
      job: job,
      pallets: pallets
          .map(
            (item) => DeliveryFlowPallet(
              id: item.id,
              code: item.code,
              itemName: item.name,
              meta: item.meta.replaceAll('|', '·'),
              progressCurrent: item.progressCurrent,
              progressTotal: item.progressTotal,
              batchCode: '',
              netWeight: '',
              containerType: '',
              lane: '',
              rack: '',
              level: '',
              bay: job.bay,
              stage: _stageFromApi(item.stage),
              badge: item.badge.toUpperCase(),
              badgeColor: _badgeColorFromApi(item.badge),
              timestamp: item.timestamp,
              canScan: item.canScan,
            ),
          )
          .toList(growable: true),
    );
  }

  List<DeliveryFlowPallet> itemsForStage(_LoadingStage stage) {
    return pallets.where((item) => item.stage == stage).toList(growable: false);
  }

  void moveToHoldingArea(DeliveryFlowPallet pallet) {
    pallet.stage = _LoadingStage.holdingArea;
    pallet.badge = 'VERIFIED';
    pallet.badgeColor = _lightBlue;
    pallet.canScan = true;
    pallet.timestamp = null;
  }

  void markScannedForLoaded(DeliveryFlowPallet pallet) {
    pallet.stage = _LoadingStage.loaded;
    pallet.badge = 'SCANNED';
    pallet.badgeColor = _veryLight;
    pallet.canScan = false;
    pallet.timestamp = null;
  }

  void confirmLoaded(DeliveryFlowPallet pallet) {
    pallet.stage = _LoadingStage.loaded;
    pallet.badge = 'LOADED';
    pallet.badgeColor = _lightBlue;
    pallet.canScan = false;
    pallet.timestamp = '14:22 PM';
  }
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
  final DeliveryApiService _api = DeliveryApiService();
  final TextEditingController _searchController = TextEditingController();
  late Future<DeliveryOverviewResponse> _overviewFuture;
  _DeliveryOverviewTab _selectedTab = _DeliveryOverviewTab.readyToLoad;
  String? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    _overviewFuture = _api.fetchOverview();
  }

  List<DeliveryOverviewJobSummary> _filteredItems(List<DeliveryOverviewJobSummary> jobs) {
    final query = _normalizeDeliverySearch(_searchController.text);
    return jobs.where((item) {
      if (_statusToTab(item.status) != _selectedTab) return false;
      if (_selectedCustomer != null && item.customer != _selectedCustomer) return false;
      if (query.isEmpty) return true;
      final searchable = _normalizeDeliverySearch([
        item.vehicleId,
        item.customer,
        item.status,
        _statusLabel(item.status),
        '${item.progressCurrent}',
        '${item.progressTotal}',
        'progress ${item.progressCurrent} ${item.progressTotal}',
      ].join(' '));

      final queryParts = query.split(' ').where((part) => part.isNotEmpty);
      return queryParts.every(searchable.contains);
    }).toList(growable: false);
  }

  Future<void> _refresh() async {
    final future = _api.fetchOverview();
    setState(() => _overviewFuture = future);
    await future;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterSheet(List<DeliveryOverviewJobSummary> jobs) {
    final customers = jobs
        .map((job) => job.customer)
        .where((customer) => customer.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

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
                  'Filter Jobs',
                  style: TextStyle(
                    color: _navy,
                    fontSize: _fs12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                _FilterOption(
                  label: 'All customers',
                  selected: _selectedCustomer == null,
                  onTap: () {
                    setState(() => _selectedCustomer = null);
                    Navigator.pop(context);
                  },
                ),
                ...customers.map(
                  (customer) => _FilterOption(
                    label: customer,
                    selected: _selectedCustomer == customer,
                    onTap: () {
                      setState(() => _selectedCustomer = customer);
                      Navigator.pop(context);
                    },
                  ),
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

  Future<String?> _openScanner() {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const _DeliveryScannerPage(),
      ),
    );
  }

  DeliveryJob _mapSummaryToJob(DeliveryOverviewJobSummary job) {
    final progress = job.progressTotal == 0 ? 0.0 : job.progressCurrent / job.progressTotal;

    return DeliveryJob(
      id: '${job.id}',
      vehicleId: job.vehicleId,
      bay: '04',
      customer: job.customer,
      doNumber: 'D-2024-${job.id.toString().padLeft(3, '0')}',
      totalPallets: '${job.progressTotal} Pallets',
      packingList: '${job.progressCurrent}',
      progressText: '${(progress * 100).round()}% (${job.progressCurrent}/${job.progressTotal} Pallets)',
      progress: progress.clamp(0.0, 1.0).toDouble(),
      clientName: job.customer,
      clientLocation: 'Shah Alam',
      productRows: _job.productRows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: FutureBuilder<DeliveryOverviewResponse>(
          future: _overviewFuture,
          builder: (context, snapshot) {
            return Column(
              children: [
                _TopBar(
                  title: 'Workwise',
                  brandMode: true,
                  onLeftTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                  onRightTap: () => _showSnack('Delivery settings opened'),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: _navy));
                      }

                      if (snapshot.hasError) {
                        return _DeliveryApiState(
                          title: 'Could not load delivery data',
                          message: '${snapshot.error}',
                          buttonText: 'Try Again',
                          onTap: _refresh,
                        );
                      }

                      final data = snapshot.data;
                      if (data == null) {
                        return _DeliveryApiState(
                          title: 'No delivery data found',
                          message: 'The server returned an empty response.',
                          buttonText: 'Refresh',
                          onTap: _refresh,
                        );
                      }

                      final items = _filteredItems(data.jobs);

                      return RefreshIndicator(
                        color: _navy,
                        onRefresh: _refresh,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DELIVERY',
                                style: TextStyle(
                                  color: _navy,
                                  fontSize: _fs18,
                                  fontWeight: FontWeight.w900,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Select a vehicle to begin dispatch.',
                                style: TextStyle(
                                  color: _muted,
                                  fontSize: _fs9,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SearchField(
                                      controller: _searchController,
                                      hintText: 'Search Vehicle, Customer, Packing List',
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  _FilterButton(
                                    active: _selectedCustomer != null,
                                    onTap: () => _openFilterSheet(data.jobs),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _DeliveryOverviewTabs(
                                selected: _selectedTab,
                                onSelected: (tab) => setState(() => _selectedTab = tab),
                              ),
                              const SizedBox(height: 10),
                              _DeliveryOverviewStatsGrid(stats: data.stats),
                              const SizedBox(height: 10),
                              if (items.isEmpty)
                                const _EmptyCard(message: 'No delivery jobs match this filter')
                              else
                                ...items.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _DeliveryOverviewJobCard(
                                      job: item,
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => DeliveryPalletLoadingPage(
                                            jobId: item.id,
                                            seedJob: _mapSummaryToJob(item),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DeliveryPalletLoadingPage extends StatefulWidget {
  const DeliveryPalletLoadingPage({
    super.key,
    required this.jobId,
    this.seedJob,
  });

  final int jobId;
  final DeliveryJob? seedJob;

  @override
  State<DeliveryPalletLoadingPage> createState() => _DeliveryPalletLoadingPageState();
}

class _DeliveryPalletLoadingPageState extends State<DeliveryPalletLoadingPage> {
  final DeliveryApiService _api = DeliveryApiService();
  DeliveryFlowController? _flow;
  late Future<void> _loadFuture;
  _LoadingStage _selectedStage = _LoadingStage.newItems;
  int _selectedIndex = 0;
  bool _showScannableOnly = false;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      _api.fetchJobDetail(widget.jobId),
      _api.fetchPallets(widget.jobId),
    ]);

    final jobDetail = results[0] as DeliveryJobDetailResponse;
    final pallets = results[1] as List<DeliveryPalletSummaryResponse>;

    final flow = DeliveryFlowController.fromApi(
      job: _mapJobDetailToJob(jobDetail),
      pallets: pallets,
    );

    if (!mounted) return;
    setState(() {
      _flow = flow;
      if (flow.itemsForStage(_selectedStage).isEmpty) {
        if (flow.itemsForStage(_LoadingStage.holdingArea).isNotEmpty) {
          _selectedStage = _LoadingStage.holdingArea;
        } else if (flow.itemsForStage(_LoadingStage.loaded).isNotEmpty) {
          _selectedStage = _LoadingStage.loaded;
        }
      }
      _selectedIndex = 0;
    });
  }

  DeliveryJob _mapJobDetailToJob(DeliveryJobDetailResponse job) {
    final progress = job.progressTotal == 0 ? 0.0 : job.progressCurrent / job.progressTotal;
    return DeliveryJob(
      id: '${job.id}',
      vehicleId: job.vehicleId,
      bay: job.bay,
      customer: job.customer,
      doNumber: job.doNumber,
      totalPallets: job.totalPallets,
      packingList: job.packingList,
      progressText: '${(progress * 100).round()}% (${job.progressCurrent}/${job.progressTotal} Pallets)',
      progress: progress.clamp(0.0, 1.0).toDouble(),
      clientName: job.customer,
      clientLocation: 'Shah Alam',
      productRows: widget.seedJob?.productRows ?? _job.productRows,
    );
  }

  List<DeliveryFlowPallet> get _filteredItems {
    final flow = _flow;
    if (flow == null) return const [];
    final stageItems = flow.itemsForStage(_selectedStage);
    if (!_showScannableOnly) return stageItems;
    return stageItems.where((item) => item.canScan).toList(growable: false);
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
    final items = _filteredItems;
    if (items.isEmpty || _selectedIndex >= items.length) return;
    final pallet = items[_selectedIndex];
    _api.confirmLoaded(_flow!.job.numericId).then((_) {
      setState(() => _flow!.confirmLoaded(pallet));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DeliveryPackingCompletePage(jobId: _flow!.job.numericId),
        ),
      );
    }).catchError((error) {
      _showSnack('Could not confirm loaded: $error');
    });
  }

  Future<String?> _openScanner() {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const _DeliveryScannerPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _loadFuture,
          builder: (context, snapshot) {
            final flow = _flow;
            final items = _filteredItems;
            return Column(
              children: [
                _TopBar(
                  title: 'TECHNICAL PANEL',
                  brandMode: false,
                  onLeftTap: () => Navigator.pop(context),
                  onRightTap: () => _showSnack('Technical panel settings opened'),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (snapshot.connectionState == ConnectionState.waiting && flow == null) {
                        return const Center(child: CircularProgressIndicator(color: _navy));
                      }
                      if (snapshot.hasError && flow == null) {
                        return _DeliveryApiState(
                          title: 'Could not load pallet data',
                          message: '${snapshot.error}',
                          buttonText: 'Try Again',
                          onTap: _loadData,
                        );
                      }
                      if (flow == null) {
                        return _DeliveryApiState(
                          title: 'No pallet data found',
                          message: 'The server returned an empty response.',
                          buttonText: 'Refresh',
                          onTap: _loadData,
                        );
                      }
                      return SingleChildScrollView(
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
                            _VehicleMeta(job: flow.job),
                            const SizedBox(height: 10),
                            _StatusBarCard(
                              progressText: flow.job.progressText,
                              progress: flow.job.progress,
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
                            pallet: item.view,
                            compact: true,
                            selected: selected,
                            showConfirmButton: selected,
                            onCardTap: () {
                              if (_selectedStage == _LoadingStage.loaded) {
                                setState(() => _selectedIndex = index);
                                return;
                              }

                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => DeliveryPalletDetailsPage(
                                    job: flow.job,
                                    pallet: item,
                                    flow: flow,
                                  ),
                                ),
                              ).then((_) => setState(() {}));
                            },
                            onScanTap: item.canScan
                                ? () {
                                    if (_selectedStage == _LoadingStage.holdingArea) {
                                      _openScanner().then((scanValue) {
                                        if (scanValue == null || scanValue.trim().isEmpty) return;
                                        _api.scanPallet(item.id).then((_) {
                                          setState(() {
                                            flow.markScannedForLoaded(item);
                                            _selectedStage = _LoadingStage.loaded;
                                            _selectedIndex = flow.itemsForStage(_LoadingStage.loaded).indexOf(item);
                                          });
                                          _showSnack('Scanned: $scanValue');
                                        }).catchError((error) {
                                          _showSnack('Could not scan pallet: $error');
                                        });
                                      });
                                      return;
                                    }
                                    _showSnack('Open pallet details to scan ${item.code}');
                                  }
                                : null,
                            onConfirmTap: _confirmLoaded,
                          ),
                        );
                      }),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class DeliveryPalletDetailsPage extends StatefulWidget {
  const DeliveryPalletDetailsPage({
    super.key,
    required this.job,
    required this.pallet,
    required this.flow,
  });

  final DeliveryJob job;
  final DeliveryFlowPallet pallet;
  final DeliveryFlowController flow;

  @override
  State<DeliveryPalletDetailsPage> createState() => _DeliveryPalletDetailsPageState();
}

class _DeliveryPalletDetailsPageState extends State<DeliveryPalletDetailsPage> {
  final DeliveryApiService _api = DeliveryApiService();
  late Future<DeliveryPalletDetailResponse> _detailFuture;

  @override
  void initState() {
    super.initState();
    _detailFuture = _api.fetchPalletDetail(widget.pallet.id);
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<String?> _openScanner() {
    return Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => const _DeliveryScannerPage(),
      ),
    );
  }

  void _scanPallet() {
    _openScanner().then((scanValue) {
      if (scanValue == null || scanValue.trim().isEmpty) return;
      _api.scanPallet(widget.pallet.id).then((_) {
        widget.flow.moveToHoldingArea(widget.pallet);
        _showSnack('Scanned: $scanValue');
        if (mounted) Navigator.of(context).pop();
      }).catchError((error) {
        _showSnack('Could not scan pallet: $error');
      });
    });
  }

  void _verifyInHoldingArea() {
    widget.flow.moveToHoldingArea(widget.pallet);
    _showSnack('${widget.pallet.code} verified in holding area');
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
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
                child: FutureBuilder<DeliveryPalletDetailResponse>(
                  future: _detailFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: _navy));
                    }
                    if (snapshot.hasError) {
                      return _DeliveryApiState(
                        title: 'Could not load pallet details',
                        message: '${snapshot.error}',
                        buttonText: 'Try Again',
                        onTap: () async {
                          setState(() => _detailFuture = _api.fetchPalletDetail(widget.pallet.id));
                        },
                      );
                    }
                    final detail = snapshot.data;
                    if (detail == null) {
                      return _DeliveryApiState(
                        title: 'No pallet details found',
                        message: 'The server returned an empty response.',
                        buttonText: 'Refresh',
                        onTap: () async {
                          setState(() => _detailFuture = _api.fetchPalletDetail(widget.pallet.id));
                        },
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PALLET DETAILS',
                          style: TextStyle(
                            color: _navy,
                            fontSize: _fs18,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _PalletLifecycleCard(
                          pallet: widget.pallet,
                          detail: detail,
                        ),
                        const SizedBox(height: 6),
                        _PalletStorageCard(detail: detail),
                        const SizedBox(height: 8),
                        _PrimaryActionBar(
                          primaryLabel: 'SCAN PALLET',
                          onPrimaryTap: _scanPallet,
                          secondaryLabel: widget.pallet.stage == _LoadingStage.newItems
                              ? 'VERIFY IN HOLDING AREA'
                              : null,
                          onSecondaryTap: widget.pallet.stage == _LoadingStage.newItems
                              ? _verifyInHoldingArea
                              : null,
                        ),
                        const SizedBox(height: 8),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DeliveryPackingCompletePage extends StatefulWidget {
  const DeliveryPackingCompletePage({super.key, required this.jobId});

  final int jobId;

  @override
  State<DeliveryPackingCompletePage> createState() => _DeliveryPackingCompletePageState();
}

class _DeliveryPackingCompletePageState extends State<DeliveryPackingCompletePage> {
  final DeliveryApiService _api = DeliveryApiService();
  late Future<DeliveryPackingSummaryResponse> _summaryFuture;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _summaryFuture = _api.fetchPackingSummary(widget.jobId);
  }

  void _showSnack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _submit() {
    _api.submitDelivery(widget.jobId).then((_) {
      setState(() => _submitted = true);
      _showSnack('Packing complete submitted');
    }).catchError((error) {
      _showSnack('Could not submit delivery: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
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
                child: FutureBuilder<DeliveryPackingSummaryResponse>(
                  future: _summaryFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: _navy));
                    }
                    if (snapshot.hasError) {
                      return _DeliveryApiState(
                        title: 'Could not load packing summary',
                        message: '${snapshot.error}',
                        buttonText: 'Try Again',
                        onTap: () async {
                          setState(() => _summaryFuture = _api.fetchPackingSummary(widget.jobId));
                        },
                      );
                    }
                    final summary = snapshot.data;
                    if (summary == null) {
                      return _DeliveryApiState(
                        title: 'No packing summary found',
                        message: 'The server returned an empty response.',
                        buttonText: 'Refresh',
                        onTap: () async {
                          setState(() => _summaryFuture = _api.fetchPackingSummary(widget.jobId));
                        },
                      );
                    }
                    final job = _mapPackingSummaryToJob(summary);
                    return Column(
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
                          grossWeight: summary.grossWeight,
                          onSubmit: _submit,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DeliveryJob _mapPackingSummaryToJob(DeliveryPackingSummaryResponse summary) {
    return DeliveryJob(
      id: '${widget.jobId}',
      vehicleId: 'BPL 1982',
      bay: '04',
      customer: summary.clientName,
      doNumber: 'D-2024-088',
      totalPallets: summary.totalPallets,
      packingList: summary.packingList,
      progressText: '75% (12/15 Pallets)',
      progress: .75,
      clientName: summary.clientName,
      clientLocation: summary.clientLocation,
      productRows: summary.items
          .map((item) => DeliveryProductRow(
                sku: item.sku,
                name: item.name,
                quantity: item.quantity,
                pallets: item.pallets,
              ))
          .toList(growable: false),
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
    this.hintText = 'Search pallet',
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
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
              decoration: InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                hintText: hintText,
                hintStyle: const TextStyle(
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

class _PalletLifecycleCard extends StatelessWidget {
  const _PalletLifecycleCard({
    required this.pallet,
    required this.detail,
  });

  final DeliveryFlowPallet pallet;
  final DeliveryPalletDetailResponse detail;

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                const Text(
                  'CURRENT LIFECYCLE STATUS',
                  style: TextStyle(color: _muted, fontSize: _fs6, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  color: _statusColor(_statusTextFromPallet(pallet)),
                  child: Text(
                    _statusBadgeText(pallet),
                    style: const TextStyle(color: Colors.white, fontSize: _fs7, fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              detail.name,
              style: const TextStyle(color: _navy, fontSize: _fs11, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'BATCH: ${detail.batch}',
              style: const TextStyle(color: _muted, fontSize: _fs7, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _PalletMiniMeta(
                    label: 'NET WEIGHT',
                    value: detail.netWeight,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _PalletMiniMeta(
                    label: 'CONTAINER TYPE',
                    value: detail.containerType,
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

class _PalletStorageCard extends StatelessWidget {
  const _PalletStorageCard({required this.detail});

  final DeliveryPalletDetailResponse detail;

  @override
  Widget build(BuildContext context) {
    Widget cell(String label, String value) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: _line),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: const TextStyle(color: _muted, fontSize: _fs6, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(color: _navy, fontSize: _fs11, fontWeight: FontWeight.w900),
              ),
            ],
          ),
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
            const Row(
              children: [
                Icon(Icons.place_outlined, size: 12, color: _navy),
                SizedBox(width: 4),
                Text(
                  'WAREHOUSE STORAGE COORDINATES',
                  style: TextStyle(color: _muted, fontSize: _fs6, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                cell('ZONE', detail.zone),
                cell('RACK', detail.rack),
              ],
            ),
            Row(
              children: [
                cell('LEVEL', detail.level),
                cell('BAY', detail.bay),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PalletMiniMeta extends StatelessWidget {
  const _PalletMiniMeta({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: _muted, fontSize: _fs6, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: _navy, fontSize: _fs11, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }
}

class _PrimaryActionBar extends StatelessWidget {
  const _PrimaryActionBar({
    required this.primaryLabel,
    required this.onPrimaryTap,
    this.secondaryLabel,
    this.onSecondaryTap,
  });

  final String primaryLabel;
  final VoidCallback onPrimaryTap;
  final String? secondaryLabel;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onPrimaryTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: _navy,
            child: Center(
              child: Text(
                primaryLabel,
                style: const TextStyle(color: Colors.white, fontSize: _fs9, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
        if (secondaryLabel != null) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: onSecondaryTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _line),
              ),
              child: Center(
                child: Text(
                  secondaryLabel!,
                  style: const TextStyle(color: _muted, fontSize: _fs8, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ),
        ],
      ],
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
    required this.grossWeight,
    this.onSubmit,
  });

  final bool submitted;
  final String grossWeight;
  final VoidCallback? onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _navy,
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'GROSS WEIGHT',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: _fs8,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Spacer(),
              Text(
                grossWeight,
                style: const TextStyle(
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

class _DeliveryScannerPage extends StatefulWidget {
  const _DeliveryScannerPage();

  @override
  State<_DeliveryScannerPage> createState() => _DeliveryScannerPageState();
}

class _DeliveryScannerPageState extends State<_DeliveryScannerPage> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        title: const Text(
          'Scan Pallet',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_handled) return;
              final barcode =
                  capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
              final rawValue = barcode?.rawValue;
              if (rawValue == null || rawValue.trim().isEmpty) return;
              _handled = true;
              Navigator.of(context).pop(rawValue);
            },
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'Point camera at the pallet QR code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
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

class _DeliveryOverviewTabs extends StatelessWidget {
  const _DeliveryOverviewTabs({
    required this.selected,
    required this.onSelected,
  });

  final _DeliveryOverviewTab selected;
  final ValueChanged<_DeliveryOverviewTab> onSelected;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, _DeliveryOverviewTab value) {
      final isSelected = selected == value;
      return Expanded(
        child: InkWell(
          onTap: () => onSelected(value),
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
      );
    }

    return Row(
      children: [
        tab('NEW', _DeliveryOverviewTab.readyToLoad),
        tab('IN PROGRESS', _DeliveryOverviewTab.inProgress),
        tab('COMPLETED', _DeliveryOverviewTab.completed),
      ],
    );
  }
}

class _DeliveryOverviewStatsGrid extends StatelessWidget {
  const _DeliveryOverviewStatsGrid({required this.stats});

  final DeliveryOverviewStats stats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _DeliveryStatCard(
                label: 'VEHICLE IN BAY',
                value: '${stats.vehicleInBay}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DeliveryStatCard(
                label: 'VEHICLE IN PROGRESS',
                value: '${stats.vehicleInProgress}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _DeliveryStatCard(
                label: 'VEHICLE COMPLETED',
                value: '${stats.vehicleCompleted}',
                valueColor: const Color(0xFFD64747),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DeliveryStatCard(
                label: 'PALLETS IN HOLDING',
                value: '${stats.palletsInHolding}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DeliveryStatCard extends StatelessWidget {
  const _DeliveryStatCard({
    required this.label,
    required this.value,
    this.valueColor = _navy,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 7),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: _fs7,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: _fs13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryOverviewJobCard extends StatelessWidget {
  const _DeliveryOverviewJobCard({
    required this.job,
    required this.onTap,
  });

  final DeliveryOverviewJobSummary job;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusText = _statusLabel(job.status);
    final statusColor = _statusColor(job.status);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _line),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          job.vehicleId,
                          style: const TextStyle(
                            color: _navy,
                            fontSize: _fs11,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        color: statusColor,
                        child: Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: _fs7,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    job.customer,
                    style: const TextStyle(
                      color: _text,
                      fontSize: _fs11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Progress ${job.progressCurrent}/${job.progressTotal} Pallets',
                    style: const TextStyle(
                      color: _navy,
                      fontSize: _fs9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: _muted, size: 18),
          ],
        ),
      ),
    );
  }
}

class _DeliveryApiState extends StatelessWidget {
  const _DeliveryApiState({
    required this.title,
    required this.message,
    required this.buttonText,
    required this.onTap,
  });

  final String title;
  final String message;
  final String buttonText;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _navy,
                fontSize: _fs13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _muted,
                fontSize: _fs10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => onTap(),
              style: ElevatedButton.styleFrom(
                backgroundColor: _navy,
                foregroundColor: Colors.white,
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

_DeliveryOverviewTab _statusToTab(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
    case 'done':
    case 'verified':
      return _DeliveryOverviewTab.completed;
    case 'in_progress':
    case 'in progress':
    case 'loading':
    case 'loaded':
    case 'holding':
      return _DeliveryOverviewTab.inProgress;
    default:
      return _DeliveryOverviewTab.readyToLoad;
  }
}

String _statusLabel(String status) {
  switch (_statusToTab(status)) {
    case _DeliveryOverviewTab.completed:
      return 'COMPLETED';
    case _DeliveryOverviewTab.inProgress:
      return 'IN PROGRESS';
    case _DeliveryOverviewTab.readyToLoad:
      return 'READY TO LOAD';
  }
}

Color _statusColor(String status) {
  switch (_statusToTab(status)) {
    case _DeliveryOverviewTab.completed:
      return _green;
    case _DeliveryOverviewTab.inProgress:
      return const Color(0xFF65748B);
    case _DeliveryOverviewTab.readyToLoad:
      return _navy;
  }
}

_LoadingStage _stageFromApi(String stage) {
  switch (stage.toLowerCase()) {
    case 'holding_area':
    case 'holding area':
      return _LoadingStage.holdingArea;
    case 'loaded':
      return _LoadingStage.loaded;
    default:
      return _LoadingStage.newItems;
  }
}

Color _badgeColorFromApi(String badge) {
  switch (badge.toLowerCase()) {
    case 'verified':
    case 'loaded':
      return _lightBlue;
    default:
      return _veryLight;
  }
}

String _statusTextFromPallet(DeliveryFlowPallet pallet) {
  switch (pallet.stage) {
    case _LoadingStage.newItems:
      return 'new';
    case _LoadingStage.holdingArea:
      return 'in_progress';
    case _LoadingStage.loaded:
      return pallet.badge.toLowerCase() == 'loaded' ? 'completed' : 'in_progress';
  }
}

String _statusBadgeText(DeliveryFlowPallet pallet) {
  if (pallet.stage == _LoadingStage.newItems) return 'NEW';
  if (pallet.stage == _LoadingStage.holdingArea) return 'VERIFIED';
  if (pallet.badge.isNotEmpty) return pallet.badge;
  return 'SCANNED';
}

String _normalizeDeliverySearch(String input) {
  final lower = input.toLowerCase().trim();
  return lower
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}


