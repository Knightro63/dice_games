import 'dart:io';

import 'games/farkle/multiplayer.dart';
import './src/dice_scene.dart';
import './src/enums.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:css/css.dart';
import 'package:flutter/services.dart';

void main() async{
  if(!kIsWeb && (Platform.isIOS || Platform.isAndroid)){
    // Force Portrait Mode
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft, // Normal Portrait
      DeviceOrientation.landscapeRight, // Upside-Down Portrait
    ]);
  }

   runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: CSS.darkTheme,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  PlayerType type = PlayerType.none;
  final Map<Callbacks,void Function([dynamic])> callbacks = {};

  Widget selectGameType(){
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        runAlignment: WrapAlignment.center,
        runSpacing: 10,
        spacing: 10,
        children: [
          InkWell(
            onTap: (){
              setState(() {
                type = PlayerType.single;
              });
            },
            child: Container(
              margin: EdgeInsets.all(5),
              width: CSS.responsive(),
              height: CSS.responsiveHeight()/2,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 2,
                  color:Theme.of(context).dividerColor
                )
              ),
              child: Text(
                'Single Player',
                style: Theme.of(context).primaryTextTheme.bodyLarge,
              ),
            ),
          ),
          InkWell(
            onTap: (){
              setState(() {
                type = PlayerType.multi;
                callbacks[Callbacks.allowDice]?.call(true);
              });
            },
            child: Container(
              margin: EdgeInsets.all(5),
              width: CSS.responsive(),
              height: CSS.responsiveHeight()/2,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  width: 2,
                  color:Theme.of(context).dividerColor
                )
              ),
              child: Text(
                'Multi-Player',
                style: Theme.of(context).primaryTextTheme.bodyLarge,
              ),
            ),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    widthInifity = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            type == PlayerType.none?selectGameType():MultiPlayerGame(
              callback: () {
                setState(() {
                  type = PlayerType.none;
                  callbacks[Callbacks.allowDice]?.call(false);
                });
              },
              diceScore: callbacks,
              nameChange: callbacks[Callbacks.changeName],
              playerType: PlayerType.multi == type?PlayerType.multi:PlayerType.single,
            ),

            DiceScene(
              callback: callbacks
            )
          ]
        )
      )
    );
  }
}