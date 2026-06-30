// lib/services/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);
  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient instance = ApiClient._();
  ApiClient._();

  String? _token;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> logout() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  dynamic _decode(http.Response res) {
    if (res.body.isEmpty) return {};
    return jsonDecode(res.body);
  }

  void _throwIfError(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) return;
    final body = _decode(res);
    final msg = body is Map && body['message'] != null
        ? body['message'].toString()
        : 'Request failed (${res.statusCode})';
    throw ApiException(msg, res.statusCode);
  }

  // ── AUTH ──
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
        'device_name': 'flutter-workwise',
      }),
    );
    _throwIfError(res);
    final body = _decode(res) as Map<String, dynamic>;
    await _saveToken(body['token'] as String);
    return body;
  }

  // ── RECEIVING (Dashboard) ──
  Future<Map<String, dynamic>> getReceivingSummary({
    String? date,
    String status = 'all',
    String supplier = 'all',
    String? po,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/receiving/summary')
        .replace(queryParameters: {
      if (date != null && date.isNotEmpty) 'date': date,
      if (status != 'all') 'status': status,
      if (supplier != 'all') 'supplier': supplier,
      if (po != null && po.isNotEmpty) 'po': po,
    });
    final res = await http.get(uri, headers: _headers);
    _throwIfError(res);
    return _decode(res) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getDailyStats({String? date}) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/receiving/daily-stats')
        .replace(queryParameters: {
      if (date != null && date.isNotEmpty) 'date': date,
    });
    final res = await http.get(uri, headers: _headers);
    _throwIfError(res);
    return _decode(res) as Map<String, dynamic>;
  }

  // ── INSPECTION ──
  Future<Map<String, dynamic>> getPoBatches(String poNumber) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/receiving/purchase-orders/$poNumber'),
      headers: _headers,
    );
    _throwIfError(res);
    return _decode(res) as Map<String, dynamic>;
  }

  Future<void> startInspection(int receivingOrderId) async {
    final res = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/receiving/$receivingOrderId/inspection/start'),
      headers: _headers,
    );
    _throwIfError(res);
  }

  Future<void> completeInspection(
    int receivingOrderId, {
    required double quantityKg,
    required String qcResult, // pass | fail
    String? qcRemarks,
    String? failureReason,
  }) async {
    final res = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/receiving/$receivingOrderId/inspection'),
      headers: _headers,
      body: jsonEncode({
        'quantity_received_kg': quantityKg,
        'qc_result': qcResult,
        'qc_remarks': qcRemarks,
        'failure_reason': failureReason,
      }),
    );
    _throwIfError(res);
  }

  // ── STOCK IN ──
  Future<Map<String, dynamic>> getStockIn({
    String tab = 'new',
    String search = '',
    int page = 1,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/stock-in').replace(queryParameters: {
      'tab': tab,
      if (search.isNotEmpty) 'search': search,
      'page': '$page',
    });
    final res = await http.get(uri, headers: _headers);
    _throwIfError(res);
    return _decode(res) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getWarehouseLocations() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/warehouse-locations'),
      headers: _headers,
    );
    _throwIfError(res);
    final body = _decode(res) as Map<String, dynamic>;
    return body['data'] as List<dynamic>;
  }

  Future<void> startStockIn(int receivingOrderId) async {
    final res = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/stock-in/receiving-order/$receivingOrderId/start'),
      headers: _headers,
    );
    _throwIfError(res);
  }

  /// Submits the stock-in confirmation step (quantity + UHF scan + approval).
  ///
  /// `warehouseLocationId` is now OPTIONAL — at this stage (Confirm Stock In
  /// page) the material hasn't been assigned a rack/location yet. Location
  /// assignment happens afterwards on the Stock In Progress screen, via
  /// [setWarehouseLocation], once the user scans the QR location for that
  /// material. When `warehouseLocationId` is null, the field is omitted from
  /// the request body entirely so the backend can treat it as "no location"
  /// rather than receiving an explicit zero/placeholder value.
  Future<void> submitStockIn(
    int receivingOrderId, {
    required double quantityKg,
    int? warehouseLocationId,
    bool labelingVerified = false,
    bool scannerLinked = false,
    String? rfidTag,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/stock-in/receiving-order/$receivingOrderId'),
      headers: _headers,
      body: jsonEncode({
        'quantity_kg': quantityKg,
        if (warehouseLocationId != null) 'warehouse_location_id': warehouseLocationId,
        'labeling_verified': labelingVerified,
        'scanner_linked': scannerLinked,
        if (rfidTag != null) 'rfid_tag': rfidTag,
      }),
    );
    _throwIfError(res);
  }

  /// Assigns/updates the warehouse location for a receiving order that has
  /// already been submitted via [submitStockIn] without a location.
  ///
  /// Called from the Stock In Progress detail screen after the user scans
  /// the QR code for a rack/location (e.g. "SCAN QR LOCATION" button).
  Future<void> setWarehouseLocation(
    int receivingOrderId, {
    required int warehouseLocationId,
  }) async {
    final res = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/stock-in/receiving-order/$receivingOrderId/location'),
      headers: _headers,
      body: jsonEncode({
        'warehouse_location_id': warehouseLocationId,
      }),
    );
    _throwIfError(res);
  }

  /// Fetches the per-PO progress payload for the Stock In Progress detail
  /// screen: PO/supplier header, completion percentage, and one entry per
  /// material with its rack/qty/UHF-link/status.
  Future<Map<String, dynamic>> getStockInProgress(String poNumber) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/stock-in/purchase-orders/$poNumber/progress'),
      headers: _headers,
    );
    _throwIfError(res);
    final body = _decode(res) as Map<String, dynamic>;
    return body['data'] as Map<String, dynamic>;
  }

  // ── PRODUCT STOCK IN ──

  /// Fetches production jobs that are completed, fully QC-passed, and
  /// not yet stocked in. Used to populate the Product Stock In pending list.
  Future<List<dynamic>> getPendingProductStockIn() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/product-stock-in/pending'),
      headers: _headers,
    );
    _throwIfError(res);
    final body = _decode(res) as Map<String, dynamic>;
    return body['data'] as List<dynamic>;
  }

  /// Submits a Product Stock In for a QC-passed production job.
  /// Backend creates the StockLot + an IN StockMovement linked to the job.
  Future<Map<String, dynamic>> submitProductStockIn({
    required int productionJobId,
    required int warehouseLocationId,
    required double quantityKg,
    String? batchNumber,
    String? manufacturingDate,
    String? expiryDate,
    String? rfidTag,
    String? palletCode,
    String? notes,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/product-stock-in'),
      headers: _headers,
      body: jsonEncode({
        'production_job_id': productionJobId,
        'warehouse_location_id': warehouseLocationId,
        'quantity_kg': quantityKg,
        if (batchNumber != null) 'batch_number': batchNumber,
        if (manufacturingDate != null) 'manufacturing_date': manufacturingDate,
        if (expiryDate != null) 'expiry_date': expiryDate,
        if (rfidTag != null) 'rfid_tag': rfidTag,
        if (palletCode != null) 'pallet_code': palletCode,
        if (notes != null) 'notes': notes,
      }),
    );
    _throwIfError(res);
    return _decode(res) as Map<String, dynamic>;
  }
}