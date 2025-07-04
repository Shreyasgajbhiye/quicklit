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
      themeMode: theme.themeMode,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: const QuicklitLoginPage(),
    );
  }
}
