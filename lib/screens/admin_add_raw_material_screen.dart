import 'package:flutter/material.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';

class AdminAddRawMaterialScreen extends StatefulWidget {
  const AdminAddRawMaterialScreen({Key? key}) : super(key: key);

  @override
  State<AdminAddRawMaterialScreen> createState() => _AdminAddRawMaterialScreenState();
}

class _AdminAddRawMaterialScreenState extends State<AdminAddRawMaterialScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitController = TextEditingController();
  final _initialStockController = TextEditingController(text: '0');
  final _minStockController = TextEditingController(text: '0');
  bool _isLoading = false;

  void _saveMaterial() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final success = await ApiService().createRawMaterial(
        name: _nameController.text,
        unit: _unitController.text,
        initialStock: double.tryParse(_initialStockController.text) ?? 0.0,
        minStock: double.tryParse(_minStockController.text) ?? 0.0,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bahan baku baru berhasil ditambahkan!'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menambahkan bahan baku.'), backgroundColor: Colors.red));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitController.dispose();
    _initialStockController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Bahan Baku Baru")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Bahan Baku', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Satuan (e.g., gram, ml, pcs)', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Satuan tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _initialStockController,
                decoration: const InputDecoration(labelText: 'Stok Awal', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => (value == null || value.isEmpty || double.tryParse(value) == null) ? 'Masukkan angka yang valid' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _minStockController,
                decoration: const InputDecoration(labelText: 'Batas Stok Minimum', border: OutlineInputBorder()),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => (value == null || value.isEmpty || double.tryParse(value) == null) ? 'Masukkan angka yang valid' : null,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      onPressed: _saveMaterial,
                      child: const Text('Simpan Bahan Baku'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}