class ApiConstants {
  // NewsData.io API
  static const String newsDataBaseUrl = 'https://newsdata.io/api/1/latest'; // Tambahkan /latest
  static const String newsDataApiKey = 'pub_274272f6b1e4442895286b2d13b34c49';
  
  // Inshorts (Simpan sebagai cadangan saja)
  static const String inshortsBaseUrl = 'https://inshortsapi.vercel.app';
}

class AppConstants {
  static const String appName = 'News Reader';
  static const String defaultCountry = 'id'; // NewsData.io menggunakan kode negara 2 digit
  static const List<String> categories = [
    'top', // Ganti 'all' menjadi 'top' untuk NewsData.io
    'business',
    'entertainment',
    'health',
    'science',
    'sports',
    'technology',
    'world',
  ];
}