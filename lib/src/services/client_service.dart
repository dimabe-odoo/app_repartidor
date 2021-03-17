import 'package:app_repartidor_v3/src/models/client_model.dart';
import 'package:app_repartidor_v3/src/models/product_model.dart';
import 'package:app_repartidor_v3/src/preferences/user_preference.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_select/smart_select.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'base_service.dart';
import 'package:path_provider/path_provider.dart';

class ClientService extends BaseService {
  final _prefs = new UserPreference();

  Future<List<S2Choice<int>>> getClient(String truck) async {
    final endpoint = Uri.parse("$url/api/clients");
    final data = {
      "params": {"truck": truck}
    };
    final resp = await http.post(endpoint,
        headers: {
          'content-type': 'Application/json',
          'Authorization': 'Bearer ' + _prefs.token,
        },
        body: json.encode(data));
    if (isSuccessCode(resp.statusCode)) {
      final decodedResponde = json.decode(resp.body);
      final List<S2Choice<int>> result = new List();
      for (var dec in decodedResponde['result']) {
        final List<ProductModel> prices = new List();
        _prefs.urlImage = (await getApplicationDocumentsDirectory()).path + "/";
        result.add(S2Choice(value: dec['Id'], title: dec['Name']));
      }
      ;
      return result;
    }
    return null;
  }

  Future<ClientModel> getClientId(int id) async {
    final uri = "$url/api/client";
    final endpoint = Uri.parse(uri);
    final data = {
      "params": {"client": id}
    };
    final resp = await http.post(endpoint,
        headers: {
          'content-type': 'Application/json',
          'Authorization': 'Bearer ' + _prefs.token,
        },
        body: json.encode(data));
    if(isSuccessCode(resp.statusCode)){
      final decoded = json.decode(resp.body);
      final client = ClientModel(
          id:decoded['result']['id'].toString(),
          name: decoded['result']['display_name'],
          address: decoded['result']['street']
      );
      return client;
    };
    return null;
  }

  Future<dynamic> createClient(String name, String email, int phoneNumber,
      int comummne_id, String address, LatLng result, String vat) async {
    final uri = "$url/api/create_client";
    final endpoint = Uri.parse(uri);
    final data = {
      "params": {
        "name": name,
        "email": email,
        "phoneNumber": phoneNumber,
        "commune_id": comummne_id,
        "address": address,
        "latitude": result.latitude,
        "longitude": result.longitude,
        "vat": vat
      }
    };
    final resp = await http.post(endpoint,
        headers: {
          'content-type': 'Application/json',
          'Authorization': 'Bearer ' + _prefs.token,
        },
        body: json.encode(data));
    if (isSuccessCode(resp.statusCode)) {
      final decodedResponde = json.decode(resp.body);
      print(decodedResponde['result']);
      return decodedResponde['result'];
    }
    return 0;
  }

  Future<List> getPrice(int client) async {
    final uri = "$url/api/prices";
    final endpoint = Uri.parse(uri);
    final data = {
      "params": {"client_id": client, "truck": _prefs.truck}
    };
    final resp = await http.post(endpoint,
        headers: {
          'content-type': 'Application/json',
          'Authorization': 'Bearer ' + _prefs.token,
        },
        body: json.encode(data));
    if (isSuccessCode(resp.statusCode)) {
      final decodedResponse = json.decode(resp.body);
      final List<ProductModel> prices = new List();
      for (var dec in decodedResponse['result']) {
        prices.add(ProductModel(
            id: dec['Product_Id'].toString(),
            isCat: dec['isCat'],
            isDis: dec['is_Dist'],
            stock: dec['Stock'],
            name: dec['Product_Name'],
            price: dec['Price']));
      }
      return prices;
    }
    return null;
  }
}
