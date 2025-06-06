import 'package:car_rental_project/onboarding_constants.dart';
import 'package:car_rental_project/screens/login_screen.dart';
import 'package:car_rental_project/screens/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingScreens extends StatefulWidget {
  const OnboardingScreens({super.key});

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
  final PageController _pageController = PageController(initialPage: 0);
  int currentIndex = 0;

  // Mock currentUser for demonstration
  final currentUser = null; // Replace with actual user-check logic

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 20),
            child: InkWell(
                onTap: () {
                  // Navigate directly to the appropriate screen based on currentUser
                  if (currentUser == null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => SignupScreen()),
                    );
                  } else {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  }
                },
                child: Text(
                  'Skip',
                  style: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.grey[300] : const Color(0XFF97B3AE),
                    fontSize: 16.0,
                    fontWeight: FontWeight.w400,
                  ),
                )),
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            onPageChanged: (int page) {
              setState(() {
                currentIndex = page;
              });
            },
            controller: _pageController,
            children: [
              createPage(
                image: 'assets/lottieFiles/food-delivery-location.json',
                title: OnboardingConstants.titleOne,
                description: OnboardingConstants.descriptionOne,
              ),
              createPage(
                image: 'assets/lottieFiles/Gift on the way.json',
                title: OnboardingConstants.titleTwo,
                description: OnboardingConstants.descriptionTwo,
              ),
              createPage(
                image: 'assets/lottieFiles/icons8-verify.json',
                title: OnboardingConstants.titleThree,
                description: OnboardingConstants.descriptionThree,
              ),
            ],
          ),
          Positioned(
            bottom: 80,
            left: 30,
            child: Row(
              children: _buildIndicator(),
            ),
          ),
          Positioned(
            bottom: 60,
            right: 30,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? Colors.grey[300] : const Color(0XFF97B3AE),
              ),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    if (currentIndex < 2) {
                      currentIndex++;
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeIn,
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => SignupScreen()),
                      );
                    }
                  });
                },
                icon: Icon(
                  Icons.arrow_forward_ios,
                  size: 24,
                  color: isDarkMode ? Colors.black : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicator(bool isActive) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 10.0,
      width: isActive ? 20 : 8,
      margin: const EdgeInsets.only(right: 5.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[300] : const Color(0XFF97B3AE),
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  List<Widget> _buildIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < 3; i++) {
      if (currentIndex == i) {
        indicators.add(_indicator(true));
      } else {
        indicators.add(_indicator(false));
      }
    }
    return indicators;
  }
}

class createPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const createPage({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(left: 50, right: 50, bottom: 80),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3, // Adjust the flex factor as needed
            child: Lottie.asset(image),
          ),
          const SizedBox(
            height: 20,
          ),
          Flexible(
            flex: 1, // Adjust the flex factor as needed
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: isDarkMode ? Colors.grey[300] : const Color(0XFF97B3AE),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Flexible(
            flex: 1, // Adjust the flex factor as needed
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}