import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:app_repatidor_v2/src/models/order_model.dart';
import 'package:app_repatidor_v2/src/pages/history_page.dart';
import 'package:app_repatidor_v2/src/pages/login_page.dart';
import 'package:app_repatidor_v2/src/pages/new_order_page.dart';
import 'package:app_repatidor_v2/src/pages/scan_page.dart';
import 'package:app_repatidor_v2/src/preferences/user_preference.dart';
import 'package:app_repatidor_v2/src/services/auth_service.dart';
import 'package:app_repatidor_v2/src/services/order_service.dart';
import 'package:app_repatidor_v2/src/utils/utils.dart';
import 'package:async_builder/async_builder.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:community_material_icon/community_material_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/appbar/gf_appbar.dart';
import 'package:getwidget/components/button/gf_icon_button.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:smart_select/smart_select.dart';
import 'package:workmanager/workmanager.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final _prefs = new UserPreference();
  final auth = new AuthService();
  Future<LocationData> current;
  Location location;
  LocationData currentLoc;
  var payment;
  var paymentId = 1;
  int currentPage = 0;
  int paymentMethod = 1;

  @override
  void initState() {
    super.initState();
    checkPrefs(context);
    payment = OrderService().getPaymenth();
    location = new Location();
    location.onLocationChanged.listen((event) {
      currentLoc = event;
    });

    setInitialLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar(context),
        body: _prefs.active == true
            ? body(context)
            : Center(
                child: AutoSizeText(
                  "Usted no se encuentra activo, no se le asignaran nuevos pedidos",
                  textAlign: TextAlign.center,
                ),
              ),
        bottomNavigationBar: bottom());
  }

  Widget bottom() {
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
                    title:
                        AutoSizeText('¿Esta seguro que desea esta inactivo?'),
                    content: AutoSizeText(
                        'Esto significa que no recibira nuevos pedidos'),
                    actions: [
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context, rootNavigator: true)
                                .pop('dialog');
                          },
                          child: AutoSizeText("Cancelar")),
                      FlatButton(
                          onPressed: () {
                            setState(() {
                              _prefs.active = false;
                              auth.setInactive().then((value) =>
                                  Navigator.of(context, rootNavigator: true)
                                      .pop('dialog'));
                            });
                          },
                          child: AutoSizeText("Confirmar"))
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
                : Icon(FontAwesomeIcons.checkSquare, color: Color(0xff1f418b)),
            label: "Activo")
      ],
    );
  }

  Widget body(BuildContext context) {
    return AsyncBuilder(
      waiting: (context) => Center(
        child: GFLoader(
          type: GFLoaderType.square,
        ),
      ),
      future: current,
      builder: (context, LocationData value) {
        var order = OrderService().getOrders(value.latitude, value.longitude);
        return order != null
            ? orderView(context, order, value)
            : Center(
                child: AutoSizeText("No hay nuevo pedido pedidos"),
              );
      },
    );
  }

  AsyncBuilder orderView(
      BuildContext context, Future<OrderModel> order, LocationData current) {
    return AsyncBuilder(
      future: order,
      error: (context, error, stackTrace) => Center(
        child: AutoSizeText("No hay nuevo pedido pedidos"),
      ),
      waiting: (context) => Center(
        child: GFLoader(type: GFLoaderType.android),
      ),
      builder: (context, value) {
        return value != null
            ? card(context, value, current,
                maps.LatLng(value.clientLatitude, value.clientLongitude))
            : Center(
                child: AutoSizeText("No hay nuevo pedido pedidos"),
              );
      },
    );
  }

  Widget card(BuildContext context, OrderModel order, LocationData current,
      maps.LatLng destiny) {
    print(order.state);
    return GFCard(
      title: GFListTile(
          title: Align(
        child: AutoSizeText(
          "Pedido Activo",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        alignment: Alignment.center,
      )),
      content: cardDescription(context, order),
      buttonBar: GFButtonBar(
        children: [
          order.state == 'onroute'
              ? GFButton(
                  onPressed: () {
                    setState(() {
                      print(order.clientAddress);
                      showMap(destiny, current);
                    });
                  },
                  child: Text("Ir al Mapa"),
                )
              : GFButton(
                  onPressed: () {
                    setState(() {
                      OrderService().acceptedorder(
                          current.latitude, current.longitude, order);
                    });
                  },
                  child: Text("Aceptar"),
                  color: GFColors.SUCCESS,
                ),
          order.state == 'onroute'
              ? GFButton(
                  child: AutoSizeText("Finalizar"),
                  onPressed: () {
                    setState(() {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Seleccione metodo de pago"),
                            content: AsyncBuilder(
                              error: (context, error, stackTrace) =>
                                  Text("Error"),
                              waiting: (context) => Center(
                                child: GFLoader(),
                              ),
                              future: payment,
                              builder: (context, List<S2Choice<int>> list) {
                                return Container(
                                  child: SmartSelect.single(
                                    title: "Seleccione un metodo de pago",
                                    choiceItems: list,
                                    value: paymentId,
                                    onChange: (value) {
                                      setState(() {
                                        paymentId = value.value;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      print(paymentId);
                                      OrderService().make_done(
                                          _prefs.orderActive,
                                          paymentId.toString());
                                      _prefs.active = false;
                                      auth.setInactive();
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("Continuar Vendiendo"),
                                            content: Text(
                                                "¿Desea continuar vendiendo?"),
                                            actions: <Widget>[
                                              FlatButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _prefs.active = false;
                                                      auth.setInactive();
                                                      Navigator.pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  super.widget),
                                                          (route) => false);
                                                    });
                                                  },
                                                  child: Text("No")),
                                              FlatButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _prefs.active = false;
                                                      auth.setActive();
                                                      Navigator.pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (BuildContext
                                                                      context) =>
                                                                  super.widget),
                                                          (route) => false);
                                                    });
                                                  },
                                                  child: Text("Si"))
                                            ],
                                          );
                                        },
                                      );
                                    });
                                  },
                                  child: Text("Seleccionar"))
                            ],
                          );
                        },
                      );
                    });
                  },
                )
              : GFButton(
                  onPressed: () {
                    setState(() {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title:
                                Text("¿Esta seguro de cancelar este pedido?"),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                    });
                                  },
                                  child: Text("No")),
                              FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      OrderService().cancelOrder(order.id);
                                    });
                                  },
                                  child: Text("Si"))
                            ],
                          );
                        },
                      );
                    });
                  },
                  child: Text('Cancelar'),
                  color: GFColors.DANGER),
          order.state == 'onroute'
              ? GFButton(
                  onPressed: () {
                    setState(() {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title:
                                Text("¿Esta seguro de cancelar este pedido?"),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      Navigator.of(context, rootNavigator: true)
                                          .pop('dialog');
                                    });
                                  },
                                  child: Text("No")),
                              FlatButton(
                                  onPressed: () {
                                    setState(() {
                                      OrderService().cancelOrder(order.id);
                                    });
                                  },
                                  child: Text("Si"))
                            ],
                          );
                        },
                      );
                    });
                  },
                  child: Text('Cancelar'),
                  color: GFColors.DANGER)
              : SizedBox(
                  height: 20,
                )
        ],
      ),
    );
  }

  Widget cardDescription(BuildContext context, OrderModel order) {
    print(order.clientName);
    return Column(
      children: <Widget>[
        GFListTile(
          avatar: Icon(FontAwesomeIcons.userAlt, color: Color(0xff1f418b)),
          title: Text("Cliente:",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          description: Text(order.clientName),
        ),
        Divider(),
        GFListTile(
          avatar: Icon(
            FontAwesomeIcons.addressBook,
            color: Color(0xff1f418b),
          ),
          title: Text("Direccion:",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          description: Text(order.clientAddress),
        ),
        Divider(),
        GFListTile(
          avatar: Icon(FontAwesomeIcons.dollarSign, color: Color(0xff1f418b)),
          title: Text("Total:",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          description: Text('\$ ${order.total.toString().split('.')[0]}'),
        ),
        cardProducts(context, order)
      ],
    );
  }

  Widget cardProducts(BuildContext context, OrderModel order) {
    return GFCard(
        elevation: 0,
        title: GFListTile(
          title: Align(
            child: Text("Detalle"),
            alignment: Alignment.center,
          ),
        ),
        content: ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, index) {
            var subtotal =
                order.lines[index].priceUnit.toInt() * order.lines[index].qty;
            return GFListTile(
              title: Text(order.lines[index].productName),
              avatar: Text(order.lines[index].qty.toString()),
              description: Text(subtotal.toString()),
            );
          },
          itemCount: order.lines.length,
        ));
  }

  Widget appBar(BuildContext context) {
    return GFAppBar(
      title: Text("Bienvenido"),
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => ScanPage(),
              ),
              (route) => false);
        },
        icon: Icon(FontAwesomeIcons.qrcode),
      ),
      automaticallyImplyLeading: true,
      actionsIconTheme: IconThemeData.fallback(),
      actions: <Widget>[
        PopupMenuButton<String>(
          icon: Icon(
            Icons.menu,
            color: Colors.white,
          ),
          onSelected: handleClick,
          itemBuilder: (context) {
            return {'Cerrar Session'}.map((String e) {
              return PopupMenuItem<String>(
                value: e,
                child: GFButton(
                  icon: Icon(Icons.logout),
                  text: "Cerrar Sesion",
                  onPressed: () {
                    setState(() {
                      print(_prefs.token);
                      auth.logout(_prefs.session);
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                          (route) => false);
                    });
                  },
                  type: GFButtonType.transparent,
                ),
              );
            }).toList();
          },
        )
      ],
    );
  }

  handleClick(String value) {
    print(value);
    switch (value) {
      case 'Cerrar Session':
        auth
            .logout(_prefs.session)
            .then((value) => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
                (route) => false));

    }
  }

  showMap(maps.LatLng destiny, LocationData current) async {
    final availableMaps = await MapLauncher.installedMaps;
    availableMaps.first.showDirections(
        destination: Coords(destiny.latitude, destiny.longitude),
        origin: Coords(current.latitude, current.longitude));
  }

  checkPrefs(BuildContext context) {
    print(_prefs.truck);
    if (_prefs.token == null || _prefs.token == '') {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => LoginPage(),
          ),
          (route) => false);
    } else if (_prefs.truck == null || _prefs.truck == '') {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => ScanPage(),
          ),
          (Route<dynamic> route) => false);
    }
  }

  setInitialLocation() async {
    current = location.getLocation();
  }
}
