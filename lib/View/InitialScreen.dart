// initial_screen.dart
import 'package:billing_app/View/BillingScreen.dart';
import 'package:flutter/material.dart';

class InitialScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Make the stack fill the entire screen
        children: [
          // Full-screen image
          Image.asset(
            'assets/image.jpg', // Replace with your actual asset path
            fit: BoxFit.cover, // Cover the entire screen
          ),
          // Positioned button at the bottom center
          Positioned(
            bottom: 50, // Adjust this value to position the button vertically
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BillingScreen()),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.8), // Semi-transparent background
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Get Start',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
