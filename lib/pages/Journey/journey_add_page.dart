import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:travel_journal/components/app_colors.dart';
import 'package:travel_journal/models/note_model.dart';
import 'package:travel_journal/pages/Plans/plan_add_page.dart';
import 'package:travel_journal/pages/home_navigator.dart';
import 'package:travel_journal/services/journey/journey_services.dart';
import 'package:travel_journal/services/notes/note_services.dart';

class JourneyAddPage extends StatefulWidget {
  JourneyAddPage({
    super.key,
  });

  @override
  State<JourneyAddPage> createState() => _JourneyPageState();
}

class _JourneyPageState extends State<JourneyAddPage> {
  late List<PlatformFile> pickedFiles;
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  List<String> imagesList = [];
  List<String> downloadURLs = [];
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();
  TextEditingController locationcontroller = TextEditingController();
  bool addingFinish = true;
  String journeyCreated = "";
  var formKey = GlobalKey<FormState>();
  JourneyServices journeyServices = JourneyServices();
  NoteServices noteServices = NoteServices();

  late Note note;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.grey[500],
        appBar: AppBar(
          elevation: 0.0,
          leading: IconTheme(
            data: IconThemeData(
              color: Colors.white,
              size: 25,
            ),
            child: GestureDetector(
                onTap: () {
                  HomeNavigator();
                },
                child: Icon(Icons.arrow_back)),
          ),
          title: Text("Collect Your Memories",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.normal)),
          backgroundColor: AppColors.mainColor,
        ),
        body: SingleChildScrollView(
          child: Container(
            height: height,
            width: width,
            child: Form(
              key: formKey,
              child: Column(children: [
                Container(
                  height: height * 0.3,
                  width: width,
                  child: CarouselSlider.builder(
                    options: CarouselOptions(
                      height: 400.0,
                      autoPlay: true,
                      viewportFraction: 1,
                      enableInfiniteScroll: false,
                      reverse: true,
                      autoPlayInterval: Duration(seconds: 2),
                    ),
                    itemCount: imagesList.length,
                    itemBuilder: (context, index, realIndex) {
                      final assetsImage = imagesList[index];

                      return buildImages(assetsImage, index);
                    },
                  ),
                ),
                FloatingActionButton(
                  onPressed: () async {
                    pickImages();
                    if (pickedFiles != null && pickedFiles!.isNotEmpty) {
                      // Wait for the completion of uploadImages

                      // Now you have the downloadURLs, and you can proceed with other logic
                      // ...
                      setState(() {});
                    } else {
                      print('No images selected');
                    }
                  },
                  child: Icon(Icons.add),
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Data and time",
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Title",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        TextFormField(
                          enabled: addingFinish,
                          controller: titlecontroller,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                          minLines: 1,
                          maxLines: 3,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)))),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Journey Details",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        TextFormField(
                          enabled: addingFinish,
                          controller: descriptioncontroller,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                          minLines: 1,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Saved Locations",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                        TextFormField(
                          enabled: addingFinish,
                          controller: locationcontroller,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                          ),
                          minLines: 1,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              )),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        buildProgress(),
                        Center(
                          child: Container(
                            height: height * 0.05,
                            width: width * 0.3,
                            child: ElevatedButton(
                                onPressed: () async {
                                  journeyCreated = await journeyServices
                                      .createJourneyInJourneyCollection(
                                          titlecontroller.text,
                                          descriptioncontroller.text,
                                          locationcontroller.text,
                                          downloadURLs);
                                  note = await noteServices
                                      .getOneNote(journeyCreated);
                                  bool uploadDone =
                                      await uploadImages(note.noteId);

                                  if (journeyCreated.isNotEmpty &&
                                      uploadDone == true &&
                                      downloadURLs.isNotEmpty) {
                                    print("inside if elsse");
                                    await journeyServices
                                        .updateJourneyImageURLs(
                                            downloadURLs, journeyCreated);
                                    setState(() {
                                      addingFinish = false;
                                      imagesList = [];
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text("Journey Added Successfully"),
                                        duration: Duration(
                                            seconds:
                                                3), // Adjust the duration as needed
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: AppColors.mainColor,
                                ),
                                child: Text(
                                  "Save",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                )),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Center(
                          child: Container(
                            height: height * 0.05,
                            width: width * 0.6,
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (note.noteId.isNotEmpty) {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => PlanAddPage(
                                                note: note,
                                              )),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Please add the journey first"),
                                        duration: Duration(
                                            seconds:
                                                3), // Adjust the duration as needed
                                      ),
                                    );
                                  }

                                  print(note);
                                },
                                style: ElevatedButton.styleFrom(
                                  primary: AppColors.mainColor,
                                ),
                                child: Row(
                                  children: [
                                    Spacer(),
                                    Text(
                                      "Make yor Plan",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    IconTheme(
                                        data: IconThemeData(
                                            color: Colors.white, size: 30),
                                        child: Icon(
                                          Icons.arrow_right_alt,
                                        )),
                                    Spacer(),
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ));
  }

  Widget buildImages(String imagePath, int index) => Container(
        color: Colors.grey,
        child: Image.file(
          File(imagePath),
          fit: BoxFit.cover,
        ),
      );

  Widget buildProgress() => StreamBuilder<TaskSnapshot>(
      stream: uploadTask?.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data;
          double progress = data!.bytesTransferred / data.totalBytes;
          return SizedBox(
            height: 50,
            child: Stack(
              fit: StackFit.expand,
              children: [
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey,
                  color: Colors.green,
                ),
                Center(
                  child: Text(
                    '${(progress * 100).toStringAsFixed(2)} % ',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                )
              ],
            ),
          );
        } else {
          return SizedBox(
            child: Text("No data"),
          );
        }
      });

  Future pickImages() async {
    List<File> files = [];
    try {
      final result = await FilePicker.platform
          .pickFiles(allowMultiple: true, type: FileType.image);
      if (result != null) {
        setState(() {
          pickedFiles = result.files;
          files = pickedFiles.map((file) => File(file.path!)).toList();
          imagesList = files.map((file) => file.path).toList();
        });
      } else {
        return null;
      }
    } catch (e) {
      print("Error picking images: $e");
      return null;
    }
  }

  Future<bool> uploadImages(String noteId) async {
    try {
      for (var pickedFile in pickedFiles!) {
        final path = '$noteId/${pickedFile.name}';

        final file = File(pickedFile.path!);
        final ref = FirebaseStorage.instance.ref(path);
        final uploadTask = ref.putFile(file);

        setState(() {
          this.uploadTask = uploadTask;
        });

        await uploadTask.whenComplete(() {});

        final urlDownload = await ref.getDownloadURL();

        setState(() {
          downloadURLs.add(urlDownload);
          this.uploadTask = null; // Reset uploadTask when upload is completed
        });
      }

      print('Download URLs: $downloadURLs');
      return true;
    } catch (e) {
      setState(() {
        this.uploadTask = null; // Reset uploadTask on error
      });
      print('Error uploading images: $e');
      return false;
    }
  }
}
