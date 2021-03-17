import 'package:app_repartidor_v3/src/bloc/provider.dart';
import 'package:app_repartidor_v3/src/models/order_model.dart';
import 'package:app_repartidor_v3/src/pages/home_page.dart';
import 'package:app_repartidor_v3/src/pages/login_page.dart';
import 'package:app_repartidor_v3/src/pages/new_client_page.dart';
import 'package:app_repartidor_v3/src/pages/new_order_page.dart';
import 'package:app_repartidor_v3/src/pages/scan_page.dart';
import 'package:app_repartidor_v3/src/preferences/user_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  UserPreference prefs = new UserPreference();
  await prefs.initPrefs();
  runApp(MyApp());
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
          '/scan' : (BuildContext context) => ScanPage(),
          '/home' : (BuildContext context) => HomePage(),
          '/new_client' : (BuildContext context) => NewClientPage(),
          '/new_order' : (BuildContext context) => NewOrderPage(),

        },
        theme: ThemeData(
            primaryColor: colors, accentColor: Colors.deepPurpleAccent),
      ),
    );
  }
}
