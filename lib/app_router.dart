import 'package:flutter/material.dart';

import 'screens/debug_menu_page.dart';
import 'screens/welcome_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/others_page.dart';
import 'screens/inspection_details_page.dart';
import 'screens/production_page.dart';
import 'screens/pre_production_page.dart';
import 'screens/material_verification_page.dart';
import 'screens/production_detail_page.dart';
import 'screens/wash_tank_page.dart';
import 'screens/tank_cleaning_confirmation.dart';
import 'screens/product_inspection_page.dart';
import 'screens/adjustment_page.dart';
import 'screens/rm_balance_weight_page.dart';
import 'screens/scanner_screen.dart';
import 'screens/quality_control_results_page.dart';
import 'screens/sampling_pages.dart';
import 'screens/delivery_pages.dart';
import 'screens/stock_count_dashboard_page.dart';
import 'screens/stock_count_select_process_page.dart';
import 'screens/stock_count_identify_location_page.dart';
import 'screens/stock_count_location_verify_page.dart';
import 'screens/stock_count_scan_verify_page.dart';
import 'screens/stock_count_summary_page.dart';
import 'screens/stock_count_models.dart';

// ── Route name constants ──────────────────────────────────────────────────────

class Routes {
  Routes._();

  static const debugMenu         = '/debug-menu';

  static const welcome           = '/';
  static const login             = '/login';
  static const signup            = '/signup';
  static const shell             = '/home';

  // Inventory
  static const dashboard         = '/home/inventory/dashboard';
  static const stockCountDashboard = '/home/inventory/stock-count';
  static const stockCountSelectProcess = '/home/inventory/stock-count/select-process';
  static const stockCountIdentifyLocation = '/home/inventory/stock-count/identify-location';
  static const stockCountLocationVerify = '/home/inventory/stock-count/location-verify';
  static const stockCountScanVerify = '/home/inventory/stock-count/scan-verify';
  static const stockCountSummary = '/home/inventory/stock-count/summary';
  static const inspectionDetails = '/home/inventory/inspection-details';
  static const others            = '/home/others';
  static const preSamplingNew       = '/home/others/pre-sampling/new';
  static const preSamplingResults   = '/home/others/pre-sampling/results';
  static const preSamplingCompleted = '/home/others/pre-sampling/completed';
  static const samplingNew          = '/home/others/sampling/new';
  static const samplingResults      = '/home/others/sampling/results';
  static const samplingCompleted    = '/home/others/sampling/completed';
  static const deliveryOverview     = '/home/delivery';
  static const deliveryPalletLoading = '/home/delivery/pallet-loading';
  static const deliveryPalletDetails = '/home/delivery/pallet-details';

  // Production
  static const production        = '/home/production';
  static const preProduction     = '/home/production/pre-production';
  static const materialVerify    = '/home/production/material-verification';
  static const productionDetail  = '/home/production/detail';
  static const washTank          = '/home/production/wash-tank';
  static const tankCleaning      = '/home/production/tank-cleaning';
  static const productInspection = '/home/production/product-inspection';
  static const adjustment        = '/home/production/adjustment';
  static const rmBalanceWeight   = '/home/production/rm-balance-weight';
  static const scanner           = '/home/production/scanner';
  static const qcResults         = '/home/production/qc-results';
}

