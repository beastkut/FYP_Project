import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/notification_api.dart';
import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:geolocator/geolocator.dart' as geo;



class Geofencing extends StatefulWidget {
  const Geofencing({Key? key}) : super(key: key);

  @override
  State<Geofencing> createState() => _GeofencingState();
}

class _GeofencingState extends State<Geofencing> {

  final _activityStreamController = StreamController<Activity>();
  final _geofenceStreamController = StreamController<Geofence>();

  geo.Position? _position;
  Location? _location;
  GeofenceStatus? _geofenceStatus;
  String? previousActivity;
  String? currActivity;
  bool alert = true;

  final _geofenceService = GeofenceService.instance.setup(
      interval: 5000,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      useActivityRecognition: true,
      allowMockLocations: false,
      printDevLog: false,
      geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

  final _geofenceList = <Geofence>[];

  DateTime date = DateTime.now();
  List<String> docIDs = [];
  Future getDocId() async{
    await FirebaseFirestore.instance
        .collection("Events")
        .orderBy('timestamp',descending: true)
        .get()
        .then(
            (snapshot) => snapshot.docs.forEach(
                (document) {
              if(date.isAfter(document['date_start'].toDate())
                  &&  date.isBefore(document['date_end'].toDate())
              ){
                docIDs.add(document.reference.id);
                addFence(Geofence(
                  id: document.reference.id,
                  latitude: double.parse(document['latitude']),
                  longitude: double.parse(document['longitude']),
                  radius: [
                    GeofenceRadius(id: 'radius_100m', length: 100),
                  ],
                ));
              }
              print('docIDs.length:' + docIDs.length.toString());
              print(_geofenceList.length.toString());
            }));
    _geofenceService.start(_geofenceList).catchError(_onError);
  }

  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    setState(() {
      _geofenceStatus = geofenceStatus;
    });
    //print('geofence: ${geofence.toJson()}');
    //print('geofenceRadius: ${geofenceRadius.toJson()}');
    _geofenceStreamController.sink.add(geofence);
  }

  void _getCurrentLocation() async{
    geo.Position position = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy:geo.LocationAccuracy.high);
    setState((){
      _position = position;
    });

  }

  final geo.LocationSettings locationSettings =  const geo.LocationSettings(
    accuracy: geo.LocationAccuracy.high,
    distanceFilter: 30,
  );

  void _continuousLocation() async{
    StreamSubscription<geo.Position> positionStream = geo.Geolocator.getPositionStream(locationSettings: locationSettings).listen(
            (geo.Position? position) {
          setState(() {
            _position = position;
          });
        });
  }

  void _onActivityChanged(Activity prevActivity, Activity currActivity) {
    _activityStreamController.sink.add(currActivity);
  }

  void _onLocationChanged(Location location) {
    setState(() {
      _location = location;
    });
  }

  void _onLocationServicesStatusChanged(bool status) {
  }

  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      return;
    }

  }

   void addFence(Geofence geofence){
    _geofenceList.add(geofence);
   }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getDocId();
      _geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      _geofenceService.addActivityChangeListener(_onActivityChanged);
      _geofenceService.addLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
      _geofenceService.addLocationChangeListener(_onLocationChanged);
      _geofenceService.addStreamErrorListener(_onError);
      _continuousLocation();
      NotificationApi.init();
    });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Flutter'),
        ),
        body:  Column(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 100.0,horizontal: 100),
                  child: _location !=null
                      ?  _widget()
                      :  null
                ),

                FloatingActionButton(
                  onPressed: dispose,
                  child: const Icon(Icons.clear),
                ),

                const SizedBox(height: 15),

                ElevatedButton(
                    onPressed: () => NotificationApi.showNotification(
                        title: 'SideQuest',
                        body: 'There is an event near you !!!',
                        payload: 'sarah.abs'
                    ),
                    child: const Text('My Button')
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _widget(){
    if(_geofenceStatus == GeofenceStatus.ENTER){
      if(alert == true){

          NotificationApi.showNotification(
              title: 'SideQuest',
              body: 'There is an event near you !!!',
              payload: 'sarah.abs'
          );
          alert= false;
        }
      }

    else if (_geofenceStatus == GeofenceStatus.EXIT){
      alert = true;
    }
    return null;
  }
}



