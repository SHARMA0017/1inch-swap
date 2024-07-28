import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  final designSize = const Size(390, 844);

  @override
  Widget build(
    BuildContext context,
  ) {
    if (MediaQuery.of(context).size.width > 0) {
      return ScreenUtilInit(
        designSize: designSize,
        splitScreenMode: true,
        builder: (context, child) {
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: SafeArea(
              child: MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Air Strike',
                scrollBehavior: const MaterialScrollBehavior()
                    .copyWith(physics: const BouncingScrollPhysics()),
                theme: ThemeData.dark(),
                home: const HomePage(),
                // initialRoute: SplashPage.id,
                // onGenerateRoute: RouteGenerator.generateRoute,
              ),
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}
