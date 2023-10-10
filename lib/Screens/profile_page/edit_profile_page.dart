import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  String userId = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  getUserDetails() async{
    final User user = auth.currentUser!;
    final uid = user.uid;
    setState(() {
      userId = uid;
    });
  }

  String? imageName ;
  String? imageDisplay ;
  XFile? imagePath;
  final ImagePicker _picker = ImagePicker();
  imagePicker() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if(image !=null){
      setState(() {
        imagePath = image;
        imageName = image.name.toString();
        imageDisplay = image.path;

      });
    }
  }

  CollectionReference profile = FirebaseFirestore.instance.collection('UserData');

  @override
  void initState() {
    // TODO: implement initState
    getUserDetails();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: profile.doc(userId).get(),
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.done){
            Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
            String? image = "${data['profileImage']}";
            String? username = "${data['username']}";
            String? desc = "${data['description']}";
            String? email = "${data['email']}";
            String? imageID = "${data['imageID']}";

            Widget buildProfileImage() =>
                GestureDetector(
                  onTap: (){
                    imagePicker();
                  },
                  child: (imageDisplay!=null)
                  ? CircleAvatar(
                    backgroundColor: Colors.grey.shade800,
                    backgroundImage: FileImage(File(imageDisplay!)),
                    radius: 65,
                  )
                  : CircleAvatar(
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage: NetworkImage(image),
                      radius: 65,
                    ),
                );


            final _usernameController = TextEditingController(text: username);
            final _descriptionController = TextEditingController(text: desc);

            FirebaseFirestore firestoreRef = FirebaseFirestore.instance;
            FirebaseStorage storageRef =  FirebaseStorage.instance;

            _uploadProfileImage() async {
              String uploadFileName = DateTime
                  .now()
                  .millisecondsSinceEpoch
                  .toString() + '.jpg';

              Reference reference = storageRef.ref("ProfileImage").child(userId).child(uploadFileName);
              UploadTask uploadTask = reference.putFile(File(imagePath!.path));

              if((imageDisplay!=null)){
                await uploadTask.whenComplete(() async{
                  var uploadPath = await uploadTask.snapshot.ref.getDownloadURL();

                  firestoreRef.collection('UserData').doc(userId).update({
                    "profileImage": uploadPath,
                    "imageID": uploadFileName
                  }).then((value) => null);

                });
              }


            }
            _updateProfileDetails() async {
              firestoreRef
                  .collection('UserData')
                  .doc(userId)
                  .update({
                "username":_usernameController.text.trim(),
                "description":_descriptionController.text.trim(),
              }).then((value) => null);
            }



            return Scaffold(
              appBar: AppBar(
                actions: [
                  IconButton(onPressed:(){
                    if(imageDisplay!=null){
                      FirebaseStorage.instance.ref().child("ProfileImage/$userId/$imageID").delete();
                      _uploadProfileImage();
                    }
                    _updateProfileDetails();

                    Navigator.pop(context);
                  },
                      icon: const Icon(Icons.check,color: Colors.white,))
                ],
              ),
              body: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                        children: [
                          const SizedBox(height: 5),
                          buildProfileImage(),


                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: TextFormField(
                              controller: _usernameController,

                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
                            child: TextFormField(
                              controller: _descriptionController,

                            ),
                          ),
                        ]
                    ),
                  )
              ),
            );
          }

          return const Text("loading...",
              style:TextStyle(
                  color: Colors.white
              )
          );
        });
  }
}
