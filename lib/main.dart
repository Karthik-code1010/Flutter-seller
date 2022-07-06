import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:localstorage/localstorage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'login/create_account.dart';
import 'login/forgot_password.dart';
import 'model/user.dart';
import 'tabs/dashboard.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  await dotenv.load();

  runApp(new MaterialApp(
    debugShowCheckedModeBanner: false,
    home: new MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalStorage storage = new LocalStorage('seller_app');
  final _formKey = GlobalKey<FormState>();
  bool keep = false;
  void initState() {
    print(dotenv.get('API_URL'));
    super.initState();
    setState(() {
      asyncMethod();
    });
  }

  var orgTypeId;
  var activeStatus;
  var appId;
  var orgId;
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

    var response = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?type=Application&q=name==' +
          dotenv.get('APP_NAME') +
          '&options=keyValues'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final responseFor = json.decode(response.body);
    final dataApp = responseFor["data"];
    if (dataApp.length > 0) {
      print('initState method');
      // print(dataApp[0]["id"]);
      //print(dataApp[0]["refAccountId"]);
      setState(() {
        storage.setItem('appid', dataApp[0]["id"]);
        storage.setItem('orgid', dataApp[0]["refAccountId"]);
      });
    }
    print('async method');
    // print(storage.getItem('appid'));
    // print(storage.getItem('orgid'));
    // ....
    setState(() {
      appId = storage.getItem('appid');
      orgId = storage.getItem('orgid');
    });
    print(appId);
    print(orgId);
  }

  Future save() async {
    print('hi karthik');

    // final appId = storage.getItem('appid'); // Abolfazl
    // final orgId = storage.getItem('orgid');
    // var appId = storage.getItem('appid');
    // var orgId = storage.getItem('orgid');
    print(orgTypeId);
    print(activeStatus);
    print(appId);
    print(orgId);
    //print(dotenv.env['API_URL'] ?? 'API Not Found');
    print(dotenv.get('API_URL'));
    // storage.deleteItem('appid');
    // storage.deleteItem('orgid');

    var res = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?type=User&q=username==' +
          user.emailphone +
          ';password==' +
          user.password),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final responseFormat = json.decode(res.body);
    final data = responseFormat["data"];
    if (data.length > 0) {
      //print(data);
      //print(data[0]["id"]);
      final userId = data[0]["id"];
      var res1 = await http.get(
        Uri.parse(dotenv.get('API_URL') +
            '/api/service/entities?type=People&options=keyValues&q=refUserId==' +
            userId +
            ';refAccountId==' +
            orgId +
            ';refApplicationId==' +
            appId),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      final responseF = json.decode(res1.body);
      final data1 = responseF["data"];
      if (data1.length > 0) {
        //print(data1);
        storage.setItem('people', data1[0]);

        print(storage.getItem('people'));

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
      } else {
        var res2 = await http.get(
          Uri.parse(dotenv.get('API_URL') +
              '/api/service/entities?type=People&options=keyValues&q=refUserId==' +
              userId),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        final responseFor = json.decode(res2.body);
        final data2 = responseFor["data"];
        if (data2.length > 0) {
          print(data2[0]["name"]);
          print(data2[0]["refOrganizationId"]);
          var res3 = await http.get(
            Uri.parse(dotenv.get('API_URL') +
                '/api/service/entities?type=Organization&options=keyValues&id=' +
                data2[0]["refOrganizationId"]),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
          );
          final responseFor3 = json.decode(res3.body);
          final oldorgresponse = responseFor3["data"];
          var postObjOrg = {
            "type": "Organization",
            "legalName": {
              "type": "Property",
              "value": oldorgresponse[0]["legalName"]
                  ? oldorgresponse[0]["legalName"]
                  : ""
            },
            "email": {
              "type": "Property",
              "value":
                  oldorgresponse[0]["email"] ? oldorgresponse[0]["email"] : ""
            },
            "website": {
              "type": "Property",
              "value": oldorgresponse[0]["website"]
                  ? oldorgresponse[0]["website"]
                  : ""
            },
            "telephone": {
              "type": "Property",
              "value": oldorgresponse[0]["telephone"]
                  ? oldorgresponse[0]["telephone"]
                  : ""
            },
            "refOrganizationType": {"type": "Relationship", "value": orgTypeId},
            "status": {"type": "Relationship", "value": activeStatus}
          };
          var orgresponse = await http.post(
            Uri.parse(dotenv.get('API_URL') + '/api/service/entities'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(postObjOrg),
          );
          final responseForold4 = json.decode(orgresponse.body);
          final orgresponse4 = responseForold4["data"];
          print(orgresponse4);

          var postObjPeople = {
            "type": "People",
            "refUserId": {"type": "Relationship", "value": userId},
            "name": {"type": "Property", "value": data2[0]["name"]},
            "refAccountId": {"type": "Relationship", "value": orgId},
            "refApplicationId": {"type": "Relationship", "value": appId},
            "refOrganizationId": {
              "type": "Relationship",
              "value": orgresponse4["id"]
            }
          };
          var res5 = await http.post(
            Uri.parse(dotenv.get('API_URL') + '/api/service/entities'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(postObjPeople),
          );
          final responseForold5 = json.decode(res5.body);
          final orgresponse5 = responseForold5["data"];
          var res6 = await http.get(
            Uri.parse(dotenv.get('API_URL') +
                '/api/service/entities?type=People&options=keyValues&q=refUserId==' +
                userId +
                ';refAccountId==' +
                orgId +
                ';refApplicationId==' +
                appId +
                ' '),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
          );
          final responseFor6 = json.decode(res6.body);
          final dataLocal6 = responseFor6["data"];

          if (dataLocal6.length > 0) {
            storage.setItem('people', dataLocal6[0]);
            showTopSnackBar(
              context,
              CustomSnackBar.success(
                message: "Signed in successfully",
              ),
            );

            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: productPage()));
          }
        }
      }
    } else {
      print('not found');
      showTopSnackBar(
        context,
        CustomSnackBar.error(
          message:
              "Please enter registered mobile number or email address and password",
        ),
      );
      // final snackBar = SnackBar(
      //   duration: Duration(seconds: 1, milliseconds: 100),
      //   behavior: SnackBarBehavior.floating,
      //   backgroundColor: Colors.red,
      //   content: const Text(
      //       'Please enter registered mobile number or email address and password'),
      // );
      // // Find the ScaffoldMessenger in the widget tree
      // // and use it to show a SnackBar.
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // Initially password is obscure
  bool _obscureText = true;

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  User user = User('', '');
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            //Text(dotenv.env['API_URL'] ?? 'API URL Not Found'),
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
            // Text(orgTypeId.toString()),
            // Text(activeStatus.toString()),
            // Text(appId.toString()),
            // Text(orgId.toString()),

            Card(
              elevation: 5.0,
              child: Container(
                constraints: BoxConstraints.loose(const Size(600, 600)),
                padding: const EdgeInsets.all(15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sign in',
                        style: GoogleFonts.poppins(
                            fontSize: 30, fontWeight: FontWeight.w500),
                        //style: TextStyle(color: Colors.black, fontSize: 30),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        'Access your account',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.normal),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        'Email address or mobile phone number ',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: TextFormField(
                          key: Key('textformfield'),
                          controller:
                              TextEditingController(text: user.emailphone),
                          onChanged: (value) {
                            user.emailphone = value;
                            print(user.emailphone);
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
                            hintText: 'Email address or mobile phone number',
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
                        'Password',
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
                              TextEditingController(text: user.password),
                          onChanged: (value) {
                            user.password = value;
                            print(user.password);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter your password ';
                            }
                            return null;
                          },
                          obscureText: _obscureText,
                          obscuringCharacter: "*",
                          decoration: InputDecoration(
                            hintText: 'Enter Password',
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
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: _toggle,
                            child: Text(
                              _obscureText ? "Show password" : "Hide Password",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: new Color(0xFF005EA2),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
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
                                //         type: PageTransitionType.rightToLeft,
                                //         child: homePage()));
                              },
                              color: new Color(0xFF005EA2),
                              textColor: Colors.white,
                              splashColor: Colors.blue,
                              child: Text('Sign In'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        key: Key('forgot_btn'),
                        onTap: () {
                          Navigator.push(
                              context,
                              PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: forgotPassword()));
                        },
                        child: Text(
                          'Forgot Password',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: new Color(0xFF005EA2),
                            decoration: TextDecoration.underline,
                          ),
                        ),
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
                              'Keep me signed in.',
                              style: GoogleFonts.poppins(
                                  fontSize: 15, fontWeight: FontWeight.normal),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15.0,
            ),
            SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Dont have an account?  ',
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.normal),
                  ),
                  TextButton(
                    key: Key('create_acc'),
                    onPressed: () {
                      //action

                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: createAccount()));
                    },
                    child: Text(
                      'Create your account now.',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: new Color(0xFF005EA2),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
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
