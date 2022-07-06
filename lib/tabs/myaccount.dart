import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localstorage/localstorage.dart';
import 'package:page_transition/page_transition.dart';

import '../address/addressinfo.dart';
import '../main.dart';
import '../notification/notification_page.dart';
import '../orders/order_info.dart';
import 'package:http/http.dart' as http;

import 'dashboard.dart';
import 'product_list.dart';

class myaccountpage extends StatefulWidget {
  const myaccountpage({Key? key}) : super(key: key);

  @override
  _myaccountpageState createState() => _myaccountpageState();
}

class _myaccountpageState extends State<myaccountpage> {
  int _selectedIndex = 1;
  final LocalStorage storage = new LocalStorage('seller_app');
  List address = [];
  var reflogoId;
  var imagepath;

  accountInformation() async {
    print('hi karthik');
    print(storage.getItem('people'));
    var refUserId = storage.getItem('people')["refUserId"];
    var refAccountId = storage.getItem('people')["refAccountId"];
    var refOrganizationId = storage.getItem('people')["refOrganizationId"];
    print(refUserId);
    print(refAccountId);
    print(refOrganizationId);

    var res = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?type=Organization&options=keyValues&id=' +
          refOrganizationId),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //print('response');
    //print(res);
    final responseFormat = json.decode(res.body);
    final data = responseFormat["data"];
    address = data.toList();
    print(address);
    print(address[0]["refLogo"]);
    var res1 = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?type=Media&options=keyValues&id=' +
          address[0]["refLogo"]),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    final responseFormat1 = json.decode(res1.body);
    final datalogo = responseFormat1["data"];
    print(datalogo[0]["path"]);

    setState(() {
      imagepath = datalogo[0]["path"];
      print(imagepath);
    });
    return address;

    //
  }

  // getImage(refid) async {
  //
  // }

  void initState() {
    // print(storage.getItem('people'));
    accountInformation().then((data) {
      setState(() {
        address = data;
        print(address[0]["refLogo"]);
      });
    });

    // setState(() {
    //   accountInformation();
    // });
    super.initState();
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
                'Hello, ' +
                    (storage.getItem('people')["name"] != null
                        ? storage.getItem('people')["name"]
                        : ''),
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
                  Navigator.push(
                      context,
                      PageTransition(
                          type: PageTransitionType.rightToLeft,
                          child: MyApp()));
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
            child: address.length > 0
                ? ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: address.length,
                    itemBuilder: (context, index) => Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 1.0,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: 20, top: 0, right: 20, bottom: 0),
                          child: Text(
                            'Account Information',
                            style: GoogleFonts.poppins(
                                fontSize: 22, fontWeight: FontWeight.w500),
                          ),
                        ),
                        Container(
                          height: 150,
                          width: 120,
                          margin: EdgeInsets.only(
                              left: 20, top: 10, right: 20, bottom: 0),
                          child:
                              // Image.asset('images/plogo.jpg')
                              //http://localhost:8000/api/service/assets/logo/buyer.png
                              // Image.network(
                              //     'http://3.93.153.180:8000/api/service/assets/uploads/file-1650816259522.png'),
                              Image.network(dotenv.get('API_URL') +
                                  '/api/service/' +
                                  imagepath.replaceAll(r'\', '/')),
                        ),
                        // Text(imagepath),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Table(
                            columnWidths: const {
                              0: FixedColumnWidth(140),
                              //0: FlexColumnWidth(),
                              1: FlexColumnWidth(),
                            },
                            children: [
                              TableRow(children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Legal Name',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(address[index]["legalName"]),
                                ),
                              ]),
                              TableRow(children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Email',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(address[index]["email"]),
                                ),
                              ]),
                              TableRow(children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Website',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(address[index]["website"]),
                                ),
                              ]),
                              TableRow(children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Telephone Number',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(address[index]["telephone"]),
                                ),
                              ]),
                              TableRow(children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Brands',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Bambinos'),
                                ),
                              ]),
                            ],
                            border:
                                TableBorder.all(width: 0, color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          height: 16.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Card(
                              elevation: 5.0,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: orderInfo()));
                                  print("Container clicked");
                                },
                                child: Container(
                                  height: 160,
                                  width: 160,
                                  //constraints: BoxConstraints.loose(const Size(160, 160)),
                                  padding: const EdgeInsets.all(35),
                                  color: Color(0xFFE5F6F5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ImageIcon(
                                        AssetImage("images/shop_card.png"),
                                        color: Color(0xFF005EA2),
                                        size: 60,
                                      ),
                                      Text(
                                        'Orders',
                                        style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              elevation: 5.0,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: addressInfo()));
                                  print("Container clicked");
                                },
                                child: Container(
                                  // constraints: BoxConstraints.loose(const Size(160, 160)),
                                  //padding: const EdgeInsets.all(25),
                                  height: 160,
                                  width: 160,
                                  color: Color(0xFFE5F6F5),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.location_on),
                                        onPressed: () {},
                                        color: Color(0xFF005EA2),
                                        iconSize: 50,
                                      ),
                                      Text(
                                        'Manage Address',
                                        style: GoogleFonts.poppins(
                                            color: Colors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Center(child: CircularProgressIndicator())),
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
