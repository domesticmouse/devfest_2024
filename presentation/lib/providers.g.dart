// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$configurationHash() => r'b569038866dd3fdeb3d0c6a33b87bd30d832e699';

/// See also [configuration].
@ProviderFor(configuration)
final configurationProvider = AutoDisposeFutureProvider<Configuration>.internal(
  configuration,
  name: r'configurationProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$configurationHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ConfigurationRef = AutoDisposeFutureProviderRef<Configuration>;
String _$highlightersHash() => r'88e7745eb013a4c8bfc78deac1df33bc00355a51';

/// See also [highlighters].
@ProviderFor(highlighters)
final highlightersProvider = AutoDisposeFutureProvider<Highlighters>.internal(
  highlighters,
  name: r'highlightersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$highlightersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HighlightersRef = AutoDisposeFutureProviderRef<Highlighters>;
String _$cursorHash() => r'9763a27c8368c949b58f6398bd639c5be4e63884';

/// See also [Cursor].
@ProviderFor(Cursor)
final cursorProvider =
    AutoDisposeNotifierProvider<Cursor, (Section, Step, SubStep)>.internal(
      Cursor.new,
      name: r'cursorProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cursorHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$Cursor = AutoDisposeNotifier<(Section, Step, SubStep)>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
