import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'recent_screen.dart';
import 'settings_screen.dart';
import 'test_connection_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const RecentScreen(),
    const FavoritesScreen(),
    const SettingsScreen(),
    const TestConnectionScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadLastTab();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadLastTab() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTab = prefs.getInt('lastTab') ?? 0;
    setState(() {
      _currentIndex = lastTab;
    });
    _pageController.animateToPage(
      _currentIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _saveLastTab(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastTab', index);
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _saveLastTab(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _saveLastTab(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.darkSurface,
          border: Border(
            top: BorderSide(
              color: AppColors.darkBorder,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.darkSurface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_outlined),
              activeIcon: Icon(Icons.folder),
              label: 'Files',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time_outlined),
              activeIcon: Icon(Icons.access_time),
              label: 'Recent',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outline),
              activeIcon: Icon(Icons.star),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bug_report_outlined),
              activeIcon: Icon(Icons.bug_report),
              label: 'Test',
            ),
          ],
        ),
      ),
    );
  }
}