// ── Router ────────────────────────────────────────────────────────────────────

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {

    // ── Debug ──
      case Routes.debugMenu:
        return _fade(const DebugMenuPage());

    // ── Auth ──
      case Routes.welcome:
        return _fade(const WelcomePage());

      case Routes.login:
        return _slide(const LoginPage());

      case Routes.signup:
        return _slide(const SignUpPage());

    // ── Main shell (bottom nav) ──
      case Routes.shell:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final tab  = args['tab'] as int? ?? 1;
        return _fade(MainShell(initialTab: tab));

    // ── Inventory ──
      case Routes.dashboard:
        return _slide(const DashboardPage());

      case Routes.stockCountDashboard:
        return _slide(const StockCountDashboardPage());

      case Routes.stockCountSelectProcess:
        return _slide(const StockCountSelectProcessPage());

      case Routes.stockCountIdentifyLocation:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final process =
            args['process'] as StockCountProcess? ?? StockCountProcess.rawMaterial;
        return _slide(StockCountIdentifyLocationPage(process: process));

      case Routes.stockCountLocationVerify:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final process =
            args['process'] as StockCountProcess? ?? StockCountProcess.rawMaterial;
        return _slide(StockCountLocationVerifyPage(process: process));

      case Routes.stockCountScanVerify:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final process =
            args['process'] as StockCountProcess? ?? StockCountProcess.rawMaterial;
        return _slide(StockCountScanVerifyPage(process: process));

      case Routes.stockCountSummary:
        return _slide(const StockCountSummaryPage());

      case Routes.inspectionDetails:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _slide(InspectionDetailsPage(
          poNumber:    args['poNumber']    as String? ?? 'PO-8842',
          companyName: args['companyName'] as String? ?? 'Industrial Alloys Inc.',
        ));

      case Routes.others:
        return _slide(const OthersPage());

      case Routes.preSamplingNew:
        return _slide(const PreSamplingNewPage());

      case Routes.preSamplingResults:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final batch = args['batch'] as SamplingBatch? ?? _fallbackPreSamplingBatch;
        return _slide(PreSamplingResultsPage(batch: batch));

      case Routes.preSamplingCompleted:
        return _slide(const PreSamplingCompletedPage());

      case Routes.samplingNew:
        return _slide(const SamplingNewPage());

      case Routes.samplingResults:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final batch = args['batch'] as SamplingBatch? ?? _fallbackSamplingBatch;
        return _slide(SamplingResultsPage(batch: batch));

      case Routes.samplingCompleted:
        return _slide(const SamplingCompletedPage());

      case Routes.deliveryOverview:
        return _slide(const DeliveryOverviewPage());

      case Routes.deliveryPalletLoading:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final job = args['job'] as DeliveryJob? ?? _fallbackDeliveryJob;
        return _slide(DeliveryPalletLoadingPage(
          jobId: job.numericId,
          seedJob: job,
        ));

      case Routes.deliveryPalletDetails:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final job = args['job'] as DeliveryJob? ?? _fallbackDeliveryJob;
        final flow = DeliveryFlowController.seeded(job);
        return _slide(DeliveryPalletDetailsPage(
          job: job,
          flow: flow,
          pallet: flow.pallets.first,
        ));

    // ── Production hub ──
      case Routes.production:
        return _slide(const ProductionPage());

      case Routes.preProduction:
        return _slide(const PreProductionPage());

      case Routes.materialVerify:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _slide(MaterialVerificationPage(
          jobId: args['jobId'] as String? ?? '',
        ));

    // ProductionDetailPage: jobSheetNumber, productName, lane, quantity
      case Routes.productionDetail:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _slide(ProductionDetailPage(
          jobSheetNumber: args['jobSheetNumber'] as String? ?? '',
          productName:    args['productName']    as String? ?? '',
          lane:           args['lane']           as String? ?? '',
          quantity:       args['quantity']       as String? ?? '',
        ));

    // WashTankPage: jobSheetId, productName, laneNumber (all optional)
      case Routes.washTank:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _slide(WashTankPage(
          jobSheetId:  args['jobSheetId']  as String? ?? '#JOB-2024-012',
          productName: args['productName'] as String? ?? '',
          laneNumber:  args['laneNumber']  as String? ?? '',
        ));

    // TankCleaningConfirmation: jobId, productName, laneNumber (all required)
      case Routes.tankCleaning:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _slide(TankCleaningConfirmation(
          jobId:       args['jobId']       as String? ?? '',
          productName: args['productName'] as String? ?? '',
          laneNumber:  args['laneNumber']  as String? ?? '',
        ));

    // QualityInspectionPage (class name inside product_inspection_page.dart)
      case Routes.productInspection:
        return _slide(const QualityInspectionPage());

    // AdjustmentPage: jobSheetNumber, productName (both optional)
      case Routes.adjustment:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _slide(AdjustmentPage(
          jobSheetNumber: args['jobSheetNumber'] as String? ?? '',
          productName:    args['productName']    as String? ?? '',
        ));

    // RmBalanceWeightPage: jobId, poNumber, allCode (all optional)
      case Routes.rmBalanceWeight:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _slide(RmBalanceWeightPage(
          jobId:    args['jobId']    as String? ?? 'JOB-2024-052',
          poNumber: args['poNumber'] as String? ?? 'PO-8826-052',
          allCode:  args['allCode']  as String? ?? 'ALL: A12',
        ));

    // ScannerScreen
      case Routes.scanner:
        return _slide(const ScannerScreen());

    // QualityControlResultsPage: jobSheetId, testedBy, updatedBy,
    //                            currentStatus, parameters (all optional)
      case Routes.qcResults:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return _slide(QualityControlResultsPage(
          jobSheetId:    args['jobSheetId']    as String? ?? '',
          testedBy:      args['testedBy']      as String? ?? 'Sarah Connor',
          updatedBy:     args['updatedBy']     as String? ?? 'John Smith',
          currentStatus: args['currentStatus'] as String? ?? 'Adjustment Require',
        ));

      default:
        return _fade(const WelcomePage());
    }
  }

  // ── Transitions ──────────────────────────────────────────────────────────
  static PageRouteBuilder _fade(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
    transitionDuration: const Duration(milliseconds: 250),
  );

  static PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, anim, __, child) => SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(
          CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 300),
  );
}

