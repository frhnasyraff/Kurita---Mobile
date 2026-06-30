import 'package:flutter/material.dart';
import '../../../services/api_client.dart';
import '../../../models/stockIn_models.dart';
import '../../../services/uhf_reader_service.dart';

class StockInConfirmationPage extends StatefulWidget {
  final String poNumber;
  final String supplier;
  final List<StockInBatch> batches;

  const StockInConfirmationPage({
    super.key,
    required this.poNumber,
    required this.supplier,
    required this.batches,
  });

  @override
  State<StockInConfirmationPage> createState() =>
      _StockInConfirmationPageState();
}

/// Per-batch form state — one of these per card.
class _BatchForm {
  final StockInBatch batch;
  final TextEditingController qtyController;
  bool scannerLinked = false; // set true once UHF tag scan completes
  String? epc; // actual EPC value read from the tag — needed for backend bind
  bool isApproved = false;
  bool scanning = false;
  bool submitted = false;
  String? error;

  _BatchForm(this.batch)
      : qtyController = TextEditingController(
          text: batch.quantityReceivedKg != null
              ? batch.quantityReceivedKg!.toStringAsFixed(
                  batch.quantityReceivedKg! % 1 == 0 ? 0 : 2)
              : '',
        ) {
    // If quantity already exists (e.g. re-opening a partially filled batch),
    // treat the tag as already linked so the field isn't locked shut.
    if (batch.quantityReceivedKg != null && batch.quantityReceivedKg! > 0) {
      scannerLinked = true;
    }
  }

  void dispose() => qtyController.dispose();
}

