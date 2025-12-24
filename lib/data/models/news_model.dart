class NewsModel {
  final String title;
  final String description;
  final String url;
  final String? urlToImage;
  final DateTime publishedAt;
  final String content;
  final String? source;
  final String? author;

  NewsModel({
    required this.title,
    required this.description,
    required this.url,
    this.urlToImage,
    required this.publishedAt,
    required this.content,
    this.source,
    this.author,
  });

  // Untuk mengubah JSON dari API menjadi Objek Dart
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? json['content'] ?? 'No Description',
      url: json['link'] ?? '', 
      urlToImage: json['image_url'], 
      publishedAt: json['pubDate'] != null 
          ? DateTime.parse(json['pubDate']) 
          : DateTime.now(),
      content: json['content'] ?? json['description'] ?? '',
      source: json['source_id'] ?? 'News',
      author: (json['creator'] as List?)?.first?.toString() ?? 'Unknown',
    );
  }

  // TAMBAHKAN INI: Untuk mengubah Objek Dart menjadi JSON (Simpan ke Local Storage)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'link': url, // Gunakan key 'link' agar konsisten dengan fromJson
      'image_url': urlToImage,
      'pubDate': publishedAt.toIso8601String(),
      'content': content,
      'source_id': source,
      'creator': [author], // Simpan sebagai list agar konsisten dengan API
    };
  }
}