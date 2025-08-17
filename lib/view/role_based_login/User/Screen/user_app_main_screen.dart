import 'package:ecom/view/role_based_login/User/Screen/user_app_home_screen.dart';
import 'package:ecom/view/role_based_login/User/User%20Activity/favorite_screen.dart';
import 'package:ecom/view/role_based_login/User/User%20Profile/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class UserAppMainScreen extends StatefulWidget {
  const UserAppMainScreen({super.key});

  @override
  State<UserAppMainScreen> createState() => _UserAppMainScreenState();
}

class _UserAppMainScreenState extends State<UserAppMainScreen> {
  int selectedIndex = 0;
  final List pages = [
    const UserAppHomeScreen(),
    // const Scaffold(),
    const FavoriteScreen(),
   const UserProfile(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.black38,
        selectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (value) {
          selectedIndex = value;
          setState(() {});
        },
        elevation: 0,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
             label: "Home"),
          // BottomNavigationBarItem(
          //   icon: Icon(Iconsax.search_normal),
          //   label: "Search",
          // ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.heart),
            label: "Favorite",
          ),
          BottomNavigationBarItem(icon: Icon(Iconsax.user), label: "Profile"),
        ],
      ),
      body: pages[selectedIndex],
    );
  }
}
