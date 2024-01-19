import 'package:flutter/material.dart';
import 'package:travel_journal/config/app_images.dart';
import 'package:travel_journal/config/app_routes.dart';
import 'package:travel_journal/pages/home_navigator.dart';
import 'package:travel_journal/services/auth/auth.dart';

class AppSetUpPage extends StatefulWidget {
  final Function toggle;

  const AppSetUpPage({
    super.key,
    required this.toggle,
  });

  @override
  State<AppSetUpPage> createState() => _AppSetUpPageState();
}

class _AppSetUpPageState extends State<AppSetUpPage> {
  bool _obscureText = true;

  String username = '';
  String email = '';
  String password = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Stack(children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(AppImages.registrationback),
                      fit: BoxFit.cover)),
            ),
            Positioned(
              top: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.00, -1.00),
                    end: Alignment(0, 1),
                    colors: [
                      Color(0xFF283F31),
                      Color(0xFF283F31),
                      Color(0xC5283F31),
                      Color(0x00283F31)
                    ],
                  ),
                ),
                height: height * 0.9,
                width: width,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0, right: 20, left: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(children: [
                      Spacer(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Registration",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        validator: (val) => val!.isEmpty
                            ? "Enter a username for you account "
                            : null,
                        onChanged: (val) {
                          setState(() {
                            username = val;
                          });
                        },
                        decoration: InputDecoration(
                            hintText: "User Name",
                            hintStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        validator: (val) =>
                            val!.isEmpty ? "Enter a valid email" : null,
                        onChanged: (val) {
                          setState(() {
                            email = val;
                          });
                        },
                        decoration: InputDecoration(
                            hintText: "Email",
                            hintStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.white,
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        validator: (val) => val!.length < 6
                            ? "Enter a password 6+ chars long"
                            : null,
                        onChanged: (val) {
                          setState(() {
                            password = val;
                          });
                        },
                        obscureText: _obscureText,
                        decoration: InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.white),
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.white,
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              },
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white))),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              widget.toggle();
                            },
                            child: Text("Already have an account",
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                  color: Colors.white,
                                  fontSize: 14,
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: Size(width, 50),
                            backgroundColor: Colors.amber),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            dynamic result =
                                await _authService.registerWithEmailAndPassword(
                                    email, password, username);
                            if (result == false) {
                              setState(() {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Sign in failed"),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              });
                            } else {
                              Navigator.of(context).pushReplacementNamed(
                                  AppRoutes.homenavigation);
                            }
                          }
                        },
                        child: Center(
                          child: Text(
                            "Register",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 30,
                              child: Container(
                                height: 1,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "Or",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(
                              width:
                                  30, // Adjust this value to change the length of the lines
                              child: Container(
                                height: 1,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      GestureDetector(
                        onTap: () async {
                          String accoutCreated =
                              await _authService.signUpWithGoogle();

                          if (accoutCreated == "SignInSuccessfull") {
                            Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => HomeNavigator()));
                          } else if (accoutCreated == "SignInFailed") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Sign in failed"),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Unknown error"),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        child: Container(
                          height: 50,
                          width: width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30)),
                          child: Row(children: [
                            Spacer(),
                            Image.asset(
                              AppImages.google,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Continue with gmail",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Spacer(),
                          ]),
                        ),
                      ),
                      Spacer(),
                    ]),
                  ),
                ),
              ),
            )
          ]),
        ));
  }
}
