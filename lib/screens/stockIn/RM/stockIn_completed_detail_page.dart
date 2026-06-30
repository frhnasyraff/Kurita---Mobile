import 'package:flutter/material.dart';
import '../../../services/api_client.dart';
import '../../../models/stockIn_models.dart';

/// Read-only detail page shown when a user taps a PO in the COMPLETE tab.
/// Visually mirrors StockInConfirmationPage's card layout (material name,
/// lot/batch subtitle, quantity), but adds the assigned warehouse LOCATION
/// per material and has no scan/approve controls since everything here is
/// already finished.
class StockInCompletedDetailPage extends StatefulWidget {
  final String poNumber;
  final String supplier;
  final List<StockInBatch> batches;

  const StockInCompletedDetailPage({
    super.key,
    required this.poNumber,
    required this.supplier,
    required this.batches,
  });

  @override
  State<StockInCompletedDetailPage> createState() =>
      _StockInCompletedDetailPageState();
}

class _StockInCompletedDetailPageState
    extends State<StockInCompletedDetailPage> {
  static const primary = Color(0xFF17335C);
  static const secondaryText = Color(0xFF6F8096);
  static const approvedGreen = Color(0xFF16A34A);
  static const pendingGrey = Color(0xFF8A99AD);

  final _api = ApiClient.instance;

  bool _loading = true;
  String? _error;

  /// Material data (qty + assigned_rack) from getStockInProgress, keyed by
  /// list index. We match by POSITION rather than receiving_order_id
  /// because the IDs returned by getStockIn() (StockInBatch.receivingOrderId)
  /// and getStockInProgress() (materials[].receiving_order_id) have been
  /// observed to NOT match for the same batch — likely different ID spaces
  /// on the backend. Since each PO's batch order should be stable, index
  /// position is the more reliable join key here.
  final List<Map<String, dynamic>> _materialsFromProgress = [];

  /// Full warehouse location list (id + label), used to resolve a short
  /// `assigned_rack` value (e.g. "Level 1") into a full Zone/Rack/Bay/Level
  /// label. This is a BEST-EFFORT fallback: the progress API doesn't return
  /// a warehouse_location_id, only a short label, and that short label can
  /// match multiple full locations (e.g. "Level 1" appears in many racks).
  /// We pick the longest matching label as the most specific guess, and
  /// flag the result as ambiguous when more than one full label matches.
  List<Map<String, dynamic>> _warehouseLocations = [];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _api.init();
      final json = await _api.getStockInProgress(widget.poNumber);
      final materials = (json['materials'] as List?) ?? [];

      final loadedMaterials =
          materials.map((m) => m as Map<String, dynamic>).toList();

      // Best-effort: resolve full Zone/Rack/Bay/Level labels for display.
      // Failure here shouldn't block showing the rest of the page.
      List<Map<String, dynamic>> loadedLocations = [];
      try {
        final rawLocations = await _api.getWarehouseLocations();
        loadedLocations =
            rawLocations.map((e) => e as Map<String, dynamic>).toList();
      } catch (_) {
        // No full-location data available — we'll just show the short
        // assigned_rack label as-is.
      }

      if (!mounted) return;
      setState(() {
        _materialsFromProgress.clear();
        _materialsFromProgress.addAll(loadedMaterials);
        _warehouseLocations = loadedLocations;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Resolves a short rack label (e.g. "Level 1") to the best-guess full
  /// Zone/Rack/Bay/Level location string from getWarehouseLocations().
  ///
  /// Returns the LONGEST label that contains [shortLabel] as a substring
  /// (more segments ≈ more specific), since the short label alone can
  /// match many different full locations. [isAmbiguous] is set true when
  /// more than one full label matches, so the UI can show a small notice
  /// that this is a best-effort guess rather than a guaranteed match.
  ({String label, bool isAmbiguous}) _resolveFullLocation(String shortLabel) {
    final matches = _warehouseLocations
        .where((loc) =>
            (loc['label'] as String?)?.contains(shortLabel) ?? false)
        .toList();

    if (matches.isEmpty) {
      return (label: shortLabel, isAmbiguous: false);
    }

    matches.sort((a, b) =>
        (b['label'] as String).length.compareTo((a['label'] as String).length));

    return (
      label: matches.first['label'] as String,
      isAmbiguous: matches.length > 1,
    );
  }

  /// Same date format used by the COMPLETE tab's card in stockIn_page.dart
  /// (e.g. "Oct 24, 2024"), kept consistent across both screens.
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: SafeArea(
        child: Column(
          children: [
            // ── Single header: back + page title + avatar + settings ──
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: primary),
                  ),
                  const Expanded(
                    child: Text(
                      'STOCK IN DETAILS',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD1E1F4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_outline,
                        color: primary, size: 18),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings_outlined, color: primary),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Text(
                                'Lokasi mungkin tidak lengkap: $_error',
                                style: const TextStyle(
                                    color: Colors.orange, fontSize: 12),
                              ),
                            ),

                          // PO / Supplier info card
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border:
                                  Border.all(color: const Color(0xFFE0E0E0)),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: _buildInfoRow(
                                      'PURCHASE ORDER', widget.poNumber),
                                ),
                                const Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: Color(0xFFE0E0E0)),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: _buildInfoRow(
                                      'SUPPLIER', widget.supplier),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          ...widget.batches.asMap().entries.map((entry) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _buildBatchCard(entry.value, entry.key),
                              )),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF8A99AD),
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBatchCard(StockInBatch batch, int index) {
    // Look up this batch's corresponding entry from getStockInProgress by
    // position — receiving_order_id doesn't reliably match between the
    // /stock-in list endpoint and the /progress endpoint, but list order
    // for a given PO is stable, so index is the safer join here.
    final progressEntry = index < _materialsFromProgress.length
        ? _materialsFromProgress[index]
        : null;

    final shortLocation = progressEntry?['assigned_rack'] as String?;
    final resolvedLocation = shortLocation != null
        ? _resolveFullLocation(shortLocation)
        : null;

    // qty from getStockInProgress already comes pre-formatted with a unit
    // (e.g. "100 kg"), unlike StockInBatch.quantityReceivedKg which is a
    // raw number and is often null for already-completed batches.
    final qtyFromProgress = progressEntry?['qty'] as String?;
    final qtyFromBatch = batch.quantityReceivedKg;
    final qtyLabel = qtyFromProgress ??
        (qtyFromBatch != null
            ? '${qtyFromBatch % 1 == 0 ? qtyFromBatch.toStringAsFixed(0) : qtyFromBatch.toStringAsFixed(2)} kg'
            : '—');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: approvedGreen),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header box: name + subtitle + COMPLETED badge ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              border: Border.all(color: const Color(0xFFD9D9D9), width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        batch.rawMaterialName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'LOT ${batch.lotNumber}'
                        '${batch.batchNumber.isNotEmpty ? " • BATCH ${batch.batchNumber}" : ""}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF7A7A7A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8F3E8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'COMPLETED',
                    style: TextStyle(
                      color: approvedGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Body: QUANTITY / LOCATION / RECEIVED DATE, each its own
          // full-width row, stacked top to bottom. ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReadOnlyField(
                  label: 'QUANTITY (KG)',
                  value: qtyLabel,
                ),
                const SizedBox(height: 14),
                _buildReadOnlyField(
                  label: 'LOCATION',
                  value: resolvedLocation?.label ?? '—',
                ),
                if (resolvedLocation?.isAmbiguous == true) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 12, color: pendingGrey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Lokasi anggaran — beberapa rack berkongsi label '
                          '"$shortLocation". Sahkan dengan QR rack sebenar.',
                          style: const TextStyle(
                            fontSize: 10,
                            color: pendingGrey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                // TODO: Backend belum sedia endpoint COA. Ikut keperluan,
                // RECEIVED DATE patut tukar guna tarikh COA/inspection
                // diluluskan (bukan received_at), apabila API tu wujud.
                _buildReadOnlyField(
                  label: 'RECEIVED DATE',
                  value: _formatDate(batch.receivedDate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: secondaryText,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            color: primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}