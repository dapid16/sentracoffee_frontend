import 'package:flutter/material.dart';
import 'package:sentra_coffee_frontend/models/raw_material.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';
import 'package:sentra_coffee_frontend/screens/admin_edit_stock_screen.dart';
import 'package:sentra_coffee_frontend/screens/admin_add_raw_material_screen.dart';

class AdminManageStockScreen extends StatefulWidget {
  const AdminManageStockScreen({Key? key}) : super(key: key);

  @override
  State<AdminManageStockScreen> createState() => _AdminManageStockScreenState();
}

class _AdminManageStockScreenState extends State<AdminManageStockScreen> {
  late Future<List<RawMaterial>> _materialsFuture;

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  void _loadMaterials() {
    setState(() {
      _materialsFuture = ApiService().fetchRawMaterials();
    });
  }

  void _navigateToEdit(RawMaterial material) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminEditStockScreen(material: material)),
    );
    if (result == true) {
      _loadMaterials();
    }
  }

  void _navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminAddRawMaterialScreen()),
    );
    if (result == true) {
      _loadMaterials();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manajemen Stok Gudang")),
      body: RefreshIndicator(
        onRefresh: () async => _loadMaterials(),
        child: FutureBuilder<List<RawMaterial>>(
          future: _materialsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Belum ada data bahan baku."));
            }
            
            final materials = snapshot.data!;
            return ListView.builder(
              itemCount: materials.length,
              itemBuilder: (context, index) {
                final material = materials[index];
                final isLowStock = material.currentStock <= material.minStockLevel;
                return ListTile(
                  title: Text(material.namaBahan),
                  subtitle: Text("Stok Minimum: ${material.minStockLevel} ${material.unit}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLowStock)
                        const Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        "${material.currentStock.toStringAsFixed(2)} ${material.unit}",
                        style: TextStyle(
                          color: isLowStock ? Colors.orange : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _navigateToEdit(material),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAdd,
        child: const Icon(Icons.add),
        tooltip: 'Tambah Bahan Baku',
      ),
    );
  }
}