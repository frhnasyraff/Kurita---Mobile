/// One "stock-in card" as returned by GET /api/stock-in.
///
/// The API normalizes two different backend sources into this one shape:
///   - source == 'receiving_order'     -> NEW / IN PROGRESS tabs
///   - source == 'rm_stock_in_record'  -> COMPLETE tab
///
/// `source` + `id` together are what you need to fetch the detail record
/// via GET /api/stock-in/{source}/{id}.
class StockInCard {
  final String source; // 'receiving_order' | 'rm_stock_in_record'
  final int id;
  final String poNumber;
  final String? lotNumber;
  final String? batchNumber;
  final String? supplierName;
  final String? rawMaterialName;
  final String? sapCode;
  final String? specification;
  final DateTime? expectedReceiveDate;
  final DateTime? receivedAt;
  final double? quantityReceivedKg;
  final String? inspectionStatus; // pending | in_progress | passed | failed
  final String? inspectionStatusLabel;
  final String stockInStatus; // new | in_progress | complete
  final String? qcRemarks;
  final String? failureReason;
  final DateTime? inspectedAt;

  // Only present when source == 'rm_stock_in_record'
  final String? warehouseLocation;
  final bool? labelingVerified;
  final bool? batchCreated;
  final bool? scannerLinked;
  final DateTime? submittedAt;

  const StockInCard({
    required this.source,
    required this.id,
    required this.poNumber,
    this.lotNumber,
    this.batchNumber,
    this.supplierName,
    this.rawMaterialName,
    this.sapCode,
    this.specification,
    this.expectedReceiveDate,
    this.receivedAt,
    this.quantityReceivedKg,
    this.inspectionStatus,
    this.inspectionStatusLabel,
    required this.stockInStatus,
    this.qcRemarks,
    this.failureReason,
    this.inspectedAt,
    this.warehouseLocation,
    this.labelingVerified,
    this.batchCreated,
    this.scannerLinked,
    this.submittedAt,
  });

  factory StockInCard.fromJson(Map<String, dynamic> json) {
    return StockInCard(
      source: json['source'] as String? ?? 'receiving_order',
      id: json['id'] as int,
      poNumber: json['po_number'] as String? ?? '-',
      lotNumber: json['lot_number'] as String?,
      batchNumber: json['batch_number'] as String?,
      supplierName: json['supplier_name'] as String?,
      rawMaterialName: json['raw_material_name'] as String?,
      sapCode: json['sap_code'] as String?,
      specification: json['specification'] as String?,
      expectedReceiveDate: _parseDate(json['expected_receive_date']),
      receivedAt: _parseDate(json['received_at']),
      quantityReceivedKg: (json['quantity_received_kg'] as num?)?.toDouble(),
      inspectionStatus: json['inspection_status'] as String?,
      inspectionStatusLabel: json['inspection_status_label'] as String?,
      stockInStatus: json['stock_in_status'] as String? ?? 'new',
      qcRemarks: json['qc_remarks'] as String?,
      failureReason: json['failure_reason'] as String?,
      inspectedAt: _parseDate(json['inspected_at']),
      warehouseLocation: json['warehouse_location'] as String?,
      labelingVerified: json['labeling_verified'] as bool?,
      batchCreated: json['batch_created'] as bool?,
      scannerLinked: json['scanner_linked'] as bool?,
      submittedAt: _parseDate(json['submitted_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value as String);
  }

  DateTime? get displayDate => receivedAt ?? submittedAt ?? expectedReceiveDate;

  bool get isComplete => source == 'rm_stock_in_record';

  /// Badge text for the QC/status chip.
  String get statusLabel {
    if (isComplete) return 'COMPLETE';
    switch (inspectionStatus) {
      case 'passed':
        return 'PASS';
      case 'failed':
        return 'FAILED';
      case 'in_progress':
        return 'IN PROGRESS';
      default:
        return 'PENDING';
    }
  }
}

class StockInListResponse {
  final List<StockInCard> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final Map<String, int> counts; // {new: x, in_progress: y, complete: z}

  const StockInListResponse({
    required this.items,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    required this.counts,
  });

  factory StockInListResponse.fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? {};
    final countsJson = json['counts'] as Map<String, dynamic>? ?? {};

    return StockInListResponse(
      items: (json['data'] as List<dynamic>? ?? [])
          .map((e) => StockInCard.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      total: meta['total'] as int? ?? 0,
      counts: countsJson.map((k, v) => MapEntry(k, (v as num).toInt())),
    );
  }
}