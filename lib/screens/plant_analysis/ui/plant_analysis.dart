import 'package:flutter/material.dart';
import '/base_scaffold.dart';
import '/screens/home_page.dart';
import '/product_listing_page_optimized.dart';

class PlantAnalysis extends StatelessWidget {
  final String plantName;
  final String diseaseName;
  final double confidenceScore;
  final List<String> symptoms;
  final String diseaseDescription;
  final String imageFile;

  const PlantAnalysis({
    super.key,
    required this.plantName,
    required this.diseaseName,
    required this.confidenceScore,
    required this.symptoms,
    required this.diseaseDescription,
    required this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    print('Displaying: $plantName, $diseaseName, $confidenceScore, $imageFile');

    return BaseScaffold(
      title: 'Plant Analysis',
      currentIndex: 0,
      onTabChange: (index) {
        // Handle navigation
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      },
      body: Stack(
        children: [
          Image.network(
            imageFile,
            width: double.infinity,
            height: 300,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.broken_image, size: 60, color: Colors.white),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 250),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overview and\nAnalysis',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildInfoRow('Plant Name:', plantName),
                  _buildInfoRow('Disease Name:', diseaseName),
                  _buildInfoRow(
                    'Confidence score:',
                    '${confidenceScore.toStringAsFixed(1)}%',
                    isConfidence: true,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Symptoms Identified:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...symptoms.map(
                    (symptom) => Padding(
                      padding: const EdgeInsets.only(left: 12.0, bottom: 4),
                      child: Text(
                        '• $symptom',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Short Disease Description:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    diseaseDescription,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Treatment:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      // Navigate to product listing to let user search for treatment products
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductListingPage(),
                        ),
                      );
                    },
                    child: const Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Click here',
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(
                            text: ' for suggested treatment',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isConfidence = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isConfidence ? FontWeight.bold : FontWeight.normal,
                color: isConfidence
                    ? _getConfidenceColor(
                        double.parse(value.replaceAll('%', '').trim()),
                      )
                    : Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.orange;
    return Colors.red;
  }
}
