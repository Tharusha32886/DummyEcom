// ignore_for_file: use_build_context_synchronously
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/Widgets/show_snackbar.dart';
import 'package:ecom/view/role_based_login/User/User%20Profile/Payment/add_payment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? userId;
  @override
  void initState() {
    userId = FirebaseAuth.instance.currentUser?.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment Method")),
      body:
          userId == null
              ? Center(child: Text("Please log-in to view payment methods."))
              : SizedBox(
                height: double.maxFinite,
                width: double.maxFinite,
                child: StreamBuilder(
                  stream:
                      FirebaseFirestore.instance
                          .collection("User Payment Methods")
                          .where("userId", isEqualTo: userId)
                          .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final methods = snapshot.data!.docs;
                    if (methods.isEmpty) {
                      return const Center(
                        child: Text(
                          "No payment methods found. Please add a payment method ",
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: methods.length,
                      itemBuilder: (context, index) {
                        final method = methods[index];
                        return ListTile(
                          leading: CachedNetworkImage(
                            imageUrl: method['image'],
                            height: 50,
                            width: 50,
                          ),
                          title: Text(method['paymentSystem']),
                          subtitle: const Text(
                            "Actice",
                            style: TextStyle(color: Colors.green),
                          ),
                          trailing: MaterialButton(
                            onPressed: () => _showAddFundsDialog(context, method),
                            child: const Text("Add Fund"),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        onPressed: () {
          //Navigate to add method screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPaymentMethod()),
          );
        },
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  void _showAddFundsDialog(BuildContext context, DocumentSnapshot method) {
    TextEditingController amountController = TextEditingController();
    showDialog(context: context, 
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: Text("Add Funds"),
      content: TextField(
        controller: amountController,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade200,
          labelText: "Amount",
          prefixText: "\$",
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
            ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
           child: const Text("Cancel"),
           ),
            TextButton(
          onPressed: () async {
            final amount = double.tryParse(amountController.text);
            if (amount == null || amount <= 0) {
             showSnackBar(context, "Please enter a valid positive amount");
             return;
            }
            try {
              await method.reference.update({
                'balance': FieldValue.increment(amount),
              });
              Navigator.pop(context);
              showSnackBar(context, "Fund Added Successfully!");
            } catch (e) {
              showSnackBar(context, "Failed to add funds: $e");
            }
          },
           child: const Text("Add"),
           ),
      ],
    ),
    
    );
  }
}
