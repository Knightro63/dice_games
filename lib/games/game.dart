import 'dart:math' as math;
import '../src/enums.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:flutter/material.dart';
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:vector_math/vector_math.dart';

class GameScoring{
  GameScoring(this.points,this.playable,this.aquired);

  int points;
  int playable;
  List<int> aquired;
}

class AIScoring{
  AIScoring(this.move,this.points,this.playable);

  int points;
  int playable;
  PlayerMove move;

  @override
  String toString() {
    // TODO: implement toString
    return {
      'points': points,
      'playable': playable,
      'move': move.name
    }.toString();
  }
}

class Game {
  bool allowSelect = false;

  int maxDice = 6;
  final three.ThreeJS threeJs;
  final three.Raycaster raycaster = three.Raycaster();
  final three.Vector2 mousePosition = three.Vector2.zero();
  final List<three.Object3D> helpers;
  List<int> selected = [];
  final List<oimo.RigidBody> dices;
  List<three.Object3D> _hovered = [];
  final List<three.Object3D> visuals;

  void Function() updateScore;

  int get points => calculatePoints().points;

  Game(
    this.threeJs,
    this.visuals,
    this.helpers,
    this.dices,
    this.updateScore
  ){
    threeJs.domElement.addEventListener(three.PeripheralType.pointerHover, onPointerHover);
    threeJs.domElement.addEventListener(three.PeripheralType.pointerdown, onPointerDown);
  }

  GameScoring rules(List<int> dieUp){
    throw("not implimented yet!");
  }

  GameScoring calculatePoints(){
    throw("not implimented yet!");
  }

  AIScoring? loop(){
    throw("not implimented yet!");
  }

  int getDieValue(int i){
    int up = 0;

    final Vector3 localUp = Vector3(0,1,0);
    var limit = math.sin(math.pi/4);

    Quaternion q = Quaternion.copy(dices[i].orientation)..inverse();
    q.vmult(localUp, localUp);

    // Check which side is up
    if(localUp.x > limit){
      up = 4;
    } else if(localUp.x < -limit){
      up = 3;
    } else if(localUp.y > limit){
      up = 5;
    } else if(localUp.y < -limit){
      up = 2;
    } else if(localUp.z > limit){
      up = 6;
    } else if(localUp.z < -limit){
      up = 1;
    } else {
      up = 0;
    }

    return up;
  }
  List<int> getDiceValues(List<int> die){
    List<int> dieUp = [];

    for(final i in die){
      int up = getDieValue(i);
      dieUp.add(up);
    }

    return dieUp;
  }

  void clearHighlight(){
    for(final o in _hovered){
      o.material?.visible = false;
    }
    _hovered = [];
  }
  void checkHighLight(List<three.Intersection> inter){
    if(inter.isEmpty) return;
    final o = inter[0].object;
    if(o != null){
      o.material?.visible = true;
      _hovered.add(o);
    }
  }
  void checkSelected(){
    if(selected.isEmpty || !allowSelect) return;
    for(final i in selected){
      helpers[i].material?.visible = true;
    }
  }
  void updatePointer(event) {
    final box = threeJs.globalKey.currentContext?.findRenderObject() as RenderBox;
    final size = box.size;
    mousePosition.x = ((event.clientX) / size.width * 2 - 1);
    mousePosition.y = (-(event.clientY) / size.height * 2 + 1);
  }

  List<three.Intersection> _checkIntersections(three.WebPointerEvent event){
    updatePointer(event);
    raycaster.setFromCamera(mousePosition, threeJs.camera);
    return raycaster.intersectObjects(helpers, false);
  }
  void onPointerDown(three.WebPointerEvent event) {
    final intersections = _checkIntersections(event);
    if(intersections.isNotEmpty){
      int i = helpers.indexOf(intersections[0].object!);
      if(selected.contains(i)){
        selected.remove(i);
      }
      else{
        selected.add(i);
      }
      updateScore.call();
    }
  }
  void onPointerHover(three.WebPointerEvent event) {
    final intersections = _checkIntersections(event);
    clearHighlight();
    checkHighLight(intersections);
    checkSelected();
  }
}