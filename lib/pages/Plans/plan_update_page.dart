import 'package:flutter/material.dart';
import 'package:travel_journal/components/app_colors.dart';
import 'package:travel_journal/models/note_model.dart';
import 'package:travel_journal/models/plan.dart';
import 'package:travel_journal/pages/Journey/journey_update_page.dart';
import 'package:travel_journal/services/plan/plan_services.dart';

class PlanUpdatePage extends StatefulWidget {
  Note? note;
  PlanUpdatePage({this.note, super.key});

  @override
  State<PlanUpdatePage> createState() => _PlanAddPageState();
}

class _PlanAddPageState extends State<PlanUpdatePage> {
  PlanServices? planServices;
  List<Plan>? plan;
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController descriptioncontroller = TextEditingController();
  TextEditingController locationcontroller = TextEditingController();
  bool isEdditingEnabled = false;
  int? isDone = 0;
  var formKey = GlobalKey<FormState>();

  void loadData() async {
    List<Plan>? fetchPlan = await planServices?.getPlanInsideTheNote();

    setState(() {
      plan = fetchPlan;
    });

    // Update TextEditingControllers if journey data exists
    if (plan != null && plan!.isNotEmpty) {
      titlecontroller.text = plan![0].title ?? '';
      descriptioncontroller.text = plan![0].planDescription ?? '';
      locationcontroller.text = plan![0].planLocations ?? '';
    }
    print(plan);
  }

  @override
  void initState() {
    super.initState();
    planServices = PlanServices(note: widget.note);
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        leading: IconTheme(
          data: IconThemeData(
            color: Colors.white,
            size: 25,
          ),
          child: Container(
            child: GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (context) =>
                            JourneyUpdatePage(note: widget.note)),
                  );
                },
                child: Icon(Icons.arrow_back)),
          ),
        ),
        title: Text("Journey Plan",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.normal)),
        actions: [
          IconButton(
              icon: IconTheme(
                  data: IconThemeData(color: Colors.white, size: 25),
                  child: Icon(Icons.edit)),
              onPressed: () {
                setState(() {
                  isEdditingEnabled = true;
                });
              })
        ],
        backgroundColor: AppColors.mainColor,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: width,
          height: height * 0.9,
          child: Form(
            key: formKey,
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Created Date:${plan?[0].date.day}/${plan?[0].date.month}/${plan?[0].date.year}   Created Time:${plan?[0].date.hour}:${plan?[0].date.minute}",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          height: 1, // Height of the line
                          color: Colors.black,
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Title",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                            controller: titlecontroller,
                            enabled: isEdditingEnabled,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            )),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Journey Plan",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          controller: descriptioncontroller,
                          enabled: isEdditingEnabled,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
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
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextFormField(
                          controller: locationcontroller,
                          enabled: isEdditingEnabled,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
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
                          height: 80,
                        ),
                        Row(
                          children: [
                            Container(
                              height: height * 0.05,
                              width: width * 0.55,
                              child: ElevatedButton(
                                  onPressed: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              JourneyUpdatePage(
                                                note: widget.note,
                                              )),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: AppColors.mainColor,
                                  ),
                                  child: Row(
                                    children: [
                                      Spacer(),
                                      IconTheme(
                                          data: IconThemeData(
                                              color: Colors.white, size: 30),
                                          child: Icon(
                                            Icons.arrow_back,
                                          )),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Go to Journey",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                      Spacer(),
                                    ],
                                  )),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              height: height * 0.05,
                              width: width * 0.3,
                              child: ElevatedButton(
                                  onPressed: () async {
                                    await planServices
                                        ?.addOrupdatePlanInPlansCollection(
                                            title: titlecontroller.text,
                                            description:
                                                descriptioncontroller.text,
                                            locations: locationcontroller.text);

                                    setState(() {
                                      isEdditingEnabled = false;
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text("Plan Update successfully"),
                                        duration: Duration(seconds: 2),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
