import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'weather.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: CityListScreen(),
    );
  }
}

class CityListScreen extends StatelessWidget {
  final List<String> cities = [
    'Bangkok',
    'London',
    'Tokyo',
    'New York',
    'Chicago'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: cities.length,
        itemBuilder: (context, index) {
          return Card(
            color: Colors.purple[200],
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              title: Text(
                cities[index],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.purple[700]),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeatherDetailScreen(city: cities[index]),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class WeatherDetailScreen extends StatefulWidget {
  final String city;
  const WeatherDetailScreen({required this.city, super.key});

  @override
  State<WeatherDetailScreen> createState() => _WeatherDetailScreenState();
}

class _WeatherDetailScreenState extends State<WeatherDetailScreen> {
  late Future<WeatherResponse> weatherData;

  @override
  void initState() {
    super.initState();
    weatherData = getData(widget.city);
  }

  Future<WeatherResponse> getData(String city) async {
    var client = http.Client();
    try {
      var response = await client.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?q=$city&units=metric&appid=6378ac581297b40ccb71e6f85e65e17a'));
      if (response.statusCode == 200) {
        return WeatherResponse.fromJson(
            jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception("Failed to load data");
      }
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.city),
        centerTitle: true,
      ),
      body: Center(
        child: FutureBuilder<WeatherResponse>(
          future: weatherData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Colors.purple[100],
                  elevation: 4.0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${snapshot.data!.name}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Current Temperature: ${snapshot.data!.main!.temp}°C',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Min Temperature: ${snapshot.data!.main!.tempMin}°C',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Max Temperature: ${snapshot.data!.main!.tempMax}°C',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Pressure: ${snapshot.data!.main!.pressure} hPa',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Humidity: ${snapshot.data!.main!.humidity}%',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Sea Level: ${snapshot.data!.main!.seaLevel} hPa',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Clouds: ${snapshot.data!.clouds!.all}%',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Rain (last 1 hour): ${snapshot.data!.rain?.d1h ?? 0} mm',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          'Sunset: ${DateTime.fromMillisecondsSinceEpoch(snapshot.data!.sys!.sunset! * 1000)}',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(height: 10),
                        Image.network(
                          'http://openweathermap.org/img/wn/${snapshot.data!.weather![0].icon}@2x.png',
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
