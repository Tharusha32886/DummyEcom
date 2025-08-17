import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/Core/Common/Utils/colors.dart';
import 'package:ecom/Core/Provider/favorite_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final provider = ref.watch(favoriteProvider);
    
    return Scaffold(
      backgroundColor: fbackgroundColor2,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: fbackgroundColor2,
        centerTitle: true,
        title: const Text(
          "Favorite",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: userId == null
          ? const Center(child: Text("Please log-in to view favorites"))
          : provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildFavoriteContent(context, ref),
    );
  }

  Widget _buildFavoriteContent(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("userFavorite")
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No favorite items found",
              style: TextStyle(color: Colors.black54),
            ),
          );
        }

        final favoriteDocs = snapshot.data!.docs;
        
        return FutureBuilder<List<DocumentSnapshot>>(
          future: Future.wait(
            favoriteDocs.map(
              (doc) => FirebaseFirestore.instance
                  .collection('items')
                  .doc(doc.id)
                  .get(),
            ),
          ),
          builder: (context, futureSnapshot) {
            if (futureSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            // This is the key fix - properly filter out non-existing documents
            final existingItems = futureSnapshot.data?.where((doc) => doc.exists).toList() ?? [];
            
            if (existingItems.isEmpty) {
              return const Center(
                child: Text(
                  "No favorite items available",
                  style: TextStyle(color: Colors.black54),
                ),
              );
            }

            return ListView.builder(
              itemCount: existingItems.length,
              itemBuilder: (context, index) {
                final favoriteItem = existingItems[index];
                
                return GestureDetector(
                  onTap: () {},
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: CachedNetworkImageProvider(
                                      favoriteItem['image'],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Text(
                                        favoriteItem['name'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17,
                                        ),
                                      ),
                                    ),
                                    Text("${favoriteItem['category']} Fashion"),
                                    Text(
                                      "\$${favoriteItem['price']}.00",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.pink,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 50,
                        right: 35,
                        child: GestureDetector(
                          onTap: () {
                            ref.read(favoriteProvider).toggleFavorite(favoriteItem);
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 25,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}