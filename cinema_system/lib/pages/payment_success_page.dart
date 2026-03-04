import 'dart:async';
import 'package:flutter/material.dart';

class PaymentSuccessPage extends StatefulWidget {
  final int seatCount;
  final double ticketTotal;
  final double snackTotal;

  const PaymentSuccessPage({
    super.key,
    required this.seatCount,
    required this.ticketTotal,
    required this.snackTotal,
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
  Timer? _timer;
  int secondsLeft = 8;

  double get grandTotal =>
      widget.ticketTotal + widget.snackTotal;

  String get orderId =>
      DateTime.now().millisecondsSinceEpoch
          .toString()
          .substring(6);

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

    // 倒计时 + 自动返回
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) return;

        setState(() {
          secondsLeft--;
        });

        if (secondsLeft == 0) {
          timer.cancel();
          Navigator.popUntil(
              context, (route) => route.isFirst);
        }
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              /// ✅ 动画图标
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

              const SizedBox(height: 30),

              const Text(
                "Payment Successful",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                "Order ID: #$orderId",
                style: TextStyle(
                  color:
                      Colors.white.withOpacity(0.6),
                ),
              ),

              const SizedBox(height: 30),

              /// ✅ 订单明细卡片（升级版）
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF1A1A2E),
                      const Color(0xFF232347),
                    ],
                  ),
                  borderRadius:
                      BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black
                          .withOpacity(0.4),
                      blurRadius: 25,
                    )
                  ],
                ),
                child: Column(
                  children: [
                    _rowItem(
                      "Seats",
                      "${widget.seatCount}",
                    ),
                    _rowItem(
                      "Ticket Total",
                      "£${widget.ticketTotal.toStringAsFixed(2)}",
                    ),
                    _rowItem(
                      "Snacks Total",
                      "£${widget.snackTotal.toStringAsFixed(2)}",
                    ),
                    const Divider(
                      color: Colors.white24,
                      height: 30,
                    ),
                    _rowItem(
                      "Total Paid",
                      "£${grandTotal.toStringAsFixed(2)}",
                      highlight: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              Text(
                "Returning to home in $secondsLeft s",
                style: TextStyle(
                  color:
                      Colors.white.withOpacity(0.5),
                ),
              ),

              const SizedBox(height: 20),

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

  Widget _rowItem(
    String title,
    String value, {
    bool highlight = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: highlight
                  ? const Color(0xFF6C63FF)
                  : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: highlight ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}

