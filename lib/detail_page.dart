import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DetailMenuPage extends StatefulWidget {
  final String docId;
  final String title;
  final String description;
  final String imagePath;
  final String category;
  final List<String> ingredients;
  final String cookingSteps;

  DetailMenuPage({
    required this.docId,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.category,
    required this.ingredients,
    required this.cookingSteps,
  });

  @override
  _DetailMenuPageState createState() => _DetailMenuPageState();
}

class _DetailMenuPageState extends State<DetailMenuPage> {
  double _userRating = 0.0;
  TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  List<Map<String, dynamic>> _ranting = [];
  double _totalRanting = 0.0;

  @override
  void initState() {
    super.initState();
    _loadRatingAndComments();
  }

  void _loadRatingAndComments() {
    if (widget.docId.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('reseps')
          .doc(widget.docId)
          .get()
          .then((snapshot) {
        if (snapshot.exists) {
          setState(() {
            _userRating = snapshot['rating'] ?? 0.0;
            _comments = List.from(snapshot['komentar'] ?? []);
            _ranting = List.from(snapshot['ranting'] ?? []);
            _totalRanting = 0.0;
            for (var rantingData in _ranting) {
              _totalRanting += rantingData['ranting'] ?? 0.0;
            }
          });
        } else {
          print('Dokumen tidak ditemukan di Firestore.');
        }
      }).catchError((error) {
        print('Terjadi kesalahan Firestore: $error');
      });
    }
  }

 void _addToRanting(double ranting) {
  String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

  // Periksa apakah pengguna sudah memberikan ranting sebelumnya
  bool hasRated = _ranting.any((ratingData) => ratingData['userId'] == userId);

  // Jika pengguna belum memberikan ranting, dan ranting kurang dari atau sama dengan 5
  if (!hasRated && ranting >= 0 && ranting <= 5) {
    Map<String, dynamic> rantingData = {
      'userId': userId,
      'ranting': ranting,
    };

    FirebaseFirestore.instance.collection('reseps').doc(widget.docId).update({
      'ranting': FieldValue.arrayUnion([rantingData]),
      'totalRanting': FieldValue.increment(ranting),
    });

    // Perbarui total ranting dan komentar
    _loadRatingAndComments();
  } else {
    // Tampilkan pesan atau lakukan tindakan lain sesuai kebutuhan
    print('Anda sudah memberikan ranting sebelumnya atau ranting tidak valid.');
  }
}


  void _saveCommentToFirestore(String comment) {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';
    String username = '';
    String profileImageUrl = '';

    FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get()
        .then((userSnapshot) {
      if (userSnapshot.exists) {
        username = userSnapshot['username'] ?? '';
        profileImageUrl = userSnapshot['profileImageUrl'] ?? '';
      }

      String commentId = DateTime.now().toIso8601String();

      Map<String, dynamic> commentData = {
        'commentId': commentId,
        'username': username,
        'comment': comment,
        'timestamp': DateTime.now(),
        'profileImageUrl': profileImageUrl,
      };

      return FirebaseFirestore.instance
          .collection('reseps')
          .doc(widget.docId)
          .set(
        {
          'komentar': FieldValue.arrayUnion([commentData]),
        },
        SetOptions(merge: true),
      );
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Komentar ditambahkan: $comment'),
        ),
      );

      _loadRatingAndComments();

      _commentController.clear();
    }).catchError((error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error. Please try again.'),
        ),
      );
    });
  }


  void _addToFavorites() {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown';

    Map<String, dynamic> favoriteData = {
      'userId': userId,
      'menuId': widget.docId,
      'judul': widget.title,
      'gambar': widget.imagePath,
      'deskripsi': widget.description, // Tambahkan deskripsi ke data favorit
      'kategori': widget.category, // Tambahkan kategori ke data favorit
      'bahan': widget.ingredients,
      'cara_memasak': widget.cookingSteps,
      'rating': _userRating,
      'komentar': _comments,
      // tambahkan bidang lain yang dibutuhkan
    };

    FirebaseFirestore.instance.collection('favorits').add(favoriteData).then(
      (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Menu ditambahkan ke favorit!'),
          ),
        );
      },
    ).catchError(
      (error) {
        print('Terjadi kesalahan saat menambahkan ke favorit: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan. Silakan coba lagi.'),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF1E4),
      appBar: AppBar(
        backgroundColor: Color(0xFFFAF1E4),
        title: Text(
        widget.title,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
        centerTitle: true,
        toolbarHeight: 60.0,
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
        // Ubah bagian tampilan judul di bawah gambar
Container(
  decoration: BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(8.0),
  ),
  child: Column(
    children: [
      Image.network(
        widget.imagePath,
        width: double.infinity,
        height: 200.0,
        fit: BoxFit.cover,
      ),
      SizedBox(height: 8.0),
       Padding(
        padding: EdgeInsets.all(5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Spacer(), // Spacer untuk memberikan ruang di sebelah kiri
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 24.0,
                ),
              SizedBox(width: 2.0),
              Text(
                '$_totalRanting',
                style: TextStyle(fontSize: 16.0),
              ),
            ],
          ),
        ],
      ),
       ),
    ],
  ),
),


