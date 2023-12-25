import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_clean_architecture_tdd/core/error/exception.dart';
import 'package:weather_clean_architecture_tdd/core/error/failure.dart';
import 'package:weather_clean_architecture_tdd/data/models/weather_model.dart';
import 'package:weather_clean_architecture_tdd/data/repositories/weather_repository_impl.dart';

import '../../helpers/test_helpers.mocks.dart';

void main() {
  late MockWeatherRemoteDataSource mockWeatherRemoteDataSource;
  late WeatherRepositoryImpl weatherRepositoryImpl;

  setUp(() {
    mockWeatherRemoteDataSource = MockWeatherRemoteDataSource();
    weatherRepositoryImpl = WeatherRepositoryImpl(
        weatherRemoteDataSource: mockWeatherRemoteDataSource);
  });

  const testWeatherModel = WeatherModel(
    cityName: 'Hanoi',
    main: 'Clouds',
    description: 'few clouds',
    iconCode: '02d',
    temperature: 291.15,
    pressure: 1027,
    humidity: 25,
  );

  group("get current weather", () {
    const String citiName = 'Hanoi';

    test(
        'should return current weather when a call to data source is successful',
        () async {
      // arrange
      when(mockWeatherRemoteDataSource.getCurrentWeather(citiName))
          .thenAnswer((_) async => testWeatherModel);
      // act
      final result = await weatherRepositoryImpl.getCurrentWeather(citiName);

      // assert
      expect(result, equals(const Right(testWeatherModel)));
    });

    test(
        'should return server failure when a call to data source is unsuccessful',
        () async {
      // arrange
      when(mockWeatherRemoteDataSource.getCurrentWeather(citiName))
          .thenThrow(ServerException());
      // act
      final result = await weatherRepositoryImpl.getCurrentWeather(citiName);

      // assert
      verify(mockWeatherRemoteDataSource.getCurrentWeather(citiName));
      expect(result,
          equals(const Left(ServerFailure('Cannot get data from server'))));
    });

    test('should return connection failure when the device has no internet',
        () async {
      // arrange
      when(mockWeatherRemoteDataSource.getCurrentWeather(citiName))
          .thenThrow(const SocketException('Failed to connect to the network'));
      // act
      final result = await weatherRepositoryImpl.getCurrentWeather(citiName);

      // assert
      verify(mockWeatherRemoteDataSource.getCurrentWeather(citiName));
      expect(
          result,
          equals(const Left(
              ConnectionFailure('Failed to connect to the network'))));
    });
  });
}
