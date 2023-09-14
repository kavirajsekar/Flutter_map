import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart'
    as google_api_headers;
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:location/location.dart' as getLocation;
import 'package:location/location.dart';
import 'dart:ui' as ui;
import 'package:maps/api_class.dart';
import 'dart:io' show Platform;

//Google map Api key for search button.
//Dont use this Google Api key
const kGoogleApiKey = "AIzaSyBUp8E7OghfEFg9fJ1ePokoOhE1I8MaD-M";

class home_screen extends StatefulWidget {
  home_screen({super.key});

  @override
  State<home_screen> createState() => _home_screenState();
}

class _home_screenState extends State<home_screen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //first time permission
    map_permission();
  }

  //markers
  final Set<Marker> _markers = {};
  //polylines
  final Set<Polyline> _polyline = {};
  //map controller
  GoogleMapController? _mapController;
  //Address field
  final AddressController = TextEditingController();
  //device height
  double deviceHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  double? lat;
  double? lng;
  String? Address;
  String latControllermap = '28.7041';
  String longControllermap = '77.1025';
  //flecting current location
  String LATTT = '', LONGGG = '';
// this is for current location
  late LatLng current_location;
// this is reqiurment provide lat, long
  LatLng loc1 = LatLng(13.0045, 80.2017);

//  image reduce the size
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

//current location
  current_location_marker() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/current_location.png', 150);
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(
            double.parse(latControllermap), double.parse(longControllermap)),
        zoom: 11.5)));

    setState(() {
      _markers.add(
        Marker(
            icon: BitmapDescriptor.fromBytes(markerIcon),
            markerId: MarkerId('1'),
            position: LatLng(double.parse(latControllermap),
                double.parse(longControllermap)),
            infoWindow: InfoWindow(
              title: 'Start Point',
            )),
      );
      current_location = LatLng(
          double.parse(latControllermap), double.parse(longControllermap));
    });
  }

// given location
  location_marker2() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/endpoint.png', 150);
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: loc1, zoom: 11.5)));

    setState(() {
      _markers.add(
        Marker(
            icon: BitmapDescriptor.fromBytes(markerIcon),
            markerId: MarkerId('2'),
            position: loc1,
            infoWindow: InfoWindow(
              title: 'End Point',
            )),
      );
      current_location = loc1;
    });
  }

//polylines
  draw_polylines() {
    _polyline.add(Polyline(
      polylineId: PolylineId('poly'),
      points: [loc1, current_location],
      color: Colors.blue,
    ));
  }

// search location
  Future<void> InternetAddressType() async {
    Prediction? p = await google_api_headers.PlacesAutocomplete.show(
        context: context,
        radius: 10000000,
        types: [],
        logo: const SizedBox.shrink(),
        strictbounds: false,
        mode: google_api_headers.Mode.overlay,
        language: "in",
        components: [
          //add this
          Component(Component.country, "fr"),
          Component(Component.country, "in"),
          Component(Component.country, "UK")
        ],
        apiKey: kGoogleApiKey);
    GoogleMapsPlaces places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );

    if (p != null) {
      _markers.clear();
      PlacesDetailsResponse detail =
          await places.getDetailsByPlaceId(p.placeId!);

      lat = detail.result.geometry?.location.lat;
      lng = detail.result.geometry?.location.lng;
      Address = detail.result.formattedAddress;

      AddressController.text = Address!;
      latControllermap = lat.toString();
      longControllermap = lng.toString();
      _mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(double.parse(latControllermap),
                  double.parse(longControllermap)),
              zoom: 11.5)));
      await current_location_marker();
    }
  }

// current location // permission
  map_permission() async {
    getLocation.Location location = getLocation.Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    locationData = await location.getLocation();
    LATTT = locationData.latitude.toString();
    LONGGG = locationData.longitude.toString();
  }

//
  onpresscurrent_location() {
    latControllermap = LATTT;
    longControllermap = LONGGG;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 6, 46, 115),
            elevation: 0,
            centerTitle: true,
            title: (Platform.isAndroid)
                ? Text(
                    " GoogleMap",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  )
                : Text(
                    " AppleMap",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                    textAlign: TextAlign.center,
                  )),
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .001,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .45,
                width: MediaQuery.of(context).size.width * 12,
                child: GoogleMap(
                  mapToolbarEnabled: true,
                  markers: _markers,
                  mapType: MapType.normal,
                  polylines: _polyline,
                  gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                    Factory<OneSequenceGestureRecognizer>(
                      () => EagerGestureRecognizer(),
                    ),
                  },
                  initialCameraPosition: CameraPosition(
                      target: LatLng(double.parse(latControllermap),
                          double.parse(longControllermap)),
                      zoom: 0),
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .03,
                    ),
                    Row(
                      children: <Widget>[
                        //Button 1 Draw route
                        Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  primary: Color.fromARGB(255, 6, 46, 115),
                                  onPrimary: Colors.white,
                                ),
                                onPressed: () async {
                                  setState(() {
                                    draw_polylines();
                                    location_marker2();
// if i call the Api iam getting the error in response.
                                    // api_service().location_api(context);
                                  });
                                },
                                child: Text(
                                  'Draw Route',
                                  style: TextStyle(fontSize: 15),
                                ))),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * .20,
                        ),
                        //Button 2 clear Route
                        Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  primary: Color.fromARGB(255, 171, 20, 10),
                                  onPrimary: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _polyline.clear();
                                  });
                                },
                                child: Text(
                                  'Clear Route',
                                  style: TextStyle(fontSize: 15),
                                ))),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .03,
                    ),
                    // Serach the current location
                    GestureDetector(
                      onTap: () async {
                        await InternetAddressType();
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * .06,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: const Color.fromARGB(255, 6, 46, 115),
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(4)),
                        ),
                        child: Container(
                          height: MediaQuery.of(context).size.width * .12,
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              const Icon(Icons.search),
                              Center(
                                child: Container(
                                  child: const Text(
                                    " Search user current location",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 6, 46, 115),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .03,
                    ),
                    TextFormField(
                      cursorColor: const Color.fromARGB(255, 6, 46, 115),
                      autofocus: false,
                      controller: AddressController,
                      decoration: InputDecoration(
                        labelText: '    Current Address ',
                        labelStyle: const TextStyle(
                          color: Color.fromARGB(255, 6, 46, 115), //<-- SEE HERE
                        ),
                        hintText: '    Current Address',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 6, 46, 115),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 6, 46, 115),
                          ),
                        ),
                        filled: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          elevation: 0,
          onPressed: () async {
            await onpresscurrent_location();
            await current_location_marker();
            setState(() {
              _polyline.clear();
              AddressController.clear();
            });
          },
          label: Icon(Icons.location_on),
          backgroundColor: const Color.fromARGB(255, 6, 46, 115),
        ));
  }
}
