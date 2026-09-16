import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'dashboard_page.dart';
import 'login_page.dart';

// Initial loading screen to handle session validation
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState()
  {
    super.initState();
    checkSessionAndNavigate();
  }

  Future<void> checkSessionAndNavigate() async {
    SharedPreferences sf= await SharedPreferences.getInstance();
    
    // Load data into provider
    if (mounted) {
      await Provider.of<UserProvider>(context, listen: false).loadUserData();
    }

     await Future.delayed(const Duration(seconds: 3),() async {

       if (!mounted) return;

       bool isLoggedIn = sf.getBool("isLoggedIn") ?? false;

      if(isLoggedIn){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const DashboardPage()),);
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> const LoginPage()),);
      }
    });

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.flash_on, size: 80, color: Colors.white),
              SizedBox(height: 20),
              Text("Student Management App",
                style: TextStyle
                  (color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),),

              SizedBox(height: 10),
              CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
    );
  }


}
