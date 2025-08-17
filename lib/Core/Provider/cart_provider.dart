// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:ecom/Core/Provider/Model/cart_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final cartService = ChangeNotifierProvider<CartProvider>(
  (ref) => CartProvider(),
);

class CartProvider with ChangeNotifier {
  List<CartModel> _carts = [];
  List<CartModel> get carts => _carts;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CartProvider() {
    loadCartItems(); // load cart items on initialzion
  }
  void reset() {
    _carts = [];
    notifyListeners();
  }

  final userId = FirebaseAuth.instance.currentUser?.uid;
  set carts(List<CartModel> carts) {
    _carts = carts;
    notifyListeners();
  }

  // add items to cart
  Future<void> addCart(
    String productId,
    Map<String, dynamic> produductData,
    String selectedColor,
    String selectedSize,
  ) async {
    int index = _carts.indexWhere(
      (elements) => elements.productId == productId,
    );
    if (index != -1) {
      // items exists, update quantity and selected attributes
      var existingItem = _carts[index];
      _carts[index] = CartModel(
        productId: productId,
        productData: produductData,
        quantity: existingItem.quantity + 1,
        selectedColor: selectedColor,
        selectedSize: selectedSize,
      );
      await _updateCartInFirebase(productId, _carts[index].quantity);
    } else {
      // Items does not exist , add new entry
      _carts.add(
        CartModel(
          productId: productId,
          productData: produductData,
          quantity: 1,
          selectedColor: selectedColor,
          selectedSize: selectedSize,
        ),
      );
      await _firestore.collection("userCart").doc(productId).set({
        "uid": userId,
        "productData": produductData,
        "quantity": 1,
        "selectedColor": selectedColor,
        "selectedSize": selectedSize,
      });
    }
    notifyListeners();
  }

  // increase quantity
  Future<void> addQuantity(String productId) async {
    int index = _carts.indexWhere((element) => element.productId == productId);
    _carts[index].quantity += 1;

    await _updateCartInFirebase(productId, _carts[index].quantity);
    notifyListeners();
  }

  // Decrease quantity or remove the items
  Future<void> decreaseQuantity(String productId) async {
    int index = _carts.indexWhere((element) => element.productId == productId);
    _carts[index].quantity -= 1;
    if (_carts[index].quantity <= 0) {
      _carts.removeAt(index);
      await _firestore.collection("userCart").doc(productId).delete();
    } else {
      await _updateCartInFirebase(productId, _carts[index].quantity);
    }
    notifyListeners();
  }

  // check if the product exits in the cart or not
  bool productExit(String productId) {
    return _carts.any((element) => element.productId == productId);
  }

  // calculate total cart value
  double totalCart() {
    double total = 0;
    for (var i = 0; i < _carts.length; i++) {
      // Safely get values with null checks and default values
      final price = _carts[i].productData["price"]?.toDouble() ?? 0.0;
      final discountPercentage =
          _carts[i].productData["discountPercentage"]?.toDouble() ?? 0.0;
      final quantity = _carts[i].quantity;

      // Calculate final price with safe operations
      final discountMultiplier = (1 - (discountPercentage / 100));
      final discountedPrice = price * discountMultiplier;
      final finalPrice = double.parse(discountedPrice.toStringAsFixed(2));

      total += quantity * finalPrice;
    }
    return total;
  }

  // save order list to firetore
  Future<void> saveOrder(
    String userId,
    BuildContext context,
    paymentMethodId,
    finalPrice,
    address,
  ) async {
    if (_carts.isEmpty) return;

    final paymentRef = FirebaseFirestore.instance
        .collection("User Payment Methods")
        .doc(paymentMethodId);
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(paymentRef);
        if (!snapshot.exists) {
          throw Exception("Payment method not found");
        }
        final currentBalance = snapshot['balance'] as num;
        if (currentBalance < finalPrice) {
          throw Exception("Insufficient balance");
        }
        // update payment method balance
        transaction.update(paymentRef, {'balance': currentBalance - finalPrice});
        // create order data
        final orderData = {
          'userId': userId,
          'items':
              _carts.map((cartItem) {
                return {
                  'productId': cartItem.productId,
                  'quantity': cartItem.quantity,
                  'selectedColor': cartItem.selectedColor,
                  'selectedSize': cartItem.selectedSize,
                  'name': cartItem.productData['name'],
                  'price': cartItem.productData['price'],
                };
              }).toList(),
          'totalPrice': finalPrice,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'address': address,
        };
        //craete new order
        final orderRef = FirebaseFirestore.instance.collection("Orders").doc();
        transaction.set(orderRef, orderData);
      });
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // load cart items from firebase to display it in cart screen
  Future<void> loadCartItems() async {
    try {
      QuerySnapshot snapshot =
          await _firestore
              .collection("userCart")
              .where("uid", isEqualTo: userId)
              .get();
      _carts =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return CartModel(
              productId: doc.id,
              productData: data["productData"],
              quantity: data["quantity"],
              selectedColor: data["selectedColor"],
              selectedSize: data["selectedSize"],
            );
          }).toList();
    } catch (e) {
      print(e.toString());
    }
    notifyListeners();
  }
  //save order list in firestore

  //remove cartitems from firestore
  Future<void> deleteCartItem(String productId) async {
    int index = _carts.indexWhere((element) => element.productId == productId);
    if (index != -1) {
      _carts.removeAt(index); // remove item from local list
      await _firestore
          .collection("userCart")
          .doc(productId)
          .delete(); // remove item from firestore
      notifyListeners(); // notify listeners to update ui
    }
  }

  // Update cart items in firestore
  Future<void> _updateCartInFirebase(String productId, int quantity) async {
    try {
      await _firestore.collection("userCart").doc(productId).update({
        "quantity": quantity,
      });
    } catch (e) {
      print(e.toString());
    }
  }
}
