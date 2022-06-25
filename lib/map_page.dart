
import 'package:flutter/material.dart';
import 'package:flutter_course/models/directions_model.dart';
import 'package:flutter_course/models/directions_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {

  List<String> map;

  MapScreen({required this.map});
  

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  LatLng? pos;

  CameraPosition? _cam;
  CameraPosition? _camZoom;

  @override
  void initState(){

    pos = LatLng(double.parse(widget.map[0]), double.parse(widget.map[1]));
    _cam = setCameraPosition(pos);
    _camZoom = setCameraPositionZoom(pos);

    _addMarker(_cam!.target);

    super.initState();
  }

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

/*  static const _initialCameraPosition = CameraPosition(
    target: LatLng(45.22, 2.33),
    //target: pos!,
    zoom: 11.5,
    tilt: 20,
  );  */

  static const _clickCameraPosition = CameraPosition(
    target: LatLng(45.22, 2.33),
    zoom: 14.5,
    tilt: 20,
  );

  GoogleMapController? _googleMapController;
  Marker? _origin;
  Marker? _destination;
  Directions? _info;

 
  @override
  void dispose() {
    _googleMapController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      /*  actions: [
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
          if (_destination != null)
            TextButton(
              onPressed: () => _googleMapController!.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: _destination!.position,
                    zoom: 14.5,
                    tilt: 50.0,
                  ),
                ),
              ),
              style: TextButton.styleFrom(
                primary: Colors.blue,
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
              child: const Text('DEST'),
            )
        ],  */
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
            //onLongPress: _addMarker,
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
    );
  }

  void _addMarker(LatLng pos) async {
    if (_origin == null || (_origin != null && _destination != null)) {
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
    } 
    /*
    else {
      // Origin is already set
      // Set destination
      setState(() {
        _destination = Marker(
          markerId: const MarkerId('destination'),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: pos,
        );
      });

      // Get directions
      final directions = await DirectionsRepository()
          .getDirections(origin: _origin!.position, destination: pos);
      setState(() => _info = directions);
    } */
  }
}