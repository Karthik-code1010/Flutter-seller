import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localstorage/localstorage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:seller/tabs/product_list.dart';
//import 'package:flutter_breadcrumb/flutter_breadcrumb.dart';

import '../main.dart';
import 'package:http/http.dart' as http;

import '../notification/notification_page.dart';
import '../orders/order_info.dart';
import 'myaccount.dart';

//import 'model/product_model.dart';

class productPage extends StatefulWidget {
  const productPage({Key? key}) : super(key: key);

  @override
  _productPageState createState() => _productPageState();
}

class _productPageState extends State<productPage> {
  final LocalStorage storage = new LocalStorage('seller_app');
  var productCount = 0;
  var cancelOrderCount = 0;
  var orderValue;
  var orderCount = 0;
  final _formKey = GlobalKey<FormState>();
  // List dash = [];

  void initState() {
    print('dasboard');
    print(storage.getItem('appid'));
    print(storage.getItem('orgid'));

    productCountFunc();

    super.initState();
  }

  productCountFunc() async {
    print('hi karthik');
    print(storage.getItem('people'));
    var refUserId = storage.getItem('people')["refUserId"];
    var refAccountId = storage.getItem('people')["refAccountId"];
    var refOrganizationId = storage.getItem('people')["refOrganizationId"];
    print(refUserId);
    print(refAccountId);
    var res = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?type=Product&options=count&q=refSellerId==' +
          refOrganizationId),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //print('response');
    //print(res);
    final responseFormat = json.decode(res.body);
    setState(() {
      productCount = responseFormat["data"];
      // dash.add(productCount);
      //print(responseFormat["data"]);
    });

    print(productCount);

