import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_journal/config/app_colors.dart';
import 'package:travel_journal/config/app_images.dart';
import 'package:travel_journal/models/firebase_user_model.dart';
import 'package:travel_journal/pages/Autheticate/authentication.dart';
import 'package:travel_journal/services/auth/auth.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({
    super.key,
  });

  @override
  State<ProfilePage> createState() => _AppSetUpPageState();
}

class _AppSetUpPageState extends State<ProfilePage> {
  bool isEditingEnabled = false;
  TextEditingController username = TextEditingController();
  TextEditingController email = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String _error = '';
  bool _obscureText = true;
  File? _image;
  String? _imagepath;
  FireStoreUser? fireStoreUser;

  void loadData() async {
    FireStoreUser? user = await _authService.getFireStoreUser();
    setState(() {
      fireStoreUser = user;
    });
    print(user);

    if (fireStoreUser != null) {
      username.text = fireStoreUser!.username!;
      email.text = fireStoreUser!.email!;
    }
  }

  @override
  void initState() {
    super.initState();
    LoadImage();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        actions: [
          IconButton(
              onPressed: () async {
                await _authService.signOut();
                const Authenticate();
              },
              icon: Icon(
                Icons.logout,
                color: Colors.white,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: height * 0.28,
                  width: width,
                  decoration: const BoxDecoration(
                    color: AppColors.mainColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                  ),
                ),
                Center(
                  child: Stack(
                    children: [
                      _imagepath != null && _imagepath!.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: FileImage(File(_imagepath!)),
                              radius: 100,
                            )
                          : CircleAvatar(
                              backgroundImage: _image != null
                                  ? FileImage(_image!)
                                  : AssetImage(AppImages.profilepic)
                                      as ImageProvider<Object>?,
                              radius: 100,
                            ),
                      Positioned(
                        bottom: 1,
                        right: 1,
                        child: Container(
                          height: 45,
                          width: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              pickImage(_image?.path);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.photo_library,
                                color: AppColors.mainColor,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0, left: 15, right: 15),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: TextFormField(
                      controller: username,
                      enabled: isEditingEnabled,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        errorStyle: TextStyle(color: Colors.white),
                        hintText: "User Name",
                        prefixIcon: Icon(
                          Icons.person,
                          color: AppColors.mainColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 15, right: 15),
                    child: TextFormField(
                      controller: email,
                      enabled: isEditingEnabled,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        errorStyle: TextStyle(color: Colors.white),
                        hintText: "Email",
                        prefixIcon: Icon(
                          Icons.email,
                          color: AppColors.mainColor,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> pickImage(path) async {
    final imagePicker = ImagePicker();
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
        _imagepath = pickedImage.path;
      });
    }

    await SaveImage(_imagepath);
  }

  Future<void> SaveImage(path) async {
    SharedPreferences saveImage = await SharedPreferences.getInstance();
    saveImage.setString("imagepath", path);
  }

  Future<void> LoadImage() async {
    SharedPreferences saveImage = await SharedPreferences.getInstance();
    setState(() {
      _imagepath = saveImage.getString("imagepath");
    });
  }
}
