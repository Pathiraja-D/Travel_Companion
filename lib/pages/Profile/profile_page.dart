import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
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

  final AuthService _authService = AuthService();

  String? _imagepath;
  FireStoreUser? fireStoreUser;
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  void loadData() async {
    FireStoreUser? user = await _authService.getFireStoreUser();
    setState(() {
      fireStoreUser = user;
    });
    print(user);

    username.text = fireStoreUser!.username!;
    email.text = fireStoreUser!.email!;
    _imagepath = fireStoreUser!.profilePictureUrl!;
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          backgroundColor: AppColors.mainColor,
          elevation: 0,
          actions: [
            IconButton(
                onPressed: () async {
                  await _authService.signOut();
                },
                icon: Icon(
                  Icons.logout,
                  color: Colors.white,
                ))
          ],
        ),
        body: profileBody());
  }

  Widget profileBody() {
    if (_imagepath == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return SingleChildScrollView(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.28,
                width: MediaQuery.of(context).size.width,
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
                    CircleAvatar(
                      backgroundImage: NetworkImage(_imagepath!),
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
                          onPressed: () async {
                            await pickImages();
                            await uploadImages();
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
    );
  }

  Future pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        setState(() {
          pickedFile = result.files.first;
          _imagepath = pickedFile!.path; // Set _imagepath for immediate display
        });
      } else {
        return null;
      }
    } catch (e) {
      print("Error picking images: $e");
      return null;
    }
  }

  Future<bool> uploadImages() async {
    try {
      final path = 'files/${pickedFile!.name}';
      final file = File(pickedFile!.path!);
      final ref = FirebaseStorage.instance.ref().child(path);

      // Upload file to Firebase Storage
      final uploadTask = ref.putFile(file);

      // Wait for the upload to complete
      await uploadTask.whenComplete(() {});

      // Get the download URL
      final urlDownloaded = await ref.getDownloadURL();

      // Update the image path and trigger a rebuild
      setState(() {
        _imagepath = urlDownloaded;
      });

      // Update profile image URL in Firestore or wherever needed
      _authService.updateProfileImageUrl(urlDownloaded);
      print("Images uploaded");

      return true;
    } catch (e) {
      print("Error uploading images: $e");
      return false;
    }
  }
}
