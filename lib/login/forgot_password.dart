import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localstorage/localstorage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:http/http.dart' as http;

import '../tabs/dashboard.dart';
import 'create_account.dart';
import 'verificatio_code.dart';

class forgotPassword extends StatefulWidget {
  const forgotPassword({Key? key}) : super(key: key);

  @override
  _forgotPasswordState createState() => _forgotPasswordState();
}

class _forgotPasswordState extends State<forgotPassword> {
  final LocalStorage storage = new LocalStorage('seller_app');
  final _formKey = GlobalKey<FormState>();
  var emailphone;
  void initState() {
    print(dotenv.get('API_URL'));
  }

  Future save() async {
    print('hi karthik');

    final appId = storage.getItem('appid'); // Abolfazl
    final orgId = storage.getItem('orgid');
    var userId;
    var text;
    // storage.deleteItem('family');
    // storage.deleteItem('name');
    print(emailphone);

    var res = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?type=User&q=username==' +
          emailphone),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final responseFormat = json.decode(res.body);
    final data = responseFormat["data"];
    if (data.length > 0) {
      //print(data);
      userId = data[0]["id"];
      print(appId);
      print(orgId);
      var postObj = {
        "userId": userId,
        "accountId": orgId,
        "applicationId": appId
      };
      print(postObj);

      var res2 = await http.post(
        Uri.parse(dotenv.get('API_URL') + '/api/service/sendOTP'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(postObj),
      );
      final responseF2 = json.decode(res2.body);
      final data2 = responseF2["data"];

      showTopSnackBar(
        context,
        CustomSnackBar.success(
          message: "Verification code sent successfully",
        ),
      );
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: verificationCode(uid: userId)));

      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //       builder: (context) => verificationCode(
      //         text: userId,
      //       ),
      //     ));

      // Navigator.push(context, MaterialPageRoute(builder: (context) {
      //   return verificationCode(var2: userId);
      // })); //Navigate to another page (Stateful page)

    } else {
      showTopSnackBar(
        context,
        CustomSnackBar.error(
          message: "Please enter registered mobile number or email address",
        ),
      );
    }
  }

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
                        'Password Assistance',
                        style: GoogleFonts.poppins(
                            fontSize: 25, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        'Enter the email address or mobile phone number associated with your account.',
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
                          controller: TextEditingController(text: emailphone),
                          onChanged: (value) {
                            emailphone = value;
                            print(emailphone);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter email or phone number';
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
                                //         child: verificationCode()));
                              },
                              color: new Color(0xFF005EA2),
                              textColor: Colors.white,
                              splashColor: Colors.blue,
                              child: Text('Continue'),
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
            Divider(
              height: 10,
              thickness: 2,
              indent: 0,
              endIndent: 0,
              color: Color(0xFD2E5EEFF),
            ),
            SizedBox(
              height: 20.0,
            ),
            Container(
              margin: EdgeInsets.only(left: 15, top: 0, right: 20, bottom: 0),
              child: Text(
                'Has your email address or mobile phone number changed? ',
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              margin: EdgeInsets.only(left: 17, top: 0, right: 10, bottom: 0),
              child: Padding(
                padding: const EdgeInsets.all(1.0),
                child: Text(
                  'If you no longer use the email address assosiated with your account. you may contact Customer Service for help restoring access tto your account. ',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.normal),
                ),
              ),
            ),
            SizedBox(
              height: 50.0,
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
