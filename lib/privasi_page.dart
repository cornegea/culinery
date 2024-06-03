import 'package:flutter/material.dart';
import 'change_username_page.dart';
import 'gantikatasandi.dart'; // Import halaman Ganti Kata Sandi
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';

class PrivasiPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> hapusAkun() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await currentUser.delete();
        // Akun Firebase Authentication berhasil dihapus
      } else {
        print('Error: Current user is null');
        // Handle case when current user is null
      }
    } catch (e) {
      print('Error saat menghapus akun: $e');
      // Tampilkan pesan kesalahan jika diperlukan
    }
  }

  Future<void> hapusDataFirestore(String uid) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();
      // Data pengguna dari Firestore berhasil dihapus
    } catch (e) {
      print('Error saat menghapus data pengguna dari Firestore: $e');
      // Tampilkan pesan kesalahan jika diperlukan
    }
  }

  Future<void> _showDeleteAccountConfirmationDialog(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Konfirmasi Hapus Akun'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Anda yakin ingin menghapus akun Anda?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Tidak'),
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
            },
          ),
          TextButton(
            child: Text('Ya'),
            onPressed: () async {
              await hapusAkun();
              await hapusDataFirestore(_auth.currentUser?.uid ?? '');
              Navigator.of(context).pop();
              
              // Navigasi kembali ke halaman login setelah penghapusan akun berhasil
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      );
    },
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF1E4),
      appBar: AppBar(
        title: Text(
          "Pengaturan",
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        toolbarHeight: 80.0,
        elevation: 2.0,
        shadowColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.0),
          child: Container(
            color: Colors.black,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMenuContainer(
              Icon(Icons.edit, color: Colors.black),
              "Ganti Username",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangeUsernamePage()),
                );
              },
            ),
            _buildMenuContainer(
              Icon(Icons.lock, color: Colors.black),
              "Ganti Kata Sandi",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GantiKataSandiPage()), // Navigasi ke halaman Ganti Kata Sandi
                );
              },
            ),
            _buildMenuContainer(
              Icon(Icons.delete, color: Colors.black),
              "Hapus Akun",
              () {
                _showDeleteAccountConfirmationDialog(context);
              },
            ),
            _buildMenuContainer(
              Icon(Icons.account_circle, color: Colors.black),
              "Ganti Akun",
              () {
                // Tambahkan logika saat item "Ganti Akun" diklik
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuContainer(Widget leading, String title, VoidCallback? onTap) {
    return Container(
      width: 350,
      height: 45,
      margin: EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: Colors.lightGreen.withOpacity(0.6),
      ),
      child: ListTile(
        leading: leading,
        title: Text(
          title,
          style: TextStyle(color: Colors.black),
        ),
        onTap: onTap,
      ),
    );
  }
}
