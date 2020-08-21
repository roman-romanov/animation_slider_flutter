import 'dart:math';

import 'package:animation_slider/card.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AnimationSliderDemo extends StatefulWidget {
  @override
  _AnimationSliderDemoState createState() => _AnimationSliderDemoState();
}

class _AnimationSliderDemoState extends State<AnimationSliderDemo>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  static const _dy = 2.0;
  static const _dOp = 0.2;
  static const _dS = 0.01;
  final idxs = [0, 1, 2, 3];
  final _backupIdx = [];

  List<Animation<Offset>> _offsetDy = [];
  List<Animation<double>> _opacity = [];
  List<Animation<double>> _scale = [];
  Animation<double> _rotate;
  Animation<Offset> _offsetDx;

  double _screenWidth;
  double _currentPos;
  double _currentAnimValue;
  bool _isReverse = false;
  bool _panStarted = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: 0,
    );

    // init - примерно середина анимации = 0.5
    // движение влево - forwar -> >05
    // swipe right - reverse -> <1

    idxs.forEach((idx) {
      var oDy = Tween<Offset>(
        begin: Offset(0, _dy * idx),
        end: Offset(0, _dy * (idx - 1)),
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0, 1),
        ),
      );

      _offsetDy.add(oDy);

      var _op = Tween<double>(
        begin: 1 - (idx) * _dOp,
        end: idx == 0 ? 1 : 1 - (idx - 1) * _dOp,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0, 1),
        ),
      );

      _opacity.add(_op);

      var s = Tween<double>(
        begin: 1 - idx * _dS,
        end: idx == 0 ? 1 : 1 - (idx - 1) * _dS,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0, 1),
        ),
      );

      _scale.add(s);
    });

    _offsetDx = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(-500, 10),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Interval(.0, 1)),
    );

    _rotate = Tween<double>(
      begin: 0.0,
      end: -pi / 10,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Interval(.0, 1)),
    );
  }

  @override
  void didChangeDependencies() {
    _screenWidth = MediaQuery.of(context).size.width;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 650,
            child: GestureDetector(
              dragStartBehavior: DragStartBehavior.start,
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              onTap: () {
                if (idxs.length == 1) return;
                _move(1, false);
              },
              child: Stack(
                children: [
                  for (var b in idxs) _buildStackChild(b),
                ].reversed.toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStackChild(int idx) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (c, w) => _buildAnimation(c, w, idx),
      child: SkillCard(
        key: ValueKey(idx),
      ),
    );
  }

  Widget _buildAnimation(BuildContext ctx, Widget w, int idx) {
    var isFirstBundle = idx == 0;

    return Transform.scale(
      alignment: Alignment.bottomCenter,
      scale: _scale[idx].value,
      child: Transform.rotate(
        angle: isFirstBundle ? _rotate.value : 0,
        child: Transform.translate(
          offset: isFirstBundle ? _offsetDx.value : _offsetDy[idx].value,
          child: Opacity(
            opacity: _opacity[idx].value,
            child: w,
          ),
        ),
      ),
    );
  }

  void _onPanStart(DragStartDetails d) {
    print("pan start");
    _currentPos = d.globalPosition.dx;
    _currentAnimValue = _controller.value;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    var delta = (_currentPos - d.globalPosition.dx) / _screenWidth;
    _isReverse = delta < 0;

    var value = _currentAnimValue + delta;

    if (_isReverse) {
      if (!_panStarted) {
        _panStarted = true;

        if (_backupIdx.isEmpty) return;

        setState(() {
          var i = _backupIdx.removeLast();
          idxs.add(i);
        });

        _currentAnimValue = _currentAnimValue == 0 ? 1 : _currentAnimValue;
      }
    }

    _controller.value = value;
    debugPrint(
        "Current value $value | curr : $_currentAnimValue | cont: ${_controller.value}");
  }

  void _onPanEnd(DragEndDetails d) {
    print("pan end");

    var velocity = d.velocity.pixelsPerSecond.dx;

    if (_controller.value >= 0.5 || velocity <= -300) {
      _move(1, false);
    } else if (_controller.value < 0.5 || velocity > 300) {
      _move(0.0, true);
    }
  }

  void _move(double to, bool reversed) async {
    try {
      await _controller.animateTo(
        to,
        duration: Duration(milliseconds: 150),
      );
    } catch (e) {} finally {
      if (!reversed) {
        setState(() {
          //hanky panky
          var i = idxs.removeLast();
          _backupIdx.add(i);
        });

        _controller.reset();
      }
    }

    _panStarted = false;
  }
}
