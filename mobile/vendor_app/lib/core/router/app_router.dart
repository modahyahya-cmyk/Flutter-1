import 'package:go_router/go_router.dart';

import '../../config/dependency_injection.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/branches/presentation/pages/branch_form_page.dart';
import '../../features/branches/presentation/pages/branches_page.dart';
import '../../features/earnings/presentation/pages/earnings_page.dart';
import '../../features/inventory/presentation/pages/inventory_page.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/products/presentation/pages/product_form_page.dart';
import '../../features/products/presentation/pages/products_page.dart';
import '../../features/thermal_printing/presentation/pages/printer_page.dart';
import '../../features/home/presentation/pages/home_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: locator<AuthController>(),
  redirect: (context, state) {
    final auth = locator<AuthController>();
    final authenticated = auth.status == AuthStatus.authenticated;
    final onLogin = state.matchedLocation == '/login';
    if (!authenticated && !onLogin) return '/login';
    if (authenticated && onLogin) return '/orders';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/printer', builder: (context, state) => const PrinterPage()),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          HomeShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrdersPage(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    OrderDetailPage(orderId: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductsPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (context, state) => const ProductFormPage(),
              ),
              GoRoute(
                path: ':id/edit',
                builder: (context, state) => ProductFormPage(productId: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/inventory', builder: (context, state) => const InventoryPage()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/branches',
            builder: (context, state) => const BranchesPage(),
            routes: [
              GoRoute(path: 'new', builder: (context, state) => const BranchFormPage()),
              GoRoute(
                path: ':id/edit',
                builder: (context, state) => BranchFormPage(branchId: int.parse(state.pathParameters['id']!)),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/earnings', builder: (context, state) => const EarningsPage()),
        ]),
      ],
    ),
  ],
);
