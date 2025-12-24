import 'package:flutter/material.dart';
import 'package:news_reader/data/models/news_model.dart';
import 'package:news_reader/domain/repositories/news_repository.dart';

class NewsProvider with ChangeNotifier {
  final NewsRepository newsRepository;

  NewsProvider({required this.newsRepository});

  List<NewsModel> _news = [];
  List<NewsModel> _bookmarks = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedCategory = 'top';

  // Getters
  List<NewsModel> get news => _news;
  List<NewsModel> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedCategory => _selectedCategory;
  
  // FIX: Tambahkan getter hasError yang diminta UI
  bool get hasError => _errorMessage.isNotEmpty;

  // FIX: Ubah fetchTopHeadlines menjadi loadTopHeadlines
  Future<void> loadTopHeadlines() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _news = await newsRepository.getTopHeadlines();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FIX: Ubah fetchNewsByCategory menjadi loadNewsByCategory
  Future<void> loadNewsByCategory(String category) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _news = await newsRepository.getNewsByCategory(category);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Metode pembantu untuk UI Category Chip
  Future<void> setCategory(String category) async {
    _selectedCategory = category;
    notifyListeners();
    await loadNewsByCategory(category);
  }

  Future<void> searchNews(String query) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _news = await newsRepository.searchNews(query);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FIX: Tambahkan loadBookmarks yang diminta UI/Main
  Future<void> loadBookmarks() async {
    // Jika repository punya fungsi ambil data lokal, panggil di sini
    // Untuk sekarang kita asumsikan data sudah ada di variabel _bookmarks
    notifyListeners();
  }

  bool isBookmarked(NewsModel article) {
    return _bookmarks.any((item) => item.url == article.url);
  }

  void toggleBookmark(NewsModel article) {
    if (isBookmarked(article)) {
      _bookmarks.removeWhere((item) => item.url == article.url);
    } else {
      _bookmarks.add(article);
    }
    notifyListeners();
  }
}