import 'package:flutter/material.dart';

/// Shared colors & text styles pulled straight from the WorkWise mockups.
class AppColors {
  static const navy = Color(0xFF122036);
  static const navyDark = Color(0xFF0D1A2B);
  static const red = Color(0xFFE0403B);
  static const redBg = Color(0xFFFDEAEA);
  static const green = Color(0xFF1E8E3E);
  static const greenBg = Color(0xFFE9F7EF);
  static const blueAccent = Color(0xFF2F6FED);
  static const grey = Color(0xFF8A94A6);
  static const lightGrey = Color(0xFFF4F6F8);
  static const border = Color(0xFFE3E7ED);
  static const cardBg = Colors.white;
  static const textDark = Color(0xFF1A2233);
}

class AppTextStyles {
  static const screenTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    height: 1.2,
  );
  static const subtitle = TextStyle(
    fontSize: 12,
    color: AppColors.grey,
    fontWeight: FontWeight.w500,
  );
  static const cardLabel = TextStyle(
    fontSize: 11,
    color: AppColors.grey,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
  );
  static const cardLabelLight = TextStyle(
    fontSize: 11,
    color: Colors.white70,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
  );
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.lightGrey,
  fontFamily: 'Roboto',
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.navy,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      letterSpacing: 1,
      color: Colors.white,
    ),
  ),
);

class DeliveryTheme extends StatelessWidget {
  final Widget child;

  const DeliveryTheme({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Theme(data: appTheme, child: child);
  }
}
