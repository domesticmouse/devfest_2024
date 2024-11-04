// Copyright 2024 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_scene/scene.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers.dart';
import 'slides/slides.dart';
import 'steps/step_01/main.dart' as step_01;
import 'steps/step_02/main.dart' as step_02;
import 'steps/step_03/main.dart' as step_03;
import 'steps/step_04/main.dart' as step_04;
import 'steps/step_05/main.dart' as step_05;
import 'steps/step_06/main.dart' as step_06;
import 'steps/step_07/main.dart' as step_07;
import 'steps/step_08/main.dart' as step_08;
import 'steps/step_09/main.dart' as step_09;
import 'steps/step_10/main.dart' as step_10;
import 'steps/step_11/main.dart' as step_11;
import 'steps/step_12/main.dart' as step_12;

void main() {
  final sceneReady = Scene.initializeStaticResources();
  runApp(
    ProviderScope(
      child: MainApp(sceneReady: sceneReady),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key, required this.sceneReady});

  final Future<void> sceneReady;

  ThemeData _buildTheme(Brightness brightness) {
    var baseTheme = ThemeData(
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: brightness,
      ),
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.robotoTextTheme(baseTheme.textTheme),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final (currentSection, currentStep, currentSubStep) =
        ref.watch(cursorProvider);

    return _EagerInitialization(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(Brightness.light),
        darkTheme: _buildTheme(Brightness.dark),
        themeMode: ThemeMode.dark,
        home: CallbackShortcuts(
          bindings: <ShortcutActivator, VoidCallback>{
            SingleActivator(LogicalKeyboardKey.arrowRight): () =>
                ref.read(cursorProvider.notifier).next(),
            SingleActivator(LogicalKeyboardKey.arrowLeft): () =>
                ref.read(cursorProvider.notifier).previous(),
          },
          child: Focus(
            autofocus: true,
            skipTraversal: true,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  'Step ${currentSection.displayStepNumber}: ${currentSection.name}',
                  style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                        fontSize: 0.02297297 * size.height + 7.594595,
                        fontWeight: FontWeight.w300),
                  ),
                ),
              ),
              drawer: NavigationDrawer(),
              body: switch ((
                currentStep.displayCode,
                currentStep.displayMarkdown,
                currentStep.showStep,
              )) {
                (String code, _, _) => DisplayCode(
                    assetPath: code,
                    fileType: currentStep.fileType ?? 'txt',
                    tree: currentStep.tree ?? [],
                    baseOffset: currentSubStep.baseOffset ??
                        currentSubStep.extentOffset,
                    extentOffset: currentSubStep.extentOffset,
                    scrollPercentage: currentSubStep.scrollPercentage ?? 0,
                    scrollSeconds: currentSubStep.scrollSeconds,
                  ),
                (_, String markdown, _) => DisplayMarkdown(assetPath: markdown),
                (_, _, 'step_01') => ShowStep(child: step_01.MainApp()),
                (_, _, 'step_02') => ShowStep(child: step_02.MainApp()),
                (_, _, 'step_03') => ShowStep(child: step_03.MainApp()),
                (_, _, 'step_04') => ShowStep(child: step_04.MainApp()),
                (_, _, 'step_05') => ShowStep(child: step_05.MainApp()),
                (_, _, 'step_06') => ShowStep(child: step_06.MainApp()),
                (_, _, 'step_07') => ShowStep(child: step_07.MainApp()),
                (_, _, 'step_08') => ShowStep(child: step_08.MainApp()),
                (_, _, 'step_09') => ShowStep(child: step_09.MainApp()),
                (_, _, 'step_10') => ShowStep(child: step_10.MainApp()),
                (_, _, 'step_11') => ShowStep(child: step_11.MainApp()),
                (_, _, 'step_12') =>
                  ShowStep(child: step_12.MainApp(sceneReady: sceneReady)),
                _ => DisplayMarkdown(
                    assetPath: 'assets/empty.txt',
                  )
              },
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationDrawer extends ConsumerWidget {
  const NavigationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final configuration = ref.watch(configurationProvider).asData;
    final (currentSection, currentStep, _) = ref.watch(cursorProvider);

    return Drawer(
      child: ListView(
        children: configuration != null
            ? [
                for (final (sectionNumber, section)
                    in configuration.value.sections.indexed) ...[
                  ListTile(
                    title: Text(
                      section.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: section == currentSection
                          ? Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800)
                          : Theme.of(context).textTheme.titleLarge,
                    ),
                    subtitle: Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Text('Step ${section.displayStepNumber}',
                          style: Theme.of(context).textTheme.titleMedium),
                    ),
                    onTap: () {
                      ref.read(cursorProvider.notifier).setCursorPosition(
                          sectionNumber: sectionNumber, stepNumber: 0);
                    },
                  ),
                  if (section == currentSection)
                    for (var (stepNumber, step) in section.steps.indexed)
                      ListTile(
                        title: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                step.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: step == currentStep
                                    ? Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800)
                                    : Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          ref.read(cursorProvider.notifier).setCursorPosition(
                              sectionNumber: sectionNumber,
                              stepNumber: stepNumber);
                          Scaffold.of(context).openEndDrawer();
                        },
                      ),
                ],
              ]
            : [],
      ),
    );
  }
}

class _EagerInitialization extends ConsumerWidget {
  const _EagerInitialization({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Force the eager loading and parsing of the assets/steps.yaml file
    ref.watch(configurationProvider);
    return child;
  }
}
