import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GoogleFitInfo extends StatelessWidget {
  final String accessToken;

  const GoogleFitInfo({required this.accessToken, super.key});

  Future<Map<String, dynamic>> _fetchFitData() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final oneDayAgo = now - 86400000;

    final response = await http.post(
      Uri.parse('https://www.googleapis.com/fitness/v1/users/me/dataset:aggregate'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "aggregateBy": [
          { "dataTypeName": "com.google.step_count.delta" },
          { "dataTypeName": "com.google.heart_rate.bpm" },
          { "dataTypeName": "com.google.weight" },
          { "dataTypeName": "com.google.height" }
        ],
        "bucketByTime": { "durationMillis": 86400000 },
        "startTimeMillis": oneDayAgo,
        "endTimeMillis": now
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Google Fit API error: ${response.body}');
    }

    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchFitData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final buckets = snapshot.data?['bucket'] ?? [];

        int steps = 0;
        double heartRateTotal = 0.0;
        int heartSamples = 0;
        double? weight;
        double? height;

        for (final bucket in buckets) {
          for (final dataset in bucket['dataset']) {
            final source = dataset['dataSourceId'] ?? '';
            for (final point in dataset['point']) {
              final value = point['value'][0];
              final dynamic val = value['fpVal'] ?? value['intVal'];

              if (source.contains('step_count')) {
                steps += (val is int) ? val : (val as double?)?.toInt() ?? 0;
              } else if (source.contains('heart_rate')) {
                if (val != null) {
                  heartRateTotal += (val is int) ? val.toDouble() : val as double;
                  heartSamples++;
                }
              } else if (source.contains('weight')) {
                if (val != null) {
                  weight = (val is int) ? val.toDouble() : val as double;
                }
              } else if (source.contains('height')) {
                if (val != null) {
                  height = (val is int) ? val.toDouble() : val as double;
                }
              }
            }
          }
        }

        final avgHeartRate = heartSamples > 0 ? (heartRateTotal / heartSamples).toStringAsFixed(1) : 'N/A';
        final weightDisplay = weight != null ? '${weight.toStringAsFixed(1)} kg' : 'N/A';
        final heightDisplay = height != null ? '${(height * 100).toStringAsFixed(1)} cm' : 'N/A';

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.fitness_center, size: 48, color: Colors.green),
                  const SizedBox(height: 12),
                  const Text(
                    'Your Fitness Summary',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildMetric('🚶 Steps (24h)', '$steps'),
                  _buildMetric('❤️ Avg Heart Rate', '$avgHeartRate bpm'),
                  _buildMetric('⚖️ Weight', weightDisplay),
                  _buildMetric('📏 Height', heightDisplay),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
