// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter_gpu_shaders/build.dart';
import 'package:flutter_scene_importer/build_hooks.dart';
import 'package:native_assets_cli/native_assets_cli.dart';

void main(List<String> args) async {
  await build(args, (buildInput, output) async {
    await buildShaderBundleJson(
      buildInput: buildInput,
      buildOutput: output,
      manifestFileName: 'my_first_triangle.shaderbundle.json',
    );
    buildModels(
      buildInput: buildInput,
      inputFilePaths: ['assets/hexagon-kit/building-port.glb'],
    );
  });
}
