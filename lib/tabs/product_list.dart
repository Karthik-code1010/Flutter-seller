import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localstorage/localstorage.dart';
import 'package:page_transition/page_transition.dart';

import '../main.dart';
import '../model/product_model.dart';
import '../notification/notification_page.dart';
import '../product_details/edit_product.dart';
import '../product_details/view_product.dart';
import 'package:http/http.dart' as http;

import 'dashboard.dart';
import 'myaccount.dart';

class productList extends StatefulWidget {
  final String searchvalue;
  const productList({Key? key, required this.searchvalue}) : super(key: key);

  @override
  _productListState createState() => _productListState();
}

class _productListState extends State<productList> {
  final LocalStorage storage = new LocalStorage('seller_app');
  final _formKey = GlobalKey<FormState>();
  void initState() {
    print(widget.searchvalue);
    getinventoryStatus();
    getProductListView(widget.searchvalue);
    getInventryData();
  }

  List inventoryStatusList = [];
  getinventoryStatus() async {
    var ires = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?options=keyValues&type=CommonDataSet&q=name==Availablity'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //print('response');
    //print(res);
    final responseFormat = json.decode(ires.body);
    final idata = responseFormat["data"];
    setState(() {
      inventoryStatusList = idata;
    });
  }

  var dataCount;
  List productListData = [];
  Future search() async {
    print('hi karthik');
    print(searchname);
    setState(() {
      getProductListView(searchname);
    });
  }

  List instdata = [];

  getInventryData() async {
    var invenres = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?type=CommonDataSet&q=name==Availablity;&options=keyValues'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final responseFormatCountry = json.decode(invenres.body);
    final cresdata = responseFormatCountry["data"];
    //  print(cresdata);
    setState(() {
      instdata = cresdata;
      print(instdata);
    });
  }

