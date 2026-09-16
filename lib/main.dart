import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'routes/routes.dart';
import 'routes/routes_name.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // 👈 ColorScheme add kar diya
        useMaterial3: true,
      ),
      initialRoute: RouteNames.splashscreen,
      routes: AppRoutes.routes,
    );
  }
}

//adb kill-server
//adb start-server
//adb devices
//adb tcpip 5555
//adb shell ip route
//USB cable connect
//adb devices
//adb connect 192.168.1.6:5555
//adb connect 192.168.1.3:5555
////Cable nikaalo


//adb shell ip route
//ping -c 4 192.168.1.17
//nc -vz 192.168.1.17 5555
//adb connect 192.168.1.17:5555


/*
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: const Text('Data Saved Successfully!'),
behavior: SnackBarBehavior.floating,
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(10),
),
backgroundColor: Colors.black87,
duration: const Duration(seconds: 2),
),
);*/
