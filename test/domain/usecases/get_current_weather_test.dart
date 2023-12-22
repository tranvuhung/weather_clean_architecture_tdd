import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_clean_architecture_tdd/domain/entities/weather.dart';
import 'package:weather_clean_architecture_tdd/domain/usecases/get_current_weather.dart';

import '../../helpers/test_helpers.mocks.dart';

void main() {
  late GetCurrentWeatherUsecase getCurrentWeatherUsecase;
  late MockWeatherRepository mockWeatherRepository;

  setUp(() {
    mockWeatherRepository = MockWeatherRepository();
    getCurrentWeatherUsecase = GetCurrentWeatherUsecase(mockWeatherRepository);
  });

  const testweatherDetail = WeatherEntity(
    cityName: 'New York',
    main: 'Clouds',
    description: 'few clouds',
    iconCode: '02d',
    temperature: 302.28,
    pressure: 1009,
    humidity: 70,
  );

  const testCitiName = "New York";

  test("Should get current weather detail from the repository", () async {
    // arrange
    when(mockWeatherRepository.getCurrentWeather(testCitiName))
        .thenAnswer((_) async => const Right(testweatherDetail));
    // act
    final result = await getCurrentWeatherUsecase.execute(testCitiName);

    // assert
    expect(result, const Right(testweatherDetail));
  });
}
