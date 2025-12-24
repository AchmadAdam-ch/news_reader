import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_reader/core/constants/api_constants.dart';
import 'package:news_reader/data/models/news_model.dart';
import 'package:news_reader/core/exceptions/news_exceptions.dart'; 

class NewsRemoteDataSource {
  final http.Client client;

  NewsRemoteDataSource({required this.client});

  Future<List<NewsModel>> getTopHeadlines() async {
    final url = '${ApiConstants.newsDataBaseUrl}?apikey=${ApiConstants.newsDataApiKey}&country=${AppConstants.defaultCountry}';
    return _fetchNews(url);
  }

  Future<List<NewsModel>> getNewsByCategory(String category) async {
    // NewsData.io: category 'top' adalah default
    final categoryParam = (category == 'all' || category == 'top') ? '' : '&category=$category';
    final url = '${ApiConstants.newsDataBaseUrl}?apikey=${ApiConstants.newsDataApiKey}&country=${AppConstants.defaultCountry}$categoryParam';
    return _fetchNews(url);
  }

  Future<List<NewsModel>> searchNews(String query) async {
    final url = '${ApiConstants.newsDataBaseUrl}?apikey=${ApiConstants.newsDataApiKey}&q=$query';
    return _fetchNews(url);
  }

  Future<List<NewsModel>> _fetchNews(String url) async {
    try {
      final response = await client.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['results'] ?? [];
        return results.map((article) => NewsModel.fromJson(article)).toList();
      } else {
        // Ganti NewsException jika di file kamu namanya berbeda
        throw NewsException('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw NewsException('Network error: $e');
    }
  }
}