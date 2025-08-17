import 'package:flutter/material.dart';

class AppModel {
  final String name, image,description,
  //  myDescription1,
  //  myDescription2, 
   category;
  final double rating;
  final int review, price;
  List<Color> fcolor;
  List<String> size;
  bool ischeck;

  AppModel({
    required this.name,
    required this.image,
    required this.description,
    required this.category,
    required this.rating,
    required this.review,
    required this.price,
    required this.fcolor,
    required this.size,
    required this.ischeck,
    // this.myDescription1 = "blaaah",
    // this.myDescription2 = "booooo",
  });
}

List<AppModel> fashionEcommerceApp = [
  // id 1
  AppModel(
    name: "Oversized Fit Printed Mesh T-Shirt",
    rating: 4.9,
    image: "assets/images/ost.png",
    price: 295,
    review: 136,
    ischeck: true,
    category: "Women",
    fcolor: [Colors.black, Colors.blue, Colors.blue[100]!],
    size: [
      "XS"
      "S",
      "M",
      "L",
    ],
    description: "",
  ),
  // id 2
   AppModel(
    name: "Printed Sweatshirt",
    rating: 4.8,
    image: "assets/images/pss.avif",
    price: 314,
    review: 178,
    ischeck: false,
    category: "Men",
    fcolor: [Colors.green, Colors.black, Colors.blue[100]!],
    size: [
      "X"
      "S",
      "XL",
    ],
    description: "",
  ),
   // id 3
   AppModel(
    name: "Lose Fit Sweatshirt",
    rating: 4.8,
    image: "assets/images/lfs.jpg",
    price: 314,
    review: 178,
    ischeck: false,
    category: "Men",
    fcolor: [Colors.green, Colors.black, Colors.blue[100]!],
    size: [
      "X"
      "S",
      "XL",
    ],
    description: "",
  ),
];
