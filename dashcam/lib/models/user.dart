class UserModel
{
  String name;
  String phone;

  UserModel({
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

  factory UserModel.fromMap(Map<String, dynamic> map)
  {
    return UserModel(
      name: map['name'],
      phone: map['phone'],
    );
  }
}