import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:news_reader/data/models/news_model.dart';
import 'package:news_reader/presentation/providers/news_provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsModel news;

  const NewsDetailScreen({Key? key, required this.news}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Membuat AppBar transparan di atas gambar
      extendBodyBehindAppBar: true,
      appBar: AppBar(
  backgroundColor: Colors.transparent,
  elevation: 0,
  leading: Container(
    margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.4),
      shape: BoxShape.circle,
    ),
    child: IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () => Navigator.pop(context),
    ),
  ),
  actions: [
    // --- TOMBOL SHARE (FITUR BONUS) ---
    Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.share, color: Colors.white, size: 20),
        onPressed: () {
          // Menggunakan link berita asli untuk dibagikan
          Share.share(
            'Baca berita menarik ini: ${news.title}\n\nSelengkapnya di: ${news.url}',
            subject: 'Berita dari ${news.source}',
          );
        },
      ),
    ),

    // --- TOMBOL BOOKMARK (YANG SUDAH ADA) ---
    Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
      child: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          final isBookmarked = newsProvider.isBookmarked(news);
          return IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.blue : Colors.white,
            ),
            onPressed: () {
              newsProvider.toggleBookmark(news);
            },
          );
        },
      ),
    ),
    const SizedBox(width: 8),
  ],
),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Image dengan Hero Animation
            Hero(
              tag: news.url, // Tag harus sama dengan yang ada di NewsItem
              child: news.urlToImage != null && news.urlToImage!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: news.urlToImage!,
                      height: 400,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        height: 400,
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 64),
                      ),
                    )
                  : Container(
                      height: 400,
                      color: Colors.grey[300],
                      child: const Icon(Icons.article, size: 64),
                    ),
            ),

            // 2. Content Container (Overlapping)
            Transform.translate(
              offset: const Offset(0, -40), // Menaikkan konten ke atas gambar
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge Source & Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            news.source ?? 'General',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy').format(news.publishedAt),
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      news.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Author
                    if (news.author != null && news.author!.isNotEmpty)
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.blue,
                            child: Icon(Icons.person, size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'By ${news.author}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Divider(),
                    ),

                    // Content Body
                    Text(
                      news.content.isNotEmpty ? news.content : news.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 40),

                    // Read More Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _launchURL(news.url),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Read Full Article',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}