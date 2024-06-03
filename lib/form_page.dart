import 'dart:io';
import 'dart:async';
import 'package:culiner/cuacadingin_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'sayur_page.dart';
import 'daging_page.dart';
import 'cuacapanas_page.dart';
import 'snack.dart';
import 'mie.dart';
import 'kategori_nasi.dart';

class TambahResepForm extends StatefulWidget {
  @override
  _TambahResepFormState createState() => _TambahResepFormState();
}

class _TambahResepFormState extends State<TambahResepForm> {
  // Text editing controllers for input fields
  final TextEditingController judulController = TextEditingController();
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController gambarController = TextEditingController();
  final TextEditingController bahanController = TextEditingController();
  final TextEditingController caraMemasakController = TextEditingController();

  // Default category value
  String kategori = 'Daging';

  // Function to show the dialog for choosing image source
  Future<void> _showImageSourceDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pilih Sumber Gambar'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                File? pickedImage = await _pickImage();
                if (pickedImage != null) {
                  await _uploadImage(pickedImage);
                }
              },
              child: Text('Galeri'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                File? pickedImage =
                    await _pickImage(source: ImageSource.camera);
                if (pickedImage != null) {
                  await _uploadImage(pickedImage);
                }
              },
              child: Text('Kamera'),
            ),
          ],
        );
      },
    );
  }

  // Function to pick an image from gallery or camera
  Future<File?> _pickImage({ImageSource source = ImageSource.gallery}) async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: source);

    if (pickedImage != null) {
      return File(pickedImage.path);
    }

    return null;
  }

  // Function to upload the picked image to Firebase Storage
  Future<void> _uploadImage(File imageFile) async {
    try {
      String userId =
          FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      String imageName =
          'reseps/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      UploadTask uploadTask =
          FirebaseStorage.instance.ref(imageName).putFile(imageFile);
      TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);

      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      setState(() {
        gambarController.text = imageUrl;
      });
    } catch (error) {
      print('Terjadi kesalahan saat mengunggah gambar: $error');
    }
  }

  // Function to save the recipe to Firestore
  Future<void> _saveRecipeToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Check if all fields are filled
        if (judulController.text.isEmpty ||
            deskripsiController.text.isEmpty ||
            gambarController.text.isEmpty ||
            bahanController.text.isEmpty ||
            caraMemasakController.text.isEmpty) {
          // Show notification if any field is empty
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Harap isi semua field sebelum menyimpan resep.'),
            ),
          );
          return;
        }

         final userId = user.uid;
        final username = await _getUsernameFromFirestore(userId);
        final userSnapshot =
            await FirebaseFirestore.instance.collection('users').doc(userId).get();

        String userProfileImageUrl = '';
        if (userSnapshot.exists) {
          userProfileImageUrl = userSnapshot['profileImageUrl'] ?? '';
        }

        await FirebaseFirestore.instance.collection('reseps').add({
          'judul': judulController.text,
          'kategori': kategori,
          'gambar': gambarController.text,
          'bahan': bahanController.text,
          'cara_memasak': caraMemasakController.text,
          'deskripsi': deskripsiController.text,
          'rating': 0.0,
          'komentar': [],
          'username': username,
          'user_id': userId,
          'created_at': FieldValue.serverTimestamp(),
          'user_profile_image_url': userProfileImageUrl,
        });
        // Show notification that the recipe has been added
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Resep berhasil ditambahkan!'),
          ),
        );

        // Close the page after adding the recipe
        Navigator.pop(context);
      }
    } catch (error) {
      // Show notification if there is an error
      print('Terjadi kesalahan saat menyimpan resep: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan. Silakan coba lagi.'),
        ),
      );
    }
  }

  // Function to get the username from Firestore
  Future<String> _getUsernameFromFirestore(String userId) async {
    try {
      final userSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userSnapshot.exists) {
        return userSnapshot['username'];
      } else {
        return 'Unknown';
      }
    } catch (error) {
      print('Terjadi kesalahan saat mengambil informasi username: $error');
      return 'Unknown';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF1E4),
      appBar: AppBar(
        backgroundColor: Color(0xFFFAF1E4),
        title: Text("Tambah Resep", style: TextStyle(color: Colors.black)),
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
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input field for Judul Menu Masakan
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Judul Menu Masakan',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.lightGreen[100], // Warna hijau muda
                      borderRadius: BorderRadius.circular(9.0),
                    ),
                    child: TextField(
                      controller: judulController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        border: InputBorder.none,
                        hintText: 'Masukkan judul',
                      ),
                    ),
                  ),
                ],
              ),
            ),
              SizedBox(height: 7.0),
Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.lightGreen[100], // Warna hijau muda
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: TextField(
                      controller: deskripsiController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        border: InputBorder.none,
                        hintText: 'Masukkan deskripsi',
                      ),
                    ),
                  ),
                ],
              ),
            ),
              SizedBox(height: 7.0),
 // Dropdown for Kategori
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kategori',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.lightGreen[100], // Warna hijau muda
                      borderRadius: BorderRadius.circular(9.0),
                    ),
                    child: DropdownButtonFormField(
                      value: kategori,
                      onChanged: (String? value) {
                        setState(() {
                          kategori = value!;
                        });
                      },
                      items: ['Daging', 'Sayuran', 'Soup', 'Seafood', 'nasi', 'Snack', 'Mie']
                          .map<DropdownMenuItem<String>>(
                            (String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
              SizedBox(height: 8.0),

              // Image picker (centered)
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gambar',
                      style: TextStyle(fontSize: 16.0),
                    ),
                    GestureDetector(
                      onTap: () {
                        _showImageSourceDialog(context);
                      },
                      child: Container(
                        width: 350,
                        height: 170.0,
                        color: Colors.grey[300],
                        child: gambarController.text.isNotEmpty
                            ? Image.network(
                                gambarController.text,
                                fit: BoxFit.cover,
                              )
                            : Icon(
                                Icons.camera_alt,
                                size: 50.0,
                                color: Colors.black,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.0),
// Input field for Bahan-bahan
Padding(
  padding: const EdgeInsets.only(bottom: 8.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Bahan-bahan',
        style: TextStyle(fontSize: 16.0),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.lightGreen[100], // Warna hijau muda
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: TextFormField(
          controller: bahanController,
          keyboardType: TextInputType.multiline,
          maxLines: 5,
          // onTap akan dipanggil saat user tap di dalam TextFormField
          onTap: () {
            if (bahanController.text.isEmpty) {
              // Jika teks bahan masih kosong, tambahkan bullet
              bahanController.text = '• ';
              // Memastikan kursor tetap di akhir teks
              bahanController.selection = TextSelection.fromPosition(
                TextPosition(offset: bahanController.text.length),
              );
            }
          },
          // onChanged akan dipanggil setiap kali teks berubah
          onChanged: (text) {
            // Mendeteksi baris baru ("\n") dan menambahkan bullet
            if (text.endsWith('\n')) {
              bahanController.text += '• ';
              // Memastikan kursor tetap di akhir teks
              bahanController.selection = TextSelection.fromPosition(
                TextPosition(offset: bahanController.text.length),
              );
            }
          },
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            border: InputBorder.none,
            hintText: 'Masukkan bahan-bahan',
          ),
        ),
      ),
    ],
  ),
),
              SizedBox(height: 6.0),  
    // Input field for Cara Memasak
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cara Memasak',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.lightGreen[100], // Warna hijau muda
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: TextField(
                      controller: caraMemasakController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                        border: InputBorder.none,
                        hintText: 'Masukkan cara memasak',
                      ),
                    ),
                  ),
                ],
              ),
            ),


              // Button to save the recipe (centered)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    _saveRecipeToFirestore();
                  },
                  child: Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.lightGreen,
                    fixedSize: Size(122, 37),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => TambahResepForm(),
      'daging': (context) => DagingPage(),
      'sayuran': (context) => SayurPage(),
      'Soup': (context) => CuacaDinginPage(),
      'Seafood': (context) => CuacaPanasPage(),
      'Snack': (context) => SnackPage(),
      'Mie': (context) => MiePage(),
      'Nasi': (context) => NasiPage(),
    },
  ));
}