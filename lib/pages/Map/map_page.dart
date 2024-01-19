import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:travel_journal/services/map/map_services.dart';
import 'package:uuid/uuid.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  //var for suggestions
  String? accessToken = '1948';
  List<dynamic> listOfPlaces = [];
  var uuid = Uuid();
  bool isListShowing = true;

  //var for display map
  TextEditingController search = TextEditingController();
  TextEditingController autoCompleteValue = TextEditingController();
  final Completer<GoogleMapController> controller = Completer();
  static CameraPosition _initialPosition = CameraPosition(
    target: LatLng(7.8774222, 80.7003428),
    zoom: 14.4746,
  );

  //map service
  MapServices mapServices = MapServices();
  Timer? _debounce;

  final List<Marker> mymarker = [];
  final List<Marker> anymarker = [];
  final List<Marker> mymarkerList = [
    const Marker(
        markerId: MarkerId('Sri Lanka'),
        position: LatLng(7.8774222, 80.7003428),
        infoWindow: InfoWindow(title: 'First Marker')),
  ];
  List<Location>? selectedLocations;
  List<String>? locationInfo;

  //suggestion
  void makeSuggestion(String input) async {
    // Cancel previous timer if it exists
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Set a new timer to make the API request after 500 milliseconds
    _debounce = Timer(const Duration(seconds: 1), () async {
      String googlePlacesApiKey = 'AIzaSyCCEax977Tl88T7wNZPPWYKyouXuVDRJvA';
      String groundUrl =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$groundUrl?input=$input&key=$googlePlacesApiKey&sessiontoken=$accessToken';

      var response = await http.get(Uri.parse(request));

      var resultData = response.body.toString();

      print(resultData);

      if (response.statusCode == 200) {
        setState(() {
          listOfPlaces = jsonDecode(response.body.toString())['predictions'];
          accessToken = null;
        });
      } else {
        throw Exception('Showing Data Failed Try Again');
      }
    });
  }

  void onModify() {
    if (accessToken == null) {
      setState(() {
        accessToken = uuid.v4();
      });
    }

    makeSuggestion(search.text);
  }

  @override
  void initState() {
    super.initState();
    mymarker.addAll(mymarkerList);
    mymarker.addAll(anymarker);
    search.addListener(() {
      onModify();
    });
  }

  //current location find

  locateMyLocation() {
    mapServices.getUserLocationAccess().then((value) async {
      print('My location');
      print('${value.latitude} ${value.longitude}');

      mymarker.add(
        Marker(
            markerId: MarkerId('Secnod Marker'),
            position: LatLng(value.latitude, value.longitude),
            infoWindow: InfoWindow(title: 'My Current Location')),
      );

      CameraPosition cameraPosition = CameraPosition(
          target: LatLng(value.latitude, value.longitude), zoom: 14);

      GoogleMapController controller = await this.controller.future;

      controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    });
  }

  //any location find
  locateAnyLocation(
      double latitude, double longitude, String locationName) async {
    mymarker.add(
      Marker(
          markerId: MarkerId('123'),
          position: LatLng(latitude, longitude),
          infoWindow: InfoWindow(title: '${locationName}')),
    );

    CameraPosition cameraPosition =
        CameraPosition(target: LatLng(latitude, longitude), zoom: 14);

    GoogleMapController controller = await this.controller.future;

    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  //Add location to the user locations list
  List<String>? addLocationToList() {
    return locationInfo;
    print(locationInfo);
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: SafeArea(
            child: Stack(children: [
      GoogleMap(
        initialCameraPosition: _initialPosition,
        mapType: MapType.normal,
        markers: Set<Marker>.of(mymarker),
        onMapCreated: (GoogleMapController _controller) {
          controller.complete(_controller);
        },
      ),
      Positioned(
        top: height * 0.7,
        left: 5,
        child: Column(children: [
          Container(
            height: height * 0.07,
            width: width * 0.15,
            child: FloatingActionButton(
              child: Icon(Icons.search),
              onPressed: () {
                setState(() {
                  isListShowing = true;
                });
              },
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            height: height * 0.07,
            width: width * 0.15,
            child: FloatingActionButton(
              child: Icon(Icons.location_searching),
              onPressed: () async {
                locateMyLocation();
              },
            ),
          ),
        ]),
      ),
      Container(
        height: height * 0.3,
        child: Visibility(
          visible: isListShowing,
          child: showList(),
        ),
      )
    ])));
  }

  Widget showList() {
    return Visibility(
      visible: isListShowing,
      child: Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: search,
                decoration: InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  hintText: 'Search the place here',
                  fillColor: Colors.transparent,
                ),
              ),
            ),
            Expanded(
                child: Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: ListView.builder(
                  itemCount: listOfPlaces.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      onTap: () async {
                        selectedLocations = await locationFromAddress(
                            listOfPlaces[index]['description']);

                        await locateAnyLocation(
                            selectedLocations!.last.latitude,
                            selectedLocations!.last.longitude,
                            selectedLocations.toString());

                        print(selectedLocations!.last.longitude);
                        print(selectedLocations!.last.latitude);
                        setState(() {
                          search = TextEditingController(
                              text: listOfPlaces[index]['description']);
                          locationInfo = listOfPlaces[index]['description'];
                          listOfPlaces = [];
                          selectedLocations = [];
                          isListShowing = false;
                        });
                      },
                      title: Text(listOfPlaces[index]['description']),
                    );
                  }),
            )),
          ],
        ),
      ),
    );
  }
}
