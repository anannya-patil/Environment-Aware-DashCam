import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/contact.dart';

class StorageService
{
  static const String userKey = "user";
  static const String contactsKey = "contacts";

  //user

  static Future<void> saveUser(UserModel user) async
  {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(userKey, jsonEncode(user.toMap()));
  }

  static Future<UserModel?> getUser() async
  {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(userKey);

    if (data == null) return null;

    return UserModel.fromMap(jsonDecode(data));
  }

  //contacts

  static Future<void> saveContacts(List<ContactModel> contacts) async
  {
    final prefs = await SharedPreferences.getInstance();

    List<String> encoded =
        contacts.map((c) => jsonEncode(c.toMap())).toList();

    prefs.setStringList(contactsKey, encoded);
  }

  static Future<List<ContactModel>> getContacts() async
  {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(contactsKey);

    if (data == null) return [];

    return data
        .map((e) => ContactModel.fromMap(jsonDecode(e)))
        .toList();
  }
}