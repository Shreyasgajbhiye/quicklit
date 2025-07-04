import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuicklitLoginPage extends StatefulWidget {
  const QuicklitLoginPage({super.key});
  @override
  State<QuicklitLoginPage> createState() => _QuicklitLoginPageState();
}

class _QuicklitLoginPageState extends State<QuicklitLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String error = '';

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } catch (e) {
      setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: login, child: const Text("Login")),
            if (error.isNotEmpty) Text(error, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
