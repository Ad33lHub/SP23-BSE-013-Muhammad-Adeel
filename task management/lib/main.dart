import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/add_task_screen.dart';
import 'theme/glassmorphism_theme.dart';
import 'widgets/glass_widgets.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Task Management',
            debugShowCheckedModeBanner: false,
            theme: GlassmorphismTheme.darkTheme,
            themeMode: ThemeMode.dark, // Force dark theme for glassmorphism
            home: const GlassBackground(
              child: HomeScreen(),
            ),
            routes: {
              '/add-task': (context) => const GlassBackground(
                    child: AddTaskScreen(),
                  ),
            },
          );
        },
      ),
    );
  }
}
