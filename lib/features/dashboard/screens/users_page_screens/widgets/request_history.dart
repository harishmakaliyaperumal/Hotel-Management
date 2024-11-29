import 'package:flutter/material.dart';

class RequestHistory extends StatelessWidget {
  final bool isHistoryLoading;
  final List<Map<String, dynamic>> history;
  final Function onRefresh;

  const RequestHistory({
    Key? key,
    required this.isHistoryLoading,
    required this.history,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(5),
          decoration: const BoxDecoration(
            color: Color(0xffB5E198),
            borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Request History',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () => onRefresh(),
              ),
            ],
          ),
        ),
        // History List
        Expanded(
          child: isHistoryLoading
              ? const Center(child: CircularProgressIndicator())
              : history.isEmpty
              ? const Center(child: Text('No request history available', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final item = history[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(item['taskName'] ?? 'N/A'),
                  subtitle: Text('Status: ${item['jobStatus'] ?? 'N/A'}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
