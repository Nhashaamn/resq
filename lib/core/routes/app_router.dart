import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/func/presentation/pages/chat_settings.dart';
import 'package:resq/features/func/presentation/pages/chatbot_page.dart';
import 'package:resq/features/func/presentation/pages/community_groups_page.dart';
import 'package:resq/features/func/presentation/pages/community_page.dart';
import 'package:resq/features/func/presentation/pages/private_emergency_messages_page.dart';
import 'package:resq/features/func/presentation/pages/group_chat_page.dart';
import 'package:resq/features/func/presentation/pages/groups_list_page.dart';
import 'package:resq/features/func/presentation/pages/home_content_page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:resq/features/func/presentation/pages/maps_page.dart';
import 'package:resq/features/func/presentation/pages/setting.dart';
import 'package:resq/features/func/presentation/providers/group_provider.dart';
import 'package:resq/features/func/presentation/widgets/main_shell.dart';
import 'package:resq/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:resq/features/auth/presentation/pages/login_page.dart';
import 'package:resq/features/auth/presentation/pages/otp_page.dart';
import 'package:resq/features/auth/presentation/pages/phone_page.dart';
import 'package:resq/features/auth/presentation/pages/signup_page.dart';
import 'package:resq/features/auth/presentation/pages/start_page.dart';
import 'package:resq/features/auth/presentation/providers/auth_provider.dart';
import 'package:resq/features/func/presentation/pages/address_page.dart';
import 'package:resq/features/func/presentation/pages/emergency_alert_page.dart';
import 'package:resq/features/func/presentation/pages/disaster_guides/earth_quack.dart';
import 'package:resq/features/func/presentation/pages/disaster_guides/earth_quack_guide.dart';
import 'package:resq/features/func/presentation/pages/disaster_guides/fire.dart';
import 'package:resq/features/func/presentation/pages/disaster_guides/fire_guide.dart';
import 'package:resq/features/func/presentation/pages/disaster_guides/flood.dart';
import 'package:resq/features/func/presentation/pages/disaster_guides/flood_guide.dart';
import 'package:resq/features/func/presentation/pages/disaster_guides/storm.dart';
import 'package:resq/features/func/presentation/pages/disaster_guides/storm_guide.dart';
import 'package:resq/features/func/presentation/pages/disaster_guides/tsunami.dart';
import 'package:resq/features/func/presentation/pages/disaster_guides/tsunami_guide.dart';
import 'package:resq/features/func/presentation/pages/disaster_guides/volcano.dart';
import 'package:resq/features/func/presentation/pages/disaster_guides/volcano_guide.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  // Determine initial location based on auth state
  // If loading, default to start (will redirect once loaded)
  // If authenticated, start at home
  // If not authenticated, start at start page
  final initialLocation = authState.isLoading 
      ? '/start' 
      : (authState.isAuthenticated ? '/home' : '/start');
  
  final router = GoRouter(
    initialLocation: initialLocation,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found: ${state.uri}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/start'),
              child: const Text('Go to Start Page'),
            ),
          ],
        ),
      ),
    ),
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;

      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignup = state.matchedLocation == '/signup';
      final isGoingToForgotPassword = state.matchedLocation == '/forgot-password';
      final isGoingToProtected = state.matchedLocation == '/home' ||
          state.matchedLocation == '/chatsetting' ||
          state.matchedLocation == '/chatbot' ||
          state.matchedLocation == '/maps' ||
          state.matchedLocation == '/community' ||
          state.matchedLocation.startsWith('/community/') ||
          state.matchedLocation == '/setting' ||
          state.matchedLocation.startsWith('/group/') ||
          state.matchedLocation == '/groups' ||
          state.matchedLocation.startsWith('/join/') ||
          state.matchedLocation == '/earth_quack' ||
          state.matchedLocation.startsWith('/earth_quack/') ||
          state.matchedLocation == '/fire' ||
          state.matchedLocation.startsWith('/fire/') ||
          state.matchedLocation == '/flood' ||
          state.matchedLocation.startsWith('/flood/') ||
          state.matchedLocation == '/storm' ||
          state.matchedLocation.startsWith('/storm/') ||
          state.matchedLocation == '/tsunami' ||
          state.matchedLocation.startsWith('/tsunami/') ||
          state.matchedLocation == '/volcano' ||
          state.matchedLocation.startsWith('/volcano/');
      final isGoingToAddress = state.matchedLocation == '/address';
      final isGoingToEmergencyAlert = state.matchedLocation == '/emergency-alert';
      
      // If still loading, don't redirect (let it finish loading first)
      if (authState.isLoading) {
        return null;
      }
      
      // If authenticated and trying to access login/signup/forgot-password, redirect to home
      if (isAuthenticated && (isGoingToLogin || isGoingToSignup || isGoingToForgotPassword)) {
        return '/home';
      }
      
      // If not authenticated and trying to access protected routes or address, redirect to login
      // Emergency alert can be accessed without auth (for panic mode)
      if (!isAuthenticated && (isGoingToProtected || isGoingToAddress) && !isGoingToEmergencyAlert) {
        return '/login';
      }
      
      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/start',
        builder: (context, state) => const StartPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/phone',
        builder: (context, state) => const PhonePage(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final extra = state.extra as Map<String, String>?;
          return OtpPage(
            verificationId: extra?['verificationId'] ?? '',
            phoneNumber: extra?['phoneNumber'] ?? '',
          );
        },
      ),
      GoRoute(
        path: '/address',
        builder: (context, state) => const AddressPage(),
      ),
      GoRoute(
        path: '/emergency-alert',
        builder: (context, state) => const EmergencyAlertPage(),
      ),
      GoRoute(
        path: '/setting',
        builder: (context, state) => const Setting(),
      ),
      GoRoute(
        path: '/chatsetting',
        builder: (context, state) => const ChatSettings(),
      ),
      GoRoute(
        path: '/groups',
        builder: (context, state) => const GroupsListPage(),
      ),
      GoRoute(
        path: '/group/:groupId',
        builder: (context, state) {
          final groupId = state.pathParameters['groupId']!;
          return GroupChatPage(groupId: groupId);
        },
      ),
      GoRoute(
        path: '/join/:inviteCode',
        builder: (context, state) {
          final inviteCode = state.pathParameters['inviteCode']!;
          return _JoinGroupPage(inviteCode: inviteCode);
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(
            location: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeContentPage(),
          ),
          GoRoute(
            path: '/maps',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              return MapsPage(
                targetSafeZoneId: extra?['safeZoneId'] as String?,
                targetSafeZoneLocation: extra?['safeZoneLocation'] as LatLng?,
                targetSafeZoneName: extra?['safeZoneName'] as String?,
              );
            },
          ),
          GoRoute(
            path: '/community',
            builder: (context, state) => const CommunityGroupsPage(),
          ),
          GoRoute(
            path: '/community/chat',
            builder: (context, state) => const CommunityPage(),
          ),
          GoRoute(
            path: '/community/private-messages',
            builder: (context, state) => const PrivateEmergencyMessagesPage(),
          ),
          GoRoute(
            path: '/chatbot',
            builder: (context, state) => const ChatbotPage(),
          ),
          GoRoute(
            path: '/earth_quack',
            builder: (context, state) => const EarthQuack(),
          ),
          GoRoute(
            path: '/earth_quack/guide',
            builder: (context, state) => const EarthQuackGuide(),
          ),
          GoRoute(
            path: '/fire',
            builder: (context, state) => const Fire(),
          ),
          GoRoute(
            path: '/fire/guide',
            builder: (context, state) => const FireGuide(),
          ),
          GoRoute(
            path: '/flood',
            builder: (context, state) => const Flood(),
          ),
          GoRoute(
            path: '/flood/guide',
            builder: (context, state) => const FloodGuide(),
          ),
          GoRoute(
            path: '/storm',
            builder: (context, state) => const Storm(),
          ),
          GoRoute(
            path: '/storm/guide',
            builder: (context, state) => const StormGuide(),
          ),
          GoRoute(
            path: '/tsunami',
            builder: (context, state) => const Tsunami(),
          ),
          GoRoute(
            path: '/tsunami/guide',
            builder: (context, state) => const TsunamiGuide(),
          ),
          GoRoute(
            path: '/volcano',
            builder: (context, state) => const Volcano(),
          ),
          GoRoute(
            path: '/volcano/guide',
            builder: (context, state) => const VolcanoGuide(),
          ),
        ],
      ),
    ],
  );
  
  // Listen to auth state changes and navigate accordingly
  // This ensures navigation happens when auth state changes from loading to authenticated/not authenticated
  ref.listen<AuthState>(authStateProvider, (previous, next) {
    // Navigate when loading finishes
    if (!next.isLoading) {
      if (next.isAuthenticated) {
        // User is authenticated, navigate to home if not already there
        // The redirect will also handle this, but this ensures immediate navigation on app startup
        router.go('/home');
      } else if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        // User just logged out, navigate to login
        router.go('/login');
      }
    }
  });
  
  return router;
});

// Temporary page for handling deep links - will join group and navigate
class _JoinGroupPage extends ConsumerStatefulWidget {
  final String inviteCode;

  const _JoinGroupPage({required this.inviteCode});

  @override
  ConsumerState<_JoinGroupPage> createState() => __JoinGroupPageState();
}

class __JoinGroupPageState extends ConsumerState<_JoinGroupPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _joinGroup();
    });
  }

  Future<void> _joinGroup() async {
    final success = await ref.read(groupProvider.notifier).joinGroup(widget.inviteCode);
    if (mounted) {
      if (success) {
        // Find the group and navigate to it
        final groups = ref.read(groupProvider).groups;
        final group = groups.firstWhere(
          (g) => g.inviteCode == widget.inviteCode.toUpperCase(),
          orElse: () => throw Exception('Group not found'),
        );
        context.go('/group/${group.id}');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ref.read(groupProvider).error?.when(
                    server: (msg) => msg,
                    network: (msg) => msg,
                    cache: (msg) => msg,
                    validation: (msg) => msg,
                    auth: (msg) => msg,
                  ) ?? 'Failed to join group',
            ),
            backgroundColor: AppTheme.errorRed,
          ),
        );
        context.go('/chatsetting');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

