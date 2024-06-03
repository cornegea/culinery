// firestore_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _recipesCollection = FirebaseFirestore.instance.collection('recipes');

  // Metode untuk mendapatkan data resep terbaru
  Stream<QuerySnapshot> getLatestRecipes() {
    return _recipesCollection.orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> addRecipe({
    required String judulMenu,
    required String gambarMenu,
    required String senderName,
    // ... tambahkan parameter lainnya sesuai kebutuhan
  }) async {
    try {
      await _recipesCollection.add({
        'judulMenu': judulMenu,
        'gambarMenu': gambarMenu,
        'senderName': senderName,
        // ... tambahkan parameter lainnya sesuai kebutuhan
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding recipe: $e');
    }
  }

  // ... tambahkan fungsi lainnya sesuai kebutuhan
}
