import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_journal/components/app_colors.dart';
import 'package:travel_journal/models/journey.dart';
import 'package:travel_journal/models/note_model.dart';
import 'package:travel_journal/services/notes/note_services.dart';
import 'package:travel_journal/services/plan/plan_services.dart';

class JourneyServices {
  Note? note;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  PlanServices planService = PlanServices();
  NoteServices noteServices = NoteServices();
  int colorId = Random().nextInt(AppColors.cardsColors.length);

  //constructor
  JourneyServices({this.note});

  //creation
  Future<String> createJourneyInJourneyCollection(
      String title,
      String journeyDescription,
      String journeyLocations,
      List<String> imageURLs) async {
    try {
      String noteId = await noteServices.createNoteInNotesCollection();
      Note immediateNote = await noteServices.getOneNote(noteId);
      await planService.createPlanInPlansCollection(immediateNote);

      await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .collection('Notes')
          .doc(noteId)
          .collection('Journey')
          .add({
        'noteId': noteId,
        'title': title,
        'journeyDescription': journeyDescription,
        'journeyLocations': journeyLocations,
        'date': Timestamp.now(),
        'colorId': colorId.toString(),
        'imageURLs': imageURLs,
      });
      await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .collection('Notes')
          .doc(noteId)
          .update({
        'title': title,
      });

      print("Note added");
      return noteId;
    } catch (e) {
      print(e);
      return "can't add notes";
    }
  }

  Future<List<Journey>> getJourneyInsideTheNote() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .collection('Notes')
          .doc(note!.noteId)
          .collection('Journey')
          .where('noteId', isEqualTo: note!.noteId)
          .get();

      List<Journey> journey = querySnapshot.docs
          .map((doc) => Journey(
                noteId: doc['noteId'],
                date: (doc['date'] as Timestamp).toDate(),
                colorId: doc['colorId'],
                journeyDescription: doc['journeyDescription'],
                journeyLocations: doc['journeyLocations'],
                title: doc['title'],
                imageURLs: List<String>.from(doc['imageURLs']),
              ))
          .toList();
      print(journey);
      return journey;
    } catch (e) {
      print(e);
      return [];
    }
  }

  //update urls in journey
  Future<bool> updateJourneyImageURLs(
      List<String> imageURLs, String noteId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .collection('Notes')
          .doc(noteId)
          .collection('Journey')
          .where('noteId', isEqualTo: noteId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        // Update the title of the first matching document
        await querySnapshot.docs.first.reference.update({
          'imageURLs': FieldValue.arrayUnion(imageURLs),
        });
        print('Image URLs  updated successfully!');
      } else {
        print('No Journey found with the provided noteId.');
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  //update data
  Future<bool> updateJourneyInsideTheNote(
      {required String title,
      required String description,
      required String locations}) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .collection('Notes')
          .doc(note!.noteId)
          .collection('Journey')
          .where('noteId', isEqualTo: note!.noteId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        // Update the title of the first matching document
        querySnapshot.docs.first.reference.update({
          'title': title,
          'journeyDescription': description,
          'journeyLocations': locations
        });
        await _firestore
            .collection('Users')
            .doc(_auth.currentUser!.uid)
            .collection('Notes')
            .doc(note!.noteId)
            .update({
          'title': title,
        });
        print('Journey updated successfully!');
      } else {
        print('No Journey found with the provided noteId.');
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  //delete journey
  Future<bool> deleteJourneyInsideTheNote() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .collection('Notes')
          .doc(note!.noteId)
          .collection('Journey')
          .where('noteId', isEqualTo: note!.noteId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Update the title of the first matching document
        querySnapshot.docs.first.reference.delete();
        print('Journey deleted successfully!');
      } else {
        print('No Journey found with the provided noteId.');
      }
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
