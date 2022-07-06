import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstorage/localstorage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../main.dart';
import '../model/address_model.dart';
import '../notification/notification_page.dart';
import '../tabs/dashboard.dart';
import '../tabs/myaccount.dart';
import '../tabs/product_list.dart';
import 'addressinfo.dart';
import 'package:http/http.dart' as http;

class addAddress extends StatefulWidget {
  const addAddress({Key? key}) : super(key: key);

  @override
  _addAddressState createState() => _addAddressState();
}

class _addAddressState extends State<addAddress> {
  int _selectedIndex = 1;
  final LocalStorage storage = new LocalStorage('seller_app');
  final _formKey = GlobalKey<FormState>();

  var refid;
  Future save() async {
    print('hi karthik');
    print(refid);
    print(storage.getItem('people'));
    var refUserId = storage.getItem('people')["refUserId"];
    var refAccountId = storage.getItem('people')["refAccountId"];
    //applicationId
    var refApplicationId = storage.getItem('people')["refApplicationId"];
    print(refApplicationId);
    var postObjAddre = {
      "type": "Address",
      "name": {"type": "Property", "value": addre.fullname},
      "phoneNumber": {"type": "Property", "value": addre.mobilenumber},
      "country": {"type": "Relationship", "value": addre.county},
      "state": {"type": "Relationship", "value": addre.state},
      "city": {"type": "Relationship", "value": addre.city},
      "postOfficeBoxNumber": {"type": "Property", "value": addre.postboxNumber},
      "postalCode": {"type": "Property", "value": addre.zipcode},
      "streetAddress1": {"type": "Property", "value": addre.street},
      "streetAddress2": {"type": "Property", "value": ""},
      "refConnector": {"type": "Relationship", "value": refid},
      "refApplicationId": {"type": "Relationship", "value": refApplicationId},
      "refAccountId": {"type": "Relationship", "value": refAccountId}
    };
    print(postObjAddre);

    var addadress = await http.post(
      Uri.parse(dotenv.get('API_URL') + '/api/service/entities'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(postObjAddre),
    );
    final responseFormatAddress = json.decode(addadress.body);
    final dataAddress = responseFormatAddress["data"];
    print(dataAddress);
    if (dataAddress.length > 0) {
      showTopSnackBar(
        context,
        CustomSnackBar.success(
          message: "Save successfully",
        ),
      );
      //addressInfo
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft, child: addressInfo()));
    }
  }

  getRefShippingAddress() async {
    print(storage.getItem('people'));
    var refUserId = storage.getItem('people')["refUserId"];
    var refAccountId = storage.getItem('people')["refAccountId"];
    var refOrganizationId = storage.getItem('people')["refOrganizationId"];
    print(refUserId);
    print(refAccountId);
    var res = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?type=Organization&options=keyValues&id=' +
          refOrganizationId),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final responseFormat = json.decode(res.body);
    final data = responseFormat["data"];
    print(data);
    if (data.length > 0) {
      if (data[0]["refAddress"].length > 0) {
        setState(() {
          refid = data[0]["refAddress"];
          print(refid);
        });
        print(refid);
      } else {
        var postObj = {
          "type": "Connector",
          "connectorEntity": {"type": "Property", "value": "Media"}
        };
        var res2 = await http.post(
          Uri.parse(dotenv.get('API_URL') + '/api/service/entities'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(postObj),
        );
        final responseFormatJson = json.decode(res2.body);
        final data1 = responseFormatJson["data"];
        setState(() {
          refid = data1["id"];
          print(refid);
        });
        print(refid);
        var patchdata = {
          "refAddress": {"type": "Property", "value": data1["id"]}
        };

        var res3 = await http.patch(
          Uri.parse(dotenv.get('API_URL') +
              '/api/service/entities/' +
              data[0]["id"] +
              '/Organization'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(patchdata),
        );
        final responseFormat3 = json.decode(res3.body);
        final data3 = responseFormat3["data"];
        print(data3);
      }
    }
  }

  List countrydata = [];
  List statedata = [];
  List citydata = [];
  getCountryData() async {
    var countryres = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?type=Country&options=keyValues'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final responseFormatCountry = json.decode(countryres.body);
    final cresdata = responseFormatCountry["data"];
    //  print(cresdata);
    setState(() {
      countrydata = cresdata;
      //print(countrydata);
    });
  }

  getStateData() async {
    var countryres = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?type=State&options=keyValues'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final responseFormatCountry = json.decode(countryres.body);
    final cresdata = responseFormatCountry["data"];
    //  print(cresdata);
    setState(() {
      statedata = cresdata;
      //print(statedata);
    });
  }

  getCityData() async {
    var countryres = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?type=City&options=keyValues'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final responseFormatCountry = json.decode(countryres.body);
    final cresdata = responseFormatCountry["data"];
    //  print(cresdata);
    setState(() {
      citydata = cresdata;
      // print(citydata);
    });
  }

  void initState() {
    setState(() {
      getRefShippingAddress();
      getCountryData();
      getStateData();
      getCityData();
    });

    super.initState();
  }

  logout() {
    storage.deleteItem('appid');
    storage.deleteItem('orgid');
    storage.deleteItem('people');
    Navigator.push(context,
        PageTransition(type: PageTransitionType.rightToLeft, child: MyApp()));
  }

  addressAdd addre = addressAdd('', '', 'Country-0303-001', 'State-0903-002',
      'City-0903-002', '', '', '');

  String dropdownValue = 'California';
  String dropdownValue1 = 'USA';
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
              SizedBox(
                height: 1.0,
              ),
              Container(
                margin: EdgeInsets.only(left: 10, top: 0, right: 20, bottom: 0),
                child: Text(
                  'Add new address',
                  style: GoogleFonts.poppins(
                      fontSize: 22, fontWeight: FontWeight.w500),
                ),
              ),
              SingleChildScrollView(
                child: Card(
                  elevation: 5.0,
                  child: Container(
                    constraints: BoxConstraints.loose(const Size(900, 1200)),
                    padding: const EdgeInsets.all(15),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Full name ',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: TextFormField(
                              controller:
                                  TextEditingController(text: addre.fullname),
                              onChanged: (value) {
                                addre.fullname = value;
                                print(addre.fullname);
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter Full Name ';
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
                            height: 15.0,
                          ),
                          Text(
                            'Mobile number',
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
                                  text: addre.mobilenumber),
                              onChanged: (value) {
                                addre.mobilenumber = value;
                                print(addre.mobilenumber);
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
                            height: 10.0,
                          ),
                          Text(
                            'Country',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          DropdownButtonFormField(
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
                            value: addre.county,
                            onChanged: (String? newValue) {
                              setState(() {
                                addre.county = newValue!;
                                print(addre.county);
                              });
                            },
                            // items: dropdownItems,
                            items: countrydata.map((item) {
                              print(item["name"]);
                              print(item["id"]);
                              return new DropdownMenuItem(
                                child: new Text(item['name']),
                                value: item['id'].toString(),
                              );
                            }).toList(),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            'State',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          DropdownButtonFormField(
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
                            value: addre.state,
                            onChanged: (String? newValue) {
                              setState(() {
                                addre.state = newValue!;
                                print(addre.state);
                              });
                            },
                            //items: dropdownStateItems,
                            items: statedata.map((item) {
                              print(item["name"]);
                              print(item["id"]);
                              return new DropdownMenuItem(
                                child: new Text(item['name']),
                                value: item['id'].toString(),
                              );
                            }).toList(),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Text(
                            'City',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          DropdownButtonFormField(
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
                                value == null ? "Select a city" : null,
                            dropdownColor: Colors.blueAccent.shade100,
                            value: addre.city,
                            onChanged: (String? newValue) {
                              setState(() {
                                addre.city = newValue!;
                                print(addre.city);
                              });
                            },
                            // items: dropdownCityItems
                            items: citydata.map((item) {
                              print(item["name"]);
                              print(item["id"]);
                              return new DropdownMenuItem(
                                child: new Text(item['name']),
                                value: item['id'].toString(),
                              );
                            }).toList(),
                          ),
                          SizedBox(
                            height: 20.0,
                          ),
                          Text(
                            'Street',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: TextFormField(
                              controller:
                                  TextEditingController(text: addre.street),
                              onChanged: (value) {
                                addre.street = value;
                                print(addre.street);
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter street ';
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
                          Text(
                            'Post Office Box Number',
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
                                  text: addre.postboxNumber),
                              onChanged: (value) {
                                addre.postboxNumber = value;
                                print(addre.postboxNumber);
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter Post Office Box Number ';
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
                            'Postal Code/Zip Code',
                            style: GoogleFonts.poppins(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: TextFormField(
                              controller:
                                  TextEditingController(text: addre.zipcode),
                              onChanged: (value) {
                                addre.zipcode = value;
                                print(addre.zipcode);
                              },
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Enter Post Code ';
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
                            height: 10.0,
                          ),
                          Center(
                            child: Container(
                              width: 350,
                              height: 50,
                              child: RaisedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      PageTransition(
                                          type: PageTransitionType.rightToLeft,
                                          child: MyApp()));
                                },
                                color: Colors.blue.shade200,
                                textColor: Colors.white,
                                splashColor: Colors.blue,
                                child: Text('Make this default address'),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          Center(
                            child: Container(
                              width: 350,
                              height: 50,
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
                                  //         type: PageTransitionType.rightToLeft,
                                  //         child: MyApp()));
                                },
                                color: new Color(0xFF005EA2),
                                textColor: Colors.white,
                                splashColor: Colors.blue,
                                child: Text('Save'),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          )
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
