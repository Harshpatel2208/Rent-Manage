import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_colors.dart';
import 'core/notifications/fcm_service.dart';
import 'core/offline/local_db.dart';
import 'features/auth/domain/entities/user_entity.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/otp_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/dashboard/presentation/screens/conflicts_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/dashboard/presentation/screens/reports_screen.dart';
import 'features/expenses/presentation/screens/expenses_list_screen.dart';
import 'features/lending/presentation/screens/add_loan_screen.dart';
import 'features/lending/presentation/screens/loan_detail_screen.dart';
import 'features/lending/presentation/screens/loans_list_screen.dart';
import 'features/rental/presentation/screens/tenant_ledger_screen.dart';
import 'features/rental/presentation/screens/units_list_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SQLite Local DB Init
  await LocalDb.instance.init();

  // Firebase Init (safely caught in case config files are not yet created)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('[Firebase] Initialization failed/skipped: $e');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

/// A listenable class that lets GoRouter refresh its route whenever the
/// authentication state changes.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<UserEntity?>>(
      authNotifierProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);

      // Avoid redirection while loading initial auth state.
      if (authState.isLoading || authState.hasError) {
        return null;
      }

      final user = authState.valueOrNull;
      final isLoggedIn = user != null;

      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/otp';

      if (!isLoggedIn) {
        // If not logged in and not on an auth screen, redirect to login
        return isLoggingIn ? null : '/login';
      }

      // If logged in and on an auth screen, redirect to dashboard
      if (isLoggingIn) {
        return '/dashboard';
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => const OtpScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/loans',
            builder: (context, state) => const LoansListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const AddLoanScreen(),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return LoanDetailScreen(loanId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/rental',
            builder: (context, state) => const UnitsListScreen(),
            routes: [
              GoRoute(
                path: 'tenants/:id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return TenantLedgerScreen(tenantId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/expenses',
            builder: (context, state) => const ExpensesListScreen(),
            routes: [
              GoRoute(
                path: 'add',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) =>
                    const ExpensesListScreen(showAddSheet: true),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/sync/conflicts',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ConflictsScreen(),
      ),
      GoRoute(
        path: '/reports',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReportsScreen(),
      ),
    ],
  );
});

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initFcm();
  }

  Future<void> _initFcm() async {
    try {
      await ref.read(fcmServiceProvider).initialize();
    } catch (e) {
      debugPrint('[FCM] Setup failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    // If the auth notifier is still reading secure storage on startup,
    // show a premium dark splash/loading screen.
    if (authState.isLoading && authState.valueOrNull == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'MoneyManager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.15),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              );
            }
            return const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primaryLight);
            }
            return const IconThemeData(color: AppColors.textSecondary);
          }),
        ),
      ),
      routerConfig: router,
    );
  }
}

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key, required this.child});

  final Widget child;

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/loans')) return 1;
    if (location.startsWith('/rental')) return 2;
    if (location.startsWith('/expenses')) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/dashboard');
        break;
      case 1:
        context.go('/loans');
        break;
      case 2:
        context.go('/rental');
        break;
      case 3:
        context.go('/expenses');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.monetization_on_outlined),
            selectedIcon: Icon(Icons.monetization_on),
            label: 'Loans',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business),
            label: 'Rental',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
        ],
      ),
    );
  }
}
