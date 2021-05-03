import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:we_source_demo/components/rounded_button.dart';

import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  // HomeScreen(this.name,this.phoneNumber);
  // final String name;
  // final String phoneNumber;
  static const String id = 'home';
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool updateEmailVisibility = false;
  String email;
  var user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: SizedBox(
        height: 300,
        width: MediaQuery.of(context).size.width - 50,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "User Name: ",
                  style: TextStyle(color: Color(0xFFDC9AFE), fontSize: 25),
                ),
                Text(
                  user.displayName,
                  style: TextStyle(color: Color(0xFFDC9AFE), fontSize: 25),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Phone Number: ",
                  style: TextStyle(color: Color(0xFFDC9AFE), fontSize: 20),
                ),
                Text(
                  user.phoneNumber,
                  style: TextStyle(color: Color(0xFFDC9AFE), fontSize: 20),
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            (user.email != null)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Email: ",
                        style:
                            TextStyle(color: Color(0xFFDC9AFE), fontSize: 20),
                      ),
                      Text(
                        user.email,
                        style:
                            TextStyle(color: Color(0xFFDC9AFE), fontSize: 20),
                      ),
                    ],
                  )
                : Container(),
            Visibility(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 35),
                child: Container(
                  child: TextField(
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    obscureText: false,
                    onChanged: (text) {
                      email = text;
                    },
                    onSubmitted: (text) {
                      email = text;
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      focusColor: Color(0xFFDC9AFE),
                      labelText: "Email Id",
                      labelStyle: TextStyle(color: Color(0xFFDC9AFE)),
                      contentPadding:
                          EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      hintText: "Email Id",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFFDC9AFE), width: 2.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Color(0xFFDC9AFE), width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.redAccent, width: 2.0),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderSide: const BorderSide(
                            color: Colors.redAccent, width: 2.0),
                      ),
                    ),
                  ),
                ),
              ),
              visible: updateEmailVisibility,
            ),
            (user.email == null)
                ? RoundedButton(
                    color: Color(0xFFDC9AFE),
                    onPressed: () async {
                      if (email != null) {
                        await user.updateEmail(email);
                        setState(() {
                          user = FirebaseAuth.instance.currentUser;
                        });
                      } else {
                        setState(() {
                          updateEmailVisibility = true;
                        });
                      }
                    },
                    text:
                        (!updateEmailVisibility) ? "ADD Email" : "Update Email",
                  )
                : Container(),
            RoundedButton(
              color: Color(0xFFDC9AFE),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, LoginScreen.id);
              },
              text: "Sign Out",
            )
          ],
        ),
      ),
    );
  }
}
