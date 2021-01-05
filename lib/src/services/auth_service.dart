import 'dart:convert';
import 'package:app_repatidor_v2/src/preferences/user_preference.dart';
import 'package:app_repatidor_v2/src/services/base_service.dart';
import 'package:http/http.dart' as http;

class AuthService extends BaseService {
  final _prefs = new UserPreference();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final endpoint = "$url/api/login_truck";
    final data = {
      'params': {'user': email, 'password': password}
    };

    final resp = await http.post(endpoint,
        headers: {'content-type': 'Application/json'}, body: json.encode(data));

    if (isSuccessCode(resp.statusCode)) {
      final decodedResponse = json.decode(resp.body);
      if (decodedResponse.containsKey('result')) {
        _prefs.id = decodedResponse['result']['id'];
        _prefs.token = decodedResponse['result']['token'];
        _prefs.name = decodedResponse['result']['user'];
        _prefs.email = decodedResponse['result']['email'];
        _prefs.user = decodedResponse['result']['user_id'];
        _prefs.employeeId = decodedResponse['result']['employee_id'];

        if (decodedResponse['result']['session'] != null) {
          _prefs.session = decodedResponse['result']['session'];
          _prefs.truck = decodedResponse['result']['truck'];
        }
        return {'ok': true, 'message': 'Conectado correctamente'};
      }

      return {'ok': false, 'message': 'Credenciales inválidas'};
    }
    return null;
  }

  Future<void> setInactive() async {
    final endpoint = "$url/api/redo_truck";
    final data = {
      "params": {"session": _prefs.session, "orderId": _prefs.orderActive}
    };
    final resp = await http.post(endpoint,
        headers: {
          'content-type': 'Application/json',
          'Authorization': 'Bearer ' + _prefs.token
        },
        body: json.encode(data));
  }

  Future<void> setActive() async {
    final endpoint = "$url/api/set_active";
    final data = {
      "params": {"session": _prefs.session}
    };
    final resp = await http.post(endpoint,
        headers: {
          'content-type': 'Application/json',
          'Authorization': 'Bearer ' + _prefs.token
        },
        body: json.encode(data));
  }

  Future<bool> refreshToken() async {
    final endpoint = '$url/api/refresh-token';
    final params = {
      'params': {'email': _prefs.email}
    };
    final resp = await http.post(endpoint,
        headers: {'content-type': 'Application/json'},
        body: json.encode(params));
    final decodedResponse = json.decode(resp.body);
    if (decodedResponse.containsKey('result')) {
      _prefs.token = decodedResponse['result']['token'];
      return true;
    }
    return false;
  }

  Future<String> assignTruck(String truck) async {
    final endpoint = '$url/api/assign_truck';
    final params = {
      'params': {
        'truck': truck,
        'employee': _prefs.employeeId,
        'user': _prefs.user
      }
    };
    final resp = await http.post(endpoint,
        headers: {
          'content-type': 'Application/json',
          'Authorization': 'Bearer ' + _prefs.token
        },
        body: json.encode(params));
    if (isSuccessCode(resp.statusCode)) {
      final decodedResponse = json.decode(resp.body);
      if (decodedResponse.containsKey('result')) {
        print(decodedResponse['result']);
        if (decodedResponse['result'] ==
            "Ya existe una sesion activa con el camion $truck") {
          print(decodedResponse[0]);
          return decodedResponse['result'];
        } else {
          _prefs.truck = truck;
          _prefs.session = decodedResponse['result']['session_id'];
          return "Sesion iniciada";
        }
      }
    }
    return "";
  }

  Future<String> logout(String session) async {
    print(session);
    final endpoint = "$url/api/logout";
    var message = '';
    final params = {
      'params': {'session_id': session}
    };
    final resp = await http.post(endpoint,
        headers: {
          'content-type': 'Application/json',
        },
        body: json.encode(params));
    if (isSuccessCode(resp.statusCode)) {
      final decodedResponse = json.encode(resp.body);
      print(decodedResponse);
      if (decodedResponse.contains('result')) {
        message = decodedResponse;
        _prefs.clearSession();
        return message;
      }
    }
    return message;
  }
}
