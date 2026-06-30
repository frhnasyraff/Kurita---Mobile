import 'package:flutter/material.dart';

import 'package:workwise/app_router.dart';
import '../widgets/bottom_nav_bar.dart';

class SamplingBatch {
  const SamplingBatch({
    required this.id,
    required this.material,
    required this.date,
    required this.quantity,
    required this.status,
    required this.appearance,
    required this.density,
    required this.purity,
    required this.moisture,
    required this.testedBy,
    required this.testedDate,
    required this.testedDuration,
  });

  final String id;
  final String material;
  final String date;
  final String quantity;
  final String status;
  final String appearance;
  final String density;
  final String purity;
  final String moisture;
  final String testedBy;
  final String testedDate;
  final String testedDuration;

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';

  DateTime get parsedDate {
    final parts = date.replaceAll(',', '').split(' ');
    if (parts.length < 3) return DateTime(2000);
    const months = <String, int>{
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    return DateTime(
      int.tryParse(parts[2]) ?? 2000,
      months[parts[0]] ?? 1,
      int.tryParse(parts[1]) ?? 1,
    );
  }

  double get parsedQuantity {
    final numeric = quantity.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(numeric) ?? 0;
  }
}

const _primary = Color(0xFF0B2D63);
const _border = Color(0xFFCAD1DD);
const _textDark = Color(0xFF101828);
const _textMuted = Color(0xFF475467);
const _statusPendingBg = Color(0xFFD9E8F8);
const _statusPendingText = Color(0xFF5F6F7F);
const _statusDoneBg = Color(0xFF0E5A1F);
const _statusDoneText = Color(0xFF56D364);
const _lineBorder = Color(0xFFA8B0BD);

// Shared bottom navigation definition used across the sampling pages.
// `selectedIndex` mirrors the previous `AppBottomNav(currentIndex: ...)` usage.
List<(IconData icon, String label, bool selected)> _navItems(int selectedIndex) {
  const labels = <(IconData, String)>[
    (Icons.home_outlined, 'Home'),
    (Icons.assignment_outlined, 'Tasks'),
    (Icons.bar_chart_outlined, 'Reports'),
    (Icons.people_outline, 'Team'),
    (Icons.science_outlined, 'Sampling'),
  ];
  return List.generate(labels.length, (index) {
    final (icon, label) = labels[index];
    return (icon, label, index == selectedIndex);
  });
}

void _onNavItemTapped(BuildContext context, int index) {
  // Hook up real navigation routes here as needed.
}

const List<SamplingBatch> _preSamplingNew = [
  SamplingBatch(
    id: '#B-2024-501',
    material: 'Sodium Hypochlorite',
    date: 'May 28, 2024',
    quantity: '2500 KG',
    status: 'PENDING',
    appearance: 'Clear, light yellow liquid',
    density: '1.205',
    purity: '12.5',
    moisture: '0.00',
    testedBy: 'Engr. David Miller',
    testedDate: 'JUN 21, 2026',
    testedDuration: '00:23:57',
  ),
  SamplingBatch(
    id: '#B-2024-502',
    material: 'Hydrochloric Acid (33%)',
    date: 'May 28, 2024',
    quantity: '1200 L',
    status: 'PENDING',
    appearance: 'Colorless liquid',
    density: '1.160',
    purity: '33.0',
    moisture: '0.00',
    testedBy: 'Engr. David Miller',
    testedDate: 'JUN 21, 2026',
    testedDuration: '00:17:21',
  ),
  SamplingBatch(
    id: '#B-2024-505',
    material: 'Caustic Soda Lye',
    date: 'May 27, 2024',
    quantity: '5000 KG',
    status: 'PENDING',
    appearance: 'Clear viscous liquid',
    density: '1.320',
    purity: '49.8',
    moisture: '0.12',
    testedBy: 'Engr. David Miller',
    testedDate: 'JUN 21, 2026',
    testedDuration: '00:28:11',
  ),
  SamplingBatch(
    id: '#B-2024-508',
    material: 'Poly Aluminum Chloride',
    date: 'May 27, 2024',
    quantity: '800 KG',
    status: 'PENDING',
    appearance: 'Yellow powder',
    density: '0.820',
    purity: '29.7',
    moisture: '0.15',
    testedBy: 'Engr. David Miller',
    testedDate: 'JUN 21, 2026',
    testedDuration: '00:14:26',
  ),
  SamplingBatch(
    id: '#B-2024-510',
    material: 'Ferric Chloride Solution',
    date: 'May 26, 2024',
    quantity: '3100 KG',
    status: 'PENDING',
    appearance: 'Dark brown liquid',
    density: '1.410',
    purity: '40.0',
    moisture: '0.05',
    testedBy: 'Engr. David Miller',
    testedDate: 'JUN 21, 2026',
    testedDuration: '00:19:12',
  ),
];

const List<SamplingBatch> _preSamplingCompleted = [
  SamplingBatch(
    id: '#B-2024-495',
    material: 'SULFURIC ACID',
    date: 'May 20, 2024',
    quantity: '1500 KG',
    status: 'COMPLETED',
    appearance: 'Clear, colorless liquid',
    density: '1.830',
    purity: '98.0',
    moisture: '0.00',
    testedBy: 'Engr. David Miller',
    testedDate: 'JUN 19, 2026',
    testedDuration: '00:16:09',
  ),
  SamplingBatch(
    id: '#B-2024-492',
    material: 'CAUSTIC SODA',
    date: 'May 19, 2024',
    quantity: '2200 KG',
    status: 'COMPLETED',
    appearance: 'White flakes',
    density: '1.280',
    purity: '99.1',
    moisture: '0.07',
    testedBy: 'Engr. David Miller',
    testedDate: 'JUN 19, 2026',
    testedDuration: '00:12:33',
  ),
  SamplingBatch(
    id: '#B-2024-488',
    material: 'MAGNESIUM OXIDE',
    date: 'May 18, 2024',
    quantity: '850 KG',
    status: 'COMPLETED',
    appearance: 'Fine white powder',
    density: '0.960',
    purity: '95.0',
    moisture: '0.10',
    testedBy: 'Engr. David Miller',
    testedDate: 'JUN 18, 2026',
    testedDuration: '00:10:48',
  ),
  SamplingBatch(
    id: '#B-2024-485',
    material: 'POTASSIUM CHLORIDE',
    date: 'May 17, 2024',
    quantity: '3000 KG',
    status: 'COMPLETED',
    appearance: 'White crystalline solid',
    density: '1.990',
    purity: '99.0',
    moisture: '0.02',
    testedBy: 'Engr. David Miller',
    testedDate: 'JUN 18, 2026',
    testedDuration: '00:18:15',
  ),
  SamplingBatch(
    id: '#B-2024-480',
    material: 'SODIUM CARBONATE',
    date: 'May 16, 2024',
    quantity: '1200 KG',
    status: 'COMPLETED',
    appearance: 'White granular powder',
    density: '1.460',
    purity: '98.7',
    moisture: '0.03',
    testedBy: 'Engr. David Miller',
    testedDate: 'JUN 18, 2026',
    testedDuration: '00:09:54',
  ),
];

const List<SamplingBatch> _samplingNew = [
  SamplingBatch(
    id: '#S-2024-611',
    material: 'Aluminum Sulfate',
    date: 'Jun 02, 2024',
    quantity: '1800 KG',
    status: 'PENDING',
    appearance: 'Off-white granules',
    density: '1.620',
    purity: '17.3',
    moisture: '0.10',
    testedBy: 'Engr. Sarah Lim',
    testedDate: 'JUN 22, 2026',
    testedDuration: '00:21:05',
  ),
  SamplingBatch(
    id: '#S-2024-614',
    material: 'Citric Acid Monohydrate',
    date: 'Jun 02, 2024',
    quantity: '950 KG',
    status: 'PENDING',
    appearance: 'White crystals',
    density: '1.540',
    purity: '99.5',
    moisture: '0.02',
    testedBy: 'Engr. Sarah Lim',
    testedDate: 'JUN 22, 2026',
    testedDuration: '00:11:32',
  ),
  SamplingBatch(
    id: '#S-2024-617',
    material: 'Sodium Bisulfite',
    date: 'Jun 01, 2024',
    quantity: '1400 KG',
    status: 'PENDING',
    appearance: 'Yellowish liquid',
    density: '1.320',
    purity: '38.2',
    moisture: '0.08',
    testedBy: 'Engr. Sarah Lim',
    testedDate: 'JUN 22, 2026',
    testedDuration: '00:14:49',
  ),
  SamplingBatch(
    id: '#S-2024-620',
    material: 'Hydrogen Peroxide',
    date: 'Jun 01, 2024',
    quantity: '700 L',
    status: 'PENDING',
    appearance: 'Clear liquid',
    density: '1.110',
    purity: '35.0',
    moisture: '0.00',
    testedBy: 'Engr. Sarah Lim',
    testedDate: 'JUN 22, 2026',
    testedDuration: '00:08:27',
  ),
  SamplingBatch(
    id: '#S-2024-624',
    material: 'Sodium Metabisulfite',
    date: 'May 31, 2024',
    quantity: '1100 KG',
    status: 'PENDING',
    appearance: 'White powder',
    density: '1.480',
    purity: '96.8',
    moisture: '0.06',
    testedBy: 'Engr. Sarah Lim',
    testedDate: 'JUN 22, 2026',
    testedDuration: '00:13:18',
  ),
];

const List<SamplingBatch> _samplingCompleted = [
  SamplingBatch(
    id: '#S-2024-602',
    material: 'SODIUM THIOSULFATE',
    date: 'May 30, 2024',
    quantity: '1600 KG',
    status: 'COMPLETED',
    appearance: 'Clear solution',
    density: '1.340',
    purity: '99.0',
    moisture: '0.01',
    testedBy: 'Engr. Sarah Lim',
    testedDate: 'JUN 20, 2026',
    testedDuration: '00:15:44',
  ),
  SamplingBatch(
    id: '#S-2024-599',
    material: 'FERROUS SULFATE',
    date: 'May 29, 2024',
    quantity: '2500 KG',
    status: 'COMPLETED',
    appearance: 'Greenish crystals',
    density: '1.890',
    purity: '91.0',
    moisture: '0.04',
    testedBy: 'Engr. Sarah Lim',
    testedDate: 'JUN 20, 2026',
    testedDuration: '00:19:06',
  ),
  SamplingBatch(
    id: '#S-2024-594',
    material: 'SODIUM NITRITE',
    date: 'May 28, 2024',
    quantity: '900 KG',
    status: 'COMPLETED',
    appearance: 'White powder',
    density: '2.170',
    purity: '98.8',
    moisture: '0.03',
    testedBy: 'Engr. Sarah Lim',
    testedDate: 'JUN 20, 2026',
    testedDuration: '00:09:31',
  ),
  SamplingBatch(
    id: '#S-2024-589',
    material: 'PHOSPHORIC ACID',
    date: 'May 27, 2024',
    quantity: '2100 L',
    status: 'COMPLETED',
    appearance: 'Clear syrupy liquid',
    density: '1.690',
    purity: '85.0',
    moisture: '0.00',
    testedBy: 'Engr. Sarah Lim',
    testedDate: 'JUN 20, 2026',
    testedDuration: '00:17:02',
  ),
  SamplingBatch(
    id: '#S-2024-584',
    material: 'AMMONIUM CHLORIDE',
    date: 'May 26, 2024',
    quantity: '1300 KG',
    status: 'COMPLETED',
    appearance: 'White fine powder',
    density: '1.530',
    purity: '99.2',
    moisture: '0.05',
    testedBy: 'Engr. Sarah Lim',
    testedDate: 'JUN 20, 2026',
    testedDuration: '00:11:14',
  ),
];

class PreSamplingNewPage extends StatelessWidget {
  const PreSamplingNewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SamplingBatchListPage(
      title: 'PRE-SAMPLING',
      subtitle: 'Select a batch to record sampling results.',
      activeTab: _BatchTab.newBatch,
      batches: _preSamplingNew,
      newRoute: Routes.preSamplingNew,
      completedRoute: Routes.preSamplingCompleted,
      resultsRoute: Routes.preSamplingResults,
      stackedFilters: false,
      leadingIcon: null,
    );
  }
}

