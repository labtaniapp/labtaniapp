import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as fStorage;
import 'package:labtani_docteur/Authentification/Login_Screen.dart';
import 'package:labtani_docteur/Authentification/register_screen_document.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../Components/global.dart';
import '../HomeScreen/homepage.dart';
import '../Widgets/custom_text_field.dart';
import '../Widgets/error_dialog.dart';
import '../Widgets/loading_dialog.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController genderTextEditingController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController birthDate = TextEditingController();
  TextEditingController locationController = TextEditingController();
  XFile? imageXFile;
  final ImagePicker _picker = ImagePicker();

  Position? position;
  List<Placemark>? placeMarks;

  String DoctorImageUrl = "";
  String completeAddress = "";
  String dropdownvalue = 'Male';

  Future<void> _getImage() async
  {
    imageXFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageXFile;
    });
  }

  getCurrentLocation() async
  {
    Position newPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    position = newPosition;

    placeMarks = await placemarkFromCoordinates(
      position!.latitude,
      position!.longitude,
    );

    Placemark pMark = placeMarks![0];

    completeAddress = '${pMark.subThoroughfare} ${pMark.thoroughfare}, ${pMark.subLocality} ${pMark.locality}, ${pMark.subAdministrativeArea}, ${pMark.administrativeArea} ${pMark.postalCode}, ${pMark.country}';

    locationController.text = completeAddress;
  }

  Future<void> formValidation() async
  {
    if(imageXFile == null)
    {
      showDialog(
          context: context,
          builder: (c)
          {
            return ErrorDialog(
              message: "Please select an image.",
            );
          }
      );
    }
    else
    {
      if(passwordController.text == confirmPasswordController.text)
      {
        if(confirmPasswordController.text.isNotEmpty && emailController.text.isNotEmpty && lastNameController.text.isNotEmpty
            && phoneController.text.isNotEmpty && locationController.text.isNotEmpty
            && firstnameController.text.isNotEmpty && genderTextEditingController.text.isNotEmpty && birthDate.text.isNotEmpty)
        {
          //start uploading image
          showDialog(
              context: context,
              builder: (c)
              {
                return LoadingDialog(
                  message: "Registering Account",
                );
              }
          );

          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          fStorage.Reference reference = fStorage.FirebaseStorage.instance.ref().child("Doctors").child(fileName);
          fStorage.UploadTask uploadTask = reference.putFile(File(imageXFile!.path));
          fStorage.TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});
          await taskSnapshot.ref.getDownloadURL().then((url) {
            DoctorImageUrl = url;

            //save info to firestore
            authenticateSellerAndSignUp();
          });
        }
        else
        {
          showDialog(
              context: context,
              builder: (c)
              {
                return ErrorDialog(
                  message: "Please write the complete required info for Registration.",
                );
              }
          );
        }
      }
      else
      {
        showDialog(
            context: context,
            builder: (c)
            {
              return ErrorDialog(
                message: "Password do not match.",
              );
            }
        );
      }
    }
  }

  void authenticateSellerAndSignUp() async
  {
    User? currentUser;

    await firebaseAuth.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    ).then((auth) {
      currentUser = auth.user;
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
      saveDataToFirestore(currentUser!).then((value) {
        Navigator.pop(context);
        //send user to homePage
        Route newRoute = MaterialPageRoute(builder: (c) => Home());
        Navigator.pushReplacement(context, newRoute);
      });
    }
  }

  Future saveDataToFirestore(User currentUser) async
  {
    FirebaseFirestore.instance.collection("Doctors").doc(currentUser.uid).set({
      "UID": currentUser.uid,
      "email": currentUser.email,
      "lastName": lastNameController.text.trim(),
      "firstName": firstnameController.text.trim(),
      "AvatarUrl": DoctorImageUrl,
      "phone": phoneController.text.trim(),
      "birthDate":birthDate.text.trim(),
      "address": completeAddress,
      "status": "approved",
      "earnings": 0.0,
      "lat": position!.latitude,
      "lng": position!.longitude,
    });

    //save data locally
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences!.setString("uid", currentUser.uid);
    await sharedPreferences!.setString("email", currentUser.email.toString());
    await sharedPreferences!.setString("lastName", lastNameController.text.trim());
    await sharedPreferences!.setString("firstName", firstnameController.text.trim());
    await sharedPreferences!.setString("PhoneNumber", phoneController.text.trim());
    await sharedPreferences!.setString("Gender", genderTextEditingController.text.trim());
    await sharedPreferences!.setString("birthDate", birthDate.text.trim());
    await sharedPreferences!.setString("photoUrl", DoctorImageUrl);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading:IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.of(context).pop(),
    ),
    ),

      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child:Container(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 10,),
                InkWell(
                  onTap: ()
                  {
                    _getImage();
                  },
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width * 0.20,
                    backgroundColor: Colors.white,
                    backgroundImage: imageXFile==null ? null : FileImage(File(imageXFile!.path)),
                    child: imageXFile == null
                        ?
                    Icon(
                      Icons.add_photo_alternate,
                      size: MediaQuery.of(context).size.width * 0.20,
                      color: Colors.grey,
                    ) : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                        controller: lastNameController,
                        style: GoogleFonts.montserrat(
                            color: Colors.black),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey,
                            hintText: "Name",
                            hintStyle: GoogleFonts.poppins(
                                color: Colors.black, fontSize: 18),
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
                    child: Row(
                      children: [
                        Text(
                          "Gender",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: Colors.grey.shade200,
                          ),
                          child: DropdownButton(
                              dropdownColor: Colors.blue,
                              borderRadius: BorderRadius.circular(5.0),
                              // Initial Value
                              value: dropdownvalue,
                              // Down Arrow Icon
                              icon: const Icon(Icons.keyboard_arrow_down),

                              // Array list of items
                              items: <String>[
                                'Male',
                                'Female',
                                'Trans Gender',
                                'Others'
                              ].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              // After selecting the desired option,it will
                              // change button value to selected value
                              onChanged: (String? newValue) {
                                setState(() {
                                  dropdownvalue = newValue!;
                                });
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                        controller: emailController,
                        style: GoogleFonts.montserrat(
                            color: Colors.black),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: CupertinoColors.lightBackgroundGray,
                            hintText: "Email",
                            hintStyle: GoogleFonts.poppins(
                                color: Colors.black, fontSize: 18),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5.0),
                            ))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                        obscureText: true,
                        controller: passwordController,
                        style: GoogleFonts.montserrat(
                            color: Colors.black),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: CupertinoColors.lightBackgroundGray,
                            hintText: "Password",
                            hintStyle: GoogleFonts.poppins(
                                color: Colors.black, fontSize: 18),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5.0),
                            ))),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width * 0.8,
                    child: TextFormField(
                        obscureText: true,
                        style: GoogleFonts.montserrat(
                            color: Colors.black),
                        decoration: InputDecoration(
                            filled: true,
                            fillColor: CupertinoColors.lightBackgroundGray,
                            hintText: "Confirm Password",
                            hintStyle: GoogleFonts.poppins(
                                color: Colors.black, fontSize: 18),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(5.0),
                            ))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 30, 30, 20),
                  child: SizedBox(
                    height: 54,
                    width: 314,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        Icons.app_registration,
                        size: 24,
                        color: Colors.black,
                      ),
                      label: Center(
                        child: Text(
                          "SIGN UP",
                          style: GoogleFonts.montserrat(
                              color: Colors.black, fontSize: 18),
                        ),
                      ),
                      onPressed: () async {
                        String d = emailController.text.trim();
                      formValidation();
                        final SharedPreferences sharedPreferences =
                        await SharedPreferences.getInstance();
                        sharedPreferences.setString('email', d);
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 10,
                          padding: EdgeInsets.all(10.0),
                          primary: CupertinoColors.lightBackgroundGray,
                          shape: new RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0))),
                    ),
                  ),
                ),
                Spacer(),
                TextButton(
                  child: Text("Already have an account? Log In"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => loginScreen()),
                    );
                  },
                ),
                Spacer()
              ],
            ),
          )
          )
        ],

      ),
      );

  }
}