import 'dart:convert';

class OrderLineModel{
  OrderLineModel({
    this.id,
    this.imageUrl = '',
    this.productId = 0,
    this.productName = '',
    this.priceUnit = 0.0,
    this.qty = 0
  });

  int id;
  String imageUrl;
  int productId;
  String productName;
  int qty;
  double priceUnit;

}