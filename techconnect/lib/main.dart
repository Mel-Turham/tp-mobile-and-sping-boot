import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:techconnect/app.dart';
import 'package:techconnect/services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const TechConnectApp(),
    ),
  );
}