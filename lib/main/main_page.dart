import 'package:final_year_project/Screens/main_layout/navigation_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../authentication/auth_page.dart';



class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context,snapshot){
        if(snapshot.hasData){
          return const NavPage(indexNo: 0,);
        }
        else{
          return const AuthPage();
        }

      },
      )
    );
  }
}
