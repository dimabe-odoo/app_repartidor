
import 'dart:convert';
import 'dart:io' as IO;
import 'dart:typed_data';
import 'package:app_repatidor_v2/src/models/product_model.dart';
import 'package:app_repatidor_v2/src/preferences/user_preference.dart';
import 'package:app_repatidor_v2/src/services/base_service.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ProductService extends BaseService{
  final _prefs = new UserPreference();

  Future<List<ProductModel>> getProduct() async{
    final endpoint = '$url/api/get_product_truck';
    final data = {
      "params":{

      }
    };
    final respond = await http.post(endpoint,headers: {
      'content-type':'Application/json',
      'Authorization': 'Bearer '+_prefs.token
    },
        body: json.encode(data)
    );
    if(isSuccessCode(respond.statusCode)){
      final decodedResponde = json.decode(respond.body);
      final List<ProductModel> result = new List();
      for(var item in decodedResponde['result']){
        result.add(ProductModel(
            id: item['Id'],
            name: item['ProductName'],
            isCat: item['isCat'] == 'true'
        ));
        _createFileString(item['ImageBase64'],item['ProductName']);
      }
      return result;
    }
    return null;
  }


  Future<void> _createFileString(String base64,String productName) async{
    Uint8List bytes = base64Decode(base64);
    String dir = (await getApplicationDocumentsDirectory()).path;
    print(dir);
  }
}