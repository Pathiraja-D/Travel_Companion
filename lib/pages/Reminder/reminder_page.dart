import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_journal/components/app_colors.dart';
import 'package:travel_journal/models/reminder.dart';
import 'package:travel_journal/services/Reminder/reminder_services.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({super.key});

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  TextEditingController descriptionController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  late DateTime selectedDateTime;
  late List<Reminder> reminders;
  ReminderServices reminderServices = ReminderServices();

  @override
  void initState() {
    super.initState();
    selectedDateTime = DateTime.now();
    ReminderServices().autoDeleteReminder();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        leading: IconTheme(
          data: IconThemeData(
            color: Colors.white,
            size: 25,
          ),
          child: GestureDetector(onTap: () {}, child: Icon(Icons.arrow_back)),
        ),
        title: Center(
          child: const Text(
            'Notifications',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            TextFormField(
              controller: descriptionController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                errorStyle: TextStyle(color: Colors.white),
                hintText: "Reminder Description",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: dateController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                errorStyle: TextStyle(color: Colors.white),
                prefixIcon: GestureDetector(
                    onTap: () async {
                      // Show date and time picker
                      DateTime? pickedDateTime = await showDatePicker(
                        context: context,
                        initialDate: selectedDateTime,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );

                      if (pickedDateTime != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                        );

                        if (pickedTime != null) {
                          pickedDateTime = DateTime(
                            pickedDateTime.year,
                            pickedDateTime.month,
                            pickedDateTime.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );

                          setState(() {
                            selectedDateTime = pickedDateTime!;
                            dateController.text = DateFormat('yyyy-MM-dd HH:mm')
                                .format(pickedDateTime);
                          });
                        }
                      }
                    },
                    child: Icon(Icons.calendar_month_rounded)),
                hintText: "Data and Time",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  fixedSize: Size(width, 50),
                  backgroundColor: AppColors.mainColor),
              onPressed: () async {
                Reminder newReminder = Reminder(
                    description: descriptionController.text.trim(),
                    datetime: selectedDateTime);
                if (descriptionController.text.trim().isNotEmpty) {
                  await ReminderServices()
                      .createReminderInReminderCollection(newReminder);
                  await ReminderServices.scheduleNotification(
                          reminder: newReminder)
                      .then((_) {
                    setState(() {
                      descriptionController.clear();
                      dateController.clear();
                    });
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Reminder Set!"),
                      duration:
                          Duration(seconds: 3), // Adjust the duration as needed
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Description is Empty!"),
                      duration:
                          Duration(seconds: 3), // Adjust the duration as needed
                    ),
                  );
                }
              },
              child: Center(
                child: Text(
                  "Set Reminder",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Text(
              "Upcomming Reminders",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.mainColor,
              ),
            ),
            Container(
              height: 1,
              width: width,
              color: Colors.black,
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
                child: StreamBuilder<List<Reminder>>(
                    stream: reminderServices.getReminderStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.all(8),
                                child: _reminders(
                                  snapshot.data![index].description,
                                  snapshot.data![index].datetime,
                                ),
                              );
                            });
                      } else {
                        return Center(child: Text("No documents yet."));
                      }
                    })),
          ],
        ),
      ),
    );
  }

  Widget _reminders(String title, DateTime date) {
    return Container(
      height: 60,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "${title}",
            style: TextStyle(color: Colors.black, fontSize: 15),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            "Date:${date.day}/${date.month}/${date.year} Time:${date.hour}:${date.minute}",
            style: TextStyle(color: Colors.black, fontSize: 15),
          ),
        ],
      ),
    );
  }
}


/*onPressed: () {
                    ReminderServices.scheduleNotification(
                            reminder: Reminder(
                                description: _controller.text.trim(),
                                datetime:
                                    now.add(const Duration(seconds: 120))))
                        .then((_) {
                      setState(() {
                        _controller.clear();
                      });
                    });*/