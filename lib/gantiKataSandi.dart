import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GantiKataSandiPage extends StatefulWidget {
  @override
  _GantiKataSandiPageState createState() => _GantiKataSandiPageState();
}

class _GantiKataSandiPageState extends State<GantiKataSandiPage> {
  final TextEditingController kataSandiLamaController = TextEditingController();
  final TextEditingController kataSandiBaruController = TextEditingController();
  final TextEditingController konfirmasiKataSandiController =
      TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  bool isPasswordVisible = false;

  void gantiKataSandi() async {
    setState(() {
      isLoading = true;
    });

    try {
      var credential = EmailAuthProvider.credential(
        email: _auth.currentUser!.email!,
        password: kataSandiLamaController.text,
      );

      await _auth.currentUser!.reauthenticateWithCredential(credential);
      await _auth.currentUser!.updatePassword(kataSandiBaruController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kata Sandi berhasil diubah.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } on FirebaseAuthException catch (e) {
      String errorMessage =
          'Gagal mengganti kata sandi. Periksa kembali kata sandi lama Anda.';
      if (e.code == 'wrong-password') {
        errorMessage = 'Kata sandi lama salah.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF1E4),
      appBar: AppBar(
        backgroundColor: Color(0xFFFAF1E4),
        title: Text('Ganti Kata Sandi'),
        centerTitle: true,
        toolbarHeight: 80.0,
        elevation: 2.0,
        shadowColor: Colors.black,
      ),
      body: Container(
        color: Color(0xFFFAF1E4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Masukkan kata Sandi lama',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: 335,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Color(0xFFCEDEBD),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: TextField(
                    controller: kataSandiLamaController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: '',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Masukkan kata sandi baru',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: 335,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Color(0xFFCEDEBD),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: TextField(
                    controller: kataSandiBaruController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: '',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'Konfirmasi Kata Sandi Baru',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Container(
                  width: 335,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Color(0xFFCEDEBD),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: TextField(
                    controller: konfirmasiKataSandiController,
                    obscureText: !isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: '',
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _onSubmitPressed,
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF9EB384),
                    onPrimary: Colors.black,
                  ),
                  child: Text('Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onSubmitPressed() {
    if (_validateInputs()) {
      gantiKataSandi();
    }
  }

  bool _validateInputs() {
    if (kataSandiLamaController.text.isEmpty ||
        kataSandiBaruController.text.isEmpty ||
        konfirmasiKataSandiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap isi semua kolom.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9]).{8,}$')
        .hasMatch(kataSandiBaruController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Kata Sandi Baru harus minimal 8 karakter dan mengandung huruf besar, huruf kecil, dan angka.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    if (kataSandiBaruController.text != konfirmasiKataSandiController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Konfirmasi kata sandi baru tidak cocok.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }
}
