import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../utils/storage_service.dart';

class AddContactPage extends StatefulWidget {

  final ContactModel? existingContact;
  final int? index;

  const AddContactPage({super.key, this.existingContact, this.index});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {

  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.existingContact != null) {
      nameController.text = widget.existingContact!.name;
      phoneController.text = widget.existingContact!.phone;
    }
  }

  void saveContact() async {

    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) return;

    List<ContactModel> contacts =
        await StorageService.getContacts();

    if (widget.index != null) {
      contacts[widget.index!] =
          ContactModel(name: name, phone: phone);
    } else {
      contacts.add(ContactModel(name: name, phone: phone));
    }

    await StorageService.saveContacts(contacts);

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingContact == null
            ? "Add Contact"
            : "Edit Contact"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: "Phone"),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: saveContact,
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}