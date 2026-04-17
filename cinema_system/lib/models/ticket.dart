enum RefundStatus { none, pending, approved, rejected }

enum TicketStatus { active, refunded }

class Ticket {
  String id;
  String movieTitle;
  String seatLabel;
  String hallName;
  double price;
  DateTime showTime;

  RefundStatus refundStatus;
  TicketStatus ticketStatus;

  Ticket({
    required this.id,
    required this.movieTitle,
    required this.seatLabel,
    required this.hallName,
    required this.price,
    required this.showTime,
    this.refundStatus = RefundStatus.none,
    this.ticketStatus = TicketStatus.active,
  });
}