import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:maps/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedSplashScreen(
          splashIconSize: MediaQuery.of(context).size.height,
          duration: 1000,
          splash: Center(
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15)),
                child: Image(
                    width: size.width * 0.6,
                    height: size.height * 0.4,
                    image: AssetImage('assets/app_logo.png'))),
          ),
          nextScreen: home_screen()),
    );
  }
}
