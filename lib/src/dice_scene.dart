import 'dart:async';
import 'dart:math' as math;
import 'package:dice_games/games/yahtzee/yahtzee.dart';

import '../games/game.dart';
import './enums.dart';
import '../games/farkle/farkle.dart';
import 'package:flutter/material.dart';
import 'package:three_js/three_js.dart' as three;
import 'package:oimo_physics/oimo_physics.dart' as oimo;
import 'package:vector_math/vector_math.dart' hide Colors;

extension Quant on Quaternion{
  three.Quaternion toQuaternion(){
    return three.Quaternion(x,y,z,w);
  }
}
extension Vec3 on Vector3{
  three.Vector3 toVector3(){
    return three.Vector3(x,y,z);
  }
}

class DiceScene extends StatefulWidget {
  const DiceScene({
    super.key,
    required this.callback,
  });

  final Map<Callbacks,void Function([dynamic])> callback;

  @override
  createState() => _State();
}

class _State extends State<DiceScene> {
  late final three.ThreeJS threeJs;
  late Game selectedGame;

  int currentScore = 0;
  List<String> totalPlayers = ['name1','name2'];
  int tempScore = 0;
  int prevSel = 0;

  bool visible = false;
  bool isNPC = false;
  
  String? player;
  bool didRollStart = false;
  GameType type = GameType.farkle;
  PlayerType playerType = PlayerType.multi;

  int numOfRolls = 0;

