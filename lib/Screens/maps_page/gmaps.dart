import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/Screens/maps_page/view_event.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();

  BitmapDescriptor customMarker = BitmapDescriptor.defaultMarker;
  LocationData? currentLocation;
  double lat = 3.140853;
  double lng = 101.693207;



  final Set<Marker> _markers = {};

  void getCurrentLocation() async {
    Location location = Location();

    GoogleMapController googleMapController = await _controller.future;

    location.getLocation().then(
            (location) {
              currentLocation = location;
              setState(() {
                lat = currentLocation!.latitude!;
                lng = currentLocation!.longitude!;

              });
            });

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;

      googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 17,
                target: LatLng(
                  newLoc.latitude!,
                  newLoc.longitude!,
                ))

      ));
    });
  }

  void addMarker(String markerID, double lat, double lng) {
    _markers.add(
         Marker(
            markerId: MarkerId(markerID),
            position: LatLng(lat,lng)
        )
    );
  }

  DateTime date = DateTime.now();
  Future getDocId() async{
    await FirebaseFirestore.instance
        .collection("Events")
        .orderBy('timestamp',descending: true)
        .get()
        .then(
            (snapshot) => snapshot.docs.forEach(
                (document) {
                  
                  if(date.isBefore(document['date_end'].toDate()))
                    {
                      _markers.add(
                          Marker(
                              markerId: MarkerId(document.reference.id),
                              position: LatLng(double.parse(document['latitude']),double.parse(document['longitude'])),

                              onTap: (){
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                      return ViewEvent(docId: document.reference.id);
                                    }
                                    ));
                              }
                          )
                      );
                    }
            }));
  }




  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDocId();


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: GoogleMap(
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(
            target: LatLng(lat,lng),

        ),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        markers: _markers,

      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
          onPressed: getCurrentLocation,
          backgroundColor: Colors.white,
          child: const Icon(Icons.my_location) ,
      ),
    );
  }


}