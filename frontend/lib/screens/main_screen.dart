import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'due_list_screen.dart';

class MainScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const MainScreen({super.key, required this.toggleTheme});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const HomeScreen(),
    const DueListScreen(),
    const AnalyticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,

        title: const Text("Smart Expense Tracker"),

        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),

            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),

      drawer: SettingsScreen(toggleTheme: widget.toggleTheme),

      body: screens[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,

        selectedItemColor: Colors.green,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Dues",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Analytics",
          ),
        ],
      ),
    );
  }
}
