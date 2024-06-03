import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detail_favorit.dart';

class FavoritPage extends StatelessWidget {
  const FavoritPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

    return Scaffold(
      appBar: null,
      backgroundColor: Color(0xFFFAF1E4),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorits')
            .where('userId', isEqualTo: userId)
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

          List<DocumentSnapshot> favorits = snapshot.data!.docs;

          return ListView.builder(
            itemCount: favorits.length,
            itemBuilder: (context, index) {
              var favoritData =
                  favorits[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(7.0),
                color: Colors.lightGreen.withOpacity(0.4),
                child: Container(
                  width: 260.0,
                  child: ListTile(
                    leading: Image.network(
                      favoritData['gambar'],
                      width: 60.0,
                      height: 60.0,
                      fit: BoxFit.cover,
                    ),
                    title: Text(favoritData['judul']),
                    subtitle: Text('Rating: ${favoritData['rating']}'),
                    onTap: () {
                      _navigateToDetailPage(context, favoritData);
                    },
                    onLongPress: () {
                      _removeFromFavorites(
                          context, favorits[index].id);
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _removeFromFavorites(
                            context, favorits[index].id);
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _removeFromFavorites(
      BuildContext context, String documentId) {
    FirebaseFirestore.instance
        .collection('favorits')
        .doc(documentId)
        .delete()
        .then(
      (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Menu dihapus dari favorit'),
          ),
        );
      },
    ).catchError(
      (error) {
        print('Terjadi kesalahan saat menghapus dari favorit: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan. Silakan coba lagi.'),
          ),
        );
      },
    );
  }

  void _navigateToDetailPage(
    BuildContext context, Map<String, dynamic> favoritData) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DetailFavoritPage(
        docId: favoritData['menuId'],
        title: favoritData['judul'],
        description: favoritData['deskripsi'],
        imagePath: favoritData['gambar'],
        category: favoritData['kategori'],
        ingredients: (favoritData['bahan'] as List).cast<String>(),
        cookingSteps: favoritData['cara_memasak'],
        userRating: favoritData['rating'],
        comments: (favoritData['komentar'] as List).cast<Map<String, dynamic>>(),
      ),
    ),
  );
}
}
