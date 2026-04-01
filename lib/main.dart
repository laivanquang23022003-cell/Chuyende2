import 'package:flutter/material.dart';
import 'core/di/injection.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() async {
  // Đảm bảo Flutter framework được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Dependency Injection
  await di.init();
  
  runApp(const MangaApp());
}

class MangaApp extends StatelessWidget {
  const MangaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MangaX',
      debugShowCheckedModeBanner: false,
      
      // Cấu hình Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, // Mặc định dùng Dark Mode theo yêu cầu thiết kế
      
      // Trang chủ
      home: const HomePage(),
    );
  }
}
