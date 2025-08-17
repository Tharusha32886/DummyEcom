import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/Core/Common/cart_order_count.dart';
import 'package:ecom/Core/Models/category_model.dart';
import 'package:ecom/view/role_based_login/User/Screen/Items_detail_screen/Screen/items_detail_screen.dart';
import 'package:ecom/core/Common/Utils/colors.dart';
import 'package:ecom/view/role_based_login/User/Screen/category_items.dart';
import 'package:ecom/Widgets/banner.dart';
import 'package:ecom/Widgets/curated_items.dart';
import 'package:flutter/material.dart';

class UserAppHomeScreen extends StatefulWidget {
  const UserAppHomeScreen({super.key});

  @override
  State<UserAppHomeScreen> createState() => _UserAppHomeScreenState();
}

class _UserAppHomeScreenState extends State<UserAppHomeScreen> {
  final CollectionReference categoriesItems = 
      FirebaseFirestore.instance.collection("Category");
      
  final CollectionReference items = 
      FirebaseFirestore.instance.collection("items");

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 50),
            // Header section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    "assets/images/icon2.png",
                    height: 40,
                  ),
                  const CartOrderCount(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Banner section
            const MyBanner(),
            
            // Shop By Category section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Shop By Category",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToAllCategories(),
                    child: const Text(
                      "See All",
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 0,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Categories horizontal list
            StreamBuilder(
              stream: categoriesItems.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        streamSnapshot.data!.docs.length,
                        (index) => InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoryItems(
                                  selectedCategory: 
                                      streamSnapshot.data!.docs[index]['name'],
                                  category: 
                                      streamSnapshot.data!.docs[index]['name'],
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: fbackgroundColor1,
                                  backgroundImage: AssetImage(
                                    category[index].image,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(category[index].name),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
            
            // Curated For You section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Curated For You",
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 0,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToAllProducts(),
                    child: const Text(
                      "See All",
                      style: TextStyle(
                        fontSize: 16,
                        letterSpacing: 0,
                        color: Colors.black45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Curated items horizontal list
            StreamBuilder(
              stream: items.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        snapshot.data!.docs.length,
                        (index) {
                          final eCommerceItems = snapshot.data!.docs[index];
                          return Padding(
                            padding: index == 0
                                ? const EdgeInsets.symmetric(horizontal: 20)
                                : const EdgeInsets.only(right: 20),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ItemsDetailScreen(
                                      productItems: eCommerceItems,
                                    ),
                                  ),
                                );
                              },
                              child: CuratedItems(
                                eCommerceItems: eCommerceItems,
                                size: size,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAllCategories() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryItems(
          selectedCategory: '', // Show all categories
          category: '',
        ),
      ),
    );
  }

  void _navigateToAllProducts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryItems(
          selectedCategory: "All Products", // Or create a dedicated ProductsScreen
          category: "All Products",
        ),
      ),
    );
  }
}