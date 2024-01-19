import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travel_journal/components/app_colors.dart';
import 'package:travel_journal/config/app_images.dart';
import 'package:travel_journal/services/map/map_services.dart';
import 'package:weather/weather.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherFactory _wf = WeatherFactory("2660213db2e9ab8cc30ac0270eacb707");
  MapServices mapServices = MapServices();

  Weather? _weather;
  String cityname = '';

  @override
  void initState() {
    super.initState();
    getCurrentPos();
  }

  void getCurrentPos() {
    mapServices.getUserLocationAccess().then((value) {
      mapServices
          .getCityFromCoordinates(value.latitude, value.longitude)
          .then((value) {
        setState(() {
          _wf.currentWeatherByCityName(value).then((value) {
            setState(() {
              _weather = value;
            });
          });
        });
      });
    });
  }

  void _fetchWeather(String cityName) {
    _wf.currentWeatherByCityName(cityName).then((value) {
      setState(() {
        _weather = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.mainColor,
          elevation: 0.0,
          title: Center(
            child: Text("Weather",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
        ),
        body: ListView(
          children: [
            _locationHeader(),
            SizedBox(
              height: 10,
            ),
            _buildUI(),
          ],
        ));
  }

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(
        child: Column(children: [
          CircularProgressIndicator(
            color: AppColors.mainColor,
          ),
          SizedBox(
            height: 10,
          ),
          Text("Loading current weather...")
        ]),
      );
    }
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: Column(
        children: [
          Container(
            height: MediaQuery.sizeOf(context).height * 0.8,
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              children: [
                _datetimeInfo(),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.03,
                ),
                _weatherIcon(),
                _currentTemp(),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.04,
                ),
                _extraInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _locationHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, right: 10, left: 10, bottom: 5),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Enter City Name',
          hintStyle: TextStyle(color: Colors.white),
          suffixIcon: IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
              size: 30,
            ),
            onPressed: () {
              _fetchWeather(cityname);
            },
          ),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none),
          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          filled: true,
          fillColor: Colors.black.withOpacity(0.2),
        ),
        onChanged: (value) {
          _fetchWeather(value);
        },
        onSubmitted: (value) {
          _fetchWeather(value);
        },
      ),
    );
  }

  Widget _datetimeInfo() {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Text(
          _weather?.areaName ?? "",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          //
          getCurrentTime(),
          style: TextStyle(
              fontSize: 35, fontWeight: FontWeight.w800, color: Colors.black),
        ),
        Text(
          //
          getCurrentDate(),
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black),
        ),
      ],
    );
  }

  Widget _weatherIcon() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 0.2,
          width: MediaQuery.sizeOf(context).width * 0.5,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 1),
              image: DecorationImage(
                image: NetworkImage(
                    "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"),
              ),
              borderRadius: BorderRadius.circular(20)),
        ),
        Text(
          _weather?.weatherDescription ?? "",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 25,
          ),
        ),
      ],
    );
  }

  Widget _currentTemp() {
    return Text("${_weather?.temperature?.celsius?.toStringAsFixed(2)}°C",
        style: TextStyle(
            fontSize: 50, fontWeight: FontWeight.w800, color: Colors.black));
  }

  Widget _extraInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            Column(
              children: [
                Image.asset(AppImages.pressure, height: 30, width: 30),
                SizedBox(height: 8),
                Text("${_weather?.pressure?.toStringAsFixed(2)} P"),
              ],
            ),
            Spacer(),
            Container(
              height: 50, // Adjust the height of the vertical line
              width: 2, // Adjust the width of the vertical line
              color: Colors.grey, // Adjust the color of the vertical line
            ),
            Spacer(),
            Column(
              children: [
                Image.asset(AppImages.wind,
                    height: 30, width: 30), // Replace with your image asset
                SizedBox(
                    height: 8), // Adjust the spacing between image and text
                Text("${_weather?.windSpeed?.toStringAsFixed(2)} m/s"),
              ],
            ),
            Spacer(),
            Container(
              height: 50, // Adjust the height of the vertical line
              width: 1, // Adjust the width of the vertical line
              color: Colors.grey, // Adjust the color of the vertical line
            ),
            Spacer(),
            Column(
              children: [
                Image.asset(AppImages.humidity,
                    height: 30, width: 30), // Replace with your image
                // Replace with your image asset
                SizedBox(
                    height: 8), // Adjust the spacing between image and text
                Text(
                  "${_weather?.humidity?.toStringAsFixed(2)} %",
                ),
              ],
            ),
            Spacer(),
          ],
        )
      ],
    );
  }

  String getCurrentTime() {
    var now = DateTime.now();
    var formatter = DateFormat('h:mm a');
    return formatter.format(now);
  }

  String getCurrentDate() {
    var now = DateTime.now();
    var formatter = DateFormat('EEEE, MMMM d, y');
    return formatter.format(now);
  }
}
