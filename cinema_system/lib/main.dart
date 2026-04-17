import 'package:flutter/material.dart';
import 'pages/login_page.dart';


void main() {
  runApp(const CinemaApp());
}

class CinemaApp extends StatelessWidget {
  const CinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cinema System',

      // ===== 全局深色主题（Netflix / Apple TV 风格）=====
      theme: ThemeData(
        brightness: Brightness.dark,

        // Scaffold 默认背景（交给页面自己控制即可）
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),

        primaryColor: const Color(0xFF6C63FF),

        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
        ),

        // 统一字体风格
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Colors.white70,
          ),
        ),

        // 按钮风格（SeatPage 会用到）
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),

        useMaterial3: false,
      ),

      // ===== 唯一首页 =====
      home: const LoginPage(),
    );
  }
}
