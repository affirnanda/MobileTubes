import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'rental_form_page.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(product.description),
            const SizedBox(height: 10),
            Text('Harga: Rp ${product.pricePerDay}/hari'),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Sewa Alat'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RentalFormPage(product: product),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
