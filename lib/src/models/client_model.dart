import 'dart:convert';

import 'package:app_repatidor_v2/src/models/product_model.dart';
class ClientModel {
  ClientModel(
      {this.id,
        this.name = '',
        this.longitude = 0.0,
        this.latitude = 0.0,
        this.address = '',
        this.phone = '',
        this.pricelist
      });

  String id;
  String name;
  String address;
  double latitude;
  double longitude;
  String phone;
  List<ProductModel> pricelist;

  factory ClientModel.fromJson(Map<String,dynamic> json_data) => ClientModel(
      id: json_data['id'],
      name : json_data['name'],
      longitude: double.parse(json_data['longitude']),
      latitude: double.parse(json_data['latitude']),
      address: json_data['address'],
      phone: json_data['phone'],
      pricelist: json.decode(json_data['pricelist'])
  );

  Map<String, dynamic> toJson() {
    var list = new List();
    for (var price in pricelist) {
      list.add(json.encode(price));
    }
    return {
      "id": id,
      "name": name,
      "longitude": longitude,
      "latitude": latitude,
      "phone": phone,
      "address": address,
      "pricelist": list
    };
  }

}
