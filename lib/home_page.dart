import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cubits/counter_cubit.dart';
import 'cubits/theme_cubit.dart';
import 'cubits/student_cubit.dart';
import '../services/weather_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final _weatherService = WeatherService();
  String temperature = '';
  String description = '';
  final cityController = TextEditingController();
  // 👆 your original controllers, exactly the same

  void fetchWeather() async {
    if (cityController.text.trim().isEmpty) return;
    final data = await _weatherService.getWeather(cityController.text);
    setState(() {
      temperature = '${data['main']['temp']}°C';
      description = data['weather'][0]['description'];
    });
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("title".tr())),
      // 👆 your original appBar, exactly the same
      body: Column(
        children: [
          // ── COUNTER SECTION ──────────────────────
          // your original counter Row
          // only change: setState → Cubit
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cityController,
                    decoration: InputDecoration(labelText: 'Enter city'),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => fetchWeather(),
                  child: Text('Search'),
                ),
              ],
            ),
          ),
          Text(temperature, style: TextStyle(fontSize: 40)),
          Text(description, style: TextStyle(fontSize: 20)),
          BlocBuilder<CounterCubit, int>(
            builder: (context, counter) {
              return Row(
                children: [
                  IconButton(
                    onPressed: () => context.read<CounterCubit>().increment(),
                    icon: Icon(Icons.add),
                  ),
                  Text("$counter"),
                  IconButton(
                    onPressed: () => context.read<CounterCubit>().decrement(),
                    icon: Icon(Icons.remove),
                  ),
                ],
              );
            },
          ),

          // ── EVERYTHING ELSE ───────────────────────
          // your original Padding + Column, exactly the same
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // your original text fields
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

                // student count and welcome text
                // only change: setState → Cubit
                BlocBuilder<StudentCubit, StudentState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        Text(
                          "students".plural(
                            state.studentCount,
                            format: NumberFormat.decimalPattern(),
                          ),
                        ),
                        if (state.hasSubmitted)
                          Text(
                            'welcome'.tr(
                              args: [state.submittedName, state.submittedAge],
                            ),
                          ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // your original buttons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // language button — exactly the same
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
                    const SizedBox(width: 10),

                    // dark mode button
                    // only change: widget.onThemeToggle → Cubit
                    BlocBuilder<ThemeCubit, bool>(
                      builder: (context, isDarkMode) {
                        return ElevatedButton(
                          onPressed: () =>
                              context.read<ThemeCubit>().toggleTheme(),
                          child: Text(isDarkMode ? 'Light Mode' : 'Dark Mode'),
                        );
                      },
                    ),
                    const SizedBox(width: 10),

                    // submit button
                    // only change: sendData() → Cubit
                    BlocBuilder<StudentCubit, StudentState>(
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: state.isLoading
                              ? null
                              : () {
                                  context.read<StudentCubit>().submitStudent(
                                    nameController.text,
                                    ageController.text,
                                  );
                                  nameController.clear();
                                  ageController.clear();
                                },
                          child: state.isLoading
                              ? CircularProgressIndicator()
                              : Text("submit").tr(),
                        );
                      },
                    ),
                  ],
                ),

                // read language button — exactly the same
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

                // your original images — exactly the same
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/image2.jpeg',
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
