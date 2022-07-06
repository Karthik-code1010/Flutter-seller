import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstorage/localstorage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../main.dart';
import 'package:http/http.dart' as http;

import '../tabs/dashboard.dart';

class createNewPassword extends StatefulWidget {
  final String vuid;
  const createNewPassword({Key? key, required this.vuid}) : super(key: key);

  @override
  _createNewPasswordState createState() => _createNewPasswordState();
}

class _createNewPasswordState extends State<createNewPassword> {
  final LocalStorage storage = new LocalStorage('seller_app');
  final _formKey = GlobalKey<FormState>();
  var vuid;
  var cpassword;
  var repassword;
  void initState() {
    print(dotenv.get('API_URL'));
  }

  Future save() async {
    print('hi karthik');

    final appId = storage.getItem('appid'); // Abolfazl
    final orgId = storage.getItem('orgid');
    print('func');
    print(vuid);
    print(cpassword);
    print(repassword);
    print(appId);
    print(orgId);
    var postObjPeople = {
      "password": {"type": "Property", "value": repassword}
    };
    var res = await http.patch(
      Uri.parse(
          dotenv.get('API_URL') + '/api/service/entities/' + vuid + '/User'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(postObjPeople),
    );
    final responseFormat = json.decode(res.body);
    final data = responseFormat["data"];
    if (data.length > 0) {
      //print(data);
      var res1 = await http.get(
        Uri.parse(dotenv.get('API_URL') +
            '/api/service/entities?type=People&options=keyValues&q=refUserId==' +
            vuid +
            ';refAccountId==' +
            orgId +
            ';refApplicationId==' +
            appId),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      final responseFormat1 = json.decode(res1.body);
      final data1 = responseFormat1["data"];
      if (data1.length > 0) {
        print(data1);
        storage.setItem('people', data1[0]);
        showTopSnackBar(
          context,
          CustomSnackBar.success(
            message: "Signed in successfully",
          ),
        );
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft, child: productPage()));
      }
    }

    // storage.deleteItem('family');
    // storage.deleteItem('name');
  }

  @override
  Widget build(BuildContext context) {
    String someString = '${widget.vuid}';
    vuid = someString;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Text(widget.vuid),
            SizedBox(
              height: 20.0,
            ),
            Container(
              height: 150,
              width: 220,
              color: Colors.white,
              child: Image(
                image: AssetImage('images/innoart.png'),
              ),
            ),
            Card(
              elevation: 5.0,
              child: Container(
                constraints: BoxConstraints.loose(const Size(800, 800)),
                padding: const EdgeInsets.all(15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        transform: Matrix4.translationValues(0.0, 0.0, 0.0),
                        margin: EdgeInsets.only(
                            left: 0, top: 0, right: 20, bottom: 0),
                        child: Text(
                          'Create new password',
                          style: GoogleFonts.poppins(
                              fontSize: 26, fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'Create password',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: TextFormField(
                          controller: TextEditingController(text: cpassword),
                          onChanged: (value) {
                            cpassword = value;
                            print(cpassword);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter password ';
                            }
                            return null;
                          },
                          obscureText: true,
                          obscuringCharacter: "*",
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
                        'Re-type password',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: TextFormField(
                          controller: TextEditingController(text: repassword),
                          onChanged: (value) {
                            repassword = value;
                            print(repassword);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter password ';
                            } else if (cpassword != value) {
                              return 'Missmatch password';
                            } else {
                              return null;
                            }
                          },
                          obscureText: true,
                          obscuringCharacter: "*",
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
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(1),
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
                              child: Text('Save & Sign-in'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Card(
              color: Color(0xFFE5F6F5),
              elevation: 5.0,
              child: Container(
                constraints: BoxConstraints.loose(const Size(600, 300)),
                padding: const EdgeInsets.all(15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 20, right: 0, bottom: 10),
                      child: Text(
                        'Secure password tips: ',
                        style: GoogleFonts.poppins(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 0, right: 0, bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("• "),
                          Expanded(
                            child: Text(
                              'Use at least 8 characters. ',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 0, right: 0, bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("• "),
                          Expanded(
                            child: Text(
                                'compination numbers and letters is best.',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.normal)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 0, right: 5, bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("• "),
                          Expanded(
                            child: Text(
                                'Do not use dictionary words, your name, email address, mobile number or other persional information that can be easily abtained. ',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.normal)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          left: 20, top: 0, right: 0, bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text("• "),
                          Expanded(
                            child: Text(
                                'Do not use the same password for multiple online accounts. ',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.normal)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 100.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.copyright_rounded),
                  onPressed: () {},
                  color: Colors.grey,
                  iconSize: 20,
                ),
                Text(
                  '2022, Mathcur Inc.',
                  style: GoogleFonts.poppins(
                      color: Colors.grey, fontWeight: FontWeight.normal),
                ),
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}
