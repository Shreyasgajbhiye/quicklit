import 'package:flutter/material.dart';

class QuicklitThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;
  void toggleTheme() {
    themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
