import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangeUsernamePage extends StatefulWidget {
  final VoidCallback? onUsernameChanged;

  ChangeUsernamePage({Key? key, this.onUsernameChanged}) : super(key: key);

  @override
  _ChangeUsernamePageState createState() => _ChangeUsernamePageState();
}

class _ChangeUsernamePageState extends State<ChangeUsernamePage> {
  final TextEditingController newUsernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF1E4),
      appBar: AppBar(
        backgroundColor: Color(0xFFFAF1E4),
        title: Text("Ganti nama pengguna", style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<String>(
              future: _getCurrentUsername(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else {
                  String currentUsername = snapshot.data ?? "";
                  return Text(
                    "Nama pengguna saat ini: $currentUsername",
                    style: TextStyle(fontSize: 16.0),
                  );
                }
              },
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: newUsernameController,
              decoration: InputDecoration(
                labelText: "Nama pengguna Baru",
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _changeUsername();
              },
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF9EB384),
                onPrimary: Colors.black,
              ),
              child: Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  Future<String> _getCurrentUsername() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (userSnapshot.exists) {
          return userSnapshot['username'] ?? "";
        } else {
          return "Username tidak ditemukan";
        }
      } else {
        return "Pengguna tidak ditemukan";
      }
    } catch (error) {
      print("Error getting current username: $error");
      return "Terjadi kesalahan";
    }
  }

  Future<void> _changeUsername() async {
    try {
      if (newUsernameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Username baru tidak boleh kosong."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      User? user = _auth.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'username': newUsernameController.text.trim()});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Username berhasil diubah."),
            backgroundColor: Colors.green,
          ),
        );

        widget.onUsernameChanged?.call();

        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Pengguna tidak ditemukan."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      print("Error changing username: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan. Gagal mengubah username."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
