import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

/// {@template exception_handler}
/// A mixin that provides error handling functionality with Firebase Crashlytics integration.
///
/// Use this mixin to wrap method calls with error handling and crash reporting.
/// In debug mode, errors are only logged locally.
/// In release mode, errors are reported to Firebase Crashlytics.
///
/// Example usage:
/// ```dart
/// class MyService with ExceptionHandler {
///   void riskyOperation() {
///     guard(
///       () => someRiskyMethod(),
///       onSuccess: (result) => print('Operation succeeded: $result'),
///       onError: (error, stack) => print('Operation failed: $error'),
///     );
///   }
/// }
/// ```
/// {@endtemplate}
mixin ExceptionHandler {
  /// {@macro exception_handler}
  Future<void> guard<T>(
    Future<T?> Function() method, {
    void Function(T? data)? onSuccess,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      final result = await method();
      onSuccess?.call(result);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        // Only log when not in debug mode
        onError?.call(error, stackTrace);
        return;
      }

      GetIt.I<FirebaseCrashlytics>().recordError(
        error,
        stackTrace,
        reason: 'Error caught by ExceptionHandler.runWithCrashlytics',
      );

      onError?.call(error, stackTrace);
    }
  }
}
