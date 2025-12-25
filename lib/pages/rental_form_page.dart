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
  double totalPrice = 0;

  final SupabaseService service = SupabaseService();

  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }

        if (startDate != null && endDate != null) {
          final days = endDate!.difference(startDate!).inDays + 1;
          totalPrice = days * widget.product.pricePerDay;
        }
      });
    }
  }

  Future<void> submitOrder() async {
    if (startDate == null || endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal sewa')),
      );
      return;
    }

    final data = {
      'user_id': 'guest-user', // sementara (nanti dari auth)
      'product_id': widget.product.id,
      'start_date': startDate!.toIso8601String(),
      'end_date': endDate!.toIso8601String(),
      'total_price': totalPrice,
      'status': 'pending',
      'payment_status': 'unpaid',
      'payment_method': 'manual',
    };

    await service.createOrder(data);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sewa berhasil dibuat')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Sewa')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.product.name,
                style: Theme.of(context).textTheme.titleLarge),

            const SizedBox(height: 16),

            ListTile(
              title: Text(
                startDate == null
                    ? 'Pilih tanggal mulai'
                    : DateFormat('dd MMM yyyy').format(startDate!),
              ),
              trailing: const Icon(Icons.date_range),
              onTap: () => pickDate(true),
            ),

            ListTile(
              title: Text(
                endDate == null
                    ? 'Pilih tanggal selesai'
                    : DateFormat('dd MMM yyyy').format(endDate!),
              ),
              trailing: const Icon(Icons.date_range),
              onTap: () => pickDate(false),
            ),

            const SizedBox(height: 16),

            Text(
              'Total Harga: Rp ${totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submitOrder,
                child: const Text('Sewa Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
