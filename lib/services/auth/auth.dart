import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:travel_journal/models/firebase_user_model.dart';

import 'package:travel_journal/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  UserModel? _userWithFirebaseUserUid(User? user) {
    return user != null ? UserModel(uid: user.uid) : null;
  }

  //Create Stream to listen to auth changes
  Stream<UserModel?> get user {
    return _auth.authStateChanges().map(_userWithFirebaseUserUid);
  }

  //get current user
  getCurrentUser() async {
    try {
      final User? user = _auth.currentUser;
      return user!.uid;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //update profile image url
  Future<bool> updateProfileImageUrl(String url) async {
    try {
      await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .update({'profilePictureUrl': url});
      print("Url updated");
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  //Sign out
  Future<bool> signOut() async {
    try {
      await _auth.signOut();
      if (googleSignIn.currentUser != null) {
        await googleSignIn.signOut();
      }
      print("Sign out");
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final User? user = result.user;
      if (result.user == null) {
        return "UserNull";
      } else {
        return _userWithFirebaseUserUid(user);
      }
    } catch (e) {
      print(e.toString());
      return 0;
    }
  }

  Future registerWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final User? user = result.user;
      FireStoreUser userWithCredentials = FireStoreUser(
          uid: user!.uid,
          email: email,
          username: username,
          profilePictureUrl: "");
      bool userCreatedInFirestore =
          await createUserInUsersCollection(userWithCredentials);

      if (userCreatedInFirestore) {
        return _userWithFirebaseUserUid(user);
      } else {
        return false;
      }
    } catch (e) {
      print(e.toString());
      return 0;
    }
  }

  //CREATE NEW  user
  Future<bool> createUserInUsersCollection(FireStoreUser fireStoreUser) async {
    try {
      await _firestore.collection('Users').doc(_auth.currentUser!.uid).set({
        'email': fireStoreUser.email,
        'id': _auth.currentUser!.uid,
        'username': fireStoreUser.username,
        'profilePictureUrl': fireStoreUser.profilePictureUrl,
      });
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  //UserWithCredentials return
  Future<FireStoreUser?> getFireStoreUser() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .get();

      if (querySnapshot.exists) {
        FireStoreUser user = FireStoreUser(
          email: querySnapshot['email'],
          username: querySnapshot['username'],
          uid: querySnapshot['id'],
          profilePictureUrl: querySnapshot['profilePictureUrl'],

          // Add other fields according to your Note model
        );
        return user;
      } else {
        // Document with the provided ID does not exist
        throw Exception('User does not exist');
      }
    } catch (e) {
      // Handle any potential errors
      print(e);
      throw Exception('Error fetching note');
    }
  }

  //gmail signUp
  Future<String> signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        // Handle the case where Google Sign-In was canceled or failed.
        return "SignInFailed";
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential result = await _auth.signInWithCredential(credential);
      User? userDetails = result.user;

      if (userDetails == null) {
        // Handle the case where user details are null.
        return "UserNull";
      }

      final userAlreadyExists =
          await getFireStoreUserFromEmail(userDetails.email!);

      if (userAlreadyExists == 2) {
        await createUserInUsersCollection(
          FireStoreUser(
            uid: userDetails.uid,
            email: userDetails.email,
            username: userDetails.displayName,
            profilePictureUrl: "",
          ),
        );
        print("User created");
      }

      return "SignInSuccessfull";
    } catch (error, stackTrace) {
      print("Error during Google Sign-In: $error");
      print("Stack trace: $stackTrace");
      return "UnknownError";
    }
  }

  Future<int> getFireStoreUserFromEmail(String email) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('Users')
          .where('email', isEqualTo: email)
          .limit(1) // Limit the result to one document
          .get();

      if (querySnapshot.size > 0) {
        // A document with the provided email exists

        return 1;
      } else {
        // Document with the provided email does not exist
        return 2;
      }
    } catch (e) {
      // Handle any potential errors
      print(e);
      return 0;
    }
  }
}
