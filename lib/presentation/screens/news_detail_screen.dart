import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:news_reader/data/models/news_model.dart';
import 'package:news_reader/presentation/providers/news_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class NewsDetailScreen extends StatelessWidget {
  final NewsModel news;

  const NewsDetailScreen({Key? key, required this.news}) : super(key: key);

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cek Dark Mode
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      // 1. Ganti SliverAppBar dengan AppBar biasa agar lebih bersih di Web
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: isDark ? Colors.white : Colors.black),
            onPressed: () {
              Share.share('Check out: ${news.title}\n${news.url}');
            },
          ),
          Consumer<NewsProvider>(
            builder: (context, provider, child) {
              final isBookmarked = provider.isBookmarked(news);
              return IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.blue : (isDark ? Colors.white : Colors.black),
                ),
                onPressed: () => provider.toggleBookmark(news),
              );
            },
          ),
        ],
      ),
      // 2. Center & ConstrainedBox agar konten tidak melebar ke seluruh layar monitor
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // Batas lebar konten (seperti Medium/Blog)
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3. Metadata (Category/Source)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        news.source?.toUpperCase() ?? 'NEWS',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      DateFormat('MMM dd, yyyy').format(news.publishedAt),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 4. Judul Besar
                Text(
                  news.title,
                  style: TextStyle(
                    fontSize: 28, // Font lebih besar untuk judul
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 24),

                // 5. GAMBAR FIXED ASPECT RATIO (16:9)
                // Ini solusi agar gambar tidak terpotong kepalanya
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 16 / 9, // Rasio standar video/berita
                    child: Hero(
                      tag: news.url,
                      child: CachedNetworkImage(
                        imageUrl: news.urlToImage ?? '',
                        fit: BoxFit.cover, // Cover tetap mengisi, tapi karena rasionya 16:9, ia akan pas
                        placeholder: (context, url) => Container(color: Colors.grey[200]),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Caption Penulis
                if (news.author != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'By ${news.author}',
                    style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ],

                const SizedBox(height: 32),

                // 6. Isi Berita
                Text(
                  news.content.isNotEmpty ? news.content : news.description,
                  style: TextStyle(
                    fontSize: 18, // Font body lebih enak dibaca
                    height: 1.8,  // Spasi antar baris lebih renggang
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 40),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 20),

                // 7. Tombol Read Full Article
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchUrl(news.url),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text("Read Full Article on Source"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}