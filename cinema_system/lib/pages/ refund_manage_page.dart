import 'package:flutter/material.dart';
import '../models/ticket.dart';
import '../data/ticket_store.dart';

class RefundManagePage extends StatefulWidget {
  const RefundManagePage({super.key});

  @override
  State<RefundManagePage> createState() => _RefundManagePageState();
}

class _RefundManagePageState extends State<RefundManagePage> {

  String selectedFilter = 'all';
  String searchKeyword = '';

  List<Ticket> getFilteredTickets() {
    return globalTickets.where((ticket) {

      final matchesSearch =
          ticket.movieTitle.toLowerCase().contains(searchKeyword.toLowerCase()) ||
          ticket.id.contains(searchKeyword);

      final matchesFilter =
          selectedFilter == 'all' ||
          (selectedFilter == 'pending' && ticket.refundStatus == RefundStatus.pending) ||
          (selectedFilter == 'approved' && ticket.refundStatus == RefundStatus.approved) ||
          (selectedFilter == 'rejected' && ticket.refundStatus == RefundStatus.rejected);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  void requestRefund(Ticket ticket) {
    setState(() {
      ticket.refundStatus = RefundStatus.pending;
    });
  }

  void approveRefund(Ticket ticket) {
    setState(() {
      ticket.refundStatus = RefundStatus.approved;
      ticket.ticketStatus = TicketStatus.refunded;
    });
  }

  void rejectRefund(Ticket ticket) {
    setState(() {
      ticket.refundStatus = RefundStatus.rejected;
    });
  }

  @override
  Widget build(BuildContext context) {

    final tickets = getFilteredTickets();

    return Scaffold(
      appBar: AppBar(title: const Text("Refund Management")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              decoration: const InputDecoration(
                hintText: "Search...",
              ),
              onChanged: (v) => setState(() => searchKeyword = v),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              children: [
                _btn("All", "all"),
                _btn("Pending", "pending"),
                _btn("Approved", "approved"),
                _btn("Rejected", "rejected"),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: tickets.isEmpty
                  ? const Center(child: Text("No tickets"))
                  : ListView.builder(
                      itemCount: tickets.length,
                      itemBuilder: (_, i) {
                        final t = tickets[i];

                        return Card(
                          child: ListTile(
                            title: Text(t.movieTitle),
                            subtitle: Text("Seat: ${t.seatLabel}"),
                            trailing: _buildActions(t),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActions(Ticket t) {

    if (t.refundStatus == RefundStatus.none) {
      return ElevatedButton(
        onPressed: () => requestRefund(t),
        child: const Text("Request Refund"),
      );
    }

    if (t.refundStatus == RefundStatus.pending) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.green),
            onPressed: () => approveRefund(t),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => rejectRefund(t),
          ),
        ],
      );
    }

    if (t.refundStatus == RefundStatus.approved) {
      return const Text("Approved", style: TextStyle(color: Colors.green));
    }

    return const Text("Rejected", style: TextStyle(color: Colors.red));
  }

  Widget _btn(String text, String value) {
    return ElevatedButton(
      onPressed: () => setState(() => selectedFilter = value),
      child: Text(text),
    );
  }
}