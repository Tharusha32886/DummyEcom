// ignore_for_file: non_constant_identifier_names
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecom/view/role_based_login/admin/models/add_items_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

final addItemProvider = StateNotifierProvider<AddItemNotifier, AddItemState>((
  ref,
) {
  return AddItemNotifier();
});

class AddItemNotifier extends StateNotifier<AddItemState> {
  AddItemNotifier() : super(AddItemState()) {
    fetchCategory();
  }
  // for storing all items
  final CollectionReference items = FirebaseFirestore.instance.collection(
    'items',
  );
  // for category
  final CollectionReference categoriesCollection = FirebaseFirestore.instance
      .collection('Category');
  //for image picker
  void pickImage() async {
    try {
      final PickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (PickedFile != null) {
        state = state.copyWith(imagePath: PickedFile.path);
      }
    } catch (e) {
      // handle error
      throw Exception('Error saving items:$e ');
    }
  }

  // to select the categoryItems
  void setSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  // for size
  void addSize(String size) {
    state = state.copyWith(sizes: [...state.sizes, size]);
  }

  void removeSize(String size) {
    state = state.copyWith(sizes: state.sizes.where((s) => s != size).toList());
  }

  // for color
  void addColor(String color) {
    state = state.copyWith(colors: [...state.colors, color]);
  }

  void removeColor(String color) {
    state = state.copyWith(
      colors: state.colors.where((c) => c != color).toList(),
    );
  }

  // for discount
  void toggleDiscount(bool? isDiscounted) {
    state = state.copyWith(isDiscounted: isDiscounted);
  }

  // for discount percentage
  void setDiscountPercentage(String percentage) {
    state = state.copyWith(discountPercentage: percentage);
  }

  // to handle loading indicator
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading);
  }

  // to fetch the category items
  Future<void> fetchCategory() async {
    try {
      QuerySnapshot snapshot = await categoriesCollection.get();
      List<String> categories =
          snapshot.docs.map((doc) => doc['name'] as String).toList();
      state = state.copyWith(categories: categories);
    } catch (e) {
      throw Exception('Error saving items:$e ');
    }
  }

  // to upload and save the items
  Future<void> uploadAndSaveItem(String name, String price) async {
    if (name.isEmpty ||
        price.isEmpty ||
        state.imagePath == null ||
        state.selectedCategory == null ||
        state.sizes.isEmpty ||
        state.colors.isEmpty ||
        (state.isDiscounted && state.discountPercentage == null)) {
      throw Exception('Pleae fill all the fields');
    }
    state = state.copyWith(isLoading: true);
    try {
      // upload image to firebase storage
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final reference = FirebaseStorage.instance.ref().child('image/$fileName');
      await reference.putFile(File(state.imagePath!));
      final imageUrl = await reference.getDownloadURL();
      //save item to firestore
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      await items.add({
        'name': name,
        'price': int.tryParse(price),
        'image': imageUrl,
        'uploadedBy': uid,
        'category': state.selectedCategory,
        'size': state.sizes,
        'fcolor': state.colors,
        'isDiscounted': state.isDiscounted,
        'discountPercentage':
            state.isDiscounted ? int.tryParse(state.discountPercentage!) : 0,
      });
      // Reset state after susccessfully upload
      state = AddItemState();
    } catch (e) {
      throw Exception('Error saving Items:$e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}
