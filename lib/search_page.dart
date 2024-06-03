import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_page.dart';

class SearchPage extends StatefulWidget {
  final String query;

  SearchPage({required this.query});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial value of _searchController from widget.query
    _searchController.text = widget.query;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAF1E4),
      appBar: AppBar(
        toolbarHeight: 70.0,
        backgroundColor: Color(0xFFCEDEBD),
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Cari menu masakan...',
            border: InputBorder.none,
          ),
          textCapitalization: TextCapitalization.none,
          onSubmitted: (query) {
            _onSearchSubmitted(query);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _onSearchSubmitted(_searchController.text);
            },
          ),
        ],
      ),
      body: _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    if (_searchController.text.isNotEmpty) {
      return StreamBuilder<QuerySnapshot>(
        key: Key(_searchController.text),
        stream: FirebaseFirestore.instance
          .collection('reseps')
          .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            var searchResults = snapshot.data!.docs;
            var filteredResults = searchResults.where((result) => result['judul'].toLowerCase().contains(_searchController.text.toLowerCase())).toList();

            if (filteredResults.isEmpty) {
              return Center(child: Text('Tidak ada hasil pencarian'));
            }

            return ListView.builder(
              itemCount: filteredResults.length,
              itemBuilder: (context, index) {
                var resultData = filteredResults[index].data() as Map<String, dynamic>;
                var judul = resultData['judul'];
                var gambar = resultData['gambar'];

                return ListTile(
                  title: Text(judul),
                  leading: Container(
                    width: 50.0,
                    height: 50.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(gambar),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  onTap: () {
                    _onSearchResultTapped(context, resultData);
                  },
                );
              },
            );
          }
        },
      );
    } else {
      // Show a message or widget when search is empty
      return Center(child: Text('Silakan masukkan kata kunci pencarian.'));
    }
  }

  void _onSearchSubmitted(String query) {
    // Clear the search history
    _searchController.clear();
    // Handle navigation or other actions with the submitted query
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SearchPage(query: query.toLowerCase()),
      ),
    );

    print('Search submitted: $query');
  }

  void _onSearchResultTapped(
    BuildContext context, Map<String, dynamic> resultData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailMenuPage(
          docId: resultData['docId'] ?? '',
          title: resultData['judul'] ?? '',
          description: resultData['deskripsi'] ?? '',
          imagePath: resultData['gambar'] ?? '',
          category: resultData['kategori'] ?? '',
          ingredients: [resultData['bahan'].toString()],
          cookingSteps: resultData['cara_memasak'] ?? '',
        ),
      ),
    );
  }
}
