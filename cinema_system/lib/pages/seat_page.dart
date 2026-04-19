import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/seat.dart';
import 'snack_page.dart';
import '../data/mock_data.dart'; // ⭐ 你之前写 generateSeatsByHall 的文件

class SeatPage extends StatefulWidget {
  final String hallType;
  final bool isMember;

  const SeatPage({
    super.key,
    required this.hallType,
    required this.isMember,
  });

  @override
  State<SeatPage> createState() => _SeatPageState();
}

class _SeatPageState extends State<SeatPage>
    with SingleTickerProviderStateMixin {
  static const String _baseUrl = 'https://cinema-backend-x2gl.onrender.com';
  late List<Seat> seats;
  late int rows;
  late int seatsPerSide;

  Map<String, double> pricingRules = {};

  bool _isLoading = true;
  String? _error;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
void initState() {
  super.initState();

  _configureHall();

  seats = generateSeatsByHall(widget.hallType); // ⭐⭐⭐ 关键这一行
  _isLoading = false; // ⭐ 关闭 loading

  _animController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  _fadeAnim = CurvedAnimation(
    parent: _animController,
    curve: Curves.easeOut,
  );

  _animController.forward();

  //_loadPricingRules(); // 这个可以留

  Future.delayed(const Duration(milliseconds: 600), () {
    if (mounted) {
      _showDiscountDialog();
    }
  });
}

Future<void> _loadPricingRules() async {
  try {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/rules'),
    );

    final List data = json.decode(response.body);

    Map<String, double> temp = {};

    for (var rule in data) {
      if (rule["enabled"] == true) {
        temp[rule["ruleType"]] = rule["value"];
      }
    }

    setState(() {
      pricingRules = temp;
    });

    print("Rules loaded: $pricingRules");
  } catch (e) {
    print("Load rules failed: $e");
  }
}

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  List<Seat> _findBestSeats(int count) {
    if (seats.isEmpty) return [];

    final centerCol = seatsPerSide;
    final idealRow = (rows * 0.6).round();

    final scored = <MapEntry<Seat, double>>[];

    for (final seat in seats) {
      if (!seat.isAvailable) continue;

      final dx = (seat.col - centerCol).abs();
      final dy = (seat.row - idealRow).abs();
      final score = dx * 1.5 + dy;

      scored.add(MapEntry(seat, score));
    }

    scored.sort((a, b) => a.value.compareTo(b.value));
    return scored.take(count).map((e) => e.key).toList();
  }

  void _configureHall() {
    switch (widget.hallType) {
      case 'IMAX':
        rows = 15;
        seatsPerSide = 10;
        break;
      case 'VIP':
        rows = 3;
        seatsPerSide = 2;
        break;
      default:
        rows = 5;
        seatsPerSide = 5;
    }
  }

  int _hallIdByType() {
    switch (widget.hallType) {
      case 'IMAX':
        return 1;
      case 'VIP':
        return 2;
      default:
        return 3;
    }
  }

  double _priceByHall() {
    switch (widget.hallType) {
      case 'IMAX':
        return 18.99;
      case 'VIP':
        return 25.99;
      default:
        return 15.99;
    }
  }

  double _calculateSeatSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final aisleWidth = widget.hallType == 'IMAX' ? 60.0 : 40.0;
    const padding = 120.0;
    final totalPerRow = seatsPerSide * 2;

    if (totalPerRow <= 0) return 24;

    final available = screenWidth - padding - aisleWidth;
    double size = available / totalPerRow -6;

    if (widget.hallType == 'VIP') {
      size *= 2.0;
      return size.clamp(30, 100);
    }

    return size.clamp(20, 50);
  }

  Future<void> _loadSeatsFromBackend() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final hallId = _hallIdByType();
      final response = await http.get(
        Uri.parse('$_baseUrl/api/halls/$hallId/seats'),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load seats: ${response.statusCode}');
      }

      final List data = json.decode(response.body);
      print(data);
      final loadedSeats = data.map<Seat>((jsonSeat) {
        final status = (jsonSeat['status'] ?? 'AVAILABLE').toString();

        return Seat(
          id: jsonSeat['id'],
          row: jsonSeat['rowNum']+1,
          col: jsonSeat['colNum']+1,
          status: status,
          selected: status == 'LOCKED',
        );
      }).toList();

      _syncLayoutWithBackend(loadedSeats);

      if (!mounted) return;

      setState(() {
        seats = loadedSeats;
        _isLoading = false;
      });

      _animController.reset();
      _animController.forward();
    } catch (e) {
      debugPrint('Load seats error: $e');

      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _syncLayoutWithBackend(List<Seat> loadedSeats) {
    if (loadedSeats.isEmpty) return;

    // IMAX 保持固定 15×20
    if (widget.hallType == 'IMAX') return;

    final maxRow = loadedSeats.fold<int>(
      0,
      (prev, seat) => seat.row > prev ? seat.row : prev,
    );

    final maxCol = loadedSeats.fold<int>(
      0,
      (prev, seat) => seat.col > prev ? seat.col : prev,
    );

    if (maxRow > 0) {
      rows = maxRow;
    }

    if (maxCol > 0) {
      seatsPerSide = (maxCol / 2).ceil();
    }
  }

  /*Future<void> _lockSeat(Seat seat) async {
    if (!seat.isAvailable) return;

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/seats/${seat.id}/lock'),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          seat.status = 'LOCKED';
          seat.selected = true;
        });
      } else {
        debugPrint('Lock failed: ${response.statusCode}');
        _showMessage('Seat lock failed');
      }
    } catch (e) {
      debugPrint('Lock error: $e');
      _showMessage('Network error while locking seat');
    }
  }
  */

  /*Future<void> _unlockSeat(Seat seat) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/seats/${seat.id}/unlock'),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          seat.status = 'AVAILABLE';
          seat.selected = false;
        });
      } else {
        debugPrint('Unlock failed: ${response.statusCode}');
        _showMessage('Seat unlock failed');
      }
    } catch (e) {
      debugPrint('Unlock error: $e');
      _showMessage('Network error while unlocking seat');
    }
  }
  */

  void _handleSeatTap(Seat seat) {
  if (seat.isSold) return;

  setState(() {
    if (seat.status == 'AVAILABLE') {
      seat.status = 'LOCKED';
      seat.selected = true;
    } else if (seat.status == 'LOCKED') {
      seat.status = 'AVAILABLE';
      seat.selected = false;
    }
  });
}

  void _showMessage(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }


Seat? _seatAt(int rowNumber, int colNumber) {
  if (seats.isEmpty) return null;

  try {
    return seats.firstWhere(
      (s) =>
          s.row == rowNumber &&
          s.col == colNumber, // ✅ 直接匹配
    );
  } catch (_) {
    return null;
  }
}

  int get _displayRows {
    if (rows <= 0) return 0;
    return rows;
  }

  double _curveOffsetForRow(int rowIndex) {
    if (widget.hallType != 'IMAX') return 0;

    final middle = (_displayRows - 1) / 2;
    return (rowIndex - middle).abs() * 4;
  }

  Widget _buildSeatOrPlaceholder({
    required int rowNumber,
    required int colNumber,
    required double seatSize,
    required int rowIndex,
  }) {
    final seat = _seatAt(rowNumber, colNumber);

    if (seat == null) {
      return _emptySeatPlaceholder(seatSize);
    }

    return _seatWidget(seat, seatSize, rowIndex);
  }

  Widget _emptySeatPlaceholder(double size) {
    if (widget.hallType == 'VIP') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: SizedBox(
          width: size,
          height: size * 0.7,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: size,
        height: size,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final seatSize = _calculateSeatSize(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Select Seats (${widget.hallType})'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            tooltip: 'Best Seats',
            onPressed: () {
              final bestSeats = _findBestSeats(2);

              setState(() {
                for (final seat in bestSeats) {
                  seat.status = 'LOCKED';
                  seat.selected = true;
                }
              });
            },
          ),
          IconButton(
          onPressed: () {
            setState(() {
              seats = generateSeatsByHall(widget.hallType);
            });
          },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh seats',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _screenIndicator(),
          const SizedBox(height: 20),
          Expanded(
            child: _buildBody(seatSize),
          ),
          _bottomBar(),
        ],
      ),
    );
  }

