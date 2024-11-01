// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_gpu_shaders/build.dart';
import 'package:flutter_scene_importer/build_hooks.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  await build(args, (config, output) async {
    await buildShaderBundleJson(
        buildConfig: config,
        buildOutput: output,
        manifestFileName: 'my_first_triangle.shaderbundle.json');
    buildModels(buildConfig: config, inputFilePaths: [
      'assets/hexagon-kit/bridge.glb',
      'assets/hexagon-kit/building-archery.glb',
      'assets/hexagon-kit/building-cabin.glb',
      'assets/hexagon-kit/building-castle.glb',
      'assets/hexagon-kit/building-dock.glb',
      'assets/hexagon-kit/building-farm.glb',
      'assets/hexagon-kit/building-house.glb',
      'assets/hexagon-kit/building-market.glb',
      'assets/hexagon-kit/building-mill.glb',
      'assets/hexagon-kit/building-mine.glb',
      'assets/hexagon-kit/building-port.glb',
      'assets/hexagon-kit/building-sheep.glb',
      'assets/hexagon-kit/building-smelter.glb',
      'assets/hexagon-kit/building-tower.glb',
      'assets/hexagon-kit/building-village.glb',
      'assets/hexagon-kit/building-wall.glb',
      'assets/hexagon-kit/building-walls.glb',
      'assets/hexagon-kit/building-watermill.glb',
      'assets/hexagon-kit/building-wizard-tower.glb',
      'assets/hexagon-kit/dirt-lumber.glb',
      'assets/hexagon-kit/dirt.glb',
      'assets/hexagon-kit/grass-forest.glb',
      'assets/hexagon-kit/grass-hill.glb',
      'assets/hexagon-kit/grass.glb',
      'assets/hexagon-kit/path-corner-sharp.glb',
      'assets/hexagon-kit/path-corner.glb',
      'assets/hexagon-kit/path-crossing.glb',
      'assets/hexagon-kit/path-end.glb',
      'assets/hexagon-kit/path-intersectionA.glb',
      'assets/hexagon-kit/path-intersectionB.glb',
      'assets/hexagon-kit/path-intersectionC.glb',
      'assets/hexagon-kit/path-intersectionD.glb',
      'assets/hexagon-kit/path-intersectionE.glb',
      'assets/hexagon-kit/path-intersectionF.glb',
      'assets/hexagon-kit/path-intersectionG.glb',
      'assets/hexagon-kit/path-intersectionH.glb',
      'assets/hexagon-kit/path-square-end.glb',
      'assets/hexagon-kit/path-square.glb',
      'assets/hexagon-kit/path-start.glb',
      'assets/hexagon-kit/path-straight.glb',
      'assets/hexagon-kit/river-corner-sharp.glb',
      'assets/hexagon-kit/river-corner.glb',
      'assets/hexagon-kit/river-crossing.glb',
      'assets/hexagon-kit/river-end.glb',
      'assets/hexagon-kit/river-intersectionA.glb',
      'assets/hexagon-kit/river-intersectionB.glb',
      'assets/hexagon-kit/river-intersectionC.glb',
      'assets/hexagon-kit/river-intersectionD.glb',
      'assets/hexagon-kit/river-intersectionE.glb',
      'assets/hexagon-kit/river-intersectionF.glb',
      'assets/hexagon-kit/river-intersectionG.glb',
      'assets/hexagon-kit/river-intersectionH.glb',
      'assets/hexagon-kit/river-start.glb',
      'assets/hexagon-kit/river-straight.glb',
      'assets/hexagon-kit/sand-desert.glb',
      'assets/hexagon-kit/sand-rocks.glb',
      'assets/hexagon-kit/sand.glb',
      'assets/hexagon-kit/stone-hill.glb',
      'assets/hexagon-kit/stone-mountain.glb',
      'assets/hexagon-kit/stone-rocks.glb',
      'assets/hexagon-kit/stone.glb',
      'assets/hexagon-kit/unit-house.glb',
      'assets/hexagon-kit/unit-mansion.glb',
      'assets/hexagon-kit/unit-mill.glb',
      'assets/hexagon-kit/unit-ship-large.glb',
      'assets/hexagon-kit/unit-ship.glb',
      'assets/hexagon-kit/unit-tower.glb',
      'assets/hexagon-kit/unit-tree.glb',
      'assets/hexagon-kit/unit-wall-tower.glb',
      'assets/hexagon-kit/water-island.glb',
      'assets/hexagon-kit/water-rocks.glb',
      'assets/hexagon-kit/water.glb',
    ]);
  });
}
