// lib/screens/admin/add_product_screen.dart (FINAL BISA ADD & EDIT)

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  // --- PERUBAHAN #1: Tambahkan properti untuk menerima data menu yang akan diedit ---
  final Menu? menuToEdit;

  const AddProductScreen({Key? key, this.menuToEdit}) : super(key: key);

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

  // --- PERUBAHAN #2: Tambahkan variabel untuk mode edit dan URL gambar lama ---
  bool _isEditMode = false;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    // --- PERUBAHAN #3: Cek jika ini mode EDIT saat halaman pertama kali dibuka ---
    if (widget.menuToEdit != null) {
      _isEditMode = true;
      final menu = widget.menuToEdit!;

      // Isi semua controller dengan data dari produk yang akan diedit
      _namaController.text = menu.namaMenu;
      _hargaController.text = menu.harga.toStringAsFixed(0);
      _kategoriController.text = menu.kategori;
      
      // Simpan URL gambar yang sudah ada untuk ditampilkan
      if (menu.image != null && menu.image!.isNotEmpty) {
        // Ganti 'localhost' dengan IP Address jika menjalankan di HP asli
        _existingImageUrl = 'http://localhost/SentraCoffee/uploads/${menu.image}';
      }
    }
  }

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

  // --- PERUBAHAN #4: Ubah nama fungsi dari _addProduct menjadi _saveProduct dan rombak total logikanya ---
  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Validasi gambar hanya wajib untuk mode Add, di mode Edit gambar opsional
    if (!_isEditMode && (_selectedImageBytes == null || _selectedImageName == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar produk terlebih dahulu.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    final apiService = ApiService();
    String? finalImageFilename;

    try {
      // TAHAP 1: UPLOAD GAMBAR JIKA ADA GAMBAR BARU YANG DIPILIH
      if (_selectedImageBytes != null && _selectedImageName != null) {
        print('Uploading new image...');
        finalImageFilename = await apiService.uploadImage(_selectedImageBytes!, _selectedImageName!);
        if (finalImageFilename == null) {
          throw Exception('Image upload failed, filename not received.');
        }
        print('Image uploaded, new filename: $finalImageFilename');
      } else if (_isEditMode) {
        // Jika mode edit dan tidak ada gambar baru, pakai nama file gambar yang lama
        finalImageFilename = widget.menuToEdit!.image;
      }

      // TAHAP 2: SIMPAN ATAU UPDATE DATA PRODUK
      if (_isEditMode) {
        // --- LOGIKA UNTUK UPDATE ---
        final updatedMenu = Menu(
          idMenu: widget.menuToEdit!.idMenu, // Pakai ID yang sudah ada
          namaMenu: _namaController.text,
          kategori: _kategoriController.text,
          harga: double.tryParse(_hargaController.text) ?? 0,
          isAvailable: widget.menuToEdit!.isAvailable, // Asumsi status tidak diubah di sini
          image: finalImageFilename, // Pakai nama file baru (jika ada) atau yang lama
        );
        print('Updating menu data...');
        // Pastikan ada method updateMenu di ApiService
        final bool success = await apiService.updateMenu(updatedMenu);
        if (!success) throw Exception('Failed to update menu data.');

      } else {
        // --- LOGIKA UNTUK CREATE (YANG LAMA) ---
        final newMenu = Menu(
          idMenu: 0,
          namaMenu: _namaController.text,
          kategori: _kategoriController.text,
          harga: double.tryParse(_hargaController.text) ?? 0,
          isAvailable: true,
          image: finalImageFilename,
        );
        print('Creating menu data...');
        final bool success = await apiService.createMenu(newMenu);
        if (!success) throw Exception('Failed to create menu data.');
      }
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Produk berhasil ${_isEditMode ? 'diperbarui' : 'ditambahkan'}!'), 
          backgroundColor: Colors.green
        ),
      );
      Navigator.of(context).pop(true);

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        // --- PERUBAHAN #5: Judul AppBar dinamis sesuai mode ---
        title: Text(
          _isEditMode ? 'Edit Product' : 'Add Product', 
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
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
                        // --- PERUBAHAN #6: Logika tampilan gambar yang lebih kompleks ---
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: _selectedImageBytes != null
                              // 1. Prioritas: Tampilkan gambar baru yang dipilih
                              ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                              // 2. Jika tidak ada, tampilkan gambar lama (mode edit)
                              : (_existingImageUrl != null
                                  ? Image.network(_existingImageUrl!, fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)))
                                  // 3. Jika tidak ada keduanya, tampilkan placeholder
                                  : const Center(
                                      child: Text('Product Image', style: TextStyle(color: Colors.grey, fontSize: 16)),
                                    )),
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
                      // --- PERUBAHAN #7: Panggil fungsi _saveProduct ---
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      // --- PERUBAHAN #8: Teks tombol dinamis sesuai mode ---
                      child: Text(
                        _isEditMode ? 'Save Changes' : 'Add', 
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                      ),
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