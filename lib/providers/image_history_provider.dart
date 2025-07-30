import 'package:flutter/foundation.dart';
import 'dart:io';

class ImageHistoryItem {
  final String id;
  final File? imageFile;
  final String? imagePath;
  final DateTime capturedAt;
  final String status; // 'Healthy', 'Disease Detected', 'Processing'
  final String? disease;
  final double? confidence;
  final String? location;
  final String? notes;
  final Map<String, dynamic>? analysisResults;

  ImageHistoryItem({
    required this.id,
    this.imageFile,
    this.imagePath,
    required this.capturedAt,
    required this.status,
    this.disease,
    this.confidence,
    this.location,
    this.notes,
    this.analysisResults,
  });

  ImageHistoryItem copyWith({
    String? id,
    File? imageFile,
    String? imagePath,
    DateTime? capturedAt,
    String? status,
    String? disease,
    double? confidence,
    String? location,
    String? notes,
    Map<String, dynamic>? analysisResults,
  }) {
    return ImageHistoryItem(
      id: id ?? this.id,
      imageFile: imageFile ?? this.imageFile,
      imagePath: imagePath ?? this.imagePath,
      capturedAt: capturedAt ?? this.capturedAt,
      status: status ?? this.status,
      disease: disease ?? this.disease,
      confidence: confidence ?? this.confidence,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      analysisResults: analysisResults ?? this.analysisResults,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'capturedAt': capturedAt.toIso8601String(),
      'status': status,
      'disease': disease,
      'confidence': confidence,
      'location': location,
      'notes': notes,
      'analysisResults': analysisResults,
    };
  }

  static ImageHistoryItem fromJson(Map<String, dynamic> json) {
    return ImageHistoryItem(
      id: json['id'],
      imagePath: json['imagePath'],
      capturedAt: DateTime.parse(json['capturedAt']),
      status: json['status'],
      disease: json['disease'],
      confidence: json['confidence']?.toDouble(),
      location: json['location'],
      notes: json['notes'],
      analysisResults: json['analysisResults'],
    );
  }
}

class ImageHistoryProvider with ChangeNotifier {
  final List<ImageHistoryItem> _imageHistory = [];
  bool _isLoading = false;

  List<ImageHistoryItem> get imageHistory => List.unmodifiable(_imageHistory);
  bool get isLoading => _isLoading;

  // Get images by status
  List<ImageHistoryItem> getImagesByStatus(String status) {
    return _imageHistory.where((item) => item.status == status).toList();
  }

  // Get healthy images
  List<ImageHistoryItem> get healthyImages {
    return _imageHistory.where((item) => item.status == 'Healthy').toList();
  }

  // Get diseased images
  List<ImageHistoryItem> get diseasedImages {
    return _imageHistory
        .where((item) => item.status == 'Disease Detected')
        .toList();
  }

  // Get images being processed
  List<ImageHistoryItem> get processingImages {
    return _imageHistory.where((item) => item.status == 'Processing').toList();
  }

