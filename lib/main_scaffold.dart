import 'package:flutter/material.dart';
import 'package:uangin/core/widgets/bottom_navigation/custom_bottom_navigator.dart';
import 'package:uangin/features/home/views/home_screen.dart';
import 'package:uangin/features/profile/views/profile_screen.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: [HomeScreen(), ProfileScreen()],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: CustomBottomNavigator(
              selectedIndex: _selectedIndex,
              onIndexChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              onAddTap: () {},
            ),
          )
        ],
      ),
    );
  }
}
