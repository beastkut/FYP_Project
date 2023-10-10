import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_year_project/Screens/maps_page/view_event.dart';
import 'package:final_year_project/Screens/profile_page/view_event_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';

class SavedEventPage extends StatefulWidget {
  const SavedEventPage({Key? key}) : super(key: key);

  @override
  State<SavedEventPage> createState() => _SavedEventPageState();
}

class _SavedEventPageState extends State<SavedEventPage> {

  final List<String> _savedPost = [];
  late final Future _myFuture;
  Future getDocId() async{
    await FirebaseFirestore.instance
        .collection("Favorite")
        .doc(userId)
        .collection("EventID")
        .get()
        .then(
            (snapshot) => snapshot.docs.forEach(
                (document) async {
                  print(document.reference.id);
                _savedPost.add(document.reference.id);

            }));
    print(_savedPost.length);
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
    return FutureBuilder(
      future: _myFuture,
      builder: (context,snapshot){
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Saved Events',
              style: GoogleFonts.arsenal(
                fontWeight: FontWeight.bold,
                fontSize: 25,
                color: Colors.white,
              ),
            ),
          ),
          body: SafeArea(
            child: Container(
              height: 750,
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
                    childCount: _savedPost.length,
                        (context,index)=> eventItemBuilder(index, _savedPost[index]),
                  )),
            ),
          ),
        );
      },
    );
  }

  Widget eventItemBuilder(int index, String docId){
    CollectionReference events = FirebaseFirestore.instance.collection('Events');
    CollectionReference fav = FirebaseFirestore.instance.collection('Favorite');
    return FutureBuilder<DocumentSnapshot>(
        future: events.doc(docId).get(),
        builder: (context,snapshot){
          if (snapshot.connectionState == ConnectionState.done ) {
            if(snapshot.data!.data() != null){
              Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
              String? image = "${data['image_url']}";

              return GestureDetector(
                onTap:(){
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                        return ViewEvent(docId: docId);
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

            else if ( snapshot.data!.data() == null){
              fav.doc(userId).collection("EventID").doc(docId).delete();

            }
          }
            return Container(
              child: Center(
                child: const Text("",
                    style: TextStyle(
                        color: Colors.white
                    )
                ),
              ),
            );

        });
  }
}
