import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'functionality/state.dart';
import 'functionality/routing.dart';
import 'controllers/splash_controller.dart';

/// App entry point. Initializes Firebase and runs the root widget.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppState>(create: (_) => AppState()),
        ChangeNotifierProvider<SplashController>(
            create: (_) => SplashController()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Root widget. Sets up MaterialApp with theme and routing.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Livingdex',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              brightness: context.watch<ThemeNotifier>().brightness,
              seedColor: const Color.fromARGB(255, 171, 222, 244),
            ),
          ),
        );
      },
    );
  }
}
