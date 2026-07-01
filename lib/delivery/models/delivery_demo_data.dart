import 'delivery_models.dart';

/// Static demo dataset matching the mockups. The BPL-1982 vehicle carries
/// the full pallet list used by the Pallet Loading / Pallet Details screens.
List<DeliveryVehicle> buildDemoVehicles() {
  final bpl1982Pallets = [
    PalletItem(
      id: '#B-2024-501',
      name: 'Industrial Disinfectant X1',
      batch: '#B-2024-501',
      weight: 500,
      weightUnit: 'KG',
      container: 'IBC Tank',
      palletsRequired: 5,
      warehouseLane: '04',
      warehouseBay: 'R-12',
      warehouseRow: '03',
      warehouseCol: '04',
    ),
    PalletItem(
      id: '#B-2024-502',
      name: 'Corrosive Compound B-4',
      batch: '#B-2024-502',
      weight: 250,
      weightUnit: 'KG',
      container: 'Steel Drum',
      palletsRequired: 2,
      warehouseLane: '02',
      warehouseBay: 'R-08',
      warehouseRow: '01',
      warehouseCol: '02',
    ),
    PalletItem(
      id: '#B-2024-509',
      name: 'Caustic Soda',
      batch: '#B-2024-509',
      weight: 25,
      weightUnit: 'KG',
      container: 'Poly Bag',
      palletsRequired: 1,
    ),
    PalletItem(
      id: '#B-2024-503',
      name: 'Sulfuric Acid',
      batch: '#B-2024-503',
      weight: 1000,
      weightUnit: 'KG',
      container: 'IBC Tank',
      palletsRequired: 3,
    ),
    PalletItem(
      id: '#B-2024-504',
      name: 'Ethanol',
      batch: '#B-2024-504',
      weight: 200,
      weightUnit: 'L',
      container: 'Steel Drum',
      palletsRequired: 1,
    ),
    PalletItem(
      id: '#B-2024-505',
      name: 'Nitric Acid',
      batch: '#B-2024-505',
      weight: 500,
      weightUnit: 'KG',
      container: 'IBC Tank',
      palletsRequired: 1,
    ),
  ];

  return [
    DeliveryVehicle(
      id: 'BPL 1982',
      customer: 'Global Logistics',
      badge: 'READY TO LOAD',
      palletsDone: 12,
      palletsTotal: 15,
      category: VehicleCategory.new_,
      pallets: bpl1982Pallets,
    ),
    DeliveryVehicle(
      id: 'BPL 6104',
      customer: 'Metro Distribution',
      badge: 'IN PROGRESS',
      palletsDone: 4,
      palletsTotal: 18,
      category: VehicleCategory.inProgress,
      pallets: [],
    ),
    DeliveryVehicle(
      id: 'BPL 9072',
      customer: 'Precision Parts Co.',
      badge: 'READY TO LOAD',
      palletsDone: 15,
      palletsTotal: 15,
      category: VehicleCategory.new_,
      pallets: [],
    ),
    DeliveryVehicle(
      id: 'BPL 2287',
      customer: 'Apex Manufacturing',
      badge: 'LOADING',
      palletsDone: 9,
      palletsTotal: 12,
      category: VehicleCategory.inProgress,
      pallets: [],
    ),
  ];
}

