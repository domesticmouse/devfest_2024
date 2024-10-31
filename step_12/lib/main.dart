// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_scene/camera.dart';
import 'package:flutter_scene/node.dart';
import 'package:flutter_scene/scene.dart';
import 'package:vector_math/vector_math.dart';

void main() {
  final sceneReady = Scene.initializeStaticResources();
  runApp(MainApp(sceneReady: sceneReady));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.sceneReady});

  final Future<void> sceneReady;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  double elapsedSeconds = 0;
  Scene scene = Scene();
  late Ticker _ticker;

  @override
  void initState() {
    _ticker = createTicker((elapsed) {
      setState(() {
        elapsedSeconds = elapsed.inMilliseconds.toDouble() / 1000;
      });
    })
      ..start();

    Node.fromAsset('build/models/building-port.model').then((model) {
      model.name = 'Port Building';
      scene.add(model);
    });

    super.initState();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hexagon Explorer',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SizedBox.expand(
          child: FutureBuilder(
            future: widget.sceneReady,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(child: CircularProgressIndicator());
              }
              return CustomPaint(
                painter: ScenePainter(
                  scene: scene,
                  camera: PerspectiveCamera(
                    position: Vector3(
                        sin(elapsedSeconds) * 3, 2, cos(elapsedSeconds) * 3),
                    target: Vector3(0, 0, 0),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class ScenePainter extends CustomPainter {
  ScenePainter({required this.scene, required this.camera});
  Scene scene;
  Camera camera;

  @override
  void paint(Canvas canvas, Size size) {
    scene.render(camera, canvas, viewport: Offset.zero & size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
