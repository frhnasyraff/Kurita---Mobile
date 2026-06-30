import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';
import '../models/stock_in_card.dart';

class StockInService {
  /// Fetch a page of stock-in cards, optionally filtered by tab and search text.
  ///
  /// [tab] should be one of: 'new', 'in_progress', 'complete' — pass null
  /// to get the combined new+in_progress set (matches backend default).
  static Future<Map<String, dynamic>> fetchList({
    String? tab,
    String? search,
    int page = 1,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {"success": false, "message": "Not logged in"};
    }

    final queryParams = <String, String>{
      'page': page.toString(),
      if (tab != null) 'tab': tab,
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final uri = Uri.parse(ApiConfig.stockInUrl).replace(queryParameters: queryParams);

    try {
      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "result": StockInListResponse.fromJson(data as Map<String, dynamic>),
        };
      } else {
        final message = data["message"] ?? "Failed to load stock-in list";
        return {"success": false, "message": message};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  /// Fetch a single stock-in record's detail.
  /// [source] must be 'receiving_order' or 'rm_stock_in_record' — use
  /// StockInCard.source from the list response.
  static Future<Map<String, dynamic>> fetchOne(String source, int id) async {
    final token = await AuthService.getToken();
    if (token == null) {
      return {"success": false, "message": "Not logged in"};
    }

    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.stockInUrl}/$source/$id"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          "success": true,
          "result": StockInCard.fromJson(data["data"] as Map<String, dynamic>),
        };
      } else {
        final message = data["message"] ?? "Failed to load stock-in record";
        return {"success": false, "message": message};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }
}