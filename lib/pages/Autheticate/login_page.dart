import 'package:flutter/material.dart';
import 'package:travel_journal/config/app_images.dart';
import 'package:travel_journal/config/app_routes.dart';
import 'package:travel_journal/pages/Autheticate/forgot_password_page.dart';
import 'package:travel_journal/services/auth/auth.dart';

class LoginPage extends StatefulWidget {
  final Function toggle;
  const LoginPage({super.key, required this.toggle});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  String _email = "";
  String _password = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Stack(children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage(AppImages.loginback),
                      fit: BoxFit.cover)),
            ),
            Positioned(
              top: height * 0.35,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(0.00, -1.00),
                    end: Alignment(0, 1),
                    colors: [
                      Color(0x35283F31),
                      Color(0xFF283F31),
                      Color(0xFF283F31)
                    ],
                  ),
                ),
                height: height * 0.65,
                width: width,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Form(
                    key: _formKey,
                    child: Column(children: [
                      Spacer(),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Login",
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
                        validator: (val) =>
                            val!.isEmpty ? "Enter a valid email" : null,
                        onChanged: (val) {
                          setState(() {
                            _email = val;
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
                            _password = val;
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
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.forgotPassword);
                            },
                            child: Text(
                              "Forgot Password?",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () {
                              widget.toggle();
                            },
                            child: Text("Don't have an account?",
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
                        height: 80,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            fixedSize: Size(width * 0.7, 50),
                            backgroundColor: Colors.amber),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            dynamic result = await _auth
                                .signInWithEmailAndPassword(_email, _password);

                            if (result == 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text("Check email and password again"),
                                  duration: Duration(seconds: 2),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } else {
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.homenavigation);
                            }
                          }
                        },
                        child: Center(
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
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
