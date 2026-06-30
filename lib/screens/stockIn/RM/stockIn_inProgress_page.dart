import 'package:flutter/material.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../../services/api_client.dart';
import '../../QualityControl/dashboard_page.dart';
import '../../preproduct/material_verification_page.dart';
import '../../PreProduct/pre_production_page.dart';
import 'qr_scanner_page.dart';

// ─────────────────────────────────────────
// MODELS
// ─────────────────────────────────────────
enum MaterialScanStatus { complete, awaitingLocation }

class StockInProgressMaterial {
  final int receivingOrderId;
  final String name;
  final String? assignedRack;
  final String? qty;
  final String uhfStatus; // 'LINKED' | 'PENDING'
  final MaterialScanStatus status;

  const StockInProgressMaterial({
    required this.receivingOrderId,
    required this.name,
    required this.assignedRack,
    required this.qty,
    required this.uhfStatus,
    required this.status,
  });

  factory StockInProgressMaterial.fromJson(Map<String, dynamic> json) {
    return StockInProgressMaterial(
      receivingOrderId: json['receiving_order_id'] as int,
      name: json['name'] as String? ?? '-',
      assignedRack: json['assigned_rack'] as String?,
      qty: json['qty'] as String?,
      uhfStatus: json['uhf_status'] as String? ?? 'PENDING',
      status: json['status'] == 'complete'
          ? MaterialScanStatus.complete
          : MaterialScanStatus.awaitingLocation,
    );
  }
}

class StockInProgressData {
  final String poNumber;
  final String supplier;
  final int qcPercent;
  final int materialsChecked;
  final int materialsTotal;
  final List<StockInProgressMaterial> materials;

  const StockInProgressData({
    required this.poNumber,
    required this.supplier,
    required this.qcPercent,
    required this.materialsChecked,
    required this.materialsTotal,
    required this.materials,
  });

