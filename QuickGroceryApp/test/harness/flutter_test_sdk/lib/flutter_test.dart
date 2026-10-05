library flutter_test;

export 'package:flutter/foundation.dart';
export 'package:flutter/widgets.dart';
export 'package:flutter/material.dart';

// Test runner primitives
void test(String description, dynamic Function() body) {}
void group(String description, void Function() body) {}
void testWidgets(String description, dynamic Function(dynamic tester) callback) {}
void expect(dynamic actual, dynamic matcher, {String? reason}) {}
