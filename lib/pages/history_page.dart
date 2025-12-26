import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Sewa')),
      body: FutureBuilder(
        future: service.getHistory('guest-user'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data ?? [];
          if (data.isEmpty) return const Center(child: Text('Belum ada riwayat'));
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, i) {
              final h = data[i];
              return Card(
                child: ListTile(
                  title: Text('Sewa ${h['quantity']} unit'),
                  subtitle: Text('${DateFormat('dd MMM yyyy').format(DateTime.parse(h['start_date']))} - ${DateFormat('dd MMM yyyy').format(DateTime.parse(h['end_date']))}\nTotal: Rp ${h['total_price']}'),
                  trailing: Text(h['status'] == 'pending' ? 'Menunggu' : 'Selesai'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}