class PreSamplingCompletedPage extends StatelessWidget {
  const PreSamplingCompletedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SamplingBatchListPage(
      title: 'PRE-SAMPLING',
      subtitle: 'Select a batch to view sampling results.',
      activeTab: _BatchTab.completed,
      batches: _preSamplingCompleted,
      newRoute: Routes.preSamplingNew,
      completedRoute: Routes.preSamplingCompleted,
      resultsRoute: Routes.preSamplingResults,
      stackedFilters: true,
      leadingIcon: Icons.person_outline_rounded,
    );
  }
}

class PreSamplingResultsPage extends StatelessWidget {
  const PreSamplingResultsPage({super.key, required this.batch});

  final SamplingBatch batch;

  @override
  Widget build(BuildContext context) {
    return _SamplingResultsPage(
      title: 'RESULTS',
      batch: batch,
      leadingIcon: Icons.science_outlined,
    );
  }
}

class SamplingNewPage extends StatelessWidget {
  const SamplingNewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SamplingBatchListPage(
      title: 'SAMPLING',
      subtitle: 'Select a batch to record sampling results.',
      activeTab: _BatchTab.newBatch,
      batches: _samplingNew,
      newRoute: Routes.samplingNew,
      completedRoute: Routes.samplingCompleted,
      resultsRoute: Routes.samplingResults,
      stackedFilters: false,
      leadingIcon: null,
    );
  }
}

