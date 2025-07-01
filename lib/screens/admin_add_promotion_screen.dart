// lib/screens/admin_add_promotion_screen.dart

import 'package:flutter/material.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';

class AdminAddPromotionScreen extends StatefulWidget {
  const AdminAddPromotionScreen({Key? key}) : super(key: key);

  @override
  State<AdminAddPromotionScreen> createState() => _AdminAddPromotionScreenState();
}

class _AdminAddPromotionScreenState extends State<AdminAddPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _valueController = TextEditingController();
  String _selectedType = 'persen'; // 'persen' or 'potongan'
  bool _isLoading = false;

  void _savePromotion() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final apiService = ApiService();
      final success = await apiService.createPromotion(
        name: _nameController.text,
        description: _descriptionController.text,
        discountType: _selectedType,
        discountValue: double.tryParse(_valueController.text) ?? 0.0,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Promo baru berhasil ditambahkan!'),
              backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Gagal menambahkan promo.'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tambah Promo Baru")),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Nama Promo', border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                    labelText: 'Deskripsi Singkat',
                    border: OutlineInputBorder()),
                validator: (value) =>
                    value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                    labelText: 'Tipe Diskon', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(
                      value: 'persen', child: Text('Persentase (%)')),
                  DropdownMenuItem(
                      value: 'potongan', child: Text('Potongan Harga (Rp)')),
                ],
                onChanged: (value) {
                  setState(() => _selectedType = value!);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valueController,
                decoration: InputDecoration(
                  labelText: _selectedType == 'persen'
                      ? 'Nilai Persen'
                      : 'Jumlah Potongan',
                  prefixText: _selectedType == 'potongan' ? 'Rp ' : null,
                  suffixText: _selectedType == 'persen' ? '%' : null,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Nilai tidak boleh kosong' : null,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _savePromotion,
                      child: const Text('Simpan Promo'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}