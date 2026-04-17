import 'dart:ui';
import 'package:flutter/material.dart';
import 'showing_manage_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int selectedIndex = 0;

  final menu = [
    {"title": "Dashboard", "icon": Icons.dashboard},
    {"title": "Movies", "icon": Icons.movie},
    {"title": "Showings", "icon": Icons.schedule},
    {"title": "Pricing", "icon": Icons.attach_money},
    {"title": "Orders", "icon": Icons.receipt_long},
    {"title": "Users", "icon": Icons.people},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// 🌌 背景渐变
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F0F1A),
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// 💜 背景光晕
          Positioned(
            top: -120,
            left: -120,
            child: _glow(300),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: _glow(350),
          ),

          Row(
            children: [

              /// 🧭 左侧导航栏
              _sidebar(),

              /// 📊 右侧内容
              Expanded(
                child: _content(),
              ),
            ],
          )
        ],
      ),
    );
  }

  /// 💜 光晕
  Widget _glow(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF6C63FF).withOpacity(0.2),
      ),
    );
  }

  /// 🧭 Sidebar
  Widget _sidebar() {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [

          /// 标题
          const Text(
            "ADMIN",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 40),

          /// 菜单
          ...List.generate(menu.length, (index) {
            final item = menu[index];
            final selected = index == selectedIndex;

            return GestureDetector(
              onTap: () {
                final title = item["title"];

                if (title == "Showings") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ShowingManagePage(),
                    ),
                  );
                  return;
                }

                setState(() {
                  selectedIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: selected
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF6C63FF),
                            Color(0xFF9A8CFF)
                          ],
                        )
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(item["icon"] as IconData,
                        color: Colors.white70),
                    const SizedBox(width: 10),
                    Text(
                      item["title"] as String,
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
            );
          }),

          const Spacer(),

          /// 登出按钮
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 45),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Logout"),
            ),
          )
        ],
      ),
    );
  }

  /// 📊 右侧内容区
  Widget _content() {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 标题
          Text(
            menu[selectedIndex]["title"] as String,
            style: const TextStyle(
              fontSize: 28,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          /// 内容区
          Expanded(
            child: GridView.count(
              crossAxisCount: 4, 
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3, 
              children: [
                _glassCard("Total Users", "128", Icons.people),
                _glassCard("Movies", "8", Icons.movie),
                _glassCard("Orders", "52", Icons.receipt),
                _glassCard("Revenue", "\$1200", Icons.attach_money),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// 🧊 毛玻璃卡片
  Widget _glassCard(String title, String value, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: Colors.white70, size: 30),
                const Spacer(),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}