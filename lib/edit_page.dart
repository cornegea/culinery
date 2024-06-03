import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class EditPage extends StatefulWidget {
  final String documentId;
  final String judul;
  final String kategori;
  final String gambar;
  final String deskripsi;
  final String bahan;
  final String caraMemasak;

  EditPage({
    required this.documentId,
    required this.judul,
    required this.kategori,
    required this.gambar,
    required this.deskripsi,
    required this.bahan,
    required this.caraMemasak,
  });

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  late TextEditingController judulController;
  late TextEditingController kategoriController;
  late TextEditingController gambarController;
  late TextEditingController deskripsiController;
  late TextEditingController bahanController;
  late TextEditingController caraMemasakController;
  bool isEditing = false;
  String selectedCategory = '';

  @override
  void initState() {
    super.initState();
    judulController = TextEditingController(text: widget.judul);
    kategoriController = TextEditingController(text: widget.kategori);
    gambarController = TextEditingController(text: widget.gambar);
    deskripsiController = TextEditingController(text: widget.deskripsi);
    bahanController = TextEditingController(text: widget.bahan);
    caraMemasakController = TextEditingController(text: widget.caraMemasak);
    selectedCategory = widget.kategori;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Edit'),
        ),
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Color(0xFFFAF1E4),
      resizeToAvoidBottomInset: true,
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 15.0, 25.0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Judul'),
                _buildTextField(judulController, 'Judul'),
                SizedBox(height: 11.0),
                _buildSectionHeader('Kategori'),
                _buildCategoryDropdown(), // Updated for category dropdown
                SizedBox(height: 11.0),
                _buildImageInput(),
                SizedBox(height: 11.0),
                _buildSectionHeader('Deskripsi'),
                _buildTextField(deskripsiController, 'Deskripsi'),
                SizedBox(height: 16.0),
                _buildSectionHeader('Bahan'),
                _buildMultilineTextField(bahanController, 'Bahan'),
                SizedBox(height: 11.0),
                _buildSectionHeader('Cara Memasak'),
                _buildMultilineTextField(caraMemasakController, 'Cara Memasak'),
                SizedBox(height: 11.0),
                _buildButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

 Widget _buildTextField(TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      decoration: _buildInputDecoration(labelText),
      enabled: isEditing,
    );
  }

  Widget _buildMultilineTextField(
      TextEditingController controller, String labelText) {
    return TextField(
      controller: controller,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      onChanged: (text) {
        // Mendeteksi baris baru ("\n") dan menambahkan bullet
        if (text.endsWith('\n')) {
          controller.text += '• ';
          // Memastikan kursor tetap di akhir teks
          controller.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.text.length),
          );
        }
      },
      decoration: _buildInputDecoration(labelText),
      enabled: isEditing,
    );
  }


  Widget _buildSectionHeader(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  InputDecoration _buildInputDecoration(String labelText) {
    return InputDecoration(
      labelText: labelText,
      filled: true,
      fillColor: Colors.lightGreen[100],
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildEditButton(),
        _buildSaveButton(),
        _buildDeleteButton(),
      ],
    );
  }

  Widget _buildEditButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isEditing = !isEditing;
        });
      },
      style: ElevatedButton.styleFrom(
        primary: isEditing ? const Color.fromARGB(255, 253, 183, 77) : Colors.green,
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      child: Text(
        isEditing ? 'Batal Edit' : 'Edit',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton(
      onPressed: isEditing ? () => _updateRecipe() : null,
      style: ElevatedButton.styleFrom(
        primary: Color.fromARGB(255, 105, 160, 255),
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      ),
      child: Text(
        'Simpan',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return ElevatedButton(
      onPressed: () {
        _showDeleteConfirmationDialog(context);
      },
      style: ElevatedButton.styleFrom(
        primary: Color.fromARGB(255, 255, 33, 33),
        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      ),
      child: Text(
        'Hapus',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildImageInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUploadImageButton(),
        SizedBox(height: 8.0),
        _buildImagePreview(),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (gambarController.text.isNotEmpty) {
      return Container(
        width: double.infinity,
        height: 200.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          image: DecorationImage(
            image: NetworkImage(gambarController.text),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: 200.0,
        color: Colors.grey[300],
        child: Center(
          child: Text('Belum ada gambar dipilih'),
        ),
      );
    }
  }

  Widget _buildUploadImageButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: isEditing ? () => _pickImage() : null,
          style: ElevatedButton.styleFrom(
            primary: const Color.fromARGB(255, 2, 141, 255),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          child: Text(
            'Pilih Gambar dari Galeri',
            style: TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      String imageUrl = await _uploadImage(pickedImage.path);
      setState(() {
        gambarController.text = imageUrl;
      });
    }
  }

  Future<String> _uploadImage(String filePath) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
      String imageName =
          'reseps/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

      UploadTask uploadTask =
          FirebaseStorage.instance.ref(imageName).putFile(File(filePath));
      TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);

      String imageUrl = await taskSnapshot.ref.getDownloadURL();

      return imageUrl;
    } catch (error) {
      print('Terjadi kesalahan saat mengunggah gambar: $error');
      throw error;
    }
  }

  Future<void> _updateRecipe() async {
    try {
      await FirebaseFirestore.instance.collection('reseps').doc(widget.documentId).update({
        'judul': judulController.text,
        'kategori': selectedCategory, // Gunakan selectedCategory
        'gambar': gambarController.text,
        'deskripsi': deskripsiController.text,
        'bahan': bahanController.text,
        'cara_memasak': caraMemasakController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resep berhasil diperbarui!'),
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      print('Error updating recipe: $error');
    }
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus Resep'),
          content: Text('Apakah Anda yakin ingin menghapus resep ini?'),
          actions: <Widget>[
            _buildTextButton('Batal', () {
              Navigator.pop(context);
            }),
            _buildTextButton('Hapus', () async {
              try {
                await _deleteRecipe(context);
                Navigator.pop(context);
              } catch (error) {
                print('Error deleting recipe: $error');
              }
            }),
          ],
        );
      },
    );
  }

  Widget _buildTextButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  Future<void> _deleteRecipe(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('reseps')
          .doc(widget.documentId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Resep berhasil dihapus!'),
        ),
      );

      await Future.delayed(Duration(seconds: 1));

      Navigator.pop(context);
    } catch (error) {
      print('Error deleting recipe: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat menghapus resep.'),
        ),
      );
    }
  }

 Widget _buildCategoryDropdown() {
  return Container(
    decoration: BoxDecoration(
      color: Colors.lightGreen[100],
      borderRadius: BorderRadius.circular(9.0),
    ),
    child: DropdownButtonFormField(
      value: selectedCategory,
      onChanged: isEditing
          ? (String? value) {
              setState(() {
                selectedCategory = value!;
              });
            }
          : null, // Menonaktifkan dropdown jika tidak sedang mengedit
      items: ['Daging', 'Sayuran', 'Soup', 'Seafood', 'Nasi', 'Snack', 'Mie']
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
  );
}
}
