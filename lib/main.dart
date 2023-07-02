import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:unitomo_va_payment/routing.dart';

import 'environtment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setSystemUIOverlayStyle(
  //   const SystemUiOverlayStyle(
  //     statusBarColor: Colors.transparent,
  //   ),
  // );

  await Hive.initFlutter();
  await Hive.openBox(boxName);
  await initializeDateFormatting('id', null);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {

  static final BuildContext? ctx = router.routerDelegate.navigatorKey.currentContext;

  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: const TextTheme().copyWith(
          // bodyLarge: const TextTheme().bodyLarge?.copyWith(
          //   // fontWeight: FontWeight.w600,
          // ),
          // bodySmall: const TextTheme().bodySmall?.copyWith(
          //   fontWeight: FontWeight.w600,
          // ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
