import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/Core/Common/cart_order_count.dart';
import 'package:ecom/Core/Common/payment_method_list.dart';
import 'package:ecom/Core/Provider/cart_provider.dart';
import 'package:ecom/Core/Provider/favorite_provider.dart';
import 'package:ecom/Widgets/show_snackbar.dart';
import 'package:ecom/view/role_based_login/User/Screen/Items_detail_screen/Controller/place_order_controller.dart';
import 'package:ecom/view/role_based_login/User/Screen/Items_detail_screen/Widgets/size_and_color.dart';
import 'package:ecom/core/Common/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class ItemsDetailScreen extends ConsumerStatefulWidget {
  final DocumentSnapshot<Object?>? productItems;
  const ItemsDetailScreen({super.key, required this.productItems});

  @override
  ConsumerState<ItemsDetailScreen> createState() => _ItemsDetailScreenState();
}

class _ItemsDetailScreenState extends ConsumerState<ItemsDetailScreen> {
  int currentIndex = 0;
  int selectedColorIndex = 1;
  int selectedSizeIndex = 1;
  String? selectedPaymentMethodId;
  double? selectedPaymentBalance;
  var myDescription1 = "Elevate your casual wardrobe with our ";
  var myDescription2 =
      "Crafted from premium cotton for maximum comfort, this relaxed fit tee features.";
  late TextEditingController addressController;

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
    Size size = MediaQuery.of(context).size;
    CartProvider cp = ref.watch(cartService);
    FavoriteProvider provider = ref.watch(favoriteProvider);

    final finalPrice = num.parse(
      ((widget.productItems?.get('price') ?? 0) *
              (1 - (widget.productItems?.get('discountPercentage') ?? 0) / 100))
          .toStringAsFixed(2),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: fbackgroundColor2,
        title: const Text("Detail Product"),
        actions: const [CartOrderCount(), SizedBox(width: 20)],
      ),
      body: ListView(
        children: [
          Container(
            color: fbackgroundColor2,
            height: size.height * 0.46,
            width: size.width,
            child: PageView.builder(
              onPageChanged: (value) {
                setState(() {
                  currentIndex = value;
                });
              },
              itemCount: 3,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Hero(
                      tag: widget.productItems?.id ?? '',
                      child: CachedNetworkImage(
                        imageUrl: widget.productItems?.get('image') ?? '',
                        height: size.height * 0.4,
                        width: size.width * 0.85,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 4),
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: index == currentIndex
                                ? Colors.blue
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "H&M",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black26,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(Icons.star, color: Colors.amber, size: 17),
                    Text(
                      "${Random().nextInt(2) + 3}.${Random().nextInt(5) + 4})",
                    ),
                    Text(" (${Random().nextInt(300) + 55})"),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        if (widget.productItems != null) {
                          provider.toggleFavorite(widget.productItems!);
                        }
                      },
                      child: Icon(
                        widget.productItems != null &&
                                provider.isExit(widget.productItems!)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: widget.productItems != null &&
                                provider.isExit(widget.productItems!)
                            ? Colors.red
                            : Colors.black,
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.productItems?.get('name') ?? "Unnamed Item",
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "\$$finalPrice",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.pink,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(width: 5),
                    if (widget.productItems?.get('isDiscounted') == true)
                      Text(
                        "\$${(widget.productItems?.get('price') ?? 0).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black26,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  "$myDescription1 ${widget.productItems?.get('name') ?? ''} $myDescription2",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black38,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizeAndColor(
                  colors: widget.productItems?.get('fcolor') ?? [],
                  sizes: widget.productItems?.get('size') ?? [],
                  onColorSelected: (index) {
                    setState(() {
                      selectedColorIndex = index;
                    });
                  },
                  onSizeSelected: (index) {
                    setState(() {
                      selectedSizeIndex = index;
                    });
                  },
                  selectedColorIndex: selectedColorIndex,
                  selectedSizeIndex: selectedSizeIndex,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: Colors.white,
        elevation: 0,
        label: SizedBox(
          width: size.width * 0.9,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      if (widget.productItems != null) {
                        final productId = widget.productItems!.id;
                        final productData =
                            widget.productItems!.data() as Map<String, dynamic>;
                        final selectedColor =
                            widget.productItems!.get('fcolor')[selectedColorIndex];
                        final selectedSize =
                            widget.productItems!.get('size')[selectedSizeIndex];

                        cp.addCart(
                          productId,
                          productData,
                          selectedColor,
                          selectedSize,
                        );
                        showSnackBar(
                          context,
                          " ${productData['name']} added to cart!",
                        );
                      }
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.shopping_bag, color: Colors.black),
                        SizedBox(width: 5),
                        Text(
                          "ADD TO CART",
                          style: TextStyle(
                            color: Colors.black,
                            letterSpacing: -1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final productId = widget.productItems!.id;
                    final productData =
                        widget.productItems!.data() as Map<String, dynamic>;
                    final selectedColor =
                        widget.productItems!['fcolor'][selectedColorIndex];
                    final selectedSize =
                        widget.productItems!['size'][selectedSizeIndex];
                    _showOrderConfirmationDialog(
                      cp,
                      context,
                      productId,
                      productData,
                      selectedColor,
                      selectedSize,
                      finalPrice + 4.99,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    color: Colors.black,
                    child: const Center(
                      child: Text(
                        "BUY NOW",
                        style: TextStyle(
                          color: Colors.white,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderConfirmationDialog(
    CartProvider cp,
    BuildContext context,
    String productId,
    Map<String, dynamic> productData,
    String selectedColor,
    String selectedSize,
    double finalPrice,
  ) {
    String? addressError;
    
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
                    Text("Product Name: ${productData['name']}"),
                    const Text("Quantity: 1"),
                    Text("Selected Color: $selectedColor"),
                    Text("Selected Size: $selectedSize"),
                    Text("Total Price: \$${finalPrice.toStringAsFixed(2)}"),
                    const SizedBox(height: 20),
                    
                    const Text(
                      "Select Payment Method",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    PaymentMethodList(
                      selectedPaymentMethodId: selectedPaymentMethodId,
                      selectedPaymentBalance: selectedPaymentBalance,
                      finalAmount: finalPrice,
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
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addressController,
                      decoration: InputDecoration(
                        hintText: "Example: 123 Main St, Kandy , Sri Lanka",
                        errorText: addressError,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            // Validate inputs
                            if (selectedPaymentMethodId == null) {
                              showSnackBar(
                                context,
                                "Please select a payment method!",
                              );
                              return;
                            }
                            
                            if (selectedPaymentBalance! < finalPrice) {
                              showSnackBar(
                                context,
                                "Insufficient balance in selected payment method!",
                              );
                              return;
                            }
                            
                            if (addressController.text.trim().isEmpty) {
                              setDialogState(() {
                                addressError = "Please enter your address!";
                              });
                              return;
                            }
                            
                            if (addressController.text.length < 10) {
                              setDialogState(() {
                                addressError = "Address must be at least 10 characters";
                              });
                              return;
                            }
                            
                            // All validations passed - place order
                            placeOrder(
                              productId,
                              productData,
                              selectedColor,
                              selectedSize,
                              selectedPaymentMethodId!,
                              finalPrice,
                              addressController.text,
                              context,
                            );
                            
                            // Clear the address field for next use
                            addressController.clear();
                          },
                          child: const Text("Confirm Order"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("Cancel"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}