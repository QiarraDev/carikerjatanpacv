import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/auth/onboarding_screen.dart';
import 'features/auth/role_selection_page.dart';
import 'features/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final role = prefs.getString('user_role');
  final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
  
  print('--- Global main(): Initial role = $role, Seen Onboarding = $seenOnboarding');
  runApp(MyApp(initialRole: role, seenOnboarding: seenOnboarding));
}

class MyApp extends StatelessWidget {
  final String? initialRole;
  final bool seenOnboarding;

  const MyApp({super.key, this.initialRole, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CariKerjaTanpaCV',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF6366F1),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6366F1)),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
      home: (initialRole != null && initialRole!.isNotEmpty)
          ? MainNavigation(initialRole: initialRole)
          : seenOnboarding
              ? const RoleSelectionScreen()
              : const OnboardingScreen(),
    );
  }
}
