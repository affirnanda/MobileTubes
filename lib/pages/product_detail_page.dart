import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';
import 'rental_form_page.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 350,
                  width: double.infinity,
                  child: product.imageUrl != null
                      ? Image.network(product.imageUrl!, fit: BoxFit.cover)
                      : Container(color: Colors.grey[300], child: const Icon(Icons.sports, size: 120)),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Chip(
                    backgroundColor: product.stock > 0 ? Colors.green : Colors.red,
                    label: Text(product.stock > 0 ? 'Stok: ${product.stock}' : 'Stok Habis', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text('Kategori: ${product.category}'),
                  const SizedBox(height: 16),
                  Text('Harga Sewa: ${currency.format(product.pricePerDay)} / hari', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 20),
                  Text(product.description.isEmpty ? 'Alat olahraga berkualitas tinggi.' : product.description),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: product.stock <= 0 ? null : () => Navigator.push(context, MaterialPageRoute(builder: (_) => RentalFormPage(product: product))),
                      child: Text(product.stock > 0 ? 'Sewa Sekarang' : 'Stok Habis'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}