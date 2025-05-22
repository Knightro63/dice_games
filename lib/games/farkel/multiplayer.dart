import '../../src/end_game_modal.dart';
import '../../src/enums.dart';
import '../../src/start_game_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MultiPlayerGame extends StatefulWidget {
  const MultiPlayerGame({
    super.key,
    required this.callback,
    required this.diceScore,
    required this.nameChange,
    required this.playerType
  });

  final Function()? callback;
  final Map<Callbacks,void Function(dynamic)> diceScore;
  final Function(String)? nameChange;
  final PlayerType playerType;

  @override
  State<MultiPlayerGame> createState() => _MultiPlayerGameState();
}

class _MultiPlayerGameState extends State<MultiPlayerGame> {
  int? winner;
  List<String> totalPlayers = ['name1','name2'];
  List<int> points = [0,0];
  List<List<TextEditingController>> cells = [[TextEditingController()],[TextEditingController()]];
  FocusNode focus = FocusNode();

  int? currentPlayer;
  int? currentCell;

  @override
  void initState(){
    super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_){
      showDialog(
        context: context,
        builder: (BuildContext context){
          return StartGameModal(
            setPlayers: (list){
              widget.diceScore[Callbacks.totalPlayers]?.call(list);
              widget.diceScore[Callbacks.playerType]?.call(widget.playerType);
              totalPlayers = list;
              for(int i = 2; i < list.length;i++){
                points.add(0);
                cells.add([TextEditingController()]);
              }

              setState(() {});
              Navigator.of(context).pop();
            },
          );
        }
      );
    });
    
    if(!widget.diceScore.containsKey(Callbacks.computerSetScore)){
      widget.diceScore[Callbacks.computerSetScore] = computerSetScore;
    }
    else{
      widget.diceScore[Callbacks.computerSetScore] = computerSetScore;
    }
  }

  @override
  void dispose(){
    super.dispose();
    focus.dispose();

    for(int i = 0; i < totalPlayers.length; i++){
      for(int j = 0; j < cells[i].length;j++){
        cells[i][j].dispose();
      }
    }
  }

  void computerSetScore([value]){
    if(currentCell == null && currentPlayer == null) return;
    setState(() {
      if(value == 0 || value == null){
        cells[currentPlayer!][currentCell!].text = 'FARKEL';
      }
      else{
        cells[currentPlayer!][currentCell!].text = value.toString();
        recalculate(currentPlayer!,totalPlayers.length-1 == currentPlayer! && currentCell! == cells[currentPlayer!].length-1);
      }
    });
    if(totalPlayers.length-1 == currentPlayer && currentCell == cells[currentCell!].length-1){
      if(isOver()){
        endGame();
      }
      else if(cells[currentPlayer!][currentCell!].text != ''){
        createCell();
      }
    }
    currentCell = null;
    currentPlayer = null;
  }

  void resetGame(){
    List<String> shiftNames = [];
    int shift = winner!;
    for(int i = 0; i < totalPlayers.length; i++){
      shiftNames.add(totalPlayers[shift]);
      points[i] = 0;
      for(int j = 0; j < cells[i].length;j++){
        cells[i][j].dispose();
      }
      cells[i] = [TextEditingController()];

      if(shift+1 < totalPlayers.length){
        shift++;
      }
      else{
        shift = 0;
      }
    }

    totalPlayers = shiftNames;
    winner = null;

    setState(() {});
  }

  void endGame(){
    showDialog(
      context: context, 
      builder: (BuildContext context){
        return EndGameModal(
          points: points, 
          players: totalPlayers,
          reset: (){
            resetGame();
            Navigator.of(context).pop();
          },
          callback: (){
            widget.callback?.call();
            Navigator.of(context).pop();
          },
        );
      }
    );
  }

  void createCell(){
    for(int i = 0; i < cells.length; i++){
      cells[i].add(TextEditingController());
    }
    setState((){});
  }

  bool isOver(){
    for(int i = 0; i < points.length;i++){
      if(points[i] >= 10000){
        winner = i;
        return true;
      }
    }
    return false;
  }

  void recalculate(int i, bool last){
    int newPoint = 0;
    for(int j = 0; j < cells[i].length; j++){
      if(cells[i][j].text != '' && cells[i][j].text != 'FARKEL'){
        newPoint += int.parse(cells[i][j].text);
      }
    }

    points[i] = newPoint;
  }

  Widget createCells(){
    List<Widget> topRow = [];
    List<Widget> rows = [];

    for(int i = 0; i < totalPlayers.length;i++){
      List<Widget> columns = [];
      topRow.add(
        Container(
          padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
          width: MediaQuery.of(context).size.width/totalPlayers.length,
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 2
            )
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                totalPlayers[i].toUpperCase(),
                style: Theme.of(context).primaryTextTheme.bodyMedium,
              ),
              Text(
                '${points[i]}',
                style: Theme.of(context).primaryTextTheme.bodyMedium,
              ),
            ]
          )
        )
      );
      for(int j = 0; j < cells[i].length; j++){
        columns.add(
          SizedBox(
            width: MediaQuery.of(context).size.width/totalPlayers.length,
            child: TextField(
              keyboardType: TextInputType.number,
              autofocus: false,
              onChanged: (String value){
                setState(() {
                  if(value == '0'){
                    cells[i][j].text = 'FARKEL';
                  }
                  else if(value != ''){
                    recalculate(i,totalPlayers.length-1 == i && j == cells[i].length-1);
                  }
                });
              },
              onTap: (){
                widget.nameChange?.call(totalPlayers[i]);
                currentPlayer = i;
                currentCell = j;
              },
              onTapOutside: (v){
                if(totalPlayers.length-1 == i && j == cells[i].length-1){
                  if(isOver()){
                    endGame();
                  }
                  else if(cells[i][j].text != ''){
                    createCell();
                  }
                }
              },
              controller: cells[i][j],
              style: Theme.of(context).primaryTextTheme.bodyMedium,
              inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
              ],
              
              decoration: InputDecoration(
                //labelText: label,
                filled: true,
                fillColor: Theme.of(context).canvasColor,
                isDense: true,
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
      
      columns.add(SizedBox(height: 100,));
      
      rows.add(
        Column(
          children: columns,
        )
      );
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: topRow
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height-30,
          child: SingleChildScrollView(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: rows
            )
          )
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: SingleChildScrollView(
          child: createCells(),
        )
      )
    );
  }
}
