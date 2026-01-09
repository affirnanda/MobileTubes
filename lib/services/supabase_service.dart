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
        .order('created_at', ascending: false); // Urutkan dari yang terbaru
  }
  
  // Update stock (Pengurangan)
  Future<void> updateProductStock(String productId, int newStock) async {
    await supabase
        .from('products')
        .update({'stock': newStock})
        .eq('id', productId);
  }

  // PERBAIKAN: Fungsi untuk mengembalikan stok (Penambahan)
  Future<void> returnProductStock(String productId, int quantityReturned) async {
    // Ambil stok saat ini terlebih dahulu
    final response = await supabase
        .from('products')
        .select('stock')
        .eq('id', productId)
        .single();
    
    int currentStock = response['stock'] as int;
    
    // Update dengan stok baru
    await supabase
        .from('products')
        .update({'stock': currentStock + quantityReturned})
        .eq('id', productId);
  }

  // PERBAIKAN: Update status di tabel history
  Future<void> updateHistoryStatus(String historyId, String status) async {
    await supabase
        .from('history')
        .update({'status': status})
        .eq('id', historyId);
  }
}