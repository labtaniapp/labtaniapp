import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:labtani_docteur/Components/textscale.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Components/global.dart';
import 'screens/onboarding_screen.dart';


Future<void> main() async
{
  WidgetsFlutterBinding.ensureInitialized();

  sharedPreferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        builder: fixTextScale,
        title: 'Docteur App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        routes:{
          "/": (context) => OnboardingScreen(),
          "/home": (context) => OnboardingScreen()

        }

    );
  }
}