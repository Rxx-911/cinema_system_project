import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MoviePage extends StatefulWidget {
  const MoviePage({super.key});

  @override
  State<MoviePage> createState() => _MoviePageState();
}

class _MoviePageState extends State<MoviePage> {
  List showings = [];

  @override
  void initState() {
    super.initState();
    fetchShowings();
  }

  // 获取电影场次
  Future<void> fetchShowings() async {
    final response = await http.get(
      Uri.parse("https://cinema-backend-x2gl.onrender.com/api/showings"),
    );

    if (response.statusCode == 200) {
      setState(() {
        showings = json.decode(response.body);
      });
    }
  }

  // 下单
  Future<void> createOrder(dynamic showing) async {
    final response = await http.post(
      Uri.parse("https://cinema-backend-x2gl.onrender.com/api/orders"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "movieName": showing["movie"],
        "seats": "A1",
        "totalPrice": showing["price"],
        "username": "test"
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking Success!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Movies"),
      ),
      body: ListView.builder(
        itemCount: showings.length,
        itemBuilder: (context, index) {
          var item = showings[index];

          return ListTile(
            title: Text(item["movie"] ?? ""),
            subtitle: Text(item["time"] ?? ""),
            trailing: ElevatedButton(
              child: const Text("Buy"),
              onPressed: () => createOrder(item),
            ),
          );
        },
      ),
    );
  }
}