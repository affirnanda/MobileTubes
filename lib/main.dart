
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'pages/product_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://ihgfycavheftuuaxunms.supabase.co',
    anonKey: 'sb_publishable_slupq8-a1Uy1k4B7GNoZDA_RDdEmIg5',
  );
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPORTMATE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ProductPage(),
    );
  }
}