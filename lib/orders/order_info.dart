import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localstorage/localstorage.dart';
import 'package:page_transition/page_transition.dart';

import '../main.dart';
import '../model/product_model.dart';
import '../notification/notification_page.dart';
import '../product_details/view_product.dart';
import '../tabs/myaccount.dart';
import '../tabs/dashboard.dart';
import '../tabs/product_list.dart';
import 'package:http/http.dart' as http;

import 'order_details.dart';

class orderInfo extends StatefulWidget {
  const orderInfo({Key? key}) : super(key: key);

  @override
  _orderInfoState createState() => _orderInfoState();
}

class _orderInfoState extends State<orderInfo> {
  final LocalStorage storage = new LocalStorage('seller_app');
  final _formKey = GlobalKey<FormState>();
  int _selectedIndex = 1;
  void initState() {
    getOrderList(searchname);
    getOrderFliterData();
    super.initState();
  }

  var searchname = "";
  var dataCount;
  List orderListData = [];
  getOrderList(search) async {
    print(storage.getItem('people'));
    var refUserId = storage.getItem('people')["refUserId"];
    var refAccountId = storage.getItem('people')["refAccountId"];
    var refApplicationId = storage.getItem('people')["refApplicationId"];
    var refOrganizationId = storage.getItem('people')["refOrganizationId"];
    print(refUserId);
    print(refAccountId);
    print(refApplicationId);

    var res = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/getSellerOrdersCount?accountId=' +
          refOrganizationId +
          '&search=&startDate=&endDate=&orderStatus='),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //print('response');
    //print(res);
    final responseFormat = json.decode(res.body);
    final data = responseFormat["data"];

    setState(() {
      dataCount = data;
    });
    print(dataCount);

