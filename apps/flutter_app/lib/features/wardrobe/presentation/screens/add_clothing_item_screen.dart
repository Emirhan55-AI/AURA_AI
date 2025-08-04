import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AddClothingItemScreen allows users to add new clothing items to their wardrobe
class AddClothingItemScreen extends ConsumerStatefulWidget {
  const AddClothingItemScreen({super.key});

  @override
  ConsumerState<AddClothingItemScreen> createState() => _AddClothingItemScreenState();
}

class _AddClothingItemScreenState extends ConsumerState<AddClothingItemScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Clothing Item'),
      ),
      body: const Center(
        child: Text(
          'Add Clothing Item Screen\n(Implementation pending)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
