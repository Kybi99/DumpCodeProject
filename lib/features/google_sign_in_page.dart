import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'google_fit_info.dart';

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

  GoogleSignInAccount? _currentUser;
  String? _accessToken;
  String _status = 'Not signed in';

  Future<void> _handleSignIn() async {
    try {
      final user = await _googleSignIn.signIn();
      if (user == null) {
        setState(() => _status = 'Sign in aborted');
        return;
      }

      final auth = await user.authentication;

      setState(() {
        _currentUser = user;
        _accessToken = auth.accessToken;
        _status = 'Signed in as ${user.displayName}';
      });
    } catch (e) {
      setState(() => _status = 'Sign-in failed: $e');
    }
  }

  Future<void> _handleSignOut() async {
    await _googleSignIn.signOut();
    setState(() {
      _currentUser = null;
      _accessToken = null;
      _status = 'Signed out';
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _currentUser?.displayName ?? 'None';
    final email = _currentUser?.email ?? 'No email';

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Welcome to Fit Tracker'),
        backgroundColor: Colors.green[700],
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.account_circle, size: 50, color: Colors.green[600]),
                const SizedBox(height: 12),
                Text(
                  _status,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                  onPressed: _handleSignIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(167, 67, 160, 72),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                  onPressed: _handleSignOut,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(123, 241, 61, 61),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
                const SizedBox(height: 30),
                const Text('User Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(thickness: 1),
                Text('👤 Name: $displayName'),
                Text('📧 Email: $email'),
                const SizedBox(height: 20),
                if (_accessToken != null)
                  GoogleFitInfo(accessToken: _accessToken!)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
