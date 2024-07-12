import 'package:flutter/material.dart';

class SpendingComponent extends StatefulWidget {
  const SpendingComponent({super.key});

  @override
  State<SpendingComponent> createState() => _SpendingComponentState();
}

class _SpendingComponentState extends State<SpendingComponent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(color: Colors.redAccent, child: Text("Spending"), alignment: Alignment.center,),
    );
  }
}

