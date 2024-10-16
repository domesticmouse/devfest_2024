import 'package:native_assets_cli/native_assets_cli.dart';
import 'package:flutter_gpu_shaders/build.dart';

void main(List<String> args) async {
  await build(args, (config, output) async {
    await buildShaderBundleJson(
        buildConfig: config,
        buildOutput: output,
        manifestFileName: 'my_first_triangle.shaderbundle.json');
  });
}
