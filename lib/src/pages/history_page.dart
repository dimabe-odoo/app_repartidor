import 'package:app_repatidor_v2/src/models/order_model.dart';
import 'package:app_repatidor_v2/src/pages/order_detail_page.dart';
import 'package:app_repatidor_v2/src/preferences/user_preference.dart';
import 'package:app_repatidor_v2/src/services/auth_service.dart';
import 'package:app_repatidor_v2/src/services/order_service.dart';
import 'package:async_builder/async_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/appbar/gf_appbar.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/components/button/gf_button_bar.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/getwidget.dart';

import 'home_page.dart';
import 'new_order_page.dart';

class HistoryPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HistoryPageState();
}

class HistoryPageState extends State<HistoryPage> {
  final orderService = new OrderService();
  final _prefs = new UserPreference();
  final auth = new AuthService();
  Future<List<OrderModel>> history;
  int currentPage = 2;

  @override
  void initState() {
    history = orderService.get_history();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(),
      body: history_list(),
      bottomNavigationBar:bottom()
    );
  }

  Widget bottom(){
    return BottomNavigationBar(
      backgroundColor: Color(0xff1f418b),
      currentIndex: currentPage,
      onTap: (value) {
        print(_prefs.active);
        if (value == 3) {
          setState(() {
            if (_prefs.active == true) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('¿Esta seguro que desea esta inactivo?'),
                    content:
                    Text('Esto significa que no recibira nuevos pedidos'),
                    actions: [
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                          },
                          child: Text("Cancelar")),
                      FlatButton(
                          onPressed: () {
                            setState(() {
                              _prefs.active = false;
                              auth.setInactive().then((value) =>
                                  Navigator.of(context, rootNavigator: true)
                                      .pop('dialog'));
                            });
                          },
                          child: Text("Confirmar"))
                    ],
                  );
                },
              );
            } else {
              _prefs.active = true;
              auth.setActive();
            }
          });
        } else if (value == 1) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => NewOrderPage(),
              ),
                  (route) => false);
        } else if (value == 0) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HomePage(),
              ),
                  (route) => false);
        } else if (value == 2) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => HistoryPage(),
              ),
                  (route) => false);
        }
      },
      fixedColor: Color(0xff1f418b),
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(FontAwesomeIcons.home, color: Color(0xff1f418b)),
          label: "Pedido en Curso",
        ),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.truck, color: Color(0xff1f418b)),
            label: "Pedido en Ruta"),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.dollarSign, color: Color(0xff1f418b)),
            label: "Mis Ventas"),
        BottomNavigationBarItem(
            icon: _prefs.active == true
                ? Icon(FontAwesomeIcons.solidCheckSquare,
                color: Color(0xff1f418b))
                : Icon(FontAwesomeIcons.checkSquare,
                color: Color(0xff1f418b)),
            label: "Activo")
      ],
    );
  }

  Widget appbar() {
    return GFAppBar(
      title: Text("Historial de Pedido"),
    );
  }

  Widget history_list() {
    return AsyncBuilder(
      future: history,
      waiting: (context) => Center(
        child: GFLoader(),
      ),
      retain: true,
      error: (context, error, stackTrace) => Center(child: GFLoader()),
      builder: (context, value) {
        return displayList(value);
      },
    );
  }

  Widget displayList(List<OrderModel> orders) {
    return ListView.separated(
      shrinkWrap: true,
        itemBuilder: (context, index) {
          return GFListTile(
            title: Text(
              "N° de Orden ${orders[index].orderName}",
              style: TextStyle(
                  color: Color(0xff1f418b), fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Cliente ${orders[index].clientName}"),
            description: Text(
              "Total \$ ${orders[index].total.toString().split('.')[0]}",
              style: TextStyle(
                  color: Color(0xff1f418b), fontWeight: FontWeight.bold),
            ),
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        },
        itemCount: orders.length);
  }
}
