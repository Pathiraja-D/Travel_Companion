import 'package:travel_journal/models/note_model.dart';

//inheritence of note
class Plan extends Note {
  String? planDescription;
  String? planLocations;

  Plan({
    required  super.title,
    this.planDescription,
    this.planLocations,
    required super.date, required super.colorId, required super.noteId,
  });
}
