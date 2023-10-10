import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_count_down/date_count_down.dart';
import 'package:flutter/material.dart';
import '../maps_page/view_event.dart';


class HomeActiveEvents extends StatefulWidget {
  const HomeActiveEvents({Key? key}) : super(key: key);

  @override
  State<HomeActiveEvents> createState() => _HomeState();
}

class _HomeState extends State<HomeActiveEvents> {
  PageController pageController = PageController(viewportFraction: 0.98);

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
                  if(date.isAfter(document["date_start"].toDate())
                    && date.isBefore(document["date_end"].toDate())
                  )
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
        return Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height:MediaQuery.of(context).size.height * 0.75,
                  child: ListView.builder(
                      controller: pageController,
                      itemCount: _activeDocIDs.length,
                      itemBuilder:(context,position){
                        return _buildPageItem(position,_activeDocIDs[position]);
                      }),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildPageItem(int index, String docId){

    CollectionReference profile = FirebaseFirestore.instance.collection('Events');

    return FutureBuilder<DocumentSnapshot>(
      future: profile.doc(docId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
          snapshot.data!.data() as Map<String, dynamic>;
          String? image = "${data['image_url']}";
          String? title = "${data['title']}";
          DateTime? endDate =data["date_end"].toDate();

          return GestureDetector(
            onTap: (){
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                    return ViewEvent(docId: docId);
                  }
                  ));
            },
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 5,top: 5,left: 5),
                  height: 200,
                  decoration:  BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(image),
                          fit: BoxFit.cover
                      )
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 5,left: 5,bottom: 7),
                  height: 50,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage("https://images.squarespace-cdn.com/content/v1/5a267f93e9bfdf7a6ed28b25/1650623655768-CKH0UVL9K4O8UROBK55X/34_%2BMidnight%2BBlue.jpg?format=2500w"),
                          fit: BoxFit.cover
                      )
                  ),

                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Row(
                              children: [
                                Text(title,
                                  maxLines: 3,
                                  style: const TextStyle(
                                    fontSize: 17
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 5,),

                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Row(
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
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),


                    ],
                  ),
                ),
              ],
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


