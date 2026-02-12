import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  State<HomePage> createState() => HomePageState(); //the dash before the name (_HomePageState) indicates that this class is private - cannot be inherited
}

class HomePageState extends State<HomePage> {
  int count = 0; 
  int currentPage = 0;

  void increment() {
    setState(() {
      count++;
    });
  }

  void decrement() {
    setState(() {
      count--;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Positioned(
        //   bottom: 16,
        //   right: 16,
        //   child: Padding(
        //     padding: const EdgeInsets.all(2.0),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.end,
        //       children: [
        //         FloatingActionButton(
        //           onPressed: () {
        //             decrement();
        //           },
        //           child: const Icon(Icons.remove),
        //         ),
        //         SizedBox(width: 10), // adds some space between the two buttons
        //         FloatingActionButton(
        //           onPressed: () {
        //             increment();
        //           },
        //           child: const Icon(Icons.add),
        //         )
        //       ],
        //     ),
        //   ),
        // ),

        Center(
          child: Text('$count', style: const TextStyle(fontSize: 50)),
        )
      ],
      // body: ListView.builder( 
      //   scrollDirection: Axis.horizontal,
      //   addAutomaticKeepAlives: false,
      //   itemBuilder: (context, index) {
      //     return Container(
      //       color: Colors.red[Random().nextInt(9) * 100],
      //       width: 500,
      //       height: 500,
      //     );
      //   },
        
      // ),
    );
  }
}