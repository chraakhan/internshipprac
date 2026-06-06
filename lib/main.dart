import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    EasyLocalization(
      child: const MyApp(),
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      startLocale: const Locale('ar'), // app opens in Arabic
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // CHANGED: added these 3 lines back — without them app crashes
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context
          .locale, // CHANGED: was Locale('ar') — now uses easy_localization to control it so the button can switch it
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  int _submitCount = 0;
  int _studentCount = 0;

  Future<void> sendData() async {
    await FirebaseFirestore.instance.collection('students').add({
      'name': nameController.text,
      'age': ageController.text,
      'time': DateTime.now().toString(),
    });

    nameController.clear();
    ageController.clear();
    setState(() {
      _submitCount++;
      _studentCount++;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          // CHANGED: added format so big numbers show with commas
          "mesg".plural(_submitCount, format: NumberFormat.decimalPattern()),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("title".tr())),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "firstname".tr()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "age".tr()),
            ),
            // CHANGED: added format so big numbers show with commas
            Text(
              "students".plural(
                _studentCount,
                format: NumberFormat.decimalPattern(),
              ),
            ),
            const SizedBox(height: 20),
            // NEW: language switcher button
            ElevatedButton(
              onPressed: () async {
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();

                if (context.locale == Locale('ar')) {
                  context.setLocale(Locale('en'));
                  prefs.setString(
                    'lang',
                    'en',
                  ); // save the current language to shared preferences
                } else {
                  context.setLocale(Locale('ar'));
                  prefs.setString(
                    'lang',
                    'ar',
                  ); // save the current language to shared preferences
                }
              },
              child: Text(
                // shows 'English' when Arabic, shows 'عربي' when English
                context.locale == Locale('ar') ? 'English' : 'عربي',
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: sendData, child: Text("submit").tr()),
            ElevatedButton(
              onPressed: () async {
                // read the current language from shared preferences and show as snackbar
                final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                final String? lang = prefs.getString('lang');
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('$lang'.tr())));
              },
              child: Text("readlang").tr(),
            ),
          ],
        ),
      ),
    );
  }
}
