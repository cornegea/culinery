import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_page.dart';

class CuacaDinginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF1E4),
      appBar: AppBar(
        backgroundColor: Color(0xFFFAF1E4),
        title: Text(
          "kategori Soup",
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
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 12.0),
        child: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('reseps')
      .where('kategori', isEqualTo: 'Soup')
      .orderBy('created_at', descending: true) // Urutkan berdasarkan waktu pembuatan, descending untuk yang paling baru dulu
      .snapshots(),
  builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

          
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Menetapkan dua kolom
                crossAxisSpacing: 13.0,
                mainAxisSpacing: 15.0,
                childAspectRatio:  4/ 7, // Sesuaikan rasio tinggi dan lebar
              ),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var resep = snapshot.data!.docs[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailMenuPage(
                          docId: resep.id,
                          title: resep['judul'],
                          description: resep['deskripsi'],
                          imagePath: resep['gambar'],
                          category: resep['kategori'],
                          ingredients: resep['bahan'].toString().split(', '),
                          cookingSteps: resep['cara_memasak'],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFCEDEBD),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Baris 1: Foto Profil dan Username
                        Container(
                          height: 65,
                          width: 250,
                          padding: EdgeInsets.all(11.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: ClipOval(
                                  child: Container(
                                    width: 28.0,
                                    height: 30.0,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          resep['user_profile_image_url'] ?? '',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Text(
                                resep['username'] ?? 'Unknown',
                                style: TextStyle(
                                  fontSize: 14.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Baris 2: Gambar Menu
                     Expanded(
  child: Center(
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        image: DecorationImage(
          image: NetworkImage(resep['gambar']),
          fit: BoxFit.cover, // Sesuaikan properti ini
        ),
      ),
      height: 250,
      width: 150.0, // Sesuaikan properti ini untuk mengatur lebar gambar
    ),
  ),
),

                       // Baris 3: Judul Menu Masakan
Container(
  height: 70,
  padding: EdgeInsets.all(11.0),
  child: Align(
    alignment: Alignment.center,
    child: FittedBox(
      fit: BoxFit.scaleDown, // Sesuaikan dengan kebutuhan Anda
      child: Text(
        resep['judul'],
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ),
),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

