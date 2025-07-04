import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicklit/quicklit.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => QuicklitThemeProvider(),
      child: const QuicklitApp(),
    ),
  );
}

class QuicklitApp extends StatelessWidget {
  const QuicklitApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<QuicklitThemeProvider>(context);

    return MaterialApp(
      title: 'Quicklit Demo',
      debugShowCheckedModeBanner: false,
      themeMode: theme.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const DemoScreen(), // shows login + theme toggle
    );
  }
}

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quicklit Login'),
        actions: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: QuicklitThemeToggle(), // Theme switch
          ),
        ],
      ),
      body: const QuicklitLoginPage(), // Login screen
    );
  }
}
