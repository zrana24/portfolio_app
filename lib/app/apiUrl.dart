class ApiUrls {
  static const String baseUrl = "https://cebecikiymetlimadenler.com/api/v1";

  static const String register = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";
  static const String logout = "$baseUrl/auth/logout";
  static const String me = "$baseUrl/auth/me";
  static const String changePassword = "$baseUrl/auth/change-password";

  static const String prices = "$baseUrl/prices";
  static const String symbols = "$baseUrl/symbols";
  static String priceDetail(String symbol) => "$baseUrl/prices/$symbol";

  static const String portfolios = "$baseUrl/portfolios";
  static const String portfolioSummary = "$baseUrl/portfolios/summary";

  static String portfolioDetail(int id) => "$baseUrl/portfolios/$id";
  static String portfolioAssets(int id) => "$baseUrl/portfolios/$id/assets";
  static String portfolioAssetDetail(int portfolioId, int assetId) =>
      "$baseUrl/portfolios/$portfolioId/assets/$assetId";

  static const String favorites = "$baseUrl/favorites";
  static String favoriteDetail(String symbol) => "$baseUrl/favorites/$symbol";

  static const String news = "$baseUrl/news";
  static String newsDetail(int id) => "$baseUrl/news/$id";

  static const String adminDashboard = "$baseUrl/admin/dashboard";
  static const String adminUsers = "$baseUrl/admin/users";
  static String adminUserDetail(int id) => "$baseUrl/admin/users/$id";
  static String adminBlockUser(int id) => "$baseUrl/admin/users/$id/block";

  static const String adminMargins = "$baseUrl/admin/margins";
  static const String adminVisibility = "$baseUrl/admin/visibility";
  static const String adminSymbolOrder = "$baseUrl/admin/symbol-order";

  static const String adminAnalyticsUsers = "$baseUrl/admin/analytics/users";
  static const String adminAnalyticsPortfolios = "$baseUrl/admin/analytics/portfolios";
  static const String adminAnalyticsPrices = "$baseUrl/admin/analytics/prices";
  static const String adminAnalyticsSystem = "$baseUrl/admin/analytics/system";
}