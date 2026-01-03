import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'giris_ekrani.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const DestekCepteApp());
}

class DestekCepteApp extends StatelessWidget {
  const DestekCepteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Destek Cepte',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF00796B), // Daha modern bir Teal tonu
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Hafif gri arka plan
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00796B),
          secondary: const Color(0xFFFFA000), // Amber vurgu rengi
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF00796B),
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00796B),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
      home: const RolSecimiEkrani(),
    );
  }
}

// --- 1. EKRAN: ROL SEÇİMİ ---
class RolSecimiEkrani extends StatelessWidget {
  const RolSecimiEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE0F2F1), Colors.white],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // LOGO VE İKON
                Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.volunteer_activism,
                    size: 70,
                    color: Color(0xFF00796B),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Destek Cepte",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004D40),
                    letterSpacing: 1.2,
                  ),
                ),
                const Text(
                  "Eğitime Destek Köprüsü",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 60),

                // ÖĞRENCİ BUTONU
                _buildRoleButton(
                  context,
                  title: "Öğrenciyim",
                  icon: Icons.school,
                  color: const Color(0xFF00796B),
                  rol: "ogrenci",
                ),
                const SizedBox(height: 20),

                // BAĞIŞÇI BUTONU
                _buildRoleButton(
                  context,
                  title: "Bağışçıyım",
                  icon: Icons.handshake,
                  color: const Color(0xFFFFA000),
                  rol: "bagisci",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String rol,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 28),
        label: Text(title, style: const TextStyle(fontSize: 20)),
        style: ElevatedButton.styleFrom(backgroundColor: color),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GirisEkrani(secilenRol: rol),
            ),
          );
        },
      ),
    );
  }
}
