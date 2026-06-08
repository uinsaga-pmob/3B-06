import 'package:flutter/material.dart';
import 'dart:async';
import 'package:APK_TRAYA/components.dart';
import 'package:APK_TRAYA/views/main_navigation.dart';

const Color orangeTraya = Color(0xFFF69C73);
const Color brownTraya = Color(0xFF7F2F00);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LandingPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: Image.asset('assets/logo.png', width: 180)),
    );
  }
}

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Text(
                  'Bergabung Sekarang',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: brownTraya,
                  ),
                ),
                const Text(
                  'Temukan pakaian preloved terbaik di TRaya',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                Image.asset('assets/shop.png', width: 220),
                const SizedBox(height: 40),
                BigButton(
                  text: 'Daftar Akun Baru',
                  backgroundColor: orangeTraya,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  ),
                ),
                const SizedBox(height: 14),
                BigButton(
                  text: 'Masuk Ke Akun Kelompok',
                  backgroundColor: const Color(0xFFEFEFEF),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                ),
                const SizedBox(height: 20),

                // TOMBOL GUEST MODE BARU (Membuka Akses Tanpa Login)
                TextButton.icon(
                  icon: const Icon(Icons.arrow_forward, color: brownTraya),
                  label: const Text(
                    "Lewati & Masuk Sebagai Tamu",
                    style: TextStyle(
                      color: brownTraya,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MainNavigation(isGuest: true),
                      ), // Mengaktifkan Mode Guest
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _inputController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: brownTraya),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Masuk Akun',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: brownTraya,
              ),
            ),
            const SizedBox(height: 30),
            _buildField(
              "Username atau Email Kelompok",
              _inputController,
              false,
            ),
            const SizedBox(height: 16),
            _buildField("Password", _passwordController, true),
            const SizedBox(height: 30),
            BigButton(
              text: 'Masuk Aplikasi',
              backgroundColor: orangeTraya,
              onTap: () async {
                final String inputUser = _inputController.text.trim();
                final String inputPass = _passwordController.text.trim();

                if (inputUser.isEmpty || inputPass.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Username/Email dan Password wajib diisi!"),
                    ),
                  );
                  return;
                }

                // 1. Validasi akun ke database secara riil
                final Map<String, dynamic>? userAccount = await DbHelper()
                    .loginUser(inputUser, inputPass);

                if (userAccount != null) {
                  // 2. Ambil email asli milik akun yang berhasil login secara dinamis
                  final String emailDinamis = userAccount['email'];

                  // 3. Suntik Notifikasi khusus ke laci pemilik akun asli tersebut
                  await DbHelper().addNotification(
                    emailDinamis, // SEKARANG DINAMIS, bukan "zen@traya.com" lagi
                    "Login Berhasil",
                    "Akun Anda berhasil masuk menggunakan perangkat Infinix. Amankan selalu password Anda.",
                    "login",
                  );

                  if (!mounted) return;
                  // 4. Masuk ke navigasi utama sebagai Member resmi (isGuest: false)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MainNavigation(isGuest: false),
                    ),
                  );
                } else {
                  if (!mounted) return;
                  // Gagal validasi jika data tidak cocok di SQLite
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Gagal Masuk! Username atau Password salah.",
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: brownTraya),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daftar Akun',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: brownTraya,
              ),
            ),
            const SizedBox(height: 30),
            _buildField(
              "Nama Lengkap Kelompok",
              TextEditingController(),
              false,
            ),
            const SizedBox(height: 16),
            _buildField("Email Toko", TextEditingController(), false),
            const SizedBox(height: 16),
            _buildField("Kata Sandi", TextEditingController(), true),
            const SizedBox(height: 40),
            BigButton(
              text: 'Daftar Akun Baru',
              backgroundColor: orangeTraya,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainNavigation(isGuest: false),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Reset Password")));
  }
}

Widget _buildField(String hint, TextEditingController ctr, bool obscure) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    decoration: BoxDecoration(
      color: const Color(0xFFF6F6F6),
      borderRadius: BorderRadius.circular(15),
    ),
    child: TextField(
      controller: ctr,
      obscureText: obscure,
      decoration: InputDecoration(hintText: hint, border: InputBorder.none),
    ),
  );
}

// Minimal DbHelper stub to satisfy usage in this file.
// Replace with real implementation in your data layer if available.
class DbHelper {
  Future<Map<String, dynamic>?> loginUser(
    String username,
    String password,
  ) async {
    // Return null by default (login failed). Implement real DB lookup elsewhere.
    return null;
  }

  Future<void> addNotification(
    String email,
    String title,
    String body,
    String type,
  ) async {
    // No-op stub. Replace with actual notification insertion logic.
    return;
  }
}
