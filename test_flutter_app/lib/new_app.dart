import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  //build method - main method that returns our main widget and that will be called anytime Flutter needs
  // to REBUILD the UI (e.g. when data changes or after some user interaction)
  Widget build(BuildContext context) { // main method that returns main widget of our app 
    return MaterialApp(
      title: 'MyApp',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // theme of the app (i.e. color scheme)
      ),
      home: const HomePage(),
        );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int count = 0; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),

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

      body: Center(
        child: Text('$count', style: const TextStyle(fontSize: 50)),
      ),
      
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  count--;
                });
              },
              child: const Icon(Icons.remove),
            ),
            SizedBox(width: 10), // adds some space between the two buttons
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  count++;
                });
              },
              child: const Icon(Icons.add),
            )
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'Profile', 
          ),
        ],
      ),

      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Handle item 1 tap
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Handle item 2 tap
              },
            ),
          ],
        ),
      ),
    );
  }
}