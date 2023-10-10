import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';

class SavedPost extends StatefulWidget {
  const SavedPost({Key? key}) : super(key: key);

  @override
  State<SavedPost> createState() => _SavedPostState();
}

class _SavedPostState extends State<SavedPost> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: ListView.builder(
            itemCount: 1,
            itemBuilder: (context,index){
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Container(
                        height: 450,
                        width: double.infinity,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  height: 100,
                                  width: 375,
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                                        child: Row(
                                          children: [
                                            SizedBox(height: 5),
                                            buildProfileImage(),
                                            const SizedBox(width: 13),
                                            const Text(
                                              'Beastkut',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),

                                      SizedBox(height: 5),

                                      Row(
                                        children: const [
                                          Text(
                                            'NIGHT PARTY',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          )
                                        ],
                                      )


                                    ],

                                  ),
                                )
                              ],

                            ),

                            Row(
                              children: [
                                Container(
                                  height: 300,
                                  width: 375,
                                  decoration: const BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          'https://marketplace.canva.com/EAFBiag7Bos/1/0/1131w/canva-black-and-pink-glow-party-night-poster-oeRmI0EKb_I.jpg'
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                )
                              ],

                            ),

                            Row(
                              children: [
                                Container(

                                  height: 50,
                                  width: 375,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children:[

                                      Row(
                                        children: const [
                                          LikeButton(
                                            isLiked: true,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'Interested',
                                            style: TextStyle(
                                                color: Colors.grey
                                            ),
                                          )
                                        ],
                                      ),

                                      Row(
                                        children: const [
                                          Icon(
                                            Icons.chat_bubble_outline,
                                            color:Colors.grey,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            'Comments',
                                            style: TextStyle(
                                                color: Colors.grey
                                            ),
                                          )
                                        ],
                                      ),

                                      Row(
                                        children: const [
                                          Icon(
                                            Icons.share_outlined,
                                            color:Colors.grey,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            'Share',
                                            style: TextStyle(
                                                color: Colors.grey
                                            ),
                                          )
                                        ],
                                      ),

                                      Row(
                                        children: const [
                                          Icon(
                                            Icons.more_outlined,
                                            color:Colors.grey,
                                          ),
                                          SizedBox(width: 2),
                                          Text(
                                            'More',
                                            style: TextStyle(
                                                color: Colors.grey
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],

                            )
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
              );
            }
        )

    );
  }
}

Widget buildProfileImage() => CircleAvatar(
  backgroundColor: Colors.grey.shade800,
  backgroundImage: NetworkImage('http://pm1.narvii.com/5998/250fd9a4cec464018967b38900963ce4c3581deb_00.jpg'),
  radius: 27,
);