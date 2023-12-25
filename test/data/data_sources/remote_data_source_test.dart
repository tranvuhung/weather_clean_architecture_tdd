import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_clean_architecture_tdd/core/constant.dart';
import 'package:weather_clean_architecture_tdd/core/exception.dart';
import 'package:weather_clean_architecture_tdd/data/data_sources/remote_data_source.dart';
import 'package:weather_clean_architecture_tdd/data/models/weather_model.dart';

import '../../helpers/dummy_data/json_reader.dart';
import '../../helpers/test_helpers.mocks.dart';

import 'package:http/http.dart' as http;

void main() {
  late MockHttpClient mockHttpClient;
  late WeatherRemoteDataSourceImpl dataSource;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = WeatherRemoteDataSourceImpl(client: mockHttpClient);
  });

  group("get current weather", () {
    const tCityName = 'Hanoi';
    final tWeatherModel = WeatherModel.fromJson(json
        .decode(readJson('helpers/dummy_data/dummy_weather_response.json')));

    test(
      'should return weather model when the response code is 200',
      () async {
        // arrange
        when(
          mockHttpClient.get(Uri.parse(Urls.currentWeatherByName(tCityName))),
        ).thenAnswer(
          (_) async => http.Response(
              readJson('helpers/dummy_data/dummy_weather_response.json'), 200),
        );

        // act
        final result = await dataSource.getCurrentWeather(tCityName);

        // assert
        expect(result, equals(tWeatherModel));
      },
    );

    test(
      'should throw a server exception when the response code is 404 or other',
      () async {
        // arrange
        when(
          mockHttpClient.get(Uri.parse(Urls.currentWeatherByName(tCityName))),
        ).thenAnswer(
          (_) async => http.Response('Not found', 404),
        );

        // act
        final call = dataSource.getCurrentWeather(tCityName);

        // assert
        expect(() => call, throwsA(isA<ServerException>()));
      },
    );
  });
}
