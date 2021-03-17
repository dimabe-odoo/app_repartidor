import 'package:app_repartidor_v3/src/helpers/rut_helper.dart' as rut;
import 'package:app_repartidor_v3/src/pages/secrets.dart';
import 'package:app_repartidor_v3/src/services/client_service.dart';
import 'package:app_repartidor_v3/src/services/commune_service.dart';
import 'package:async_builder/async_builder.dart';
import 'package:dart_rut_validator/dart_rut_validator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/appbar/gf_appbar.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/components/button/gf_button_bar.dart';
import 'package:getwidget/components/button/gf_icon_button.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:getwidget/components/loader/gf_loader.dart';
import 'package:getwidget/types/gf_loader_type.dart';
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_select/smart_select.dart';
import 'package:toast/toast.dart';

import 'new_order_page.dart';

class NewClientPage extends StatefulWidget {
  @override
  NewClientPageState createState() => NewClientPageState();
}

class NewClientPageState extends State<NewClientPage> {
  var anonimous = false;
  var communeService = new CommuneService();
  var clientService = new ClientService();
  var communes;
  var valueSmart = 1;
  var namecontroller = TextEditingController();
  var phonecontroller = TextEditingController();
  var emailcontrller = TextEditingController();
  var addresscontroller = TextEditingController();
  TextEditingController _rutController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LatLng result;

  @override
  void initState() {
    _rutController.clear();
    communes = communeService.getCommunes();
    super.initState();
  }

  void validateAndSave() {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      print('Form is valid');
    } else {
      print('Form is invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: GFAppBar(
        leading: GFIconButton(
          onPressed: () {
            setState(() {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => NewOrderPage(),
                  ),
                      (route) => false);
            });
          },
          icon: Icon(FontAwesomeIcons.arrowAltCircleLeft),
        ),
        title: Text('Nuevo Cliente'),
      ),
      body: Container(
        child: card(context),
      ),
    );
  }

  void onChangedApplyFormat(String text) {
    RUTValidator.formatFromTextController(_rutController);
  }

  Widget card(BuildContext context) {
    final node = FocusScope.of(context);
    return Form(
      key: _formKey,
      child: GFCard(
        borderOnForeground: true,
        semanticContainer: true,
        title: GFListTile(
          title: Text("Nuevo Cliente"),
        ),
        content: Wrap(
          children: <Widget>[
            TextFormField(
              validator: (value) {
                if (value.isEmpty) {
                  return 'Dato Requerido';
                }
                return null;
              },
              onEditingComplete:() => node.nextFocus(),
              controller: namecontroller,
              decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.userAlt),
                hintText: "Nombre:",
                alignLabelWithHint: true,
                filled: true,
              ),
            ),
            TextFormField(
              controller: phonecontroller,
              onEditingComplete: () => node.nextFocus(),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.mobileAlt),
                hintText: "Telefono:",
                alignLabelWithHint: true,
                filled: true,
              ),
            ),
            TextFormField(
                controller: _rutController,
                onEditingComplete: () {
                  setState(() {
                    _rutController.text = RUTValidator.formatFromText(_rutController.text);

                  });
                  node.nextFocus();
                },
                validator: (value) {
                  if (!rut.RutHelper.check(value)) {
                    return 'Rut No Valido';
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(FontAwesomeIcons.idCard),
                  hintText: "Rut:",
                  alignLabelWithHint: true,
                  filled: true,
                )),
            TextFormField(
              controller: emailcontrller,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  hintText: "Correo",
                  alignLabelWithHint: true,
                  filled: true),
              onEditingComplete: () => node.unfocus(),
            ),
            selectComumme(),
            TextButton(
                onPressed: () {
                  setState(() {
                    showLocation(context).then((value) {
                      addresscontroller.text = value.address;
                      result = value.latLng;
                    });
                  });
                },
                child: Text("Seleccionar Direccion")),
            addresscontroller.text == '' || addresscontroller.text == null
                ? Text('Sin Direccion')
                : TextFormField(
              controller: addresscontroller,
              autovalidateMode: AutovalidateMode.always,
              maxLines: 2,
              decoration: InputDecoration(
                  prefixIcon: Icon(FontAwesomeIcons.addressCard),
                  hintText: "Direccion",
                  alignLabelWithHint: true,
                  filled: true),
            ),
          ],
        ),
        buttonBar: GFButtonBar(
          children: [
            GFButton(
                child: Text('Crear'),
                onPressed: () {
                  setState(() {
                    if (_formKey.currentState.validate()) {
                      clientService
                          .createClient(
                          namecontroller.text,
                          emailcontrller.text,
                          int.parse(phonecontroller.text),
                          valueSmart,
                          addresscontroller.text,
                          result,
                          _rutController.text)
                          .then((value) {
                        if(value == 'el email ${emailcontrller.text} ya se encuentra registrado'){
                          Toast.show(value, context);
                        }else{
                          Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => NewOrderPage(client: value['ClientId'],),), (route) => false);
                        }
                      });
                    }
                  });
                })
          ],
        ),
      ),
    );
  }

  Widget selectComumme() {
    return AsyncBuilder(
      waiting: (context) => GFLoader(
        type: GFLoaderType.android,
      ),
      future: communes,
      builder: (context, list) {
        return SmartSelect.single(
          value: valueSmart,
          onChange: (item) {
            setState(() {
              valueSmart = item.value;
            });
          },
          title: "Comuna",
          choiceItems: list,
        );
      },
    );
  }

  Future<LocationResult> showLocation(BuildContext context)  async{
    LocationResult result = await showLocationPicker(
      context,
      Secrets.API_KEY,
      initialCenter: LatLng(31.1975844, 29.9598339),
      myLocationButtonEnabled: true,
      layersButtonEnabled: true,
      desiredAccuracy: LocationAccuracy.best,
    );
    return result;
  }
}
