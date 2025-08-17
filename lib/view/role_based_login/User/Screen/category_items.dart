import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/Core/Models/sub_category.dart';
import 'package:ecom/Core/Provider/favorite_provider.dart';
import 'package:ecom/view/role_based_login/User/Screen/Items_detail_screen/Screen/items_detail_screen.dart';
import 'package:ecom/core/Common/Utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';


class CategoryItems extends ConsumerStatefulWidget {
  final String selectedCategory;
  final String category;
  const CategoryItems({
    super.key,
    required this.category,
    required this.selectedCategory,
  });

  @override
  ConsumerState<CategoryItems> createState() => _CategoryItemsState();
}

class _CategoryItemsState extends ConsumerState<CategoryItems> {
  Map<String, Map<String, dynamic>> randomValueCache = {};
  TextEditingController searchController = TextEditingController();
  List<QueryDocumentSnapshot> allItems = [];
  List<QueryDocumentSnapshot> filteredItems = [];

  @override
  void initState() {
    searchController.addListener(_onSearchChanged);
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String searchTerm = searchController.text.toLowerCase();
    setState(() {
      filteredItems = allItems.where((item) {
        final data = item.data() as Map<String, dynamic>;
        final itemName = data['name'].toString().toLowerCase();
        return itemName.contains(searchTerm);
      }).toList();
    });
  }

  double getDiscountedPrice(Map<String, dynamic> item) {
    final price = item['price'];
    final discount = item['discountPercentage'];
    if (price is num && discount is num) {
      return (price * (1 - discount / 100)).toDouble();
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference itemsCollection = FirebaseFirestore.instance.collection("items");
    Size size = MediaQuery.of(context).size;
    final provider = ref.watch(favoriteProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.arrow_back_ios_new),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 45,
                      child: TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(5),
                          hintText: "${widget.category}'s Fashion",
                          hintStyle: TextStyle(color: Colors.black38),
                          filled: true,
                          fillColor: fbackgroundColor2,
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
                          prefixIcon: Icon(Iconsax.search_normal, color: Colors.black38),
                          border: const OutlineInputBorder(borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Filter categories
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    filterCategory.length,
                    (index) => Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Row(
                          children: [
                            Text(filterCategory[index]),
                            const SizedBox(width: 5),
                            index == 0
                                ? const Icon(Icons.filter_list, size: 15)
                                : const Icon(Icons.keyboard_arrow_down, size: 15),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Subcategories
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  subcategory.length,
                  (index) => InkWell(
                    onTap: () {},
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: fbackgroundColor1,
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(subcategory[index].image),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(subcategory[index].name),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Items Grid
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: itemsCollection.where('category', isEqualTo: widget.selectedCategory).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final items = snapshot.data!.docs;
                    if (allItems.isEmpty) {
                      allItems = items;
                      filteredItems = items;
                    }
                    if (filteredItems.isEmpty) {
                      return const Center(child: Text("No items found"));
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: filteredItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.6,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final doc = filteredItems[index];
                        final item = doc.data() as Map<String, dynamic>;
                        final itemId = doc.id;

                        if (!randomValueCache.containsKey(itemId)) {
                          randomValueCache[itemId] = {
                            "rating": "${Random().nextInt(2) + 3}.${Random().nextInt(5) + 4}",
                            "reviews": Random().nextInt(300) + 100,
                          };
                        }
                        final cachedRating = randomValueCache[itemId]!['rating'];
                        final cachedReviews = randomValueCache[itemId]!['reviews'];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ItemsDetailScreen(productItems: doc),
                              ),
                            );
                          },
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Hero(
                                  tag: doc.id,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: fbackgroundColor2,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: CachedNetworkImageProvider(item['image']),
                                      ),
                                    ),
                                    height: size.height * 0.25,
                                    width: size.width * 0.5,
                                    child: Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Align(
                                        alignment: Alignment.topRight,
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundColor: provider.isExit(doc)
                                              ? Colors.white
                                              : Colors.black26,
                                          child: GestureDetector(
                                            onTap: () {
                                              ref.read(favoriteProvider).toggleFavorite(doc);
                                            },
                                            child: Icon(
                                              provider.isExit(doc)
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: provider.isExit(doc) ? Colors.red : Colors.white,
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
                                    Text("H&M", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black26)),
                                    const SizedBox(width: 5),
                                    Icon(Icons.star, color: Colors.amber, size: 17),
                                    Text("$cachedRating"),
                                    Text("($cachedReviews)", style: TextStyle(color: Colors.black38)),
                                  ],
                                ),
                                SizedBox(
                                  width: size.width * 0.5,
                                  child: Text(
                                    item['name'] ?? '',
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
                                      "\$${getDiscountedPrice(item).toStringAsFixed(2)}",
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.pink,
                                        height: 1.5,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    if (item['isDiscounted'] == true && item['price'] != null)
                                      Text(
                                        "\$${item['price'].toString()}.00",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          color: Colors.black26,
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
