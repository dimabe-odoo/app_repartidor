import 'dart:convert';

import 'package:flutter/material.dart';

class ProductModel {
  ProductModel({
    this.id,
    this.name ='',
    this.price = 0.0,
    this.isCat,
    this.qty = 0,
    this.stock = 0.0,
    this.imageProduct,
    this.isDis
  });

  String id;
  String name;
  double price;
  bool isDis;
  bool isCat;
  int qty;
  dynamic stock;
  FileImage imageProduct;

  factory ProductModel.fromJson(Map<String,dynamic> json) => ProductModel(
      id:json['id'],
      name: json['name'],
      price: json['price'],
      qty : json['qty'],
      stock: json['stock']
  );

  Map<String,dynamic> toJson() => {
    "id":id,
    "name":name,
    "price":price,
    "qty":qty,
    "stock":stock
  };
}