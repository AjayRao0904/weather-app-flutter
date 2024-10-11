import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:weather_app/additional_info.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Import the intl package

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      final res = await http.get(
        Uri.parse(
            'https://api.openweathermap.org/data/2.5/forecast?q=Bengaluru&APPID=95a1302a191788803980a65efb9e5d5b'),
      );
      final data = jsonDecode(res.body);

      if (data["cod"] != '200') {
        throw 'Error Occurred';
      }

      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  String formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat.Hm().format(dateTime); // Format the time as "HH:mm"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            )),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No data available'));
          }

          final data = snapshot.data!;
          final currentWeather = data['list'][0]['main'] ;
          final weatherDetails = data['list'][0]['weather'][0];
          final windDetails = data['list'][0]['wind'];

           double currentTemp = currentWeather['temp'] ?? 0.0;
          final String currentSky = weatherDetails['main'] ?? 'Unknown';
          final int currentPressure = currentWeather['pressure'] ?? 0;
          final double windSpeed = windDetails['speed'] ?? 0.0;
          final int humidity = currentWeather['humidity'] ?? 0;

          currentTemp = currentTemp-273;
          currentTemp = currentTemp.floorToDouble();
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp°C',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.wb_sunny,
                                size: 64,
                              ),
                              SizedBox(height: 16),
                              Text(
                                currentSky,
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 16),
                // weather forecast cards
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(5, (i) {
                      final forecast = data['list'][i + 1];
                      final forecastMain = forecast['main'] ?? {};
                      final forecastWeather = forecast['weather'][0] ?? {};
                      final forecastTemp = forecastMain['temp'] ?? 0.0;
                      final forecastCondition = forecastWeather['main'] ?? 'Unknown';
                      final forecastIcon = forecastCondition == 'Clouds' || forecastCondition == 'Rain'
                          ? Icons.cloud
                          : Icons.wb_sunny;

                      return HourlyForecastItem(
                        icon: forecastIcon,
                        timeV: formatTime(forecast['dt']),
                        label: forecastTemp.toString(),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 25),
                // additional info
                Text(
                  'Additional Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AdditionalInfo(
                      icon: Icons.water_drop,
                      label: 'Humidity',
                      value: humidity.toString(),
                    ),
                    AdditionalInfo(
                      icon: Icons.air,
                      label: 'Wind Speed',
                      value: windSpeed.toString(),
                    ),
                    AdditionalInfo(
                      icon: Icons.beach_access,
                      label: 'Pressure',
                      value: currentPressure.toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
