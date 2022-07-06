import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstorage/localstorage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import '../main.dart';
import '../model/create_user.dart';
import 'package:http/http.dart' as http;

class createAccount extends StatefulWidget {
  const createAccount({Key? key}) : super(key: key);

  @override
  _createAccountState createState() => _createAccountState();
}

class _createAccountState extends State<createAccount> {
  bool keep = false;
  final LocalStorage storage = new LocalStorage('seller_app');

  void initState() {
    print(dotenv.get('API_URL'));
    super.initState();
    asyncMethod();
  }

  var orgTypeId;
  var activeStatus;
  void asyncMethod() async {
    var resorg = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?type=OrganizationType&q=name==' +
          dotenv.get('APP_NAME') +
          '&options=keyValues'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final responseFOrg = json.decode(resorg.body);
    final dataOrgTypeId = responseFOrg["data"];
    print(dataOrgTypeId);
    if (dataOrgTypeId.length > 0) {
      setState(() {
        orgTypeId = dataOrgTypeId[0]["id"];
      });

      print(orgTypeId);
    }
    var resActiveSta = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?type=CommonDataSet&q=name==Status;value==Active&options=keyValues'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final responseFActSta = json.decode(resActiveSta.body);
    final dataActiveSta = responseFActSta["data"];
    print(dataActiveSta);
    if (dataActiveSta.length > 0) {
      setState(() {
        activeStatus = dataActiveSta[0]["id"];
      });

      print(activeStatus);
    }
  }

  Future save() async {
    print('hi karthik');
    final appId = storage.getItem('appid'); // Abolfazl
    final orgId = storage.getItem('orgid');
    print(appId);
    print(orgId);

    var res = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?type=User&q=username==' +
          cuser.emailphone),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final responseFormat = json.decode(res.body);
    final data = responseFormat["data"];
    if (data.length > 0) {
      print('already have');
      print(data[0]["username"]["value"]);
      showTopSnackBar(
        context,
        CustomSnackBar.error(
          message: "your mobile number or email address is already taken..",
        ),
      );
      // final snackBar = SnackBar(
      //   duration: Duration(seconds: 1, milliseconds: 100),
      //   behavior: SnackBarBehavior.floating,
      //   backgroundColor: Colors.red,
      //   content: const Text(
      //       'Your mobile number or email address is already taken..'),
      // );
      // // Find the ScaffoldMessenger in the widget tree
      // // and use it to show a SnackBar.
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      print('not found');
      var postObj = {
        "type": "User",
        "username": {"type": "Property", "value": cuser.emailphone},
        "password": {"type": "Property", "value": cuser.repassword},
        "salt": {"type": "Property", "value": ""},
        "status": {"type": "Relationship", "value": activeStatus}
      };

      print(postObj);
      var res2 = await http.post(
        Uri.parse(dotenv.get('API_URL') + '/api/service/entities'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(postObj),
      );
      final responseF2 = json.decode(res2.body);
      final data2 = responseF2["data"];

      if (data2.length > 0) {
        print(data2["id"]);
        final uidc = data2["id"];
        var postObjOrg = {
          "type": "Organization",
          "legalName": {"type": "Property", "value": cuser.uname},
          "refOrganizationType": {"type": "Relationship", "value": orgTypeId},
          "status": {"type": "Relationship", "value": activeStatus}
        };
        var resorg = await http.post(
          Uri.parse(dotenv.get('API_URL') + '/api/service/entities'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(postObjOrg),
        );
        final responseForg = json.decode(resorg.body);
        final dataorg = responseForg["data"];
        print('virat');
        print(dataorg);

        var postObjPeople = {
          "type": "People",
          "refUserId": {"type": "Relationship", "value": uidc},
          "name": {"type": "Property", "value": cuser.uname},
          "refAccountId": {"type": "Relationship", "value": orgId},
          "refApplicationId": {"type": "Relationship", "value": appId},
          "refOrganizationId": {"type": "Relationship", "value": dataorg["id"]}
        };
        //print(postObjPeople);
        var res3 = await http.post(
          Uri.parse(dotenv.get('API_URL') + '/api/service/entities'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(postObjPeople),
        );
        final responseF3 = json.decode(res3.body);
        final data3 = responseF3["data"];
        if (data3.length > 0) {
          showTopSnackBar(
            context,
            CustomSnackBar.success(
              message: "Your account has been created successfully",
            ),
          );
          // final snackBar = SnackBar(
          //   duration: Duration(seconds: 1, milliseconds: 100),
          //   behavior: SnackBarBehavior.floating,
          //   backgroundColor: Colors.green,
          //   content: const Text('Your account has been created successfully'),
          //   // action: SnackBarAction(
          //   //   label: 'Undo',
          //   //   onPressed: () {
          //   //     // Some code to undo the change.
          //   //   },
          //   // ),
          // );
          // // Find the ScaffoldMessenger in the widget tree
          // // and use it to show a SnackBar.
          // ScaffoldMessenger.of(context).showSnackBar(snackBar);

          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft, child: MyApp()));
        }
      }
    }
  }

