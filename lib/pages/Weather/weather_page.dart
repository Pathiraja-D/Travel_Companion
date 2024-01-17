import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final WeatherFactory _wf = WeatherFactory("2660213db2e9ab8cc30ac0270eacb707");

  Weather? _weather;
  String cityname = '';

  @override
  void initState() {
    super.initState();
    _fetchWeather('Kottawa');
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
          title: Text("Short Weather"),
        ),
        body: SingleChildScrollView(
          child: _buildUI(),
        ));
  }

  Widget _buildUI() {
    if (_weather == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      height: MediaQuery.sizeOf(context).height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Spacer(),
          _locationHeader(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.08,
          ),
          _datetimeInfo(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.05,
          ),
          _weatherIcon(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _currentTemp(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _extraInfo(),
          Spacer(),
        ],
      ),
    );
  }

  Widget _locationHeader() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Enter City Name',
            suffixIcon: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _fetchWeather(cityname);
                FocusScope.of(context).unfocus();
              },
            ),
          ),
          onChanged: (value) {
            cityname = value;
          },
          onSubmitted: (value) {
            _fetchWeather(value);
            FocusScope.of(context).unfocus();
          },
        ),
        Text(
          _weather?.areaName ?? "",
          style: TextStyle(fontSize: 20),
        ),
      ],
    );
  }

  Widget _datetimeInfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("hh:mm a").format(now),
          style: TextStyle(
            fontSize: 35,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              DateFormat("EEEE").format(now),
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              "${DateFormat(" d.m.y").format(now)}",
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        )
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
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(
                      "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"))),
        ),
        Text(
          _weather?.weatherDescription ?? "",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _currentTemp() {
    return Text("${_weather?.temperature?.celsius?.toStringAsFixed(2)}°C");
  }

  Widget _extraInfo() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.15,
      width: MediaQuery.sizeOf(context).width * 0.80,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
      padding: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Max: ${_weather?.tempMax?.celsius?.toStringAsFixed(2)} °C"),
              Text("Min: ${_weather?.tempMin?.celsius?.toStringAsFixed(2)} °C"),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Wind: ${_weather?.windSpeed?.toStringAsFixed(2)} m/s"),
              Text("Humidity: ${_weather?.humidity?.toStringAsFixed(2)} %"),
            ],
          )
        ],
      ),
    );
  }
}
