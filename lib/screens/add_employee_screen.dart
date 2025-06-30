// lib/screens/admin/add_employee_screen.dart (SESUAI DESAIN FIGMA)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sentra_coffee_frontend/models/staff.dart';
import 'package:sentra_coffee_frontend/services/admin_auth_service.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';

class AddEmployeeScreen extends StatefulWidget {
  const AddEmployeeScreen({Key? key}) : super(key: key);

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _roleController = TextEditingController();
  final _noHpController = TextEditingController();

  bool _isLoading = false;
  bool _obscureText = true;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _roleController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  void _saveStaff() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final adminAuthService = Provider.of<AdminAuthService>(context, listen: false);
      final ownerId = adminAuthService.currentOwner?.idOwner;

      if (ownerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Owner ID not found. Please re-login.'), backgroundColor: Colors.red),
        );
        setState(() => _isLoading = false);
        return;
      }
      
      final apiService = ApiService();
      final bool success = await apiService.createStaff(
        namaStaff: _namaController.text,
        email: _emailController.text,
        password: _passwordController.text,
        role: _roleController.text,
        noHp: _noHpController.text,
        idOwner: ownerId,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Karyawan baru berhasil ditambahkan!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true); // Kembali dengan sinyal sukses
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan karyawan.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Add Employee',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _namaController,
                      labelText: 'Employee Name',
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _noHpController,
                      labelText: 'Phone Number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _emailController,
                      labelText: 'Email Address',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _roleController,
                      labelText: 'Position',
                    ),
                    const SizedBox(height: 24),
                    // --- FIELD PASSWORD YANG DITAMBAHKAN ---
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(color: Colors.grey),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
                        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                      ),
                      validator: (value) => value!.isEmpty ? 'Password tidak boleh kosong' : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // --- TOMBOL ADD DI BAGIAN BAWAH ---
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveStaff,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text('Add', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper untuk input text sesuai desain
  Widget _buildTextField({required TextEditingController controller, required String labelText, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
      ),
      validator: (value) => value!.isEmpty ? '$labelText tidak boleh kosong' : null,
    );
  }
}