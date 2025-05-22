import 'package:css/css.dart';
import 'package:flutter/material.dart';

class StartGameModal extends StatefulWidget {
  const StartGameModal({
    Key? key,
    required this.setPlayers,
  }):super(key: key);

  final void Function(List<String>) setPlayers;

  @override
  State<StartGameModal> createState() => _StartGameModalState();
}

class _StartGameModalState extends State<StartGameModal> {
  List<TextEditingController> players = [TextEditingController(text: 'name 1'),TextEditingController(text: 'name 2')];
  @override
  void initState(){
    super.initState();
  }

  List<Widget> playerList(){
    double wid = CSS.responsive()-20;
    List<Widget> widgets = [];
    for(int i = 0; i < players.length; i++){
      widgets.add(
        SizedBox(
          width: wid,
          child: TextField(
            keyboardType: TextInputType.number,
            autofocus: false,
            controller: players[i],
            style: Theme.of(context).primaryTextTheme.bodyMedium,
            decoration: InputDecoration(
              //labelText: label,
              filled: true,
              fillColor: Theme.of(context).canvasColor,
              contentPadding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
              border: const OutlineInputBorder(
                borderSide: BorderSide(
                  width: 4, 
                  style: BorderStyle.solid,
                ),
              ),
            ),
          )
        )
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    double hei = MediaQuery.of(context).size.height;
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: Container(
            width: CSS.responsive(),
            height: hei-48,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.all(Radius.circular(7)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  height: hei-98,
                  child: ListView(
                    children: playerList(),
                  ),
                ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    InkWell(
                      onTap: (){
                        setState(() {
                          players.add(TextEditingController(text: 'name ${players.length+1}'));
                        });
                      },
                      child: Container(
                        width: 110,
                        height: 30,
                        margin: EdgeInsets.only(bottom: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            width: 2,
                            color: Theme.of(context).dividerColor
                          )
                        ),
                        child: Text(
                          'Add Player'
                        ),
                      )
                    ),
                    InkWell(
                      onTap: (){
                        setState(() {
                          List<String> totalPlayers = [];
                          for(int i = 0; i < players.length;i++){
                            totalPlayers.add(players[i].text);
                          }
                          widget.setPlayers(totalPlayers);
                        });
                      },
                      child: Container(
                        width: 110,
                        height: 30,
                        margin: EdgeInsets.only(bottom: 10),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).canvasColor,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            width: 2,
                            color: Theme.of(context).dividerColor
                          )
                        ),
                        child: Text(
                          'Play'
                        ),
                      ),
                    )
                  ],
                )
            ]),
          )
        ),
      );
    });
  }
}