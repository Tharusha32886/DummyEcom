import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoriteProvider = ChangeNotifierProvider<FavoriteProvider>(
  (ref) => FavoriteProvider(),
);

class FavoriteProvider extends ChangeNotifier {
  List<String> _favoriteIds = [];
  bool _isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<String> get favorites => _favoriteIds;
  bool get isLoading => _isLoading;

  void reset() {
    _favoriteIds = [];
    notifyListeners();
  }

  final userId = FirebaseAuth.instance.currentUser?.uid;
  
  FavoriteProvider() {
    if (userId != null) {
      loadFavorites();
    } else {
      _isLoading = false;
    }
  }

  void toggleFavorite(DocumentSnapshot product) async {
    String productId = product.id;
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
      await _removeFavorite(productId);
    } else {
      _favoriteIds.add(productId);
      await _addFavorite(productId);
    }
    notifyListeners();
  }

  bool isExit(DocumentSnapshot product) {
    return _favoriteIds.contains(product.id);
  }

  Future<void> _addFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).set({
        "isFavorite": true,
        "userId": userId,
      });
    } catch (e) {
      throw (e.toString());
    }
  }

  Future<void> _removeFavorite(String productId) async {
    try {
      await _firestore.collection("userFavorite").doc(productId).delete();
    } catch (e) {
      throw (e.toString());
    }
  }

  Future<void> loadFavorites() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      QuerySnapshot snapshot = await _firestore
          .collection("userFavorite")
          .where("userId", isEqualTo: userId)
          .get();
          
      _favoriteIds = snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw (e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}