import 'package:flutter/material.dart';
import 'dart:async';
import 'package:APK_TRAYA/components.dart';
import 'package:APK_TRAYA/views/main_navigation.dart';

const Color orangeTraya = Color(0xFFEF8E6E);
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LandingPage()));
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
                const Text('Bergabung Sekarang', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: brownTraya)),
                const Text('temukan kebutuhanmu\natau mulai usahamu', textAlign: TextAlign.center),
                const SizedBox(height: 30),
                Image.asset('assets/shop.png', width: 250),
                const SizedBox(height: 40),
                BigButton(
                  text: 'Daftar Akun Baru',
                  backgroundColor: orangeTraya,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                ),
                const SizedBox(height: 18),
                BigButton(
                  text: 'Sudah Punya Akun? Masuk',
                  backgroundColor: const Color(0xFFDADADA),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// HALAMAN LOGIN REPLIKASI DARI Log in.png
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Image.asset('assets/halaman_awal.jpg', fit: BoxFit.cover, height: 160, alignment: Alignment.topCenter),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 140, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Masuk', style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: brownTraya)),
                  const SizedBox(height: 30),
                  _buildCustomTextField('Nama pengguna'),
                  const SizedBox(height: 16),
                  _buildCustomTextField('Password', isPassword: true),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text("Lupa Password?", style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  BigButton(
                    text: 'Masuk',
                    backgroundColor: const Color(0xFFFBA07A),
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigation())),
                  ),
                  const SizedBox(height: 20),
                  const Center(child: Text('Atau', style: TextStyle(color: Colors.grey))),
                  const SizedBox(height: 20),
                  const SocialButton(icon: Icons.g_mobiledata_rounded, text: 'Masuk dengan Google'),
                  const SizedBox(height: 12),
                  const SocialButton(icon: Icons.apple, text: 'Masuk dengan Apple'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// HALAMAN REGISTER REPLIKASI DARI daftar.png
class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0, left: 0, right: 0,
            child: Image.asset('assets/halaman_awal.jpg', fit: BoxFit.cover, height: 160, alignment: Alignment.topCenter),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 140, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daftar', style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: brownTraya)),
                  const SizedBox(height: 24),
                  _buildCustomTextField('Nama Pengguna'),
                  const SizedBox(height: 16),
                  _buildCustomTextField('No Hp/Email'),
                  const SizedBox(height: 16),
                  _buildCustomTextField('Password', isPassword: true),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(value: true, onChanged: (_) {}),
                      const Expanded(child: Text('Saya setuju dengan Syarat & Ketentuan & Kebijakan Privasi', style: TextStyle(fontSize: 11))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BigButton(
                    text: 'Daftar',
                    backgroundColor: const Color(0xFFFBA07A),
                    onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigation())),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildCustomTextField(String hint, {bool isPassword = false}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFEFEFEF),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: const Color(0xFFFBA07A)),
    ),
    child: TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        border: InputBorder.none,
      ),
    ),
  );
}