// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:ecom/view/role_based_login/admin/controller/add_items_controller.dart';
import 'package:ecom/widgets/my_button.dart';
import 'package:ecom/widgets/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddItems extends ConsumerWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _discountpercentageController = TextEditingController();

  AddItems({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addItemProvider);
    final notifier = ref.read(addItemProvider.notifier);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 199, 228, 250),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 175, 216, 250),
        centerTitle: true,
        title: const Text("Add New Items"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: state.imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(state.imagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : state.isLoading
                          ? const CircularProgressIndicator()
                          : GestureDetector(
                              onTap: notifier.pickImage,
                              child: const Icon(Icons.camera_alt, size: 30),
                            ),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Item Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: "Item Price",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: state.selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Select Category",
                  border: OutlineInputBorder(),
                ),
                onChanged: notifier.setSelectedCategory,
                items: state.categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _sizeController,
                decoration: const InputDecoration(
                  labelText: "Item Size",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  notifier.addSize(value);
                  _sizeController.clear();
                },
              ),
              Wrap(
                spacing: 8,
                children: state.sizes.map((size) {
                  return Chip(
                    onDeleted: () => notifier.removeSize(size),
                    label: Text(size),
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: "Item Colour",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  notifier.addColor(value);
                  _colorController.clear();
                },
              ),
              Wrap(
                spacing: 8,
                children: state.colors.map((color) {
                  return Chip(
                    onDeleted: () => notifier.removeColor(color),
                    label: Text(color),
                  );
                }).toList(),
              ),
              Row(
                children: [
                  Checkbox(
                    value: state.isDiscounted,
                    onChanged: notifier.toggleDiscount,
                  ),
                  const Text("Apply Discount"),
                ],
              ),
              if (state.isDiscounted)
                Column(
                  children: [
                    TextField(
                      controller: _discountpercentageController,
                      decoration: const InputDecoration(
                        labelText: "Item Discount Percentage (%)",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        notifier.setDiscountPercentage(value);
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              const SizedBox(height: 10),
              state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: MyButton(
                        onTab: () async {
                          try {
                            await notifier.uploadAndSaveItem(
                              _nameController.text,
                              _priceController.text,
                            );
                            showSnackBar(context, "Item Added Successfully!");
                            Navigator.of(context).pop();
                          } catch (e) {
                            showSnackBar(context, "Error: $e");
                          }
                        },
                        buttonText: "Save Item",
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

