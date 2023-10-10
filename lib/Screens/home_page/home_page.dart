import 'package:final_year_project/Screens/home_page/home_all_events.dart';
import 'package:final_year_project/Screens/home_page/events_by_catergory.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_active_events.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int index = 0;
  Color _containerColor = Colors.black;
  Color _textColor = Colors.white;
  Color _containerColor2 = Colors.white;
  Color _textColor2 = Colors.black;
  final screens = [
    const HomeAllEvents(),
    const HomeActiveEvents()
  ];

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();

    return Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          backgroundColor: Colors.transparent,

          leading:Builder(
            builder: (context)=> IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.filter_list_sharp)
            ),
          ),

          title: Text(
            'SideQuest',
            style: GoogleFonts.dancingScript(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.white,
            ),
          ),
        ),

        drawer: Drawer(
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                    child: ListView(
                      children: [
                        DrawerHeader(
                            child:Center(
                              child: Text(
                                'Category',
                                style: GoogleFonts.arsenal(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 35,
                                  color: Colors.white,
                                ),
                              ),
                            ) ),
                         ListTile(
                          onTap: (){
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return const EventByCategory(catergory: 'E-sport');
                                }
                                ));                          },
                          title: const Text(
                            'E-sport',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),

                         ListTile(
                           onTap: (){
                             Navigator.push(context,
                                 MaterialPageRoute(builder: (context) {
                                   return const EventByCategory(catergory: 'Sport');
                                 }
                                 ));                          },
                          title: const Text(
                            'Sport',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),

                         ListTile(
                          onTap: (){
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return const EventByCategory(catergory: 'Education');
                                }
                                ));                          },
                          title: const Text(
                            'Education',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),

                         ListTile(
                           onTap: (){
                             Navigator.push(context,
                                 MaterialPageRoute(builder: (context) {
                                   return const EventByCategory(catergory: 'Festival & Concert');
                                 }
                                 ));                          },
                          title: const Text(
                            'Festival & Concert',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),

                         ListTile(
                           onTap: (){
                             Navigator.push(context,
                                 MaterialPageRoute(builder: (context) {
                                   return const EventByCategory(catergory: 'Other');
                                 }
                                 ));                          },
                          title: const Text(
                            'Others',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ],
                    )
                ),

                Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: Column(
                    children:  <Widget>[
                      const Divider(color: Colors.white,thickness: 1,),
                      ListTile(
                          leading: const Icon(Icons.logout_rounded),
                          title: const Text('Logout'),
                          onTap: (){
                            FirebaseAuth.instance.signOut();
                            Navigator.pop(context);
                          }

                      ),
                      const ListTile(
                          leading: Icon(Icons.help),
                          title: Text('Help and Feedback'))
                    ],
                  ),
                )
              ],
            ),
          ),
        ),

        body: SafeArea(
          child: Column(
            children:  [
              Container(
                height: 50,
                width: double.infinity,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50.0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        GestureDetector(
                            onTap: (){
                              setState(() {
                                  index = 0;

                                  if(index == 0){
                                    _containerColor = Colors.black;
                                    _textColor = Colors.white;
                                    _containerColor2 = Colors.white;
                                    _textColor2 = Colors.black;
                                  }
                              });
                            },
                            child: Container(
                              height: 50,
                              width: 100,
                              color: _containerColor,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15),
                                  child: Text("All Events",
                                    style: TextStyle(
                                        color: _textColor,
                                        fontSize: 15
                                    ),
                                  ),
                                )
                            )
                        ),

                        GestureDetector(
                            onTap: (){
                              setState(() {
                                index = 1;

                                if(index == 1){
                                  _containerColor2 = Colors.black;
                                  _textColor2 = Colors.white;
                                  _containerColor = Colors.white;
                                  _textColor = Colors.black;
                                }

                              });
                            },
                            child: Container(
                                height: 50,
                                width: 100,
                                color: _containerColor2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15),
                                  child: Text(
                                    "Active ",
                                    maxLines: 2,
                                    style: TextStyle(
                                        color: _textColor2,
                                        fontSize: 15
                                    ),
                                  ),
                                )
                            )
                        ),
                        const SizedBox(height: 10),

                      ],
                    ),
                  ),
                ),
              ),

              screens[index],
            ],
          ),
        ),


      );
  }

}

class CustomSearchDelegate extends SearchDelegate {

  List<String> searchTerms = [
    'Apple',
    'Banana',
    'mango'
  ];

  @override
  List<Widget>buildActions(BuildContext context){
    return [
      IconButton(
          onPressed: (){
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return
      IconButton(
            onPressed:(){
              close(context, null);
            },

          icon: const Icon(Icons.arrow_back),
      );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];

    for( var fruit in searchTerms){
      if(fruit.toLowerCase().contains(query.toLowerCase())){
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index){
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
        );
      }
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];

    for( var fruit in searchTerms){
      if(fruit.toLowerCase().contains(query.toLowerCase())){
        matchQuery.add(fruit);
      }
    }
    return ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index){
          var result = matchQuery[index];
          return ListTile(
            title: Text(result),
          );
        }
    );
  }
}