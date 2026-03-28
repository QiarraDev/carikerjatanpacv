import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home/candidate_home_page.dart';
import 'home/recruiter_home_page.dart';
import 'profile/profile_page.dart';
import 'chat/chat_page.dart';

class MainNavigation extends StatefulWidget {
  final String? initialRole;
  const MainNavigation({super.key, this.initialRole});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _userRole = widget.initialRole;
    if (_userRole == null) _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userRole = prefs.getString('user_role');
    });
  }

  List<Widget> get _pages {
    Widget homeScreen = const CandidateHomeScreen();
    if (_userRole == 'recruiter') {
      homeScreen = const RecruiterHomeScreen();
    }

    return [
      homeScreen,
      const ChatPage(),
      const ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Hidden but can have overlay
        title: Text("Role Debug: ${_userRole ?? 'Loading...'}"),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: _userRole == 'recruiter' ? const Color(0xFF10B981) : const Color(0xFF6366F1),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(_userRole == 'recruiter' ? Icons.dashboard : Icons.search), 
            label: _userRole == 'recruiter' ? 'Dashboard' : 'Cari'
          ),
          BottomNavigationBarItem(
            icon: Icon(_userRole == 'recruiter' ? Icons.people : Icons.assignment_outlined), 
            label: _userRole == 'recruiter' ? 'Kandidat' : 'Lamaran'
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}
