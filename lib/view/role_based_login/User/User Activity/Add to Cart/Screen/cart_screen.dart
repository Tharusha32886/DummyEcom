// ignore_for_file: use_build_context_synchronously

import 'package:dotted_line/dotted_line.dart';
import 'package:ecom/Core/Common/Utils/colors.dart';
import 'package:ecom/Core/Common/payment_method_list.dart';
import 'package:ecom/Core/Provider/cart_provider.dart';
import 'package:ecom/Widgets/show_snackbar.dart';
import 'package:ecom/view/role_based_login/User/User%20Activity/Add%20to%20Cart/Widgets/cart_items.dart';
import 'package:ecom/view/role_based_login/User/User%20Profile/Order/my_order_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  String? selectedPaymentMethodId;
  double? selectedPaymentBalance;
  late TextEditingController addressController;
  String? addressError;

  @override
  void initState() {
    super.initState();
    addressController = TextEditingController();
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cp = ref.watch(cartService);
    final carts = cp.carts.reversed.toList();
    return Scaffold(
      backgroundColor: fbackgroundColor1,
      appBar: AppBar(
        backgroundColor: fbackgroundColor1,
        elevation: 0,
        title: const Text(
          "My Cart",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: carts.isNotEmpty
                ? ListView.builder(
                    itemCount: carts.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Dismissible(
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            cp.deleteCartItem(carts[index].productId);
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            child: const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Iconsax.trash,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          key: Key(carts[index].productId),
                          child: CartItems(cart: carts[index]),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      "Your cart is empty!",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
          ),
          if (carts.isNotEmpty) _buildSummarySection(context, cp),
        ],
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context, CartProvider cp) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                "Delivery",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: DottedLine()),
              const SizedBox(width: 10),
              Text(
                "\$4.99",
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text(
                "Total Order",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(child: DottedLine()),
              const SizedBox(width: 10),
              Text(
                "\$${(cp.totalCart()).toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          MaterialButton(
            color: Colors.black,
            height: 70,
            minWidth: MediaQuery.of(context).size.width - 50,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onPressed: () {
              _showOrderConfirmationDialog(context, cp);
            },
            child: Text(
              "Pay \$${((cp.totalCart() + 4.99).toStringAsFixed(2))}",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderConfirmationDialog(BuildContext context, CartProvider cp) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Confirm Your Order"),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...cp.carts.map((cartItem) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${cartItem.productData['name']} x ${cartItem.quantity}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                      ],
                    )),
                    const SizedBox(height: 16),
                    Text(
                      "Total Payable Price: \$${(cp.totalCart() + 4.99).toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Select Payment Method",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    PaymentMethodList(
                      selectedPaymentMethodId: selectedPaymentMethodId,
                      selectedPaymentBalance: selectedPaymentBalance,
                      finalAmount: cp.totalCart() + 4.99,
                      onPaymentMethodSelected: (methodId, balance) {
                        setDialogState(() {
                          selectedPaymentMethodId = methodId;
                          selectedPaymentBalance = balance;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Delivery Address",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addressController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: "Example: 123 Main St, Kandy, Sri lanaka",
                        errorText: addressError,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setDialogState(() {
                          addressError = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    _validateAndSubmitOrder(cp, context, setDialogState);
                  },
                  child: const Text(
                    "Confirm Order",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _validateAndSubmitOrder(
    CartProvider cp,
    BuildContext context,
    void Function(void Function()) setDialogState,
  ) {
    // Validate payment method
    if (selectedPaymentMethodId == null) {
      showSnackBar(context, "Please select a payment method!");
      return;
    }

    // Validate payment balance
    if (selectedPaymentBalance! < cp.totalCart() + 4.99) {
      showSnackBar(
        context,
        "Insufficient balance in selected payment method!",
      );
      return;
    }

    // Validate address
    final address = addressController.text.trim();
    if (address.isEmpty) {
      setDialogState(() {
        addressError = "Please enter your delivery address";
      });
      return;
    }

    if (address.length < 10) {
      setDialogState(() {
        addressError = "Address must be at least 10 characters";
      });
      return;
    }

    // All validations passed - proceed with order
    _saveOrder(cp, context);
  }

  Future<void> _saveOrder(CartProvider cp, BuildContext context) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      showSnackBar(context, "You need to be logged in to place an order.");
      return;
    }

    try {
      await cp.saveOrder(
        userId,
        context,
        selectedPaymentMethodId,
        cp.totalCart() + 4.99,
        addressController.text,
      );

      // Clear the address field for next use
      addressController.clear();

      showSnackBar(context, "Order placed successfully!");
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MyOrderScreen()),
        (route) => false,
      );
    } catch (e) {
      showSnackBar(context, "Failed to place order: ${e.toString()}");
    }
  }
}