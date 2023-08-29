import 'package:autostop/firebase_options.dart';
import 'package:autostop/screens/map_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final Color primaryColor = const Color(0xFF4C72B0);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoStop',
      themeMode: ThemeMode.system,
      theme: _buildLightThemeData(),
      darkTheme: _buildDarkThemeData(),
      home: const MapScreen(),
    );
  }

  ThemeData _buildLightThemeData() {
    const bg = Colors.white;
    const fg = Color(0xFF202123);
    return ThemeData(
      primaryColor: primaryColor, // Dark pastel blue
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        color: bg,
        iconTheme: IconThemeData(color: fg),
      ),
      textTheme: _getTextTheme().apply(bodyColor: fg, displayColor: fg),
      cardTheme: _getCardTheme(null),
      iconTheme: const IconThemeData(color: fg),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const MaterialStatePropertyAll(bg),
          backgroundColor: MaterialStatePropertyAll(primaryColor),
        ),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor, // Dark pastel blue for buttons
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(primaryColor),
          foregroundColor: const MaterialStatePropertyAll(Colors.white),
          textStyle: const MaterialStatePropertyAll(TextStyle(fontSize: 14)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStatePropertyAll(primaryColor),
      ),
    );
  }

  ThemeData _buildDarkThemeData() {
    const fg = Colors.white;
    const bg = Color(0xFF202123);
    return ThemeData.dark().copyWith(
      primaryColor: primaryColor, // Dark pastel blue
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: fg),
      ),
      textTheme: _getTextTheme().apply(bodyColor: fg, displayColor: fg),
      cardTheme: _getCardTheme(null),
      buttonTheme: ButtonThemeData(
        buttonColor: primaryColor, // Dark pastel blue for buttons
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(primaryColor),
          textStyle: const MaterialStatePropertyAll(TextStyle(fontSize: 14)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: fg,
      ),
      iconTheme: const IconThemeData(color: fg),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: const MaterialStatePropertyAll(fg),
          backgroundColor: MaterialStatePropertyAll(primaryColor),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStatePropertyAll(primaryColor),
      ),
    );
  }

  CardTheme _getCardTheme(Color? color) {
    return CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: color,
    );
  }

  TextTheme _getTextTheme() {
    return const TextTheme(
      displayLarge: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold),
      titleSmall: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontSize: 16.0),
      bodyMedium: TextStyle(fontSize: 14.0),
      bodySmall: TextStyle(fontSize: 12.0),
      labelLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      labelMedium: TextStyle(fontSize: 12.0, fontWeight: FontWeight.bold),
      labelSmall: TextStyle(
        fontSize: 12,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w300,
      ),
    );
  }
}
