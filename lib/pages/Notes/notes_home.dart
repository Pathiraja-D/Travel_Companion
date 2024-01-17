import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_journal/config/app_routes.dart';
import 'package:travel_journal/models/note_model.dart';
import 'package:travel_journal/config/app_colors.dart';
import 'package:travel_journal/pages/Journey/journey_update_page.dart';
import 'package:travel_journal/services/notes/note_services.dart';
import 'package:travel_journal/widgets/note.dart';
import 'package:travel_journal/services/auth/auth.dart';

class NoteHomePage extends StatefulWidget {
  const NoteHomePage({super.key});

  @override
  State<NoteHomePage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<NoteHomePage> {
  final AuthService _auth = AuthService();
  NoteServices noteServices = NoteServices();
  final search = TextEditingController();
  final StreamController<List<Note>> _filteredNotesStreamController =
      StreamController<List<Note>>.broadcast();
  List<Note> notes = [];

  void filterNotes(String query) {
    List<Note> filteredNotes = notes
        .where((note) => note.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    _filteredNotesStreamController.sink.add(filteredNotes);
  }

  @override
  void dispose() {
    _filteredNotesStreamController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return ChangeNotifierProvider(
      create: (_) => ChangeNotifier(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.mainColor,
          elevation: 0.0,
          title: Row(children: [
            Spacer(),
            Text("Your Memories",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.reminderspage);
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.transparent,
                ),
                height: height * 0.05,
                width: height * 0.05,
                child: Icon(Icons.notifications, color: Colors.white),
              ),
            )
          ]),
        ),
        body: Stack(children: [
          Column(children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 10.0, right: 10, left: 10, bottom: 5),
              child: TextFormField(
                controller: search,
                onChanged: (query) {},
                decoration: InputDecoration(
                    hintText: "Search",
                    hintStyle: TextStyle(color: Colors.white),
                    prefixIcon: Icon(Icons.search, color: Colors.white),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.zero,
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.2)),
              ),
            ),
            SizedBox(height: height * 0.02),
            Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StreamBuilder<List<Note>>(
                      stream: noteServices.getNotesStream(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.all(8),
                                  child: noteCard(
                                      () => Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  JourneyUpdatePage(
                                                      note: snapshot
                                                          .data![index]))),
                                      snapshot.data![index]),
                                );
                              });
                        } else {
                          return CircularProgressIndicator(
                              color: AppColors.mainColor);
                        }
                      })),
            ),
          ]),
        ]),
      ),
    );
  }
}
