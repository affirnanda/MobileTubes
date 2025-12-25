import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/supabase_service.dart';
import 'product_detail_page.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = SupabaseService();

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Alat Gym')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: service.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Data produk kosong'));
          }

          final products = snapshot.data!
              .where((e) =>
                  e['name'] != null &&
                  e['price_per_day'] != null &&
                  e['stock'] != null)
              .map((e) => Product.fromMap(e))
              .toList();

          if (products.isEmpty) {
            return const Center(
              child: Text('Semua data produk tidak valid'),
            );
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return ListTile(
                title: Text(product.name),
                subtitle: Text(
                  'Rp ${product.pricePerDay.toStringAsFixed(0)} / hari',
                ),
                trailing: product.isAvailable
                    ? const Icon(Icons.check_circle, color: Colors.green)
                    : const Icon(Icons.cancel, color: Colors.red),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProductDetailPage(product: product),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