SizedBox(height: 16.0),
            // Tombol "Simpan Menu"
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: ElevatedButton(
                onPressed: () {
                  _addToFavorites();
                },
                child: Text(
                  'Simpan Menu',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  shadowColor: Colors.transparent,
                ),
              ),
            ),
            SizedBox(height: 16.0),
             // Deskripsi
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'Deskripsi:',
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(height: 0.0),
    Text(
      widget.description,
      style: TextStyle(fontSize: 16.0),
    ),
  ],
),

  SizedBox(height: 15.0),
           Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'Bahan-bahan:',
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(height: 8.0),
    Container(
       width: 360,
      decoration: BoxDecoration(
       color: Colors.grey[350],
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.all(8.0),
      child: Text(
        widget.ingredients.join(", "), // Menggabungkan elemen list dengan koma dan spasi
        style: TextStyle(fontSize: 16.0),
      ),
    ),
  ],
),

            SizedBox(height: 16.0),
  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Cara Memasak:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.0),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Container(
                    decoration: BoxDecoration(
                       color: Colors.grey[350],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      widget.cookingSteps,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            // Ranting
      Text(
              'Ranting:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
           RatingBar.builder(
  initialRating: 0.0,
  minRating: 1,
  maxRating: 5, // Tambahkan nilai ini
  direction: Axis.horizontal,
  allowHalfRating: true,
  itemCount: 5,
  itemSize: 30.0,
  itemBuilder: (context, _) => Icon(
    Icons.star,
    color: Colors.amber,
  ),
  onRatingUpdate: (ranting) {
    // Pastikan ranting tidak melebihi 5
    ranting = ranting > 5 ? 5 : ranting;
    _addToRanting(ranting);
  },
),

            SizedBox(height: 16.0),
            // Komentar
            Text(
              'Komentar:',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Tambahkan komentar...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  ElevatedButton(
                    onPressed: () {
                      String comment = _commentController.text;
                      _saveCommentToFirestore(comment);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.send,
                          size: 18.0,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          'Kirim',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
// Daftar Komentar
  Container(
  width: 360,
  padding: EdgeInsets.all(16.0),
  decoration: BoxDecoration(
   color: Colors.grey[350],
    borderRadius: BorderRadius.circular(8.0),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: _comments.map((commentData) {
      var timestamp = commentData['timestamp'] as Timestamp;
      var date = DateTime.fromMillisecondsSinceEpoch(
        timestamp.millisecondsSinceEpoch,
      );
      DateFormat formatter = DateFormat('dd MMMM yyyy, HH:mm');
      String formattedDate = formatter.format(date);

      // Tambahkan penanganan nilai null
      String profileImageUrl = commentData['profileImageUrl']?.toString() ?? '';
      String username = commentData['username']?.toString() ?? '';
      String commentText = commentData['comment']?.toString() ?? '';

      return Container(
        margin: EdgeInsets.symmetric(vertical: 8.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(profileImageUrl),
                  // Atur radius dan ukuran sesuai kebutuhan
                ),
                SizedBox(width: 8.0),
                Text(username),
              ],
            ),
            SizedBox(height: 8.0),
            Text(
              commentText,
            ),
            Text(
              '  $formattedDate',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }).toList(),
  ),
),

          ],
        ),
      ),
    );
  }
}