  final _formKey = GlobalKey<FormState>();
  createUser cuser = createUser('', '', '', '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
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
            SingleChildScrollView(
              child: Card(
                elevation: 5.0,
                child: Container(
                  constraints: BoxConstraints.loose(const Size(900, 900)),
                  padding: const EdgeInsets.all(15),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Create Account',
                          style: GoogleFonts.poppins(
                              fontSize: 25, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(
                          height: 15.0,
                        ),
                        Text(
                          'Your name ',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: TextFormField(
                            key: Key('uname'),
                            controller:
                                TextEditingController(text: cuser.uname),
                            onChanged: (value) {
                              cuser.uname = value;
                              print(cuser.uname);
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter your username';
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
                          'Mobile number or email address ',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: TextFormField(
                            key: Key('pemail'),
                            controller:
                                TextEditingController(text: cuser.emailphone),
                            onChanged: (value) {
                              cuser.emailphone = value;
                              print(cuser.emailphone);
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter your email or phone number';
                              } else if (RegExp(
                                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
                                  .hasMatch(value)) {
                                return null;
                              } else {
                                return 'Enter valid email';
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
                          'Create Password',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: TextFormField(
                            key: Key('cpass'),
                            controller:
                                TextEditingController(text: cuser.cpassword),
                            onChanged: (value) {
                              cuser.cpassword = value;
                              print(cuser.cpassword);
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter your password';
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
                          height: 20.0,
                        ),
                        Text(
                          'Re-type Password',
                          style: GoogleFonts.poppins(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: TextFormField(
                            key: Key('repass'),
                            controller:
                                TextEditingController(text: cuser.repassword),
                            onChanged: (value) {
                              cuser.repassword = value;
                              print(cuser.repassword);
                            },
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter your password';
                              } else if (cuser.cpassword != value) {
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
                        Container(
                          transform: Matrix4.translationValues(-15.0, 0.0, 0.0),
                          margin: EdgeInsets.only(
                              left: 0, top: 0, right: 20, bottom: 0),
                          child: Row(
                            children: [
                              Checkbox(
                                checkColor: Colors.white,
                                activeColor: new Color(0xFF005EA2),
                                onChanged: (bool? value) {
                                  setState(() {
                                    keep = value!;
                                  });
                                },
                                value: keep,
                              ),
                              Text(
                                'I agree to the ',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.normal),
                              ),
                              Text(
                                'terms and conditions.',
                                style: GoogleFonts.poppins(
                                  color: new Color(0xFF005EA2),
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              Text(
                                '*',
                                style: TextStyle(color: Colors.red),
                              )
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(0),
                              child: RaisedButton(
                                key: Key('c_btn'),
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
                                child: Text('Create Account'),
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
            SizedBox(
              height: 15.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.normal),
                ),
                TextButton(
                  onPressed: () {
                    //action
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: MyApp()));
                  },
                  child: Text(
                    'Sign in.',
                    style: GoogleFonts.poppins(
                      color: new Color(0xFF005EA2),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30.0,
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