// ── Main Shell (Bottom Nav) ───────────────────────────────────────────────────

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.initialTab = 1});
  final int initialTab;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  Widget _buildTab(int index) {
    switch (index) {
      case 0:  return const _EmptyTab(label: 'Quality');
      case 1:  return const StockCountDashboardPage();
      case 2:  return const ProductionPage();
      case 3:  return const DeliveryOverviewPage();
      case 4:  return const OthersPage();
      default: return const DashboardPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: List.generate(5, _buildTab),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE4EAF2))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.verified_outlined,
                label: 'Quality',
                selected: _currentTab == 0,
                onTap: () => setState(() => _currentTab = 0),
              ),
              _NavItem(
                icon: Icons.inventory_2_outlined,
                label: 'Inventory',
                selected: _currentTab == 1,
                onTap: () => setState(() => _currentTab = 1),
              ),
              _NavItem(
                icon: Icons.precision_manufacturing_outlined,
                label: 'Production',
                selected: _currentTab == 2,
                onTap: () => setState(() => _currentTab = 2),
              ),
              _NavItem(
                icon: Icons.local_shipping_outlined,
                label: 'Delivery',
                selected: _currentTab == 3,
                onTap: () => setState(() => _currentTab = 3),
              ),
              _NavItem(
                icon: Icons.more_horiz_outlined,
                label: 'Others',
                selected: _currentTab == 4,
                onTap: () => setState(() => _currentTab = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Nav Item ──────────────────────────────────────────────────────────────────

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _primary     = Color(0xFF17335C);
  static const _navInactive = Color(0xFF98A6B7);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22,
              color: selected ? _primary : _navInactive),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  color: selected ? _primary : _navInactive,
                  fontSize: 10,
                  fontWeight:
                  selected ? FontWeight.w800 : FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Empty Tab Placeholder ─────────────────────────────────────────────────────

class _EmptyTab extends StatelessWidget {
  const _EmptyTab({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.construction_rounded,
                color: Color(0xFF8A99AD), size: 40),
            const SizedBox(height: 12),
            Text('$label coming soon',
                style: const TextStyle(
                    color: Color(0xFF8A99AD),
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

const _fallbackPreSamplingBatch = SamplingBatch(
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
);

const _fallbackSamplingBatch = SamplingBatch(
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
);

const _fallbackDeliveryJob = DeliveryJob(
  id: 'BPL 1982',
  vehicleId: 'BPL 1982',
  bay: '04',
  customer: 'Global Logistics',
  doNumber: 'D-2024-088',
  totalPallets: '15 Pallets',
  packingList: '12',
  progressText: '75% (12/15 Pallets)',
  progress: 0.80,
  clientName: 'Global Logistics',
  clientLocation: 'Shah Alam',
  productRows: [
    DeliveryProductRow(
      sku: 'CP-902-X',
      name: 'Premium Catalyst Pdr',
      quantity: '456 KG / 15 Units',
      pallets: '4',
    ),
  ],
);
