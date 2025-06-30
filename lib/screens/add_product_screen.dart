// lib/screens/admin/add_product_screen.dart (FINAL DENGAN LOGIC UPLOAD & SAVE)

import 'dart:typed_data';
import 'dart:io'; // Meskipun tidak dipakai di web, import ini kadang dibutuhkan oleh package lain secara internal
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _hargaController = TextEditingController();
  final _kategoriController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    _kategoriController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = pickedFile.name;
      });
    }
  }

  // --- INI FUNGSI YANG DI-UPGRADE TOTAL ---
  void _addProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedImageBytes == null || _selectedImageName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar produk terlebih dahulu.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    final apiService = ApiService();
    String? newFilename;

    try {
      // TAHAP 1: UPLOAD GAMBAR
      print('Uploading image...');
      newFilename = await apiService.uploadImage(_selectedImageBytes!, _selectedImageName!);
      
      if (newFilename == null) {
        throw Exception('Image upload failed, filename not received.');
      }
      print('Image uploaded, new filename: $newFilename');

      // TAHAP 2: SIMPAN DATA PRODUK
      final newMenu = Menu(
        idMenu: 0,
        namaMenu: _namaController.text,
        kategori: _kategoriController.text,
        harga: double.tryParse(_hargaController.text) ?? 0,
        isAvailable: true,
        image: newFilename, // Gunakan nama file baru dari server
      );
      
      print('Creating menu data...');
      final bool success = await apiService.createMenu(newMenu);

      if (success) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(true); // Kembali dengan sinyal sukses
      } else {
        throw Exception('Failed to create menu data.');
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // KODE UI TIDAK BERUBAH
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Add Product', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400, width: 1.5),
                        ),
                        child: _selectedImageBytes != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                              )
                            : const Center(
                                child: Text('Product Image', style: TextStyle(color: Colors.grey, fontSize: 16)),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _namaController,
                      labelText: 'Product Name',
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _hargaController,
                      labelText: 'Sell Price',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _kategoriController,
                      labelText: 'Category',
                    ),
                    // Kita tidak perlu input filename manual lagi
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _addProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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