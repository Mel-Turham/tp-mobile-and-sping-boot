import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:techconnect/app.dart';
import 'package:techconnect/services/auth_service.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => AuthService(),
        child: const TechConnectApp(),
      ),
    );
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}