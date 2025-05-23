import '../game.dart';

class Yahtzee extends Game{
  Yahtzee(
    super.threeJs,
    super.visuals,
    super.helpers,
    super.dices,
    super.updateScore
  ){
    maxDice = 5;
  }
}