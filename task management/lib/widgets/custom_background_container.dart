import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class CustomBackgroundContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  const CustomBackgroundContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final settings = themeProvider.backgroundSettings;

        if (settings.useDefault) {
          // Return default background
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: themeProvider.isDarkMode
                    ? [Colors.grey[900]!, Colors.black]
                    : [Colors.blue[100]!, Colors.lightBlue[100]!],
              ),
            ),
            child: child,
          );
        }

        if (settings.imagePath != null) {
          // Return image background
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(File(settings.imagePath!)),
                fit: BoxFit.cover,
              ),
            ),
            child: child,
          );
        }

        if (settings.backgroundColor != null) {
          // Return color background
          return Container(
            width: width,
            height: height,
            color: Color(settings.backgroundColor!),
            child: child,
          );
        }

        // Fallback to default
        return SizedBox(
          width: width,
          height: height,
          child: child,
        );
      },
    );
  }
}