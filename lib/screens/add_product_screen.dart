import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sentra_coffee_frontend/models/menu.dart';
import 'package:sentra_coffee_frontend/models/menu_composition.dart';
import 'package:sentra_coffee_frontend/models/raw_material.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';

class AddProductScreen extends StatefulWidget {
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

  bool _isEditMode = false;
  String? _existingImageUrl;

  List<MenuComposition> _compositions = [];
  List<RawMaterial> _availableMaterials = [];
  bool _isDataLoading = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      _availableMaterials = await _apiService.fetchRawMaterials();

      if (widget.menuToEdit != null) {
        _isEditMode = true;
        final menu = widget.menuToEdit!;
        _namaController.text = menu.namaMenu;
        _hargaController.text = menu.harga.toStringAsFixed(0);
        _kategoriController.text = menu.kategori;
        if (menu.image != null && menu.image!.isNotEmpty) {
          _existingImageUrl = 'http://localhost/SentraCoffee/uploads/${menu.image}';
        }
        _compositions = await _apiService.getMenuComposition(menu.idMenu);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memuat data awal: $e")));
    } finally {
      if (mounted) {
        setState(() => _isDataLoading = false);
      }
    }
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

  void _addCompositionField() {
    setState(() {
      _compositions.add(MenuComposition(quantityNeeded: 0));
    });
  }

  void _removeCompositionField(int index) {
    setState(() {
      _compositions.removeAt(index);
    });
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;
    
    for (var comp in _compositions) {
      if (comp.idRawMaterial == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan pilih bahan untuk semua komposisi.'), backgroundColor: Colors.orange));
        return;
      }
    }

    if (!_isEditMode && (_selectedImageBytes == null || _selectedImageName == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan pilih gambar produk.'), backgroundColor: Colors.orange));
      return;
    }

    setState(() => _isLoading = true);
    
    String? finalImageFilename;

    try {
      if (_selectedImageBytes != null) {
        finalImageFilename = await _apiService.uploadImage(_selectedImageBytes!, _selectedImageName!);
        if (finalImageFilename == null) throw Exception('Image upload failed.');
      } else {
        finalImageFilename = widget.menuToEdit?.image;
      }
      
      bool success = false;
      if (_isEditMode) {
        final updatedMenu = Menu(
          idMenu: widget.menuToEdit!.idMenu,
          namaMenu: _namaController.text,
          kategori: _kategoriController.text,
          harga: double.tryParse(_hargaController.text) ?? 0,
          isAvailable: widget.menuToEdit!.isAvailable,
          image: finalImageFilename,
        );
        success = await _apiService.updateMenu(updatedMenu, _compositions);
      } else {
        final newMenu = Menu(
          idMenu: 0,
          namaMenu: _namaController.text,
          kategori: _kategoriController.text,
          harga: double.tryParse(_hargaController.text) ?? 0,
          isAvailable: true,
          image: finalImageFilename,
        );
        success = await _apiService.createMenu(newMenu, _compositions);
      }
      
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Produk berhasil ${_isEditMode ? 'diperbarui' : 'ditambahkan'}!'), backgroundColor: Colors.green));
        Navigator.of(context).pop(true);
      } else {
        throw Exception('Gagal menyimpan data produk ke server.');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: Text(
          _isEditMode ? 'Edit Product' : 'Add Product',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        centerTitle: true,
      ),
      body: _isDataLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
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
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: _selectedImageBytes != null
                                    ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                                    : (_existingImageUrl != null
                                        ? Image.network(_existingImageUrl!, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image)))
                                        : const Center(
                                            child: Text('Product Image', style: TextStyle(color: Colors.grey, fontSize: 16)),
                                          )),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildTextField(controller: _namaController, labelText: 'Product Name'),
                          const SizedBox(height: 16),
                          _buildTextField(controller: _hargaController, labelText: 'Sell Price', keyboardType: TextInputType.number),
                          const SizedBox(height: 16),
                          _buildTextField(controller: _kategoriController, labelText: 'Category'),
                          const Divider(height: 48, thickness: 1),
                          const Text("Komposisi Bahan", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _compositions.length,
                            itemBuilder: (context, index) {
                              return _buildCompositionRow(index);
                            },
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: _addCompositionField,
                            icon: const Icon(Icons.add),
                            label: const Text("Tambah Bahan"),
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
                            onPressed: _saveProduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
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

  Widget _buildCompositionRow(int index) {
    final currentComposition = _compositions[index];
    RawMaterial? selectedMaterial;
    if (currentComposition.idRawMaterial != null) {
      try {
        selectedMaterial = _availableMaterials.firstWhere((m) => m.idRawMaterial == currentComposition.idRawMaterial);
      } catch (e) {
        selectedMaterial = null;
      }
    }
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 4,
            child: DropdownButtonFormField<int>(
              value: selectedMaterial?.idRawMaterial,
              isExpanded: true,
              hint: const Text("Pilih Bahan"),
              items: _availableMaterials.map((material) {
                return DropdownMenuItem<int>(
                  value: material.idRawMaterial,
                  child: Text(material.namaBahan, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _compositions[index].idRawMaterial = value;
                  _compositions[index].unit = _availableMaterials.firstWhere((m) => m.idRawMaterial == value).unit;
                });
              },
              validator: (value) => value == null ? 'Pilih' : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: currentComposition.quantityNeeded.toString(),
              decoration: InputDecoration(
                labelText: "Jumlah",
                suffixText: currentComposition.unit ?? '',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                currentComposition.quantityNeeded = double.tryParse(value) ?? 0.0;
              },
              validator: (value) => (value == null || value.isEmpty || double.tryParse(value) == null) ? '!' : null,
            ),
          ),
          IconButton(
            onPressed: () => _removeCompositionField(index),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}