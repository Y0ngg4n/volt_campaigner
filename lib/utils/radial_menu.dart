import 'package:flutter/material.dart';
import 'dart:math';
import 'package:vector_math/vector_math.dart' show radians;
import 'package:volt_campaigner/map/poster/add_poster.dart';

typedef OnStartAddPoster = Function();
typedef OnStartAddPosterIndex = Function(int);

// The stateful widget + animation controller
class RadialMenu extends StatefulWidget {
  int length;
  OnStartAddPoster onStartAddPoster;
  OnStartAddPosterIndex onStartAddPosterIndex;

  RadialMenu(
      {Key? key,
      required this.length,
      required this.onStartAddPoster,
      required this.onStartAddPosterIndex})
      : super(key: key);

  createState() => RadialMenuState();
}

class RadialMenuState extends State<RadialMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final GlobalKey<RadialAnimationState> radialMenuKey =
      GlobalKey<RadialAnimationState>();

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: 900), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return RadialAnimation(
      key: radialMenuKey,
      length: widget.length,
      controller: controller,
      onStartAddPoster: widget.onStartAddPoster,
      onStartAddPosterIndex: widget.onStartAddPosterIndex,
    );
  }

  close() {
    if (radialMenuKey.currentState != null) radialMenuKey.currentState!.close();
  }
}

class RadialAnimation extends StatefulWidget {
  final AnimationController controller;
  final Animation<double> scale;
  final Animation<double> translation;
  final Animation<double> rotation;
  int length;
  OnStartAddPoster onStartAddPoster;
  OnStartAddPosterIndex onStartAddPosterIndex;

  RadialAnimation(
      {Key? key,
      required this.controller,
      required this.onStartAddPoster,
      required this.onStartAddPosterIndex,
      required this.length})
      : scale = Tween<double>(
          begin: 1,
          end: 0.0,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn),
        ),
        translation = Tween<double>(
          begin: 0.0,
          end: 100.0,
        ).animate(
          CurvedAnimation(parent: controller, curve: Curves.linear),
        ),
        rotation = Tween<double>(
          begin: 0.0,
          end: 360.0,
        ).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.3,
              0.9,
              curve: Curves.decelerate,
            ),
          ),
        ),
        super(key: key);

  @override
  RadialAnimationState createState() => RadialAnimationState();
}

// The Animation
class RadialAnimationState extends State<RadialAnimation> {
  build(context) {
    return AnimatedBuilder(
        animation: widget.controller,
        builder: (context, builder) {
          return SizedBox(
            width: 150,
            height: 150,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(75, 75, 0, 0),
              child: Transform.rotate(
                angle: radians(widget.rotation.value),
                child: Stack(alignment: Alignment.center, children: [
                  for (int i = 0; i < 4; i++)
                    _buildButton(i, 172 + (35 * i).toDouble(),
                        color: Theme.of(context).primaryColor,
                        text: (i + 1).toString()),
                  Transform.scale(
                    scale: widget.scale.value - 1.5,
                    // subtract the beginning value to run the opposite animation
                    child: FloatingActionButton(
                        heroTag: "Add-PosterAdd",
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        onPressed: () => widget.onStartAddPoster(),
                        backgroundColor: Theme.of(context).primaryColor),
                  ),
                  Transform.scale(
                    scale: widget.scale.value,
                    child: FloatingActionButton(
                        heroTag: "Add-PosterFirstAdd",
                        backgroundColor: Theme.of(context).primaryColor,
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        onPressed: widget.length == -1
                            ? () => widget.onStartAddPoster()
                            : () => open()),
                  ),
                ]),
              ),
            ),
          );
        });
  }

  open() {
    widget.controller.forward();
  }

  close() {
    widget.controller.reverse();
  }

  _buildButton(int index, double angle,
      {required Color color, required String text}) {
    final double rad = radians(angle);
    return Transform(
        transform: Matrix4.identity()
          ..translate((widget.translation.value) * cos(rad),
              (widget.translation.value) * sin(rad)),
        child: FloatingActionButton(
            heroTag: "radial-menu-" + angle.toString(),
            child: Text(text),
            backgroundColor: color,
            foregroundColor: Colors.white,
            onPressed: () => widget.onStartAddPosterIndex(index)));
  }
}
