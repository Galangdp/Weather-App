import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  int? temprature;
  String location = "Jakarta";
  String weather = 'clear';
  int woeid = 1047378;
  String abbreviation = 'c';

  String errormessage = '';

  //Buat var untuk list template nya
  var minTempratureForecast = List.filled(7, 0);
  var maxTempratureForecast = List.filled(7, 0);
  var abbrevationForecast = List.filled(7, '');

  String searchApiUrl =
      'https://www.metaweather.com/api/location/search/?query=';

  String locationApiUrl = 'https://www.metaweather.com/api/location/';

  @override
  void initState() {
    super.initState();
    fetchLocation();
    fetchLocationDay();
  } // Buat nge get data

  Future<void> fetchSearch(String input) async {
    try {
      //Di tambahin async karena dia ada hubungannya
      var searchResult = await http.get(
          Uri.parse(searchApiUrl + input)); //input dari parameter searchResult
      var result = json.decode(searchResult.body)[0];

      setState(() {
        //Hanya ada di stateful widget(STF)
        location = result['title'];
        woeid = result['woeid'];
        errormessage = '';
      }); //Gunanya untuk mengganti - ganti (?query= ) apa apa
    } catch (error) {
      errormessage =
          "Maaf kita tidak ada data untuk kota itu, coba kota yang lain";
    }
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
      abbreviation = data['weather_state_abbr'];
    }); //Berubah Backgorund Ketika Di Sini
  }

  Future<void> fetchLocationDay() async {
    var today = DateTime.now();
    for (var i = 0; i < 7; i++) {
      var locationDayResult = await http.get(Uri.parse(locationApiUrl +
          woeid.toString() +
          '/' +
          DateFormat('y/M/d')
              .format(today.add(Duration(days: i + 1)))
              .toString())); //Nambahin enpoint
      var result = jsonDecode(locationDayResult.body);
      var data = result[0];

      setState(() {
        minTempratureForecast[i] = data['min_temp'].round();
        maxTempratureForecast[i] = data['max_temp'].round();
        abbrevationForecast[i] = data['weather_state_abbr'];
      });
    }
  } //ini lanjutan var template (Logic)

  void onTxtFieldSubmitted(String input) async {
    await fetchLocation();
    await fetchSearch(input);
    await fetchLocationDay;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/$weather.png'), fit: BoxFit.cover)),
        child: temprature == null
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Scaffold(
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
                                abbreviation +
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
                    Padding(
                        padding: EdgeInsets.only(top: 50),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 0; i < 7; i++)
                                forecastElement(
                                    i + 1,
                                    abbrevationForecast[i],
                                    maxTempratureForecast[i],
                                    minTempratureForecast[i]),
                            ],
                          ),
                        )),
                    Column(
                      children: [
                        Container(
                          width: 300,
                          child: TextField(
                            onSubmitted: (String input) {
                              onTxtFieldSubmitted(input);
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
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            errormessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: Platform.isAndroid ? 15 : 20),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

Widget forecastElement(
    daysFromNow, abbreviation, maxTemprature, minTemprature) {
  var now = DateTime.now();
  var oneDayfromNow = now.add(Duration(days: daysFromNow));
  return Padding(
    padding: EdgeInsets.only(
      left: 16,
    ),
    child: Container(
      decoration: BoxDecoration(
          color: Color.fromRGBO(205, 212, 228, 0.2),
          borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              DateFormat.E().format(oneDayfromNow),
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
              ),
            ),
            Text(
              DateFormat.MMMd().format(oneDayfromNow),
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: 16,
              ),
              child: Image.network(
                'https://www.metaweather.com/static/img/weather/png/' +
                    abbreviation +
                    '.png',
                width: 100,
              ),
            ),
            Text(
              'High ' + maxTemprature.toString() + '°C',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            Text(
              'Low ' + minTemprature.toString() + '°C',
              style: TextStyle(color: Colors.white, fontSize: 20),
            )
          ],
        ),
      ),
    ),
  );
}
