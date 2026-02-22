import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCAD7CD),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 30,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Color(0xFF2D503C),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Halo!',
                      style: TextStyle(fontSize: 16, color: Color(0xFF2D503C)),
                    ),
                    const Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D503C),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFF2D503C),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50),
                  ),
                ),
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildRegisterField(
                      label: 'nama',
                      hint: 'Masukkan nama lengkap',
                      icon: Icons.person,
                      controller: _nameController,
                    ),
                    const SizedBox(height: 20),
                    _buildRegisterField(
                      label: 'email',
                      hint: 'email@contoh.com',
                      icon: Icons.email,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 20),
                    _buildRegisterField(
                      label: 'password',
                      hint: '*********',
                      icon: Icons.lock,
                      controller: _passwordController,
                      isPassword: true,
                    ),
                    const SizedBox(height: 40),
                    _buildActionButton(context),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "Sudah punya akun? Login di sini",
                        style: TextStyle(color: Color(0xFFCAD7CD)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFCAD7CD),
          foregroundColor: const Color(0xFF2D503C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: auth.isLoading
            ? null
            : () async {
                if (_nameController.text.isEmpty ||
                    _emailController.text.isEmpty ||
                    _passwordController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Semua kolom harus diisi")),
                  );
                  return;
                }
                try {
                  await context.read<AuthProvider>().signUp(
                    email: _emailController.text.trim(),
                    password: _passwordController.text.trim(),
                    name: _nameController.text.trim(),
                  );
                  if (mounted) Navigator.pushReplacementNamed(context, '/home');
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Gagal: $e")));
                }
              },
        child: Text(
          auth.isLoading ? 'Mendaftarkan...' : 'Register',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }

  Widget _buildRegisterField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Color(0xFF2D503C)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black26),
            prefixIcon: Icon(icon, color: const Color(0xFF2D503C)),
            filled: true,
            fillColor: const Color(0xFFCAD7CD).withOpacity(0.9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}
