import 'dart:convert';

import 'package:app_repatidor_v2/src/models/order_line_model.dart';
import 'package:app_repatidor_v2/src/models/order_model.dart';
import 'package:app_repatidor_v2/src/models/product_model.dart';
import 'package:app_repatidor_v2/src/preferences/user_preference.dart';
import 'package:app_repatidor_v2/src/services/base_service.dart';
import 'package:app_repatidor_v2/src/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:smart_select/smart_select.dart';

class OrderService extends BaseService {
  final _prefs = UserPreference();
  PolylinePoints polylinePoints;

  Future<void> createOrder(
      int clientId, List<ProductModel> list, String payment) async {
    final endpoint = "$url/api/create_mobile";
    List<String> listItem = new List();
    for (var item in list) {
      if (item.qty > 0 && item.qty != null) {
        listItem.add(json.encode(item));
      }
    }
    final data = {
      "params": {
        "customer_id": clientId,
        "product_ids": listItem,
        "session": _prefs.session,
        "payment": payment
      }
    };
    final resp = await http.post(endpoint,
        headers: {
          'content-type': 'Application/json',
          'Authorization': 'Bearer ' + _prefs.token,
        },
        body: json.encode(data));
  }

  Future<void> acceptedorder(double lat, double lon, OrderModel order) async {
    final endpoint = '$url/api/accept_order';
    final data = {
      "params": {"latitude": lat, "longitude": lon, "mobile_id": order.id}
    };
    final resp = await http.post(endpoint,
        headers: {
          'content-type': 'Application/json',
          'Authorization': 'Bearer ' + _prefs.token,
        },
        body: json.encode(data));
  }

  Future<void> cancelOrder(String id) async {
    final endpoint = '$url/api/cancel';
    final data = {
      "params": {"mobile_id": int.parse(id)}
    };
    final resp = await http.post(endpoint,
        headers: {
          'content-type': "Application/json",
          'Authorization': "Bearer " + _prefs.token
        },
        body: json.encode(data));
  }

  Future<OrderModel> getOrders(double lat, double lot) async {
    final endpoint = "$url/api/mobile_orders";
    final data = {
      "params": {'latitude': lat, 'longitude': lot, 'session': _prefs.session}
    };
    OrderModel orderObject;
    final resp = await http.post(endpoint,
        headers: {
          'content-type': 'Application/json',
          'Authorization': 'Bearer ' + _prefs.token,
        },
        body: json.encode(data));
    if (isSuccessCode(resp.statusCode)) {
      final decodedResponse = json.decode(resp.body);
      _prefs.orderActive = decodedResponse['result']['Order_Id'];
    }
    final getorder = "$url/api/order";
    final params = {
      "params": {"latitude": lat, "longitude": lot, "id": _prefs.orderActive}
    };
    final respond = await http.post(getorder,
        headers: {
          'content-type': 'Application/json',
          'Authorization': 'Bearer ' + _prefs.token,
        },
        body: json.encode(params));
    if (isSuccessCode(respond.statusCode)) {
      final decodedResponse_order = json.decode(respond.body);
      print(decodedResponse_order);
      if (decodedResponse_order.containsKey('result')) {
        final res = decodedResponse_order['result'];
        for (var order in res) {
          List<OrderLineModel> lines = new List();
          for (var line in order['Lines']) {
            lines.add(OrderLineModel(
                id: line['id'],
                productId: line['productId'],
                productName: line['productName'],
                priceUnit: line['priceUnit'],
                qty: line['qty']));
          }
          orderObject = OrderModel(
              id: order['OrderId'].toString(),
              orderName: order['OrderName'],
              distance: order['Distance'],
              clientName: order['ClientName'],
              clientAddress: order['ClientAddress'],
              clientLatitude: order['ClientLatitude'],
              clientLongitude: order['ClientLongitude'],
              state: order['State'],
              total: order['Total'],
              lines: lines);
        }
      }
      return orderObject;
    }
    return null;
  }

  Future<List<S2Choice<int>>> getPaymenth() async {
    final endpoint = "$url/api/paymentmethod";
    final data = {"params": {}};
    final resp = await http.post(endpoint,
        headers: {
          'content-type': 'Application/json',
          'Authorization': 'Bearer ' + _prefs.token,
        },
        body: json.encode(data));
    if (isSuccessCode(resp.statusCode)) {
      final decodedResponse = json.decode(resp.body);
      if (decodedResponse.containsKey('result')) {
        var res = decodedResponse['result'];
        List<S2Choice<int>> result = new List();
        for (var payment in res) {
          print(payment);
          result.add(S2Choice(value: payment['Id'], title: payment['Name']));
        }
        return result;
      }
    }
    return new List();
  }

  Future<OrderModel> getOrder(double lat, double lot, String id) async {
    final endpoint = "$url/api/order";
    final data = {
      "params": {"latitude": lat, "longitude": lot, "id": id}
    };
    final resp = await http.post(endpoint,
        headers: {
          'content-type': 'Application/json',
          'Authorization': 'Bearer ' + _prefs.token,
        },
        body: json.encode(data));
    if (isSuccessCode(resp.statusCode)) {
      final decodedResponse = json.decode(resp.body);
      print(decodedResponse);
      var order;

      order = OrderModel(
          id: decodedResponse['result'][0]['OrderId'].toString(),
          orderName: decodedResponse['result'][0]['OrderName'],
          distance: decodedResponse['result'][0]['Distance'],
          clientAddress: decodedResponse['result'][0]['ClientAddress'],
          clientLatitude: decodedResponse['result'][0]['ClientLatitude'],
          clientLongitude: decodedResponse['result'][0]['ClientLongitude'],
          total: decodedResponse['result'][0]['Total']);
      return order;
    }
    return null;
  }

  Future<String> make_done(String id, String payment_id) async {
    final endpoint = '$url/api/sale/make_done';
    final data = {
      "params": {"mobile_id": id, "payment_id": payment_id}
    };
    final resp = await http.post(endpoint,
        headers: {
          'content-type': 'Application/json',
          'Authorization': 'Bearer ' + _prefs.token,
        },
        body: json.encode(data));
    if (isSuccessCode(resp.statusCode)) {
      final decoded = json.decode(resp.body);

      _prefs.orderActive = '';
      return decoded['result'];
    }
    return null;
  }

  Future<List<OrderModel>> get_history() async {
    final endpoint = '$url/api/my_orders';
    final data = {
      "params": {"employee": int.parse(_prefs.employeeId)}
    };
    final resp = await http.post(endpoint,
        headers: {
          'content-type': 'Application/json',
          'Authorization': 'Bearer ' + _prefs.token
        },
        body: json.encode(data));
    if (isSuccessCode(resp.statusCode)) {
      final decoded = json.decode(resp.body);
      final res = decoded['result'];
      print(res.length);
      List<OrderModel> result = new List();
      for (var r in res) {
        result.add(OrderModel(
            clientName: r['customerName'],
            orderName: r['name'],
            total: r['total']));
      }
      return result;
    }
    return null;
  }
  
}
