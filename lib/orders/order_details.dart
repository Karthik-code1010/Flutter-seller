import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:localstorage/localstorage.dart';
import 'package:page_transition/page_transition.dart';

import '../main.dart';
import '../model/product_model.dart';
import '../notification/notification_page.dart';
import '../tabs/myaccount.dart';
import '../tabs/dashboard.dart';
import '../tabs/product_list.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // for date format
import 'package:intl/date_symbol_data_local.dart'; // for other locales

class orderFullDetails extends StatefulWidget {
  final String orderid;
  final String invoidpath;
  const orderFullDetails(
      {Key? key, required this.orderid, required this.invoidpath})
      : super(key: key);

  @override
  _orderFullDetailsState createState() => _orderFullDetailsState();
}

class _orderFullDetailsState extends State<orderFullDetails> {
  final LocalStorage storage = new LocalStorage('seller_app');
  int _selectedIndex = 1;
  var orderId;
  @override
  void initState() {
    setState(() {
      orderId = widget.orderid;
      print(orderId);
      print('invoice path');
      print(widget.invoidpath);
    });
    getOrderDetails();
    // TODO: implement initState
    super.initState();
  }

  List orderDetailData = [];
  getOrderDetails() async {
    print(storage.getItem('people'));
    var refUserId = storage.getItem('people')["refUserId"];
    var refAccountId = storage.getItem('people')["refAccountId"];
    var refApplicationId = storage.getItem('people')["refApplicationId"];
    var refOrganizationId = storage.getItem('people')["refOrganizationId"];
    print(refUserId);
    print(refAccountId);
    print(refApplicationId);
    print(orderId);
    var resproduct = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/getSellerOrderById?accountId=' +
          refOrganizationId +
          '&id=' +
          orderId),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //print('response');
    //print(res);
    final responseFormatProduct = json.decode(resproduct.body);
    final pdata = responseFormatProduct["data"];

    setState(() {
      orderDetailData = pdata;
    });
    print(orderDetailData);

