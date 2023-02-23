import 'package:flutter/material.dart';


import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:labtani_docteur_app/Authentification/Login_Screen.dart';
import 'package:labtani_docteur_app/Components/delayed_animation.dart';

class social_page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white.withOpacity(0),
        leading:IconButton(
          icon: Icon(
            Icons.arrow_back,
            color:Colors.black,
            size:30,
          ),
          onPressed:(){
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView (
        child:Column (
        children:[
          DelayedAnimation(
            delay:1000,
             child: Container (
                height: 280,
                child: Image.asset ("assets/images/Auth-image.png"),
    ),
        ),
               DelayedAnimation(
               delay:1000,
               child: Container (
                 margin: const EdgeInsets.symmetric(
                    vertical:40,
                        horizontal:30,
                 ),
                 child: Column(
                   children:[
                     Text("Lets you in",
                           style: GoogleFonts.poppins(
                     color:Colors.blue,
                   fontSize:39,
                   fontWeight: FontWeight.w600
                 ),
                     ),
                     SizedBox (height:10),
                   ],
                 )
    ),
    ),
                          DelayedAnimation(
                           delay:3500,
                           child: Container (
                            margin:  EdgeInsets.symmetric(
                             vertical:14,
                              horizontal:40,
                           ),
                              child: Column(
                             children:[
                               ElevatedButton(
                               onPressed: (){
                                Navigator.push(context, MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                                );
                                 },
                                style:ElevatedButton.styleFrom(
                                shape:StadiumBorder(),
                                primary:Colors.blue,
                                padding:EdgeInsets.all(13),
                                ),
                                 child: Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                  Icon(Icons.email),
                                  Text ( "EMAIL")

    ],
    ),
    ),
                                  SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(
                                   builder: (context) => LoginScreen(),
                                  ),
                                  );
                                  },
                               style:ElevatedButton.styleFrom(
                                shape:StadiumBorder(),
                                primary:Colors.blue,
                                padding:EdgeInsets.all(13),
                                ),
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                Icon(Icons.facebook),
                                Text ( "S’authentifier avec Facebook")

                                ],
                                ),
                                ),
                                SizedBox(height: 20),
                                ElevatedButton(
                                onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                  ),
                                  );
                                  },
                                style:ElevatedButton.styleFrom(
                                shape:StadiumBorder(),
                                primary:Colors.blue,
                                padding:EdgeInsets.all(13),
                                ),
                                child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                Icon(Icons.mail_outline_outlined),
                                Text ( "S’authentifier avec Google")

                                ],
                                ),
                                ),
                                SizedBox(height: 20,)


    ],
    ),
    ),
                          ),
      ]
    ),
    ),
    );
    }
        }