class SamplingCompletedPage extends StatelessWidget {
  const SamplingCompletedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return _SamplingBatchListPage(
      title: 'SAMPLING',
      subtitle: 'Select a batch to view sampling results.',
      activeTab: _BatchTab.completed,
      batches: _samplingCompleted,
      newRoute: Routes.samplingNew,
      completedRoute: Routes.samplingCompleted,
      resultsRoute: Routes.samplingResults,
      stackedFilters: true,
      leadingIcon: Icons.person_outline_rounded,
    );
  }
}

class SamplingResultsPage extends StatelessWidget {
  const SamplingResultsPage({super.key, required this.batch});

  final SamplingBatch batch;

  @override
  Widget build(BuildContext context) {
    return _SamplingResultsPage(
      title: 'RESULTS',
      batch: batch,
      leadingIcon: Icons.science_outlined,
    );
  }
}

enum _BatchTab { newBatch, completed }

enum _BatchFilter { all, latest, oldest, quantityHigh, quantityLow }

class _SamplingBatchListPage extends StatefulWidget {
  const _SamplingBatchListPage({
    required this.title,
    required this.subtitle,
    required this.activeTab,
    required this.batches,
    required this.newRoute,
    required this.completedRoute,
    required this.resultsRoute,
    required this.stackedFilters,
    required this.leadingIcon,
  });