    var res2 = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/getSellerCancelOrdersCount?accountId=' +
          refOrganizationId),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //print('response');
    //print(res);
    final responseFormat2 = json.decode(res2.body);
    setState(() {
      cancelOrderCount = responseFormat2["data"];
      // dash.add(cancelOrderCount);
    });

    print(cancelOrderCount);
    var res3 = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/getSellerOrdersValue?accountId=' +
          refOrganizationId),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //print('response');
    //print(res);
    final responseFormat3 = json.decode(res3.body);
    setState(() {
      orderValue = responseFormat3["data"];
      // orderValue = double.parse(responseFormat3["data"]).toStringAsFixed(2);
      //toStringAsFixed(3)
      //  dash.add(orderValue);
    });

    print(orderValue);

    var res4 = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/getSellerOrdersCount?accountId=' +
          refOrganizationId),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //print('response');
    //print(res);
    final responseFormat4 = json.decode(res4.body);
    setState(() {
      orderCount = responseFormat4["data"];
      //dash.add(orderCount);
    });

    print(orderCount);
    print('list value');
    // print(dash);
  }

  int _selectedIndex = 0;

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

  var searchname;
  search() async {
    print('hi karthik');
    print(searchname);
    if (searchname != null) {
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: productList(searchvalue: searchname)));
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
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 5.0),
            child: Column(
              children: [
                SizedBox(
                  height: 1.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      margin: new EdgeInsets.symmetric(horizontal: 12.0),
                      child: Text(
                        'Dashboard',
                        style: GoogleFonts.poppins(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF005EA2),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 0.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FittedBox(
                      child: Card(
                        color: Color(0xFF005EA2),
                        child: Container(
                          constraints:
                              BoxConstraints.loose(const Size(170, 205)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 10.0),
                              ImageIcon(
                                AssetImage("images/shop_card.png"),
                                color: Colors.white,
                                size: 48,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: orderInfo()));
                                },
                                child: Text(
                                  'Total Orders',
                                  style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Container(
                                height: 30,
                                width: 80,
                                child: FittedBox(
                                  child: Center(
                                    child: Text(
                                      orderCount.toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF006EC1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6)),
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Text(
                                  'Total Orders placed as on date',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    FittedBox(
                      child: Card(
                        color: Color(0xFF005EA2),
                        child: Container(
                          constraints:
                              BoxConstraints.loose(const Size(170, 205)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 10.0),
                              ImageIcon(
                                AssetImage("images/cancel.png"),
                                color: Colors.white,
                                size: 48,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: orderInfo()));
                                },
                                child: Text(
                                  'Cancelled Orders',
                                  style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Container(
                                height: 30,
                                width: 80,
                                child: FittedBox(
                                  child: Center(
                                    child: Text(
                                      cancelOrderCount.toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF006EC1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6)),
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Text(
                                  'Total cancelled orders as on date',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FittedBox(
                      child: Card(
                        color: Color(0xFF005EA2),
                        child: Container(
                          constraints:
                              BoxConstraints.loose(const Size(170, 205)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 10.0),
                              ImageIcon(
                                AssetImage("images/box.png"),
                                color: Colors.white,
                                size: 48,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: productList(
                                            searchvalue: '',
                                          )));
                                },
                                child: Text(
                                  'Total Products',
                                  style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Container(
                                height: 30,
                                width: 80,
                                child: FittedBox(
                                  child: Center(
                                    child: Text(
                                      productCount.toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF006EC1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6)),
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Text(
                                  'Total number of products added',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    FittedBox(
                      child: Card(
                        color: Color(0xFF005EA2),
                        child: Container(
                          constraints:
                              BoxConstraints.loose(const Size(170, 205)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 10.0),
                              ImageIcon(
                                AssetImage("images/money.png"),
                                color: Colors.white,
                                size: 48,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: orderInfo()));
                                },
                                child: Text(
                                  'Total Order Value',
                                  style: GoogleFonts.poppins(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.0),
                              Container(
                                height: 35,
                                width: 110,
                                child: FittedBox(
                                  child: Center(
                                    child:
                                        orderValue != null || orderValue == ''
                                            ? Text(
                                                '\$' +
                                                    double.parse(orderValue)
                                                        .toStringAsFixed(2),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 5,
                                                ),
                                              )
                                            : Text(
                                                '0',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                  ),
                                ),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF006EC1),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6)),
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Padding(
                                padding: EdgeInsets.all(7.0),
                                child: Text(
                                  '        Total order value as on date        ',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),

                SizedBox(
                  height: 10.0,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 9.0),
                  child: Row(
                    children: [
                      Text(
                        "Find your products in Mathcur's catalog",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF005EA2),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                // Row(
                //   children: [
                //     Container(
                //       margin: EdgeInsets.all(0),
                //       child: FlatButton(
                //         child: Text(
                //           'Search',
                //           style: TextStyle(fontSize: 20.0),
                //         ),
                //         color: Color(0xFF005EA2),
                //         textColor: Colors.white,
                //         onPressed: () {},
                //       ),
                //     ),
                //   ],
                // ),
                // TextField(
                //   decoration: InputDecoration(
                //       labelText: 'Search product names',
                //       enabledBorder: OutlineInputBorder(
                //         borderSide:
                //             const BorderSide(width: 1, color: Color(0xFF005EA2)),
                //         borderRadius: BorderRadius.circular(0),
                //       ),
                //       focusedBorder: OutlineInputBorder(
                //         borderSide:
                //             const BorderSide(width: 1, color: Color(0xFF005EA2)),
                //         borderRadius: BorderRadius.circular(0),
                //       )),
                // ),
                Container(
                  margin:
                      EdgeInsets.only(left: 0, top: 0, right: 10, bottom: 0),
                  child: Row(children: <Widget>[
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                flex: 5,
                                child: Container(
                                  height: 45.0,
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
                                              width: 1,
                                              color: Color(0xFF005EA2)),
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: const BorderSide(
                                              width: 1,
                                              color: Color(0xFF005EA2)),
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        )),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 45.0,
                                  decoration: BoxDecoration(
                                    // borderRadius: BorderRadius.circular(0.0),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(0.0)),
                                  ),
                                  child: FlatButton(
                                    child: Text(
                                      'Search',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    color: Color(0xFF005EA2),
                                    textColor: Colors.white,
                                    onPressed: () {
                                      search();
                                      // if (_formKey.currentState!.validate()) {
                                      //
                                      // } else {
                                      //   print("not ok");
                                      // }
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
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            )),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.navigate_before),
      //   onPressed: () {
      //     Navigator.of(context)
      //         .pop(MaterialPageRoute(builder: (context) => MyApp()));
      //   },
      // ),
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
