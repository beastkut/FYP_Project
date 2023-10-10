import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomBottomSheet extends StatelessWidget {

  final String documentId;
  const CustomBottomSheet({super.key, required this.documentId});

  @override
  Widget build(BuildContext context) {
    CollectionReference userData= FirebaseFirestore.instance.collection('UserData');


    return FutureBuilder<DocumentSnapshot>(
        future: userData.doc(documentId).get(),
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.done){
            Map<String,dynamic> data =
                snapshot.data!.data() as Map<String,dynamic>;
            String? username = "${data['username']}";
            String? profileImage = "${data['profileImage']}";

            Widget buildProfileImage() => CircleAvatar(
              backgroundColor: Colors.grey.shade800,
              backgroundImage: NetworkImage(profileImage),
              radius: 27,
            );

            return Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 50),
              decoration: const BoxDecoration(
                color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  )
              ),

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    height: 4,
                    width: 50,

                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 223, 221, 221),
                      borderRadius: BorderRadius.circular(10)
                    ),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Organizer",
                          style:TextStyle(
                              color: Colors.black,
                              fontSize: 17
                          )
                      )
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const SizedBox(height: 5),
                      buildProfileImage(),
                      const SizedBox(width: 13),
                      Text(username,
                          style:const TextStyle(
                              color: Colors.black,
                              fontSize: 17
                          ))
                    ],
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Icon(Icons.phone,color: Colors.black),

                          Text(" 0132500738",
                              style:TextStyle(
                                  color: Colors.black,
                                  fontSize: 17
                              )),
                        ],
                      ),

                      GestureDetector(
                        onTap: () async {
                          await Clipboard.setData(const ClipboardData(text: "your text"));
                          // copied successfully
                        },
                        child: Row(
                          children: const [
                            Icon(Icons.copy,color: Colors.blueGrey),
                          ],
                        ),
                      ),

                    ],
                  )

                ],
              ),

            );
          }
          return const Text("");
        });
  }
}
