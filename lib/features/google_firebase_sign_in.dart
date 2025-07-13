/*import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleSignInPage extends StatefulWidget {
  const GoogleSignInPage({super.key});

  @override
  State<GoogleSignInPage> createState() => _GoogleSignInPageState();
}

class _GoogleSignInPageState extends State<GoogleSignInPage> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/fitness.activity.read',
      'https://www.googleapis.com/auth/fitness.heart_rate.read',
      'https://www.googleapis.com/auth/fitness.body.read',
    ],
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleSignInAccount? _currentUser;
  User? _firebaseUser;
  String? _accessToken;
  String _status = 'Not signed in';

  Future<void> _handleSignIn() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _status = 'Sign in aborted');
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      setState(() {
        _currentUser = googleUser;
        _firebaseUser = userCredential.user;
        _accessToken = googleAuth.accessToken;
        _status = 'Signed in as ${googleUser.displayName}';
      });
    } catch (e) {
      setState(() => _status = 'Sign-in failed: $e');
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    setState(() {
      _currentUser = null;
      _firebaseUser = null;
      _accessToken = null;
      _status = 'Signed out';
    });
  }

  Future<Map<String, dynamic>> _fetchFitData() async {
    if (_accessToken == null) return {};

    final now = DateTime.now().millisecondsSinceEpoch;
    final oneDayAgo = now - 86400000;

    final response = await http.post(
      Uri.parse('https://www.googleapis.com/fitness/v1/users/me/dataset:aggregate'),
      headers: {
        'Authorization': 'Bearer $_accessToken',
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

  Widget _buildFitDataSection() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchFitData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Text('Error loading Fit data: ${snapshot.error}');
        }

        final buckets = snapshot.data?['bucket'] ?? [];

        int steps = 0;
        double heartRate = 0.0;
        int heartSamples = 0;
        double? weight;
        double? height;

        for (final bucket in buckets) {
          for (final dataset in bucket['dataset']) {
            final source = dataset['dataSourceId'] ?? '';
            for (final point in dataset['point']) {
              final value = point['value'][0];
              if (source.contains('step_count')) {
                steps += (value['intVal'] as int?) ?? 0;
              } else if (source.contains('heart_rate')) {
                heartRate += (value['fpVal'] as double?) ?? 0;
                heartSamples++;
              } else if (source.contains('weight')) {
                weight = (value['fpVal'] as double?);
              } else if (source.contains('height')) {
                height = (value['fpVal'] as double?);
              }
            }
          }
        }

        final avgHeartRate = heartSamples > 0 ? (heartRate / heartSamples).toStringAsFixed(1) : 'N/A';
        final weightDisplay = weight != null ? '${weight.toStringAsFixed(1)} kg' : 'N/A';
        final heightDisplay = height != null ? '${(height! * 100).toStringAsFixed(1)} cm' : 'N/A';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const Text('Google Fit Summary', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Steps (last 24h): $steps'),
            Text('Avg Heart Rate: $avgHeartRate bpm'),
            Text('Weight: $weightDisplay'),
            Text('Height: $heightDisplay'),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _firebaseUser?.displayName ?? 'None';
    final email = _firebaseUser?.email ?? 'No email';

    return Scaffold(
      appBar: AppBar(title: const Text('Google Sign-In & Fit')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_status, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _handleSignIn, child: const Text('Sign In')),
            ElevatedButton(onPressed: _handleSignOut, child: const Text('Sign Out')),
            const SizedBox(height: 20),
            const Divider(),
            Text('User: $displayName'),
            Text('Email: $email'),
            if (_accessToken != null) _buildFitDataSection(),
          ],
        ),
      ),
    );
  }
}
*/