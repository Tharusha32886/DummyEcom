class SubCategory {
  final String name, image;
  SubCategory({required this.name, required this.image});
}

List<SubCategory> subcategory = [
  SubCategory(name: "Bags", image: "assets/images/bag.jpg"),
  SubCategory(name: "Wallets", image: "assets/images/wallet.jpg"),
  SubCategory(name: "Footwear", image: "assets/images/shoes.jpg"),
  SubCategory(name: "Clothes", image: "assets/images/clothes.jpg"),
  SubCategory(name: "Watch", image: "assets/images/watch.jpg"),
  SubCategory(name: "makeup", image: "assets/images/makeup.jpg"),
];

List<String> filterCategory = [
  "Filter",
  "Ratings",
  "Size",
  "Color",
  "Price",
  "Brand",
];
