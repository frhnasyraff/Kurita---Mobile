import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DeliveryOverviewResponse {
  const DeliveryOverviewResponse({
    required this.stats,
    required this.jobs,
  });

  factory DeliveryOverviewResponse.fromJson(Map<String, dynamic> json) {
    final statsJson = json['stats'] as Map<String, dynamic>? ?? const {};
    final jobsJson = json['jobs'] as List<dynamic>? ?? const [];

    return DeliveryOverviewResponse(
      stats: DeliveryOverviewStats.fromJson(statsJson),
      jobs: jobsJson
          .whereType<Map<String, dynamic>>()
          .map(DeliveryOverviewJobSummary.fromJson)
          .toList(growable: false),
    );
  }

  final DeliveryOverviewStats stats;
  final List<DeliveryOverviewJobSummary> jobs;
}

class DeliveryOverviewStats {
  const DeliveryOverviewStats({
    required this.vehicleInBay,
    required this.vehicleInProgress,
    required this.vehicleCompleted,
    required this.palletsInHolding,
  });

  factory DeliveryOverviewStats.fromJson(Map<String, dynamic> json) {
    return DeliveryOverviewStats(
      vehicleInBay: _asInt(json['vehicle_in_bay']),
      vehicleInProgress: _asInt(json['vehicle_in_progress']),
      vehicleCompleted: _asInt(json['vehicle_completed']),
      palletsInHolding: _asInt(json['pallets_in_holding']),
    );
  }

  final int vehicleInBay;
  final int vehicleInProgress;
  final int vehicleCompleted;
  final int palletsInHolding;
}

class DeliveryOverviewJobSummary {
  const DeliveryOverviewJobSummary({
    required this.id,
    required this.vehicleId,
    required this.customer,
    required this.status,
    required this.progressCurrent,
    required this.progressTotal,
  });

  factory DeliveryOverviewJobSummary.fromJson(Map<String, dynamic> json) {
    return DeliveryOverviewJobSummary(
      id: _asInt(json['id']),
      vehicleId: '${json['vehicle_id'] ?? ''}',
      customer: '${json['customer'] ?? ''}',
      status: '${json['status'] ?? ''}',
      progressCurrent: _asInt(json['progress_current']),
      progressTotal: _asInt(json['progress_total']),
    );
  }

  final int id;
  final String vehicleId;
  final String customer;
  final String status;
  final int progressCurrent;
  final int progressTotal;
}

class DeliveryJobDetailResponse {
  const DeliveryJobDetailResponse({
    required this.id,
    required this.vehicleId,
    required this.bay,
    required this.customer,
    required this.doNumber,
    required this.totalPallets,
    required this.packingList,
    required this.progressCurrent,
    required this.progressTotal,
  });

  factory DeliveryJobDetailResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryJobDetailResponse(
      id: _asInt(json['id']),
      vehicleId: '${json['vehicle_id'] ?? ''}',
      bay: '${json['bay'] ?? ''}',
      customer: '${json['customer'] ?? ''}',
      doNumber: '${json['do_number'] ?? ''}',
      totalPallets: '${json['total_pallets'] ?? ''}',
      packingList: '${json['packing_list'] ?? ''}',
      progressCurrent: _asInt(json['progress_current']),
      progressTotal: _asInt(json['progress_total']),
    );
  }

  final int id;
  final String vehicleId;
  final String bay;
  final String customer;
  final String doNumber;
  final String totalPallets;
  final String packingList;
  final int progressCurrent;
  final int progressTotal;
}

class DeliveryPalletSummaryResponse {
  const DeliveryPalletSummaryResponse({
    required this.id,
    required this.code,
    required this.name,
    required this.meta,
    required this.stage,
    required this.badge,
    required this.progressCurrent,
    required this.progressTotal,
    required this.timestamp,
    required this.canScan,
  });

  factory DeliveryPalletSummaryResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryPalletSummaryResponse(
      id: _asInt(json['id']),
      code: '${json['code'] ?? ''}',
      name: '${json['name'] ?? ''}',
      meta: '${json['meta'] ?? ''}',
      stage: '${json['stage'] ?? ''}',
      badge: '${json['badge'] ?? ''}',
      progressCurrent: _asInt(json['progress_current']),
      progressTotal: _asInt(json['progress_total']),
      timestamp: json['timestamp'] == null ? null : '${json['timestamp']}',
      canScan: json['can_scan'] == true,
    );
  }

  final int id;
  final String code;
  final String name;
  final String meta;
  final String stage;
  final String badge;
  final int progressCurrent;
  final int progressTotal;
  final String? timestamp;
  final bool canScan;
}

class DeliveryPalletDetailResponse {
  const DeliveryPalletDetailResponse({
    required this.id,
    required this.name,
    required this.batch,
    required this.netWeight,
    required this.containerType,
    required this.lifecycleStatus,
    required this.zone,
    required this.rack,
    required this.level,
    required this.bay,
  });

