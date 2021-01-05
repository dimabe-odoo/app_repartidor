import 'dart:convert';

class UserModel{

  UserModel({
    this.id,
    this.name = '',
    this.birthDay = '',
    this.email = '',
    this.rut = '',
    this.employeeId = ''
  });

  String id;
  String name;
  String email;
  String birthDay;
  String rut;
  String employeeId = '';

  factory UserModel.fromJson(Map<String,dynamic> json) => UserModel(
      id: json["id"],
      name: json["name"],
      email: json["email"],
      birthDay: json["birth_day"],
      rut: json["rut"],
      employeeId: json["employeeId"]
  );

  Map<String,dynamic> toJson() => {
    "name": name,
    "email":email,
    "rut":rut,
    "birth_day":birthDay,
    "employeeId":employeeId
  };
}