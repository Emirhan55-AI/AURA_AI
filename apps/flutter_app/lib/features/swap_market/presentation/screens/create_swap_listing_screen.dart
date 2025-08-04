import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/ui/system_state_widget.dart';
import '../../domain/entities/swap_listing.dart';
import '../providers/swap_market_providers.dart';
import '../widgets/linked_clothing_item_preview.dart';

/// Screen for creating a new swap listing
class CreateSwapListingScreen extends ConsumerStatefulWidget {
  final String clothingItemId;

  const CreateSwapListingScreen({
    super.key,
    required this.clothingItemId,
  });

  @override
  ConsumerState<CreateSwapListingScreen> createState() =>
      _CreateSwapListingScreenState();
}

class _CreateSwapListingScreenState
    extends ConsumerState<CreateSwapListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _swapWantedController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _descriptionController.dispose();
    _priceController.dispose();
    _swapWantedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createSwapListingNotifierProvider);
    final createNotifier = ref.read(createSwapListingNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Listing'),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (createState.isPublishing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _canPublish(createState)
                  ? () => _publishListing(createNotifier)
                  : null,
              child: const Text('Publish'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linked clothing item preview
              LinkedClothingItemPreview(
                clothingItemId: widget.clothingItemId,
              ),

              const SizedBox(height: 24),

              if (createState.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          createState.error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Description field
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description *',
                  hintText: 'Describe your item, its condition, and why you\'re selling/swapping...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                maxLength: 500,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide a description';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
                onChanged: (value) => createNotifier.updateDescription(value),
              ),

              const SizedBox(height: 24),

              // Listing type
              Text(
                'Listing Type *',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              SegmentedButton<SwapListingType>(
                segments: const [
                  ButtonSegment(
                    value: SwapListingType.sale,
                    label: Text('For Sale'),
                    icon: Icon(Icons.sell),
                  ),
                  ButtonSegment(
                    value: SwapListingType.swap,
                    label: Text('For Swap'),
                    icon: Icon(Icons.swap_horiz),
                  ),
                ],
                selected: {createState.type},
                onSelectionChanged: (Set<SwapListingType> selection) {
                  createNotifier.updateType(selection.first);
                },
              ),

              const SizedBox(height: 24),

              // Price or swap wanted field
              if (createState.type == SwapListingType.sale) ...[
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (USD) *',
                    hintText: '0.00',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a price';
                    }
                    final price = double.tryParse(value.trim());
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    final price = double.tryParse(value.trim());
                    createNotifier.updatePrice(price);
                  },
                ),
              ] else ...[
                TextFormField(
                  controller: _swapWantedController,
                  decoration: const InputDecoration(
                    labelText: 'What do you want in exchange? *',
                    hintText: 'e.g., Blue jeans size M, Vintage dress, etc.',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  maxLength: 200,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please specify what you want in exchange';
                    }
                    return null;
                  },
                  onChanged: (value) => createNotifier.updateSwapWantedFor(value),
                ),
              ],

              const SizedBox(height: 24),

              // Additional images section
              Text(
                'Additional Images',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Add more photos to showcase your item (optional)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              // Image picker and preview
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  // Add image button
                  if (createState.additionalImages.length < 5)
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add Photo',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Preview existing images
                  ...createState.additionalImages.asMap().entries.map((entry) {
                    final index = entry.key;
                    final image = entry.value;
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            image,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => createNotifier.removeImage(index),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),

              const SizedBox(height: 32),

              // Publish button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: createState.isPublishing || !_canPublish(createState)
                      ? null
                      : () => _publishListing(createNotifier),
                  child: createState.isPublishing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Publishing...'),
                          ],
                        )
                      : const Text('Publish Listing'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  bool _canPublish(CreateSwapListingState state) {
    if (state.description.trim().length < 10) return false;
    
    if (state.type == SwapListingType.sale) {
      return state.price != null && state.price! > 0;
    } else {
      return state.swapWantedFor.trim().isNotEmpty;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final createNotifier = ref.read(createSwapListingNotifierProvider.notifier);
        createNotifier.addImage(File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _publishListing(CreateSwapListingNotifier notifier) async {
    if (!_formKey.currentState!.validate()) return;

    final listingId = await notifier.publishListing(widget.clothingItemId);
    
    if (listingId != null && mounted) {
      // Success - navigate to the created listing
      context.go('/swap-market/listing/$listingId');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Listing published successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
