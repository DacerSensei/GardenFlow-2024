import 'package:http/http.dart' as http;
import 'dart:convert';

class WeatherApiClient {
  final String baseUrl =
      'https://api.weatherapi.com/v1/current.json?key=8c8e398fdc994ecfb7e50000232806&q=Pasig City';

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse;
      } else {
        throw Exception('Failed to fetch weather data');
      }
    } catch (e) {
      throw Exception('Failed to connect to the weather API');
    }
  }
}
