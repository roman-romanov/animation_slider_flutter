import 'package:animation_slider/const/consts.dart';
import 'package:flutter/material.dart';

class SkillCard extends StatelessWidget {
  const SkillCard({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.loose,
      children: [
        Positioned(
          top: 87.5,
          right: 0,
          left: 0,
          child: AspectRatio(
            aspectRatio: 342 / 275,
            child: Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 30),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 41.0),
                        child: Text(
                          "Крутое название",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Container(
                        height: 16,
                      ),
                      Text(
                        "Какой-то долгий или не совсем долгий и нудный текст",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Image.asset(
            icGift,
            width: 175,
            height: 175,
          ),
        ),
      ],
    );
  }
}
