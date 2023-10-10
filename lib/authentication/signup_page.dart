import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback showLoginPage;
  const RegisterPage({Key? key ,required this.showLoginPage}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscureText = true;

  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userNameController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _userNameController.dispose();
    super.dispose();
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  Future addUserDetails() async{
    final User user = auth.currentUser!;
    final uid = user.uid;
    await FirebaseFirestore.instance.collection("UserData").doc(uid).set({
      "email": _emailController.text.trim(),
      "username": _userNameController.text.trim(),
      "description": null,
      "profileImage" : 'https://png.pngitem.com/pimgs/s/508-5087146_circle-hd-png-download.png',
    });
  }

  Future signUp() async {

    if(passwordConfirm()){
      QuerySnapshot query = await FirebaseFirestore.instance.collection('UserData').where('username',isEqualTo:_userNameController.text.trim()).get();
      if (query.docs.isNotEmpty){
        showDialog(
            context: context,
            builder: (context){
              return const AlertDialog(
                content: Text("This username has been taken!"),
              );
            });
      }
      else {
        QuerySnapshot query = await FirebaseFirestore.instance.collection('UserData').where('email',isEqualTo:_emailController.text.trim()).get();
        if (query.docs.isNotEmpty){
          showDialog(
              context: context,
              builder: (context){
                return const AlertDialog(
                  content: Text("The email has been registered!"),
                );
              });
        }

        else{
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim());

          showDialog(
              context: context,
              builder: (context){
                return const AlertDialog(
                  content: Text("Account has been successfully registered"),
                );
              });
        }
          addUserDetails();
        }
      }
    else{
      showDialog(
          context: context,
          builder: (context){
            return const AlertDialog(
              content: Text("Password and confirm password does not match!"),
            );
          });
    }
  }

  bool passwordConfirm(){
    if(_passwordController.text.trim()==
        _confirmPasswordController.text.trim()){
      return true;
    }
    else{
      return false;
    }
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
          body:SafeArea(
              child:Center(
                child: Column(
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

                    //username textfield
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
                            style: const TextStyle(color: Colors.black),
                            controller: _userNameController,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Username',
                              hintStyle: TextStyle(color: Colors.grey)
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

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
                            style: const TextStyle(color: Colors.black),
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
                          child: TextField(
                            style: const TextStyle(color: Colors.black),
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
                              hintStyle: const TextStyle(color: Colors.grey)
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    //confirm password textfield
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
                          child: TextField(
                            style: const TextStyle(color: Colors.black),
                            controller: _confirmPasswordController,
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
                              hintText: 'Confirm Password',
                              hintStyle: const TextStyle(color: Colors.grey)
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    //Sign up Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: GestureDetector(
                        onTap: (){
                          if(_emailController.text.isEmpty || _userNameController.text.isEmpty || _passwordController.text.isEmpty || _confirmPasswordController.text.isEmpty ){
                            showDialog(context: context, builder: (context){
                              return const AlertDialog(
                                content: Text("Please fill all the details !"),
                              );

                            });
                          }

                          else{
                            signUp();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Sign Up',
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
                          ' I am a member? ',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),


                           GestureDetector(
                             onTap: widget.showLoginPage,
                             child: const Text(
                              ' Login now',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold),
                          ),
                           ),

                      ],
                    )



                  ],
                ),
              )
          )
      ),

    );

  }

}
