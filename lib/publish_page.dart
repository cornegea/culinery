import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_page.dart'; // Sesuaikan dengan nama file edit_page.dart
import 'package:firebase_auth/firebase_auth.dart';

class KoleksiPage extends StatelessWidget {
  const KoleksiPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reseps').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            String userId = user.uid;
            var menus = snapshot.data!.docs.where((menu) => menu['user_id'] == userId);
            return ListView.builder(
              itemCount: menus.length,
              itemBuilder: (context, index) {
                var menuData = menus.elementAt(index).data() as Map<String, dynamic>;
                var title = menuData['judul'];
                var imageAsset = menuData['gambar'];
                var documentId = menus.elementAt(index).id;

                return _buildMenuItem(
                  context,
                  title,
                  imageAsset,
                  documentId,
                  menuData['bahan'],
                  menuData['cara_memasak'],
                  menuData['deskripsi'],
                );
              },
            );
          } else {
            return Text('Pengguna tidak terautentikasi');
          }
        }
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    String imageAsset,
    String documentId,
    String bahan,
    String caraMemasak,
    String deskripsi,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditPage(
              documentId: documentId,
              judul: title,
              kategori: 'Daging', // Sesuaikan dengan kategori atau dapatkan dari data resep
              gambar: imageAsset,
              bahan: bahan,
              caraMemasak: caraMemasak,
              deskripsi: deskripsi,
            ),
          ),
        );
      },
      child: Container(
        height: 70,
        width: 80,
        decoration: BoxDecoration(
          color: Colors.lightGreen.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: EdgeInsets.all(11.0),
        margin: EdgeInsets.only(bottom: 9.0),
        child: Row(
          children: [
            Container(
              width: 75.0,
              height: 55.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                image: DecorationImage(
                  image: NetworkImage(imageAsset),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 13.0),
            Text(
              title,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
