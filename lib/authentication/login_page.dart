import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'forgot_pw_page.dart';

class LoginPage extends StatefulWidget{
  final VoidCallback showRegisterPage;
  const LoginPage({Key? key,required this.showRegisterPage}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage>{
  bool _obscureText = true;

  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future signIn() async{
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim()
      );
    }on FirebaseException catch (e){
      print(e);
      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              content: Text("Username or Password is incorrect"),
            );
          });
    }


  }

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
            image: NetworkImage(
                'https://i.pinimg.com/564x/60/c7/80/60c78026a1b2b2956f09a57e8bd6d723.jpg'
            ),
          fit: BoxFit.cover,
        ),
      ),

    child: Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  'SideQuest',
              style: GoogleFonts.dancingScript(
                fontSize: 60,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              ),

              const SizedBox(height: 15),

              //email textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      controller: _emailController,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Email',
                        hintStyle: TextStyle(color: Colors.grey)
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              //password textfield
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:  Container(
                    padding: const EdgeInsets.only(left: 20.0) ,
                    child: TextField( style: TextStyle(color: Colors.black ),
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText =!_obscureText;
                            });

                          },
                            child:Icon(_obscureText
                                ?Icons.visibility
                                :Icons.visibility_off),

                        ),
                        border: InputBorder.none,
                        hintText: 'Password',
                        hintStyle: TextStyle(color: Colors.grey)
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              //Login Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: GestureDetector(
                  onTap: signIn,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:  const Center(
                        child: Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize:20),
                        ),
                      ),
                    ),
                  ),
              ),
              const SizedBox(height: 20),

              //register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [
                  const Text(
                    ' Not a member? ',
                    style: TextStyle(
                        color: Colors.white,
                    fontWeight: FontWeight.bold),
                  ),

                  GestureDetector(
                    onTap: widget.showRegisterPage ,
                    child:  const Text(
                      ' Register now',
                      style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

               SizedBox(height: 10),

              //forgot password
              GestureDetector(
                onTap: (){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                    return const forgotPasswordPage();
                  }
                  ));
                },
                child:  const Text(
                    'Forgot Password ?',
                    style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold)
                ),
              )
            ],
          ),
      ),
    );
  }

}