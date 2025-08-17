import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/Core/Provider/favorite_provider.dart';
import 'package:ecom/core/Common/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CuratedItems extends ConsumerWidget {
  final DocumentSnapshot<Object?> eCommerceItems;
  final Size size;

  const CuratedItems({
    super.key,
    required this.eCommerceItems,
    required this.size,
  });

  double _getDiscountedPrice(DocumentSnapshot item) {
    final price = (item['price'] ?? 0).toDouble();
    final discount = (item['discountPercentage'] ?? 0).toDouble();
    return price * (1 - discount / 100);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(favoriteProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: eCommerceItems.id,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: fbackgroundColor2,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: CachedNetworkImageProvider(
                  eCommerceItems['image'] ?? '',
                ),
              ),
            ),
            height: size.height * 0.25,
            width: size.width * 0.5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.topRight,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: provider.isExit(eCommerceItems)
                      ? Colors.white
                      : Colors.black26,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(favoriteProvider).toggleFavorite(eCommerceItems);
                    },
                    child: Icon(
                      provider.isExit(eCommerceItems)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: provider.isExit(eCommerceItems)
                          ? Colors.red
                          : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 7),
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
            Text("${Random().nextInt(2) + 3}.${Random().nextInt(5) + 4})"),
            Text(
              "(${Random().nextInt(300) + 25})",
              style: const TextStyle(color: Colors.black26),
            ),
          ],
        ),
        SizedBox(
          width: size.width * 0.5,
          child: Text(
            eCommerceItems['name'] ?? "N/A",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
        ),
        Row(
          children: [
            Text(
              "\$${_getDiscountedPrice(eCommerceItems).toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.pink,
                height: 1.5,
              ),
            ),
            const SizedBox(width: 5),
            if (eCommerceItems['isDiscounted'] == true)
              Text(
                "\$${(eCommerceItems['price'] ?? 0).toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black26,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
