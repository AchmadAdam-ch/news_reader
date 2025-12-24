import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:news_reader/presentation/providers/news_provider.dart';
import 'package:news_reader/presentation/widgets/news_item.dart';
import 'package:news_reader/presentation/screens/news_detail_screen.dart';
import 'package:news_reader/core/constants/api_constants.dart';
import 'package:news_reader/presentation/screens/bookmark_screen.dart';

class NewsListScreen extends StatefulWidget {
  const NewsListScreen({Key? key}) : super(key: key);

  @override
  State<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends State<NewsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NewsProvider>().loadTopHeadlines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BookmarkScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
  padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
  child: TextField(
    controller: _searchController,
    decoration: InputDecoration(
      hintText: 'Search news...',
      prefixIcon: const Icon(Icons.search, color: Colors.blue),
      filled: true,
      fillColor: Theme.of(context).cardColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      // Border membulat sempurna (Capsule style)
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: Colors.blue, width: 1),
      ),
    ),
    onSubmitted: (value) {
      if (value.isNotEmpty) {
        context.read<NewsProvider>().searchNews(value);
      }
    },
  ),
),

          SizedBox(
  height: 50,
  child: ListView.builder(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    itemCount: AppConstants.categories.length,
    itemBuilder: (context, index) {
      final category = AppConstants.categories[index];
      final isSelected = context.watch<NewsProvider>().selectedCategory == category;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ChoiceChip(
          label: Text(
            // Format teks jadi Capital Case (misal: 'business' -> 'Business')
            category[0].toUpperCase() + category.substring(1),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              context.read<NewsProvider>().setCategory(category);
            }
          },
          // Styling Chip agar lebih elegan
          selectedColor: Colors.blue,
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          side: BorderSide.none,
          showCheckmark: false, // Hilangkan centang agar lebih bersih
          elevation: isSelected ? 4 : 0,
        ),
      );
    },
  ),
),

          // News List
          Expanded(
            child: _buildNewsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = AppConstants.categories;
    
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        return SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = newsProvider.selectedCategory == category;
              
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(
                    category[0].toUpperCase() + category.substring(1),
                    style: TextStyle(
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      newsProvider.loadNewsByCategory(category);
                    }
                  },
                  backgroundColor: Colors.grey[300],
                  selectedColor: Colors.blue,
                  checkmarkColor: Colors.white,
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildNewsList() {
    return Consumer<NewsProvider>(
      builder: (context, newsProvider, child) {
        // Loading State
        if (newsProvider.isLoading && newsProvider.news.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error State
        if (newsProvider.hasError && newsProvider.news.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  newsProvider.errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: newsProvider.loadTopHeadlines,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Empty State
        if (newsProvider.news.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No news found',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Success State
        return RefreshIndicator(
          onRefresh: () => newsProvider.loadTopHeadlines(),
          child: ListView.builder(
            itemCount: newsProvider.news.length,
            itemBuilder: (context, index) {
              final news = newsProvider.news[index];
              final isBookmarked = newsProvider.isBookmarked(news);
              
              return NewsItem(
                news: news,
                isBookmarked: isBookmarked,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewsDetailScreen(news: news),
                    ),
                  );
                },
                onBookmark: () {
                  newsProvider.toggleBookmark(news);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
