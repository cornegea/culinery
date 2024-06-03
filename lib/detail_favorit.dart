import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailFavoritPage extends StatelessWidget {
  final String docId;
  final String title;
  final String description;
  final String imagePath;
  final String category;
  final List<String> ingredients;
  final String cookingSteps;
  final double userRating;
  final List<Map<String, dynamic>> comments;

  DetailFavoritPage({
    required this.docId,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.category,
    required this.ingredients,
    required this.cookingSteps,
    required this.userRating,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF1E4),
      appBar: AppBar(
        title: Text(
          title,
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Image.network(
                    imagePath,
                    width: double.infinity,
                    height: 200.0,
                    fit: BoxFit.cover,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Spacer(), 
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.yellow),
                            SizedBox(width: 4.0),
                            Text(
                              '$userRating',
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
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
      description,
      style: TextStyle(fontSize: 16.0),
    ),
  ],
),

SizedBox(height: 16.0),
           //Bahan-bahan
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
       ingredients.join(", "), // Menggabungkan elemen list dengan koma dan spasi
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
                      cookingSteps,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                ),
              ],
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
            SizedBox(height: 16.0),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[350],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: comments.map((commentData) {
                  var timestamp = commentData['timestamp'] as Timestamp;
                  var date = DateTime.fromMillisecondsSinceEpoch(
                      timestamp.millisecondsSinceEpoch);
                  var formattedDate =
                      DateFormat('dd MMMM yyyy, HH:mm').format(date);

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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(commentData['comment']),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'dari ${commentData['username']} - $formattedDate',
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
