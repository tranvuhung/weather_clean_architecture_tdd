import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:weather_clean_architecture_tdd/core/error/failure.dart';
import 'package:weather_clean_architecture_tdd/domain/entities/weather.dart';
import 'package:weather_clean_architecture_tdd/presentation/bloc/weather_bloc.dart';
import 'package:weather_clean_architecture_tdd/presentation/bloc/weather_even.dart';
import 'package:weather_clean_architecture_tdd/presentation/bloc/weather_state.dart';
import 'package:bloc_test/bloc_test.dart';

import '../../helpers/test_helpers.mocks.dart';

void main() {
  late MockGetCurrentWeatherUsecase mockGetCurrentWeatherUsecase;
  late WeatherBloc weatherBloc;

  setUp(() {
    mockGetCurrentWeatherUsecase = MockGetCurrentWeatherUsecase();
    weatherBloc = WeatherBloc(mockGetCurrentWeatherUsecase);
  });

  const testweatherDetail = WeatherEntity(
    cityName: 'Hanoi',
    main: 'Clouds',
    description: 'few clouds',
    iconCode: '02d',
    temperature: 291.15,
    pressure: 1027,
    humidity: 25,
  );

  const testCitiName = 'Hanoi';

  test(
    'initial state should be empty',
    () {
      expect(weatherBloc.state, WeatherEmpty());
    },
  );

  blocTest<WeatherBloc, WeatherState>(
    'should emit [loading, has data] when data is gotten successfully',
    build: () {
      when(mockGetCurrentWeatherUsecase.execute(testCitiName))
          .thenAnswer((_) async => const Right(testweatherDetail));
      return weatherBloc;
    },
    act: (bloc) => bloc.add(const OnCityChanged(testCitiName)),
    wait: const Duration(milliseconds: 500),
    expect: () => <WeatherState>[
      WeatherLoading(),
      const WeatherHasData(testweatherDetail)
    ],
    verify: (bloc) {
      verify(mockGetCurrentWeatherUsecase.execute(testCitiName));
    },
  );

  blocTest<WeatherBloc, WeatherState>(
    'should emit [loading, error] when get data is unsuccessful',
    build: () {
      when(mockGetCurrentWeatherUsecase.execute(testCitiName))
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
      return weatherBloc;
    },
    act: (bloc) => bloc.add(const OnCityChanged(testCitiName)),
    wait: const Duration(milliseconds: 500),
    expect: () => <WeatherState>[
      WeatherLoading(),
      const WeatherError('Server Failure'),
    ],
    verify: (bloc) {
      verify(mockGetCurrentWeatherUsecase.execute(testCitiName));
    },
  );
}
