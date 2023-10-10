import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_count_down/date_count_down.dart';
import 'package:final_year_project/Screens/maps_page/bottom_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:url_launcher/url_launcher.dart';


class ViewEvent extends StatefulWidget {

  final String docId;
  const ViewEvent({super.key, required this.docId});

  @override
  State<ViewEvent> createState() => _ViewEventState();
}

class _ViewEventState extends State<ViewEvent> {
  bool isLike = false;
  final List<String>_favDocID = [];
  late final Future _myFuture;
  
  Future getDocId() async{
    await FirebaseFirestore.instance
        .collection("Favorite")
        .doc(userId)
        .collection("EventID")
        .get()
        .then(
            (snapshot) => snapshot.docs.forEach(
                (document) {
                  if(widget.docId == document.reference.id) {
                      print(document.reference.id);
                      _favDocID.add(document.reference.id);
                      isLike = true;
                    }

            }));
}

  String userId = "";
  final FirebaseAuth auth = FirebaseAuth.instance;
  getUserDetails() async{
    final User user = auth.currentUser!;
    final uid = user.uid;
    setState(() {
      userId = uid;
    });
  }


  @override
  void initState() {
    getUserDetails();
    _myFuture = getDocId();

    // TODO: implement initState
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    CollectionReference profile = FirebaseFirestore.instance.collection('Events');
    CollectionReference fav = FirebaseFirestore.instance.collection('Favorite');

    
    

    return FutureBuilder<DocumentSnapshot>(
      future: profile.doc(widget.docId).get(),
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

          _addFav()async{
            fav.doc(uid).collection("EventID").doc(widget.docId).set({
            });
          }
          _deleteFav()async{
            fav.doc(uid).collection("EventID").doc(widget.docId).delete();
          }


          return Scaffold(
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
                                   LikeButton(size: 20,
                                     isLiked: isLike,
                                     onTap: (isLiked) async{
                                          isLiked?
                                          _deleteFav(): _addFav();
                                          isLike = !isLiked;

                                          return isLike;

                                     },
                                   ),
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
