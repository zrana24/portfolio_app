class ApiUrls {
  static const String baseUrl = "https://cebecikiymetlimadenler.com/api/v1";

  static const String register = "$baseUrl/auth/register";
  static const String login = "$baseUrl/auth/login";
  static const String logout = "$baseUrl/auth/logout";
  static const String me = "$baseUrl/auth/me";
  static const String getProfile = '$baseUrl/auth/me';
  static const String updateProfile = '$baseUrl/auth/me';
  static const String changePassword = '$baseUrl/auth/change-password';

  static const String deleteAccount = '$baseUrl/auth/account';

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

  static const String mobileNews = "$baseUrl/mobile/news";
  static const String mobileTrending = "$baseUrl/mobile/news/trending";
  static String mobileNewsDetail(int id) => "$baseUrl/mobile/news/$id";
  static const String news = "$baseUrl/news";
  static String newsDetail(int id) => "$baseUrl/news/$id";
}