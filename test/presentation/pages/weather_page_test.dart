import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:weather_clean_architecture_tdd/core/constants/constants.dart';
import 'package:weather_clean_architecture_tdd/domain/entities/weather.dart';
import 'package:weather_clean_architecture_tdd/presentation/bloc/weather_bloc.dart';
import 'package:weather_clean_architecture_tdd/presentation/bloc/weather_even.dart';
import 'package:weather_clean_architecture_tdd/presentation/bloc/weather_state.dart';
import 'package:weather_clean_architecture_tdd/presentation/pages/weather_page.dart';

class MockWeatherBloc extends MockBloc<WeatherEvent, WeatherState>
    implements WeatherBloc {}

class FakeWeatherEvent extends Fake implements WeatherEvent {}

class FakeWeatherState extends Fake implements WeatherState {}

void main() {
  late MockWeatherBloc mockWeatherBloc;

  setUpAll(() async {
    HttpOverrides.global = null;
    registerFallbackValue(FakeWeatherState());
    registerFallbackValue(FakeWeatherEvent());

    final di = GetIt.instance;
    di.registerFactory(() => mockWeatherBloc);
  });

  setUp(() => {mockWeatherBloc = MockWeatherBloc()});

  const tWeather = WeatherEntity(
    cityName: 'Hanoi',
    main: 'Clouds',
    description: 'few clouds',
    iconCode: '02d',
    temperature: 291.15,
    pressure: 1027,
    humidity: 25,
  );

  Widget makeTestableWidget(Widget body) {
    return BlocProvider<WeatherBloc>.value(
      value: mockWeatherBloc,
      child: MaterialApp(
        home: body,
      ),
    );
  }

  testWidgets(
    'text field should trigger state to change from empty to loading',
    (WidgetTester tester) async {
      // arrange
      when(() => mockWeatherBloc.state).thenReturn(WeatherEmpty());

      // act
      await tester.pumpWidget(makeTestableWidget(const WeatherPage()));
      await tester.enterText(find.byType(TextField), 'Hanoi');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // assert
      verify(() => mockWeatherBloc.add(const OnCityChanged('Hanoi'))).called(1);
      expect(find.byType(TextField), equals(findsOneWidget));
    },
  );

  testWidgets(
    'should show progress indicator when state is loading',
    (WidgetTester tester) async {
      // arrange
      when(() => mockWeatherBloc.state).thenReturn(WeatherLoading());

      // act
      await tester.pumpWidget(makeTestableWidget(const WeatherPage()));

      // assert
      expect(find.byType(CircularProgressIndicator), equals(findsOneWidget));
    },
  );

  testWidgets(
    'should show widget contain weather data when state is has data',
    (WidgetTester tester) async {
      // arrange
      when(() => mockWeatherBloc.state)
          .thenReturn(const WeatherHasData(tWeather));

      // act
      await tester.pumpWidget(makeTestableWidget(const WeatherPage()));
      // await tester.runAsync(() async {
      //   final HttpClient client = HttpClient();
      //   await client.getUrl(Uri.parse(Urls.weatherIcon('02d')));
      // });
      await tester.pumpAndSettle();

      // assert
      expect(find.byKey(const Key('weather_data')), equals(findsOneWidget));
    },
  );

  testWidgets(
    'should show weather icon when state is has data',
    (WidgetTester tester) async {
      await tester.runAsync(() async {
        final HttpClient client = HttpClient();
        await client.getUrl(Uri.parse(Urls.weatherIcon('02d')));
      });
    },
  );
}