  @override
  void initState() {
    threeJs = three.ThreeJS(
      onSetupComplete: (){setState(() {});},
      setup: setup,
      settings: three.Settings(
        alpha: true,
        useOpenGL: true,
        clearAlpha: 0,
      )
    );
    threeJs.visible = false;
    super.initState();
  }
  @override
  void dispose() {
    threeJs.dispose();
    three.loading.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if(threeJs.visible && player != null)Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 260,
            height: 97,
            alignment: Alignment.center,
            margin: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                width: 2,
                color: Theme.of(context).dividerColor
              )
            ),
            child: Column(
              children: [
                Text(
                  player!,
                  style: Theme.of(context).primaryTextTheme.bodyMedium,
                ),
                Text(
                  tempScore.toString(),
                  style: Theme.of(context).primaryTextTheme.displayLarge,
                ),
              ],
            )
          ),
        ),
        threeJs.build(),
        if(threeJs.visible && !isNPC)Align(
          alignment: Alignment.bottomCenter,
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if(didRollStart) Container(
                margin: EdgeInsets.all(20),
                child: InkWell(
                  onTap: (){
                    if(GameType.farkle == type){
                      setState(() {
                        currentScore += selectedGame.points;
                        if(selectedGame.points == 0){
                          currentScore = 0;
                        }
                        widget.callback[Callbacks.computerSetScore]?.call(currentScore);
                        reset();
                      });
                    }
                    else{
                      setState(() {
                        List<int> left = [];
                        for(int i = 0; i < visuals.length;i++){
                          if(visuals[i].visible){
                            left.add(i);
                          }
                        }
                        widget.callback[Callbacks.computerSetSelected]?.call(selectedGame.getDiceValues(left));
                        reset();
                      });
                    }
                  },
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
                      'Score'
                    ),
                  ),
                )
              ),
              Container(
                margin: EdgeInsets.all(20),
                child:InkWell(
                  onTap: (){
                    if(GameType.farkle == type){
                      setState(() {
                        GameScoring gs = selectedGame.calculatePoints();
                        int points = gs.points;
                        currentScore += gs.points;
                        prevSel += gs.playable;

                        if(prevSel < 6 && points != 0){
                          reRoll(6-prevSel);
                        }
                        else if(prevSel == 6 && points != 0){
                          prevSel = 0;
                          reRoll();
                        }
                        else if(prevSel == 0 && points == 0 && !didRollStart){
                          reRoll();
                        }
                      });
                    }
                    else if(numOfRolls < 3){
                      widget.callback[Callbacks.computerSetSelected]?.call(selectedGame.getDiceValues(selectedGame.selected));
                      prevSel += selectedGame.selected.length;
                      if(prevSel < 5){
                        reRoll(5-prevSel);
                      }
                      else if(prevSel == 0 && !didRollStart){
                        widget.callback[Callbacks.computerSetSelected]?.call();
                        reRoll();
                      }
                    }
                  },
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
                      'Roll'
                    ),
                  ),
                ),
              )
            ],
          )
        ),
        if(visible && !isNPC) Align(
          alignment: Alignment.bottomRight,
          child: Container(
            margin: EdgeInsets.all(20),
            child: InkWell(
              onTap: () {
                setState(() {
                  if(!threeJs.visible){
                    widget.callback[Callbacks.unfocus]?.call();
                  }
                  threeJs.visible = !threeJs.visible;
                });
              },
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(45/2)
                ),
                child: Icon(
                  Icons.rocket
                ),
              ),
            ),
          )
        ),
        if(visible) Align(
          alignment: Alignment.bottomLeft,
          child: Container(
            margin: EdgeInsets.all(20),
            child: InkWell(
              onTap: () {
                setState(() {
                  widget.callback[Callbacks.mainMenue]?.call();
                });
              },
              child: Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(45/2)
                ),
                child: Icon(
                  Icons.exit_to_app_rounded
                ),
              ),
            ),
          )
        ),
      ],
    );
  }

  late final oimo.World world;
  List<oimo.RigidBody> dices = [];
  List<three.Object3D> visuals = [];
  List<three.Object3D> helpers = [];

  void npc(){
    visible = true;
    isNPC = true;
    final ai = selectedGame.loop();
    
    if(!didRollStart && ai == null){
      reRoll();
    }
    else if(ai != null){
      print(ai);
      if(ai.move == PlayerMove.roll){
        final points = ai.points;
        currentScore += points;
        prevSel += ai.playable;
        if(prevSel < 6 && points != 0){
          reRoll(6-prevSel);
        }
        else if(prevSel == 6 && points != 0){
          prevSel = 0;
          reRoll();
        }
        else if(prevSel == 0 && points == 0 && !didRollStart){
          reRoll();
        }

        updateScore();
      }
      else{
        currentScore += ai.points;
        if(ai.points == 0){
          currentScore = 0;
        }
        widget.callback[Callbacks.computerSetScore]?.call(currentScore);
        reset();
      }
    }

    setState(() {});
  }

  void reset(){
    numOfRolls = 0;
    player = null;
    isNPC = false;

    visuals.forEach((model){
      model.traverse((child) => {
        if (child is three.Mesh && child.name != 'highlight') {
          model.visible = false
        }
        else if(child is three.Mesh && child.name == 'highlight'){
          child.material?.visible = false
        }
      });
    });
    setState(() {
      currentScore = 0;
      tempScore = 0;
      prevSel = 0;
      threeJs.visible = false;
      didRollStart = false;
      selectedGame.selected.clear();
    });
  }

  void updateScore(){
    if(GameType.farkle == type){
      setState(() {
        tempScore = currentScore + selectedGame.points;
      });
    }
  }

  void reRoll([dynamic allow]){
    allow ??= selectedGame.maxDice;

    print(allow);

    didRollStart = true;
    selectedGame.selected.clear();

    int j = 0;
    visuals.forEach((model){
      model.traverse((child) => {
        if(child is three.Mesh && child.name != 'highlight' && j >= allow){
          model.visible = false
        }
        else if (child is three.Mesh && child.name != 'highlight') {
          model.visible = true
        }
        else if(child is three.Mesh && child.name == 'highlight'){
          child.material?.visible = false
        }
      });
      j++;
    });

    int i = 0;
    dices.forEach((body){
      body.type = oimo.RigidBodyType.dynamic;
      body.position.setFrom(getRandomPosition(i < allow?2:50));
      body.linearVelocity.setFrom(body.initLinearVelocity);
      body.angularVelocity.setFrom(body.initAngularVelocity);
      body.orientation.setFrom(body.initOrientation);
      i++;
    });
    threeJs.visible = true;
    numOfRolls++;
    setState(() {});
  }

  void oimoSetup(){
    world = oimo.World(oimo.WorldConfigure(
      timeStep: 1 / 60, 
      iterations: 8, 
      broadPhaseType: oimo.BroadPhaseType.sweep, 
      scale: 1, 
      enableRandomizer: true, 
      gravity: Vector3(0, -9.8 * 3, 0),
    ));
  }

  void setupGame(){
    if(GameType.farkle == type){
      selectedGame = Farkle(threeJs,visuals,helpers,dices,updateScore);
    }
    else if(GameType.yahtzee == type){
      selectedGame = Yahtzee(threeJs,visuals,helpers,dices,updateScore);
    }
  }

  Future<void> setup() async {
    oimoSetup();
    threeJs.scene = three.Scene();
    threeJs.camera = three.PerspectiveCamera(45, threeJs.width / threeJs.height, 0.1,1000);
    threeJs.camera.position.setValues(0,30,0);

    // Plane
    final planeGeometry = three.PlaneGeometry(17, 15);
    final planeMaterial = three.MeshStandardMaterial.fromMap({ 
      'visible': false
    });
    final plane = three.Mesh(planeGeometry, planeMaterial);
    threeJs.scene.add(plane);
    plane.rotation.y = -0.5 * math.pi;
    threeJs.camera.lookAt(plane.position);

    // Lighting
    final ambientLight = three.AmbientLight(0xfffffff, 10);
    threeJs.scene.add(ambientLight);

    //initPostProcessing();
    await addDices();
    threeJs.addAnimationEvent((dt){
      animate();
    });

    widget.callback[Callbacks.reRoll] = reRoll;
    widget.callback[Callbacks.allowDice] = 
    ([vis]){
      setState(() {
        visible = vis;
      });
    };
    widget.callback[Callbacks.changeName] = ([name]){
      setState(() {
        player = name;
      });
    };
    widget.callback[Callbacks.totalPlayers] = ([total]){
      setState(() {
        totalPlayers = total;
      });
    };
    widget.callback[Callbacks.playerType] = ([type]){
      setState(() {
        playerType = type;
      });
    };
    widget.callback[Callbacks.gameType] = ([t]){
      setState(() {
        type = t;
        setupGame();
      });
    };
    setupGame();
  }

  Vector3 getRandomPosition([int outside = 2]) {
    return Vector3(
      math.Random().nextDouble() * 4 - outside, 
      15,
      math.Random().nextDouble() * 4 - 2 
    );
  }

  Future<void> addDices() async {
    // Ground Body
    world.addRigidBody(oimo.RigidBody(
      type: oimo.RigidBodyType.static,
      shapes: [oimo.Box(oimo.ShapeConfig(geometry: oimo.Shapes.box),100, 1, 100)],
      position: Vector3(0, -0.5, 0),
      orientation: Quaternion.euler(0,0,0),
    ));
    createWalls();
    final diceCount = 6;
    for (int i = 0; i < diceCount; i++) {
      final position = getRandomPosition();
      dices.add(await createDice(position.x, position.y, position.z));
    }
  }

  void createWalls(){
    final vFOV = threeJs.camera.fov * math.pi / 180;        // convert vertical fov to radians
    final height = 2 * math.tan( vFOV / 2 ) * 30; // visible height
    final width = height * threeJs.camera.aspect;
    for(int i = 0; i < 4; i++){
      final boxGeometry = three.BoxGeometry(i<2?width:height, 30,1);
      final boxMaterial = three.MeshStandardMaterial.fromMap({ 
        'color': 0xe9e464,
        'side': three.DoubleSide,
        'visible': false
      });

      final box = three.Mesh(boxGeometry, boxMaterial);
      threeJs.scene.add(box);
      if(i < 2){
        box.position.z = i == 0?height/2:-height/2;
      }
      else{
        box.position.x = i == 2?width/2:-width/2;
        box.rotation.y = -0.5 * math.pi;
      }

      final hd = height/threeJs.height;

      final body = oimo.RigidBody(
        type: oimo.RigidBodyType.static,
        shapes: [oimo.Box(oimo.ShapeConfig(geometry: oimo.Shapes.box),i<2?width:height, 30, 1)],
        position: i < 2?Vector3(0, 0, i == 0?height/2-(50*hd):-height/2):Vector3(i == 2?width/2:-width/2, 0, 0),
        orientation: i < 2?Quaternion.euler(0,0,0):Quaternion.euler(-0.5 * math.pi,0,0),
      );

      world.addRigidBody(body);

      box.position.setFrom(body.position.toVector3());
      box.quaternion.setFrom(body.orientation.toQuaternion());
    }
  }

  Future<oimo.RigidBody> createDice(double x, double y, double z) async{
      final assetLoader = three.GLTFLoader();
      final gltf = await assetLoader.fromAsset("assets/dice_highres_red.glb");
      final model = gltf!.scene;

      final three.BoundingBox box = three.BoundingBox();
      box.setFromObject(model);
      
      final h = three.Mesh(
        three.SphereGeometry(box.max.distanceTo(box.min)/2),
        three.MeshStandardMaterial.fromMap({
          'flatShading': false,
          'transparent': true, 
          'opacity': 0.2,
          'visible': false,
          'color': Theme.of(context).secondaryHeaderColor.toARGB32()
        })
      )..name = 'highlight';
      helpers.add(h);
      threeJs.scene.add(model.add(h));
      visuals.add(model);
      model.position.setValues(0, 5, 0);

      model.traverse((child) => {
        if (child is three.Mesh) {
          model.visible = false
        }
      });

      final oimo.RigidBody body = oimo.RigidBody(
        type: oimo.RigidBodyType.dynamic,
        shapes: [
          oimo.Box(
            oimo.ShapeConfig(
              geometry: oimo.Shapes.box,
              density: 2,
              friction: 0.5,
              restitution: 0.75,
              belongsTo: 1,
              collidesWith: 0xffffffff
            ),
            2, 
            2, 
            2
          )
        ],
        position: Vector3(x,y,z),
        orientation: Quaternion.euler(
          (math.Random().nextDouble() * 360).floorToDouble(), 
          (math.Random().nextDouble() * 360).floorToDouble(), 
          (math.Random().nextDouble() * 360).floorToDouble()
        ),
        mass: 1.0
      );//

      world.addRigidBody(body);

    return body;
  }
  
  void updateVisuals(){
    bool allSleeping = true;
    for (int i = 0; i < dices.length; i++) {
      final body = dices[i];
      final visual = visuals[i];

      visual.position.setFrom(body.position.toVector3());
      visual.quaternion.setFrom(body.orientation.toQuaternion());
    
      if(!body.sleeping && visual.visible){
        allSleeping = false;
      }
    }

    selectedGame.allowSelect = allSleeping && didRollStart;
  }

  void animate() {
    world.step();
    updateVisuals();

    if(playerType == PlayerType.single && player != totalPlayers[0] && player != null){
      npc();
    }
  }
}
