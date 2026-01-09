import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/supabase_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final service = SupabaseService();

  // PERBAIKAN: Fungsi untuk memproses pengembalian barang
  Future<void> _handleReturn(Map<String, dynamic> historyItem) async {
    try {
      // 1. Tambah kembali stok di tabel products
      await service.returnProductStock(
        historyItem['product_id'], 
        historyItem['quantity']
      );

      // 2. Update status history menjadi 'returned' atau 'finished'
      await service.updateHistoryStatus(historyItem['id'].toString(), 'finished');

      setState(() {}); // Refresh UI
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alat telah dikembalikan. Stok bertambah!'), backgroundColor: Colors.blue),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengembalikan: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              bool isPaid = h['status'] == 'paid';
              bool isFinished = h['status'] == 'finished';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text('Sewa ${h['quantity']} unit'),
                  subtitle: Text(
                    'Periode: ${DateFormat('dd MMM').format(DateTime.parse(h['start_date']))} - ${DateFormat('dd MMM yyyy').format(DateTime.parse(h['end_date']))}\n'
                    'Total: Rp ${h['total_price']}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // PERBAIKAN: Tampilan status yang lebih jelas
                      Text(
                        isPaid ? 'DI SEWA' : (isFinished ? 'SELESAI' : h['status']),
                        style: TextStyle(
                          color: isPaid ? Colors.green : (isFinished ? Colors.grey : Colors.orange),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Tombol kembalikan jika status masih 'paid'
                      if (isPaid)
                        TextButton(
                          onPressed: () => _handleReturn(h),
                          child: const Text('Kembalikan', style: TextStyle(fontSize: 12)),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}