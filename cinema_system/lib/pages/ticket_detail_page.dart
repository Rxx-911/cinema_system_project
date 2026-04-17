import 'dart:ui';
import 'package:flutter/material.dart';
import 'my_page.dart';

class TicketDetailPage extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🌌 背景
          Container(
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

          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 20),

                Hero(
                  tag: ticket.movieTitle,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: BackdropFilter(
                      filter:
                          ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(25),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              ticket.movieTitle,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Text(
                              "Time: ${ticket.time}",
                              style: const TextStyle(
                                  color: Colors.white70),
                            ),

                            Text(
                              "Seat: ${ticket.seat}",
                              style: const TextStyle(
                                  color: Colors.white70),
                            ),

                            const SizedBox(height: 30),

                            Container(
                              width: 120,
                              height: 120,
                              color: Colors.white,
                              child: const Center(child: Text("QR")),
                            ),

                            const SizedBox(height: 30),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                      content: Text("Refund success")),
                                );
                              },
                              child: const Text("Refund"),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}