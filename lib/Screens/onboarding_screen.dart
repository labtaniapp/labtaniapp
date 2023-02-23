import 'package:flutter/material.dart';

import '../Components/Onboarding_page.dart';
class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({Key? key}) : super(key: key);

  PageController controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          OnboardingPage(
            image: Image.asset("assets/images/Accueil.png"),
            title: "Bienvenue chez Labtani!👋",
            description:
            "La première et meilleure application de prise de rendez-vous et consultation médicale en ligne dans l’ensemble du térritoire guinéen.",
            noOfScreen: 4,
            onNextPressed: changeScreen,
            currentScreenNo: 0,
          ),
          OnboardingPage(
            image: Image.asset("assets/images/Image-1.png"),
            title: "Consultez un medecin en quelques minutes ",
            description:
            "",
            noOfScreen: 4,
            onNextPressed: changeScreen,
            currentScreenNo: 1,
          ),
          //lets add 3rd screen
          OnboardingPage(
            image: Image.asset("assets/images/Group.png"),
            title: " Ou un dentiste sur rendez-vous ",
            description:
            "",
            noOfScreen: 4,
            onNextPressed: changeScreen,
            currentScreenNo: 2,
          ),

          OnboardingPage(
            image: Image.asset("assets/images/Image.png"),
            title: "Ils sont inscrits à l’ordre des médecins guinéens",
            description:
            "",
            noOfScreen: 4,
            onNextPressed: changeScreen,
            currentScreenNo: 3,
          ),
        ],
      ),
    );
  }

  //Lets write function to change next onboarding screen
  void changeScreen(int nextScreenNo) {
    controller.animateToPage(nextScreenNo,
        duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }
}