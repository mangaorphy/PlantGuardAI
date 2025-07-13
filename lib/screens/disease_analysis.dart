import 'package:flutter/material.dart';

class DiseaseAnalysisScreen extends StatelessWidget {
  final String plantName;
  final String diseaseName;
  final double confidenceScore;
  final List<String> symptoms;
  final String diseaseDescription;

  const DiseaseAnalysisScreen({
    super.key,
    required this.plantName,
    required this.diseaseName,
    required this.confidenceScore,
    required this.symptoms,
    required this.diseaseDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disease Analysis', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.black87,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text(
              'Overview and Analysis',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Plant Name:', plantName),
            _buildInfoRow('Disease Name:', diseaseName),
            _buildInfoRow(
              'Confidence score:',
              '${confidenceScore.toStringAsFixed(1)}%',
              isConfidence: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'Symptoms Identified:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            ...symptoms.map((symptom) => Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 4),
              child: Text('• $symptom', style: const TextStyle(color: Colors.white70)),
            )).toList(),
            const Divider(height: 32, thickness: 1, color: Colors.grey),
            const Text(
              'Short Disease Description:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(diseaseDescription, style: const TextStyle(color: Colors.white70)),
            const Divider(height: 32, thickness: 1, color: Colors.grey),
            const Text(
              'Treatment:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to treatment screen
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Click here for suggested treatment',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // Show more info
              },
              child: const Text('More Info', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isConfidence = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: isConfidence
                  ? TextStyle(
                      color: _getConfidenceColor(confidenceScore),
                      fontWeight: FontWeight.bold,
                    )
                  : const TextStyle(color: Colors.white70),
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