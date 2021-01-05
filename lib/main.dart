import 'dart:io';

import 'package:app_repatidor_v2/src/pages/home_page.dart';
import 'package:app_repatidor_v2/src/pages/login_page.dart';
import 'package:app_repatidor_v2/src/pages/new_client_dart.dart';
import 'package:app_repatidor_v2/src/pages/new_order_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:app_repatidor_v2/src/bloc/provider.dart';
import 'package:app_repatidor_v2/src/models/order_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app_repatidor_v2/src/preferences/user_preference.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  UserPreference prefs = new UserPreference();
  await prefs.initPrefs();
  runApp(MyApp());
  download();
}

void download() async {
  var path = (await getApplicationDocumentsDirectory()).path;
  var directory = new Directory(path);
  print(directory.path);
}

class MyApp extends StatelessWidget {
  var colors = const Color(0xff1f418b);
  var orders = new OrderModel();

  @override
  Widget build(BuildContext context) {
    return Provider(
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [const Locale('en', 'US'), const Locale('es', 'ES')],
        debugShowCheckedModeBanner: false,
        title: 'Somos JP',
        initialRoute: '/',
        routes: {
          '/': (BuildContext context) => HomePage(),
          '/login': (BuildContext context) => LoginPage(),
          '/neworder': (BuildContext context) => NewOrderPage(),
          '/newclient': (BuildContext context) => NewClientPage()
        },
        theme: ThemeData(
            primaryColor: colors, accentColor: Colors.deepPurpleAccent),
      ),
    );
  }
}
