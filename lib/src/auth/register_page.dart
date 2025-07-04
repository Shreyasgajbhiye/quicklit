import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuicklitRegisterPage extends StatefulWidget {
  const QuicklitRegisterPage({super.key});

  @override
  State<QuicklitRegisterPage> createState() => _QuicklitRegisterPageState();
}

class _QuicklitRegisterPageState extends State<QuicklitRegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  String _error = '';
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() {
      _error = '';
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmController.text;

    if (password != confirmPassword) {
      setState(() {
        _error = 'Passwords do not match.';
        _isLoading = false;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = e.message ?? 'An unknown error occurred.';
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            TextField(
              controller: _confirmController,
              decoration: const InputDecoration(labelText: "Confirm Password"),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Register"),
            ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
