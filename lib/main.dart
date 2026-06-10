import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'cubits/counter_cubit.dart';
import 'cubits/theme_cubit.dart';
import 'cubits/student_cubit.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      startLocale: const Locale('ar'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // 👆 no longer StatefulWidget — Cubits handle everything now
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      // 👆 provides ALL 3 cubits to the whole app at once
      providers: [
        BlocProvider(
          create: (_) => ThemeCubit()..loadTheme(),
          // 👆 create ThemeCubit AND immediately load saved theme
          //    .. means "call loadTheme() on the same object"
        ),
        BlocProvider(
          create: (_) => CounterCubit(),
          // 👆 create CounterCubit, starts at 0
        ),
        BlocProvider(
          create: (_) => StudentCubit(),
          // 👆 create StudentCubit, starts with empty state
        ),
      ],
      child: BlocBuilder<ThemeCubit, bool>(
        // 👆 watches ThemeCubit — rebuilds MaterialApp when theme changes
        builder: (context, isDarkMode) {
          return MaterialApp(
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: context.locale,
            debugShowCheckedModeBanner: false,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
            // 👆 isDarkMode comes from ThemeCubit automatically
            home: HomePage(),
            // 👆 no more passing isDarkMode and onThemeToggle down!
            //    HomePage gets them directly from the Cubit
          );
        },
      ),
    );
  }
}
