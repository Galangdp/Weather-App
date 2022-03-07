import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//Bisa Begini
void main(List<String> args) => runApp(WeatherApp());

// void main(List<String> args) {
//   runApp(WeatherApp());
// }

class WeatherApp extends StatefulWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  State<WeatherApp> createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  int temprature = 0;
  String location = "Jakarta";
  String weather = 'clear';
  int woeid = 1047378;
  String abbrevation = 'c';

  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';

  String locationApiUrl = 'https://www.metaweather.com/api/location/';

  Future<void> fetchSearch(String input) async {
    //Di tambahin async karena dia ada hubungannya
    var searchResult = await http.get(
        Uri.parse(searchApiUrl + input)); //input dari parameter searchResult
    var result = json.decode(searchResult.body)[0];

    setState(() {
      //Hanya ada di stateful widget(STF)
      location = result['title'];
      woeid = result['woeid'];
    }); //Gunanya untuk mengganti - ganti (?query= ) apa apa
  }

  Future<void> fetchLocation() async {
    //ga pake yang di dalam parameter karena sudah di panggil di function pertama
    var locationResult =
        await http.get(Uri.parse(locationApiUrl + woeid.toString()));
    var result = json.decode((locationResult.body));
    var consolidated_weather = result[
        'consolidated_weather']; //Buat ngakses array 1 nya itu karena array 0 nya ada json object
    var data = consolidated_weather[
        0]; //Akses 0 karena udah di dalam array 1 nya (json Object)

    setState(() {
      temprature = data['the_temp'].round();
      weather = data['weather_state_name']
          .replaceAll(' ', '')
          .toLowerCase(); //REPLACE ALL Buat bikin dari Light Rain jadi bisa lightrain
      abbrevation = data['weather_state_abbr'];
    }); //Berubah Backgorund Ketika Di Sini
  }

  void onTextFieldSubmitted(String input) {
    fetchLocation();
    fetchSearch(input);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/$weather.png'), fit: BoxFit.cover)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment
                .spaceEvenly, //Sejajar jarak nya atas bawah karena main axis
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Center(
                    child: Image.network(
                      'https://www.metaweather.com/static/img/weather/png/' +
                          abbrevation +
                          '.png',
                      width: 100,
                    ),
                  ),
                  Center(
                    child: Text(
                      temprature.toString() +
                          '°C', //From Int toString     Int Dari Database Di masukin ke variable truss di ubah menggunakan toString()
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 60,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      location,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                width: 300,
                child: TextField(
                  onSubmitted: (String input) {
                    onTextFieldSubmitted(input);
                  },
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                  decoration: InputDecoration(
                      hintText: 'Seach another location...',
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      prefixIcon: Icon(Icons.search)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
