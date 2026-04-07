import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'state/asset_state.dart';
import 'pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  runApp(const AssetTrackerApp());
}

class AssetTrackerApp extends StatefulWidget {
  const AssetTrackerApp({super.key});

  @override
  State<AssetTrackerApp> createState() => _AssetTrackerAppState();
}

class _AssetTrackerAppState extends State<AssetTrackerApp> {
  final AssetState _assetState = AssetState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '資產追蹤面板',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: GoogleFonts.notoSansTcTextTheme(),
        useMaterial3: true,
      ),
      home: HomePage(assetState: _assetState),
    );
  }
}
