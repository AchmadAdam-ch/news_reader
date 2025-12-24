import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// Import Core & Theme
import 'package:news_reader/core/constants/api_constants.dart';
import 'package:news_reader/core/themes/app_theme.dart'; // PASTIKAN IMPORT INI ADA

// Import Data & Domain
import 'package:news_reader/data/datasources/news_remote_data_source.dart';
import 'package:news_reader/domain/repositories/news_repository.dart';

// Import Presentation
import 'package:news_reader/presentation/providers/news_provider.dart';
import 'package:news_reader/presentation/screens/news_list_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // HAPUS kata 'const' di depan MyApp() karena Provider bersifat dinamis
  runApp(MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NewsRemoteDataSource>(
          create: (_) => NewsRemoteDataSource(client: http.Client()),
        ),
        Provider<NewsRepository>(
          create: (context) => NewsRepositoryImpl(
            remoteDataSource: context.read<NewsRemoteDataSource>(),
          ),
        ),
        ChangeNotifierProvider<NewsProvider>(
          create: (context) => NewsProvider(
            newsRepository: context.read<NewsRepository>(),
          )..loadBookmarks(),
        ),
      ],
      child: MaterialApp(
        title: 'News Reader',
        debugShowCheckedModeBanner: false,
        
        // GUNAKAN INI SAJA:
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme, // Bonus: Aktifkan Dark Mode
        themeMode: ThemeMode.system,   // Otomatis ganti sesuai setting HP
        
        home: const NewsListScreen(),
      ),
    );
  }
}