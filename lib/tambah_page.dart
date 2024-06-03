import 'package:flutter/material.dart';
import 'favorit_page.dart';
import 'publish_page.dart';
import 'form_page.dart';
import 'panduan_page.dart';

class Resepku extends StatefulWidget {
  @override
  _TambahPageState createState() => _TambahPageState();
}

class _TambahPageState extends State<Resepku> {
  int _currentPageIndex = 0;  // Atur 0 untuk menunjukkan tampilan Favorit aktif pertama kali
  bool isFavoriteSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF1E4),
      appBar: AppBar(
        title: Text("Resep Saya", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        toolbarHeight: 80.0,
        backgroundColor: Color(0xFFFAF1E4),
        elevation: 2.0,
        shadowColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2.0),
          child: Container(
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 22.0),
          Container(
            decoration: BoxDecoration(
              color: Colors.lightGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20.0),
            ),
            width: 335.0,
            height: 160.0,
            padding: EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "! Ketentuan Menambah Menu Masakan",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.0),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PanduanPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF16381A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Text(
                      "Panduan menulis resep",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25.0),
         
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentPageIndex = 0;
                    isFavoriteSelected = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11.0),
                  ),
                  minimumSize: Size(115.0, 40.0),
                  primary: isFavoriteSelected
                      ? Color(0xFF9EB384)
                      : Colors.white,
                  onPrimary: Colors.black,
                ),
                child: Text(
                  "Favorit",
                  style: TextStyle(
                    color: isFavoriteSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentPageIndex = 1;
                    isFavoriteSelected = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(11.0),
                  ),
                  minimumSize: Size(115.0, 40.0),
                  primary: !isFavoriteSelected
                      ? Color(0xFF9EB384)
                      : Colors.white,
                  onPrimary: Colors.black,
                ),
                child: Text(
                  "Koleksi",
                  style: TextStyle(
                    color: !isFavoriteSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Expanded(
            child: IndexedStack(
              index: _currentPageIndex,
              children: [
                FavoritPage(key: UniqueKey()),
                KoleksiPage(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahResepForm(),
            ),
          );
        },
        label: Text("Tulis Resep"),
        icon: Icon(Icons.edit),
        backgroundColor: Color(0xFF9EB384),
      ),
    );
  }
}