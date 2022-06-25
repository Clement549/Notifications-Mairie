import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_course/models/directions_model.dart';
import 'package:flutter_course/models/directions_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreenPicker extends StatefulWidget {
  @override
  _MapScreenPickerState createState() => _MapScreenPickerState();
}

class _MapScreenPickerState extends State<MapScreenPicker> {

  CameraPosition? _cam;
  CameraPosition? _camZoom;

  LatLng? currentPos;
  String currentPosString = "";

  CameraPosition setCameraPosition(pos){
     return CameraPosition(
        target: pos!,
        //target: pos!,
        zoom: 11.5,
        tilt: 20,
      );
  }
  CameraPosition setCameraPositionZoom(pos){
     return CameraPosition(
        target: pos!,
        //target: pos!,
        zoom: 14.5,
        tilt: 20,
      );
  }

  GoogleMapController? _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Directions? _info;

  @override
  void initState() {

    _cam = setCameraPosition(LatLng(45.22, 2.33));
    _camZoom = setCameraPositionZoom(LatLng(45.22, 2.33));

    activateGPS();

    super.initState();
  }
  @override
  void dispose() {
    _googleMapController!.dispose();
    super.dispose();
  }

  Future activateGPS() async {

    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();

    currentPos =  LatLng(_locationData.latitude!, _locationData.longitude!);
    currentPosString = _locationData.latitude!.toString()+","+_locationData.longitude!.toString();

    _cam = setCameraPosition(currentPos);
    _camZoom = setCameraPositionZoom(currentPos);

    _addMarker(currentPos!);

    _googleMapController!.animateCamera(
            _info != null
                ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
                : CameraUpdate.newCameraPosition(_cam!),
    );    
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _willPop(context),
      child: Scaffold( 
        appBar: AppBar(
          toolbarHeight: 50,
          flexibleSpace: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(100, 198, 214, 1),
                        Color.fromRGBO(0,152, 242, 1),
                      ],
                    ),
                    boxShadow: [
                      //background color of box
                      BoxShadow(
                        color: Color.fromRGBO(0, 50, 70, 1),
                        blurRadius: 5.0, // soften the shadow
                        spreadRadius: 1.0, //extend the shadow
                        offset: Offset(
                          0, // Move to right 10  horizontally
                          0, // Move to bottom 10 Vertically
                        ),
                      )
                    ],
                  ),
              ),
          centerTitle: false,
          title: const Text('Localisation'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () { 
              if(currentPosString.isNotEmpty)
              Navigator.pop(context, currentPosString);
              if(currentPosString.isEmpty)
              Navigator.pop(context);
            }
          ), 
          /*actions: [
            if (_origin != null)
             TextButton(
                onPressed: () => _googleMapController!.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(
                      target: _origin!.position,
                      zoom: 14.5,
                      tilt: 50.0,
                    ),
                  ),
                ),
                style: TextButton.styleFrom(
                  primary: Colors.green,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('ORIGIN'),
              ), 
              TextButton(
                onPressed: () => Navigator.pop(context, currentPosString),
                style: TextButton.styleFrom(
                  primary: Colors.blue,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600),
                ),
                child: const Text('DEST'),
              )
          ], */
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: _cam!,
              onMapCreated: (controller) => _googleMapController = controller,
              markers: {
                if (_origin != null) _origin!,
                if (_destination != null) _destination!
              },
              polylines: {
                if (_info != null)
                  Polyline(
                    polylineId: const PolylineId('overview_polyline'),
                    color: Colors.red,
                    width: 5,
                    points: _info!.polylinePoints
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList(),
                  ),
              },
              onTap: _addMarker,
            ),
            if (_info != null)
              Positioned(
                top: 20.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6.0,
                    horizontal: 12.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.yellowAccent,
                    borderRadius: BorderRadius.circular(20.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      )
                    ],
                  ),
                  child: Text(
                    '${_info!.totalDistance}, ${_info!.totalDuration}',
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Container(
            width: 60,
            height: 60,
            child: const Icon(Icons.center_focus_strong, color: Colors.white,),
            decoration: const BoxDecoration(
                  shape: BoxShape.circle, // circular shape
                  gradient: LinearGradient(
                    colors: [
                        Color.fromRGBO(100, 198, 214, 1),
                        Color.fromRGBO(0,152, 242, 1),
                    ],
                  ),
                  boxShadow: [
                      //background color of box
                      BoxShadow(
                        color: Color.fromRGBO(0, 50, 70, 1),
                        blurRadius: 3.0, // soften the shadow
                        spreadRadius: 0.8, //extend the shadow
                        offset: Offset(
                          0, // Move to right 10  horizontally
                          0, // Move to bottom 10 Vertically
                        ),
                      )
                  ],
            ),

          ),
          onPressed: () => _googleMapController!.animateCamera(
              _info != null
                  ? CameraUpdate.newLatLngBounds(_info!.bounds, 100.0)
                  : CameraUpdate.newCameraPosition(_camZoom!),
            ),     
        ),
      ),
    );
  }

  void _addMarker(LatLng pos) async {
    
      // Origin is not set OR Origin/Destination are both set
      // Set origin
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Lieu indiqué'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          position: pos,
        );
        // Reset destination
        _destination = null;

        // Reset info
        _info = null;
      });

      currentPos =  LatLng(pos.latitude, pos.longitude);
      currentPosString = pos.latitude.toString()+","+ pos.longitude.toString();

      _cam = setCameraPosition(pos);
      _camZoom = setCameraPositionZoom(pos);

      //returnPos(pos);
  }

  String returnPos(pos){

      List<String> l = [pos.latitude.toString(), pos.longitude.toString()];

      log(l[0]+","+l[1]);
      
      return l[0]+","+l[1];
  }


  Future<bool> _willPop(BuildContext context) {
    
    final completer = Completer<bool>();
    completer.complete(true);

    if(currentPosString.isNotEmpty)
      Navigator.pop(context, currentPosString);
    if(currentPosString.isEmpty)
      Navigator.pop(context);

    return completer.future;
  }
}