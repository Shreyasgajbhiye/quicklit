import 'package:flutter/material.dart';
import 'theme_provider.dart';
import 'package:provider/provider.dart';

class QuicklitThemeToggle extends StatelessWidget {
  const QuicklitThemeToggle({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<QuicklitThemeProvider>(context);
    return Switch(
      value: themeProvider.themeMode == ThemeMode.dark,
      onChanged: (_) => themeProvider.toggleTheme(),
    );
  }
}
