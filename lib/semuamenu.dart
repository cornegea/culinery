import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_page.dart';

class AllMenusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF1E4),
      appBar: AppBar(
        backgroundColor: Color(0xFFFAF1E4),
        title: Text(
          "Semua Menu",
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reseps')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          List<DocumentSnapshot> allMenus = snapshot.data!.docs;

          return ListView.builder(
            itemCount: allMenus.length,
            itemBuilder: (context, index) {
              var menu = allMenus[index];

              return _buildMenuTerbaruItem(
                context,
                menu.id,
                menu['judul'],
                menu['gambar'],
                menu['bahan'].toString().split(', '),
                menu['cara_memasak'],
                menu['deskripsi'],
                menu['kategori'],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildMenuTerbaruItem(
    BuildContext context,
    String docId,
    String title,
    String imagePath,
    List<String> ingredients,
    String cookingSteps,
    String description,
    String category,
  ) {
    return GestureDetector(
      onTap: () {
        _navigateToDetailPage(
          context,
          docId,
          title,
          imagePath,
          ingredients,
          cookingSteps,
          description,
          category,
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.lightGreen.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            Container(
              width: 80.0,
              height: 80.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                image: DecorationImage(
                  image: NetworkImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    description, // Menggunakan deskripsi sebagai pengganti pengirim
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.normal,
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

  void _navigateToDetailPage(
    BuildContext context,
    String docId,
    String title,
    String imagePath,
    List<String> ingredients,
    String cookingSteps,
    String description,
    String category,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailMenuPage(
          docId: docId,
          title: title,
          description: description,
          imagePath: imagePath,
          ingredients: ingredients,
          cookingSteps: cookingSteps,
          category: category,
        ),
      ),
    );
  }
}
