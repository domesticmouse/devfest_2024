// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;
import 'package:vector_math/vector_math.dart' as vm;

import '../config.dart';
import 'shaders.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0, end: 4 * math.pi).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: SizedBox.expand(
        child: AnimatedBuilder(
          builder: (context, child) {
            return CustomPaint(
              painter: TrianglePainter(angle: _animation.value),
            );
          },
          animation: _animation,
        ),
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  const TrianglePainter({required this.angle});
  final double angle;

  @override
  void paint(Canvas canvas, Size size) {
    final texture = gpu.gpuContext.createTexture(
      gpu.StorageMode.devicePrivate,
      size.width.ceil(),
      size.height.ceil(),
    );

    final renderTarget = gpu.RenderTarget.singleColor(
      gpu.ColorAttachment(texture: texture),
    );

    final commandBuffer = gpu.gpuContext.createCommandBuffer();
    final renderPass = commandBuffer.createRenderPass(renderTarget);

    final vert = shaderLibrary['Step11Vertex'];
    if (vert == null) {
      throw Exception('Failed to load SimpleVertex vertex shader');
    }

    final frag = shaderLibrary['Step11Fragment'];
    if (frag == null) {
      throw Exception('Failed to load SimpleFragment fragment shader');
    }

    final pipeline = gpu.gpuContext.createRenderPipeline(vert, frag);

    const floatsPerVertex = 6;
    final vertices = Float32List.fromList([
      // layout: x, y, z, r, g, b

      // Back Face
      -0.5, -0.5, -0.5, 1.0, 0.0, 0.0,
      0.5, -0.5, -0.5, 0.0, 1.0, 0.0,
      0.5, 0.5, -0.5, 0.0, 0.0, 1.0,
      0.5, 0.5, -0.5, 0.0, 0.0, 1.0,
      -0.5, 0.5, -0.5, 1.0, 1.0, 0.0,
      -0.5, -0.5, -0.5, 1.0, 0.0, 0.0,

      // Front Face
      -0.5, -0.5, 0.5, 1.0, 0.0, 0.0,
      0.5, 0.5, 0.5, 0.0, 0.0, 1.0,
      0.5, -0.5, 0.5, 0.0, 1.0, 0.0,
      0.5, 0.5, 0.5, 0.0, 0.0, 1.0,
      -0.5, -0.5, 0.5, 1.0, 0.0, 0.0,
      -0.5, 0.5, 0.5, 1.0, 1.0, 0.0,

      // Left Face
      -0.5, 0.5, 0.5, 1.0, 0.0, 0.0,
      -0.5, -0.5, -0.5, 0.0, 0.0, 1.0,
      -0.5, 0.5, -0.5, 0.0, 1.0, 0.0,
      -0.5, -0.5, -0.5, 0.0, 0.0, 1.0,
      -0.5, 0.5, 0.5, 1.0, 0.0, 0.0,
      -0.5, -0.5, 0.5, 1.0, 1.0, 0.0,

      // Right Face
      0.5, 0.5, 0.5, 1.0, 0.0, 0.0,
      0.5, 0.5, -0.5, 0.0, 1.0, 0.0,
      0.5, -0.5, -0.5, 0.0, 0.0, 1.0,
      0.5, -0.5, -0.5, 0.0, 0.0, 1.0,
      0.5, -0.5, 0.5, 1.0, 1.0, 0.0,
      0.5, 0.5, 0.5, 1.0, 0.0, 0.0,

      // Bottom Face
      0.5, -0.5, -0.5, 0.0, 1.0, 0.0,
      -0.5, -0.5, -0.5, 1.0, 0.0, 0.0,
      0.5, -0.5, 0.5, 0.0, 0.0, 1.0,
      -0.5, -0.5, 0.5, 1.0, 1.0, 0.0,
      0.5, -0.5, 0.5, 0.0, 0.0, 1.0,
      -0.5, -0.5, -0.5, 1.0, 0.0, 0.0,

      // Top Face
      -0.5, 0.5, -0.5, 1.0, 0.0, 0.0,
      0.5, 0.5, -0.5, 0.0, 1.0, 0.0,
      0.5, 0.5, 0.5, 0.0, 0.0, 1.0,
      0.5, 0.5, 0.5, 0.0, 0.0, 1.0,
      -0.5, 0.5, 0.5, 1.0, 1.0, 0.0,
      -0.5, 0.5, -0.5, 1.0, 0.0, 0.0,
    ]);

    final verticesDeviceBuffer = gpu.gpuContext.createDeviceBufferWithCopy(
      ByteData.sublistView(vertices),
    );

    final model = vm.Matrix4.identity()
      ..rotateY(angle)
      ..rotateX(angle / 2);
    final view = vm.Matrix4.translation(vm.Vector3(0.0, 0.0, -2.5));
    final projection = vm.makePerspectiveMatrix(
      vm.radians(45),
      size.aspectRatio,
      0.1,
      100,
    );

    final vertUniforms = [model, view, projection];

    final vertUniformsDeviceBuffer = gpu.gpuContext.createDeviceBufferWithCopy(
      ByteData.sublistView(
        Float32List.fromList(vertUniforms.expand((m) => m.storage).toList()),
      ),
    );

    renderPass.bindPipeline(pipeline);

    renderPass.setCullMode(gpu.CullMode.backFace);

    final verticesView = gpu.BufferView(
      verticesDeviceBuffer,
      offsetInBytes: 0,
      lengthInBytes: verticesDeviceBuffer.sizeInBytes,
    );
    renderPass.bindVertexBuffer(
      verticesView,
      vertices.length ~/ floatsPerVertex,
    );

    final vertUniformsView = gpu.BufferView(
      vertUniformsDeviceBuffer,
      offsetInBytes: 0,
      lengthInBytes: vertUniformsDeviceBuffer.sizeInBytes,
    );

    renderPass.bindUniform(vert.getUniformSlot('VertInfo'), vertUniformsView);

    renderPass.draw();

    commandBuffer.submit();
    final image = texture.asImage();
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
