import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/Screens/maps_page/gmaps.dart';
import 'package:final_year_project/Screens/create_page/upload_page.dart';
import 'package:final_year_project/Screens/profile_page/new_profile_page.dart';
import 'package:final_year_project/Screens/saved_page/new_saved_event_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../notification_api.dart';
import '../home_page/home_page.dart';
import 'package:geolocator/geolocator.dart' as geo;



class NavPage extends StatefulWidget {
  final int indexNo ;
  const NavPage({super.key,required this.indexNo});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  final screens = [
    const HomePage(),
    const SavedEventPage(),
    const UploadPage(),
    const MapSample(),
    const NewProfilePage()
  ];
  final _activityStreamController = StreamController<Activity>();
  final _geofenceStreamController = StreamController<Geofence>();
  final _geofenceList = <Geofence>[];

  final user = FirebaseAuth.instance.currentUser!;
  int? index;

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
    // TODO: implement initState
    super.initState();
    index = widget.indexNo;
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


    return Container(

      color: Colors.black,

      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        bottomNavigationBar: Padding(
          padding:  const EdgeInsets.symmetric(horizontal: 7.0,vertical: 5),
          child: GNav(
            color: Colors.grey,
            padding: const EdgeInsets.all(16),
            gap: 6,
            selectedIndex: index!,
            onTabChange: (index) => setState(() => this.index=index),
            iconSize: 20,
            tabActiveBorder: Border.all(color: Colors.white),
            activeColor: Colors.white,
            tabs:  const [
              GButton(
                icon: Icons.home,
              ),

              GButton(
                  icon: Icons.favorite_border_outlined,
              ),

              GButton(
                icon: Icons.add,
              ),

              GButton(
                icon: Icons.map_outlined,
              ),

              GButton(
                icon: Icons.account_circle_outlined,
              ),

            ],
          ),
        ),

        body: Container(
          child: Column(
            children: [
              Container(
                  height:MediaQuery.of(context).size.height * 0.92,
                  child: screens[index!]
              ),

              Padding(
                  padding: const EdgeInsets.symmetric(vertical:0,horizontal: 0),
                  child: _location !=null
                      ?  _widget()
                      :  null
              ),

            ],
          ),
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
