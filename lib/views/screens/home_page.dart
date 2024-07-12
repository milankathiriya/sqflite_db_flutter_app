import 'package:flutter/material.dart';
import 'package:sqlite_app/utils/helpers/db_helper.dart';
import 'package:sqlite_app/views/components/category_component.dart';
import 'package:sqlite_app/views/components/home_component.dart';
import 'package:sqlite_app/views/components/spending_component.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController pageController = PageController();
  int initialIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Budget Tracker"),
        centerTitle: true,
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (val) {
          setState(() {
            initialIndex = val;
          });
        },
        children: [
          HomeComponent(),
          CategoryComponent(),
          SpendingComponent(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: initialIndex,
        onDestinationSelected: (val) {
          setState(() {
            initialIndex = val;
            pageController.animateToPage(
              val,
              duration: Duration(milliseconds: 200),
              curve: Curves.easeInOut,
            );
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(Icons.apps),
            label: "Category",
          ),
          NavigationDestination(
            icon: Icon(Icons.money),
            label: "I/E",
          ),
        ],
      ),
    );
  }
}
