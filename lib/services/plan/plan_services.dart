import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_journal/models/note_model.dart';
import 'package:travel_journal/models/plan.dart';
import 'package:travel_journal/services/notes/note_services.dart';

class PlanServices {
  Note? note;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  NoteServices noteServices = NoteServices();

  PlanServices({this.note});

  Future<bool> createPlanInPlansCollection(Note note) async {
    try {
      await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .collection('Notes')
          .doc(note.noteId)
          .collection('Plan')
          .add({
        'noteId': note.noteId,
        'title': note.title,
        'planDescription': '',
        'planLocations': '',
        'date': Timestamp.now(),
        'colorId': note.colorId
      });
      print("Plan added");
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<List<Plan>> getPlanInsideTheNote() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .collection('Notes')
          .doc(note!.noteId)
          .collection('Plan')
          .where('noteId', isEqualTo: note!.noteId)
          .get();

      List<Plan> journey = querySnapshot.docs
          .map((doc) => Plan(
                noteId: doc['noteId'],
                date: (doc['date'] as Timestamp).toDate(),
                colorId: doc['colorId'],
                planDescription: doc['planDescription'],
                planLocations: doc['planLocations'],
                title: doc['title'],
              ))
          .toList();
      print(journey);
      return journey;
    } catch (e) {
      print(e);
      return [];
    }
  }

  //update plan
  Future<int> addOrupdatePlanInPlansCollection(
      {required String title,
      required String description,
      required String locations}) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .collection('Notes')
          .doc(note!.noteId)
          .collection('Plan')
          .where('noteId', isEqualTo: note!.noteId)
          .get();
      print("Plan Found");
      if (querySnapshot.docs.isNotEmpty) {
        // Update the title of the first matching document
        querySnapshot.docs.first.reference.update({
          'title': title,
          'planDescription': description,
          'planLocations': locations
        });
        print('Plan updated successfully!');
        return 1;
      } else {
        await _firestore
            .collection('Users')
            .doc(_auth.currentUser!.uid)
            .collection('Notes')
            .doc(note!.noteId)
            .collection('Plan')
            .add({
          'noteId': note!.noteId,
          'title': title,
          'planDescription': description,
          'planLocations': locations,
          'date': Timestamp.now(),
          'colorId': note!.colorId
        });
        print("Plan added");
        return 2;
      }
    } catch (e) {
      print(e);
      return 0;
    }
  }

  //delete plan
  Future<bool> deletePlanInPlansCollection() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('Users')
          .doc(_auth.currentUser!.uid)
          .collection('Notes')
          .doc(note!.noteId)
          .collection('Plan')
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
