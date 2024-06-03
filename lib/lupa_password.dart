import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF1E4),
      appBar: AppBar(
        title: Text('Lupa Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Masukkan Email',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Panggil fungsi untuk mengirim email reset password
                resetPassword(context, emailController.text);
              },
              child: Text('Kirim Email Reset Password'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Navigator.of(context).pop(); // Tutup halaman reset password setelah email terkirim
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email reset password telah dikirim. Silakan periksa kotak masuk Anda.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim email reset password. Cek kembali email Anda.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
