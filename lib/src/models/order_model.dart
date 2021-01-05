import 'dart:convert';
import 'package:app_repatidor_v2/src/models/order_line_model.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

OrderModel orderModelFromJson(String str) =>
    OrderModel.fromJson(json.decode(str));

class OrderModel {
  OrderModel(
      {this.id ='',
        this.orderName = '',
        this.clientId = '',
        this.clientName = '',
        this.clientAddress = '',
        this.orderDescription = '',
        this.clientLatitude = 0.0,
        this.clientLongitude = 0.0,
        this.distance = '',
        this.total = 0.0,
        this.lines,
        this.state = '',
        this.polylines});

  String id;
  String orderName;
  String clientId;
  String clientName;
  String clientAddress;
  double clientLatitude;
  double clientLongitude;
  String state;
  String orderDescription;
  String distance;
  double total;
  List<OrderLineModel> lines;
  List<PointLatLng> polylines;

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
      id: json['id'],
      state: json['state'],
      clientLatitude: json['clientLatitude'],
      clientId: json['clientId'],
      clientLongitude: json['clientLongitude'],
      orderName: json['OrderName'],
      clientName: json['ClientName'],
      clientAddress: json['ClientAddress'],
      orderDescription: json['ShortDescription'],
      distance: json['Distance'],
      total: double.parse(json['Total']));

  factory OrderModel.fromJsonGet(Map<String , dynamic> json) {
    return OrderModel(
        id:json['result']['Order_Id'],
        orderName: json['result']['Order_Name']
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'clientLatitude': clientLatitude,
    'clientId':clientId,
    'clientLongitude': clientLongitude,
    'OrderName': orderName,
    'ClientName': clientName,
    'ClientAddress': clientAddress,
    'State':state,
    'orderDescription': orderDescription,
    'Distance': distance,
    'Total': total
  };
}
