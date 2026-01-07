import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  final String location;

  const MainShell({
    super.key,
    required this.child,
    required this.location,
  });

  int _getCurrentIndex(String location) {
    if (location == '/home' || location.startsWith('/home/')) {
      return 0;
    } else if (location == '/maps' || location.startsWith('/maps/')) {
      return 1;
    } else if (location == '/community' || location.startsWith('/community/')) {
      return 2;
    } else if (location == '/chatbot' || location.startsWith('/chatbot/')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/maps');
        break;
      case 2:
        context.go('/community');
        break;
      case 3:
        context.go('/chatbot');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(context, index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.white,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_rounded),
              activeIcon: Icon(Icons.map_rounded),
              label: 'Maps',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: 'Community',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.smart_toy_outlined),
              activeIcon: Icon(Icons.smart_toy),
              label: 'AI Assistant',
            ),
          ],
        ),
      ),
    );
  }
}