  final String title;
  final String subtitle;
  final _BatchTab activeTab;
  final List<SamplingBatch> batches;
  final String newRoute;
  final String completedRoute;
  final String resultsRoute;
  final bool stackedFilters;
  final IconData? leadingIcon;

  @override
  State<_SamplingBatchListPage> createState() => _SamplingBatchListPageState();
}

class _SamplingBatchListPageState extends State<_SamplingBatchListPage> {
  late final TextEditingController _searchController;
  DateTime? _selectedDate;
  _BatchFilter _filter = _BatchFilter.all;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<SamplingBatch> get _visibleBatches {
    final query = _searchController.text.trim().toLowerCase();
    var items = widget.batches.where((batch) {
      final matchesQuery =
          query.isEmpty ||
          batch.id.toLowerCase().contains(query) ||
          batch.material.toLowerCase().contains(query) ||
          batch.quantity.toLowerCase().contains(query);
      final matchesDate =
          _selectedDate == null ||
          (batch.parsedDate.year == _selectedDate!.year &&
              batch.parsedDate.month == _selectedDate!.month &&
              batch.parsedDate.day == _selectedDate!.day);
      return matchesQuery && matchesDate;
    }).toList();

    switch (_filter) {
      case _BatchFilter.all:
        break;
      case _BatchFilter.latest:
        items.sort((a, b) => b.parsedDate.compareTo(a.parsedDate));
        break;
      case _BatchFilter.oldest:
        items.sort((a, b) => a.parsedDate.compareTo(b.parsedDate));
        break;
      case _BatchFilter.quantityHigh:
        items.sort((a, b) => b.parsedQuantity.compareTo(a.parsedQuantity));
        break;
      case _BatchFilter.quantityLow:
        items.sort((a, b) => a.parsedQuantity.compareTo(b.parsedQuantity));
        break;
    }
    return items;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? widget.batches.first.parsedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2027, 12, 31),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showFilterMenu() async {
    final selected = await showModalBottomSheet<_BatchFilter>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter batches',
                style: TextStyle(
                  color: _primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              ..._BatchFilter.values.map(
                (filter) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(_filterLabel(filter)),
                  trailing: _filter == filter
                      ? const Icon(Icons.check_rounded, color: _primary)
                      : null,
                  onTap: () => Navigator.pop(context, filter),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Clear date filter'),
                trailing: _selectedDate == null
                    ? null
                    : const Icon(Icons.event_busy_outlined, color: _primary),
                onTap: () {
                  setState(() => _selectedDate = null);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null) {
      setState(() => _filter = selected);
    }
  }

  String get _dateLabel {
    if (_selectedDate == null) return 'Select Date';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[_selectedDate!.month - 1]} ${_selectedDate!.day}, ${_selectedDate!.year}';
  }

  String _filterLabel(_BatchFilter filter) {
    switch (filter) {
      case _BatchFilter.all:
        return 'Default order';
      case _BatchFilter.latest:
        return 'Latest date first';
      case _BatchFilter.oldest:
        return 'Oldest date first';
      case _BatchFilter.quantityHigh:
        return 'Highest quantity';
      case _BatchFilter.quantityLow:
        return 'Lowest quantity';
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleBatches = _visibleBatches;
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(
        items: _navItems(4),
        onItemTapped: (index) => _onNavItemTapped(context, index),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _PageHeader(leadingIcon: widget.leadingIcon),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: _primary,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.subtitle,
                            style: const TextStyle(
                              color: _textDark,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: _border),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _TopTab(
                              label: 'NEW',
                              selected: widget.activeTab == _BatchTab.newBatch,
                              onTap: () {
                                if (widget.activeTab != _BatchTab.newBatch) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    widget.newRoute,
                                  );
                                }
                              },
                            ),
                          ),
                          Expanded(
                            child: _TopTab(
                              label: 'COMPLETED',
                              selected: widget.activeTab == _BatchTab.completed,
                              onTap: () {
                                if (widget.activeTab != _BatchTab.completed) {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    widget.completedRoute,
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 24, 18),
                      child: widget.stackedFilters
                          ? Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _SearchControlBox(
                                        controller: _searchController,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    _SquareControl(
                                      icon: Icons.filter_alt_outlined,
                                      onTap: _showFilterMenu,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                _ControlBox(
                                  icon: Icons.calendar_today_outlined,
                                  label: _dateLabel,
                                  trailing: Icons.keyboard_arrow_down_rounded,
                                  onTap: _pickDate,
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  flex: 7,
                                  child: _SearchControlBox(
                                    controller: _searchController,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  flex: 7,
                                  child: _ControlBox(
                                    icon: Icons.calendar_today_outlined,
                                    label: _dateLabel,
                                    onTap: _pickDate,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  flex: 3,
                                  child: _SquareControl(
                                    icon: Icons.filter_alt_outlined,
                                    onTap: _showFilterMenu,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    Container(
                      color: widget.activeTab == _BatchTab.completed
                          ? const Color(0xFFF2F4F7)
                          : Colors.white,
                      child: Column(
                        children: [
                          ...visibleBatches
                            .map(
                              (batch) => _BatchTile(
                                batch: batch,
                                compactCompleted:
                                    widget.activeTab == _BatchTab.completed,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  widget.resultsRoute,
                                  arguments: {'batch': batch},
                                ),
                              ),
                            )
                            .toList(),
                          if (visibleBatches.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'No batches match the current filters.',
                                style: TextStyle(
                                  color: _textMuted,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
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

class _SamplingResultsPage extends StatefulWidget {
  const _SamplingResultsPage({
    required this.title,
    required this.batch,
    required this.leadingIcon,
  });

  final String title;
  final SamplingBatch batch;
  final IconData leadingIcon;

  @override
  State<_SamplingResultsPage> createState() => _SamplingResultsPageState();
}

class _SamplingResultsPageState extends State<_SamplingResultsPage> {
  static const _appearanceOptions = [
    'Clear, light yellow liquid',
    'Colorless liquid',
    'Clear viscous liquid',
    'Yellow powder',
    'Dark brown liquid',
    'White flakes',
    'White crystalline solid',
    'White granular powder',
    'Off-white granules',
    'Greenish crystals',
  ];

  late String _appearance;
  late TextEditingController _densityController;
  late TextEditingController _purityController;
  late TextEditingController _moistureController;

  @override
  void initState() {
    super.initState();
    _appearance = widget.batch.appearance;
    _densityController = TextEditingController(text: widget.batch.density);
    _purityController = TextEditingController(text: widget.batch.purity);
    _moistureController = TextEditingController(text: widget.batch.moisture);
  }

  @override
  void dispose() {
    _densityController.dispose();
    _purityController.dispose();
    _moistureController.dispose();
    super.dispose();
  }

  void _submitResults() {
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Results for ${widget.batch.id} submitted successfully.'),
        backgroundColor: _primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavBar(
        items: _navItems(4),
        onItemTapped: (index) => _onNavItemTapped(context, index),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _PageHeader(
              leadingIcon: widget.leadingIcon,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 26, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: _primary,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _BatchSummaryCard(batch: widget.batch),
                    const SizedBox(height: 22),
                    _CurrentStatusCard(status: widget.batch.status),
                    const SizedBox(height: 34),
                    const _FormLabel('APPEARANCE'),
                    const SizedBox(height: 12),
                    _AppearanceDropdown(
                      value: _appearance,
                      options: {
                        widget.batch.appearance,
                        ..._appearanceOptions,
                      }.toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _appearance = value);
                        }
                      },
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FormLabel('DENSITY (G/CM³)'),
                              const SizedBox(height: 10),
                              _NumberFieldBox(controller: _densityController),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _FormLabel('PURITY (%)'),
                              const SizedBox(height: 10),
                              _NumberFieldBox(controller: _purityController),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    const _FormLabel('MOISTURE CONTENT (%)'),
                    const SizedBox(height: 12),
                    _NumberFieldBox(controller: _moistureController),
                    const SizedBox(height: 40),
                    _TesterCard(batch: widget.batch),
                    const SizedBox(height: 34),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _submitResults,
                        icon: const Icon(Icons.cloud_upload_outlined, size: 20),
                        label: const Text('SUBMIT RESULTS'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(62),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
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

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.leadingIcon});

  final IconData? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final showBox = leadingIcon != null && leadingIcon != Icons.science_outlined;
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFF8C95A2), width: 1.2)),
      ),
      child: Row(
        children: [
          if (leadingIcon != null) ...[
            showBox
                ? Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(leadingIcon, color: Colors.white, size: 28),
                  )
                : Icon(leadingIcon, color: _primary, size: 34),
            SizedBox(width: showBox ? 18 : 12),
          ],
          const Text(
            'WORKWISE',
            style: TextStyle(
              color: _primary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon.')),
              );
            },
            child: const Icon(
              Icons.settings_outlined,
              color: Color(0xFF414954),
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTab extends StatelessWidget {
  const _TopTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? _primary : Colors.transparent,
              width: 3.5,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected ? _primary : const Color(0xFF4F5562),
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _ControlBox extends StatelessWidget {
  const _ControlBox({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final IconData? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _lineBorder, width: 1.4),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4E5561), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF2C3138),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (trailing != null) Icon(trailing, color: _primary, size: 24),
          ],
        ),
      ),
    );
  }
}

class _SquareControl extends StatelessWidget {
  const _SquareControl({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 62,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _lineBorder, width: 1.4),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: const Color(0xFF303744), size: 24),
      ),
    );
  }
}

class _SearchControlBox extends StatelessWidget {
  const _SearchControlBox({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _lineBorder, width: 1.4),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF4E5561), size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Search batch...',
                border: InputBorder.none,
                isCollapsed: true,
                hintStyle: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            InkWell(
              onTap: controller.clear,
              child: const Icon(Icons.close_rounded, color: _textMuted, size: 18),
            ),
        ],
      ),
    );
  }
}

class _BatchTile extends StatelessWidget {
  const _BatchTile({
    required this.batch,
    required this.compactCompleted,
    required this.onTap,
  });

  final SamplingBatch batch;
  final bool compactCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(
          24,
          compactCompleted ? 0 : 8,
          24,
          compactCompleted ? 0 : 8,
        ),
        padding: EdgeInsets.fromLTRB(
          compactCompleted ? 28 : 0,
          compactCompleted ? 18 : 0,
          compactCompleted ? 24 : 0,
          compactCompleted ? 18 : 0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: compactCompleted
              ? const Border(bottom: BorderSide(color: _border))
              : Border.all(color: _border),
        ),
        child: Row(
          children: [
            if (!compactCompleted)
              Container(width: 4, height: 126, color: _primary),
            if (!compactCompleted) const SizedBox(width: 24),
            Expanded(
              child: compactCompleted
                  ? _CompletedBatchTileContent(batch: batch)
                  : _PendingBatchTileContent(batch: batch),
            ),
            const SizedBox(width: 12),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF838A95),
              size: 34,
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingBatchTileContent extends StatelessWidget {
  const _PendingBatchTileContent({required this.batch});

  final SamplingBatch batch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              batch.id,
              style: const TextStyle(
                color: _primary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            _StatusPill(status: batch.status),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          batch.material,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF4C5563)),
            const SizedBox(width: 8),
            Text(
              batch.date,
              style: const TextStyle(
                color: Color(0xFF303744),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 22),
            const Icon(Icons.scale_outlined, size: 18, color: Color(0xFF4C5563)),
            const SizedBox(width: 8),
            Text(
              batch.quantity,
              style: const TextStyle(
                color: Color(0xFF303744),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CompletedBatchTileContent extends StatelessWidget {
  const _CompletedBatchTileContent({required this.batch});

  final SamplingBatch batch;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              batch.id,
              style: const TextStyle(
                color: _primary,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 12),
            _StatusPill(status: batch.status),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          children: [
            Text(
              batch.material,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const Text(
              '\u2022',
              style: TextStyle(
                color: Color(0xFF5D6672),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              batch.date,
              style: const TextStyle(
                color: Color(0xFF3E4651),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          batch.quantity,
          style: const TextStyle(
            color: Color(0xFF4F5B66),
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isCompleted = status.toUpperCase() == 'COMPLETED';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompleted ? 12 : 10,
        vertical: isCompleted ? 6 : 5,
      ),
      decoration: BoxDecoration(
        color: isCompleted ? _statusDoneBg : _statusPendingBg,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: isCompleted ? _statusDoneText : _statusPendingText,
          fontSize: isCompleted ? 10 : 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _BatchSummaryCard extends StatelessWidget {
  const _BatchSummaryCard({required this.batch});

  final SamplingBatch batch;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(0, 18, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(width: 4, height: 214, color: _primary),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.inventory_2_outlined, color: Color(0xFF4B5563), size: 20),
                    SizedBox(width: 12),
                    Text(
                      'BATCH ID',
                      style: TextStyle(
                        color: Color(0xFF414954),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  batch.id,
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: _border, height: 1),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.science_outlined, color: Color(0xFF4B5563), size: 20),
                    SizedBox(width: 12),
                    Text(
                      'RAW MATERIAL',
                      style: TextStyle(
                        color: Color(0xFF414954),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  batch.material,
                  style: const TextStyle(
                    color: Color(0xFF59697A),
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
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

class _CurrentStatusCard extends StatelessWidget {
  const _CurrentStatusCard({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isCompleted = status.toUpperCase() == 'COMPLETED';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        color: const Color(0xFFECEEF2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: const [
                Icon(Icons.info, color: Color(0xFF5A6779), size: 26),
                SizedBox(width: 16),
                Flexible(
                  child: Text(
                    'CURRENT STATUS',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Color(0xFF556171),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFDCEBFA),
              border: Border.all(color: const Color(0xFF627A99), width: 1.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 12,
                  color: isCompleted ? const Color(0xFF0E5A1F) : const Color(0xFF90A3B7),
                ),
                const SizedBox(width: 10),
                Text(
                  status,
                  style: TextStyle(
                    color: isCompleted ? const Color(0xFF0E5A1F) : const Color(0xFF667789),
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.4,
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

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF343C46),
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _AppearanceDropdown extends StatelessWidget {
  const _AppearanceDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF8C94A3), width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: options.contains(value) ? value : options.first,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF6C7480),
            size: 28,
          ),
          items: options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _NumberFieldBox extends StatelessWidget {
  const _NumberFieldBox({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF8C94A3), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(
          border: InputBorder.none,
          suffixIcon: Icon(
            Icons.unfold_more_rounded,
            color: Color(0xFF6C7480),
            size: 24,
          ),
        ),
        style: const TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TesterCard extends StatelessWidget {
  const _TesterCard({required this.batch});

  final SamplingBatch batch;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TESTED BY',
            style: TextStyle(
              color: Color(0xFF424A55),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: _primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Text(
                  batch.testedBy,
                  style: const TextStyle(
                    color: _primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: _border, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, color: Color(0xFF4D5562), size: 22),
              const SizedBox(width: 12),
              Text(
                batch.testedDate,
                style: const TextStyle(
                  color: Color(0xFF3B4350),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              const Icon(Icons.access_time_outlined, color: Color(0xFF4D5562), size: 24),
              const SizedBox(width: 10),
              Text(
                batch.testedDuration,
                style: const TextStyle(
                  color: Color(0xFF3B4350),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}