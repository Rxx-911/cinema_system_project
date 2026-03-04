import 'package:flutter/material.dart';
import '../models/seat.dart';
import 'snack_page.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SeatPage extends StatefulWidget {
  final String hallType;

  const SeatPage({
    super.key,
    required this.hallType,
  });

  @override
  State<SeatPage> createState() => _SeatPageState();
}

class _SeatPageState extends State<SeatPage> {
  late List<Seat> seats;
  late int rows;
  late int seatsPerSide;

      Future<void> _lockSeat(Seat seat) async {
  if (!seat.isAvailable) return;

  final response = await http.post(
    Uri.parse('http://localhost:8080/api/seats/${seat.id}/lock'),
  );

  if (response.statusCode == 200) {
    setState(() {
      seat.status = 'LOCKED';
      seat.selected = true;
    });
  } else {
    print("Lock failed");
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

  @override
  void initState() {
    super.initState();
    _configureHall();
    seats = [];
    _loadSeatsFromBackend();
  }

  void _configureHall() {
    switch (widget.hallType) {
      case 'IMAX':
        rows = 15;
        seatsPerSide = 10; // 15 × 20 = 300
        break;
      case 'VIP':
        rows = 3;
        seatsPerSide = 2; // 3 × 4 = 12
        break;
      default:
        rows = 5;
        seatsPerSide = 5; // 5 × 10 = 50
    }
  }

  double _calculateSeatSize(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double aisleWidth = widget.hallType == 'IMAX' ? 60 : 40;
    double padding = 120;
    int totalPerRow = seatsPerSide * 2;
    double available = screenWidth - padding - aisleWidth;
    double size = available / totalPerRow - 8;

    if (widget.hallType == 'VIP') {
      size *= 2.0;
    }
    if (widget.hallType == 'VIP') {
      return size.clamp(30, 100);   // VIP 更大
    }
    return size.clamp(18, 60);
  }

  @override
  Widget build(BuildContext context) {
    double seatSize = _calculateSeatSize(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Select Seats (${widget.hallType})'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          _screenIndicator(),
          const SizedBox(height: 20),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ...List.generate(rows, (rowIndex) {
                    String rowLabel =
                        String.fromCharCode(65 + rowIndex);

                    double curveOffset = 0;
                    if (widget.hallType == 'IMAX') {
                      double middle = rows / 2;
                      curveOffset =
                          (rowIndex - middle).abs() * 4;
                    }

                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 6),
                      child: Transform.translate(
                        offset: Offset(0, curveOffset),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [

                            SizedBox(
                              width: 28,
                              child: Text(
                                rowLabel,
                                style: const TextStyle(
                                    color: Colors.white54),
                              ),
                            ),

                            ...List.generate(
                                seatsPerSide, (seatIndex) {
                              int realIndex =
                                  rowIndex *
                                          (seatsPerSide * 2) +
                                      seatIndex;
                              return _seatWidget(
                                  seats[realIndex],
                                  seatSize,
                                  rowIndex);
                            }),

                            SizedBox(
                                width: widget.hallType ==
                                        'IMAX'
                                    ? 60
                                    : 40),

                            ...List.generate(
                                seatsPerSide, (seatIndex) {
                              int realIndex =
                                  rowIndex *
                                          (seatsPerSide * 2) +
                                      seatIndex +
                                      seatsPerSide;
                              return _seatWidget(
                                  seats[realIndex],
                                  seatSize,
                                  rowIndex);
                            }),
                          ],
                        ),
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
                        Text("EXIT",
                            style: TextStyle(
                                color: Colors.redAccent)),
                        Text("EXIT",
                            style: TextStyle(
                                color: Colors.redAccent)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          _bottomBar(),
        ],
      ),
    );
  }

  Widget _screenIndicator() {
    return Column(
      children: [
        Container(
          width: widget.hallType == 'IMAX'
              ? 420
              : 280,
          height: widget.hallType == 'IMAX'
              ? 60
              : 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(
                  widget.hallType == 'IMAX'
                      ? 120
                      : 80),
            ),
            gradient: LinearGradient(
              colors: [
                const Color(0xFF6C63FF)
                    .withOpacity(0.8),
                const Color(0xFF8A85FF)
                    .withOpacity(0.5),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'SCREEN',
          style: TextStyle(
            color: Colors.white54,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _bottomBar() {
  final selectedCount =
      seats.where((s) => s.isLocked).length;

  final pricePerSeat = _priceByHall();   // ⭐ 用函数
  final total = selectedCount * pricePerSeat;

  return Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1A2E),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 20,
          offset: const Offset(0, -4),
        ),
      ],
    ),
    child: Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$selectedCount seats',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '£${total.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
          child: const Text(
            'Confirm',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

  Future<void> _loadSeatsFromBackend() async {
  final response = await http.get(
    Uri.parse('http://localhost:8080/api/halls/1/seats'),
  );

  if (response.statusCode == 200) {
    List data = json.decode(response.body);

    setState(() {
      seats = data.map((jsonSeat) {
        return Seat(
          id: jsonSeat['id'],
          row: jsonSeat['rowNum'],
          col: jsonSeat['colNum'],
          status: jsonSeat['status'],
          selected: false,
        );
      }).toList();
    });
  } else {
    print("Failed to load seats");
  }
}

  Widget _seatWidget(
    Seat seat, double size, int rowIndex) {

  // 🎬 IMAX 透视缩放
  if (widget.hallType == 'IMAX') {
    double scale =
        0.85 + (rowIndex / rows) * 0.25;
    size *= scale;
  }

  // 💎 VIP 沙发
  if (widget.hallType == 'VIP') {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 6),
      child: _VipSeatItem(
        size: size,
        selected: seat.selected,
        sold: seat.sold,
        onTap: () {
          if (seat.sold) return;
          setState(() {
            seat.selected = !seat.selected;
          });
        },
      ),
    );
  }

  // ⭐ 普通厅
  return Padding(
    padding:
        const EdgeInsets.symmetric(horizontal: 4),
    child: _SeatItem(
              size: size,
              seat: seat,
              onTap: () {
                if (!seat.isAvailable) return;
                _lockSeat(seat);
              },
            ),
  );
}
}


  @override
  State<_SeatItem> createState() =>
      _SeatItemState();

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
  bool hovering = false;
  bool pressing = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hovering = true),
      onExit: (_) => setState(() => hovering = false),
      child: GestureDetector(
        onTapDown: (_) {
          if (!widget.seat.isAvailable) return;
          setState(() => pressing = true);
        },
        onTapUp: (_) {
          if (!widget.seat.isAvailable) return;
          setState(() => pressing = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => pressing = false),
        child: AnimatedScale(
          scale: pressing ? 0.9 : 1,
          duration: const Duration(milliseconds: 100),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: widget.seat.isSold
                  ? Colors.grey.withOpacity(0.4)
                  : widget.seat.isLocked
                      ? const Color(0xFF6C63FF)
                      : hovering
                          ? Colors.white.withOpacity(0.35)
                          : Colors.white.withOpacity(0.15),
              boxShadow: widget.seat.isLocked
                  ? [
                      BoxShadow(
                        color: const Color(0xFF6C63FF)
                            .withOpacity(0.6),
                        blurRadius: 10,
                      ),
                    ]
                  : [],
            ),
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
  State<_VipSeatItem> createState() =>
      _VipSeatItemState();
}

class _VipSeatItemState
    extends State<_VipSeatItem> {
  bool hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) =>
          setState(() => hovering = true),
      onExit: (_) =>
          setState(() => hovering = false),
      child: GestureDetector(
        onTap:
            widget.sold ? null : widget.onTap,
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200),
          width: widget.size,
          height: widget.size * 0.7,
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(16),
            gradient: widget.sold
                ? LinearGradient(
                    colors: [
                      Colors.grey.shade700,
                      Colors.grey.shade600
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
                              Colors.white
                                  .withOpacity(0.4),
                              Colors.white
                                  .withOpacity(0.2),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.white
                                  .withOpacity(0.25),
                              Colors.white
                                  .withOpacity(0.15),
                            ],
                          ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: const Color(
                              0xFF6C63FF)
                          .withOpacity(0.6),
                      blurRadius: 16,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Icon(
              Icons.weekend,
              size: widget.size * 0.4,
              color: widget.sold
                  ? Colors.white38
                  : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
