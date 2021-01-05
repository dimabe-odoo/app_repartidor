import 'package:shared_preferences/shared_preferences.dart';

class UserPreference {
  static final _instance = new UserPreference._internal();

  factory UserPreference(){
    return _instance;
  }

  UserPreference._internal();

  SharedPreferences _prefs;

  initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  get token => _prefs.getString('api-token');

  set token(String value) => _prefs.setString('api-token', value);

  get id => _prefs.getString('id');

  set id(String value) => _prefs.setString('id', value);

  get name => _prefs.getString('name');

  set name(String value) => _prefs.setString('name', value);

  get email => _prefs.getString('email');

  set email(String value) => _prefs.setString('email', value);

  get rut => _prefs.getString('rut');

  set rut(String value) => _prefs.setString('rut', value);

  get birthDay => _prefs.getString('birthDay');

  set birthDay(String value) => _prefs.setString('birthDay', value);

  get address => _prefs.getString('address');

  set address(String value) => _prefs.setString('address', value);

  get employeeId => _prefs.getString('employeeId');

  set employeeId(String value) => _prefs.setString('employeeId', value);

  get truck => _prefs.getString('truck');

  set truck(String value) => _prefs.setString('truck', value);

  get user => _prefs.getString('user_id');

  set user(String value) => _prefs.setString('user_id', value);

  get session => _prefs.getString('session');

  set session(String value) => _prefs.setString('session', value);

  get orderActive => _prefs.getString('orderActive');

  set orderActive(String value) => _prefs.setString('orderActive', value);

  get active => _prefs.getBool('active');

  set active(bool value) => _prefs.setBool('active', value);
  
  get urlImage => _prefs.getString('urlImage');

  set urlImage(String value) => _prefs.setString('urlImage', value);

  void clearSession(){
    _prefs.clear();
  }
}