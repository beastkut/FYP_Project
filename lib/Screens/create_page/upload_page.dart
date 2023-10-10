import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:place_picker/place_picker.dart';

import '../../main/main_page.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {

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


  final _titlecontroller = TextEditingController();
  final _descriptioncontroller = TextEditingController();
  final _contactcontroller = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestoreRef = FirebaseFirestore.instance;
  FirebaseStorage storageRef =  FirebaseStorage.instance;
  String collectionName = "Events";
  _uploadImage() async {
    String uploadFileName = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString() + '.jpg';

    String timeStamp = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    Reference reference = storageRef.ref("Image").child(uploadFileName);
    UploadTask uploadTask = reference.putFile(File(imagePath!.path));

    uploadTask.snapshotEvents.listen((event) {
      print(event.totalBytes.toString() + "\t" +
          event.bytesTransferred.toString());
    });

    await uploadTask.whenComplete(() async {
      final User user =  auth.currentUser!;
      final uid = user.uid;
      // here you write the codes to input the data into firestore
      var uploadPath = await uploadTask.snapshot.ref.getDownloadURL();
      firestoreRef.collection(collectionName).doc().set({
        "uid":uid.toString(),
        "image_id":uploadFileName,
        "image_url":uploadPath,
        "title":_titlecontroller.text.trim(),
        "description": _descriptioncontroller.text.trim(),
        "contact": _contactcontroller.text.trim(),
        "date_start": _startDate,
        "date_end": _endDate,
        "category": value,
        "latitude":lat,
        "longitude":lng,
        "address":_locationAddress.toString(),
        "timestamp": timeStamp
      }).then((value) => null);

      _titlecontroller.clear();
      _descriptioncontroller.clear();
      _contactcontroller.clear();
    });
  }

  DateTime _startDate = DateTime.now();
  void _showDatePickerStart(){
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),

    ).then((value) {
      setState(() {
        _startDate = value!;
      });
    });
  }

  DateTime _endDate = DateTime.now();
  void _showDatePickerEnd(){
    showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2025),

    ).then((value) {
      setState(() {
        _endDate = value!;
      });
    });
  }


  String? lat;
  String? lng;
  String? _locationAddress;
  void _showPlacePicker() async {
    LocationResult result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            PlacePicker("AIzaSyAhWUl77w84O7LXHKobTAInGd-i5BPHLik",
            )
    ));

    setState(() {
      _locationAddress= result.formattedAddress;
      lat=result.latLng!.latitude.toString();
      lng=result.latLng!.longitude.toString();
      //print('lat = $lat');

    });


  }

  final items = ['E-sport', 'Sport', 'Education', 'Festival & Concert','Other'];
  String? value;
  String cat = 'Category';
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
      value: item,
      child: Text(
        item,
        style: const TextStyle( color: Colors.grey,
            fontWeight: FontWeight.bold
            , fontSize: 15),
      ),
  );

  @override
  void dispose() {
    // TODO: implement dispose
    _contactcontroller.dispose();
    _descriptioncontroller.dispose();
    _titlecontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [

          TextButton(
              onPressed: (){
                _uploadImage();
                Timer(Duration(seconds: 2), () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
                    return const MainPage();
                  }), (e) => false);
                });
              },
              child: const Icon(
                  Icons.arrow_forward_outlined,
                  color: Colors.grey,
                size: 30,
              ),
              )
        ],
      ),

      body: Container(
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: (){
                    imagePicker();
                  },
                  child: Container(

                    height: 150,
                    width: 150,

                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.white)
                    ),
                    child: Column(
                      children:  [
                        (imageDisplay!=null)
                            ? Image.file(File(imageDisplay!),height: 145,width: 145,)
                            :const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 50.0 ,vertical: 50),
                          child:Icon(
                              Icons.upload_rounded,
                              color: Colors.white,
                              size: 30,
                          ) ,
                        )
                      ],
                    ),
                  )
                )
              ],

            ),
            const SizedBox(height: 5),

            TextField(
              controller: _titlecontroller,
              style: const TextStyle(
                  color: Colors.white
              ),
              decoration: const InputDecoration(
                  hintText: 'Interesting title for your event ....',
                  hintStyle: TextStyle(
                      color: Colors.grey
                  )
              ),
            ),

            const SizedBox(height: 5),

             TextField(
              controller: _descriptioncontroller,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: const TextStyle(
                  color: Colors.white
              ),
              decoration: const InputDecoration(
                  hintText: 'Description ....',
                  hintStyle: TextStyle(
                      color: Colors.grey
                  )
              ),
            ),

            const SizedBox(height: 5),

            TextField(
              controller: _contactcontroller,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              style: const TextStyle(
                  color: Colors.white
              ),
              decoration: const InputDecoration(
                  hintText: 'Contact info ....',
                  hintStyle: TextStyle(
                      color: Colors.grey
                  )
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                    hint: Text(cat),
                    value: value,
                    items: items.map(buildMenuItem).toList(),
                    onChanged: (value) => setState(() {
                      this.value=value;
                      cat=value!;
                      })
                )
              ],
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text("Start Date : ",style: TextStyle(color: Colors.grey),),

                    const SizedBox(width: 10),

                    Text(DateFormat('dd-MM-yyyy').format(_startDate),
                        style:const TextStyle(color: Colors.grey,fontSize: 15)
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(onTap: (){
                      _showDatePickerStart();
                    },
                        child: const Icon(Icons.calendar_month,color: Colors.grey,))
                  ],
                ),

                Row(
                  children: [
                    const Text("End Date : ",style: TextStyle(color: Colors.grey),),

                    const SizedBox(width: 10),

                    Text(_startDate.isBefore(_endDate) || _startDate.isAtSameMomentAs(_endDate) ? DateFormat('dd-MM-yyyy').format(_endDate) : '',
                        style:const TextStyle(color: Colors.grey,fontSize: 15)
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(onTap: (){
                      _showDatePickerEnd();
                    },
                        child: const Icon(Icons.calendar_month,color: Colors.grey,))
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 350,
                  child: Text("Location : $_locationAddress",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey)
                  ),
                ),
                GestureDetector(onTap: (){
                  _showPlacePicker();
                },
                    child: const Icon(Icons.pin_drop,color: Colors.grey,))
              ],
            ),
          ],
        ),
      ),

    );
  }

}