Widget _buildBody(double seatSize) {
  if (_isLoading) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  if (_error != null) {
    return Center(
      child: Text(
        'Error: $_error',
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  return RefreshIndicator(
    onRefresh: () async {}, // ⭐ 不用后端
    child: SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width,
          ),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Column(
              children: [
                ...List.generate(_displayRows, (rowIndex) {
                  final rowNumber = rowIndex + 1;
                  final rowLabel = String.fromCharCode(65 + rowIndex);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start, // ⭐ 必须
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            rowLabel,
                            style:
                                const TextStyle(color: Colors.white54),
                          ),
                        ),

                        // 左侧
                        ...List.generate(seatsPerSide, (seatIndex) {
                          final colNumber = seatIndex + 1;
                          return _buildSeatOrPlaceholder(
                            rowNumber: rowNumber,
                            colNumber: colNumber,
                            seatSize: seatSize,
                            rowIndex: rowIndex,
                          );
                        }),

                        SizedBox(
                          width: widget.hallType == 'IMAX' ? 60 : 40,
                        ),

                        // 右侧
                        ...List.generate(seatsPerSide, (seatIndex) {
                          final colNumber =
                              seatsPerSide + seatIndex + 1;
                          return _buildSeatOrPlaceholder(
                            rowNumber: rowNumber,
                            colNumber: colNumber,
                            seatSize: seatSize,
                            rowIndex: rowIndex,
                          );
                        }),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 20),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('EXIT',
                          style:
                              TextStyle(color: Colors.redAccent)),
                      Text('EXIT',
                          style:
                              TextStyle(color: Colors.redAccent)),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  Widget _screenIndicator() {
  return Column(
    children: [
      Container(
        width: widget.hallType == 'IMAX' ? 420 : 280,
        height: widget.hallType == 'IMAX' ? 70 : 45,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(
              widget.hallType == 'IMAX' ? 140 : 90,
            ),
          ),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF9A8CFF),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.8),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'SCREEN',
        style: TextStyle(
          color: Colors.white70,
          letterSpacing: 4,
          fontSize: 12,
        ),
      ),
    ],
  );
}

  Widget _bottomBar() {
  final selectedSeats = seats.where((s) => s.isLocked).toList();
  final selectedCount = selectedSeats.length;
  final pricePerSeat = _priceByHall();
  final total = calculateFinalPrice(
      basePrice: selectedCount * pricePerSeat,
      ticketCount: selectedCount,
      totalSold: 120, // ⭐ 先写死，后面接后端
      time: DateTime.now(),
      isMember: widget.isMember, // ⭐ 后面接用户系统
    );
    
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 26),
    decoration: BoxDecoration(
      color: const Color(0xFF121226),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.7),
          blurRadius: 30,
          offset: const Offset(0, -6),
        ),
      ],
    ),
    child: Row(
      children: [
        Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    /// ⭐⭐⭐ 新加：显示选中座位
    Text(
      selectedSeats.isEmpty
          ? "No seats selected"
          : selectedSeats
              .map((s) =>
                  "${String.fromCharCode(65 + s.row - 1)}${s.col}")
              .join(", "),
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
      ),
    ),

    const SizedBox(height: 6),

    /// 原来的 TOTAL
    Text(
      'TOTAL',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 2,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '£${total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
             const SizedBox(height: 4),

              const Text(
                "🔥 Dynamic Pricing Applied",
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontSize: 12,
                ),
              ),
           ],
        ),

        const Spacer(),

        ElevatedButton(
          onPressed: selectedCount == 0
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SnackPage(
                        seatCount: selectedCount,
                        ticketTotal: total,
                      ),
                    ),


                    
                  );
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            padding: const EdgeInsets.symmetric(
                horizontal: 28, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 10,
          ),
          child: const Text(
            'CONFIRM',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _seatWidget(Seat seat, double size, int rowIndex) {
    final totalRows = _displayRows == 0 ? 1 : _displayRows;

    if (widget.hallType == 'IMAX') {
      final scale = 0.85 + (rowIndex / totalRows) * 0.25;
      size *= scale;
    }

    if (widget.hallType == 'VIP') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: _VipSeatItem(
          size: size,
          selected: seat.selected,
          sold: seat.isSold,
          onTap: () => _handleSeatTap(seat),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: _SeatItem(
        size: size,
        seat: seat,
        onTap: () => _handleSeatTap(seat),
      ),
    );
  }

      double calculateFinalPrice({
        required double basePrice,
        required int ticketCount,
        required int totalSold,
        required DateTime time,
        required bool isMember,
      }) {
        double price = basePrice;

        /// 🎟️ 销量规则
        if (totalSold > 100) {
          price *= 1.1;
        } else if (totalSold < 30) {
          price *= 0.9;
        }

        /// 🕒 黄金时间
        if (time.hour >= 18 && time.hour <= 22) {
          price *= 1.15;
        }

        /// 📅 周二
        if (time.weekday == DateTime.tuesday) {
          price *= 0.5;
        }

        /// 📅 节假日
        if (_isHoliday(time)) {
          price *= 0.8;
        }

        /// 👑 会员
        if (isMember) {
          price *= 0.8;
        }

        return price;
      }

      /// ⭐ 节假日判断
      bool _isHoliday(DateTime time) {
        return (time.month == 12 && time.day == 25);
      }
  void _showDiscountDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                const Text(
                  "🎉 Special Offer",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Tuesday → 50% OFF",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Members → 20% OFF",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("OK"),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SeatItem extends StatefulWidget {
  final double size;
  final Seat seat;
  final VoidCallback onTap;

  const _SeatItem({
    required this.size,
    required this.seat,
    required this.onTap,
  });

  @override
  State<_SeatItem> createState() => _SeatItemState();
}

class _SeatItemState extends State<_SeatItem> {
  bool pressing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.seat.isSold) return;
        setState(() => pressing = true);
      },
      onTapUp: (_) {
        if (widget.seat.isSold) return;
        setState(() => pressing = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => pressing = false),

      child: AnimatedScale(
        scale: pressing ? 0.92 : 1,
        duration: const Duration(milliseconds: 100),

        child: Container(
          width: widget.size ,
          height: widget.size,
          margin: const EdgeInsets.symmetric(horizontal: 4),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),

            color: widget.seat.isSold
                ? Colors.grey.withOpacity(0.4)
                : widget.seat.selected
                    ? const Color(0xFF6C63FF)
                    : widget.seat.isLocked
                        ? Colors.orange.withOpacity(0.6)
                        : Colors.white.withOpacity(0.15),

            boxShadow: widget.seat.selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ]
                : [],
          ),
        ),
      ),
    );
  }
}

class _VipSeatItem extends StatefulWidget {
  final double size;
  final bool selected;
  final bool sold;
  final VoidCallback onTap;

  const _VipSeatItem({
    required this.size,
    required this.selected,
    required this.sold,
    required this.onTap,
  });

  @override
  State<_VipSeatItem> createState() => _VipSeatItemState();
}

class _VipSeatItemState extends State<_VipSeatItem> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTap: widget.sold ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: widget.size,
          height: widget.size * 0.7,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: widget.sold
                ? LinearGradient(
                    colors: [
                      Colors.grey.shade700,
                      Colors.grey.shade600,
                    ],
                  )
                : widget.selected
                    ? const LinearGradient(
                        colors: [
                          Color(0xFF6C63FF),
                          Color(0xFF8A85FF),
                        ],
                      )
                    : hovering
                        ? LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.4),
                              Colors.white.withOpacity(0.2),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.2),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.7),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Icon(
              Icons.weekend,
              size: widget.size * 0.4,
              color: widget.sold ? Colors.white38 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}