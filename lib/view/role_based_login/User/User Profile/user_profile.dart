import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/Core/Provider/cart_provider.dart';
import 'package:ecom/Core/Provider/favorite_provider.dart';
import 'package:ecom/services/auth_service.dart';
import 'package:ecom/view/role_based_login/User/User%20Profile/Order/my_order_screen.dart';
import 'package:ecom/view/role_based_login/User/User%20Profile/Payment/payment_screen.dart';
import 'package:ecom/view/role_based_login/User/User%20Profile/aboutUs/about_us_page.dart';
import 'package:ecom/view/role_based_login/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

AuthService authService = AuthService();

class UserProfile extends ConsumerWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(backgroundColor: Colors.white),
      body: SafeArea(
        child: Center(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(

                mainAxisAlignment: MainAxisAlignment.start,
        
                children: [
                  const SizedBox(height: 20),
                  // currunt login user details
                  SizedBox(
                    width: double.maxFinite,
                    // fetch the user data from firebase
                    child: StreamBuilder<DocumentSnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection("users")
                              .doc(userId)
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return const Center(child: CircularProgressIndicator());
                        }
        
                        final user = snapshot.data!;
                        return Column(
                          children: [
                            const CircleAvatar(
                              radius: 60,
                              backgroundImage: CachedNetworkImageProvider(
                                "https://www.pngarts.com/files/5/User-Avatar-PNG-Image.png",
                              ),
                            ),
                            Text(
                              user['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                height: 2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user['email'],
                              style: const TextStyle(height: 0.5),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.black, thickness: 1),
                  Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyOrderScreen(),
                            ),
                          );
                        },
                        child: const ListTile(
                          leading: Icon(Icons.change_circle_rounded, size: 30),
                          title: Text(
                            'Order',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentScreen(),
                            ),
                          );
                        },
                        child: const ListTile(
                          leading: Icon(Icons.payments, size: 30),
                          title: Text(
                            'Payment Method',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutUsPage(),
                            ),
                          );
                        },
                        child: const ListTile(
                          leading: Icon(Icons.info, size: 30),
                          title: Text(
                            'About Us',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          authService.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                          ref.invalidate(cartService);
                          ref.invalidate(favoriteProvider);
                        },
                        child: const ListTile(
                          leading: Icon(Icons.exit_to_app, size: 30),
                          title: Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
