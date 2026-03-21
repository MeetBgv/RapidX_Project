import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:newrapidx/splashPage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, ChangeNotifierProvider;
import 'package:newrapidx/providers/userDataProvider.dart';

import 'package:newrapidx/deliveyPartner/theme/dp_theme.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(
    // ProviderScope is required for Riverpod (Delivery Partner)
    const ProviderScope(child: newRapidX()),
  );
}

class newRapidX extends StatelessWidget {
  const newRapidX({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider is kept only for Customer-side UserDataProvider
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp(
            title: "RapidX",
            theme: DPTheme.themeData,
            scrollBehavior: AppScrollBehavior(),
            debugShowCheckedModeBanner: false,
            home: const Scaffold(body: splashPage()),
          );
        },
      ),
    );
  }
}
