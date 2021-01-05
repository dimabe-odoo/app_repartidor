import 'dart:convert';

import 'package:app_repatidor_v2/src/models/client_model.dart';
import 'package:app_repatidor_v2/src/models/product_model.dart';
import 'package:app_repatidor_v2/src/pages/new_client_dart.dart';
import 'package:app_repatidor_v2/src/preferences/user_preference.dart';
import 'package:app_repatidor_v2/src/services/auth_service.dart';
import 'package:app_repatidor_v2/src/services/client_service.dart';
import 'package:app_repatidor_v2/src/services/order_service.dart';
import 'package:app_repatidor_v2/src/utils/utils.dart';
import 'package:async_builder/async_builder.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cool_stepper/cool_stepper.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_number_picker/flutter_number_picker.dart';
import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/colors/gf_color.dart';
import 'package:getwidget/components/avatar/gf_avatar.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/components/button/gf_button_bar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:getwidget/getwidget.dart';
import 'package:getwidget/shape/gf_avatar_shape.dart';
import 'package:location/location.dart';
import 'package:smart_select/smart_select.dart';
import 'package:toast/toast.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'history_page.dart';
import 'home_page.dart';

class NewOrderPage extends StatefulWidget {
  final int client;

  NewOrderPage({Key key, this.client}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewOrderPageState();
}

class _NewOrderPageState extends State<NewOrderPage> {
  var _prefs = new UserPreference();
  var auth = new AuthService();
  var clientService = new ClientService();
  Future<List<S2Choice<int>>> listclient;
  List<ProductModel> products = new List();
  var orders = new OrderService();
  var colors = const Color(0xff1f418b);
  var clientmodel = new ClientModel();
  var clientId = 0;
  int currentStep = 0;
  bool complete = false;
  LocationData currentLocation;
  var payment;
  var paymentId = 1;
  Location location;
  List<Step> steps;
  int currentPage = 1;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    location = new Location();
    payment = orders.getPaymenth();
    if (widget.client != 0) {
      clientService.getPrice(widget.client).then((value) {
        products = value;
      });
    }
    if (clientId != 0) {
      clientService.getClientId(clientId).then((value) {
        clientmodel = value;
      });
    }
    listclient = clientService.getClient(_prefs.truck);
    location.onLocationChanged.listen((LocationData cLoc) {
      currentLocation = cLoc;
    });
    setInitialLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appbar(context),
      body: stepperNative(context),
      bottomNavigationBar: bottom(context),
      resizeToAvoidBottomInset: true,
    );
  }

  Widget bottom(BuildContext context) {
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
                : Icon(FontAwesomeIcons.checkSquare, color: Color(0xff1f418b)),
            label: "Activo")
      ],
    );
  }

  Widget appbar(BuildContext context) {
    return AppBar(
      title: Text("Pedido en ruta"),
      automaticallyImplyLeading: true,
      leading: IconButton(
        icon: Icon(FontAwesomeIcons.userPlus),
        onPressed: () {
          setState(() {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => NewClientPage(),
                ),
                (route) => false);
          });
        },
      ),
    );
  }

  Widget stepper(BuildContext context) {
    return CoolStepper(
        steps: <CoolStep>[
          CoolStep(
            title: "Productos",
            subtitle: "",
            content: formNew(context, listclient),
            validation: () {
              if (products.every((element) => element.qty == 0)) {
                showAlert(context, "Cantidad en 0",
                    "No puede crear pedidos con cantidad en 0");
              }
            },
          ),
          CoolStep(
              title: "Descuentos",
              subtitle: "",
              content: discount(products),
              validation: () {}),
          CoolStep(
              title: "Metodo Pago",
              subtitle: "",
              content: showpayments(),
              validation: () {})
        ],
        config: CoolStepperConfig(
            stepText: "Paso",
            ofText: "de",
            backText: "Anterior",
            finalText: "Finalizar",
            nextText: "Siguiente"),
        onCompleted: () {
          setState(() {});
        });
  }

  Widget stepperNative(BuildContext context) {
    return Stepper(
      steps: listStep(context),
      type: StepperType.horizontal,
      currentStep: currentStep,
      onStepTapped: (value) {
        setState(() {
          currentStep = value;
        });
      },
      controlsBuilder: (context, {onStepCancel, onStepContinue}) {
        return GFButtonBar(
          children: <GFButton>[
            currentStep == listStep(context).length - 1
                ? GFButton(
                    onPressed: () {
                      setState(() {
                        print(paymentId);
                        orders.createOrder(
                            clientId, products, paymentId.toString());
                        Toast.show("Venta Realizada Correctamente", context,
                            duration: Toast.LENGTH_SHORT,
                            backgroundColor: GFColors.SUCCESS,
                            gravity: Toast.BOTTOM);
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    super.widget),
                            (route) => false);
                      });
                    },
                    color: GFColors.SUCCESS,
                    text: "Finalizar",
                    type: GFButtonType.transparent,
                  )
                : GFButton(
                    onPressed: () => stepContinue(context),
                    text: "Continuar",
                    type: GFButtonType.transparent,
                    color: GFColors.PRIMARY,
                  ),
            GFButton(
              onPressed: () => stepCancel(context),
              text: "Cancelar",
              type: GFButtonType.transparent,
              color: GFColors.DANGER,
            )
          ],
        );
      },
    );
  }

  void stepCancel(BuildContext context) {
    if (listStep(context).length != 0 &&
        clientId != 0 &&
        !products.every((element) => element.qty == 0)) {
      setState(() {
        currentStep = currentStep - 1;
      });
    } else {
      showAlert(context, "Error", "No puedo crear un pedido con cantidad en 0");
    }
  }

  void stepContinue(BuildContext context) {
    if (listStep(context).length < 5 &&
        clientId != 0 &&
        !products.any((element) => element.qty == 0 && element.stock > 0)) {
      setState(() {
        currentStep = currentStep + 1;
      });
    } else {
      showAlert(context, "Error", "No puedo crear un pedido con cantidad en 0");
    }
  }

  List<Step> listStep(BuildContext context) {
    return <Step>[
      Step(
          title: AutoSizeText("Productos"),
          isActive: currentStep == 0 ? true : false,
          state: currentStep == 1
              ? StepState.complete
              : currentStep == 0
                  ? StepState.editing
                  : StepState.disabled,
          content: formNew(context, listclient)),
      Step(
          title: AutoSizeText(
            "Descuentos",
          ),
          isActive: currentStep == 1 ? true : false,
          state: currentStep == 2
              ? StepState.complete
              : currentStep == 1
                  ? StepState.editing
                  : StepState.disabled,
          content: discount(products)),
      Step(
          title: AutoSizeText("Pago"),
          isActive: currentStep == 2 ? true : false,
          state: currentStep == 3
              ? StepState.complete
              : currentStep == 2
                  ? StepState.editing
                  : StepState.disabled,
          content: showpayments()),
    ];
  }

  Widget showpayments() {
    return AsyncBuilder(
      error: (context, error, stackTrace) => Text("Error"),
      waiting: (context) => Center(
        child: GFLoader(),
      ),
      future: payment,
      builder: (context, List<S2Choice<int>> list) {
        return Container(
          height: 600,
          width: 200,
          child: Column(
            children: <Widget>[
              SmartSelect.single(
                choiceItems: list,
                title: "Seleccione metodo de pago",
                value: paymentId,
                onChange: (value) {
                  setState(() {
                    paymentId = value.value;
                  });
                },
              ),
              cardDetails()
            ],
          ),
        );
      },
    );
  }

  Widget discount(List<ProductModel> list) {
    return Container(
      height: 500,
      child: Card(
        child: _products_list(
            list.where((element) => element.isDis == true).toList()),
      ),
    );
  }

  Widget card() {
    return Card();
  }

  Widget cardDetails() {
    var sum = 0;
    products.where((check) => check.qty > 0).toList().forEach((element) {
      sum += (element.price * element.qty).toInt();
    });
    return GFCard(
      title: GFListTile(
        title: Text("Detalle del Pedido"),
      ),
      content: Container(
        height: 400,
        width: 300,
        child: Column(
          children: <Widget>[
            TextFormField(
              initialValue: clientmodel.name,
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                  labelText: "Cliente",
                  prefixIcon: Icon(FontAwesomeIcons.user),
                  enabled: false),
            ),
            TextFormField(
              initialValue: "\$ ${sum.toString()}",
              readOnly: true,
              enabled: false,
              decoration: InputDecoration(
                  labelText: "Total",
                  prefixIcon: Icon(FontAwesomeIcons.dollarSign),
                  enabled: false),
            ),
            SizedBox(
              width: 10,
            ),
            previewProduct(
                products.where((element) => element.qty > 0).toList())
          ],
        ),
      ),
      titlePosition: GFPosition.start,
    );
  }

  Widget previewProduct(List<ProductModel> prod) {
    return Expanded(
        child: ListView.separated(
            itemBuilder: (context, index) {
              var subtotal = prod[index].price.toInt() * prod[index].qty;
              return ListTile(
                leading: GFAvatar(
                  child: AutoSizeText(
                    "Cant: ${prod[index].qty}",
                    style: TextStyle(color: Colors.black),
                  ),
                  size: 50,
                  shape: GFAvatarShape.square,
                  backgroundColor: Colors.transparent,
                ),
                title: AutoSizeText(
                  prod[index].name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: AutoSizeText(
                  "\$ ${subtotal}",
                  style: TextStyle(color: Colors.black),
                ),
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
            itemCount: prod.length));
  }

  Widget formNew(BuildContext context, Future<List<S2Choice<int>>> clients) {
    return Container(
      height: 500,
      child: AsyncBuilder(
        future: clients,
        waiting: (context) => Center(
          child: GFLoader(),
        ),
        builder: (context, List<S2Choice<int>> list) {
          print(list.length);
          return Card(
            child: Wrap(
              children: <Widget>[
                SmartSelect.single(
                  title: "Seleccione un Cliente",
                  value: widget.client != 0 ? widget.client : clientId,
                  onChange: (value) {
                    setState(() {
                      print(value.title);
                      clientService.getClientId(value.value).then((value) {
                        setState(() {
                          clientmodel = value;
                        });
                      });
                      clientId = value.value;
                      clientService.getPrice(value.value).then((value) {
                        setState(() {
                          products = value;
                        });
                      });
                    });
                  },
                  choiceItems: list,
                  choiceLayout: S2ChoiceLayout.list,
                ),
                _tabs(products)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _tabs(List<ProductModel> products) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: TabBar(
                tabs: [
                  Tab(
                    child: AutoSizeText(
                      "Normal",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Tab(
                    child: AutoSizeText(
                      "Catalitico",
                      style: TextStyle(color: Colors.black),
                    ),
                  )
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _products_list(products
                    .where((element) =>
                        element.isCat != true && element.isDis != true)
                    .toList()),
                _products_list(products
                    .where((element) =>
                        element.isCat == true && element.isDis != true)
                    .toList()),
              ],
            ),
          )),
    );
  }

  Widget _customPopupItem(
      BuildContext context, ClientModel model, String itemDesignation) {
    return model != null
        ? Container(
            child: ListTile(
              contentPadding: EdgeInsets.all(0),
              title: AutoSizeText(model.name),
              subtitle: AutoSizeText(model.address),
            ),
          )
        : Container(
            child: ListTile(
              contentPadding: EdgeInsets.all(0),
              title: AutoSizeText("Seleccione un cliente"),
            ),
          );
  }

  Widget _customPopupItemBuilderExample2(
      BuildContext context, ClientModel item, bool isSelected) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: !isSelected
          ? null
          : BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
      child: ListTile(
        selected: isSelected,
        title: AutoSizeText(
          item.name,
        ),
        subtitle: AutoSizeText(item.address),
      ),
    );
  }

  Widget _products_list(List<ProductModel> list) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          var qty = 0;
          var stock = list[index].stock;
          var subtotal = list[index].price.toInt() * list[index].qty;
          return ListTile(
              title: AutoSizeText(
                list[index].name,
                style: TextStyle(
                    color: list[index].stock > 0 ? Colors.orange : Colors.grey),
              ),
              subtitle: subtotal == 0
                  ? AutoSizeText(list[index].price.toString())
                  : AutoSizeText(subtotal.toString()),
              leading: list[index].stock > 0
                  ? CustomNumberPicker(
                      customAddButton: Center(
                        child: IconButton(
                          icon: Icon(
                            FontAwesomeIcons.plusCircle,
                          ),
                          disabledColor: Colors.black,
                        ),
                      ),
                      customMinusButton: IconButton(
                        icon: Icon(FontAwesomeIcons.minusCircle),
                        alignment: Alignment.center,
                        disabledColor: Colors.black,
                      ),
                      initialValue: qty,
                      minValue: 0,
                      maxValue: 100,
                      step: 1,
                      onValue: (value) {
                        setState(() {
                          qty = value;
                          list[index].qty = value;
                        });
                      },
                    )
                  : CustomNumberPicker(
                      customAddButton: Center(
                        child: IconButton(
                          splashColor: Colors.transparent,
                          onPressed: () {},
                          icon: Icon(
                            FontAwesomeIcons.plusCircle,
                          ),
                          color: Colors.grey,
                        ),
                      ),
                      customMinusButton: IconButton(
                        splashColor: Colors.transparent,
                        icon: Icon(FontAwesomeIcons.minusCircle),
                        onPressed: () {},
                        alignment: Alignment.center,
                        color: Colors.grey,
                      ),
                      initialValue: products[index].qty,
                      minValue: 0,
                      maxValue: 100,
                      step: 1,
                      onValue: (value) {
                        setState(() {
                          list[index].qty = value;
                        });
                      },
                    ));
        },
      ),
    );
  }

  void setInitialLocation() async {
    currentLocation = await location.getLocation();
  }
}
