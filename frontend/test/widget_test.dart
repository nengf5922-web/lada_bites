import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart'; 

void main() {
  testWidgets('Aplikasi Lada Bites berjalan lancar', (WidgetTester tester) async {
    // Membangun aplikasi kita
    await tester.pumpWidget(const LadaBitsApp());

    // Memastikan widget dasar MaterialApp berhasil dimuat
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}