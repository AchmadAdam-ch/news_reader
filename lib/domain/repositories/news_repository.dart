import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:news_reader/data/models/news_model.dart';
import 'package:news_reader/core/exceptions/news_exceptions.dart';
import 'package:news_reader/data/datasources/news_remote_data_source.dart';

abstract class NewsRepository {
  Future<List<NewsModel>> getTopHeadlines();
  Future<List<NewsModel>> getNewsByCategory(String category);
  Future<List<NewsModel>> searchNews(String query);
  Future<List<NewsModel>> getBookmarkedNews();
  Future<void> bookmarkNews(NewsModel news);
  Future<void> removeBookmark(NewsModel news);
  bool isBookmarked(NewsModel news);
}

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;
  List<NewsModel> _bookmarks = [];
  final String _bookmarkKey = 'news_bookmarks';

  NewsRepositoryImpl({required this.remoteDataSource});

  // Load bookmarks from SharedPreferences
  Future<void> _loadBookmarksFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_bookmarkKey);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _bookmarks = jsonList.map((e) => NewsModel.fromJson(e)).toList();
    }
  }

  // Save bookmarks to SharedPreferences
  Future<void> _saveBookmarksToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_bookmarks.map((e) => e.toJson()).toList());
    await prefs.setString(_bookmarkKey, jsonString);
  }

  @override
  Future<List<NewsModel>> getTopHeadlines() async {
    try {
      return await remoteDataSource.getNewsByCategory('all');
    } catch (e) {
      throw NewsException('Failed to get top headlines: $e');
    }
  }

  @override
  Future<List<NewsModel>> getNewsByCategory(String category) async {
    try {
      return await remoteDataSource.getNewsByCategory(category);
    } catch (e) {
      throw NewsException('Failed to get news by category: $e');
    }
  }

  @override
  Future<List<NewsModel>> searchNews(String query) async {
    try {
      if (query.isEmpty) return await getTopHeadlines();
      return await remoteDataSource.searchNews(query);
    } catch (e) {
      throw NewsException('Failed to search news: $e');
    }
  }

  @override
  Future<List<NewsModel>> getBookmarkedNews() async {
    if (_bookmarks.isEmpty) {
      await _loadBookmarksFromPrefs();
    }
    return _bookmarks;
  }

  @override
  Future<void> bookmarkNews(NewsModel news) async {
    if (!_bookmarks.any((item) => item.url == news.url)) {
      _bookmarks.add(news);
      await _saveBookmarksToPrefs();
    }
  }

  @override
  Future<void> removeBookmark(NewsModel news) async {
    _bookmarks.removeWhere((item) => item.url == news.url);
    await _saveBookmarksToPrefs();
  }

  @override
  bool isBookmarked(NewsModel news) {
    return _bookmarks.any((item) => item.url == news.url);
  }
}