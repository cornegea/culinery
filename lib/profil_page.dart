import 'package:flutter/material.dart';
import 'package:culiner/change_username_page.dart';
import 'dart:io';
import 'login_page.dart';
import 'gantiKataSandi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProfilPage extends StatefulWidget {
  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic> userData = {};
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Tambahkan variabel untuk menyimpan fungsi callback
  VoidCallback? onUsernameChanged;

  Future<void> _getUserData() async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .get();

        if (userSnapshot.exists) {
          Map<String, dynamic> userDataFromFirestore = userSnapshot.data()!;

          if (userDataFromFirestore.containsKey('username') &&
              userDataFromFirestore.containsKey('email')) {
            setState(() {
              this.userData = userDataFromFirestore;
              this.profileImageUrl =
                  userDataFromFirestore['profileImageUrl'] ?? 'images/icon.jpg';
            });
          } else {
            print('Dokumen pengguna tidak memiliki bidang yang diharapkan.');
          }
        } else {
          print('Dokumen pengguna tidak ditemukan.');
        }
      } else {
        print('Pengguna tidak ditemukan.');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }

      // Panggil fungsi callback jika tidak null
      onUsernameChanged?.call();
    } catch (error) {
      print('Terjadi kesalahan: $error');
    }
  }

  Future<void> _uploadProfilePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      String imageUrl =
          await _uploadImageToStorage(imageFile, _auth.currentUser?.uid ?? '');
      await _updateProfileImageUrl(imageUrl);

      // Perbarui juga URL gambar pada widget
      setState(() {
        this.profileImageUrl = imageUrl;
      });
    } else {
      // User membatalkan pemilihan gambar
    }
  }

  Future<String> _uploadImageToStorage(File imageFile, String uid) async {
    try {
      String fileName = '$uid-${DateTime.now().millisecondsSinceEpoch}.jpg';

      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('profile_images/$fileName');

      await ref.putFile(imageFile);
      String imageUrl = await ref.getDownloadURL();

      return imageUrl;
    } catch (error) {
      print('Terjadi kesalahan saat mengunggah gambar: $error');
      return ''; // Mengembalikan string kosong jika terjadi kesalahan
    }
  }

  Future<void> _updateProfileImageUrl(String imageUrl) async {
    try {
      User? user = _auth.currentUser;

      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profileImageUrl': imageUrl});

        setState(() {
          this.profileImageUrl = imageUrl;
        });
      }
    } catch (error) {
      print('Terjadi kesalahan: $error');
    }
  }

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

  Future<void> _showDeleteAccountConfirmationDialog(
      BuildContext context) async {
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

  Future<void> _showExitConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Keluar'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Anda yakin ingin keluar?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Tidak'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ya'),
              onPressed: () {
                setState(() {
                  this.userData = {};
                });
                Navigator.of(context).pop();
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
        title: Text("Profil", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        toolbarHeight: 80.0,
        elevation: 2.0,
        shadowColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.0),
          child: Container(
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: GestureDetector(
                onTap: _uploadProfilePicture,
                child: Container(
                  width: double.infinity,
                  height: 170.0,
                  decoration: BoxDecoration(
                    color: Color(0xFF92A584),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 50.0,
                            backgroundImage: (profileImageUrl != null &&
                                    profileImageUrl!.isNotEmpty)
                                ? NetworkImage(profileImageUrl!)
                                : NetworkImage(
          'https://firebasestorage.googleapis.com/v0/b/masakan-7a664.appspot.com/o/profile_images%2FS70wBQ9ThtNO5MGLEyqJv63WQrZ2-1702707336895.jpg?alt=media&token=5c155e36-a98c-4169-a632-eb345b03d200'),
),
                          SizedBox(width: 10.0),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['username'] ?? 'Username',
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                userData['email'] ?? 'Email',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Container(
              height: 320,
              width: 325,
              decoration: BoxDecoration(
                color: Color(0xFF435334),
                borderRadius: BorderRadius.circular(25.0),
              ),
              padding: EdgeInsets.all(35.0),
              child: Column(
                children: [
                  Container(
                    height: 50,
                    width: 500,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13.0),
                      color: Color(0xFFCEDEBD),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.edit,
                      ),
                      title: Text(
                        'Ganti nama pengguna',
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => ChangeUsernamePage(
                                    // Setel callback untuk perubahan nama pengguna
                                    onUsernameChanged: () {
                                      _getUserData();
                                    },
                                  )),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    height: 50,
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13.0),
                      color: Color(0xFFCEDEBD),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.lock,
                      ),
                      title: Text(
                        'Ganti kata sandi',
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => GantiKataSandiPage()),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    height: 50,
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13.0),
                      color: Color(0xFFCEDEBD),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.delete),
                      title: Text(
                        'Hapus Akun',
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        _showDeleteAccountConfirmationDialog(context);
                      },
                    ),
                  ),
                  SizedBox(height: 15.0),
                  Container(
                    height: 50,
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13.0),
                      color: Color(0xFFCEDEBD),
                    ),
                    child: ListTile(
                      leading: Icon(Icons.exit_to_app),
                      title: Text(
                        'Keluar',
                        style: TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        _showExitConfirmationDialog(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
