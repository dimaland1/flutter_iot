import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ttgo_app/screens/sensors_screen.dart';
import 'package:ttgo_app/screens/statistics_screen.dart';
import 'package:ttgo_app/screens/threshold_screen.dart';

import 'led_control_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const SensorsScreen(),
    const LedControlScreen(),
    const ThresholdScreen(),
    const StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sensors),
            label: 'Capteurs',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb),
            label: 'LEDs',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune),
            label: 'Seuils',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}