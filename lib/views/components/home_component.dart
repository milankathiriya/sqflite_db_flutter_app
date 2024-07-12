import 'package:flutter/material.dart';

class HomeComponent extends StatefulWidget {
  const HomeComponent({super.key});

  @override
  State<HomeComponent> createState() => _HomeComponentState();
}

class _HomeComponentState extends State<HomeComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(color: Colors.amber, child: Text("Home"), alignment: Alignment.center,),
    );
  }
}

