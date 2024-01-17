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

  //Sign out
  Future<bool> signOut() async {
    try {
      await _auth.signOut();
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
      FireStoreUser userWithCredentials =
          FireStoreUser(uid: user!.uid, email: email, username: username);
      bool userCreatedInFirestore =
          await createUserInUsersCollection(userWithCredentials);
      //await SharedPreferenceService().saveUserEmail(email);
      //await SharedPreferenceService().saveUserId(user!.uid);
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
            uid: querySnapshot['id']

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

  //gmail signup
  Future<bool> signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        // Handle the case where Google Sign-In was canceled or failed.
        return false;
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
        return false;
      }

      bool gmailUserCreatedInFirestore = await createUserInUsersCollection(
        FireStoreUser(
          uid: userDetails.uid,
          email: userDetails.email,
          username: userDetails.displayName,
        ),
      );

      return gmailUserCreatedInFirestore;
    } catch (error) {
      print("Error during Google Sign-In: $error");
      return false;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount == null) {
        return null; // User canceled Google Sign-In
      }

      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);

      final User? user = authResult.user;
      return user;
    } catch (error) {
      print('Google Sign-In Error: $error');
      return null;
    }
  }
}
