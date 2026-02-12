import 'package:flutter/material.dart';
import 'package:test_flutter_app/testing_database/contact.dart';
import 'package:test_flutter_app/testing_database/contact_repository.dart';
import 'package:test_flutter_app/testing_database/contact_form_widget.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   //build method - main method that returns our main widget and that will be called anytime Flutter needs
//   // to REBUILD the UI (e.g. when data changes or after some user interaction)
//   Widget build(BuildContext context) { // main method that returns main widget of our app 
//     return MaterialApp(
//       title: 'MyApp',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), // theme of the app (i.e. color scheme)
//       ),
//       home: const ContactPage(),
//         );
//   }
// }

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => ContactPageState();
}

class ContactPageState extends State<ContactPage> {
  List<Contact> contacts = []; 

  Future<void> loadContacts() async {
    final contacts = await ContactRepository.getContacts();
    setState(() {
      this.contacts = contacts; 
    });
  }

  void showContactFormDialog(Contact? contact) async {
    final title = contact == null ? 'Add Contact' : 'Edit Contact';
    final result = await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: ContactFormWidget(contact: contact),
        );
      },
    );

    if (result != null) {
      await loadContacts();
    }
  }

  void _deleteContact(int id) async {
    await ContactRepository.deleteContact(id);
    loadContacts(); 
  }

  @override
  void initState() {
    super.initState();
    loadContacts(); 
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.lightBlueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),

          child: ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      contact.name[0], 
                      style: const TextStyle(color: Colors.white)
                    ),
                  ),
                  title: Text(
                    contact.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(contact.email),
                  onTap: () {
                    // Handle contact tap (e.g., navigate to contact details)
                    showContactFormDialog(contact); // show the contact form dialog with the selected contact (for editing)
                  },
          
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _deleteContact(contact.id!); // delete the contact (the "!" is used to assert that contact.id is not null)
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}