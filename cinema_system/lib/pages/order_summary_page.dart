import 'dart:async';
import 'package:flutter/material.dart';

class PaymentSuccessPage extends StatefulWidget {
  final int seatCount;
  final double totalPrice;

  const PaymentSuccessPage({
    super.key,
    required this.seatCount,
    required this.totalPrice,
  });

  @override
  State<PaymentSuccessPage> createState() =>
      _PaymentSuccessPageState();
}

class _PaymentSuccessPageState
    extends State<PaymentSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();

    // ⭐ 2秒后自动回首页
    Timer(const Duration(seconds: 10), () {
      Navigator.popUntil(
          context, (route) => route.isFirst);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get orderId =>
      DateTime.now().millisecondsSinceEpoch
          .toString()
          .substring(6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00C853),
                        Color(0xFF69F0AE),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green
                            .withOpacity(0.6),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                "Payment Successful",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                "Order ID: #$orderId",
                style: TextStyle(
                  color:
                      Colors.white.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Seats booked: ${widget.seatCount}",
                style: TextStyle(
                  color:
                      Colors.white.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                "Total Paid: £${widget.totalPrice.toStringAsFixed(2)}",
                style: TextStyle(
                  color:
                      Colors.white.withOpacity(0.7),
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF6C63FF),
                  padding:
                      const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.popUntil(context,
                      (route) => route.isFirst);
                },
                child: const Text(
                  "Back to Home",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
