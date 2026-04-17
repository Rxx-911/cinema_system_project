import 'dart:ui';
import 'package:flutter/material.dart';
import 'ticket_detail_page.dart';

class Ticket {
  final String movieTitle;
  final String time;
  final String seat;

  Ticket({
    required this.movieTitle,
    required this.time,
    required this.seat,
  });
}

List<Ticket> myTickets = [
  Ticket(movieTitle: "Interstellar", time: "20:00", seat: "A5"),
  Ticket(movieTitle: "Inception", time: "18:00", seat: "B3"),
  Ticket(movieTitle: "Avatar", time: "16:00", seat: "C1"),
];

class MyPage extends StatefulWidget {
  final String username;

  const MyPage({super.key, required this.username});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.75);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 🌌 背景
  Widget _background() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F0F1A),
                Color(0xFF1A1A2E),
                Color(0xFF16213E),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        Positioned(top: -120, left: -120, child: _glow(300)),
        Positioned(bottom: -150, right: -100, child: _glow(350)),
      ],
    );
  }

  Widget _glow(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF6C63FF).withOpacity(0.25),
      ),
    );
  }

  /// 👤 头部
  Widget _header() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 45,
            backgroundColor: const Color(0xFF6C63FF),
            child: Text(
              widget.username[0].toUpperCase(),
              style: const TextStyle(fontSize: 32, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            widget.username,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Text(
            "Premium User",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  /// 🎞 Ticket滑动
  Widget _ticketSlider() {
    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _controller,
        itemCount: myTickets.length,
        itemBuilder: (context, index) {
          final ticket = myTickets[index];

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double scale = 1.0;

              if (_controller.position.haveDimensions) {
                final page = _controller.page ?? 0;
                scale =
                    (1 - (page - index).abs() * 0.2).clamp(0.85, 1.0);
              }

              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: _ticketCard(ticket),
          );
        },
      ),
    );
  }

  /// 🎫 Ticket卡片（带动画跳转）
  Widget _ticketCard(Ticket ticket) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (_, __, ___) =>
                TicketDetailPage(ticket: ticket),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Hero(
          tag: ticket.movieTitle,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF6C63FF).withOpacity(0.25),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.movieTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Time: ${ticket.time}",
                        style:
                            const TextStyle(color: Colors.white70)),
                    Text("Seat: ${ticket.seat}",
                        style:
                            const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 🔥 按钮（可点击）
  Widget _glowButton(
      String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 20,
            )
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// 📦 主内容
  Widget _content() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(),
              const SizedBox(height: 20),

              const Text(
                "My Tickets",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              _ticketSlider(),

              const Spacer(),

              _glowButton("Customer Service", Colors.blue, () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Contacting support...")),
                );
              }),

              const SizedBox(height: 12),

              _glowButton("Logout", Colors.red, () {
                Navigator.pop(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _background(),
          SafeArea(child: _content()),
        ],
      ),
    );
  }
}