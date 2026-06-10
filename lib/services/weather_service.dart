import 'package:dio/dio.dart';

class WeatherService {
  final Dio _dio = Dio();
  final String _apiKey = '17eaeeeb3af1db21970dfa6307ae54d9'; 

  Future<Map<String, dynamic>> getWeather(String city) async {
    try {
      final response = await _dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'q': city,
          'appid': _apiKey,
          'units': 'metric', // celsius
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Failed to get weather: ${e.message}');
    }
  }
}
