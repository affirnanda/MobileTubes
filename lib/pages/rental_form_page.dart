import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';
import '../services/supabase_service.dart';

class RentalFormPage extends StatefulWidget {
  final Product product;

  const RentalFormPage({super.key, required this.product});

  @override
  State<RentalFormPage> createState() => _RentalFormPageState();
}

class _RentalFormPageState extends State<RentalFormPage> {
  DateTime? startDate;
  DateTime? endDate;
  int quantity = 1;
  double totalPrice = 0.0;
  bool isLoading = false;

  final service = SupabaseService();
  final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  void _updateTotal() {
    if (startDate != null && endDate != null) {
      final int diff = endDate!.difference(startDate!).inDays;
      final int days = diff <= 0 ? 1 : diff; 
      
      totalPrice = quantity * days * widget.product.pricePerDay;
    } else {
      totalPrice = 0.0;
    }
    setState(() {});
  }

  Future<void> _pickDate(bool isStart) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = isStart
        ? (startDate ?? now)
        : (endDate ?? (startDate?.add(const Duration(days: 1)) ?? now.add(const Duration(days: 1))));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      locale: const Locale('id', 'ID'),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          if (endDate != null && endDate!.isBefore(picked)) {
            endDate = null;
          }
        } else {
          endDate = picked;
        }
        _updateTotal();
      });
    }
  }

  // --- PERBAIKAN: LOGIKA SUBMIT DENGAN VALIDASI STOK ---
  Future<void> _submit() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih tanggal sewa terlebih dahulu')),
      );
      return;
    }

    // Perbaikan: Validasi jika input jumlah melebihi stok yang tersedia
    if (quantity > widget.product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan melebihi stock'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final int diff = endDate!.difference(startDate!).inDays;
      final int finalDays = diff <= 0 ? 1 : diff;

      // 1. Simpan ke tabel 'pesan' dengan status 'paid'
      final orderData = {
        'product_id': widget.product.id,
        'quantity': quantity,
        'start_date': DateFormat('yyyy-MM-dd').format(startDate!),
        'end_date': DateFormat('yyyy-MM-dd').format(endDate!),
        'days': finalDays, 
        'total_price': totalPrice,
        'status': 'paid', // Status langsung menjadi paid/di sewa
        'payment_status': 'paid',
        'payment_method': 'manual',
        'created_at': DateTime.now().toIso8601String(),
      };
      await service.createOrder(orderData); //

      // 2. Update stok (mengurangi jumlah barang)
      final int newStock = widget.product.stock - quantity;
      await service.updateProductStock(widget.product.id, newStock); //

      // 3. Simpan ke tabel 'history'
      final historyData = {
        'user_id': 'guest-user', 
        'product_id': widget.product.id,
        'quantity': quantity,
        'total_price': totalPrice,
        'start_date': DateFormat('yyyy-MM-dd').format(startDate!),
        'end_date': DateFormat('yyyy-MM-dd').format(endDate!),
        'status': 'paid',
        'created_at': DateTime.now().toIso8601String(),
      };
      await service.createHistory(historyData); //

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sewa Berhasil! Pesanan diproses dengan status: PAID'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyewa: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int diff = (startDate != null && endDate != null) ? endDate!.difference(startDate!).inDays : 0;
    final int displayDays = diff <= 0 && startDate != null && endDate != null ? 1 : diff;

    return Scaffold(
      appBar: AppBar(title: const Text('Form Sewa Alat')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('Tersedia: ${widget.product.stock} unit'),
            const Divider(height: 30),

            const Text('Jumlah Barang', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(
                  onPressed: quantity > 1 ? () => setState(() { quantity--; _updateTotal(); }) : null,
                  icon: const Icon(Icons.remove_circle),
                ),
                Text('$quantity', style: const TextStyle(fontSize: 20)),
                // PERBAIKAN: Tombol tambah akan memunculkan pesan jika melebihi stok
                IconButton(
                  onPressed: () {
                    if (quantity < widget.product.stock) {
                      setState(() { 
                        quantity++; 
                        _updateTotal(); 
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pesanan melebihi stock')),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_circle, color: Colors.blue),
                ),
              ],
            ),

            ListTile(
              leading: const Icon(Icons.date_range),
              title: Text(startDate == null ? 'Pilih Tanggal Mulai' : DateFormat('dd MMM yyyy').format(startDate!)),
              onTap: () => _pickDate(true),
              tileColor: Colors.grey[100],
            ),
            const SizedBox(height: 10),
            ListTile(
              leading: const Icon(Icons.date_range),
              title: Text(endDate == null ? 'Pilih Tanggal Selesai' : DateFormat('dd MMM yyyy').format(endDate!)),
              onTap: () => _pickDate(false),
              tileColor: Colors.grey[100],
            ),

            const SizedBox(height: 30),
            
            if (startDate != null && endDate != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue[50],
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [const Text('Durasi:'), Text('$displayDays hari')],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Bayar:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(currency.format(totalPrice), style: const TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.product.stock > 0 ? Colors.blue : Colors.grey,
                ),
                child: isLoading 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : Text(
                      widget.product.stock > 0 ? 'Sewa Sekarang' : 'Stock Habis', 
                      style: const TextStyle(color: Colors.white)
                    ),
              ),
            )
          ],
        ),
      ),
    );
  }
}