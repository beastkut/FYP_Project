import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../maps_page/view_event.dart';


class HomeAllEvents extends StatefulWidget {
  const HomeAllEvents({Key? key}) : super(key: key);

  @override
  State<HomeAllEvents> createState() => _Test1State();
}

class _Test1State extends State<HomeAllEvents>{

  final List<String> _activeDocIDs = [];

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
                _activeDocIDs.add(document.reference.id);
            }));
    print(_activeDocIDs.length);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _myFuture = getDocId();
  }



  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: _myFuture,
        builder: (context,snapshot){
          return Expanded(
            child: Container(
              width: 400,
              child: ListView.builder(
                  itemCount: _activeDocIDs.length,
                  itemBuilder:(context,position){
                    return _buildPageItem(position,_activeDocIDs[position]);
                  }),
            ),
          );
        }
    );
  }

  Widget _buildPageItem(int index, String docId){
    DateTime _getPSTTime(DateTime now) {
      tz.initializeTimeZones();
      final DateTime dateTime = now;
      final pacificTimeZone = tz.getLocation('Asia/Kuala_Lumpur');
      return tz.TZDateTime.from(dateTime, pacificTimeZone);
    }

    CollectionReference profile = FirebaseFirestore.instance.collection('Events');

    return FutureBuilder<DocumentSnapshot>(
      future: profile.doc(docId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
          snapshot.data!.data() as Map<String, dynamic>;
          String? image = "${data['image_url']}";
          String? title = "${data['title']}";
          String? category = "${data['category']}";
          DateTime? startDate =data["date_start"].toDate();
          String _dateTime = (DateFormat('EEE, d MMM , ''yyyy, h:mm a' ).format(_getPSTTime(startDate!)));

          return GestureDetector(
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                    return ViewEvent(docId: docId);
                  }
                  ));
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 6.0,bottom: 6),
              child: Container(
                height: 350,
                width: 400,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white),
                    image: DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover
                    )
                ),

                child: Padding(
                  padding: const EdgeInsets.only(top: 250.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 75,
                        width: 300,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30)
                        ),

                        child: Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10,top: 7),
                                child: Text( _dateTime,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.blue[600],
                                      fontSize: 13
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(left: 10,top: 3),
                                child: Text( title,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.only(left: 10,top: 1),
                                child: Text( category,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 13
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
