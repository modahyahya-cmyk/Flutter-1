import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/splash_page.dart';
import '../features/cart/presentation/pages/cart_page.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/map/presentation/pages/map_page.dart';
import '../features/orders/presentation/pages/orders_page.dart';
import '../features/products/presentation/pages/products_page.dart';
import '../features/subscriptions/presentation/pages/subscription_plans_page.dart';
import '../features/video_feed/presentation/pages/video_feed_page.dart';

import 'dependency_injection.dart';

/// Centralised, typed router configuration.
///
/// The router owns a single [AuthController] instance resolved from DI and
/// listens to it ([GoRouter.refreshListenable]) so any authentication-state
/// change (login, logout, session restore) re-runs the auth guard below.
class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String products = '/products';
  static const String cart = '/cart';
  static const String videoFeed = '/videos';
  static const String subscriptions = '/subscriptions';
  static const String orders = '/orders';
  static const String map = '/map';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    refreshListenable: getIt<AuthController>(),
    redirect: _redirect,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: home,
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: products,
        builder: (context, state) => const ProductsPage(),
      ),
      GoRoute(
        path: cart,
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: videoFeed,
        builder: (context, state) => const VideoFeedPage(),
      ),
      GoRoute(
        path: subscriptions,
        builder: (context, state) => const SubscriptionPlansPage(),
      ),
      GoRoute(
        path: orders,
        builder: (context, state) => const OrdersPage(),
      ),
      GoRoute(
        path: map,
        builder: (context, state) => const MapPage(),
      ),
    ],
  );

  /// Auth guard: keeps unauthenticated users on [login]/[register]/[splash]
  /// and sends them to [login] otherwise, while authenticated users never see
  /// the auth screens and land on [home].
  static String? _redirect(BuildContext context, GoRouterState state) {
    final status = getIt<AuthController>().status;
    final location = state.matchedLocation;

    final atSplash = location == splash;
    final atLogin = location == login || location == register;

    // Session not resolved yet: hold on the splash screen.
    if (status == AuthStatus.initial || status == AuthStatus.loading) {
      return atSplash ? null : splash;
    }

    if (status == AuthStatus.unauthenticated) {
      // Allow staying on splash/login/register, block everything else.
      return (atSplash || atLogin) ? null : login;
    }

    // Authenticated: never show splash or the auth screens.
    if (atSplash || atLogin) return home;
    return null;
  }
}
