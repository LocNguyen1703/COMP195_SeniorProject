import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test_flutter_app/testing_database/contact.dart';
import 'package:test_flutter_app/testing_database/contact_repository.dart'; 

class ContactFormWidget extends StatefulWidget {
  final Contact? contact; // if contact is null, we're adding a new contact; if it's not null, we're editing an existing contact
  const ContactFormWidget({super.key, this.contact}); //this is kinda like a constructor for new ContactFormWidget object 

  @override
  State<ContactFormWidget> createState() => ContactFormWidgetState();
}

class ContactFormWidgetState extends State<ContactFormWidget> {
  final _formKey = GlobalKey<FormState>();
  String name = "", email = "", phone = "", address = "";

  @override
  void initState() {
    super.initState();
    name = widget.contact?.name ?? ""; // if widget.contact is not null, use its name; otherwise, use an empty string
    email = widget.contact?.email ?? "";
    phone = widget.contact?.phone ?? "";
    address = widget.contact?.address ?? "";
  }

  void _save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); 
      final contact = Contact(
        id: widget.contact?.id, // if we're editing an existing contact, we want to keep the same id
        name: name, 
        email: email,
        phone: phone,
        address: address,
      );

      if (widget.contact != null) {
        await ContactRepository.updateContact(contact);
      } else {
      await ContactRepository.addContact(contact);
      }
      
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20.0),
            TextFormField(
              initialValue: name,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (v) => v == null || v.isEmpty ? 'Please enter a name' : null,
              onSaved: (v) => name = v ?? '',
            ),
            TextFormField(
              initialValue: email,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (v) => v == null || v.isEmpty ? 'Please enter an email' : null,
              onSaved: (v) => email = v ?? '',
            ),
            TextFormField(
              initialValue: phone,
              decoration: const InputDecoration(labelText: 'Phone'),
              validator: (v) => v == null || v.isEmpty ? 'Please enter a phone number' : null,
              onSaved: (v) => phone = v ?? '',
            ),
            TextFormField(
              initialValue: address,
              decoration: const InputDecoration(labelText: 'Address'),
              validator: (v) => v == null || v.isEmpty ? 'Please enter an address' : null,
              onSaved: (v) => address = v ??  '',
            ),

            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}