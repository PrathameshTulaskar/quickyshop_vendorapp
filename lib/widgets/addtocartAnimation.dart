import 'dart:async';
import 'dart:math';

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

import 'colors.dart';


class CartAnimation extends StatefulWidget {
  CartAnimation({Key key, this.title,this.cartCount,this.onAppPressed}) : super(key: key);
  final String title;
  final String cartCount;
  final Function onAppPressed;
  @override
  _CartAnimationState createState() => new _CartAnimationState();
}

enum ScoreWidgetStatus {
  HIDDEN,
  BECOMING_VISIBLE,
  VISIBLE,
  BECOMING_INVISIBLE
}

class _CartAnimationState extends State<CartAnimation> with TickerProviderStateMixin {
  double _sparklesAngle = 0.0;
  ScoreWidgetStatus _scoreWidgetStatus = ScoreWidgetStatus.HIDDEN;
  final duration = new Duration(milliseconds: 400);
  final oneSecond = new Duration(seconds: 1);
  Random random;
  Timer holdTimer, scoreOutETA;
  AnimationController scoreInAnimationController, scoreOutAnimationController,
      scoreSizeAnimationController, sparklesAnimationController;
  Animation scoreOutPositionAnimation, sparklesAnimation;
  
  initState() {
    super.initState();
    random = new Random();
    scoreInAnimationController = new AnimationController(duration: new Duration(milliseconds: 150), vsync: this);
    scoreInAnimationController.addListener((){
      setState(() {}); // Calls render function
    });

    scoreOutAnimationController = new AnimationController(vsync: this, duration: duration);
    scoreOutPositionAnimation = new Tween(begin: 100.0, end: 150.0).animate(
      new CurvedAnimation(parent: scoreOutAnimationController, curve: Curves.easeOut)
    );
    scoreOutPositionAnimation.addListener((){
      setState(() {});
    });
    scoreOutAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _scoreWidgetStatus = ScoreWidgetStatus.HIDDEN;
      }
    });

    scoreSizeAnimationController = new AnimationController(vsync: this, duration: new Duration(milliseconds: 150));
    scoreSizeAnimationController.addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        scoreSizeAnimationController.reverse();
      }
    });
    scoreSizeAnimationController.addListener((){
      setState(() {});
    });

    sparklesAnimationController = new AnimationController(vsync: this, duration: duration);
    sparklesAnimation = new CurvedAnimation(parent: sparklesAnimationController, curve: Curves.easeIn);
    sparklesAnimation.addListener((){
      setState(() { });
    });
  }

  dispose() {
   super.dispose();
   scoreInAnimationController.dispose();
   scoreOutAnimationController.dispose();
  }

  void increment(Timer t) {
    scoreSizeAnimationController.forward(from: 0.0);
    sparklesAnimationController.forward(from: 0.0);
    setState(() {
      _sparklesAngle = random.nextDouble() * (2*pi);
    });
  }
  
  void onTapDown(TapDownDetails tap) {
    // User pressed the button. This can be a tap or a hold.
    if (scoreOutETA != null) {
      scoreOutETA.cancel(); // We do not want the score to vanish!
    }
    if(_scoreWidgetStatus == ScoreWidgetStatus.BECOMING_INVISIBLE) {
      // We tapped down while the widget was flying up. Need to cancel that animation.
      scoreOutAnimationController.stop(canceled: true);
      _scoreWidgetStatus = ScoreWidgetStatus.VISIBLE;
    }
    else if (_scoreWidgetStatus == ScoreWidgetStatus.HIDDEN ) {
        _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_VISIBLE;
        scoreInAnimationController.forward(from: 0.0);
    }
    increment(null); // Take care of tap
    holdTimer = new Timer.periodic(duration, increment); // Takes care of hold
  }

  void onTapUp(TapUpDetails tap) {
    // User removed his finger from button.
    scoreOutETA = new Timer(oneSecond, () {
      scoreOutAnimationController.forward(from: 0.0);
      _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_INVISIBLE;
    });
    holdTimer.cancel();
  }

  Widget getScoreButton() {
    var scorePosition = 0.0;
    var scoreOpacity = 0.0;
    var extraSize = 0.0;
    switch(_scoreWidgetStatus) {
      case ScoreWidgetStatus.HIDDEN:
        break;
      case ScoreWidgetStatus.BECOMING_VISIBLE :
      case ScoreWidgetStatus.VISIBLE:
        scorePosition = scoreInAnimationController.value * 100;
        scoreOpacity = scoreInAnimationController.value;
        extraSize = scoreSizeAnimationController.value * 3;
        break;
      case ScoreWidgetStatus.BECOMING_INVISIBLE:
        scorePosition = scoreOutPositionAnimation.value;
        scoreOpacity = 1.0 - scoreOutAnimationController.value;
    }
    var stackChildren = <Widget>[
    ];
    var firstAngle = _sparklesAngle;
    var sparkleRadius = (sparklesAnimationController.value * 50) ;
    var sparklesOpacity = (1 - sparklesAnimation.value);

    for(int i = 0;i < 5; ++i) {
      var currentAngle = (firstAngle + ((2*pi)/5)*(i));
      var sparklesWidget =
        new Positioned(child: new Transform.rotate(
            angle: currentAngle - pi/2,
            child: new Opacity(opacity: sparklesOpacity,
                child : new Image.asset("assets/images/sparkles.png", width: 14.0, height: 14.0, ))
          ),
          left:(sparkleRadius*cos(currentAngle)) + 20,
          top: (sparkleRadius* sin(currentAngle)) + 20 ,
      );
      stackChildren.add(sparklesWidget);
    }

    stackChildren.add(new Opacity(opacity: scoreOpacity, child: new Container(
        height: 50.0 + extraSize,
        width: 50.0  + extraSize,
        decoration: new ShapeDecoration(
          shape: new CircleBorder(
              side: BorderSide.none
          ),
          color: animationCartBtn,
        ),
        
    )));
    var widget =  new Positioned(
        child: new Stack(
          alignment: FractionalOffset.center,
          overflow: Overflow.visible,
          children: stackChildren,
        )
        ,
        //bottom: scorePosition
    );
    return widget;
  }

  Widget getClapButton() {
    // Using custom gesture detector because we want to keep increasing the claps
    // when user holds the button.

    var extraSize = 0.0;
    if (_scoreWidgetStatus == ScoreWidgetStatus.VISIBLE || _scoreWidgetStatus == ScoreWidgetStatus.BECOMING_VISIBLE) {
      extraSize = scoreSizeAnimationController.value * 3;
    }
    return new GestureDetector(
        onTapUp:(void tap){
          scoreOutETA = new Timer(oneSecond, () {
      scoreOutAnimationController.forward(from: 0.0);
      _scoreWidgetStatus = ScoreWidgetStatus.BECOMING_INVISIBLE;
    });
    holdTimer.cancel();
    //Navigator.pushNamed(context, '/cart');
        },
        onTapDown: onTapDown,
        child: new Container(
          height: 60.0 + extraSize ,
          width: 60.0 + extraSize,
          padding: new EdgeInsets.all(10.0),
          decoration: new BoxDecoration(
              border: new Border.all(color: Colors.pink, width: 1.0),
              borderRadius: new BorderRadius.circular(50.0),
              color: Colors.white,
              boxShadow: [
                new BoxShadow(color: Colors.pink, blurRadius: 8.0)
              ]
          ),
          child:Badge(padding: EdgeInsets.all(12),
          position: BadgePosition.topEnd(top: 10,end:10),
          badgeContent: Text(widget.cartCount ?? "0",
            // cartItems.length.toString()
          ),
          child:IconButton(icon:Icon(Icons.shopping_bag_outlined),
          onPressed: ()=>Navigator.pushNamed(context,'/cart'),)
          
          )
        //    GFIconBadge(
        //     padding: EdgeInsets.only(right: 10.0,top: 1),
        //     child: Icon(Icons.shopping_cart,size: 40.0,),
        //     counterChild: Badge(
        //           child: Padding(
        //             padding: const EdgeInsets.all(12),
        //             child: Text(widget.cartCount ?? "0"),
        //           ),
        //           size: 25,
        //           shape: GFBadgeShape.circle,
        //     ),
        // ),
    ),);
  }

  @override
  Widget build(BuildContext context) {
    return new Padding(
          padding: new EdgeInsets.only(right: 0.0),
          child: new Stack(
            alignment: FractionalOffset.center,
            overflow: Overflow.visible,
            children: <Widget>[ 
              getScoreButton(),
              getClapButton(),
              //runTimer()
            ],
          )
      );
  }
}