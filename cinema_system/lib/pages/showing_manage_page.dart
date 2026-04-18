import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ShowingManagePage extends StatefulWidget {
  const ShowingManagePage({super.key});

  @override
  State<ShowingManagePage> createState() => _ShowingManagePageState();
}

class _ShowingManagePageState extends State<ShowingManagePage> {

  /// ⭐ 从后端获取的数据
  List<Map<String, dynamic>> showings = [];

  /// ⭐ 页面加载时请求数据
  @override
  void initState() {
    super.initState();
    _loadShowings();
  }

  /// ⭐ 获取排片
  Future<void> _loadShowings() async {
    print("🔥 Loading showings...");

    try {
      final response = await http.get(
        Uri.parse("https://cinema-backend-x2gl.onrender.com/api/showings"),
      );

      print("🔥 Response: ${response.body}");

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        setState(() {
          showings = data.map<Map<String, dynamic>>((item) {
            return {
              "id": item["id"],
              "movie": item["movie"],
              "date": item["date"],
              "time": item["time"],
              "hall": item["hall"],
              "price": item["price"].toString(),
            };
          }).toList();
        });
      }
    } catch (e) {
      print("❌ Load failed: $e");
    }
  }

  /// ⭐ 新增排片（调用后端）
  Future<void> _addShowing(Map data) async {
    final response = await http.post(
      Uri.parse("https://cinema-backend-x2gl.onrender.com/api/showings"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      _loadShowings(); // 刷新
    }
  }

  /// ⭐ 删除排片（调用后端）
  Future<void> _deleteShowing(int id) async {
    await http.delete(
      Uri.parse("https://cinema-backend-x2gl.onrender.com/api/showings/$id"),
    );

    _loadShowings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text("Manage Showings"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            /// ➕ 添加按钮
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "All Showings",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: _showAddDialog,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Showing"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            /// 📋 列表
            Expanded(
              child: ListView.builder(
                itemCount: showings.length,
                itemBuilder: (context, index) {
                  final item = showings[index];
                  return _glassCard(item, index);
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  /// 🧊 卡片
  Widget _glassCard(Map<String, dynamic> item, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                /// 信息
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["movie"] ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text("Date: ${item["date"]}",
                        style: const TextStyle(color: Colors.white70)),
                    Text("Time: ${item["time"]}",
                        style: const TextStyle(color: Colors.white70)),
                    Text("Hall: ${item["hall"]}",
                        style: const TextStyle(color: Colors.white70)),
                    Text("Price: £${item["price"]}",
                        style: const TextStyle(color: Colors.orangeAccent)),
                  ],
                ),

                /// 删除
                IconButton(
                  onPressed: () {
                    _deleteShowing(item["id"]);
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ➕ 添加弹窗
  void _showAddDialog() {
    final movieController = TextEditingController();
    final dateController = TextEditingController();
    final timeController = TextEditingController();
    final hallController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text("Add Showing",
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _input(movieController, "Movie Name"),
              const SizedBox(height: 10),
              _input(dateController, "Date (2026-04-20)"),
              const SizedBox(height: 10),
              _input(timeController, "Time (20:00)"),
              const SizedBox(height: 10),
              _input(hallController, "Hall (IMAX/VIP)"),
              const SizedBox(height: 10),
              _input(priceController, "Price"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await _addShowing({
                  "movie": movieController.text,
                  "date": dateController.text,
                  "time": timeController.text,
                  "hall": hallController.text,
                  "price": double.parse(priceController.text),
                });

                Navigator.pop(context);
              },
              child: const Text("Add"),
            )
          ],
        );
      },
    );
  }

  Widget _input(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}