import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart'; 
import 'package:flutter_localizations/flutter_localizations.dart'; // 1. IMPORT INI
import 'pages/product_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://ihgfycavheftuuaxunms.supabase.co',
    anonKey: 'sb_publishable_slupq8-a1Uy1k4B7GNoZDA_RDdEmIg5',
  );
  
  // Inisialisasi format tanggal bahasa Indonesia
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
        primaryColor: Colors.blue, // primarySwatch diganti primaryColor di Material3
        useMaterial3: true,
      ),
      // --- TAMBAHKAN KODE DI BAWAH INI ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'), // Bahasa Indonesia
        Locale('en', 'US'), // Bahasa Inggris (opsional sebagai cadangan)
      ],
      // -----------------------------------
      home: const ProductPage(),
    );
  }
}