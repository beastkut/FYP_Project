import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/Screens/main_layout/navigation_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:place_picker/place_picker.dart';

import '../../main/main_page.dart';


class EditEventPage extends StatefulWidget {
  final String docID;
  const EditEventPage({super.key,required this.docID});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {

  CollectionReference event = FirebaseFirestore.instance.collection('Events');
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

  final FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestoreRef = FirebaseFirestore.instance;
  FirebaseStorage storageRef =  FirebaseStorage.instance;

  final items = ['E-sport', 'Sport', 'Education', 'Festival & Concert','Other'];
  String? value;
  String? cat ;
  DropdownMenuItem<String> buildMenuItem(String item) => DropdownMenuItem(
    value: item,
    child: Text(
      item,
      style: const TextStyle( color: Colors.grey,
          fontWeight: FontWeight.bold
          , fontSize: 15),
    ),
  );

  DateTime? _startDate;
  DateTime? _endDate;



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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: event.doc(widget.docID).get(),
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.done){
            Map<String, dynamic> data =
            snapshot.data!.data() as Map<String, dynamic>;
            String? image = "${data['image_url']}";
            String? imageID = "${data['image_id']}";
            String? title = "${data['title']}";
            String? category = "${data['category']}";
            String? contact = "${data['contact']}";
            String? description = "${data['description']}";
            String? address = "${data['address']}";
            String? uid = "${data['uid']}";
            String? latitude = "${data['latitude']}";
            String? longitude = "${data['longitude']}";
            DateTime? startDate =data["date_start"].toDate();
            DateTime? endDate =data["date_end"].toDate();
            DateTime? dateTime = DateTime.now();
            print(widget.docID);

            final _titlecontroller = TextEditingController(text: title);
            final _descriptioncontroller = TextEditingController(text: description);
            final _contactcontroller = TextEditingController(text: contact);
            cat = category;


            void _showDatePickerStart(){
              showDatePicker(
                context: context,
                initialDate: startDate!,
                firstDate: startDate.isBefore(dateTime)
                            ? startDate
                            : dateTime,
                lastDate: DateTime(2025),

              ).then((value) {
                setState(() {
                  _startDate = value!;
                });
              });
            }

            void _showDatePickerEnd(){
              showDatePicker(
                context: context,
                initialDate: endDate!,
                firstDate: dateTime,
                lastDate: DateTime(2025),

              ).then((value) {
                setState(() {
                  _endDate = value!;
                });
              });
            }


            _updateEventImage() async {
              String uploadFileName = DateTime
                  .now()
                  .millisecondsSinceEpoch
                  .toString() + '.jpg';


              Reference reference = storageRef.ref("Image").child(uploadFileName);
              UploadTask uploadTask = reference.putFile(File(imagePath!.path));


              await uploadTask.whenComplete(() async{
                var uploadPath = await uploadTask.snapshot.ref.getDownloadURL();
                event.doc(widget.docID).update({
                  "image_id":uploadFileName,
                  "image_url":uploadPath,
                }).then((value) => null);
              });


            }

            _updateEventDetails() async {
              firestoreRef.collection('Events').doc(widget.docID).update({
                "title":_titlecontroller.text.trim(),
                "description":_descriptioncontroller.text.trim(),
                "contact":_contactcontroller.text.trim(),
                "date_start":_startDate!=null? _startDate : startDate,
                "date_end":_endDate!=null? _endDate :endDate,
                "category":value!=null? value : category,
                "latitude":lat!=null? lat : latitude,
                "longitude":lng!=null ? lng : longitude,
                "address":_locationAddress!=null? _locationAddress.toString() : address,

              }).then((value) => null);

              _titlecontroller.clear();
              _descriptioncontroller.clear();
              _contactcontroller.clear();
            }


            return Scaffold(
              backgroundColor: Colors.transparent,

              appBar: AppBar(
                backgroundColor: Colors.transparent,
                actions: [

                  TextButton(
                    onPressed: (){
                      if(imageDisplay!=null){
                        _updateEventImage();
                        FirebaseStorage.instance.ref().child("Image/$imageID").delete();

                      }
                      _updateEventDetails();
                      Timer(Duration(seconds: 2), () {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
                          return const NavPage(indexNo: 4);
                        }), (e) => false);
                      });
                    },
                    child: const Icon(
                      Icons.check,
                      color: Colors.grey,
                      size: 30,
                    ),
                  )
                ],
              ),

              body: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                          onTap: (){
                            imagePicker();
                          },
                          child: (imageDisplay!=null)
                              ? Container(
                            height: 150,
                            width: 150,
                               decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  image: DecorationImage(
                                      image: FileImage(File(imageDisplay!))
                                  )
                              ),
                          )
                              : Container(
                            height: 150,
                            width: 150,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.white),
                                image: DecorationImage(
                                    image: NetworkImage(image)
                                )
                            ),
                          )
                      )
                    ],

                  ),
                  const SizedBox(height: 5),

                  TextFormField(
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
                          hint: Text(cat!),
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

                          Text( _startDate !=null
                              ? DateFormat('dd-MM-yyyy').format(_startDate!)
                              : DateFormat('dd-MM-yyyy').format(startDate!),
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

                          Text( _endDate != null
                              ? DateFormat('dd-MM-yyyy').format(_endDate!)
                              : DateFormat('dd-MM-yyyy').format(endDate!),
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
                        child: Text(_locationAddress!=null
                            ?"Location : $_locationAddress"
                            :"Location : $address",
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