  // Add new image for analysis
  Future<String> addImageForAnalysis({
    required File imageFile,
    String? location,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final imageId = 'IMG_${DateTime.now().millisecondsSinceEpoch}';

      // Create directory if it doesn't exist
      final directory = Directory('${imageFile.parent.path}/plant_analysis');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Copy image to permanent storage
      final permanentPath = '${directory.path}/$imageId.jpg';
      final permanentFile = await imageFile.copy(permanentPath);

      final historyItem = ImageHistoryItem(
        id: imageId,
        imageFile: permanentFile,
        imagePath: permanentPath,
        capturedAt: DateTime.now(),
        status: 'Processing', // Initially processing
        location: location,
        notes: notes,
      );

      _imageHistory.insert(
        0,
        historyItem,
      ); // Add to beginning (most recent first)
      _isLoading = false;
      notifyListeners();

      // Simulate AI analysis (replace with actual AI service call)
      _simulateAnalysis(imageId);

      return imageId;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update analysis results
  Future<void> updateAnalysisResults({
    required String imageId,
    required String status,
    String? disease,
    double? confidence,
    Map<String, dynamic>? analysisResults,
  }) async {
    try {
      final index = _imageHistory.indexWhere((item) => item.id == imageId);
      if (index >= 0) {
        _imageHistory[index] = _imageHistory[index].copyWith(
          status: status,
          disease: disease,
          confidence: confidence,
          analysisResults: analysisResults,
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error updating analysis results: $e');
    }
  }

  // Simulate AI analysis (replace with actual AI service)
  Future<void> _simulateAnalysis(String imageId) async {
    await Future.delayed(
      const Duration(seconds: 3),
    ); // Simulate processing time

    // Mock analysis results
    final random = DateTime.now().millisecond;
    final isHealthy = random % 3 == 0; // 33% chance of being healthy

    if (isHealthy) {
      await updateAnalysisResults(
        imageId: imageId,
        status: 'Healthy',
        confidence: 90.0 + (random % 10),
        analysisResults: {
          'detected_issues': [],
          'health_score': 90 + (random % 10),
          'recommendations': [
            'Plant appears healthy',
            'Continue current care routine',
            'Monitor for changes',
          ],
        },
      );
    } else {
      final diseases = [
        'Leaf Spot',
        'Powdery Mildew',
        'Blight',
        'Rust',
        'Aphid Infestation',
        'Spider Mites',
      ];
      final disease = diseases[random % diseases.length];

      await updateAnalysisResults(
        imageId: imageId,
        status: 'Disease Detected',
        disease: disease,
        confidence: 75.0 + (random % 20),
        analysisResults: {
          'detected_disease': disease,
          'severity': random % 3 == 0
              ? 'High'
              : (random % 2 == 0 ? 'Medium' : 'Low'),
          'affected_area': '${10 + (random % 30)}%',
          'recommendations': [
            'Apply appropriate fungicide',
            'Remove affected leaves',
            'Improve air circulation',
            'Reduce watering frequency',
          ],
          'suggested_products': [
            {
              'name': 'Organic Fungicide Spray',
              'type': 'pesticide',
              'effectiveness': '85%',
            },
            {
              'name': 'Plant Health Booster',
              'type': 'fertilizer',
              'effectiveness': '70%',
            },
          ],
        },
      );
    }
  }

  // Delete image from history
  Future<void> deleteImage(String imageId) async {
    try {
      final index = _imageHistory.indexWhere((item) => item.id == imageId);
      if (index >= 0) {
        final item = _imageHistory[index];

        // Delete the actual file
        if (item.imageFile != null && await item.imageFile!.exists()) {
          await item.imageFile!.delete();
        }

        _imageHistory.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting image: $e');
    }
  }

  // Clear all history
  Future<void> clearHistory() async {
    try {
      // Delete all image files
      for (final item in _imageHistory) {
        if (item.imageFile != null && await item.imageFile!.exists()) {
          await item.imageFile!.delete();
        }
      }

      _imageHistory.clear();
      notifyListeners();
    } catch (e) {
      print('Error clearing history: $e');
    }
  }

  // Get image by ID
  ImageHistoryItem? getImageById(String imageId) {
    try {
      return _imageHistory.firstWhere((item) => item.id == imageId);
    } catch (e) {
      return null;
    }
  }

  // Add notes to image
  Future<void> addNotes(String imageId, String notes) async {
    try {
      final index = _imageHistory.indexWhere((item) => item.id == imageId);
      if (index >= 0) {
        _imageHistory[index] = _imageHistory[index].copyWith(notes: notes);
        notifyListeners();
      }
    } catch (e) {
      print('Error adding notes: $e');
    }
  }

  // Get statistics
  Map<String, int> get statistics {
    return {
      'total': _imageHistory.length,
      'healthy': healthyImages.length,
      'diseased': diseasedImages.length,
      'processing': processingImages.length,
    };
  }
}
