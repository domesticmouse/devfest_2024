// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

import '../config.dart';
import 'shaders.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: SizedBox.expand(child: CustomPaint(painter: TrianglePainter())),
    );
  }
}

class TrianglePainter extends CustomPainter {
  const TrianglePainter();

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

    final vert = shaderLibrary['Step02Vertex'];
    if (vert == null) {
      throw Exception('Failed to load SimpleVertex vertex shader');
    }

    final frag = shaderLibrary['Step02Fragment'];
    if (frag == null) {
      throw Exception('Failed to load SimpleFragment fragment shader');
    }

    final pipeline = gpu.gpuContext.createRenderPipeline(vert, frag);

    const floatsPerVertex = 5;
    final vertices = Float32List.fromList([
      // Format: x, y, r, g, b,
      -0.5, -0.5, 1.0, 0.0, 0.0,
      0.5, -0.5, 0.0, 1.0, 0.0,
      0.0, 0.5, 0.0, 0.0, 1.0,
    ]);

    final verticesDeviceBuffer = gpu.gpuContext.createDeviceBufferWithCopy(
      ByteData.sublistView(vertices),
    );

    renderPass.bindPipeline(pipeline);

    final verticesView = gpu.BufferView(
      verticesDeviceBuffer,
      offsetInBytes: 0,
      lengthInBytes: verticesDeviceBuffer.sizeInBytes,
    );
    renderPass.bindVertexBuffer(
      verticesView,
      vertices.length ~/ floatsPerVertex,
    );

    renderPass.draw();

    commandBuffer.submit();
    final image = texture.asImage();
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
