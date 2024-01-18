import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:travel_journal/components/app_colors.dart';
import 'package:travel_journal/pages/Journey/journey_add_page.dart';
import 'package:travel_journal/pages/Map/map_page.dart';
import 'package:travel_journal/pages/Notes/notes_home.dart';
import 'package:travel_journal/pages/Profile/profile_page.dart';
import 'package:travel_journal/pages/Weather/weather_page.dart';

class HomeNavigator extends StatefulWidget {
  const HomeNavigator({super.key});

  @override
  State<HomeNavigator> createState() => _HomeNavigatorState();
}

class _HomeNavigatorState extends State<HomeNavigator> {
  int index = 0;
  final pages = [
    NoteHomePage(),
    WeatherPage(),
    JourneyAddPage(),
    MapPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Items = <Widget>[
      Icon(
        Icons.home,
        size: 30,
      ),
      Icon(
        Icons.cloud,
        size: 30,
      ),
      Icon(
        Icons.add,
        size: 30,
      ),
      Icon(
        Icons.map,
        size: 30,
      ),
      Icon(
        Icons.person,
        size: 30,
      )
    ];

    return SafeArea(
      child: Scaffold(
        extendBody: true,
        body: pages[index],
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
            iconTheme: IconThemeData(
              color: Colors.white, //this will change the icon color
            ),
          ),
          child: CurvedNavigationBar(
            color: AppColors.mainColor, //Navigation bar Color change
            buttonBackgroundColor:
                AppColors.mainColor, //change the selected background color
            backgroundColor: Colors.white,
            index: index,
            animationCurve:
                Curves.easeInOut, //Thransition duration change in here
            animationDuration: Duration(
                milliseconds: 500), //Thransition duration change in here
            items: Items,
            height: 60,
            onTap: (index) => setState(() {
              this.index = index;
            }),
          ),
        ),
      ),
    );
  }
}
