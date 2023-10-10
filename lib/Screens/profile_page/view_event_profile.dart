import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_count_down/date_count_down.dart';
import 'package:final_year_project/Screens/main_layout/navigation_page.dart';
import 'package:final_year_project/Screens/maps_page/bottom_sheet.dart';
import 'package:final_year_project/Screens/profile_page/edit_event_page.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:url_launcher/url_launcher.dart';

import 'edit_profile_page.dart';


class EventProfilePage extends StatefulWidget {

  final String docId;
  const EventProfilePage({super.key, required this.docId});

  @override
  State<EventProfilePage> createState() => _EventProfileState();
}

class _EventProfileState extends State<EventProfilePage> {

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    CollectionReference events = FirebaseFirestore.instance.collection('Events');
    CollectionReference fav = FirebaseFirestore.instance.collection('Favorite');
    return FutureBuilder<DocumentSnapshot>(
      future: events.doc(widget.docId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
          snapshot.data!.data() as Map<String, dynamic>;
          String? image = "${data['image_url']}";
          String? title = "${data['title']}";
          String? category = "${data['category']}";
          String? description = "${data['description']}";
          String? address = "${data['address']}";
          String? uid = "${data['uid']}";
          DateTime? startDate =data["date_start"].toDate();
          DateTime? endDate =data["date_end"].toDate();
          DateTime? dateTime = DateTime.now();


          return Scaffold(
            appBar: AppBar(
              actions: [
                PopupMenuButton(
                    icon: const Icon(Icons.menu),
                    onSelected: (value) async {
                      switch (value){
                        case 1:
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                                return  EditEventPage(docID: widget.docId);
                              }
                              ));
                          break;
                        case 2:
                          events.doc(widget.docId).delete();


                          Timer(Duration(seconds: 2),(){
                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context){
                              return const NavPage(indexNo: 4);
                            }), (e) => false);

                          });

                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 1,child: Text("Edit"),),
                      const PopupMenuItem(value: 2,child: Text("Delete"),)
                    ]),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      height: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 224, 224, 224),
                        image: DecorationImage(
                          image: NetworkImage(image),
                          fit: BoxFit.fill
                        )
                      ),
                    ),

                    const SizedBox(height: 10),
                    Padding(
                        padding: const EdgeInsets.only(top: 8, left: 15, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  title,
                                  maxLines: 3,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white
                                  ),
                                ),
                              ),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const LikeButton(size: 20),
                                  const SizedBox(width: 5,),
                                  InkWell(
                                    onTap: (){
                                      showModalBottomSheet(
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (context){
                                            return CustomBottomSheet(documentId: uid);
                                          });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: const Icon(
                                        Icons.person,
                                        size: 15,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  InkWell(
                                    onTap: () async{
                                      var urls ="https://www.google.com/maps/search/?api=1&query=$address";
                                      Uri uri = Uri.parse(urls);
                                      if(await canLaunchUrl(uri)){
                                        await launchUrl(uri);
                                      }
                                      else{
                                        throw "Cannot load Url";
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: const Icon(
                                        Icons.location_pin,
                                        size: 15,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category,
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16
                                ),
                              ),

                              dateTime.isBefore(startDate!)
                              ? Row(
                                children: [
                                  const Text(
                                    "Start in: ",
                                    style: TextStyle(
                                      color: Colors.white70
                                    ),
                                  ),
                                  CountDownText(
                                    due: startDate,
                                    finishedText: "Done",
                                    showLabel: true,
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ],
                              )
                              : Row(
                                children: [
                                  const Text(
                                    "End in: ",
                                    style: TextStyle(
                                        color: Colors.white70
                                    ),
                                  ),
                                  CountDownText(
                                    due: endDate,
                                    finishedText: "Done",
                                    showLabel: true,
                                    style: const TextStyle(color: Colors.blue),
                                  ),
                                ],
                              )
                            ],
                          ),

                          const SizedBox(height: 20),

                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const Text("loading...",
            style: TextStyle(
                color: Colors.white
            )
        );
      },

    );
  }
}
