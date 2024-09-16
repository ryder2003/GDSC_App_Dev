import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_gallery/api/apis.dart';
import 'package:gdsc_gallery/screens/profile.dart';
import 'home_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  late List<Widget> Pages;
  late HomeScreen home_screen;
  late ProfileScreen profile;
  int currentTabIndex = 0;
  bool _isInitialized = false; // Add a flag to track initialization

  @override
  void initState() {
    super.initState();
    // Initialize the user info and setup the screens
    _initialize();
  }

  Future<void> _initialize() async {
    await APIs.getSelfInfo(); // Ensure APIs.me is initialized
    setState(() {
      home_screen = HomeScreen();
      profile = ProfileScreen(user: APIs.me);
      Pages = [home_screen, profile];
      _isInitialized = true; // Set the flag to true when initialization is complete
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if Pages have been initialized
    if (!_isInitialized) {
      // Return a loader or some placeholder UI until initialization is complete
      return Scaffold(
        body: Center(child: CircularProgressIndicator()), // Show loading indicator
      );
    }

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: CurvedNavigationBar(
          height: 70,
          backgroundColor: const Color(0xfff2f2f2),
          color: Colors.black,
          animationDuration: const Duration(milliseconds: 500),
          onTap: (int index) {
            setState(() {
              currentTabIndex = index;
            });
          },
          items: const [
            Icon(Icons.home_outlined, color: Colors.white),
            Icon(Icons.person_outlined, color: Colors.white),
          ],
        ),
      ),
      body: Pages[currentTabIndex], // Use Pages here after checking it's initialized
    );
  }
}

