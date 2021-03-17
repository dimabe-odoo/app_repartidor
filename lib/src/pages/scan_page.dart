import 'package:app_repartidor_v3/src/pages/home_page.dart';
import 'package:app_repartidor_v3/src/services/auth_service.dart';
import 'package:barcode_scan_fix/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';

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
                  TextButton.icon(
                      onPressed: () {
                        setState(() {
                          backCamera = !backCamera;
                          camera = backCamera ? 1 : -1;
                        });
                      },
                      icon: backCamera
                          ? Icon(Icons.camera,color: Colors.black,)
                          : Icon(Icons.camera_outlined,color: Colors.black),
                      label: Text('Esta usando :' +
                          (backCamera ? "Camara Frontal" : "Camara Trasera"),style: TextStyle(color: Colors.black),)),
                  Text(
                    (qrCodeResult == null) || (qrCodeResult == "")
                        ? "Escanear el codigo qr presente en el camión"
                        : "Camión:" + qrCodeResult,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                      onPressed: () {
                        scan();
                      },
                      icon: Icon(FontAwesomeIcons.qrcode,color: Colors.black,),
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) => getColor(states))),
                      label:
                          Text("Escanear QR", style: TextStyle(fontSize: 16,color: Colors.black))),
                  ElevatedButton(
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
                                (route) => false);
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

  Future scan() async {
    try {
      String barcode = await BarcodeScanner.scan();
      setState(() => this.qrCodeResult = barcode);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          this.qrCodeResult = 'La app no tiene permiso para usar la camara';
        });
      } else {
        setState(() => this.qrCodeResult = 'Unknown error: $e');
      }
    } on FormatException {
      setState(() => this.qrCodeResult =
          'Escanear el codigo qr presente en el camion');
    } catch (e) {
      setState(() => this.qrCodeResult = 'Unknown error: $e');
    }
  }
  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.deepOrange;
    }
    return Colors.transparent;
  }
}

int camera = -1;
