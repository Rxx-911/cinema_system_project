import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import 'payment_success_page.dart';

class SnackPage extends StatefulWidget {
  final int seatCount;
  final double ticketTotal;

  const SnackPage({
    super.key,
    required this.seatCount,
    required this.ticketTotal,
  });

  @override
  State<SnackPage> createState() => _SnackPageState();
}

class _SnackPageState extends State<SnackPage> {
  final Map<String, int> cart = {};

  // ================= 零食总价 =================
  double get snackTotal {
    double total = 0;
    cart.forEach((id, count) {
      final snack = snacks.firstWhere((s) => s.id == id);
      total += snack.price * count;
    });
    return total;
  }

  // ================= 最终总价（票 + 零食） =================
  double get finalTotal {
    return widget.ticketTotal + snackTotal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Snacks & Drinks'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: snacks.length,
        itemBuilder: (context, index) {
          final snack = snacks[index];
          final count = cart[snack.id] ?? 0;
          final isSelected = count > 0;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF6C63FF).withOpacity(0.15)
                  : const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6C63FF)
                            .withOpacity(0.35),
                        blurRadius: 18,
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // 图片
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.circular(12),
                    child: Image.asset(
                      snack.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // 名称 & 价格
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        snack.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight:
                              FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '£${snack.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white
                              .withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),

                // 数量控制
                Row(
                  children: [
                    IconButton(
                      onPressed: count == 0
                          ? null
                          : () {
                              setState(() {
                                cart[snack.id] =
                                    count - 1;
                                if (cart[snack.id] ==
                                    0) {
                                  cart.remove(
                                      snack.id);
                                }
                              });
                            },
                      icon: const Icon(Icons.remove,
                          color: Colors.white),
                    ),
                    Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          cart[snack.id] =
                              count + 1;
                        });
                      },
                      icon: const Icon(Icons.add,
                          color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),

      // ================= 底部按钮 =================
      bottomNavigationBar: Padding(
        padding:
            const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                const Color(0xFF6C63FF),
            padding:
                const EdgeInsets.symmetric(
                    vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(16),
            ),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentSuccessPage(
                  seatCount: widget.seatCount,
                  ticketTotal: widget.ticketTotal,
                  snackTotal: snackTotal,
                ),
              ),
            );

          },
          child: Text(
            snackTotal == 0
                ? 'Continue · £${widget.ticketTotal.toStringAsFixed(2)}'
                : 'Confirm · £${finalTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight:
                  FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