class _StockInConfirmationPageState extends State<StockInConfirmationPage> {
  // ── Palette taken directly from the reference HTML tailwind colors ──
  static const primary = Color(0xFF002046);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFF1B365D);
  static const onSurface = Color(0xFF191C1D);
  static const onSurfaceVariant = Color(0xFF44474E);
  static const outline = Color(0xFF74777F);
  static const outlineVariant = Color(0xFFC4C6CF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF3F4F5);
  static const surfaceContainerHigh = Color(0xFFE7E8E9);
  static const secondaryContainer = Color(0xFFD5E3FC);
  static const onSecondaryContainer = Color(0xFF57657A);
  static const tertiaryContainer = Color(0xFF00356D); // "TAG VERIFIED" state
  static const onTertiaryContainer = Color(0xFF619FFD);
  static const secondaryText = Color(0xFF6F8096);

  final _api = ApiClient.instance;

  // Swap MockUhfReaderService() for the real implementation once hardware
  // connection (LLRP / vendor SDK) is wired up. Nothing else in this file
  // needs to change.
  final UhfReaderService _uhf = MockUhfReaderService();

  bool _submitting = false;

  late List<_BatchForm> _forms;

  @override
  void initState() {
    super.initState();
    _forms = widget.batches.map((b) => _BatchForm(b)).toList();
    _uhf.connect();
  }

  @override
  void dispose() {
    for (final f in _forms) {
      f.dispose();
    }
    _uhf.disconnect();
    super.dispose();
  }

  Future<void> _scanUhfTag(_BatchForm form) async {
    if (form.submitted || form.scanning) return;

    setState(() => form.scanning = true);

    try {
      final epc = await _uhf.scanOnce();

      if (!mounted) return;

      if (epc == null) {
        setState(() => form.scanning = false);
        _showSnack('Tag tak detect — pastikan dekat dengan reader, cuba lagi.');
        return;
      }

      setState(() {
        form.scanning = false;
        form.scannerLinked = true;
        form.epc = epc;
      });

      _showSnack('UHF tag linked for ${form.batch.rawMaterialName} (${form.batch.lotNumber}).');
    } catch (e) {
      if (!mounted) return;
      setState(() => form.scanning = false);
      _showSnack('Ralat scan UHF: $e');
    }
  }

  Future<void> _submitAll() async {
    // Validate every batch first.
    for (final form in _forms) {
      if (form.submitted) continue;
      if (!form.scannerLinked || form.epc == null) {
        _showSnack('${form.batch.rawMaterialName} (${form.batch.lotNumber}): scan UHF tag dahulu.');
        return;
      }
      final qty = double.tryParse(form.qtyController.text);
      if (qty == null || qty <= 0) {
        _showSnack('${form.batch.rawMaterialName} (${form.batch.lotNumber}): masukkan quantity yang sah.');
        return;
      }
      if (!form.isApproved) {
        _showSnack('${form.batch.rawMaterialName} (${form.batch.lotNumber}): sila approve batch ini.');
        return;
      }
    }

    setState(() => _submitting = true);

    var anyFailed = false;
    for (final form in _forms) {
      if (form.submitted) continue;
      form.error = null;
      try {
        try {
          await _api.startStockIn(form.batch.receivingOrderId);
        } catch (_) {
          // already in progress — proceed to submit
        }

        await _api.submitStockIn(
          form.batch.receivingOrderId,
          quantityKg: double.parse(form.qtyController.text),
          scannerLinked: form.scannerLinked,
          rfidTag: form.epc, // TODO: confirm ApiClient.submitStockIn accepts this param
        );

        setState(() => form.submitted = true);
      } catch (e) {
        anyFailed = true;
        setState(() => form.error = e.toString());
      }
    }

    setState(() => _submitting = false);

    final allDone = _forms.every((f) => f.submitted);
    if (allDone) {
      if (!mounted) return;
      Navigator.pop(context, true);
    } else if (anyFailed) {
      _showSnack('Sebahagian batch gagal — semak mesej ralat pada card berkaitan.');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _forms.where((f) => !f.submitted).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // background
      // ── Top App Bar: back + title + avatar + settings, all in one row ──
      appBar: AppBar(
        backgroundColor: surfaceContainerLowest,
        elevation: 0.5,
        surfaceTintColor: surfaceContainerLowest,
        leading: IconButton(
          onPressed: () =>
              Navigator.pop(context, _forms.any((f) => f.submitted)),
          icon: const Icon(Icons.arrow_back, color: primary),
        ),
        title: const Text(
          'CONFIRM STOCK IN',
          style: TextStyle(
            color: primary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: surfaceContainerHigh,
              shape: BoxShape.circle,
              border: Border.all(color: outlineVariant),
            ),
            child: const Icon(Icons.person, color: onSurfaceVariant, size: 18),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined,
                color: onSurfaceVariant),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Context Area / Summary Box ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceContainerLowest,
                  border: Border.all(color: outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSummaryRow('PURCHASE ORDER', widget.poNumber,
                        mono: true),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Divider(height: 1, color: outlineVariant),
                    ),
                    _buildSummaryRow('SUPPLIER', widget.supplier),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── List of Materials ──
              ..._forms.map((f) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildBatchCard(f),
                  )),
            ],
          ),
        ),
      ),
      // ── Fixed Footer Action ──
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: surfaceContainerLowest,
          border: const Border(top: BorderSide(color: outlineVariant)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: (_submitting || remaining == 0) ? null : _submitAll,
              style: FilledButton.styleFrom(
                backgroundColor: remaining == 0 ? Colors.grey : primary,
                foregroundColor: onPrimary,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                elevation: 0,
              ),
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle, size: 20),
              label: Text(
                remaining == 0
                    ? 'ALL BATCHES SUBMITTED'
                    : _submitting
                        ? 'SUBMITTING...'
                        : 'SUBMIT STOCK IN',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool mono = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: mono ? primary : onSurface,
            fontWeight: mono ? FontWeight.w700 : FontWeight.w600,
            fontFamily: mono ? 'monospace' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBatchCard(_BatchForm form) {
    final batch = form.batch;
    final locked = form.submitted;
    final qtyUnlocked = form.scannerLinked && !locked;

    return Container(
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        border: Border.all(color: outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header: name + subtitle, separated by a bottom border ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: surfaceContainerLow,
              border: const Border(
                bottom: BorderSide(color: outlineVariant),
              ),
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
                          fontWeight: FontWeight.w600,
                          color: primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'LOT ${batch.lotNumber}'
                        '${batch.batchNumber.isNotEmpty ? "  •  BATCH ${batch.batchNumber}" : ""}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: outline,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                if (locked)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: const BoxDecoration(color: tertiaryContainer),
                    child: const Text(
                      'SUBMITTED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: onTertiaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Body: scan button, quantity field, approve — gap-md (16px) ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (form.error != null) ...[
                  Text(
                    form.error!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                ],

                // --- SCAN UHF TAG ---
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed:
                        (locked || form.scanning) ? null : () => _scanUhfTag(form),
                    style: FilledButton.styleFrom(
                      backgroundColor: locked || form.scannerLinked
                          ? tertiaryContainer
                          : primary,
                      foregroundColor: locked || form.scannerLinked
                          ? onTertiaryContainer
                          : onPrimary,
                      disabledBackgroundColor: tertiaryContainer,
                      disabledForegroundColor: onTertiaryContainer,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      elevation: 0,
                    ),
                    icon: form.scanning
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            form.scannerLinked
                                ? Icons.check_circle
                                : Icons.qr_code_2,
                            size: 18,
                          ),
                    label: Text(
                      form.scanning
                          ? 'SCANNING...'
                          : form.scannerLinked
                              ? 'TAG VERIFIED'
                              : 'SCAN UHF TAG',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                if (form.scannerLinked && form.epc != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'EPC: ${form.epc}',
                    style: const TextStyle(fontSize: 10, color: secondaryText),
                  ),
                ],

                const SizedBox(height: 16),

                // --- UPDATE QUANTITY (KG) ---
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UPDATE QUANTITY (KG)',
                      style: TextStyle(
                        fontSize: 12,
                        color: onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: form.qtyController,
                      enabled: qtyUnlocked,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: qtyUnlocked ? primary : outline,
                      ),
                      decoration: InputDecoration(
                        hintText: form.scannerLinked
                            ? 'Enter Weight'
                            : 'Pending scan...',
                        hintStyle: const TextStyle(color: outline),
                        filled: true,
                        fillColor: qtyUnlocked
                            ? Colors.white
                            : surfaceContainerHigh,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 14),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: outlineVariant),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: outlineVariant),
                        ),
                        disabledBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: outlineVariant),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: primary, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // --- APPROVE toggle ---
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: (locked || !form.scannerLinked)
                        ? null
                        : () =>
                            setState(() => form.isApproved = !form.isApproved),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: form.isApproved
                          ? tertiaryContainer
                          : (form.scannerLinked
                              ? secondaryContainer
                              : Colors.transparent),
                      foregroundColor: form.isApproved
                          ? onTertiaryContainer
                          : (form.scannerLinked
                              ? onSecondaryContainer
                              : outline),
                      disabledForegroundColor: outline,
                      side: BorderSide(
                        color: form.scannerLinked
                            ? (form.isApproved
                                ? tertiaryContainer
                                : onSecondaryContainer)
                            : outlineVariant,
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: Text(
                      form.isApproved ? 'APPROVED' : 'APPROVE',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
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