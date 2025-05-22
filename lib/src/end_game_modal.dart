import 'package:css/css.dart';
import 'package:flutter/material.dart';

class EndGameModal extends StatefulWidget {
  const EndGameModal({
    Key? key,
    this.callback,
    this.reset,
    required this.points,
    required this.players
  }):super(key: key);

  final Function()? callback;
  final void Function()? reset;
  final List<int> points;
  final List<String> players;

  @override
  State<EndGameModal> createState() => _EndGameModalState();
}

class _EndGameModalState extends State<EndGameModal> {
  String winner = '';
  List<int> order = []; 
  
  @override
  void initState(){
    super.initState();
    int val = widget.points[0];
    winner = widget.players[0];

    order = widget.points.sublist(0);

    for(int i = 1; i < widget.players.length; i++){
      if(widget.points[i] > val){
        winner = widget.players[i];
      }
    }

    order.sort((a, b){
      if(a > b){
        return -1;
      }
      else if(b > a){
        return 1;
      }

      return 0;
    });
  }

  int checkPosition(int val){
    for(int i = 0; i < order.length; i++){
      if(widget.points[i] == val){
        return i;
      }
    }

    return 0;
  }

  Widget leaderBoard(){
    List<Widget> leaders = [];

    for(int j = 0; j < widget.players.length; j++){
      int i = checkPosition(order[j]);
      leaders.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.players[i].toUpperCase(),
              style: Theme.of(context).primaryTextTheme.bodyMedium,
            ),
            Text(
              '${widget.points[i]}',
              style: Theme.of(context).primaryTextTheme.bodyMedium,
            ),
          ]
        )
      );
    }

    return Column(
      children: leaders,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(builder: (context, setState) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          width: CSS.responsive(),
          height: CSS.responsive(),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.all(Radius.circular(7)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "congratulations $winner you Won!".toUpperCase(),
                style: Theme.of(context).primaryTextTheme.headlineLarge,
              ),
              leaderBoard(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: widget.callback,
                    child: Container(
                      width: 110,
                      height: 30,
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
                        'Home'
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: widget.reset,
                    child: Container(
                      width: 110,
                      height: 30,
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
                        'New Game'
                      ),
                    ),
                  )
                ],
              )
          ]),
        ),
      );
    });
  }
}