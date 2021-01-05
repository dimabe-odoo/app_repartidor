import 'dart:convert';
import 'package:app_repatidor_v2/src/preferences/user_preference.dart';
import 'package:app_repatidor_v2/src/services/base_service.dart';
import 'package:app_repatidor_v2/src/utils/utils.dart';
import 'package:http/http.dart' as http;
import 'package:smart_select/smart_select.dart';

class CommuneService extends BaseService {
  final _prefs = UserPreference();

  Future<List<S2Choice<int>>> getCommunes() async {
    final endpoint = "$url/api/get_communes";
    final resp = await http.post(endpoint,
        headers: {
          'content-type': 'Application/json',
          'Authorization': 'Bearer ' + _prefs.token
        },
        body: json.encode({'params': {}}));
    if (isSuccessCode(resp.statusCode)) {
      final decodedResponse = json.decode(resp.body);
      print(decodedResponse);
        final res = decodedResponse['result'];
        final List<S2Choice<int>> result = new List();
        for (var r in res) {
          result.add(S2Choice(value: r['id'], title: r['name'].toString()));
        }
        return result;
      }
    
    return null;
  }
}
