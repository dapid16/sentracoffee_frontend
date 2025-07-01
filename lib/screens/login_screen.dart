// lib/screens/login_screen.dart (DENGAN LOGIKA STAFF)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/models/customer.dart';
import 'package:sentra_coffee_frontend/models/owner.dart';
import 'package:sentra_coffee_frontend/models/staff.dart'; // <<< TAMBAH IMPORT MODEL STAFF
import 'package:sentra_coffee_frontend/services/api_service.dart';
import 'package:sentra_coffee_frontend/services/auth_service.dart';
import 'package:sentra_coffee_frontend/services/admin_auth_service.dart';
import 'package:sentra_coffee_frontend/services/staff_auth_service.dart'; // <<< TAMBAH IMPORT SERVICE STAFF
import 'package:sentra_coffee_frontend/main.dart';
import 'package:sentra_coffee_frontend/utils/constants.dart';
import 'package:sentra_coffee_frontend/utils/text_styles.dart';
import 'package:sentra_coffee_frontend/screens/register_screen.dart';
import 'package:sentra_coffee_frontend/widgets/circular_icon_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _doUnifiedLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final apiService = ApiService();
    final response = await apiService.unifiedLogin(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (response['success'] == true) {
      final role = response['role'];
      final data = response['data'];

      if (role == 'admin') {
        Provider.of<AdminAuthService>(context, listen: false)
            .loginWithOwnerData(Owner.fromJson(data));
      } else if (role == 'customer') {
        Provider.of<AuthService>(context, listen: false)
            .loginWithCustomerData(Customer.fromJson(data));
      // --- PERUBAHAN DI SINI: Tambahkan penanganan untuk role 'staff' ---
      } else if (role == 'staff') {
        Provider.of<StaffAuthService>(context, listen: false)
            .loginWithStaffData(Staff.fromJson(data));
      }
      // --- BATAS PERUBAHAN ---

      // Navigasi ke AuthWrapper yang akan menentukan halaman tujuan
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (Route<dynamic> route) => false,
      );

    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Login gagal.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // KODE UI TIDAK ADA YANG BERUBAH, SAYA TAMPILKAN SEBAGAI RINGKASAN
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
                  'Sign in',
                  style: AppTextStyles.h1.copyWith(color: AppColors.textColor),
                ),
                const SizedBox(height: 10),
                Text(
                  'Welcome to Sentra Coffee App',
                  style:
                      AppTextStyles.bodyText1.copyWith(color: AppColors.greyText),
                ),
                const SizedBox(height: 50),
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
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      print('Forgot Password tapped!');
                    },
                    child: Text(
                      'Forgot Password?',
                      style: AppTextStyles.bodyText2
                          .copyWith(color: AppColors.greyText),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Align(
                  alignment: Alignment.centerRight,
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.primaryColor)
                      : CircularIconButton(
                          backgroundColor: AppColors.darkGrey,
                          onPressed: _doUnifiedLogin,
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
                        'New member?',
                        style: AppTextStyles.bodyText1
                            .copyWith(color: AppColors.greyText),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const RegisterScreen()));
                        },
                        child: Text(
                          'Sign up',
                          style: AppTextStyles.bodyText1.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.bold),
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

  Widget _buildTextField(
      {required TextEditingController controller,
      required String labelText,
      required String hintText,
      TextInputType keyboardType = TextInputType.text,
      bool obscureText = false,
      Widget? suffixIcon,
      String? Function(String?)? validator}) {
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
        labelStyle:
            AppTextStyles.bodyText2.copyWith(color: AppColors.greyText),
        hintStyle: AppTextStyles.bodyText2
            .copyWith(color: AppColors.greyText.withOpacity(0.7)),
        fillColor: AppColors.backgroundColor,
        filled: true,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 0.0),
      ),
    );
  }
}