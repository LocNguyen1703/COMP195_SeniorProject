import 'package:flutter/material.dart';

class NewPage2 extends StatelessWidget {
  const NewPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: const Center(
        child: Text('Hello World', style: TextStyle(fontSize: 50)),
      ),
    );
  }
}