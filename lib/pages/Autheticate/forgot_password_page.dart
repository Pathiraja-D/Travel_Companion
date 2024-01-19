import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_journal/components/app_colors.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String email = "";
  TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
          content: Text(
            "Email Sent",
          )));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red,
            content: Text(
              "No user found for that email",
            )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        leading: IconTheme(
          data: IconThemeData(
            color: Colors.white,
            size: 25,
          ),
          child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Icon(Icons.arrow_back)),
        ),
        title: Center(
          child: const Text(
            'Forget Password',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(children: [
            Container(
              padding: const EdgeInsets.only(top: 100),
              child: TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                controller: emailController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Email",
                ),
                onChanged: (text) {
                  email = text;
                },
              ),
            ),
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    fixedSize: Size(width, 50),
                    backgroundColor: AppColors.mainColor),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      email = emailController.text;
                    });
                  } else
                    (Error) {
                      print(Error);
                    };
                  resetPassword();
                },
                child: Center(
                  child: Text(
                    "Send Email",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
