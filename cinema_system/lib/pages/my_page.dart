import 'package:flutter/material.dart';
import '../data/mock_data.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      appBar: AppBar(
        title: const Text("My Tickets"),
        backgroundColor: Colors.transparent,
      ),
      body: myTickets.isEmpty
          ? const Center(
              child: Text(
                "No tickets purchased yet.",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              itemCount: myTickets.length,
              itemBuilder: (context, index) {
                final ticket = myTickets[index];

                return Card(
                  color: Colors.white.withOpacity(0.1),
                  margin: const EdgeInsets.all(12),
                  child: ListTile(
                    title: Text(
                      ticket.movieTitle,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Seat ${ticket.seatNumber}\n${ticket.showTime}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          myTickets.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