  factory StockInProgressData.fromJson(Map<String, dynamic> json) {
    return StockInProgressData(
      poNumber: json['po_number'] as String? ?? '-',
      supplier: json['supplier_name'] as String? ?? '-',
      qcPercent: json['qc_percent'] as int? ?? 0,
      materialsChecked: json['materials_checked'] as int? ?? 0,
      materialsTotal: json['materials_total'] as int? ?? 0,
      materials: ((json['materials'] as List?) ?? [])
          .map((e) => StockInProgressMaterial.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Warehouse location option, used to resolve a scanned QR token to an id.
class _WarehouseLocationOption {
  final int id;
  final String label;
  final String? qrToken;
  const _WarehouseLocationOption(this.id, this.label, this.qrToken);
}

// ─────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────
class StockInProgressPage extends StatefulWidget {
  final String poNumber;

  const StockInProgressPage({
    super.key,
    required this.poNumber,
  });

  @override
  State<StockInProgressPage> createState() => _StockInProgressPageState();
}

class _StockInProgressPageState extends State<StockInProgressPage> {
  // ── Palette from the reference HTML tailwind colors ──
  static const primary = Color(0xFF002046);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF44474E);
  static const outline = Color(0xFF74777F);
  static const outlineVariant = Color(0xFFC4C6CF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F4F5);
  static const surfaceContainerHigh = Color(0xFFE7E8E9);
  // Scanned badge colors (custom hex from the HTML, not in the token list)
  static const scannedBg = Color(0xFFE7F5ED);
  static const scannedFg = Color(0xFF1B5E20);
  static const scannedBorder = Color(0xFFC8E6C9);

  final _api = ApiClient.instance;
  int _selectedNavBar = 1;

  bool _loading = true;
  bool _assigning = false;
  String? _error;
  StockInProgressData? _data;
  List<_WarehouseLocationOption> _locations = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _api.init();
      final results = await Future.wait([
        _api.getStockInProgress(widget.poNumber),
        _api.getWarehouseLocations(),
      ]);

      final progressJson = results[0] as Map<String, dynamic>;
      final rawLocations = results[1] as List<dynamic>;

      setState(() {
        _data = StockInProgressData.fromJson(progressJson);
        _locations = rawLocations.map((e) {
          final m = e as Map<String, dynamic>;
          return _WarehouseLocationOption(
            m['value'] as int,
            m['label'] as String? ?? 'Location ${m['value']}',
            m['qr_token'] as String?,
          );
        }).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Opens the camera, scans a rack's QR code, resolves it to a
  /// warehouse_location_id, then assigns it to this material via
  /// [ApiClient.setWarehouseLocation].
  Future<void> _scanQrLocation(StockInProgressMaterial material) async {
    if (_assigning) return;

    final scanned = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerPage()),
    );
    if (scanned == null || !mounted) return;

    final match = _locations.where((l) => l.qrToken == scanned).toList();
    if (match.isEmpty) {
      _showSnack('QR tak match mana-mana location berdaftar.');
      return;
    }

    setState(() => _assigning = true);
    try {
      await _api.setWarehouseLocation(
        material.receivingOrderId,
        warehouseLocationId: match.first.id,
      );
      _showSnack('Location "${match.first.label}" assigned untuk ${material.name}.');
      await _load();
    } catch (e) {
      if (!mounted) return;
      _showSnack(e.toString());
    } finally {
      if (mounted) setState(() => _assigning = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _navigateTo(int index) {
    Widget page;
    switch (index) {
      case 0:
        page = const MaterialVerificationPage(jobId: 'JOB-001');
        break;
      case 1:
        Navigator.pop(context);
        return;
      case 2:
        page = const PreProductionPage();
        break;
      case 3:
        page = const DashboardPage();
        break;
      default:
        return;
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // ── TopAppBar: Workwise + settings, matches HTML #2 ──
      appBar: AppBar(
        backgroundColor: surfaceContainerLowest,
        elevation: 0.5,
        surfaceTintColor: surfaceContainerLowest,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            const Icon(Icons.precision_manufacturing, color: primary, size: 22),
            const SizedBox(width: 8),
            const Text(
              'Workwise',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: onSurfaceVariant),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        items: [
          (Icons.verified_outlined, 'Quality', _selectedNavBar == 0),
          (Icons.inventory_2_outlined, 'Inventory', _selectedNavBar == 1),
          (Icons.precision_manufacturing_outlined, 'Production', _selectedNavBar == 2),
          (Icons.local_shipping_outlined, 'Delivery', _selectedNavBar == 3),
          (Icons.more_horiz, 'Others', _selectedNavBar == 4),
        ],
        onItemTapped: _navigateTo,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final data = _data!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Page Header, with bottom border per HTML ──
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: outlineVariant)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STOCK IN - IN PROGRESS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: primary,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.inventory, size: 18, color: onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '${data.poNumber} | ${data.supplier}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          _buildProgressCard(data),

          const SizedBox(height: 24),

          Text(
            'MATERIAL LIST',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),

          ...data.materials.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildMaterialCard(m),
              )),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildProgressCard(StockInProgressData data) {
    final progress = data.qcPercent / 100.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLow,
        border: Border.all(color: outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PO PROGRESS SUMMARY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${data.qcPercent}%',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: primary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'COMPLETE',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: primary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${data.materialsChecked}/${data.materialsTotal} MATERIALS',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primary,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'SCANNED',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRect(
            child: SizedBox(
              height: 12,
              child: Stack(
                children: [
                  Container(color: surfaceContainerHigh),
                  FractionallySizedBox(
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(color: primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialCard(StockInProgressMaterial material) {
    final isComplete = material.status == MaterialScanStatus.complete;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        border: Border.all(color: outlineVariant),
        // PENDING items get a left accent border, per the HTML
        // (border-l-4 border-l-primary on the pending card).
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isComplete)
            Container(
              width: 4,
              margin: const EdgeInsets.only(right: 12),
              color: primary,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Name + status badge ──
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      material.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isComplete ? scannedBg : surfaceContainerHigh,
                        border: Border.all(
                          color: isComplete ? scannedBorder : outlineVariant,
                        ),
                      ),
                      child: Text(
                        isComplete ? 'SCANNED' : 'PENDING SCAN',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isComplete ? scannedFg : onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // ── Rack ──
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16, color: onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      'ASSIGNED: ${material.assignedRack ?? "Pending scan..."}',
                      style: TextStyle(
                        fontSize: 13,
                        color: onSurfaceVariant,
                        fontFamily: 'monospace',
                        fontStyle:
                            isComplete ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // ── QTY + UHF ──
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.scale_outlined,
                            size: 16, color: onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          'QTY: ${material.qty ?? "Pending"}',
                          style: TextStyle(
                            fontSize: 13,
                            color: onSurfaceVariant,
                            fontFamily: 'monospace',
                            fontStyle: isComplete
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sell_outlined,
                            size: 16, color: onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          'UHF: ${material.uhfStatus}',
                          style: TextStyle(
                            fontSize: 13,
                            color: onSurfaceVariant,
                            fontFamily: 'monospace',
                            fontStyle: isComplete
                                ? FontStyle.normal
                                : FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (!isComplete) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _assigning
                          ? null
                          : () => _scanQrLocation(material),
                      icon: _assigning
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.qr_code_scanner, size: 18),
                      label: Text(
                        _assigning ? 'ASSIGNING...' : 'SCAN QR LOCATION',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (isComplete) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_circle, color: primary, size: 32),
          ],
        ],
      ),
    );
  }
}