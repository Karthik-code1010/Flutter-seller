import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:localstorage/localstorage.dart';
import 'package:page_transition/page_transition.dart';
import 'package:http/http.dart' as http;
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

import 'create_new_password.dart';

class verificationCode extends StatefulWidget {
  final String uid;
  const verificationCode({
    Key? key,
    required this.uid,
  }) : super(key: key);

  @override
  _verificationCodeState createState() => _verificationCodeState();
}

class _verificationCodeState extends State<verificationCode> {
  // var userid = widget.uid;
  final LocalStorage storage = new LocalStorage('seller_app');
  final _formKey = GlobalKey<FormState>();
  var verificode;
  void initState() {
    print(dotenv.get('API_URL'));
  }

  var uid;

  Future save() async {
    print('hi karthik');

    final appId = storage.getItem('appid'); // Abolfazl
    final orgId = storage.getItem('orgid');
    print('func');
    print(uid);
    print(verificode);
    print(appId);
    print(orgId);

    // storage.deleteItem('family');
    // storage.deleteItem('name');

    var res = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?type=Verification&q=verificationCode==' +
          verificode +
          ';refUser==' +
          uid +
          ';refAccountId==' +
          orgId +
          ';refApplicationId==' +
          appId),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    final responseFormat = json.decode(res.body);
    final data = responseFormat["data"];
    if (data.length > 0) {
      print(data);
      showTopSnackBar(
        context,
        CustomSnackBar.success(
          message: "Verification successful",
        ),
      );
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: createNewPassword(vuid: uid)));
    } else {
      showTopSnackBar(
        context,
        CustomSnackBar.error(
          message: "Please enter a valid verification code",
        ),
      );
    }
  }

  resend() async {
    final appId = storage.getItem('appid'); // Abolfazl
    final orgId = storage.getItem('orgid');
    var postObj = {"userId": uid, "accountId": orgId, "applicationId": appId};
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
  }

  @override
  Widget build(BuildContext context) {
    String someString = '${widget.uid}';
    uid = someString;
    //print(uid);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Text(widget.uid),
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
                      Text(
                        'Verification Required',
                        style: GoogleFonts.poppins(
                            fontSize: 25, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "To continue, complete this verfication step. We've sent an Verification Code to your registered email address Please enter it below to complete verfication. ",
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.normal),
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                      Text(
                        'Enter Verification Code ',
                        style: GoogleFonts.poppins(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(0.0),
                        child: TextFormField(
                          controller: TextEditingController(text: verificode),
                          onChanged: (value) {
                            verificode = value;
                            print(verificode);
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Enter your code';
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
                                //         child: createNewPassword()));
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
              height: 35.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    resend();
                  },
                  child: Text(
                    'Resend Verification Code ',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: new Color(0xFF005EA2),
                    ),
                  ),
                ),
              ],
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
