
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/Widget/numberwidget_page.dart';
import 'package:final_year_project/Screens/profile_page/edit_profile_page.dart';
import 'package:final_year_project/Screens/profile_page/view_event_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

class NewProfilePage extends StatefulWidget {
  const NewProfilePage({Key? key}) : super(key: key);

  @override
  State<NewProfilePage> createState() => _NewProfilePageState();
}

class _NewProfilePageState extends State<NewProfilePage> {

  final List<String> _activeDocIDs = [];
  final List<String> _allDocIDs = [];
  DateTime date = DateTime.now();
  late final Future _myFuture;
  Future getDocId() async{
    await FirebaseFirestore.instance
        .collection("Events")
        .orderBy('timestamp',descending: true)
        .get()
        .then(
            (snapshot) => snapshot.docs.forEach(
                (document) {
                  if(userId==document["uid"].toString()){
                      _allDocIDs.add(document.reference.id);
                      if(date.isAfter(document["date_start"].toDate())
                          && date.isBefore(document["date_end"].toDate())){
                        _activeDocIDs.add(document.reference.id);
                      }
                    }
            }));
    print(_activeDocIDs.length);
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _myFuture,
      builder: (context,snapshot){
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 315,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30),bottomRight: Radius.circular(30)),
                    image: DecorationImage(
                        image: NetworkImage('https://i.pinimg.com/originals/53/d9/cd/53d9cd303086eae0decfed3d000fc976.jpg'),
                        fit: BoxFit.fill
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0,right: 10,top: 10),
                            child: Text(
                              'My Profile',
                              style: GoogleFonts.arsenal(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: (){
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                    return const EditProfilePage();
                                  }
                                  ));
                            },
                            child: const Padding(
                              padding: EdgeInsets.only(right: 10,top: 10),
                              child: Icon(Icons.edit,color: Colors.white,),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 5),

                      profileItemBuilder(userId),

                      const SizedBox(height: 5),

                       NumbersWidget(activeEvent: _activeDocIDs.length ,allEvent: _allDocIDs.length,)
                    ],
                  ),
                ),
                const SizedBox(height: 5),

                Container(
                  height: 500,
                  child: GridView.custom(
                      gridDelegate: SliverQuiltedGridDelegate(
                          crossAxisCount: 4,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                          repeatPattern: QuiltedGridRepeatPattern.inverted,
                          pattern: [
                            const QuiltedGridTile(2, 2),
                            const QuiltedGridTile(1, 1),
                            const QuiltedGridTile(1, 1),
                            const QuiltedGridTile(1, 2),

                          ]
                      ),
                      childrenDelegate: SliverChildBuilderDelegate(
                          childCount: _allDocIDs.length,
                              (context,index)=> eventItemBuilder(index, _allDocIDs[index]),
                      )),
                )
              ],
            ),
          ),
        );
      },

    );
  }
}

Widget eventItemBuilder(int index, String docId){

  CollectionReference profile = FirebaseFirestore.instance.collection('Events');
  return FutureBuilder<DocumentSnapshot>(
      future: profile.doc(docId).get(),
      builder: (context,snapshot){
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
          snapshot.data!.data() as Map<String, dynamic>;
          String? image = "${data['image_url']}";


          return GestureDetector(
            onTap:(){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                    return EventProfilePage(docId: docId);
                  }
                  ));
            },

            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(image),
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
      });
}

Widget profileItemBuilder(String userId){
  CollectionReference profile = FirebaseFirestore.instance.collection('UserData');

  return FutureBuilder<DocumentSnapshot>(
      future: profile.doc(userId).get(),
      builder: (context,snapshot){
        if(snapshot.connectionState==ConnectionState.done){
          Map<String, dynamic> data =
          snapshot.data!.data() as Map<String, dynamic>;
          String? image = "${data['profileImage']}";
          String? username = "${data['username']}";
          String? desc = "${data['description']}";

          Widget buildProfileImage() =>
              CircleAvatar(
                backgroundColor: Colors.grey.shade800,
                backgroundImage: NetworkImage(image),
                radius: 45,
              );

          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildProfileImage(),
                ],
              ),

              const SizedBox(height: 2),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    username,
                    style: GoogleFonts.arsenal(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100,vertical: 5),
                child: Container(
                  height: 50,
                  width: 300,
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:[
                      Text(desc,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.grey
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return const Text("loading...",
            style:TextStyle(
                color: Colors.white
            )
        );
      });
}