class ContactModel
{
  String name;
  String phone;

  ContactModel({
    required this.name,
    required this.phone,
  });

  Map<String, dynamic> toMap()
  {
    return {
      'name': name,
      'phone': phone,
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map)
  {
    return ContactModel(
      name: map['name'],
      phone: map['phone'],
    );
  }
}