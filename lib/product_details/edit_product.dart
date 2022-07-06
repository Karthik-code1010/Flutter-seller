import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstorage/localstorage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../main.dart';
import '../model/address_model.dart';
import '../model/editproduct.dart';
import '../notification/notification_page.dart';
import '../tabs/dashboard.dart';
import '../tabs/myaccount.dart';
import '../tabs/product_list.dart';
import 'package:http/http.dart' as http;

class editProduct extends StatefulWidget {
  final String prodid;
  const editProduct({Key? key, required this.prodid}) : super(key: key);

  @override
  _editProductState createState() => _editProductState();
}

class _editProductState extends State<editProduct> {
  final LocalStorage storage = new LocalStorage('seller_app');
  final _formKey = GlobalKey<FormState>();
  int _selectedIndex = 2;

  var prouniqId;
  String productPriceId = '';
  var InventryId;
  void initState() {
    setState(() {
      prouniqId = widget.prodid;
      print(prouniqId);
      getProductdetails();
      getInventryData();
      getStatusData();
    });
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
        editModel = editPList(
            pDetails[0]["refInventory"][0]["inventoryStatus"][0]["id"],
            pDetails[0]["status"][0]["id"],
            pDetails[0]["refInventory"][0]["quantity"],
            pDetails[0]["refProductPrice"][0]["mrp"],
            pDetails[0]["refProductPrice"][0]["sellingPrice"]);

        productPriceId = pDetails[0]["refProductPrice"][0]["id"].toString();
        InventryId = pDetails[0]["refInventory"][0]["id"];
      });

      //print('skkkkk' + productPriceId);
      //pDetails[0]["refInventory"][0]["inventoryStatus"][0]["value"]
      //pDetails[0]["status"][0]["value"]

    }
  }

  Future save() async {
    print('hi karthik');
    print(productPriceId);
    print(prouniqId);
    print(InventryId);
    print(storage.getItem('people'));
    var refUserId = storage.getItem('people')["refUserId"];
    var refAccountId = storage.getItem('people')["refAccountId"];
    //applicationId
    var refApplicationId = storage.getItem('people')["refApplicationId"];
    print(refApplicationId);
    print(editModel.inventoryStatus +
        ' ' +
        editModel.status +
        ' ' +
        editModel.quantity +
        ' ' +
        editModel.maximumretailprice +
        ' ' +
        editModel.sellingprice);

    var inventoryPatch = {
      "inventoryStatus": {
        "type": "Relationship",
        "value": editModel.inventoryStatus
      },
      "quantity": {"type": "Property", "value": editModel.quantity}
    };

    var statusPatch = {
      "status": {"type": "Relationship", "value": editModel.status}
    };
    var productPricePatch = {
      "mrp": {"type": "Property", "value": editModel.maximumretailprice},
      "sellingPrice": {"type": "Property", "value": editModel.sellingprice}
    };

    var postObjAddre = {
      // "type": "status",
      "status": {"type": "Relationship", "value": editModel.status},
      "type": "Inventory",
      "inventoryStatus": {
        "type": "Relationship",
        "value": editModel.inventoryStatus
      },
      "quantity": {"type": "Property", "value": editModel.quantity},
      "type": "ProductPrice",
      "mrp": {"type": "Property", "value": editModel.maximumretailprice},
      "sellingPrice": {"type": "Property", "value": editModel.sellingprice},
    };
    //  print(postObjAddre);

    var pInvenres = await http.patch(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities/' +
          InventryId +
          '/Inventory'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(inventoryPatch),
    );
    final responseFormatNo = json.decode(pInvenres.body);
    final data1 = responseFormatNo["data"];

    var patchPres = await http.patch(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities/' +
          prouniqId +
          '/Product'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(statusPatch),
    );
    final responseFormatP = json.decode(patchPres.body);
    final data2 = responseFormatP["data"];

    var patchPPriceres = await http.patch(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities/' +
          productPriceId +
          '/ProductPrice'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(productPricePatch),
    );
    final responseFormatPrice = json.decode(patchPPriceres.body);
    final data3 = responseFormatPrice["data"];
    if (data3.length > 0) {
      showTopSnackBar(
        context,
        CustomSnackBar.success(
          message: "Product added successfully",
        ),
      );

      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: productList(
                searchvalue: '',
              )));
    }

    // if (data3.length > 0) {
    //   showTopSnackBar(
    //     context,
    //     CustomSnackBar.success(
    //       message: "Product added successfully",
    //     ),
    //   );
    //
    //   Navigator.push(
    //       context,
    //       PageTransition(
    //           type: PageTransitionType.rightToLeft, child: productList()));
    // }
  }

  List instdata = [];
  List statusdata = [];

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

  getStatusData() async {
    var statusres = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?type=CommonDataSet&q=name==Status;&options=keyValues'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final responseFormatCountry = json.decode(statusres.body);
    final cresdata = responseFormatCountry["data"];
    //  print(cresdata);
    setState(() {
      statusdata = cresdata;
      //  print(statusdata);
    });
  }

  editPList editModel = editPList('CommonDataSet-0203-004',
      'CommonDataSet-0203-008', '28 Nos', '39.99', '29.99');

  String dropdownValue = 'Active';
  String dropdownValue1 = 'In stock';
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 0.0,
              ),
              SingleChildScrollView(
                child: Card(
                  elevation: 5.0,
                  child: Container(
                    constraints: BoxConstraints.loose(const Size(900, 900)),
                    padding: EdgeInsets.all(15),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Inventory Information',
                            style: GoogleFonts.poppins(
                                fontSize: 25, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            'Inventory Status',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
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
                              dropdownColor: Colors.blueAccent.shade100,
                              value: editModel.inventoryStatus,
                              onChanged: (String? newValue) {
                                setState(() {
                                  editModel.inventoryStatus = newValue!;
                                  print(editModel.inventoryStatus);
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
                          SizedBox(
                            height: 15.0,
                          ),
                          Text(
                            'Status',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
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
                                  value == null ? "Select a state" : null,
                              dropdownColor: Colors.blueAccent.shade100,
                              value: editModel.status,
                              onChanged: (String? newValue) {
                                setState(() {
                                  editModel.status = newValue!;
                                  print(editModel.status);
                                });
                              },
                              //items: dropdownStateItems,
                              items: statusdata.map((item) {
                                print(item["value"]);
                                print(item["id"]);
                                return new DropdownMenuItem(
                                  child: new Text(item['value']),
                                  value: item['id'].toString(),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            'Quantity',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: TextFormField(
                              controller: TextEditingController(
                                  text: editModel.quantity),
                              onChanged: (value) {
                                editModel.quantity = value;
                                print(editModel.quantity);
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter Mobile Number ';
                                } else {
                                  return null;
                                }
                              },
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
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            'Pricing Information',
                            style: GoogleFonts.poppins(
                                fontSize: 25, fontWeight: FontWeight.w500),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            'Maximum retail price',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: TextFormField(
                              controller: TextEditingController(
                                  text: editModel.maximumretailprice),
                              onChanged: (value) {
                                editModel.maximumretailprice = value;
                                print(editModel.maximumretailprice);
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter Mobile Number ';
                                } else {
                                  return null;
                                }
                              },
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
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            'Selling Price',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: TextFormField(
                              controller: TextEditingController(
                                  text: editModel.sellingprice),
                              onChanged: (value) {
                                editModel.sellingprice = value;
                                print(editModel.sellingprice);
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter Mobile Number ';
                                } else {
                                  return null;
                                }
                              },
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
                            ),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: RaisedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      save();
                                    } else {
                                      print("not ok");
                                    }
                                    // Navigator.push(
                                    //     context,
                                    //     PageTransition(
                                    //         type:
                                    //             PageTransitionType.rightToLeft,
                                    //         child: MyApp()));
                                  },
                                  color: new Color(0xFF005EA2),
                                  textColor: Colors.white,
                                  splashColor: Colors.blue,
                                  child: Text('Save'),
                                ),
                              ),
                              SizedBox(
                                width: 40,
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0),
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        PageTransition(
                                            type:
                                                PageTransitionType.rightToLeft,
                                            child: productList(
                                              searchvalue: '',
                                            )));
                                  },
                                  color: new Color(0xFF005EA2),
                                  textColor: Colors.white,
                                  splashColor: Colors.blue,
                                  child: Text('Cancel'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
