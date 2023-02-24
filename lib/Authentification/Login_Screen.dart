import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:labtani_docteur/Components/global.dart';
import 'package:labtani_docteur/Components/social-page.dart';
import 'package:labtani_docteur/HomeScreen/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:labtani_docteur/Authentification/register_screen_document.dart';
import 'package:labtani_docteur/Authentification/register_screen.dart';


import '../Widgets/error_dialog.dart';
import '../Widgets/loading_dialog.dart';

class loginScreen extends StatefulWidget {
  const loginScreen({Key? key}) : super(key: key);

  @override
  State<loginScreen> createState() => _loginScreenState();
}


class _loginScreenState extends State<loginScreen> {


  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  formValidation()
  {
    if(emailController.text.isNotEmpty && passwordController.text.isNotEmpty)
    {
      //login
      loginNow();
    }
    else
    {
      showDialog(
          context: context,
          builder: (c)
          {
            return ErrorDialog(
              message: "Please write email/password.",
            );
          }
      );
    }
  }


  loginNow() async
  {
    showDialog(
        context: context,
        builder: (c)
        {
          return LoadingDialog(
            message: "Checking Credentials",
          );
        }
    );

    User? currentUser;
    await firebaseAuth.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth){
      currentUser = auth.user!;
    }).catchError((error){
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (c)
          {
            return ErrorDialog(
              message: error.message.toString(),
            );
          }
      );
    });
    if(currentUser != null)
    {
      readDataAndSetDataLocally(currentUser!);
    }
  }

  Future readDataAndSetDataLocally(User currentUser) async
  {
    await FirebaseFirestore.instance.collection("doctors")
        .doc(currentUser.uid)
        .get()
        .then((snapshot) async {
      if(snapshot.exists)
      {
        await sharedPreferences!.setString("uid", currentUser.uid);
        await sharedPreferences!.setString("email", snapshot.data()!["Email"]);
        await sharedPreferences!.setString("firstName", snapshot.data()!["FirstName"]);
        await sharedPreferences!.setString("lastName", snapshot.data()!["lastName"]);

        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (c)=>  Home()));
      }
      else
      {
        firebaseAuth.signOut();
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (c)=>  social_page()));

        showDialog(
            context: context,
            builder: (c)
            {
              return ErrorDialog(
                message: "No record found.",
              );
            }
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor:  Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.blueGrey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset("assets/images/logo_labtani.png"),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                      "Login To Your Account",
                      style:TextStyle(fontFamily: "Urbanist-Bold",
                          fontSize: 32, color: Colors.black),
                    ),
                  ),
                Spacer(),
                Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: GoogleFonts.urbanist(
                            color: Colors.black),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: CupertinoColors.extraLightBackgroundGray,
                            hintText: "Email",
                            hintStyle: GoogleFonts.urbanist(
                                color: Colors.black, fontSize: 14),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5.0),
                            ))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                        obscureText: true,
                        controller: passwordController,
                        style: GoogleFonts.urbanist(
                            color: Colors.black),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: CupertinoColors.extraLightBackgroundGray,
                            hintText: "Password",
                            hintStyle: GoogleFonts.urbanist(
                                color: Colors.black, fontSize: 14),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5.0),
                            ))),
                  ),
                ),
                Spacer(),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 30, 30, 50),
                  child: SizedBox(
                    height: 54,
                    width: 314,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.login,
                        size: 24,
                        color: Colors.white,
                      ),
                      label: Text(
                        "LOGIN",
                        style: GoogleFonts.urbanist(
                            color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () {
                        formValidation();
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 10,
                          padding: EdgeInsets.all(0.0),
                          primary: Colors.blue,
                          shape: new RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0))),
                    ),
                  ),
                ),
                TextButton(
                  child: Text("Forgot password?"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPwd()),
                    );
                  },
                ),
                TextButton(
                  child: Text("New here? Sign Up"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                ),
                Spacer()
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ForgotPwd extends StatefulWidget {
  const ForgotPwd({Key? key}) : super(key: key);

  @override
  State<ForgotPwd> createState() => _ForgotPwdState();
}

class _ForgotPwdState extends State<ForgotPwd> {
  TextEditingController emailTextEditingController = TextEditingController();

  Future<void> resetPassword(String email) async {
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .catchError((msg) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error: " + msg.toString());
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ForgotPwd()),
      );
    });

    Fluttertoast.showToast(msg: "Check Your Mail to Reset password!");

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => loginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.blue),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10, 100, 10, 10),
                    child: Text(
                      "CHANGE PASSWORD",
                      style: TextStyle(fontFamily:'Urbanist',
                          fontSize: 32, color: Colors.black),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 30.0, horizontal: 10.0),
                  child: SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                        controller: emailTextEditingController,
                        style: GoogleFonts.montserrat(
                            color: Colors.blue),
                        decoration: InputDecoration(
                            filled: false,
                            fillColor: Colors.grey,
                            labelText: "Enter Email",
                            labelStyle: GoogleFonts.urbanist(
                                color: Colors.black, fontSize: 18),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(0.0),
                            ))),
                  ),
                ),
                Spacer(
                  flex: 2,
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 30, 30, 20),
                  child: ElevatedButton.icon(
                    icon: Icon(
                      Icons.save,
                      size: 24,
                      color: Colors.blue,
                    ),
                    label: Text(
                      "Update",
                      style: GoogleFonts.montserrat(
                          color: Colors.white, fontSize: 18),
                    ),
                    onPressed: () {
                      resetPassword(
                          emailTextEditingController.text.trim().toString());
                    },
                    style: ElevatedButton.styleFrom(
                        elevation: 10,
                        padding: EdgeInsets.all(8.0),
                        primary: Colors.blue,
                        shape: new RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0))),
                  ),
                ),
                Spacer()
              ],
            ),
          )
        ],
      ),
    );
  }
}

class loginFormValidator {
  static validateEmail(String email) {
    if (email.isEmpty) return "Please enter an email!";
    RegExp regExp = RegExp(r'^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$');
    if (!regExp.hasMatch(email)) {
      return "Please enter a valid email";
    }
    return null;
  }

  static validatePassword(String value) {
    if (value.isEmpty) return 'Please choose a password.';
    if (value.length < 8) return 'Password must contain atleast 8 characters.';
    return null;
  }
}
