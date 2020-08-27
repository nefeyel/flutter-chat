import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  //needing _auth object for firebase
  final _auth = FirebaseAuth.instance;
  bool showSpinner = false;
  String email;
  String password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //wrapped with this class for showing spinner
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  //without trim() would not work on emulator. Solution found online
                  email = value.trim();
                },
                decoration:
                    kTextFieldDecoration.copyWith(hintText: 'Enter your email'),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                //to hide typing of password
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value.trim();
                },
                decoration: kTextFieldDecoration.copyWith(
                    hintText: 'Enter your password'),
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                btnColor: Colors.blueAccent,
                btnTitle: 'Register',
                functionPressed: () async {
//createUserWithEmailAndPassword is async method so we don't want to continue
// without knowing whether our user has been created or not, so we add async to
// callback and await

                  //start spinning spinner
                  setState(() {
                    showSpinner = true;
                  });

                  if (email == null || password == null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Field empty'),
                            content: Text('Please fill out the form'),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    showSpinner = false;
                                  });
                                },
                                child: Text('Ok'),
                              ),
                            ],
                            elevation: 23.0,
                          );
                        },
                      ),
                    );
                  }

                  try {
                    final newUser = await _auth.createUserWithEmailAndPassword(
                      email: email,
                      password: password,
                    );
                    if (newUser != null) {
                      Navigator.pushNamed(context, ChatScreen.id);
                    }
                    //stop spinning
                    setState(() {
                      showSpinner = false;
                    });
                  } catch (error) {
                    String errorMessage = '';
                    switch (error.code) {
                      case "ERROR_INVALID_EMAIL":
                        errorMessage =
                            "Your email address appears to be malformed.";
                        break;
                      case "ERROR_EMAIL_ALREADY_IN_USE":
                        errorMessage =
                            "User already registered with this email. "
                            "Please choose another email.";
                        break;
                      default:
                        errorMessage = "An undefined Error happened.";
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Error message'),
                            content: Text(errorMessage),
                            actions: [
                              FlatButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  setState(() {
                                    showSpinner = false;
                                  });
                                },
                                child: Text('Ok'),
                              ),
                            ],
                            elevation: 23.0,
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
