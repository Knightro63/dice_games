import '../../src/end_game_modal.dart';
import '../../src/enums.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class YahtzeeGame extends StatefulWidget {
  const YahtzeeGame({
    super.key,
    required this.diceScore,
  });

  final Map<Callbacks,void Function([dynamic])> diceScore;

  @override
  State<YahtzeeGame> createState() => _MultiPlayerGameState();
}

class _MultiPlayerGameState extends State<YahtzeeGame> {
  final SharedPreferencesAsync asyncPrefs = SharedPreferencesAsync();
  final List<int?> points = List.filled(14, null);
  int get totalPoints => getTotal();

  List<int> selected = [];
  List<int> highScores = [];

  @override
  void initState(){
    super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_){
        widget.diceScore[Callbacks.playerType]?.call(PlayerType.single);
        widget.diceScore[Callbacks.allowDice]?.call(true);
        widget.diceScore[Callbacks.gameType]?.call(GameType.yahtzee);

        getHighScores().then((v){
          highScores = v;
          print(highScores);
        });
    });
    
    if(!widget.diceScore.containsKey(Callbacks.computerSetSelected)){
      widget.diceScore[Callbacks.computerSetSelected] = computerSetSelected;
    }
    else{
      widget.diceScore[Callbacks.computerSetSelected] = computerSetSelected;
    }
  }

  @override
  void dispose(){
    super.dispose();
  }

  Future<List<int>> getHighScores() async{
    final strings = await asyncPrefs.getStringList('yahtzee_scores');

    if(strings == null){
      return [];
    }
    else{
      List<int> nums = [];
      for(int i = 0; i < strings.length;i++){
        nums.add(int.parse(strings[i]));
      }

      return nums;
    }
  }

  Future<void> setScore() async{
    List<String> nums = [];
    bool isLarger = false;
    final tp = totalPoints;
    int smallest = highScores.isEmpty?0:highScores[0];

    for(int i = 0; i < highScores.length;i++){
      nums.add(highScores[i].toString());

      if(tp > highScores[i]){
        isLarger = true;
      }

      if(smallest < highScores[i]){
        smallest = highScores[i];
      }
    }

    if(nums.length < 10 || isLarger){
      nums.add(tp.toString());
      highScores.add(tp);
    }
    else if(isLarger){
      nums.add(tp.toString());
      highScores.add(tp);
      nums.remove(smallest.toString());
      highScores.remove(smallest);
    }

    await asyncPrefs.setStringList('yahtzee_scores', nums);
  }

  int getTotal(){
    if (points.isEmpty) return 0;
    int total = 0;
    for (int i = 1; i < points.length; ++i) {
      total += points[i]??0;
    }
    return total;
  }

  void computerSetSelected([value]){
    setState(() {
      if(value != null){
        selected += (value as List<int>).sublist(0);
      }
      else{
        selected = [];
      }
    });
  }

  void resetGame(){
    selected = [];
    for(int i = 0; i < points.length;i++){
      points[i] = 0;
    }
  }

  void endGame(){
    setScore().then((_){
      showDialog(
        context: context, 
        builder: (BuildContext context){
          return EndGameModal(
            points: highScores,
            players: [],
            reset: (){
              resetGame();
              Navigator.of(context).pop();
            },
            callback: (){
              widget.diceScore[Callbacks.mainMenue]?.call();
              Navigator.of(context).pop();
            },
          );
        }
      );
    });
  }

  bool isOver(){
    for(int i = 0; i < points.length-1;i++){
      if(points[i] == null){
        return false;
      }
    }
    return true;
  }

  bool recalculate(int i){
    List<int> kind = [0,0,0,0,0,0];

    for(int i = 0; i < selected.length; i++){
      kind[selected[i]-1]++;
    }

    int k2 = 0;
    int k3 = 0;
    int k4 = 0;
    int k5 = 0;
    for(int i = 0; i < kind.length; i++){
      if(kind[i] == 2){
        k2++;
      }
      else if(kind[i] == 3){
        k3 = (i+1)*3;
      }
      else if(kind[i] == 4){
        k4 = (i+1)*4;
      }
      else if(kind[i] == 5){
        k5 = (i+1)*5;
      }
    }

    if(k5 != 0 && points[i] != 0){
      points[13] = 100+(points[13] ?? 0);
    }

    switch (i) {
      case 0:
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
        if(points[i] == null){
          for(int j = 0; j < selected.length;j++){
            if(selected[j] == i+1){
              points[i] = (points[i] ?? 0)+i+1;
            }
          }
          if(points[i] == null){
            points[i] = 0;
          }
          return true;
        }
        break;
      case 6:
        if(k3 != 0 && points[i] == null){
          points[i] = k3;
          return true;
        }
        else{
          points[i] = 0;
          return true;
        }
      case 7:
        if(k4 != 0 && points[i] == null){
          points[i] = k4;
          return true;
        }
        else{
          points[i] = 0;
          return true;
        }
      case 8:
        if(k2 != 0 && k3 != 0 && points[i] == null){
          points[i] = 25;
          return true;
        }
        else{
          points[i] = 0;
          return true;
        }
      case 9:
        if(points[i] == null){
          if(kind[0] == 1 && kind[1] == 1 && kind[2] == 1 && kind[3] == 1){
            points[i] = 4+3+2+1;
            return true;
          }
          else if(kind[1] == 1 && kind[2] == 1 && kind[3] == 1 && kind[4] == 1){
            points[i] = 2+3+4+5;
            return true;
          }
          else if(kind[2] == 1 && kind[3] == 1 && kind[4] == 1 && kind[5] == 1){
            points[i] = 3+4+5+6;
            return true;
          }
          else{
            points[i] = 0;
            return true;
          }
        }
        else{
          points[i] = 0;
          return true;
        }
      case 10:
        if(points[i] == null){
          if(kind[0] == 1 && kind[1] == 1 && kind[2] == 1 && kind[3] == 1 && kind[4] == 1){
            points[i] = 5+4+3+2+1;
            return true;
          }
          else if(kind[1] == 1 && kind[2] == 1 && kind[3] == 1 && kind[4] == 1 && kind[5] == 1){
            points[i] = 6+5+4+3+2;
            return true;
          }
          else{
            points[i] = 0;
            return true;
          }
        }
      case 11:
        if(k5 != 0 && points[i] == null){
          points[i] = 50;
          return true;
        }
        else{
          points[i] = 0;
          return true;
        }
      case 12:
        if(points[i] == null){
          for(int j = 0; j < selected.length;j++){
            points[i] = selected[j]+1+(points[i]??0);
          }
          return true;
        }
        else{
          points[i] = 0;
          return true;
        }
      default:
    }

    return false;
  }

  Widget section(String name, int i){
    final double width = 250-125;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          width: 120,
          height: 30,
          padding: EdgeInsets.only(left: 5),
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 2
            )
          ),
          child: Text(
            name,
            style: Theme.of(context).primaryTextTheme.bodyMedium,
          ),
        ),
        InkWell(
          onTap: points[i] == null && selected.length == 5?(){
            setState(() {
              bool didDis = recalculate(i);
              if(didDis){
                selected = [];
              }
              if(isOver()){
                endGame();
              }
            });
          }:null,
          child: Container(
            width: width,
            height: 30,
            padding: EdgeInsets.only(right: 5),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 2
              )
            ),
            child: points[i] != null?Text(
              points[i].toString(),
              textAlign: TextAlign.right,
              style: Theme.of(context).primaryTextTheme.bodyMedium,
            ):Container(),
          )
        )
      ],
    );
  }

  Widget card(String title, Widget preInfo){
    final double width = 250;
    final double height = 250;
    return Container(
      margin: const EdgeInsets.only(top: 20),
      width: width,
      height:  height + 8 + 14,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(
          color: Theme.of(context).shadowColor,
          blurRadius: 5,
          offset: const Offset(0,2),
        ),]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Padding(padding: const EdgeInsets.only(top:10, left: 10),
            child: Text(
              title.toUpperCase(),
              style: Theme.of(context).primaryTextTheme.labelLarge
            ),
          ),
          Container(
            width: width,
            margin: const EdgeInsets.only(bottom:10),
            color: Theme.of(context).splashColor,
            height: height-24,
            child:preInfo
          )
        ]),
      );
  }

  Widget dot(){
    return Container(
      width: 7,
      height: 7,
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(7/2)
      ),
    );
  }

  Widget dots(int n){
    List<Widget> widgets = [];
    if(n == 1){
      widgets.add(dot());
    }
    else if(n == 2 || n == 3){
      widgets.addAll([
        Row(mainAxisAlignment: MainAxisAlignment.start ,children:[dot()]),
        n==2?SizedBox(width: 7,height: 7):dot(),
        Row(mainAxisAlignment: MainAxisAlignment.end ,children:[dot()]),
      ]);
    }
    else if(n == 4 || n == 5 || n == 6){
      widgets.addAll([
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween ,children:[dot(), dot()]),
        n==4?SizedBox(width: 7,height: 7):n==5?dot():Row(mainAxisAlignment: MainAxisAlignment.spaceBetween ,children:[dot(), dot()]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween ,children:[dot(), dot()]),
      ]);
    }
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,
    );
  }

  Widget dice(){
    List<Widget> dices = [];
    for(int i = 0; i < selected.length;i++){
      dices.add(
        Container(
          width: 35,
          height: 35,
          margin: EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5)
          ),
          child: dots(selected[i])
        )
      );
    }

    return Row(
      children: dices
    );
  }

  Widget createCard(){
    return Wrap(
      alignment: WrapAlignment.spaceAround,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 50,
                alignment: Alignment.center,
                padding: EdgeInsets.only(left: 5),
                margin: EdgeInsets.fromLTRB(20,20,20,0),
                child: Text(
                  'Score: ${totalPoints.toString()}',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).primaryTextTheme.headlineLarge,
                )
              ),
              Container(
                height: 50,
                width: 209,
                padding: EdgeInsets.only(left: 5),
                margin: EdgeInsets.fromLTRB(20,20,20,0),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 2
                  )
                ),
                child: dice()
              )
            ]
          )
        ),
        card('upper section',
          Column( //UpperSection
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              section('Aces',0),
              section('Twos',1),
              section('Threes',2),
              section('Fours',3),
              section('Fives',4),
              section('Sixes',5),
            ],
          )
        ),
        card('lower section',
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                section('3 of a Kind',6),
                section('4 of a Kind',7),
                section('Full House',8),
                section('SM Straight',9),
                section('LG Straight',10),
                section('YAHTZEE',11),
                section('Chance',12),
            ],
          )
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: createCard(),
        )
      )
    );
  }
}
