import 'package:flutter/material.dart';
import 'colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.darkBlue,
        onPrimary: AppColors.white,
        secondary: AppColors.orange,
        onSecondary: AppColors.black,
        error: Colors.red,
        onError: AppColors.white,
        background: AppColors.lightGray,
        onBackground: AppColors.black,
        surface: AppColors.white,
        onSurface: AppColors.black,
      ),
      useMaterial3: true,
    );
  }
}
