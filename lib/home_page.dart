import 'package:culiner/mie.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tambah_page.dart';
import 'profil_page.dart';
import 'search_page.dart';
import 'daging_page.dart';
import 'sayur_page.dart';
import 'cuacadingin_page.dart';
import 'cuacapanas_page.dart';
import 'detail_page.dart';
import 'snack.dart';
import 'semuamenu.dart';
import 'kategori_nasi.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MainScreen(),
  ));
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          // Selalu kembalikan false untuk mencegah kembali ke halaman sebelumnya
          return false;
        },
        child: HomeScreen(),
      ),
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFAF1E4),
          elevation: 1.0,
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _lastBackPressedTimestamp = 0;

  final List<Widget> _pages = [
    HomeContent(), // Halaman "Home"
    Resepku (), // Halaman "Tambah"
    ProfilPage(), // Halaman "Profil"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 0
          ? AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 80.0,
              backgroundColor: Color(0xFFFAF1E4),
              title: Row(
                children: [
                  Container(
                    margin: EdgeInsets.all(9.0),
                    child: ClipOval(
                      child: Image.asset(
                        'images/log.jpg',
                        width: 50.0,
                        height: 50.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Text(
                    'CulinaryRec',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: Container(
        color: Color(0xFFFAF1E4),
        child: Padding(
          padding: EdgeInsets.only(top: 8.0),
          child: WillPopScope(
            onWillPop: () async {
              int currentTime = DateTime.now().millisecondsSinceEpoch;

              if (currentTime - _lastBackPressedTimestamp < 2000) {
                // If tapped back twice within 2 seconds, exit the app
                return true;
              } else {
                _lastBackPressedTimestamp = currentTime;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ketuk lagi untuk keluar'),
                    duration: Duration(seconds: 2),
                  ),
                );
                return false;
              }
            },
            child: IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF92A584).withOpacity(0.8),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 40.0),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notes_rounded, size: 40.0),
            label: 'Resepku',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 40.0),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  TextEditingController searchController = TextEditingController();

  void _onSearchSubmitted(String query) {
    print('Query submitted: $query'); // Tambahkan log untuk memeriksa query
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(query: query),
      ),
    );
  }

  void _navigateToCategoryPage(String category) {
    print("Navigating to category page: $category");
    if (category == 'Daging') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DagingPage()),
      );
    } else if (category == 'Sayuran') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SayurPage()),
      );
    } else if (category == 'Soup') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CuacaDinginPage()),
      );
    } else if (category == 'Seafood') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CuacaPanasPage()),
      );
    } else if (category == 'Snack') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => SnackPage()), // Ganti dengan nama kelas halaman SnackPage
      );
    } else if (category == 'Mie') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MiePage()), 
      );
    } else if (category == 'Nasi') {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => NasiPage()), 
      );
    }
  }

  void _navigateToDetailPage(
      String docId,
      String title,
      String imagePath,
      List<String> ingredients,
      String cookingSteps,
      String description,
      String category) {
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

  Widget _buildMenuTerbaruItem(DocumentSnapshot menuSnapshot) {
    if (menuSnapshot.data() == null) {
      return Container(); // Tidak menampilkan apapun jika data null
    }

    String docId = menuSnapshot.id;
    String title = menuSnapshot['judul'];
    String imagePath = menuSnapshot['gambar'];
    String senderUsername = menuSnapshot['username'] ?? 'Unknown';

    return GestureDetector(
      onTap: () {
        _navigateToDetailPage(
          docId,
          title,
          imagePath,
          menuSnapshot['bahan'].toString().split(', '),
          menuSnapshot['cara_memasak'],
          menuSnapshot['deskripsi'], // Provide the description value
          menuSnapshot['kategori'], // Provide the category value
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
                // Ganti Image.asset dengan Image.network
                image: DecorationImage(
                  image: NetworkImage(
                      imagePath), // Ganti dengan imagePath dari Firestore
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
                    'Dikirim oleh: $senderUsername', // Ganti UID dengan username
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _onSearchSubmitted(
                  searchController.text); // Menggunakan _onSearchSubmitted
              FocusScope.of(context).requestFocus(FocusNode());
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30.0),
                color: Colors.lightGreen.withOpacity(0.2),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.black),
                  SizedBox(width: 10.0),
                  Expanded(
                    child: IgnorePointer(
                      child: TextField(
                        onTap: () => _onSearchSubmitted(searchController
                            .text), // Menggunakan _onSearchSubmitted
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari menu masakan...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: 
            Text(
              'Mau masak apa hari ini?',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Kategori',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            height: 110.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryButton('Daging', 'images/daging.jpg'),
                _buildCategoryButton('Sayuran', 'images/sayur.jpeg'),
                _buildCategoryButton('Soup', 'images/soup.jpeg'),
                _buildCategoryButton('Seafood', 'images/seafood.jpg'),
                _buildCategoryButton('Nasi', 'images/nasi.jpeg'),
                _buildCategoryButton('Snack', 'images/snack.jpeg'),
                _buildCategoryButton('Mie', 'images/mie.jpg'),
              ],
            ),
          ),
          SizedBox(height: 17.0),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              'Menu Terbaru',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Menggunakan StreamBuilder untuk mendapatkan data dari Firestore
StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
    .collection('reseps')
    .orderBy('created_at', descending: true)
    .limit(10) // Tampilkan 10 item pertama
    .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    }

    if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    }

    List<DocumentSnapshot> menus = snapshot.data!.docs;

    return Column(
      children: [
        for (var menu in menus) _buildMenuTerbaruItem(menu),
        if (snapshot.data?.docs.length == 10) // Menampilkan tombol hanya jika sudah 10 item
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllMenusPage(),
                ),
              );
            },
            child: Text('Lihat Semua'),
          ),
      ],
    );
  },
),

        ],
      ),
    );
  }

  Widget _buildCategoryButton(String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        _navigateToCategoryPage(title);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        width: 80.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.lightGreen.withOpacity(0.8),
                  ),
                ),
                Container(
                  width: 60.0,
                  height: 60.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Center(
                    child: ClipOval(
                      child: Image.asset(
                        imagePath,
                        width: 57.0,
                        height: 57.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
