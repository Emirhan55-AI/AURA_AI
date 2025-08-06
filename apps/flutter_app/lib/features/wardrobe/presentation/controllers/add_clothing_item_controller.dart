import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/providers/service_providers.dart';
import '../../../../core/services/aura_ai_service.dart';
import '../../domain/entities/clothing_item.dart';
import '../../domain/repositories/i_user_wardrobe_repository.dart';
import '../../data/providers/wardrobe_providers.dart';

/// State class for Add Clothing Item functionality
class AddClothingItemState {
  final XFile? pickedImage;
  final bool isImageLoading;
  final String? imageError;
  final String itemName;
  final String itemDescription;
  final String? selectedCategory;
  final String? selectedColor;
  final Set<String> selectedSeasons;
  final Set<String> customTags;
  final String? itemNameError;
  final String? itemDescriptionError;
  final String? categoryError;
  final String? colorError;
  final bool isAiTaggingLoading;
  final bool hasAiTaggingError;
  final bool isSaving;
  final String? saveError;
  final bool saveSuccess;

  const AddClothingItemState({
    this.pickedImage,
    this.isImageLoading = false,
    this.imageError,
    this.itemName = '',
    this.itemDescription = '',
    this.selectedCategory,
    this.selectedColor,
    this.selectedSeasons = const <String>{},
    this.customTags = const <String>{},
    this.itemNameError,
    this.itemDescriptionError,
    this.categoryError,
    this.colorError,
    this.isAiTaggingLoading = false,
    this.hasAiTaggingError = false,
    this.isSaving = false,
    this.saveError,
    this.saveSuccess = false,
  });

  AddClothingItemState copyWith({
    XFile? pickedImage,
    bool? isImageLoading,
    String? imageError,
    String? itemName,
    String? itemDescription,
    String? selectedCategory,
    String? selectedColor,
    Set<String>? selectedSeasons,
    Set<String>? customTags,
    String? itemNameError,
    String? itemDescriptionError,
    String? categoryError,
    String? colorError,
    bool? isAiTaggingLoading,
    bool? hasAiTaggingError,
    bool? isSaving,
    String? saveError,
    bool? saveSuccess,
  }) {
    return AddClothingItemState(
      pickedImage: pickedImage ?? this.pickedImage,
      isImageLoading: isImageLoading ?? this.isImageLoading,
      imageError: imageError ?? this.imageError,
      itemName: itemName ?? this.itemName,
      itemDescription: itemDescription ?? this.itemDescription,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSeasons: selectedSeasons ?? this.selectedSeasons,
      customTags: customTags ?? this.customTags,
      itemNameError: itemNameError ?? this.itemNameError,
      itemDescriptionError: itemDescriptionError ?? this.itemDescriptionError,
      categoryError: categoryError ?? this.categoryError,
      colorError: colorError ?? this.colorError,
      isAiTaggingLoading: isAiTaggingLoading ?? this.isAiTaggingLoading,
      hasAiTaggingError: hasAiTaggingError ?? this.hasAiTaggingError,
      isSaving: isSaving ?? this.isSaving,
      saveError: saveError ?? this.saveError,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }
}

class AddClothingItemController extends StateNotifier<AddClothingItemState> {
  final Ref ref;
  final ImagePicker _picker = ImagePicker();

  AddClothingItemController(this.ref) : super(const AddClothingItemState());

  /// Gets the current repository instance
  IUserWardrobeRepository get _repository => ref.read(userWardrobeRepositoryProvider);
  
  /// Gets the AI service instance
  AuraAiService get _aiService => ref.read(auraAiServiceProvider);

  /// Computed property to check if form is valid
  bool get isFormValid {
    return state.itemName.trim().isNotEmpty &&
           state.selectedCategory != null &&
           state.selectedColor != null &&
           state.pickedImage != null;
  }

