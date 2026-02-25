import 'package:flutter/material.dart';
import 'package:test_flutter_app/ai_chat_handler/ai_chat_page.dart';
import 'package:test_flutter_app/new_app.dart';
import 'package:test_flutter_app/new_page.dart';
import 'package:test_flutter_app/testing_database/contact_page.dart';

/*handy VSCode shortcuts for refactoring: 
Alt + Click: Place cursors at arbitrary, non-consecutive locations in the file.
Ctrl + Alt + Down / Up: Insert a cursor directly below or above the current line, useful for consecutive lines.
Ctrl + D: Select the word under the cursor, or add a cursor to the next occurrence of the current selection (one by one).
Ctrl + Shift + L: Select all occurrences of the currently highlighted text in the document and add a cursor to each, which is great for mass changes.
Shift + Alt + Down / Up: Copies the current line down or up and places a cursor on the new line.
Shift + Alt + I: After making a multi-line selection (e.g., using Shift and arrow keys), this shortcut places a cursor at the end of each selected
*/

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData( 
        colorScheme: .fromSeed(seedColor: Colors.yellowAccent), // This is the color theme of your application.
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentPage = 0; 
  final GlobalKey<HomePageState> homeKey = GlobalKey<HomePageState>();
  final GlobalKey<ContactPageState> contactKey = GlobalKey<ContactPageState>();
  final GlobalKey<AIChatPageState> aiChatKey = GlobalKey<AIChatPageState>();
  
  final ScrollController scrollController = ScrollController();
  
  List<Widget> pages = [];
  
  Widget? _buildFAB() {
    switch (currentPage) {
    case 0:
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () {
              homeKey.currentState?.decrement();
            }, 
            child: const Icon(Icons.remove),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              homeKey.currentState?.increment();
            },
            child: const Icon(Icons.add),
          ),
        ],
      );

    case 1:
      return FloatingActionButton(
        onPressed: () {
          contactKey.currentState?.showContactFormDialog(null);
        },
        child: const Icon(Icons.add),
      );

    default:
      return null;
    }
  }

  Widget? _buildDrawer() {
    switch(currentPage) {
      case != 2: 
        return Drawer(
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
        );

      case 2:
        return Drawer(
          child: ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            itemCount: aiChatKey.currentState?.conversations.length ?? 0,
            itemBuilder: (context, index) {
              final title = aiChatKey.currentState?.conversations[index].title ?? 'Conversation $index';
              return ListTile(
                title: Text(title),
                onTap: () {
                  // Handle conversation tap (e.g., load the conversation in the main area)
                  setState(() {
                    aiChatKey.currentState?.currentConversationId = aiChatKey.currentState?.conversations[index].id;
                    aiChatKey.currentState?.loadMessages(aiChatKey.currentState?.currentConversationId ?? -1); // load messages for the selected conversation (using -1 as a placeholder for no conversation)
                  });
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Handle conversation deletion
                    aiChatKey.currentState?.deleteConversation(aiChatKey.currentState?.conversations[index].id??-1);
                  },
                ),
              );
            },
          ),
          // child: FutureBuilder<List<Conversation>>(
            // future: aiChatKey.currentState?.loadConversations()
        );

      default:
        return null;
    }
  }

  @override
  void initState() {
    super.initState();

    pages = [
      HomePage(key: homeKey),
      ContactPage(key: contactKey),
      // const NewPage(),
      AIChatPage(key: aiChatKey),

    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: IndexedStack(
        index: currentPage,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPage,
        onTap: (value) {
          setState(() {
            currentPage = value;
          });
        },
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

      floatingActionButton: _buildFAB(),

      // drawer: Drawer(
      //   child: ListView(
      //     padding: EdgeInsets.zero,
      //     children: [
      //       DrawerHeader(
      //         decoration: BoxDecoration(
      //           color: Theme.of(context).colorScheme.primary,
      //         ),
      //         child: Text('Drawer Header'),
      //       ),
      //       ListTile(
      //         title: Text('Item 1'),
      //         onTap: () {
      //           // Handle item 1 tap
      //         },
      //       ),
      //       ListTile(
      //         title: Text('Item 2'),
      //         onTap: () {
      //           // Handle item 2 tap
      //         },
      //       ),
      //     ],
      //   ),
      // ),

      drawer: _buildDrawer(),
    );
  }
}


