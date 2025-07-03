// lib/screens/admin_edit_stock_screen.dart

import 'package:flutter/material.dart';
import 'package:sentra_coffee_frontend/models/raw_material.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';

class AdminEditStockScreen extends StatefulWidget {
  final RawMaterial material;
  const AdminEditStockScreen({Key? key, required this.material}) : super(key: key);

  @override
  State<AdminEditStockScreen> createState() => _AdminEditStockScreenState();
}

class _AdminEditStockScreenState extends State<AdminEditStockScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _stockController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _stockController = TextEditingController(text: widget.material.currentStock.toString());
  }

  @override
  void dispose() {
    _stockController.dispose();
    super.dispose();
  }

  void _updateStock() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final newStock = double.tryParse(_stockController.text) ?? 0.0;
      
      final success = await ApiService().updateRawMaterialStock(
        id: widget.material.idRawMaterial,
        newStock: newStock,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stok berhasil diperbarui!'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal memperbarui stok.'), backgroundColor: Colors.red));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Update Stok: ${widget.material.namaBahan}")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _stockController,
                decoration: InputDecoration(
                  labelText: 'Jumlah Stok Saat Ini',
                  suffixText: widget.material.unit,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah stok tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Masukkan angka yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updateStock,
                      child: const Text("Simpan Perubahan"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}