import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/supabase_service.dart';
import 'product_detail_page.dart';
import 'history_page.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  String selectedCategory = 'Semua';
  final SupabaseService service = SupabaseService();

  Future<List<Product>> fetchProducts() async {
    final raw = await service.getProducts();
    return raw.map((e) => Product.fromMap(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SPORTMATE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage())),
          )
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) return const Center(child: Text('Belum ada produk'));

          final categories = ['Semua', ...products.map((p) => p.category).toSet()];

          final filtered = selectedCategory == 'Semua'
              ? products
              : products.where((p) => p.category == selectedCategory).toList();

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: categories.map((cat) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: selectedCategory == cat,
                      onSelected: (_) => setState(() => selectedCategory = cat),
                    ),
                  )).toList(),
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final p = filtered[index];
                    return Card(
                      child: InkWell(
                        onTap: p.stock > 0
                            ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(product: p)))
                            : () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stok habis'))),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: p.imageUrl != null
                                    ? Image.network(p.imageUrl!, fit: BoxFit.cover)
                                    : Container(color: Colors.grey[300], child: const Icon(Icons.sports, size: 80)),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  Text('Rp ${p.pricePerDay.toStringAsFixed(0)} / hari'),
                                  Text('Stok: ${p.stock}', style: TextStyle(color: p.stock > 0 ? Colors.green : Colors.red)),
                                  Text(p.category, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}