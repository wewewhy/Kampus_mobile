import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../services/api_service.dart';
import 'login_page.dart';
import 'dashboard_shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  bool _showWelcome = false;
  bool _showHome = true;

  @override
  void initState() {
    super.initState();
    _checkAndValidateSession();
  }

  Future<void> _checkAndValidateSession() async {
    // 1. Cek apakah ini pertama kali instal aplikasi
    final isFirst = !(await ApiService.isFirstOpen());
    if (isFirst) {
      setState(() => _showWelcome = true);
      await ApiService.setFirstOpen();
      await Future.delayed(const Duration(seconds: 6));
      setState(() => _showWelcome = false);
    }

    // 2. Tampilkan loading minimal 2 detik agar tidak terlalu cepat berkedip
    await Future.delayed(const Duration(seconds: 4));

    // 3. Cek Token Lokal
    final token = await ApiService.getToken();
    if (!mounted) return;

    if (token != null) {
      // 4. VALIDASI TOKEN KE LARAVEL (Ping server)
      // Kita panggil getDashboard untuk memastikan token masih aktif di database
      try {
        final checkSession = await ApiService.getDashboard();

        if (!mounted) return;

        // Jika response memiliki key 'events', berarti Laravel mengizinkan (Token Valid)
        if (checkSession.containsKey('events')) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const DashboardShell()));
        } else {
          // Token ditolak oleh Laravel (mungkin expired/revoked) -> Hapus sesi & ke Login
          await ApiService.clearToken();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => const LoginPage()));
        }
      } catch (e) {
        // Jika tidak ada koneksi internet, tetap lempar ke Dashboard agar
        // error handling di HomePage yang menangani pesan "No Internet"
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const DashboardShell()));
      }
    } else {
      // Jika token lokal kosong, langsung ke Login
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: Center(
        child: _showWelcome
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Fallback icon jika file lottie belum kamu download
                  _buildLottieOrIcon(
                      'assets/animations/welcome.json', Icons.handshake, 120),
                  const SizedBox(height: 24),
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Dashboard Kampus Mobile',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLottieOrIcon(
                      'assets/animations/home.json', Icons.school, 100),
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(color: Colors.white),
                ],
              ),
      ),
    );
  }

  // Helper function agar aplikasi tidak crash jika file .json animasi Lottie belum ada
  Widget _buildLottieOrIcon(String path, IconData fallbackIcon, double size) {
    try {
      return Lottie.asset(
        path,
        width: size * 2,
        errorBuilder: (context, error, stackTrace) {
          return Icon(fallbackIcon, size: size, color: Colors.white);
        },
      );
    } catch (e) {
      return Icon(fallbackIcon, size: size, color: Colors.white);
    }
  }
}
