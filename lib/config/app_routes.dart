
import 'package:travel_journal/pages/Autheticate/forgot_password_page.dart';
import 'package:travel_journal/pages/Reminder/reminder_page.dart';
import 'package:travel_journal/pages/Start/app_start_page.dart';
import 'package:travel_journal/pages/Autheticate/login_page.dart';
import 'package:travel_journal/pages/Map/map_page.dart';
import 'package:travel_journal/pages/Autheticate/accout_setup_page.dart';
import 'package:travel_journal/pages/Notes/notes_home.dart';
import 'package:travel_journal/pages/Weather/weather_page.dart';
import 'package:travel_journal/pages/home_navigator.dart';

class AppRoutes {
  static final pages = {
    start: (context) => const AppStartPage(),
    login: (context) => LoginPage(
          toggle: context,
        ),
    accoutsetup: (context) => AppSetUpPage(
          toggle: context,
        ),
    notehomepage: (context) => const NoteHomePage(),
    mappage: (context) => const MapPage(),
    weatherpage: (context) => const WeatherPage(),
    reminderspage: (context) => const RemindersPage(),
    homenavigation: (context) => const HomeNavigator(),
    forgotPassword:(context) => const ForgotPassword(),
  };

  static const start = '/';

  static const accoutsetup = '/accoutsetup';
  static const notehomepage = '/notehomepage';
  static const mappage = '/mappage';
  static const noteaddpage = '/noteaddpage';
  static const login = '/loginpage';
  static const weatherpage = '/weatherpage';
  static const reminderspage = '/reminderspage';
  static const homenavigation = '/homenavigator';
  static const forgotPassword = '/forgotPassword';
}
