import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/providers/service_providers.dart';
import '../../../core/services/aura_ai_service.dart';

/// Test screen for AI integration
/// Allows testing of both image processing and recommendation APIs
class AiIntegrationTestScreen extends ConsumerStatefulWidget {
  const AiIntegrationTestScreen({super.key});

  @override
  ConsumerState<AiIntegrationTestScreen> createState() => _AiIntegrationTestScreenState();
}

class _AiIntegrationTestScreenState extends ConsumerState<AiIntegrationTestScreen> {
  final TextEditingController _queryController = TextEditingController();
  XFile? _selectedImage;
  Uint8List? _imageBytes;
  ClothingAnalysisResult? _analysisResult;
  StyleRecommendationResult? _recommendationResult;
  bool _isProcessingImage = false;
  bool _isGettingRecommendation = false;
  String? _error;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImage = pickedFile;
          _imageBytes = bytes;
          _analysisResult = null;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick image: $e';
      });
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessingImage = true;
      _error = null;
    });

    try {
      final aiService = ref.read(auraAiServiceProvider);
      
      // Web uyumlu XFile kullan
      final result = await aiService.processImageFromXFile(_selectedImage!);
      
      result.fold(
        (failure) {
          setState(() {
            _error = 'Image processing failed: ${failure.message}';
            _isProcessingImage = false;
          });
        },
        (analysisResult) {
          setState(() {
            _analysisResult = analysisResult;
            _isProcessingImage = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Unexpected error: $e';
        _isProcessingImage = false;
      });
    }
  }

  Future<void> _getRecommendation() async {
    if (_queryController.text.trim().isEmpty) return;

    setState(() {
      _isGettingRecommendation = true;
      _error = null;
    });

    try {
      final aiService = ref.read(auraAiServiceProvider);
      final result = await aiService.getRecommendation(
        userId: 'test_user',
        query: _queryController.text.trim(),
        context: {
          'test_mode': true,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      result.fold(
        (failure) {
          setState(() {
            _error = 'Recommendation failed: ${failure.message}';
            _isGettingRecommendation = false;
          });
        },
        (recommendationResult) {
          setState(() {
            _recommendationResult = recommendationResult;
            _isGettingRecommendation = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Unexpected error: $e';
        _isGettingRecommendation = false;
      });
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _error = null;
    });

    try {
      final aiService = ref.read(auraAiServiceProvider);
      final result = await aiService.testConnection();
      
      result.fold(
        (failure) {
          setState(() {
            _error = 'Connection failed: ${failure.message}';
          });
        },
        (isConnected) {
          setState(() {
            _error = isConnected 
                ? 'Connection successful!' 
                : 'Connection failed - service unavailable';
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Connection test error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Integration Test'),
        actions: [
          IconButton(
            onPressed: _testConnection,
            icon: const Icon(Icons.wifi),
            tooltip: 'Test Connection',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error Display
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: _error!.contains('successful') 
                      ? Colors.green.withOpacity(0.1) 
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _error!.contains('successful') 
                        ? Colors.green 
                        : Colors.red,
                  ),
                ),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: _error!.contains('successful') 
                        ? Colors.green.shade700 
                        : Colors.red.shade700,
                  ),
                ),
              ),

            // Image Processing Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Image Processing Test',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    
                    // Image Selection
                    if (_selectedImage != null && _imageBytes != null)
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: MemoryImage(_imageBytes!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey.shade200,
                        ),
                        child: const Center(
                          child: Text('No image selected'),
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _pickImage,
                            child: const Text('Pick Image'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _selectedImage != null && !_isProcessingImage
                                ? _processImage
                                : null,
                            child: _isProcessingImage
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Process Image'),
                          ),
                        ),
                      ],
                    ),
                    
                    // Analysis Results
                    if (_analysisResult != null) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Analysis Results',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Success: ${_analysisResult!.success}'),
                      Text('Message: ${_analysisResult!.message}'),
                      Text('Category: ${_analysisResult!.category}'),
                      Text('Color: ${_analysisResult!.color}'),
                      Text('Pattern: ${_analysisResult!.pattern}'),
                      Text('Style: ${_analysisResult!.style}'),
                      Text('Season: ${_analysisResult!.season}'),
                      Text('Material: ${_analysisResult!.material}'),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Recommendation Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Style Recommendation Test',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    
                    TextField(
                      controller: _queryController,
                      decoration: const InputDecoration(
                        labelText: 'Style Query',
                        hintText: 'e.g., "What should I wear to a casual dinner?"',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: !_isGettingRecommendation ? _getRecommendation : null,
                        child: _isGettingRecommendation
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Get Recommendation'),
                      ),
                    ),
                    
                    // Recommendation Results
                    if (_recommendationResult != null) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        'Recommendation Results',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text('Recommendation: ${_recommendationResult!.recommendation}'),
                      if (_recommendationResult!.tips.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Tips: ${_recommendationResult!.tips.join(', ')}'),
                      ],
                      if (_recommendationResult!.outfits.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Outfit Suggestions: ${_recommendationResult!.outfits.length}'),
                        for (final outfit in _recommendationResult!.outfits) ...[
                          Text('- ${outfit.description} (${outfit.occasion})'),
                        ],
                      ],
                      Text('Confidence: ${(_recommendationResult!.confidence * 100).toStringAsFixed(1)}%'),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
