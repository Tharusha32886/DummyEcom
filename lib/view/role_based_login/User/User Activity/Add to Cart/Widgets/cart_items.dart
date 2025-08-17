import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom/Core/Common/color_conversion.dart';
import 'package:ecom/Core/Provider/Model/cart_model.dart';
import 'package:ecom/Core/Provider/cart_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItems extends ConsumerWidget {
  final CartModel cart;
  const CartItems({super.key, required this.cart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    CartProvider cp = ref.watch(cartService);
    Size size = MediaQuery.of(context).size;

    // Safe calculation of final price with null checks
    final price = cart.productData['price'] ?? 0.0;
    final discountPercentage = cart.productData['discountPercentage'] ?? 0.0;
    final finalPrice = num.parse((price * (1 - (discountPercentage / 100))).toStringAsFixed(2));

    // final finalPrice = num.parse(
    //   (cart.productData['price'] ??
    //           0.0 * (1 - cart.productData['discountPercentage'] / 100))
    //       .toStringAsFixed(2),
    // );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      height: 120,
      width: size.width / 1.1,
      child: Column(
        children: [
          Row(
            children: [
              const SizedBox(width: 20),
              CachedNetworkImage(
                imageUrl: cart.productData['image'] ?? "",
                height: 120,
                width: 100,
                fit: BoxFit.cover,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      cart.productData['name'] ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Text("Color :"),
                        const SizedBox(width: 5),
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: getColorFromName(cart.selectedColor),
                        ),
                        const SizedBox(width: 10),
                        const Text("Size :"),
                        Text(
                          cart.selectedSize,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          "\$$finalPrice",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 45),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (cart.quantity > 1) {
                                  cp.decreaseQuantity(cart.productId);
                                }
                              },
                              child: Container(
                                width: 25,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(7),
                                  ),
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              cart.quantity.toString(),
                              style: const  TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),

                            GestureDetector(
                              onTap: () {
                                cp.addCart(
                                  cart.productId,
                                  cart.productData,
                                  cart.selectedColor,
                                  cart.selectedSize,
                                );
                              },
                              child: Container(
                                width: 25,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(7),
                                  ),
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
