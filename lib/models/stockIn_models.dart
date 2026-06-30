/// Shared models for the Stock In flow.
///
/// Pulled out of stockIn_page.dart into their own file so that other pages
/// (e.g. stockIn_completed_detail_page.dart) can use StockInBatch /
/// StockInPoGroup without creating a circular import with stockIn_page.dart
/// itself.
library;

/// One receiving order / batch line.
class StockInBatch {
  final int receivingOrderId;
  final String poNumber;
  final String lotNumber;
  final String batchNumber;
  final String rawMaterialName;
  final String supplier;
  final double? quantityReceivedKg;
  final DateTime receivedDate;

  const StockInBatch({
    required this.receivingOrderId,
    required this.poNumber,
    required this.lotNumber,
    required this.batchNumber,
    required this.rawMaterialName,
    required this.supplier,
    required this.quantityReceivedKg,
    required this.receivedDate,
  });

  factory StockInBatch.fromJson(Map<String, dynamic> json) {
    return StockInBatch(
      receivingOrderId: json['id'] as int,
      poNumber: json['po_number'] as String? ?? '-',
      lotNumber: (json['lot_number'] ?? '-') as String,
      batchNumber: (json['batch_number'] ?? '') as String,
      rawMaterialName: json['raw_material_name'] as String? ?? '-',
      supplier: json['supplier_name'] as String? ?? '-',
      quantityReceivedKg: json['quantity_received_kg'] != null
          ? double.tryParse(json['quantity_received_kg'].toString())
          : null,
      receivedDate: json['received_at'] != null
          ? DateTime.tryParse(json['received_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Batches grouped under one PO, for display + navigation.
class StockInPoGroup {
  final String poNumber;
  final String supplier;
  final DateTime receivedDate;
  final List<StockInBatch> batches;

  const StockInPoGroup({
    required this.poNumber,
    required this.supplier,
    required this.receivedDate,
    required this.batches,
  });
}