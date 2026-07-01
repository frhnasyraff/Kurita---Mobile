/// Lifecycle of a single pallet as it moves through the loading process.
enum PalletStatus { new_, holding, loaded }

class FulfilledDeliveryItem {
  final String sku;
  final String name;
  final String quantity;
  final String pallets;

  const FulfilledDeliveryItem({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.pallets,
  });
}

class PalletItem {
  final int apiId;
  final String id;
  final String name;
  final String batch;
  final double weight;
  final String weightUnit;
  final String container;
  final int palletsRequired;
  PalletStatus status;
  int palletsScanned;
  String? scanTime;
  final String? warehouseLane;
  final String? warehouseBay;
  final String? warehouseRow;
  final String? warehouseCol;

  PalletItem({
    this.apiId = 0,
    required this.id,
    required this.name,
    required this.batch,
    required this.weight,
    required this.weightUnit,
    required this.container,
    this.palletsRequired = 1,
    this.status = PalletStatus.new_,
    this.palletsScanned = 0,
    this.scanTime,
    this.warehouseLane,
    this.warehouseBay,
    this.warehouseRow,
    this.warehouseCol,
  });

  String get statusLabel {
    switch (status) {
      case PalletStatus.new_:
        return palletsScanned == 0 ? 'NEW' : 'SCAN';
      case PalletStatus.holding:
        return 'SCANNED';
      case PalletStatus.loaded:
        return 'READY';
    }
  }
}

enum VehicleCategory { new_, inProgress, completed }

class DeliveryVehicle {
  final int jobId;
  final String id;
  final String customer;
  final String badge;
  final int palletsDone;
  final int palletsTotal;
  final VehicleCategory category;
  final List<PalletItem> pallets;
  final String bay;
  final String doNumber;
  String clientLocation;
  String packingList;
  String grossWeight;
  List<FulfilledDeliveryItem> fulfilledItems;

  DeliveryVehicle({
    this.jobId = 0,
    required this.id,
    required this.customer,
    required this.badge,
    required this.palletsDone,
    required this.palletsTotal,
    required this.category,
    required this.pallets,
    this.bay = '04',
    this.doNumber = 'D-2024-888',
    this.clientLocation = 'Shah Alam',
    this.packingList = '12',
    this.grossWeight = '4,129.45 KG',
    this.fulfilledItems = const [],
  });

  double get progress => palletsTotal == 0 ? 0 : palletsDone / palletsTotal;
}
