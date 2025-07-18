import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'providers/auth_provider.dart';
import 'providers/wish_provider.dart';
import 'providers/user_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'utils/app_colors.dart';
import 'utils/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const WishLinkApp());
}

class WishLinkApp extends StatelessWidget {
  const WishLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WishProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
      ],
      child: MaterialApp(
        title: 'WishLink',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          fontFamily: GoogleFonts.poppins().fontFamily,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            titleTextStyle: GoogleFonts.poppins(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: const IconThemeData(color: AppColors.textDark),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              textStyle: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          textTheme: GoogleFonts.poppinsTextTheme().copyWith(
            headlineLarge: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
            headlineMedium: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            bodyLarge: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textDark,
            ),
            bodyMedium: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textGray,
            ),
          ),
        ),
        home: const SplashScreen(),
        routes: AppRoutes.routes,
      ),
    );
  }
} 