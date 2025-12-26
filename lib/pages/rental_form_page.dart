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
    if (startDate != null && endDate != null && endDate!.isAfter(startDate!)) {
      final int days = endDate!.difference(startDate!).inDays + 1;
      totalPrice = quantity * days * widget.product.pricePerDay;
    } else {
      totalPrice = 0.0;
    }
    setState(() {});
  }

  Future<void> _pickDate(bool isStart) async {
    final DateTime initialDate = isStart
        ? (startDate ?? DateTime.now())
        : (endDate ?? DateTime.now().add(const Duration(days: 1)));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      locale: const Locale('id', 'ID'),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
          // Reset tanggal selesai jika lebih awal dari tanggal mulai
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

  Future<void> _submit() async {
    // Validasi quantity
    if (quantity > widget.product.stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Jumlah melebihi stok tersedia (${widget.product.stock} unit)')),
      );
      return;
    }

    // Validasi tanggal
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mulai dan selesai sewa')),
      );
      return;
    }

    if (endDate!.isBefore(startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal selesai harus setelah tanggal mulai')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Kurangi stok
      final int newStock = widget.product.stock - quantity;
      await service.updateProductStock(widget.product.id, newStock);

      // Hitung durasi
      final int days = endDate!.difference(startDate!).inDays + 1;

      // Insert pesanan
      final orderData = {
        'user_id': 'guest-user',
        'product_id': widget.product.id,
        'quantity': quantity,
        'start_date': startDate!.toIso8601String(),
        'end_date': endDate!.toIso8601String(),
        'days': days,
        'total_price': totalPrice,
        'status': 'pending',
        'payment_status': 'unpaid',
        'payment_method': 'manual',
        'created_at': DateTime.now().toIso8601String(),
      };

      await service.createOrder(orderData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sewa $quantity unit berhasil dibuat!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyewa: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final int days = (startDate != null && endDate != null && endDate!.isAfter(startDate!))
        ? endDate!.difference(startDate!).inDays + 1
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Sewa Alat'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: widget.product.imageUrl != null
                    ? Image.network(
                        widget.product.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            height: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.sports_soccer, size: 80),
                        ),
                      )
                    : Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.sports_soccer, size: 80),
                      ),
              ),
            ),
            const SizedBox(height: 20),

            // Info Produk
            Text(
              widget.product.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Kategori: ${widget.product.category}'),
            Text(
              'Stok tersedia: ${widget.product.stock} unit',
              style: TextStyle(
                color: widget.product.stock >= quantity ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Harga: ${currency.format(widget.product.pricePerDay)} / hari / unit'),

            const Divider(height: 40),

            // Quantity Picker
            const Text('Jumlah Barang yang Disewa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: quantity > 1 ? () => setState(() => quantity--) : null,
                  icon: const Icon(Icons.remove_circle_outline, size: 40),
                  color: quantity > 1 ? Colors.blue : Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '$quantity',
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: quantity < widget.product.stock ? () => setState(() => quantity++) : null,
                  icon: const Icon(Icons.add_circle_outline, size: 40),
                  color: quantity < widget.product.stock ? Colors.blue : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Maksimal: ${widget.product.stock} unit',
                style: const TextStyle(color: Colors.grey),
              ),
            ),

            const SizedBox(height: 24),

            // Tanggal Mulai
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.blue),
                title: Text(
                  startDate == null
                      ? 'Pilih Tanggal Mulai Sewa'
                      : DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(startDate!),
                ),
                subtitle: startDate == null ? const Text('Wajib dipilih') : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickDate(true),
              ),
            ),
            const SizedBox(height: 12),

            // Tanggal Selesai
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month, color: Colors.green),
                title: Text(
                  endDate == null
                      ? 'Pilih Tanggal Selesai Sewa'
                      : DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(endDate!),
                ),
                subtitle: endDate == null ? const Text('Wajib dipilih') : null,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _pickDate(false),
              ),
            ),

            const SizedBox(height: 24),

            // Ringkasan Harga
            if (days > 0)
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Jumlah Barang'),
                          Text('$quantity unit', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Durasi Sewa'),
                          Text('$days hari', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Harga per Hari/Unit'),
                          Text(currency.format(widget.product.pricePerDay)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Harga', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            currency.format(totalPrice),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 40),

            // Tombol Sewa
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                          SizedBox(width: 16),
                          Text('Memproses...', style: TextStyle(color: Colors.white, fontSize: 18)),
                        ],
                      )
                    : Text(
                        'Sewa Sekarang (${currency.format(totalPrice)})',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}