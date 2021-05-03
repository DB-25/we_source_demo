import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:we_source_demo/components/rounded_button.dart';

import 'HomeScreen.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var firebaseAuth;
  String phone;
  String userName;
  String smsCode;
  void initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    firebaseAuth = FirebaseAuth.instance;
  }

  final _text = TextEditingController();

  @override
  void initState() {
    initialize();
    super.initState();
  }

  void dispose() {
    _text.dispose();
    super.dispose();
  }

  bool _validate = false;
  bool nameValidate = false;
  bool smsMode = false;
  bool numberMode = true;
  bool nameMode = false;
  bool otpValidate = false;

  Widget textFieldCustom(String hint) {
    Color focusColor = Color(0xFFDC9AFE);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 35),
      child: Container(
        child: TextField(
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          controller: _text,
          obscureText: false,
          onChanged: (text) {
            (numberMode)
                ? setState(() {
                    if (text.length != 10) {
                      _validate = true;
                    } else {
                      _validate = false;
                    }
                    phone = text;
                  })
                : (smsMode)
                    ? setState(() {
                        if (text.length != 6) {
                          otpValidate = true;
                        } else {
                          otpValidate = false;
                        }
                        smsCode = text;
                      })
                    : setState(() {
                        if (text.length == 0)
                          nameValidate = true;
                        else
                          nameValidate = false;
                        userName = text;
                      });
          },
          onSubmitted: (text) {
            (numberMode)
                ? setState(() {
                    if (text.length != 10) {
                      _validate = true;
                    } else {
                      _validate = false;
                    }
                    phone = text;
                  })
                : (smsMode)
                    ? setState(() {
                        if (text.length != 6) {
                          otpValidate = true;
                        } else {
                          otpValidate = false;
                        }
                        smsCode = text;
                      })
                    : setState(() {
                        if (text.length == 0)
                          nameValidate = true;
                        else
                          nameValidate = false;
                        userName = text;
                      });
          },
          inputFormatters: (!nameMode)
              ? [
                  (numberMode)
                      ? LengthLimitingTextInputFormatter(10)
                      : LengthLimitingTextInputFormatter(6),
                  FilteringTextInputFormatter.digitsOnly
                ]
              : null,
          keyboardType: (nameMode) ? TextInputType.name : TextInputType.number,
          decoration: InputDecoration(
              prefixText: (numberMode) ? "+91  " : " ",
              focusColor: focusColor,
              labelText: hint,
              labelStyle: (_validate || otpValidate || nameValidate)
                  ? TextStyle(color: Colors.redAccent)
                  : TextStyle(color: Color(0xFFDC9AFE)),
              contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFFDC9AFE), width: 2.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Color(0xFFDC9AFE), width: 2.0),
              ),
              errorBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Colors.redAccent, width: 2.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide:
                    const BorderSide(color: Colors.redAccent, width: 2.0),
              ),
              errorText: _validate
                  ? "Please make sure your number is right."
                  : otpValidate
                      ? "Please enter a valid 6 digit OTP."
                      : nameValidate
                          ? "Enter your name."
                          : null),
        ),
      ),
    );
  }

  void verifyNumber() async {
    if (phone != null) {
      await firebaseAuth.verifyPhoneNumber(
        phoneNumber: "+91 " + phone,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await firebaseAuth.signInWithCredential(credential);

          setState(() {
            smsMode = false;
            numberMode = false;
            nameMode = true;
            _text.clear();
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          _validate = true;
          if (e.code == 'invalid-phone-number') {
            _validate = true;
            print('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int resendToken) async {
          // Update the UI - wait for the user to enter the SMS code
          setState(() {
            smsMode = true;
            numberMode = false;
            _text.clear();
            verifId = verificationId;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } else {
      setState(() {
        _validate = true;
      });
    }
  }

  String verifId;
  void verifyOtp() async {
    if (verifId != null && smsCode != null) {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verifId, smsCode: smsCode);
      // Sign the user in (or link) with the credential
      await firebaseAuth.signInWithCredential(credential);
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setBool("loggedIn", true);
      print("verified");
      setState(() {
        nameMode = true;
        smsMode = false;
        numberMode = false;
        _text.clear();
      });
    } else {
      setState(() {
        otpValidate = true;
      });
    }
  }

  void updateName() async {
    var user = FirebaseAuth.instance.currentUser;
    print(user.uid);
    if (userName != null) {
      await user.updateProfile(displayName: userName);
      var user2 = FirebaseAuth.instance.currentUser;
      if (user2.displayName == userName) {
        _text.clear();
        Navigator.pushReplacementNamed(context, HomeScreen.id);
      }
    } else
      setState(() {
        nameValidate = true;
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
        setState(() {
          _validate = false;
          nameValidate = false;
          otpValidate = false;
        });
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height - 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundImage: AssetImage('assets/shopping.jpg'),
                      radius: MediaQuery.of(context).size.width / 3,
                    ),
                  ),
                  (smsMode)
                      ? textFieldCustom("OTP")
                      : (numberMode)
                          ? textFieldCustom("Number")
                          : textFieldCustom("Name"),
                  RoundedButton(
                    text: (smsMode)
                        ? "Verify"
                        : (numberMode)
                            ? "Proceed"
                            : "Add Name",
                    color: Color(0xFFDC9AFE),
                    onPressed: () {
                      (numberMode)
                          ? verifyNumber()
                          : (smsMode)
                              ? verifyOtp()
                              : updateName();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
