import 'package:flutter/material.dart';


class NumbersWidget extends StatelessWidget {
  final int activeEvent;
  final int allEvent;
  const NumbersWidget({super.key,required this.activeEvent,required this.allEvent});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children:<Widget>[
      buildButton(text: 'Active Event', value:activeEvent),
      buildDivider(),
      SizedBox(width: 15,),

      buildButton(text: 'Events', value:allEvent),



    ],
  );

  Widget buildDivider()=> const SizedBox(
    height: 40,
    width: 10,
    child: VerticalDivider(width:40, color: Colors.white,),
  );

  Widget buildButton({
    required String text,
    required int value,
  }) =>
      MaterialButton(
          onPressed: (){},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                text,
                style: const TextStyle(fontSize: 15,color: Colors.white),
              ),

              const SizedBox(height: 5),
              Text(
                '$value',
                style:const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
            ],
          ),

      );
}
