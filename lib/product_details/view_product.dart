import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstorage/localstorage.dart';
import 'package:page_transition/page_transition.dart';

import '../main.dart';
import '../notification/notification_page.dart';
import '../tabs/myaccount.dart';
import '../tabs/dashboard.dart';
import '../tabs/product_list.dart';
import 'package:http/http.dart' as http;

class viewProduct extends StatefulWidget {
  final String prodid;
  const viewProduct({Key? key, required this.prodid}) : super(key: key);

  @override
  _viewProductState createState() => _viewProductState();
}

class _viewProductState extends State<viewProduct> {
  final LocalStorage storage = new LocalStorage('seller_app');
  int _selectedIndex = 2;
  var prouniqId;
  void initState() {
    setState(() {
      prouniqId = widget.prodid;
      print(prouniqId);
    });

    getProductdetails();
  }

  List pDetails = [];
  getProductdetails() async {
    var res = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/getProductById?id=' +
          prouniqId),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //print('response');
    //print(res);
    final responseFormat = json.decode(res.body);
    final data = responseFormat["data"];
    if (data.length > 0) {
      setState(() {
        pDetails = data.toList();
      });
      print(pDetails);
    }
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
            child: pDetails.length > 0
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 0.0,
                      ),
                      Row(children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              child: productList(
                                                searchvalue: '',
                                              )));
                                    },
                                    color: Colors.black,
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    height: 34.0,
                                    child: TextField(
                                      decoration: InputDecoration(
                                          labelText: 'Search products',
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
                                        onPressed: () {},
                                        color: Colors.white,
                                        iconSize: 23,
                                      ),
                                      color: Color(0xFF005EA2),
                                      textColor: Colors.white,
                                      onPressed: () {},
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ]),
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 0, right: 20, bottom: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              pDetails[0]["name"],
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF005EA2),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 10,
                        thickness: 2,
                        indent: 10,
                        endIndent: 0,
                        color: Color(0xFD2E5EEFF),
                      ),
                      Center(
                        child: Container(
                          height: 200,
                          width: 150,
                          margin: EdgeInsets.only(
                              left: 20, top: 20, right: 20, bottom: 0),
                          child: Image.network(dotenv.get('API_URL') +
                              '/api/service/' +
                              (pDetails[0]["smallImage"][0]["path"])
                                  .replaceAll(r'\', '/')),
                          // Image(
                          //   image: AssetImage('images/p1.png'),
                          // ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 15, right: 20, bottom: 0),
                        child: Text(
                          'Product Information',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF005EA2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Table(
                          columnWidths: const {
                            0: FixedColumnWidth(110),
                            1: FlexColumnWidth(),
                          },
                          children: [
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Product SKU',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(pDetails[0]["skuId"]),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Product Name',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(pDetails[0]["name"]),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Brand',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(pDetails[0]["brand"][0]["name"]),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Is Featured',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child:
                                    Text(pDetails[0]["isFeatured"][0]["value"]),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'New Arrival',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child:
                                    Text(pDetails[0]["newArrival"][0]["value"]),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Category',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(pDetails[0]["refCatalogue"][0]
                                    ["name"]), //refCatalogue
                              ),
                            ])
                          ],
                          border:
                              TableBorder.all(width: 0, color: Colors.white),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 5, right: 20, bottom: 0),
                        child: Text(
                          'Inventory Information',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF005EA2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Table(
                          columnWidths: const {
                            0: FixedColumnWidth(170),
                            1: FlexColumnWidth(),
                          },
                          children: [
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Inventory Status',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(pDetails[0]["refInventory"][0]
                                    ["inventoryStatus"][0]["value"]),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Status',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(pDetails[0]["status"][0]["value"]),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Quantity',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(pDetails[0]["refInventory"][0]
                                        ["quantity"] +
                                    ' Nos'),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Minimum quantity to order',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(pDetails[0]
                                        ["minimumQuantityToOrder"] +
                                    ' Nos'),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Maximum quantity to order',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(pDetails[0]
                                        ["maximumQuantityToOrder"] +
                                    ' Nos'),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Managed Inventory',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(pDetails[0]["managedInventory"][0]
                                    ["value"]),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Low inventory threshold',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child:
                                    Text(pDetails[0]["lowInventoryThreshold"]),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Highlight low inventory threshold',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(pDetails[0]["highlightLowInventory"]
                                    [0]["value"]),
                              ),
                            ]),
                          ],
                          border:
                              TableBorder.all(width: 0, color: Colors.white),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(
                            left: 20, top: 5, right: 20, bottom: 0),
                        child: Text(
                          'Pricing Information',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF005EA2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Table(
                          columnWidths: {
                            0: FixedColumnWidth(170),
                            1: FlexColumnWidth(),
                          },
                          children: [
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Maximum retail price',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('\$' +
                                    pDetails[0]["refProductPrice"][0]["mrp"]),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Selling Price',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('\$' +
                                    pDetails[0]["refProductPrice"][0]
                                        ["sellingPrice"]),
                              ),
                            ]),
                            TableRow(children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Tax Code',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child:
                                    Text(pDetails[0]["tax"][0]["displayName"]),
                              ),
                            ]),
                          ],
                          border:
                              TableBorder.all(width: 0, color: Colors.white),
                        ),
                      )
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(),
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
