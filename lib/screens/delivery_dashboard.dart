import 'package:flutter/material.dart';
import '../delivery/theme.dart';
import '../delivery/widgets/bottom_nav.dart';
import '../delivery/navigation.dart';
import '../delivery/models/delivery_models.dart';
import '../services/delivery_api_service.dart';
import 'pallet_loading.dart';
import 'delivery_summary.dart';

class DeliveryDashboardScreen extends StatefulWidget {
  const DeliveryDashboardScreen({super.key});

  @override
  State<DeliveryDashboardScreen> createState() => _DeliveryDashboardScreenState();
}

class _DeliveryDashboardScreenState extends State<DeliveryDashboardScreen> {
  final _api = DeliveryApiService();
  List<DeliveryVehicle> _vehicles = const [];
  DeliveryOverviewStats? _stats;
  bool _loading = true;
  Object? _error;
  VehicleCategory _tab = VehicleCategory.new_;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_refreshSearch);
    _loadOverview();
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_refreshSearch)
      ..dispose();
    super.dispose();
  }

  void _refreshSearch() => setState(() {});

  Future<void> _loadOverview() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await _api.fetchOverview();
      if (!mounted) return;
      setState(() {
        _stats = response.stats;
        _vehicles = response.jobs.map(_vehicleFromSummary).toList(growable: false);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  DeliveryVehicle _vehicleFromSummary(DeliveryOverviewJobSummary job) {
    final normalized = job.status.toLowerCase().replaceAll('-', '_');
    final category = normalized == 'completed'
        ? VehicleCategory.completed
        : normalized == 'in_progress' || normalized == 'loading'
            ? VehicleCategory.inProgress
            : VehicleCategory.new_;
    final badge = normalized == 'in_progress'
        ? 'IN PROGRESS'
        : normalized == 'loading'
            ? 'LOADING'
            : normalized == 'completed'
                ? 'COMPLETED'
                : 'READY TO LOAD';
    return DeliveryVehicle(
      jobId: job.id,
      id: job.vehicleId,
      customer: job.customer,
      badge: badge,
      palletsDone: job.progressCurrent,
      palletsTotal: job.progressTotal,
      category: category,
      pallets: const [],
    );
  }

  PalletItem _palletFromResponse(DeliveryPalletSummaryResponse pallet) {
    final normalized = pallet.stage.toLowerCase().replaceAll('-', '_');
    final status = normalized == 'loaded'
        ? PalletStatus.loaded
        : normalized == 'holding' || normalized == 'holding_area' || normalized == 'scanned'
            ? PalletStatus.holding
            : PalletStatus.new_;
    final weightMatch = RegExp(r'([0-9]+(?:\.[0-9]+)?)\s*([A-Za-z]+)').firstMatch(pallet.meta);
    final containerParts = pallet.meta.split(RegExp(r'\s*[·|-]\s*'));
    return PalletItem(
      apiId: pallet.id,
      id: pallet.code,
      name: pallet.name,
      batch: pallet.code,
      weight: double.tryParse(weightMatch?.group(1) ?? '') ?? 0,
      weightUnit: weightMatch?.group(2) ?? '',
      container: containerParts.length > 1 ? containerParts.last : pallet.meta,
      palletsRequired: pallet.progressTotal == 0 ? 1 : pallet.progressTotal,
      palletsScanned: pallet.progressCurrent,
      status: status,
      scanTime: pallet.timestamp,
    );
  }

  List<DeliveryVehicle> get _filtered {
    final query = _searchController.text.trim().toLowerCase();
    return _vehicles.where((vehicle) {
      final matchesTab = vehicle.category == _tab;
      final matchesQuery = query.isEmpty ||
          vehicle.id.toLowerCase().contains(query) ||
          vehicle.customer.toLowerCase().contains(query) ||
          vehicle.badge.toLowerCase().contains(query);
      return matchesTab && matchesQuery;
    }).toList(growable: false);
  }

  Future<void> _openVehicle(DeliveryVehicle vehicle) async {
    try {
      final results = await Future.wait([
        _api.fetchJobDetail(vehicle.jobId),
        _api.fetchPallets(vehicle.jobId),
      ]);
      if (!mounted) return;
      final detail = results[0] as DeliveryJobDetailResponse;
      final pallets = results[1] as List<DeliveryPalletSummaryResponse>;
      final loadedVehicle = DeliveryVehicle(
        jobId: vehicle.jobId,
        id: detail.vehicleId,
        customer: detail.customer,
        badge: vehicle.badge,
        palletsDone: detail.progressCurrent,
        palletsTotal: detail.progressTotal,
        category: vehicle.category,
        pallets: pallets.map(_palletFromResponse).toList(),
        bay: detail.bay,
        doNumber: detail.doNumber,
        packingList: detail.packingList,
      );
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DeliveryTheme(
            child: PalletLoadingScreen(vehicle: loadedVehicle),
          ),
        ),
      );
      if (mounted) _loadOverview();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open delivery: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text('Workwise'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('DELIVERY', style: AppTextStyles.screenTitle),
            const SizedBox(height: 4),
            const Text('Select a vehicle to begin dispatch.',
                style: AppTextStyles.subtitle),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Vehicle, Customer, Packing List',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.grey),
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.grey),
                filled: true,
                fillColor: AppColors.cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _TabChip(
                    label: 'NEW',
                    selected: _tab == VehicleCategory.new_,
                    onTap: () => setState(() => _tab = VehicleCategory.new_),
                  ),
                ),
                Expanded(
                  child: _TabChip(
                    label: 'IN PROGRESS',
                    selected: _tab == VehicleCategory.inProgress,
                    onTap: () => setState(() => _tab = VehicleCategory.inProgress),
                  ),
                ),
                Expanded(
                  child: _TabChip(
                    label: 'COMPLETED',
                    selected: _tab == VehicleCategory.completed,
                    onTap: () => setState(() => _tab = VehicleCategory.completed),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.6,
              children: [
                _StatTile(label: 'VEHICLE IN BAY', value: '${_stats?.vehicleInBay ?? 0}'),
                _StatTile(label: 'VEHICLE IN PROGRESS', value: '${_stats?.vehicleInProgress ?? 0}'),
                _StatTile(label: 'VEHICLE COMPLETED', value: '${_stats?.vehicleCompleted ?? 0}'),
                _StatTile(label: 'PALLETS IN HOLDING', value: '${_stats?.palletsInHolding ?? 0}'),
              ],
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Column(
                  children: [
                    Text('$_error', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: _loadOverview, child: const Text('TRY AGAIN')),
                  ],
                ),
              )
            else if (_filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text('No ${_tab.name} deliveries',
                      style: const TextStyle(color: AppColors.grey)),
                ),
              )
            else
              for (final vehicle in _filtered) ...[
                _VehicleCard(
                  vehicle: vehicle,
                  onTap: () => _openVehicle(vehicle),
                ),
                const SizedBox(height: 12),
              ],
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

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: selected ? AppColors.textDark : AppColors.grey,
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
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

class _VehicleCard extends StatelessWidget {
  final DeliveryVehicle vehicle;
  final VoidCallback onTap;
  const _VehicleCard({required this.vehicle, required this.onTap});

  Color get _badgeColor {
    switch (vehicle.badge) {
      case 'READY TO LOAD':
        return AppColors.green;
      case 'IN PROGRESS':
        return AppColors.blueAccent;
      case 'LOADING':
        return const Color(0xFFB07A16);
      default:
        return AppColors.grey;
    }
  }

  Color get _badgeBg {
    switch (vehicle.badge) {
      case 'READY TO LOAD':
        return AppColors.greenBg;
      case 'IN PROGRESS':
        return const Color(0xFFE8EFFD);
      case 'LOADING':
        return const Color(0xFFFBF1DD);
      default:
        return AppColors.lightGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(vehicle.id,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(vehicle.badge,
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: _badgeColor)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(vehicle.customer,
                style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Progress',
                    style: TextStyle(fontSize: 10, color: AppColors.grey)),
                Text('${vehicle.palletsDone} / ${vehicle.palletsTotal} Pallets',
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.grey)),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: vehicle.progress,
                minHeight: 6,
                backgroundColor: AppColors.lightGrey,
                valueColor: const AlwaysStoppedAnimation(AppColors.navy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
