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
      startLocale: const Locale('ar'),
    ),
  );
}

// CHANGED: StatelessWidget → StatefulWidget so it can hold _isDarkMode
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false; // MOVED here from HomePage

  @override
  void initState() {
    super.initState();
    _loadTheme(); // read the notebook when app opens
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance(); // open notebook
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false; // read value
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(), // ADDED — light mode colors
      darkTheme: ThemeData.dark(), // ADDED — dark mode colors
      // ADDED — this is what actually switches the app theme
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomePage(
        isDarkMode: _isDarkMode, // ADDED — pass value down to HomePage
        onThemeToggle: () async {
          // ADDED — pass toggle action down to HomePage
          final prefs = await SharedPreferences.getInstance();
          setState(() {
            _isDarkMode = !_isDarkMode; // flip the value
          });
          await prefs.setBool('isDarkMode', _isDarkMode); // save to notebook
        },
      ),
    );
  }
}

// CHANGED: added isDarkMode and onThemeToggle parameters
class HomePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const HomePage({
    super.key,
    required this.isDarkMode,
    required this.onThemeToggle,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  int _submitCount = 0;
  int _studentCount = 0;
  bool _hasSubmitted = false; // false = not submitted yet
  String _submittedName = '';
  String _submittedAge = '';
  // REMOVED: _isDarkMode, _loadTheme, _saveTheme — they moved to MyApp

  Future<void> sendData() async {
    await FirebaseFirestore.instance.collection('students').add({
      'name': nameController.text,
      'age': ageController.text,
      'time': DateTime.now().toString(),
    });

    setState(() {
      _submittedName = nameController.text; // save name before clearing
      _submittedAge = ageController.text; // save age before clearing
      _submitCount++;
      _studentCount++;
      _hasSubmitted = true;
    });
    nameController.clear();
    ageController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
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
            Text(
              "students".plural(
                _studentCount,
                format: NumberFormat.decimalPattern(),
              ),
            ),
            if (_hasSubmitted)
              Text('welcome'.tr(args: [_submittedName, _submittedAge])),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // language button
                ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    if (context.locale == Locale('ar')) {
                      context.setLocale(Locale('en'));
                      prefs.setString('lang', 'en');
                    } else {
                      context.setLocale(Locale('ar'));
                      prefs.setString('lang', 'ar');
                    }
                  },
                  child: Text(
                    context.locale == Locale('ar') ? 'English' : 'عربي',
                  ),
                ),
                const SizedBox(
                  width: 10,
                ), // width not height — horizontal space
                // dark mode button
                ElevatedButton(
                  onPressed: widget.onThemeToggle,
                  child: Text(widget.isDarkMode ? 'Light Mode' : 'Dark Mode'),
                ),
                const SizedBox(
                  width: 10,
                ), // width not height — horizontal space
                // submit button
                ElevatedButton(onPressed: sendData, child: Text("submit").tr()),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                final String? lang = prefs.getString('lang');
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('$lang'.tr())));
              },
              child: Text("readlang").tr(),
            ),
            Image.asset(
              'assets/images/image1.jpg', // the path to your image
              width: 200, // how wide
              height: 200, // how tall
              fit: BoxFit.cover, // fills the space without stretching
            ),
            const SizedBox(height: 20),
            Image.asset(
              'assets/images/image2.jpeg', // the path to your image
              width: 200, // how wide
              height: 200, // how tall
              fit: BoxFit.cover, // fills the space without stretching
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
