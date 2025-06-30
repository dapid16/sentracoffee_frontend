// lib/screens/admin/employee_list_screen.dart (FINAL DENGAN NAVIGASI ADD)

import 'package:flutter/material.dart';
import 'package:sentra_coffee_frontend/models/staff.dart';
import 'package:sentra_coffee_frontend/services/api_service.dart';
import 'package:sentra_coffee_frontend/screens/add_employee_screen.dart'; // <<< IMPORT HALAMAN TUJUAN

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Staff>> _staffFuture;
  
  List<Staff> _allStaff = [];
  List<Staff> _filteredStaff = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStaff();
    _searchController.addListener(_filterStaff);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadStaff() {
    setState(() {
      _staffFuture = _apiService.fetchAllStaff();
      _staffFuture.then((staffList) {
        if (mounted) {
          setState(() {
            _allStaff = staffList;
            _filteredStaff = staffList;
          });
        }
      });
    });
  }

  void _filterStaff() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStaff = _allStaff.where((staff) {
        return staff.namaStaff.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('List of Employees', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Find Employee',
                prefixIcon: const Icon(Icons.menu, color: Colors.grey),
                suffixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<Staff>>(
                future: _staffFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Tidak ada staff ditemukan.'));
                  }
                  if (_filteredStaff.isEmpty && _searchController.text.isNotEmpty) {
                    return const Center(child: Text('Staff tidak ditemukan.'));
                  }
                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _filteredStaff.length,
                    itemBuilder: (context, index) {
                      return _buildEmployeeCard(_filteredStaff[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // --- PERBAIKAN DI SINI ---
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigasi ke halaman AddEmployee dan TUNGGU hasilnya
          final bool? isSuccess = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEmployeeScreen()),
          );
          // Jika kita kembali dengan sinyal sukses (true), refresh daftar staff
          if (isSuccess == true) {
            _loadStaff();
          }
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmployeeCard(Staff staff) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          print('${staff.namaStaff} diklik');
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[200],
              child: Text(
                staff.namaStaff.isNotEmpty ? staff.namaStaff.substring(0, 1) : '?',
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              staff.namaStaff,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              staff.role,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}