  /// Pick an image from the specified source
  Future<void> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      state = state.copyWith(
        isImageLoading: true,
        imageError: null,
      );

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        state = state.copyWith(
          pickedImage: pickedFile,
          isImageLoading: false,
        );
      } else {
        state = state.copyWith(
          isImageLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isImageLoading: false,
        imageError: 'Failed to pick image: ${e.toString()}',
      );
    }
  }

  /// Crop the selected image
  Future<void> cropImage() async {
    if (state.pickedImage == null) return;

    try {
      state = state.copyWith(
        isImageLoading: true,
        imageError: null,
      );

      // Temporarily skip cropping functionality
      // TODO: Re-enable when image_cropper package is available
      /*
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: state.pickedImage!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            lockAspectRatio: false,
            hideBottomControls: false,
            initAspectRatio: CropAspectRatioPreset.original,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            aspectRatioLockEnabled: false,
            resetAspectRatioEnabled: true,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
          ),
        ],
      );
      */

      // For now, use the original picked image without cropping
      final croppedXFile = state.pickedImage;
      
      if (croppedXFile != null) {
        state = state.copyWith(
          pickedImage: croppedXFile,
          isImageLoading: false,
        );
      } else {
        state = state.copyWith(
          isImageLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isImageLoading: false,
        imageError: 'Failed to process image: ${e.toString()}',
      );
    }
  }

  /// Update item name
  void updateItemName(String name) {
    state = state.copyWith(
      itemName: name,
      itemNameError: name.trim().isEmpty ? 'Item name is required' : null,
    );
  }

  /// Update item description
  void updateItemDescription(String description) {
    state = state.copyWith(
      itemDescription: description,
      itemDescriptionError: null,
    );
  }

  /// Update selected category
  void updateCategory(String? category) {
    state = state.copyWith(
      selectedCategory: category,
      categoryError: category == null ? 'Please select a category' : null,
    );
  }

  /// Update selected color
  void updateColor(String? color) {
    state = state.copyWith(
      selectedColor: color,
      colorError: color == null ? 'Please select a color' : null,
    );
  }

  /// Toggle season selection
  void toggleSeason(String season) {
    final currentSeasons = Set<String>.from(state.selectedSeasons);
    if (currentSeasons.contains(season)) {
      currentSeasons.remove(season);
    } else {
      currentSeasons.add(season);
    }
    state = state.copyWith(selectedSeasons: currentSeasons);
  }

  /// Add custom tag
  void addCustomTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !state.customTags.contains(trimmedTag)) {
      final currentTags = Set<String>.from(state.customTags);
      currentTags.add(trimmedTag);
      state = state.copyWith(customTags: currentTags);
    }
  }

  /// Remove custom tag
  void removeCustomTag(String tag) {
    final currentTags = Set<String>.from(state.customTags);
    currentTags.remove(tag);
    state = state.copyWith(customTags: currentTags);
  }

  /// Perform AI analysis on the selected image
  Future<void> performAiTagging() async {
    if (state.pickedImage == null) return;

    try {
      state = state.copyWith(
        isAiTaggingLoading: true,
        hasAiTaggingError: false,
      );

      // Convert XFile to File for AI service
      final File imageFile = File(state.pickedImage!.path);
      
      // Call the real AI service
      final result = await _aiService.processImage(imageFile);
      
      result.fold(
        (failure) {
          // Handle AI service failure
          state = state.copyWith(
            isAiTaggingLoading: false,
            hasAiTaggingError: true,
          );
        },
        (analysisResult) {
          // Apply AI analysis results to the form
          final currentTags = Set<String>.from(state.customTags);
          final currentSeasons = Set<String>.from(state.selectedSeasons);
          
          // Add detected style and pattern as tags
          if (analysisResult.style.isNotEmpty && analysisResult.style != 'unknown') {
            currentTags.add(analysisResult.style);
          }
          
          if (analysisResult.pattern.isNotEmpty && analysisResult.pattern != 'unknown') {
            currentTags.add(analysisResult.pattern);
          }
          
          // Add material as tag if detected
          if (analysisResult.material.isNotEmpty && analysisResult.material != 'unknown') {
            currentTags.add(analysisResult.material);
          }
          
          // Add season if detected
          if (analysisResult.season.isNotEmpty) {
            currentSeasons.add(_capitalizeFirst(analysisResult.season));
          }
          
          // Map AI category to our app categories
          String? mappedCategory = _mapAiCategoryToAppCategory(analysisResult.category);
          
          // Use the detected color or keep existing
          String? detectedColor;
          if (analysisResult.color.isNotEmpty && analysisResult.color != 'unknown') {
            detectedColor = _capitalizeFirst(analysisResult.color);
          }

          state = state.copyWith(
            customTags: currentTags,
            selectedCategory: mappedCategory ?? state.selectedCategory,
            selectedColor: detectedColor ?? state.selectedColor,
            selectedSeasons: currentSeasons,
            isAiTaggingLoading: false,
            categoryError: mappedCategory != null ? null : state.categoryError,
            colorError: detectedColor != null ? null : state.colorError,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isAiTaggingLoading: false,
        hasAiTaggingError: true,
      );
    }
  }

  /// Map AI detected category to app categories
  String? _mapAiCategoryToAppCategory(String aiCategory) {
    final categoryMap = {
      'shirt': 'Tops',
      'blouse': 'Tops',
      'sweater': 'Tops',
      'hoodie': 'Tops',
      'jacket': 'Outerwear',
      'coat': 'Outerwear',
      'pants': 'Bottoms',
      'jeans': 'Bottoms',
      'shorts': 'Bottoms',
      'skirt': 'Bottoms',
      'dress': 'Dresses',
      'shoes': 'Shoes',
      'sneakers': 'Shoes',
      'boots': 'Shoes',
      'sandals': 'Shoes',
      'bag': 'Accessories',
      'hat': 'Accessories',
      'scarf': 'Accessories',
      'belt': 'Accessories',
      'jewelry': 'Accessories',
    };
    
    final normalizedCategory = aiCategory.toLowerCase();
    return categoryMap[normalizedCategory];
  }

  /// Capitalize first letter of a string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// Reset AI tagging error state
  void resetAiTaggingError() {
    state = state.copyWith(hasAiTaggingError: false);
  }

  /// Save the clothing item
  Future<void> saveItem() async {
    if (!isFormValid) {
      _updateValidationErrors();
      return;
    }

    try {
      state = state.copyWith(
        isSaving: true,
        saveError: null,
        saveSuccess: false,
      );

      // In a real implementation, you would upload the image and create the item
      // For now, we'll simulate the save operation
      await Future<void>.delayed(const Duration(seconds: 2));

      // Mock successful save
      state = state.copyWith(
        isSaving: false,
        saveSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        saveError: 'Failed to save item: ${e.toString()}',
      );
    }
  }

  /// Update validation errors for all fields
  void _updateValidationErrors() {
    state = state.copyWith(
      itemNameError: state.itemName.trim().isEmpty ? 'Item name is required' : null,
      categoryError: state.selectedCategory == null ? 'Please select a category' : null,
      colorError: state.selectedColor == null ? 'Please select a color' : null,
    );
  }

  /// Reset the form to initial state
  void resetForm() {
    state = const AddClothingItemState();
  }
}
