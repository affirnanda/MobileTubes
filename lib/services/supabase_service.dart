import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  // View Product
  Future<List<Map<String, dynamic>>> getProducts() async {
    return await supabase.from('products').select();
  }

  // Insert Pesan (Rental)
  Future<void> createOrder(Map<String, dynamic> data) async {
    await supabase.from('pesan').insert(data);
  }

  // Insert History
  Future<void> createHistory(Map<String, dynamic> data) async {
    await supabase.from('history').insert(data);
  }

  // View History
  Future<List<Map<String, dynamic>>> getHistory(String userId) async {
    return await supabase
        .from('history')
        .select()
        .eq('user_id', userId);
  }
  // update stock
  Future<void> updateProductStock(String productId, int newStock) async {
  await supabase
      .from('products')
      .update({'stock': newStock})
      .eq('id', productId);
  }
}
