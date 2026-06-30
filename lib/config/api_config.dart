/// API configuration — single source of truth for the base URL.
/// Change this when moving from local dev to staging/production.
class ApiConfig {
  // ── Local development (physical phone + laptop on same WiFi) ──
  static const baseUrl = 'http://192.168.100.55/kurita/public/api';

  // ── When deployed later, swap to something like: ──
  // static const String baseUrl = "https://kurita.workwise.com/api";

  static const String loginUrl = "$baseUrl/login";
  static const String logoutUrl = "$baseUrl/logout";
  static const String userUrl = "$baseUrl/user";
  static const String stockInUrl = "$baseUrl/stock-in";

}