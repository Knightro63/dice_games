import '../game.dart';
import '../../../src/enums.dart';

class Farkle extends Game{
  Farkle(
    super.threeJs,
    super.visuals,
    super.helpers,
    super.dices,
    super.updateScore
  ){
    maxDice = 6;
  }

  List<int> getAllowedDie(){
    List<int> al = [];
    for(int i = 0; i < helpers.length;i++){
      if(visuals[i].visible){
        al.add(i);
      }
    }
    return al;
  }

  @override
  AIScoring? loop(){
    if(!allowSelect) return null;
    final die = getAllowedDie();
    print(die);
    final gs = rules(getDiceValues(die));

    if(gs.points != 0 && (gs.playable == 6 || die.length - gs.playable == 0)){
      return AIScoring(PlayerMove.roll,gs.points,gs.playable);
    }
    else if(gs.points == 0 || die.length <= 2){
      return AIScoring(PlayerMove.score,gs.points,gs.playable);
    }
    else if(gs.points < 300){
      if(gs.aquired[0] > 0){
        return AIScoring(PlayerMove.roll,100,1);
      }
      else if(gs.aquired[4] > 0){
        return AIScoring(PlayerMove.roll,50,1);
      }
      return AIScoring(PlayerMove.roll,gs.points,gs.playable);
    }
    else if(gs.points == 300){
      if(gs.playable == 4 || gs.playable == 5){
        if(gs.aquired[0] > 0){
          return AIScoring(PlayerMove.roll,100,1);
        }
        else if(gs.aquired[4] > 0){
          return AIScoring(PlayerMove.roll,50,1);
        }
        else{
          return AIScoring(PlayerMove.roll,300,gs.playable);
        }
      }
    }
    else if(gs.points > 300){
      if(gs.playable == 4 || gs.playable == 5){
        return AIScoring(PlayerMove.score,gs.points,gs.playable);
      }
      else if(gs.aquired[0] >= 3){
        return AIScoring(PlayerMove.roll,300,3);
      }
      else if(gs.aquired[4] >= 3){
        return AIScoring(PlayerMove.score,gs.points,gs.playable);
      }
    }

    return AIScoring(PlayerMove.roll,gs.points,gs.playable);
  }

  @override
  GameScoring rules(List<int> dieUp){
    int playable = 0;
    int add = 0;
    List<int> kind = [0,0,0,0,0,0];
    for(int i = 0; i < dieUp.length; i++){
      kind[dieUp[i]-1]++;
    }

    if(kind[0] == 1 && kind[0] == 1 && kind[2] == 1 && kind[3] == 1 && kind[4] == 1 && kind[5] == 1){
      playable = 6;
      return GameScoring(1500,playable,kind);
    }

    int oh = 0;
    int fy = 0;
    int k2 = 0;
    int k4 = 0;
    int k3 = 0;
    int k5 = 0;

    int? loc;

    bool isFromOh = false;
    bool isFromFy = false;
    
    for(int i = 0; i < kind.length; i++){
      if(kind[i] == 2){
        k2++;
      }
      else if(kind[i] == 3){
        k3++;
        loc = i;

        if(i == 0){
          isFromOh = true;
        }
        else if(i == 4){
          isFromFy = true;
        }
      }
      else if(kind[i] == 4){
        k4++;
        if(i == 0){
          isFromOh = true;
        }
        else if(i == 4){
          isFromFy = true;
        }
      }
      else if(kind[i] == 5){
        k5++;
        if(i == 0){
          isFromOh = true;
        }
        else if(i == 4){
          isFromFy = true;
        }
      }
      else if(kind[i] == 6){
        playable = 6;
        return GameScoring(3000,playable,kind);
      }

      if(i == 0 && kind[i] != 0){
        oh = kind[i];
      }
      else if(i == 4 && kind[i] != 0){
        fy = kind[i];
      }
    }

    if(k3 == 2){
      playable = 6;
      return GameScoring(2500,playable,kind);
    }
    else if(k2 == 3){
      playable = 6;
      return GameScoring(1500,playable,kind);
    }
    else if(k4 == 1 && k2 == 1){
      playable = 6;
      return GameScoring(1500,playable,kind);
    }
    else if(k4 == 1){
      playable = 4;
      int a = 1000;
      if(oh != 0 && !isFromOh){
        playable += oh;
        a += oh*100;
      }
      if(fy != 0 && !isFromFy){
        playable += fy;
        a += fy*50;
      }
      return GameScoring(a,playable,kind);
    }
    else if(k5 == 1){
      playable = 5;
      int a = 2000;
      if(oh == 1 && !isFromOh){
        playable = 6;
        return GameScoring(a+100,playable,kind);
      }
      else if(fy == 1 && !isFromFy){
        playable = 6;
        return GameScoring(a+50,playable,kind);
      }
      return GameScoring(a,playable,kind);
    }
    else if(k3 != 0 && oh != 3){
      playable = 3;
      add += (loc!+1)*100;
    }

    if(oh != 0){
      playable += oh;
      add += oh*100;
    }
    if(k3 == 1 && isFromFy){
      //add += 0;
    }
    else if(fy != 0){
      playable += fy;
      add += fy*50;
    }

    return GameScoring(add,playable,kind);
  }

  @override
  GameScoring calculatePoints(){
    List<int> dieUp = getDiceValues(selected);
    return rules(dieUp);
  }
}