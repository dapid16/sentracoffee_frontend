// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/services/auth_service.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart';
import 'package:sentra_coffee_frontend/utils/text_styles.dart';
import 'package:sentra_coffee_frontend/screens/login_screen.dart';
import 'package:sentra_coffee_frontend/widgets/circular_icon_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus menyetujui Ketentuan Penggunaan.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      final String message = await authService.register(
        _nameController.text, // Pastikan nama dikirim
        _emailController.text,
        _passwordController.text,
        _phoneController.text.isEmpty ? null : _phoneController.text,
      );

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: message.contains('Berhasil') ? Colors.green : Colors.red,
        ),
      );

      if (message.contains('Berhasil')) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: CircularIconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icons.arrow_back,
            size: 40,
            backgroundColor: AppColors.darkGrey,
            iconColor: Colors.white,
            elevation: 0,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign up',
                  style: AppTextStyles.h1.copyWith(color: AppColors.textColor),
                ),
                const SizedBox(height: 10),
                Text(
                  'Create an account here',
                  style: AppTextStyles.bodyText1.copyWith(color: AppColors.greyText),
                ),
                const SizedBox(height: 50),

                // --- TAMBAHKAN INPUT FIELD NAMA DI SINI ---
                _buildTextField(
                  controller: _nameController,
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap Anda',
                  keyboardType: TextInputType.text,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20), // Jarak ke field berikutnya
                // --- AKHIR TAMBAH INPUT FIELD NAMA ---

                // Mobile Number
                _buildTextField(
                  controller: _phoneController,
                  labelText: 'Mobile Number',
                  hintText: 'Masukkan nomor telepon Anda',
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor HP tidak boleh kosong';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Nomor HP hanya boleh angka';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Email address
                _buildTextField(
                  controller: _emailController,
                  labelText: 'Email address',
                  hintText: 'Masukkan alamat email Anda',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password
                _buildTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  hintText: 'Masukkan password Anda',
                  obscureText: _obscureText,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.greyText,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                Row(
                  children: [
                    Checkbox(
                      value: _agreeToTerms,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _agreeToTerms = newValue ?? false;
                        });
                      },
                      activeColor: AppColors.primaryColor,
                    ),
                    Expanded(
                      child: Text(
                        'By signing up you agree with our Terms of Use',
                        style: AppTextStyles.bodyText2.copyWith(color: AppColors.greyText),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                Align(
                  alignment: Alignment.centerRight,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.primaryColor)
                      : CircularIconButton(
                          backgroundColor: AppColors.darkGrey,
                          onPressed: _register,
                          icon: Icons.arrow_forward,
                          size: 60,
                          iconColor: Colors.white,
                        ),
                ),
                const SizedBox(height: 60),

                Align(
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already a member?',
                        style: AppTextStyles.bodyText1.copyWith(color: AppColors.greyText),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                        },
                        child: Text(
                          'Sign in',
                          style: AppTextStyles.bodyText1.copyWith(color: AppColors.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      style: AppTextStyles.bodyText1.copyWith(color: AppColors.textColor),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixIcon: suffixIcon,
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.greyText),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.greyText),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        labelStyle: AppTextStyles.bodyText2.copyWith(color: AppColors.greyText),
        hintStyle: AppTextStyles.bodyText2.copyWith(color: AppColors.greyText.withOpacity(0.7)),
        fillColor: AppColors.backgroundColor,
        filled: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 0.0),
      ),
    );
  }
}