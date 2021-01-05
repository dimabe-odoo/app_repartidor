import 'dart:io';

import 'package:app_repatidor_v2/src/pages/home_page.dart';
import 'package:app_repatidor_v2/src/services/auth_service.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';
import 'package:getwidget/components/button/gf_icon_button.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  String qrCodeResult;
  bool backCamera = true;
  var authService = new AuthService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
              leading: IconButton(
                icon: Icon(FontAwesomeIcons.arrowLeft),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                      (route) => false);
                },
              ),
            ),
            body: Center(
              child: Column(
                children: <Widget>[
                  FlatButton.icon(
                      onPressed: () {
                        setState(() {
                          backCamera = !backCamera;
                          camera = backCamera ? 1 : -1;
                        });
                      },
                      icon: backCamera
                          ? Icon(Icons.camera)
                          : Icon(Icons.camera_outlined),
                      label: Text('Esta usando :' +
                          (backCamera ? "Camara Frontal" : "Camara Trasera"))),
                  Text(
                    (qrCodeResult == null) || (qrCodeResult == "")
                        ? "Escanear el codigo qr presente en el camión"
                        : "Camión:" + qrCodeResult,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  FlatButton.icon(
                      onPressed: () {
                        _scan();
                      },
                      height: 70.0,
                      icon: Icon(FontAwesomeIcons.qrcode),
                      label:
                          Text("Escanear QR", style: TextStyle(fontSize: 16))),
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        authService.assignTruck(qrCodeResult).then((value) {
                          if (value.contains("Ya existe una sesion activa")) {
                            Toast.show(value, context,
                                duration: 10, gravity: Toast.BOTTOM);
                          } else {
                            Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => HomePage(),
                                ),
                                (Route<dynamic> route) => false);
                          }
                        });
                      });
                    },
                    child: Text("Confirmar"),
                  )
                ],
              ),
            )),
        onWillPop: () async {
          return Navigator.canPop(context);
        });
  }

  Future<void> _scan() async {
    ScanResult codeScanner = await BarcodeScanner.scan(
      options: ScanOptions(
        useCamera: camera,
      ),
    );
    setState(() {
      if (codeScanner.rawContent.contains('-')) {
        qrCodeResult = codeScanner.rawContent;
      }
    });
  }
}

int camera = -1;
