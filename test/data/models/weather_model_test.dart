import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:weather_clean_architecture_tdd/data/models/weather_model.dart';
import 'package:weather_clean_architecture_tdd/domain/entities/weather.dart';

import '../../helpers/dummy_data/json_reader.dart';

void main() {
  const testWeatherModel = WeatherModel(
    cityName: 'Hanoi',
    main: 'Clouds',
    description: 'few clouds',
    iconCode: '02d',
    temperature: 291.15,
    pressure: 1027,
    humidity: 25,
  );
  test("should be subclass of weather entity", () async {
    expect(testWeatherModel, isA<WeatherEntity>());
  });

  test("should return a valid model from json", () async {
    final Map<String, dynamic> jsonMap =
        json.decode(readJson('helpers/dummy_data/dummy_weather_response.json'));

    final result = WeatherModel.fromJson(jsonMap);

    expect(result, equals(testWeatherModel));
  });

  test(
    'should return a json map containing proper data',
    () async {
      // act
      final result = testWeatherModel.toJson();

      // assert
      final expectedJsonMap = {
        'weather': [
          {"main": "Clouds", "description": "few clouds", "icon": "02d"}
        ],
        'main': {
          "temp": 291.15,
          "pressure": 1027,
          "humidity": 25,
        },
        'name': 'Hanoi',
      };

      expect(result, equals(expectedJsonMap));
    },
  );
}
