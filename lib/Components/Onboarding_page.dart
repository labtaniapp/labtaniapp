import 'package:flutter/material.dart';
import 'package:labtani_docteur/Components/rounded_button.dart';
import 'package:labtani_docteur/Components/social-page.dart';

class OnboardingPage extends StatelessWidget {
  OnboardingPage(
      {Key? key,
        required this.image,
        required this.title,
        required this.description,
        required this.noOfScreen,
        required this.onNextPressed,
        required this.currentScreenNo})
      : super(key: key);

  final Image image;

  final String title;

  final String description;

  final int noOfScreen;

  final Function(int) onNextPressed;

  final int currentScreenNo;

  @override
  Widget build(BuildContext context) {
    bool isLastScreen = currentScreenNo >= noOfScreen - 1;
    return Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  image,
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    title,
                    style: TextStyle(fontSize: 38, color: Colors.blue,fontFamily:"Urbanist" ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      description,
                      style: TextStyle(fontSize: 18,color: Colors.black,fontFamily:"Urbanist"),
                    ),
                  )
                ],
              ),
            ),
            Visibility(
              visible: !isLastScreen,
              replacement: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 300,
                      height: 50,
                      child: RoundedButton(
                          title: "Get Started",
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (context) => social_page(),
                            ),
                            );
                          }))
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RoundedButton(
                    title: "Skip",
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => social_page(),
                      ),
                      );;
                    },
                  ),
                  Row(
                    children: [
                      for (int index = 0; index < noOfScreen; index++)
                        createProgressDots(
                            (index == currentScreenNo) ? true : false)
                    ],
                  ),
                  RoundedButton(
                    title: "Next",
                    onPressed: () {
                      onNextPressed(currentScreenNo + 1);
                    },
                  )
                ],
              ),
            )
          ],
        ));
  }

  //Create a function to create progress dots
  Widget createProgressDots(bool isActiveScreen) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      height: isActiveScreen ? 15 : 10,
      width: isActiveScreen ? 15 : 10,
      decoration: BoxDecoration(
          color: isActiveScreen ? Colors.green : Colors.grey,
          borderRadius: const BorderRadius.all(Radius.circular(12))),
    );
  }

  //Lets create function to open home screen, same function we will call from skip button too.
  void openHomeScreen(BuildContext context) {
    Navigator.pushReplacementNamed(context, "/home");
  }
}