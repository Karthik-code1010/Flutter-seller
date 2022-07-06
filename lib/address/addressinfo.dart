import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstorage/localstorage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../main.dart';
import '../notification/notification_page.dart';
import '../orders/order_info.dart';
import '../tabs/dashboard.dart';
import '../tabs/myaccount.dart';
import '../tabs/product_list.dart';
import 'addaddress.dart';
import 'editAddress.dart';
import 'package:http/http.dart' as http;

class addressInfo extends StatefulWidget {
  const addressInfo({Key? key}) : super(key: key);

  @override
  _addressInfoState createState() => _addressInfoState();
}

class _addressInfoState extends State<addressInfo> {
  int _selectedIndex = 1;
  final LocalStorage storage = new LocalStorage('seller_app');

  List addInfo = [];
  void initState() {
    print('hi karthik');

    getAddressInfo().then((data) {
      setState(() {
        addInfo = data;
        print(addInfo);
      });
    });
    super.initState();
  }

  getAddressInfo() async {
    print(storage.getItem('people'));
    var refUserId = storage.getItem('people')["refUserId"];
    var refAccountId = storage.getItem('people')["refAccountId"];
    var refApplicationId = storage.getItem('people')["refApplicationId"];
    print(refUserId);
    print(refAccountId);
    print(refApplicationId);

    var res = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/getMyAddress?shippingAddress=no&userId=' +
          refUserId +
          '&accountId=' +
          refAccountId +
          '&applicationId=' +
          refApplicationId),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //print('response');
    //print(res);
    final responseFormat = json.decode(res.body);
    final data = responseFormat["data"];
    addInfo = data.toList();

    return addInfo;
  }

  logout() {
    storage.deleteItem('appid');
    storage.deleteItem('orgid');
    storage.deleteItem('people');
    Navigator.push(context,
        PageTransition(type: PageTransitionType.rightToLeft, child: MyApp()));
  }

  defaultClick(aid) async {
    print(aid);
    for (var i = 0; i < addInfo.length; i++) {
      print(aid == addInfo[i]["id"]);
      print(addInfo[i]["id"]);
      if (aid == addInfo[i]["id"]) {
        var patchdata = {
          "isDefault": {"type": "Property", "value": "Yes"}
        };
        var pres = await http.patch(
          Uri.parse(dotenv.get('API_URL') +
              '/api/service/entities/' +
              addInfo[i]["id"] +
              '/Address'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(patchdata),
        );
        final responseFormat3 = json.decode(pres.body);
        final data3 = responseFormat3["data"];
      } else {
        var patchdata1 = {
          "isDefault": {"type": "Property", "value": "No"}
        };
        var pnores = await http.patch(
          Uri.parse(dotenv.get('API_URL') +
              '/api/service/entities/' +
              addInfo[i]["id"] +
              '/Address'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(patchdata1),
        );
        final responseFormatNo = json.decode(pnores.body);
        final data3 = responseFormatNo["data"];
      }
    }

    showTopSnackBar(
      context,
      CustomSnackBar.success(
        message: "Set as default successfully",
      ),
    );
    //addressInfo
    Navigator.push(
        context,
        PageTransition(
            type: PageTransitionType.rightToLeft, child: addressInfo()));
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
                child: Text(
                  'Manage Addresses',
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ),
              addInfo.length > 0
                  ? ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: addInfo.length,
                      itemBuilder: (context, i) => Container(
                        constraints: BoxConstraints.loose(const Size(400, 350)),
                        padding: const EdgeInsets.all(15),
                        child: Card(
                          elevation: 5,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(15),
                                child: Table(
                                  columnWidths: const {
                                    // 0: FixedColumnWidth(140),
                                    //0: FlexColumnWidth(),
                                    1: FlexColumnWidth(),
                                  },
                                  children: [
                                    TableRow(children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(addInfo[i]["name"]),
                                      ),
                                    ]),
                                    TableRow(children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(addInfo[i]
                                                ["postOfficeBoxNumber"] +
                                            ', ' +
                                            addInfo[i][
                                                "streetAddress1"]), //"postOfficeBoxNumber""streetAddress1"
                                      ),
                                    ]),
                                    TableRow(children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(addInfo[i]["city"]["name"] +
                                            ', ' +
                                            addInfo[0][
                                                "postalCode"]), //city //"postalCode"
                                      ),
                                    ]),
                                    TableRow(children: [
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text(addInfo[i]["country"]
                                            ["name"]), //"country"
                                      ),
                                    ]),
                                  ],
                                  border: TableBorder.all(
                                      width: 0, color: Colors.white),
                                ),
                              ),
                              Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2, color: Color(0xFF005EA2)),
                                  ),
                                  width: 300,
                                  height: 40,
                                  child: RaisedButton(
                                    onPressed: () {
                                      //editAddress
                                      Navigator.push(
                                          context,
                                          PageTransition(
                                              type: PageTransitionType
                                                  .rightToLeft,
                                              child: editAddress(
                                                editid: addInfo[i]["id"],
                                              )));
                                    },
                                    color: Colors.white,
                                    textColor: Color(0xFF005EA2),
                                    splashColor: Colors.blue,
                                    child: Text('Edit this address'),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: addInfo[i]["isDefault"] != 'Yes'
                                    ? Container(
                                        width: 300,
                                        height: 40,
                                        child: RaisedButton(
                                          disabledColor: Color(0xFF006EC1)
                                              .withOpacity(0.19),
                                          disabledTextColor: Color(0xFF006EC1)
                                              .withOpacity(0.80),
                                          onPressed: () {
                                            defaultClick(addInfo[i]["id"]);
                                          },
                                          child:
                                              Text('Make this default address'),
                                        ),
                                      )
                                    : Center(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Center(child: Text('')),
              SizedBox(
                height: 18.0,
              ),
              Center(
                child: Container(
                  width: 300,
                  height: 40,
                  child: RaisedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: addAddress()));
                    },
                    color: new Color(0xFF005EA2),
                    textColor: Colors.white,
                    splashColor: Colors.blue,
                    child: Text('Add new address'),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
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