    print(DateTime.parse('2020-01-02T07:12:50Z'));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print('Tap');
      print(_selectedIndex);
      if (_selectedIndex == 2) {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: productList(
                  searchvalue: '',
                )));
      }
      if (_selectedIndex == 0) {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft, child: productPage()));
      }

      if (_selectedIndex == 1) {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft, child: myaccountpage()));
      }
    });
  }

  logout() {
    storage.deleteItem('appid');
    storage.deleteItem('orgid');
    storage.deleteItem('people');
    Navigator.push(context,
        PageTransition(type: PageTransitionType.rightToLeft, child: MyApp()));
  }

  void _viewFile() async {
    if (widget.invoidpath == '') {
      showTopSnackBar(
        context,
        CustomSnackBar.error(
          message: "Invoice not uploaded..",
        ),
      );
    } else {
      final _url = dotenv.get('API_URL') + '/api/service/' + widget.invoidpath;
      if (await canLaunch(_url)) {
        await launch(_url);
      } else {
        print('Something went wrong');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          transform: Matrix4.translationValues(-58.0, 0.0, 0.0),
          margin: EdgeInsets.only(left: 0, top: 0, right: 20, bottom: 0),
          height: 50,
          width: 140,
          color: Colors.white,
          child: Image(
            image: AssetImage('images/innoart.png'),
          ),
        ),
        elevation: 1,
        actions: [
          Row(
            children: [
              Text(
                'Hello, ' + storage.getItem('people')["name"],
                // style: TextStyle(color: Colors.black)
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(
                width: 2.0,
              ),
              IconButton(
                icon: Icon(Icons.notifications_active),
                onPressed: () {
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: notificationPage()));
                },
                color: Color(0xFF005EA2),
              ),
              IconButton(
                icon: ImageIcon(
                  AssetImage("images/logout.png"),
                  size: 24.0,
                  color: Color(0xFF005EA2),
                ),
                onPressed: () {
                  logout();
                  // Navigator.push(
                  //     context,
                  //     PageTransition(
                  //         type: PageTransitionType.rightToLeft,
                  //         child: MyApp()));
                },
                color: Color(0xFF005EA2),
              ),
              SizedBox(
                width: 5.0,
              )
            ],
          ),
        ],
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Container(
            // Symetric Padding
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 9.0),
            child: orderDetailData.length > 0
                ? Column(
                    children: [
                      SizedBox(
                        height: 1.0,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 0, right: 20, bottom: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order Details',
                              style: GoogleFonts.poppins(
                                  color: Color(0xFF005EA2),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints.loose(const Size(600, 160)),
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(children: <Widget>[
                              Expanded(
                                child: Padding(
                                  // padding: const EdgeInsets.all(10.0),
                                  padding: EdgeInsets.only(
                                      bottom: 10.0,
                                      top: 10.0,
                                      left: 10.0,
                                      right: 10.0),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          child: Text(
                                            'Order Number',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          child: Text(
                                              orderDetailData[0]["orderNumber"],
                                              style: GoogleFonts.poppins(
                                                  fontWeight:
                                                      FontWeight.normal)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                            Row(children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      bottom: 10.0,
                                      top: 0.0,
                                      left: 10.0,
                                      right: 10.0),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          child: Text(
                                            'Ordered On',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          child: Text(
                                            DateTime.parse(orderDetailData[0]
                                                    ["orderedOn"])
                                                .toString()
                                                .substring(0, 16),
                                            // orderDetailData[0]["orderedOn"],
                                            // DateFormat('yyyy-MM-dd hh:mm:ss')
                                            //     .format(DateTime.now()),

                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                            Row(children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      bottom: 10.0,
                                      top: 0.0,
                                      left: 10.0,
                                      right: 10.0),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          child: Text(
                                            'Grand Total',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          child: Text(
                                            '\$' +
                                                double.parse(orderDetailData[0]
                                                        ["grandTotal"])
                                                    .toStringAsFixed(2),
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                            SizedBox(
                              height: 5.0,
                            ),
                            Divider(
                              height: 0,
                              thickness: 1,
                              indent: 0,
                              endIndent: 0,
                              color: Colors.grey.shade400,
                            ),
                            Row(children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      bottom: 0.0,
                                      top: 0.0,
                                      left: 10.0,
                                      right: 10.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 6,
                                        child: Container(
                                          child: Text(
                                            'Download Invoice',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: IconButton(
                                          icon: Icon(Icons.arrow_forward_ios),
                                          onPressed: _viewFile,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 0, right: 20, bottom: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order Summary',
                              style: GoogleFonts.poppins(
                                  color: Color(0xFF005EA2),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints.loose(const Size(600, 140)),
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(children: <Widget>[
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  // padding: const EdgeInsets.all(10.0),
                                  padding: EdgeInsets.only(
                                      bottom: 10.0,
                                      top: 10.0,
                                      left: 10.0,
                                      right: 10.0),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 5,
                                            child: Container(
                                              child: Text(
                                                'Item(s) Subtotal',
                                                style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              child: Text(
                                                  '\$' +
                                                      double.parse(orderDetailData[
                                                                  0]
                                                              ["subTotalValue"])
                                                          .toStringAsFixed(2),
                                                  textAlign: TextAlign.right,
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // SizedBox(
                                      //   height: 10.0,
                                      // ),
                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.spaceBetween,
                                      //   children: <Widget>[
                                      //     Expanded(
                                      //       flex: 5,
                                      //       child: Container(
                                      //         child: Text(
                                      //           'Total',
                                      //           style: GoogleFonts.poppins(
                                      //               fontWeight:
                                      //                   FontWeight.normal),
                                      //         ),
                                      //       ),
                                      //     ),
                                      //     Expanded(
                                      //       flex: 2,
                                      //       child: Container(
                                      //         child: Text(
                                      //             '\$' +
                                      //                 orderDetailData[0]
                                      //                         ["totalValue"]
                                      //                     .toString(),
                                      //             style: GoogleFonts.poppins(
                                      //                 fontWeight:
                                      //                     FontWeight.normal)),
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 5,
                                            child: Container(
                                              child: Text(
                                                'Total Tax',
                                                style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.normal),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              child: Text(
                                                  '\$' +
                                                      double.parse(
                                                              orderDetailData[0]
                                                                  ["totalTax"])
                                                          .toStringAsFixed(2),
                                                  textAlign: TextAlign.right,
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.normal)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 10.0,
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            flex: 5,
                                            child: Container(
                                              child: Text(
                                                'Grand Total',
                                                style: GoogleFonts.poppins(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              child: Text(
                                                  '\$' +
                                                      double.parse(
                                                              orderDetailData[0]
                                                                  [
                                                                  "grandTotal"])
                                                          .toStringAsFixed(2),
                                                  textAlign: TextAlign.right,
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  // padding: const EdgeInsets.all(10.0),
                                  padding: EdgeInsets.only(
                                      bottom: 10.0,
                                      top: 10.0,
                                      left: 10.0,
                                      right: 10.0),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        height: 90,
                                        width: 70,
                                        color: Colors.white,
                                        child: Image(
                                          image: // orderDetailData[0]["qrCode"]
                                              AssetImage('images/qr-code.png'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 0, right: 20, bottom: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shipping address',
                              style: GoogleFonts.poppins(
                                  color: Color(0xFF005EA2),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints.loose(const Size(600, 182)),
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(children: <Widget>[
                              Expanded(
                                child: Padding(
                                  // padding: const EdgeInsets.all(10.0),
                                  padding: EdgeInsets.only(
                                      bottom: 5.0,
                                      top: 10.0,
                                      left: 10.0,
                                      right: 10.0),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          child: Text(
                                            orderDetailData[0]
                                                ["refShippingAddress"]["name"],
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                            Row(children: <Widget>[
                              Expanded(
                                child: Padding(
                                  // padding: const EdgeInsets.all(10.0),
                                  padding: EdgeInsets.only(
                                      bottom: 5.0,
                                      top: 10.0,
                                      left: 10.0,
                                      right: 10.0),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          child: Text(
                                            orderDetailData[0]
                                                    ["refShippingAddress"]
                                                ["streetAddress1"],
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                            Row(children: <Widget>[
                              Expanded(
                                child: Padding(
                                  // padding: const EdgeInsets.all(10.0),
                                  padding: EdgeInsets.only(
                                      bottom: 5.0,
                                      top: 10.0,
                                      left: 10.0,
                                      right: 10.0),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          child: Text(
                                            orderDetailData[0]
                                                        ["refShippingAddress"]
                                                    ["city"]["name"] +
                                                ', ' +
                                                orderDetailData[0]
                                                        ["refShippingAddress"]
                                                    ["state"]["name"] +
                                                ' ' +
                                                orderDetailData[0]
                                                        ["refShippingAddress"]
                                                    ["postalCode"],
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                            Row(children: <Widget>[
                              Expanded(
                                child: Padding(
                                  // padding: const EdgeInsets.all(10.0),
                                  padding: EdgeInsets.only(
                                      bottom: 5.0,
                                      top: 10.0,
                                      left: 10.0,
                                      right: 10.0),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          child: Text(
                                            orderDetailData[0]
                                                    ["refShippingAddress"]
                                                ["country"]["name"],
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                            SizedBox(
                              height: 5.0,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        constraints: BoxConstraints.loose(const Size(600, 180)),
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(0.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Row(children: <Widget>[
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Image.network(dotenv.get('API_URL') +
                                      '/api/service/' +
                                      (orderDetailData[0]["OrderItems"][0]
                                                  ["refProduct"][0]
                                              ["largeImage"][0]["path"])
                                          .replaceAll(r'\', '/')),
                                  // Image(
                                  //   image:
                                  //   AssetImage('images/p1.png'),
                                  // ),
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Padding(
                                  // padding: const EdgeInsets.all(10.0),
                                  padding: EdgeInsets.only(
                                      bottom: 1.0,
                                      top: 10.0,
                                      left: 10.0,
                                      right: 10.0),
                                  child: Column(
                                    children: [
                                      Row(children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            // padding: const EdgeInsets.all(10.0),
                                            padding: EdgeInsets.only(
                                                bottom: 1.0,
                                                top: 10.0,
                                                left: 10.0,
                                                right: 10.0),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Container(
                                                    child: Text(
                                                      orderDetailData[0]
                                                                  ["OrderItems"]
                                                              [0]["refProduct"]
                                                          [0]["name"],
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
                                      Row(children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            // padding: const EdgeInsets.all(10.0),
                                            padding: EdgeInsets.only(
                                                bottom: 1.0,
                                                top: 10.0,
                                                left: 10.0,
                                                right: 10.0),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Container(
                                                    child: Text(
                                                      'by ' +
                                                          orderDetailData[0][
                                                                      "OrderItems"]
                                                                  [0]["brand"]
                                                              [0]["name"],
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
                                      Row(children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            // padding: const EdgeInsets.all(10.0),
                                            padding: EdgeInsets.only(
                                                bottom: 1.0,
                                                top: 10.0,
                                                left: 10.0,
                                                right: 10.0),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Container(
                                                    child: Text(
                                                      '\$' +
                                                          double.parse(orderDetailData[
                                                                              0]
                                                                          [
                                                                          "OrderItems"][0]
                                                                      [
                                                                      "refProductPrice"][0]
                                                                  [
                                                                  "sellingPrice"])
                                                              .toStringAsFixed(
                                                                  2),
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal,
                                                              color: Color(
                                                                  0xFF005EA2)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
                                      Row(children: <Widget>[
                                        Expanded(
                                          child: Padding(
                                            // padding: const EdgeInsets.all(10.0),
                                            padding: EdgeInsets.only(
                                                bottom: 1.0,
                                                top: 10.0,
                                                left: 10.0,
                                                right: 10.0),
                                            child: Row(
                                              children: <Widget>[
                                                Expanded(
                                                  child: Container(
                                                    child: Text(
                                                      'SKU :' +
                                                          orderDetailData[0][
                                                                      "OrderItems"]
                                                                  [
                                                                  0]["refProduct"]
                                                              [0]["skuId"],
                                                      style:
                                                          GoogleFonts.poppins(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
                                      // Row(children: <Widget>[
                                      //   Expanded(
                                      //     child: Padding(
                                      //       // padding: const EdgeInsets.all(10.0),
                                      //       padding: EdgeInsets.only(
                                      //           bottom: 1.0,
                                      //           top: 10.0,
                                      //           left: 10.0,
                                      //           right: 10.0),
                                      //       child: Row(
                                      //         children: <Widget>[
                                      //           Expanded(
                                      //             child: Container(
                                      //               child: Text(
                                      //                 'Delivered',
                                      //                 style:
                                      //                     GoogleFonts.poppins(
                                      //                   fontWeight:
                                      //                       FontWeight.normal,
                                      //                   color:
                                      //                       Color(0xFF005EA2),
                                      //                 ),
                                      //               ),
                                      //             ),
                                      //           ),
                                      //         ],
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ]),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: SingleChildScrollView(),
                  )),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 16,
        unselectedFontSize: 16,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("images/dashboard.png"),
              size: 29.0,
              color: Colors.black,
            ),
            activeIcon: ImageIcon(
              AssetImage("images/dashboard.png"),
              size: 29.0,
              color: Color(0xFF006EC1),
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("images/user.png"),
              size: 29.0,
              color: Colors.black,
            ),
            activeIcon: ImageIcon(
              AssetImage("images/user.png"),
              size: 29.0,
              color: Color(0xFF006EC1),
            ),
            label: 'My Account',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage("images/package.png"),
              size: 29.0,
              color: Colors.black,
            ),
            activeIcon: ImageIcon(
              AssetImage("images/package.png"),
              size: 29.0,
              color: Color(0xFF006EC1),
            ),
            label: 'Products',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF006EC1),
        unselectedItemColor: Colors.black,
        onTap: _onItemTapped,
      ),
    );
  }
}
