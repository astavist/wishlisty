import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/main_navigation_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/wish/wish_detail_screen.dart';
import '../screens/wish/add_wish_screen.dart';
import '../screens/friends/friends_screen.dart';
import '../screens/notifications/notifications_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String mainNavigation = '/main-navigation';
  static const String profile = '/profile';
  static const String wishDetail = '/wish-detail';
  static const String addWish = '/add-wish';
  static const String friends = '/friends';
  static const String notifications = '/notifications';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      forgotPassword: (context) => const ForgotPasswordScreen(),
      home: (context) => const HomeScreen(),
      mainNavigation: (context) => const MainNavigationScreen(),
      profile: (context) => const ProfileScreen(),
      wishDetail: (context) => const WishDetailScreen(),
      addWish: (context) => const AddWishScreen(),
      friends: (context) => const FriendsScreen(),
      notifications: (context) => const NotificationsScreen(),
    };
  }

  static void pushNamed(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void pushReplacementNamed(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void pushNamedAndClearStack(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void pop(BuildContext context, [Object? result]) {
    Navigator.pop(context, result);
  }
} 