  factory DeliveryPalletDetailResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryPalletDetailResponse(
      id: _asInt(json['id']),
      name: '${json['name'] ?? ''}',
      batch: '${json['batch'] ?? ''}',
      netWeight: '${json['net_weight'] ?? ''}',
      containerType: '${json['container_type'] ?? ''}',
      lifecycleStatus: '${json['lifecycle_status'] ?? ''}',
      zone: '${json['zone'] ?? ''}',
      rack: '${json['rack'] ?? ''}',
      level: '${json['level'] ?? ''}',
      bay: '${json['bay'] ?? ''}',
    );
  }

  final int id;
  final String name;
  final String batch;
  final String netWeight;
  final String containerType;
  final String lifecycleStatus;
  final String zone;
  final String rack;
  final String level;
  final String bay;
}

class DeliveryPackingSummaryItemResponse {
  const DeliveryPackingSummaryItemResponse({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.pallets,
  });

  factory DeliveryPackingSummaryItemResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryPackingSummaryItemResponse(
      sku: '${json['sku'] ?? ''}',
      name: '${json['name'] ?? ''}',
      quantity: '${json['quantity'] ?? ''}',
      pallets: '${json['pallets'] ?? ''}',
    );
  }

  final String sku;
  final String name;
  final String quantity;
  final String pallets;
}

class DeliveryPackingSummaryResponse {
  const DeliveryPackingSummaryResponse({
    required this.clientName,
    required this.clientLocation,
    required this.totalPallets,
    required this.packingList,
    required this.grossWeight,
    required this.items,
  });

  factory DeliveryPackingSummaryResponse.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? const [];
    return DeliveryPackingSummaryResponse(
      clientName: '${json['client_name'] ?? ''}',
      clientLocation: '${json['client_location'] ?? ''}',
      totalPallets: '${json['total_pallets'] ?? ''}',
      packingList: '${json['packing_list'] ?? ''}',
      grossWeight: '${json['gross_weight'] ?? ''}',
      items: itemsJson
          .whereType<Map<String, dynamic>>()
          .map(DeliveryPackingSummaryItemResponse.fromJson)
          .toList(growable: false),
    );
  }

  final String clientName;
  final String clientLocation;
  final String totalPallets;
  final String packingList;
  final String grossWeight;
  final List<DeliveryPackingSummaryItemResponse> items;
}

class DeliveryApiService {
  DeliveryApiService({String? baseUrl}) : _baseUrl = baseUrl ?? _defaultBaseUrl;

  final String _baseUrl;

  static String get _defaultBaseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api';
    }
    return 'http://127.0.0.1:8000/api';
  }

  Future<DeliveryOverviewResponse> fetchOverview() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/delivery/overview'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load delivery overview (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid delivery overview response');
    }

    return DeliveryOverviewResponse.fromJson(decoded);
  }

  Future<DeliveryJobDetailResponse> fetchJobDetail(int jobId) async {
    final decoded = await _getJson('/delivery/jobs/$jobId');
    return DeliveryJobDetailResponse.fromJson(decoded);
  }

  Future<List<DeliveryPalletSummaryResponse>> fetchPallets(int jobId) async {
    final decoded = await _getJson('/delivery/jobs/$jobId/pallets');
    final items = decoded['items'] as List<dynamic>? ?? const [];
    return items
        .whereType<Map<String, dynamic>>()
        .map(DeliveryPalletSummaryResponse.fromJson)
        .toList(growable: false);
  }

  Future<DeliveryPalletDetailResponse> fetchPalletDetail(int palletId) async {
    final decoded = await _getJson('/delivery/pallets/$palletId');
    return DeliveryPalletDetailResponse.fromJson(decoded);
  }

  Future<DeliveryPackingSummaryResponse> fetchPackingSummary(int jobId) async {
    final decoded = await _getJson('/delivery/jobs/$jobId/packing-summary');
    return DeliveryPackingSummaryResponse.fromJson(decoded);
  }

  Future<void> scanPallet(int palletId) async {
    await _post('/delivery/pallets/$palletId/scan');
  }

  Future<void> confirmLoaded(int jobId) async {
    await _post('/delivery/jobs/$jobId/confirm-loaded');
  }

  Future<void> submitDelivery(int jobId) async {
    await _post('/delivery/jobs/$jobId/submit');
  }

  Future<Map<String, dynamic>> _getJson(String path) async {
    final response = await http.get(
      Uri.parse('$_baseUrl$path'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load $path (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid response for $path');
    }
    return decoded;
  }

  Future<void> _post(String path) async {
    final response = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: const {'Accept': 'application/json'},
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Request failed for $path (${response.statusCode})');
    }
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? 0;
}
