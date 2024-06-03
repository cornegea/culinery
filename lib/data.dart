import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdditionalDataScreen extends StatefulWidget {
  final String uid;

  AdditionalDataScreen({required this.uid});

  @override
  _AdditionalDataScreenState createState() => _AdditionalDataScreenState();
}

class _AdditionalDataScreenState extends State<AdditionalDataScreen> {
  String gender = ''; // Variabel untuk menyimpan pilihan gender
  DateTime? birthDate; // Variabel untuk menyimpan tanggal lahir

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pengisian Data Tambahan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pilih Gender:'),
            Row(
              children: [
                Radio(
                  value: 'wanita',
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value as String;
                    });
                  },
                ),
                Text('Wanita'),
                Radio(
                  value: 'pria',
                  groupValue: gender,
                  onChanged: (value) {
                    setState(() {
                      gender = value as String;
                    });
                  },
                ),
                Text('Pria'),
              ],
            ),
            SizedBox(height: 20),
            Text('Tanggal Lahir:'),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );

                if (pickedDate != null && pickedDate != birthDate) {
                  setState(() {
                    birthDate = pickedDate;
                  });
                }
              },
              child: Text(
                birthDate == null
                    ? 'Pilih Tanggal Lahir'
                    : 'Tanggal Lahir: ${birthDate!.toLocal()}'.split(' ')[0],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simpan data tambahan ke Firestore
                saveAdditionalData();
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void saveAdditionalData() async {
  if (gender.isNotEmpty && birthDate != null) {
    // Periksa apakah UID tidak kosong
    if (widget.uid.isNotEmpty) {
      // Simpan data tambahan ke Firestore
      await FirebaseFirestore.instance.collection('users').doc(widget.uid).update({
        'gender': gender,
        'birthDate': birthDate,
      });

      // Setelah menyimpan data tambahan, pindah ke halaman home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } else {
      // Tampilkan pesan kesalahan jika UID kosong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('UID pengguna kosong.'),
        ),
      );
    }
  } else {
    // Tampilkan pesan kesalahan jika data belum lengkap
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Harap lengkapi data tambahan.'),
      ),
    );
  }
}
}