  getProductListView(search) async {
    print(storage.getItem('people'));
    var refUserId = storage.getItem('people')["refUserId"];
    var refAccountId = storage.getItem('people')["refAccountId"];
    var refApplicationId = storage.getItem('people')["refApplicationId"];
    var refOrganizationId = storage.getItem('people')["refOrganizationId"];
    print(refUserId);
    print(refAccountId);
    print(refApplicationId);
    print(refOrganizationId);

    var res = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/getProductsCount?accountId=' +
          refOrganizationId +
          '&search=&inventoryStatus='),
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
          '/api/service/getProducts?accountId=' +
          refOrganizationId +
          '&limit=&offset=&search=' +
          search +
          '&inventoryStatus='),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //print('response');
    //print(res);
    final responseFormatProduct = json.decode(resproduct.body);
    final pdata = responseFormatProduct["data"];

    setState(() {
      productListData = pdata;
    });
    print(productListData);
  }

  int _selectedIndex = 2;
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

  var searchname = "";
  logout() {
    storage.deleteItem('appid');
    storage.deleteItem('orgid');
    storage.deleteItem('people');
    Navigator.push(context,
        PageTransition(type: PageTransitionType.rightToLeft, child: MyApp()));
  }

  bool keep = false;
  bool outofstock = false;
  fliter() async {
    print('fliter');
    print(inventoryStatus);
    var refUserId = storage.getItem('people')["refUserId"];
    var refAccountId = storage.getItem('people')["refAccountId"];
    var refApplicationId = storage.getItem('people')["refApplicationId"];
    var refOrganizationId = storage.getItem('people')["refOrganizationId"];
    print(refUserId);
    print(refAccountId);
    print(refApplicationId);
    var resproduct = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/getProducts?accountId=' +
          refOrganizationId +
          '&limit=&offset=&search=&inventoryStatus=' +
          inventoryStatus),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //print('response');
    //print(res);
    final responseFormatProduct = json.decode(resproduct.body);
    final pdata = responseFormatProduct["data"];

    setState(() {
      productListData = pdata;
    });
    Navigator.of(context).pop();
    print(productListData);
  }

  bool check = false;
  var isSelected;
  String inventoryStatus = "CommonDataSet-0203-004";
  dialogbox() {
    // return AwesomeDialog(
    //   btnOkColor: Color(0xFF005EA2),
    //   dialogBackgroundColor: Colors.grey.shade100,
    //   context: context,
    //   animType: AnimType.TOPSLIDE,
    //   dialogType: DialogType.QUESTION,
    //   headerAnimationLoop: false,
    //   showCloseIcon: true,
    //   customHeader: Image(
    //     image: AssetImage('images/innoart.png'),
    //   ),
    //   body: Column(
    //     mainAxisAlignment: MainAxisAlignment.start,
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: Text(
    //           'Inventory Status',
    //           style: TextStyle(
    //             fontWeight: FontWeight.bold,
    //             fontSize: 22,
    //           ),
    //         ),
    //       ),
    //       Row(
    //         children: [
    //           Checkbox(
    //             checkColor: Colors.white,
    //             activeColor: new Color(0xFF005EA2),
    //             value: keep,
    //             onChanged: (bool? value) {
    //               setState(() {
    //                 keep = value!;
    //               });
    //             },
    //           ),
    //           Text('Instock'),
    //         ],
    //       ),
    //       Row(
    //         children: [
    //           Checkbox(
    //             checkColor: Colors.white,
    //             activeColor: new Color(0xFF005EA2),
    //             value: outofstock,
    //             onChanged: (bool? value) {
    //               setState(() {
    //                 outofstock = value!;
    //               });
    //             },
    //           ),
    //           Text('Out Of Stock'),
    //         ],
    //       ),
    //     ],
    //   ),
    //   title: 'This is Ignored',
    //   desc: 'This is also Ignored',
    //   btnOkOnPress: () {
    //     fliter();
    //   },
    // )..show();
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
                    // CheckboxListTile(
                    //   title: Text("Instock"),
                    //   value: check,
                    //   onChanged: (bool? val) {
                    //     setState(() {
                    //       check = val!;
                    //     });
                    //   },
                    // ),
                    // CheckboxListTile(
                    //   title: Text("Out Of Stock"),
                    //   value: outofstock,
                    //   onChanged: (bool? val) {
                    //     setState(() {
                    //       outofstock = val!;
                    //     });
                    //   },
                    // ),
                    // ListView.builder(
                    //   physics: NeverScrollableScrollPhysics(),
                    //   shrinkWrap: true,
                    //   scrollDirection: Axis.vertical,
                    //   itemCount: instdata.length,
                    //   itemBuilder: (context, index) {
                    //     return RadioListTile<List>(
                    //       selected: isSelected,
                    //       groupValue: instdata,
                    //       value: instdata[index]["id"],
                    //       onChanged: (var value) {
                    //         setState(() {
                    //           isSelected = instdata[index]["id"];
                    //         });
                    //       },
                    //       title: new Text(instdata[index]["value"]),
                    //     );
                    //   },
                    // ),
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
                        value: inventoryStatus,
                        onChanged: (String? newValue) {
                          setState(() {
                            inventoryStatus = newValue!;
                            print(inventoryStatus);
                          });
                        },
                        // items: dropdownItems,
                        items: instdata.map((item) {
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
        child: Container(
          // Symetric Padding
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 9.0),
          child: Column(
            children: [
              SizedBox(
                height: 1.0,
              ),
              Row(children: <Widget>[
                Form(
                  key: _formKey,
                  child: Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: <Widget>[
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
                margin: EdgeInsets.only(left: 20, top: 0, right: 20, bottom: 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Product List',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF005EA2),
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
              Divider(
                height: 10,
                thickness: 2,
                indent: 10,
                endIndent: 0,
                color: Color(0xFD2E5EEFF),
              ),
              productListData.length > 0
                  ? SingleChildScrollView(
                      child: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: productListData.length,
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
                              Expanded(
                                flex: 3,
                                child: Container(
                                  height: 150,
                                  width: 100,
                                  child: Image.network(dotenv.get('API_URL') +
                                      '/api/service/' +
                                      (productListData[i]["largeImage"][0]
                                              ["path"])
                                          .replaceAll(r'\', '/')),
                                  //Image.asset(productData[i].pimg),
                                ),
                              ),
                              Expanded(
                                flex: 8,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 10,
                                          top: 15,
                                          right: 0,
                                          bottom: 5),
                                      child: Text(
                                        productListData[i]["name"],
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 10,
                                          top: 0,
                                          right: 0,
                                          bottom: 5),
                                      child: Text(
                                        'SKU : ' + productListData[i]["skuId"],
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                    // Container(
                                    //   margin: EdgeInsets.only(
                                    //       left: 10,
                                    //       top: 0,
                                    //       right: 0,
                                    //       bottom: 5),
                                    //   child: Text(
                                    //     productListData[i]["inventoryStatus"]
                                    //         ["value"],
                                    //     style: GoogleFonts.poppins(
                                    //       fontSize: 14,
                                    //       color: Colors.green,
                                    //       fontWeight: FontWeight.bold,
                                    //     ),
                                    //   ),
                                    // ),
                                    productListData[i]["inventoryStatus"]
                                                    ["value"]
                                                .toString() ==
                                            'Out Of Stock'
                                        ? Container(
                                            margin: EdgeInsets.only(
                                                left: 10,
                                                top: 0,
                                                right: 0,
                                                bottom: 5),
                                            child: Text(
                                              productListData[i]
                                                  ["inventoryStatus"]["value"],
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            margin: EdgeInsets.only(
                                                left: 10,
                                                top: 0,
                                                right: 0,
                                                bottom: 5),
                                            child: Text(
                                              productListData[i]
                                                  ["inventoryStatus"]["value"],
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                color: Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                    Container(
                                      width: 110,
                                      margin: EdgeInsets.only(
                                          left: 10,
                                          top: 0,
                                          right: 0,
                                          bottom: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Quantity',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          Text(
                                            productListData[i]["refInventory"]
                                                ["quantity"],
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 136,
                                      margin: EdgeInsets.only(
                                          left: 10,
                                          top: 0,
                                          right: 0,
                                          bottom: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Status',
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          Text(
                                            productListData[i]["status"]
                                                ["value"],
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          left: 10,
                                          top: 0,
                                          right: 0,
                                          bottom: 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            height: 28,
                                            width: 80,
                                            child: FlatButton(
                                              child: Text(
                                                'View',
                                                style:
                                                    TextStyle(fontSize: 14.0),
                                              ),
                                              color: Color(0xFF005EA2),
                                              textColor: Colors.white,
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    PageTransition(
                                                        type: PageTransitionType
                                                            .rightToLeft,
                                                        child: viewProduct(
                                                            prodid:
                                                                productListData[
                                                                    i]["id"])));
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
                                                'Edit',
                                                style:
                                                    TextStyle(fontSize: 14.0),
                                              ),
                                              color: Color(0xFF005EA2),
                                              textColor: Colors.white,
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    PageTransition(
                                                        type: PageTransitionType
                                                            .rightToLeft,
                                                        child: editProduct(
                                                            prodid:
                                                                productListData[
                                                                    i]["id"])));
                                              },
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        ' ',
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontStyle: FontStyle.italic),
                      ),
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
