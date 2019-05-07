import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class Po {
  bool isRemove;

  double x;
  double y;
  double r;
  double vx;
  double vy;

  Po(this.x, this.y, this.r, this.vx, this.vy);

  double lenght(Po o) {
    double lx = x - o.x;
    double ly = y - o.y;
    return sqrt(lx * lx + ly * ly);
  }

  void move() {
    Future(() {
      if ((x < -0.01 && vx < 0) || (x > 1.01 && vx > 0)) {
        vx = -vx;
      }
      if ((y < -0.01 && vy < 0) || (y > 1.01 && vy > 0)) {
        vy = -vy;
      }
      x += vx;
      y += vy;
    });
  }
}

class GravitationView extends StatefulWidget {
  @override
  _GraState createState() => _GraState();
}

class _GraState extends State<GravitationView> {
  List<Po> pos;
  Timer timer;
  Random random;
  @override
  void initState() {
    random = Random();
    pos = List();
    for (var i = 0; i < 80; i++) {
      Po po = Po(
          random.nextDouble(),
          random.nextDouble(),
          random.nextDouble(),
          random.nextBool()
              ? random.nextDouble() / 1000
              : -random.nextDouble() / 1000,
          random.nextBool()
              ? random.nextDouble() / 1000
              : -random.nextDouble() / 1000);
      pos.add(po);
    }

    timer = Timer.periodic(Duration(milliseconds: 16), (a) {
      setState(() {
        for (var o in pos) {
          o.move();
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onDoubleTap: () {
          Navigator.of(context).pop(this);
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: Colors.black),
          child: CustomPaint(
            size: Size(double.infinity, double.infinity),
            painter: view(pos: pos),
          ),
        ),
      ),
    );
  }
}

class view extends CustomPainter {
  Paint mPaint;
  List<Po> pos;
  int size;
  Timer timer;
  Random random;
  Po po;
  Po poj;

  view({this.pos}) {
    mPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = Colors.white
      ..isAntiAlias = true;
  }

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;

    for (var i = 0; i < pos.length; i++) {
      po = pos[i];
      mPaint.strokeWidth = 10;
      canvas.drawPoints(
          PointMode.points, [Offset(po.x * width, po.y * height)], mPaint);
      for (var j = i + 1; j < pos.length; j++) {
        poj = pos[j];
        double lenght = po.lenght(poj);
        if (lenght > 0 && lenght < 0.2) {
          mPaint.strokeWidth = 5 * (0.2 - lenght);
          canvas.drawLine(Offset(po.x * width, po.y * height),
              Offset(poj.x * width, poj.y * height), mPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
