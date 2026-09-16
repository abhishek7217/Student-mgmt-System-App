import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import 'registration_screen.dart';
import 'dashboard_page.dart';
import '../utils/validation_mixin.dart';

// User authentication screen
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with ValidationMixin {
  TextEditingController idController = TextEditingController();
  TextEditingController passController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String? name, email, mobile, pass, profilePath;

  @override
  void initState() {
    super.initState();
    getDataFromShare();
  }

  Future<void> getDataFromShare() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    name = prefs.getString("name");
    email = prefs.getString("email");
    mobile = prefs.getString("mobile");
    pass = prefs.getString("password");
    profilePath = prefs.getString("profilePath");
    setState(() {});
  }

  Future<bool> loginValidation() async {
    String inputId = idController.text;
    String inputPass = passController.text;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if ((inputId == mobile || inputId == email) && inputPass == pass) {
      prefs.setBool("isLoggedIn", true);
      if (mounted) {
        Provider.of<UserProvider>(
          context,
          listen: false,
        ).setUserData(name ?? '', email ?? '', profilePath ?? '');
      }
      return true;
    }
    return false;
  }

  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      /* appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: Text("Login page",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20,color: Colors.white,),),
      ),
*/
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/loginpage2.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 180, bottom: 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: idController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.person,
                                color: const Color(0xFF673AB7),
                              ),
                              label: Text("Email or Mobile"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.deepPurple,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) => validateEmailOrMobile(value),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 15),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            maxLength: 6,
                            controller: passController,
                            obscureText: !isPasswordVisible,
                            decoration: InputDecoration(
                              counterText: "",
                              prefixIcon: Icon(
                                Icons.password,
                                color: Colors.deepPurple,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              label: Text("Password"),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.deepPurple,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) => validatePassword(value),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            elevation: 10,
                            fixedSize: Size(150, 25),
                          ),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              bool isValid = await loginValidation();
                              if (!context.mounted) return;
                              if (isValid) {
                                // Showing success feedback before navigating
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Login Successful!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DashboardPage(),
                                  ),
                                );
                              } else {
                                // Alerting user about wrong credentials
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Invalid Email/Mobile or Password",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: Colors.black,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegistrationScreen(),
                              ),
                            );
                          },
                          child: Text(
                            "Signup",
                            style: TextStyle(
                              color: Colors.deepPurple,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: 0.5,

                          child: Text(
                            "Version 1.0.0",
                            style: TextStyle(
                              color: Colors.black,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
