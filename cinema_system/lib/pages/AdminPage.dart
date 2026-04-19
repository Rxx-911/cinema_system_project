import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {

  int selectedIndex = 0;

  List movies = ["Inception", "Dune", "Zootopia"];
  List users = [
    {"name": "Alice", "member": true},
    {"name": "Bob", "member": false},
  ];

  List showings = [];
  bool loadingShowings = true;

  @override
  void initState() {
    super.initState();
    fetchShowings();
  }

  /// 🌐 API
  Future<void> fetchShowings() async {
    try {
      final res = await http.get(
        Uri.parse("https://cinema-backend-x2gl.onrender.com/api/showings"),
      );

      if (res.statusCode == 200) {
        setState(() {
          showings = json.decode(res.body);
          loadingShowings = false;
        });
      }
    } catch (e) {
      loadingShowings = false;
    }
  }

  final menu = [
    {"title": "Dashboard", "icon": Icons.dashboard},
    {"title": "Movies", "icon": Icons.movie},
    {"title": "Showings", "icon": Icons.schedule},
    {"title": "Users", "icon": Icons.people},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: selectedIndex == 2
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF6C63FF),
              onPressed: _addShowingDialog,
              child: const Icon(Icons.add),
            )
          : null,

      body: Stack(
        children: [

          /// 🌌 背景
          AnimatedContainer(
            duration: const Duration(seconds: 5),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0F0F1A),
                  Color(0xFF1A1A2E),
                  Color(0xFF16213E),
                ],
              ),
            ),
          ),

          /// 💜 光晕
          Positioned(top: -120, left: -120, child: _glow(300)),
          Positioned(bottom: -150, right: -100, child: _glow(350)),

          Row(
            children: [
              _sidebar(),
              Expanded(child: _content()),
            ],
          ),
        ],
      ),
    );
  }

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

  /// Sidebar
  Widget _sidebar() {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [

          const Text("ADMIN",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),

          const SizedBox(height: 40),

          ...List.generate(menu.length, (index) {
            final selected = index == selectedIndex;

            return GestureDetector(
              onTap: () => setState(() => selectedIndex = index),
              child: AnimatedContainer(
                curve: Curves.easeInOut,
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: selected
                      ? const LinearGradient(
                          colors: [
                            Color(0xFF6C63FF),
                            Color(0xFF9A8CFF)
                          ])
                      : null,
                ),
                child: Row(
                  children: [
                    Icon(menu[index]["icon"] as IconData,
                        color: Colors.white),
                    const SizedBox(width: 10),
                    Text(menu[index]["title"] as String,
                        style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );
          }),

          const Spacer(),

          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Logout"),
          )
        ],
      ),
    );
  }

  Widget _content() {
    switch (selectedIndex) {
      case 0:
        return _dashboard();
      case 1:
        return _movies();
      case 2:
        return _showings();
      case 3:
        return _users();
      default:
        return _dashboard();
    }
  }

  /// Dashboard
  Widget _dashboard() {
    return _wrapper(
      "Dashboard",
      GridView.count(
        crossAxisCount: 4,
        children: [
          _card("Users", users.length.toString(), Icons.people),
          _card("Movies", movies.length.toString(), Icons.movie),
          _card("Showings", showings.length.toString(), Icons.schedule),
          _card("Revenue", "\$1200", Icons.attach_money),
        ],
      ),
    );
  }

  /// Movies
  Widget _movies() {
    return _wrapper(
      "Movies",
      ListView.builder(
        itemCount: movies.length,
        itemBuilder: (_, i) {
          return Card(
            color: Colors.white10,
            child: ListTile(
              title: Text(movies[i],
                  style: const TextStyle(color: Colors.white)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () =>
                    setState(() => movies.removeAt(i)),
              ),
            ),
          );
        },
      ),
    );
  }

  /// ⭐ Showings（终极UI）
  Widget _showings() {
    if (loadingShowings) {
      return const Center(child: CircularProgressIndicator());
    }

    return _wrapper(
      "Showings",
      ListView.builder(
        itemCount: showings.length,
        itemBuilder: (_, i) {
          final s = showings[i];

          return TweenAnimationBuilder(
            duration: Duration(milliseconds: 300 + i * 100),
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - value)),
                  child: child,
                ),
              );
            },

            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),

                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.all(10),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: ListTile(
                    leading: const Icon(Icons.movie,
                        color: Colors.white),

                    title: Text(
                      s["movie"] ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    subtitle: Text(
                      "Time: ${s["time"]}",
                      style:
                          const TextStyle(color: Colors.white70),
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: Colors.blueAccent),
                          onPressed: () => _editShowingDialog(i),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.redAccent),
                          onPressed: () => _confirmDelete(i),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Users
  Widget _users() {
    return _wrapper(
      "Users",
      ListView.builder(
        itemCount: users.length,
        itemBuilder: (_, i) {
          return Card(
            color: Colors.white10,
            child: ListTile(
              title: Text(users[i]["name"],
                  style: const TextStyle(color: Colors.white)),
              trailing: Switch(
                value: users[i]["member"],
                onChanged: (v) =>
                    setState(() => users[i]["member"] = v),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _wrapper(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _card(String t, String v, IconData icon) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
                color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white),
              const Spacer(),
              Text(v,
                  style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              Text(t,
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }

  /// 删除
  void _confirmDelete(int i) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Delete this showing?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                showings.removeAt(i);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  /// 编辑
  void _editShowingDialog(int index) {
    String movie = showings[index]["movie"];
    String time = showings[index]["time"];

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Showing"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: movie),
              onChanged: (v) => movie = v,
            ),
            TextField(
              controller: TextEditingController(text: time),
              onChanged: (v) => time = v,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                showings[index] = {
                  "movie": movie,
                  "time": time
                };
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  /// 添加
  void _addShowingDialog() {
    String movie = "";
    String time = "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Showing"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration:
                  const InputDecoration(labelText: "Movie"),
              onChanged: (v) => movie = v,
            ),
            TextField(
              decoration:
                  const InputDecoration(labelText: "Time"),
              onChanged: (v) => time = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                showings.add({"movie": movie, "time": time});
              });
              Navigator.pop(context);
            },
            child: const Text("Add"),
          )
        ],
      ),
    );
  }
}