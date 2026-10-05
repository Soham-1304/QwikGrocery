import 'dart:async';

import 'package:flutter/material.dart';
import 'package:qwik_grocery_app/core/theme/app_theme.dart';
import 'package:qwik_grocery_app/state/cart_controller.dart';
import 'package:qwik_grocery_app/state/cart_scope.dart';
import 'mock_api_client.dart';

/// Test runner results and summary.
class TestSummary {
  int total = 0;
  int passed = 0;
  int failed = 0;
  final List<String> failureMessages = [];

  void recordPass() {
    total++;
    passed++;
  }

  void recordFail(String message) {
    total++;
    failed++;
    failureMessages.add(message);
  }

  void printReport(String suiteName) {
    print('======================================================');
    print('TEST SUITE: $suiteName');
    print('Total: $total | Passed: $passed | Failed: $failed');
    if (failed > 0) {
      print('--- FAILURES ---');
      for (final msg in failureMessages) {
        print('❌ $msg');
      }
    } else {
      print('✅ All tests passed successfully!');
    }
    print('======================================================\n');
  }
}

/// Global test execution context.
final TestSummary globalTestSummary = TestSummary();

/// Assertion error thrown when expect fails.
class TestAssertionError extends Error {
  TestAssertionError(this.message);
  final String message;

  @override
  String toString() => 'TestAssertionError: $message';
}

/// Helper for matching values in test assertions.
void expect(dynamic actual, dynamic expectedOrMatcher, [String? reason]) {
  if (expectedOrMatcher is bool) {
    if (actual != expectedOrMatcher) {
      throw TestAssertionError(
        'Expected $expectedOrMatcher, but got $actual${reason != null ? " ($reason)" : ""}',
      );
    }
    return;
  }

  if (expectedOrMatcher is _Matcher) {
    if (!expectedOrMatcher.matches(actual)) {
      throw TestAssertionError(
        'Expected ${expectedOrMatcher.describe()}, but got $actual${reason != null ? " ($reason)" : ""}',
      );
    }
    return;
  }

  if (actual != expectedOrMatcher) {
    throw TestAssertionError(
      'Expected "$expectedOrMatcher", but got "$actual"${reason != null ? " ($reason)" : ""}',
    );
  }
}

abstract class _Matcher {
  bool matches(dynamic actual);
  String describe();
}

class _EqualsMatcher extends _Matcher {
  _EqualsMatcher(this.expected);
  final dynamic expected;
  @override
  bool matches(dynamic actual) => actual == expected;
  @override
  String describe() => 'equals($expected)';
}

class _GreaterThanMatcher extends _Matcher {
  _GreaterThanMatcher(this.threshold);
  final num threshold;
  @override
  bool matches(dynamic actual) => actual is num && actual > threshold;
  @override
  String describe() => 'greater than $threshold';
}

class _GreaterThanOrEqualToMatcher extends _Matcher {
  _GreaterThanOrEqualToMatcher(this.threshold);
  final num threshold;
  @override
  bool matches(dynamic actual) => actual is num && actual >= threshold;
  @override
  String describe() => 'greater than or equal to $threshold';
}

class _LessThanMatcher extends _Matcher {
  _LessThanMatcher(this.threshold);
  final num threshold;
  @override
  bool matches(dynamic actual) => actual is num && actual < threshold;
  @override
  String describe() => 'less than $threshold';
}

class _LessThanOrEqualToMatcher extends _Matcher {
  _LessThanOrEqualToMatcher(this.threshold);
  final num threshold;
  @override
  bool matches(dynamic actual) => actual is num && actual <= threshold;
  @override
  String describe() => 'less than or equal to $threshold';
}

class _ContainsMatcher extends _Matcher {
  _ContainsMatcher(this.sub);
  final dynamic sub;
  @override
  bool matches(dynamic actual) {
    if (actual is String && sub is String) return actual.contains(sub);
    if (actual is Iterable) return actual.contains(sub);
    if (actual is Map) return actual.containsKey(sub);
    return false;
  }
  @override
  String describe() => 'contains $sub';
}

class _IsEmptyMatcher extends _Matcher {
  @override
  bool matches(dynamic actual) {
    if (actual is String) return actual.isEmpty;
    if (actual is Iterable) return actual.isEmpty;
    if (actual is Map) return actual.isEmpty;
    return false;
  }
  @override
  String describe() => 'is empty';
}

class _IsNotEmptyMatcher extends _Matcher {
  @override
  bool matches(dynamic actual) {
    if (actual is String) return actual.isNotEmpty;
    if (actual is Iterable) return actual.isNotEmpty;
    if (actual is Map) return actual.isNotEmpty;
    return false;
  }
  @override
  String describe() => 'is not empty';
}

// Matcher factory helpers
_Matcher equals(dynamic expected) => _EqualsMatcher(expected);
_Matcher greaterThan(num threshold) => _GreaterThanMatcher(threshold);
_Matcher greaterThanOrEqualTo(num threshold) => _GreaterThanOrEqualToMatcher(threshold);
_Matcher lessThan(num threshold) => _LessThanMatcher(threshold);
_Matcher lessThanOrEqualTo(num threshold) => _LessThanOrEqualToMatcher(threshold);
_Matcher contains(dynamic sub) => _ContainsMatcher(sub);
final _Matcher isTrue = _EqualsMatcher(true);
final _Matcher isFalse = _EqualsMatcher(false);
final _Matcher isNull = _EqualsMatcher(null);
final _Matcher isNotNull = _MatcherNotNull();
final _Matcher isEmpty = _IsEmptyMatcher();
final _Matcher isNotEmpty = _IsNotEmptyMatcher();

class _MatcherNotNull extends _Matcher {
  @override
  bool matches(dynamic actual) => actual != null;
  @override
  String describe() => 'is not null';
}

/// Executes a test case within the harness.
Future<void> testCase(String description, FutureOr<void> Function() body) async {
  try {
    await body();
    globalTestSummary.recordPass();
    print('  ✓ $description');
  } catch (e, st) {
    globalTestSummary.recordFail('$description -> $e');
    print('  ✗ $description');
    print('    Error: $e');
    print('    Stack: $st');
  }
}

/// Groups test cases under a descriptive heading.
Future<void> testGroup(String groupName, FutureOr<void> Function() body) async {
  print('\n[$groupName]');
  await body();
}

/// Simulated widget testing harness for headless verification.
class TestGroceryHarness {
  TestGroceryHarness({
    MockApiClient? client,
    CartController? controller,
  })  : client = client ?? MockApiClient(),
        controller = controller ?? CartController();

  final MockApiClient client;
  final CartController controller;
  Widget? _mountedWidget;

  void pumpGroceryApp(Widget child) {
    _mountedWidget = CartScope(
      controller: controller,
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(body: child),
      ),
    );
  }

  Widget? get mounted => _mountedWidget;
}
