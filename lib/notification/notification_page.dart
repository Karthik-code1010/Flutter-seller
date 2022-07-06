import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:localstorage/localstorage.dart';
import 'package:page_transition/page_transition.dart';

import '../main.dart';
import '../tabs/dashboard.dart';
import '../tabs/myaccount.dart';
import '../tabs/product_list.dart';
import 'package:http/http.dart' as http;
import 'dart:math' as math;

class notificationPage extends StatefulWidget {
  const notificationPage({Key? key}) : super(key: key);

  @override
  _notificationPageState createState() => _notificationPageState();
}

class _notificationPageState extends State<notificationPage> {
  final LocalStorage storage = new LocalStorage('seller_app');
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      print('Tap');
      print(_selectedIndex);
      if (_selectedIndex == 2) {
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft, child: productList(searchvalue: '',)));
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

  void initState() {
    getNotifications();
  }

  List notifiData = [];
  getNotifications() async {
    print(storage.getItem('people'));
    var refUserId = storage.getItem('people')["refUserId"];
    var refAccountId = storage.getItem('people')["refAccountId"];
    var refApplicationId = storage.getItem('people')["refApplicationId"];
    print(refUserId);
    print(refAccountId);
    print(refApplicationId);

    var res = await http.get(
      Uri.parse(dotenv.get('API_URL') +
          '/api/service/entities?options=keyValues&type=Notifications'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    //print('response');
    //print(res);
    final responseFormat = json.decode(res.body);
    final data = responseFormat["data"];

    setState(() {
      notifiData = data;
    });
    print(notifiData);
  }

  logout() {
    storage.deleteItem('appid');
    storage.deleteItem('orgid');
    storage.deleteItem('people');
    Navigator.push(context,
        PageTransition(type: PageTransitionType.rightToLeft, child: MyApp()));
  }

  // timeDiffCalc(date) {
  //   final dateFuture = DateTime.parse(date);
  //
  //   DateTime dateNow = DateTime.now();
  //
  //   print(dateFuture);
  //   print(dateNow);
  //   var delta = (dateFuture - dateNow).abs() / 1000;
  //   // const days = Math.floor(delta / 86400);
  //   // delta -= days * 86400;
  //   // const hours = Math.floor(delta / 3600) % 24;
  //   // delta -= hours * 3600;
  //   // const minutes = Math.floor(delta / 60) % 60;
  //   // delta -= minutes * 60;
  //   // const seconds = delta % 60
  //   // console.log(days, hours, minutes, seconds)
  //   //
  //   // var returnString = "";
  //   // if (days > 0) {
  //   // returnString = returnString + days + " days ";
  //   // }
  //   // if (hours > 0 || returnString.length > 0) {
  //   // returnString = returnString + hours + " hours ";
  //   // }
  //   // if (minutes > 0 || returnString.length > 0) {
  //   // returnString = returnString + minutes + " minutes ";
  //   // }
  //   // if (seconds > 0 || returnString.length > 0) {
  //   // returnString = returnString + parseInt(seconds + "") + " soconds ";
  //   // }
  //
  //   // return returnString;
  //
  //   return date;
  // }

  static differenceFormattedString(int minute) {
    try {
      DateTime now = DateTime.now();

      Duration difference = Duration(minutes: minute);

      final today =
          DateTime(now.year).add(difference).subtract(const Duration(days: 1));

      return '${today.day} Days ${today.hour} Hours ${today.minute} Min';
    } catch (e) {
      return '';
    }
  }

  String convertToAgo(DateTime input) {
    Duration diff = DateTime.now().difference(input);

    if (diff.inDays >= 1) {
      return '${diff.inDays} day(s) ago';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours} hour(s) ago';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} minute(s) ago';
    } else if (diff.inSeconds >= 1) {
      return '${diff.inSeconds} second(s) ago';
    } else {
      return 'just now';
    }
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
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Container(
          // Symetric Padding
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 5.0),
          child: Column(
            children: [
              SizedBox(
                height: 1.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: new EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'Notifications',
                      style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF005EA2),
                      ),
                    ),
                  ),
                ],
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: notifiData.length,
                itemBuilder: (context, i) => Container(
                  height: 85,
                  // width: 100,
                  // decoration: BoxDecoration(
                  //   border: Border(
                  //     left: BorderSide(
                  //       color: Colors.green,
                  //       width: 8.0,
                  //     ),
                  //   ),
                  // ),
                  child: Card(
                    color: Color(0xFFecf3ec),
                    child: ListTile(
                      //  selectedTileColor: Colors.black,
                      hoverColor: Colors.green,
                      leading: Icon(
                        Icons.done_outline_rounded,
                        color: Colors.black,
                      ),
                      title: Text(notifiData[i]["event"],
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          )),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(notifiData[i]["eventDescription"]),
                          Text(
                            convertToAgo(
                                DateTime.parse(notifiData[i]["createdAt"])),

                            //timeDiffCalc(notifiData[i]["createdAt"]
                            //differenceFormattedString(100000),
                            //notifiData[i]["createdAt"],
                            style: TextStyle(fontSize: 10),
                          )
                        ],
                      ),
                    ),
                    elevation: 8,
                    shadowColor: Colors.greenAccent,
                    margin: EdgeInsets.all(5),
                  ),
                ),
              ),
              // Container(
              //   height: 85,
              //   // width: 100,
              //   // decoration: BoxDecoration(
              //   //   border: Border(
              //   //     left: BorderSide(
              //   //       color: Colors.green,
              //   //       width: 8.0,
              //   //     ),
              //   //   ),
              //   // ),
              //   child: Card(
              //     color: Color(0xFFf4e3db),
              //     child: ListTile(
              //       //  selectedTileColor: Colors.black,
              //       hoverColor: Colors.green,
              //       leading: Icon(
              //         Icons.error,
              //         color: Colors.black,
              //       ),
              //       title: Text("Errors",
              //           style: GoogleFonts.poppins(
              //             fontSize: 20,
              //             fontWeight: FontWeight.w500,
              //             color: Colors.black,
              //           )),
              //       subtitle: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text('New Order received'),
              //           Text(
              //             '3day 18hours 15minutes',
              //             style: TextStyle(fontSize: 10),
              //           )
              //         ],
              //       ),
              //     ),
              //     elevation: 8,
              //     shadowColor: Colors.greenAccent,
              //     margin: EdgeInsets.all(5),
              //   ),
              // ),
              // Container(
              //   height: 85,
              //   // width: 100,
              //   // decoration: BoxDecoration(
              //   //   border: Border(
              //   //     left: BorderSide(
              //   //       color: Colors.green,
              //   //       width: 8.0,
              //   //     ),
              //   //   ),
              //   // ),
              //   child: Card(
              //     color: Color(0xFFfaf3d1),
              //     child: ListTile(
              //       //  selectedTileColor: Colors.black,
              //       hoverColor: Colors.green,
              //       leading: Icon(
              //         Icons.warning,
              //         color: Colors.black,
              //       ),
              //       title: Text("Warning",
              //           style: GoogleFonts.poppins(
              //             fontSize: 20,
              //             fontWeight: FontWeight.w500,
              //             color: Colors.black,
              //           )),
              //       subtitle: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Text('New Order received'),
              //           Text(
              //             '3day 18hours 15minutes',
              //             style: TextStyle(fontSize: 10),
              //           )
              //         ],
              //       ),
              //     ),
              //     elevation: 8,
              //     shadowColor: Colors.greenAccent,
              //     margin: EdgeInsets.all(5),
              //   ),
              // )
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   child: Icon(Icons.navigate_before),
      //   onPressed: () {
      //     Navigator.of(context)
      //         .pop(MaterialPageRoute(builder: (context) => MyApp()));
      //   },
      // ),
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
