import 'package:app_repatidor_v2/src/models/order_model.dart';
import 'package:app_repatidor_v2/src/pages/history_page.dart';
import 'package:app_repatidor_v2/src/utils/utils.dart';
import 'package:async_builder/async_builder.dart';
import 'package:flutter/material.dart';
import 'package:app_repatidor_v2/src/services/order_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:getwidget/components/list_tile/gf_list_tile.dart';
import 'package:responsive_grid/responsive_grid.dart';

class OrderDetail extends StatefulWidget {
  final OrderModel order;

  OrderDetail(this.order, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  final service = new OrderService();
  var paramaters;
  var colors = const Color(0xff1f418b);
  var paymentmethod;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles'),
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => HistoryPage(),
                ),
                (Route<dynamic> route) => false);
          },
        ),
      ),
      body: cardDetails(),
      floatingActionButton: FlatButton(
        onPressed: () {},
        child: Icon(FontAwesomeIcons.check),
      ),
    );
  }

  Widget cardDetails() {
    return GFCard(
      title: GFListTile(
        titleText: "Detalle Orden ${widget.order.orderName}",
      ),
      content: Column(
        children: <Widget>[
          TextFormField(
            initialValue: widget.order.clientName,
            readOnly: true,
            enabled: false,
            decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.user), labelText: "Cliente"),
          ),
          TextFormField(
            initialValue: widget.order.total.toString().split('.')[0],
            readOnly: true,
            enabled: false,
            decoration: InputDecoration(
                prefixIcon: Icon(FontAwesomeIcons.dollarSign),
                labelText: "Total"),
          ),
          TextFormField(
            initialValue: widget.order.clientAddress,
            readOnly: true,
            enabled: false,
            decoration: InputDecoration(
              prefixIcon: Icon(FontAwesomeIcons.addressCard),
              labelText: "Direccion"
            ),
          )
        ],
      ),
    );
  }
}
