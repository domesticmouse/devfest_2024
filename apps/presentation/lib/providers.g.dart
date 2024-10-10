// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$configurationHash() => r'47c526cdcc9b3803aaa6399130a784fb7aeeb04b';

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

typedef ConfigurationRef = AutoDisposeFutureProviderRef<Configuration>;
String _$highlightersHash() => r'd30c06cf3c26ba914ee3573ff56a790917e2dc94';

/// See also [highlighters].
@ProviderFor(highlighters)
final highlightersProvider = AutoDisposeFutureProvider<Highlighters>.internal(
  highlighters,
  name: r'highlightersProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$highlightersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef HighlightersRef = AutoDisposeFutureProviderRef<Highlighters>;
String _$cursorHash() => r'9763a27c8368c949b58f6398bd639c5be4e63884';

/// See also [Cursor].
@ProviderFor(Cursor)
final cursorProvider =
    AutoDisposeNotifierProvider<Cursor, (Section, Step, SubStep)>.internal(
  Cursor.new,
  name: r'cursorProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$cursorHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Cursor = AutoDisposeNotifier<(Section, Step, SubStep)>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
