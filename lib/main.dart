import 'package:autostop/firebase_options.dart';
import 'package:autostop/screens/account_deletion_screen.dart';
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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AutoStop',
      themeMode: ThemeMode.system,
      theme: _buildLightThemeData(),
      darkTheme: _buildDarkThemeData(),
      home: const MapScreen(),
      routes: {
        '/delete-account': (context) => const AccountDeletionPage(),
      },
    );
  }

  ThemeData _buildLightThemeData() {
    const bg = Colors.white;
    const fg = Color(0xFF202123);
    const Color primaryColor = Color(0xFF4C72B0);
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
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStatePropertyAll(bg),
          backgroundColor: MaterialStatePropertyAll(primaryColor),
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryColor, // Dark pastel blue for buttons
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(primaryColor),
          foregroundColor: MaterialStatePropertyAll(Colors.white),
          textStyle: MaterialStatePropertyAll(TextStyle(fontSize: 14)),
        ),
      ),
      checkboxTheme: const CheckboxThemeData(
        checkColor: MaterialStatePropertyAll(primaryColor),
      ),
    );
  }

  ThemeData _buildDarkThemeData() {
    const fg = Colors.white;
    const bg = Color(0xFF202123);
    const Color primaryColor = Color(0xFF4C72B0);
    return ThemeData.dark().copyWith(
      primaryColor: primaryColor, // Dark pastel blue
      scaffoldBackgroundColor: bg,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: fg),
      ),
      textTheme: _getTextTheme().apply(bodyColor: fg, displayColor: fg),
      cardTheme: _getCardTheme(null),
      buttonTheme: const ButtonThemeData(
        buttonColor: primaryColor, // Dark pastel blue for buttons
      ),
      elevatedButtonTheme: const ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStatePropertyAll(primaryColor),
          textStyle: MaterialStatePropertyAll(TextStyle(fontSize: 14)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: fg,
      ),
      iconTheme: const IconThemeData(color: fg),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStatePropertyAll(fg),
          backgroundColor: MaterialStatePropertyAll(primaryColor),
        ),
      ),
      checkboxTheme: const CheckboxThemeData(
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
