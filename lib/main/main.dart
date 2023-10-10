import 'package:final_year_project/Screens/profile_page/edit_profile_page.dart';
import 'package:final_year_project/geofence.dart';
import 'package:final_year_project/Screens/profile_page/new_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'main_page.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp( const MyApp());
}

class MyApp extends StatelessWidget{
  const MyApp({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      home : MainPage(),
      theme: ThemeData(brightness: Brightness.dark),

    );
  }

}