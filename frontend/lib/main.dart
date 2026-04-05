import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/history_screen.dart';
import 'screens/login_screen.dart';
import 'screens/saved_reviews_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/history_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/review_provider.dart';
import 'providers/lifecycle_provider.dart';
import 'providers/navigation_provider.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'widgets/figma_bottom_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  try {
    await _bootstrap();
  } catch (e, stack) {
    debugPrint('Bootstrap error: $e');
    debugPrint('Stack trace: $stack');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SelectableText('Failed to start app:\n$e'),
        ),
      ),
    ));
  }
}

Future<void> _bootstrap() async {
  await NotificationService.init();
  await NotificationService.showInstallSuccessOnFirstLaunch();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Error loading .env: $e');
  }
  
  final url = dotenv.env['SUPABASE_URL'] ?? '';
  final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  if (url.isEmpty || anonKey.isEmpty) {
    runApp(const _MissingEnvApp());
    return;
  }

  await Supabase.initialize(url: url, anonKey: anonKey);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, HistoryProvider>(
          create: (_) => HistoryProvider(),
          update: (_, auth, history) {
            history ??= HistoryProvider();
            history.updateUser(auth.currentUserId);
            return history;
          },
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => LifecycleProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ReviewProvider>(
          create: (_) => ReviewProvider(),
          update: (_, auth, reviews) {
            reviews ??= ReviewProvider();
            reviews.updateUser(auth.currentUserId);
            return reviews;
          },
        ),
      ],
      child: const SentimentApp(),
    ),
  );
}

class _MissingEnvApp extends StatelessWidget {
  const _MissingEnvApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Missing Supabase keys. Add SUPABASE_URL and SUPABASE_ANON_KEY to .env.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class SentimentApp extends StatefulWidget {
  const SentimentApp({super.key});

  @override
  State<SentimentApp> createState() => _SentimentAppState();
}

class _SentimentAppState extends State<SentimentApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    context.read<LifecycleProvider>().update(state);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'SentimentPro Analyzer',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.mode,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (!authProvider.initialized) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return authProvider.isAuthenticated
            ? const MainScreen()
            : const LoginScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  static const List<Widget> _screens = [
    DashboardScreen(),
    HomeScreen(),
    HistoryScreen(),
    SavedReviewsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationProvider>(
      builder: (context, nav, child) {
        return Scaffold(
          body: _screens[nav.index],
          bottomNavigationBar: FigmaBottomNav(
            currentIndex: nav.index,
            onTap: nav.setIndex,
            items: const [
              FigmaBottomNavItem(icon: Icons.dashboard_rounded, label: 'Dashboard'),
              FigmaBottomNavItem(icon: Icons.analytics_rounded, label: 'Analyze'),
              FigmaBottomNavItem(icon: Icons.history_rounded, label: 'History'),
              FigmaBottomNavItem(icon: Icons.bookmark_rounded, label: 'Saved'),
              FigmaBottomNavItem(icon: Icons.person_rounded, label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
