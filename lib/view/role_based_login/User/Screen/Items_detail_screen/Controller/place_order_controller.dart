// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/view/role_based_login/User/User%20Profile/Order/my_order_screen.dart';
import 'package:ecom/widgets/show_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


Future<void> placeOrder(
  String productId,
  Map<String, dynamic> productData,
  String selectedColor,
  String selectedSize,
  String paymentMethodId,
  num finalPrice,
  String address,
  BuildContext context,
) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    showSnackBar(
      context,
      "User not logged in. Please log in to place an order.",
    );
    return;
  }
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
        'items': [
          {
            'productId': productId,
            'quantity': 1,
            'selectedColor': selectedColor,
            'selectedSize': selectedSize,
            'name': productData['name'],
            'price': productData['price'],
          },
        ],
        'totalPrice': finalPrice,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'address': address,
      };
      //craete new order
      final orderRef = FirebaseFirestore.instance.collection("Orders").doc();
      transaction.set(orderRef, orderData);
    });
    showSnackBar(context, "Order placed successfully.");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyOrderScreen()),
    );
  } on FirebaseException catch (e) {
    showSnackBar(context, "Firebase Error: ${e.message}");
    
  } on Exception catch (e) {
    showSnackBar(context, "Error: ${e.toString()}");
  }
}