    var resproduct = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/getSellerOrders?accountId=' +
          refOrganizationId +
          '&limit=&offset=&search=' +
          search +
          '&startDate=&endDate=&orderStatus='),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //print('response');
    //print(res);
    final responseFormatProduct = json.decode(resproduct.body);
    final pdata = responseFormatProduct["data"];

    setState(() {
      orderListData = pdata;
    });
    print('order');
    print(orderListData);
  }

  Future search() async {
    print('hi karthik');
    print(searchname);
    setState(() {
      getOrderList(searchname);
    });
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

  List orderstatusFildata = [];

  getOrderFliterData() async {
    var invenres = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?options=keyValues&type=CommonDataSet&q=name==OrderStatus'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final responseFormatCountry = json.decode(invenres.body);
    final cresdata = responseFormatCountry["data"];
    //  print(cresdata);
    setState(() {
      orderstatusFildata = cresdata;
      print(orderstatusFildata);
    });
  }

  fliter() async {
    print('filter');
    //print(orderstatusFildata);
    print(orderStatus);
    print(storage.getItem('people'));
    var refUserId = storage.getItem('people')["refUserId"];
    var refAccountId = storage.getItem('people')["refAccountId"];
    var refApplicationId = storage.getItem('people')["refApplicationId"];
    var refOrganizationId = storage.getItem('people')["refOrganizationId"];
    print(refUserId);
    print(refAccountId);
    print(refApplicationId);

    var resproduct = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/getSellerOrders?accountId=' +
          refOrganizationId +
          '&limit=&offset=&search=&startDate=&endDate=&orderStatus=' +
          orderStatus),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //print('response');
    //print(res);
    final responseFormatProduct = json.decode(resproduct.body);
    final pdata = responseFormatProduct["data"];

    setState(() {
      orderListData = pdata;
    });
    Navigator.of(context).pop();
    print(orderListData);
  }

  String orderStatus = "CommonDataSet-0403-014";
  dialogbox() async {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Inventory Status'),
              content: Container(
                height: 80,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: DropdownButtonFormField(
                        decoration: InputDecoration(
                          hintText: '',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide:
                                BorderSide(color: new Color(0xFF005EA2)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        validator: (value) =>
                            value == null ? "Select a country" : null,
                        dropdownColor: Colors.white,
                        value: orderStatus,
                        onChanged: (String? newValue) {
                          setState(() {
                            orderStatus = newValue!;
                            print(orderStatus);
                          });
                        },
                        // items: dropdownItems,
                        items: orderstatusFildata.map((item) {
                          print(item["value"]);
                          print(item["id"]);
                          return new DropdownMenuItem(
                            child: new Text(item['value']),
                            value: item['id'].toString(),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 28,
                      width: 80,
                      child: FlatButton(
                        child: Text(
                          'Cancel',
                          style: TextStyle(fontSize: 14.0),
                        ),
                        color: Color(0xFF005EA2),
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    SizedBox(
                      width: 18,
                    ),
                    Container(
                      height: 28,
                      width: 80,
                      child: FlatButton(
                        child: Text(
                          'Ok',
                          style: TextStyle(fontSize: 14.0),
                        ),
                        color: Color(0xFF005EA2),
                        textColor: Colors.white,
                        onPressed: () {
                          fliter();
                        },
                      ),
                    )
                  ],
                ),
              ],
            );
          });
        });
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
        // physics: NeverScrollableScrollPhysics(),
        // scrollDirection: Axis.vertical,
        child: Container(
          // Symetric Padding
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 9.0),
          child: Column(
            children: [
              SizedBox(
                height: 1.0,
              ),
              Row(children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Form(
                      key: _formKey,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 0,
                            child: IconButton(
                              icon: Icon(Icons.arrow_back),
                              onPressed: () {
                                //myaccountpage
                                Navigator.push(
                                    context,
                                    PageTransition(
                                        type: PageTransitionType.rightToLeft,
                                        child: myaccountpage()));
                              },
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              height: 34.0,
                              child: TextFormField(
                                controller:
                                    TextEditingController(text: searchname),
                                onChanged: (value) {
                                  searchname = value;
                                  print(searchname);
                                },
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                    labelText: 'Search for products',
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 1, color: Color(0xFF005EA2)),
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: const BorderSide(
                                          width: 1, color: Color(0xFF005EA2)),
                                      borderRadius: BorderRadius.circular(0),
                                    )),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 34.0,
                              decoration: BoxDecoration(
                                // borderRadius: BorderRadius.circular(0.0),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(0.0)),
                              ),
                              child: FlatButton(
                                child: IconButton(
                                  icon: Icon(Icons.search),
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      search();
                                    } else {
                                      print("not ok");
                                    }
                                  },
                                  color: Colors.white,
                                  iconSize: 23,
                                ),
                                color: Color(0xFF005EA2),
                                textColor: Colors.white,
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    search();
                                  } else {
                                    print("not ok");
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ]),
              Container(
                margin: EdgeInsets.only(left: 10, top: 0, right: 20, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Orders',
                      style: GoogleFonts.poppins(
                        color: Color(0xFF005EA2),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        dialogbox();
                      },
                      child: Text(
                        'Show filters',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Color(0xFF005EA2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Divider(
                height: 0,
                thickness: 2,
                indent: 10,
                endIndent: 0,
                color: Colors.grey.shade400,
              ),
              orderListData.length > 0
                  ? SingleChildScrollView(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: orderListData.length,
                        itemBuilder: (context, i) => Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom:
                                  BorderSide(width: 1.0, color: Colors.grey),
                            ),
                            color: Colors.white,
                          ),
                          margin: EdgeInsets.only(
                              left: 10, top: 0, right: 0, bottom: 10),
                          child: Row(
                            children: [
                              orderListData.length > 0
                                  ? Expanded(
                                      flex: 3,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: 0,
                                            top: 0,
                                            right: 10,
                                            bottom: 0),
                                        height: 150,
                                        width: 100,
                                        child: Image.network(dotenv
                                                .get('API_URL') +
                                            '/api/service/' +
                                            (orderListData[i]["OrderItems"][0]
                                                        ["refProduct"][0]
                                                    ["largeImage"][0]["path"])
                                                .replaceAll(r'\', '/')),
                                        // Image.asset(productData[i].pimg),
                                      ),
                                    )
                                  : CircularProgressIndicator(),
                              orderListData.length > 0
                                  ? Expanded(
                                      flex: 7,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 0,
                                                top: 15,
                                                right: 0,
                                                bottom: 5),
                                            child: Text(
                                              orderListData[i]["OrderItems"][0]
                                                  ["refProduct"][0]["name"],
                                              style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 0,
                                                top: 0,
                                                right: 0,
                                                bottom: 5),
                                            child: Text(
                                              'by ' +
                                                  orderListData[i]["OrderItems"]
                                                      [0]["brand"][0]["name"],
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 0,
                                                top: 0,
                                                right: 0,
                                                bottom: 5),
                                            child: Text(
                                              '\$' +
                                                  orderListData[i]["OrderItems"]
                                                          [0]["refProductPrice"]
                                                      [0]["sellingPrice"],
                                              style: GoogleFonts.poppins(
                                                color: Color(0xFF005EA2),
                                                fontSize: 14,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 0,
                                                top: 0,
                                                right: 0,
                                                bottom: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'SKU :' +
                                                      orderListData[i]
                                                                  ["OrderItems"]
                                                              [0]["refProduct"]
                                                          [0]["skuId"],
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 0,
                                                top: 0,
                                                right: 0,
                                                bottom: 5),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  orderListData[i]
                                                      ["orderStatus"]["value"],
                                                  style: GoogleFonts.poppins(
                                                    color: Color(0xFF005EA2),
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                        ],
                                      ),
                                    )
                                  : CircularProgressIndicator(),
                              orderListData.length > 0
                                  ? Expanded(
                                      flex: 1,
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            left: 0,
                                            top: 0,
                                            right: 0,
                                            bottom: 0),
                                        height: 150,
                                        width: 100,
                                        child: IconButton(
                                          icon: Icon(Icons.arrow_forward_ios),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                PageTransition(
                                                    type: PageTransitionType
                                                        .rightToLeft,
                                                    child: orderFullDetails(
                                                        orderid:
                                                            orderListData[i]
                                                                ["id"],
                                                        invoidpath: orderListData[
                                                                            i][
                                                                        "invoice"]
                                                                    ["path"] ==
                                                                null
                                                            ? ''
                                                            : orderListData[i]
                                                                    ["invoice"]
                                                                ["path"])));
                                          },
                                          color: Colors.black,
                                          iconSize: 28,
                                        ),
                                      ),
                                    )
                                  : CircularProgressIndicator(),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(' '),
                    )
            ],
          ),
        ),
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
