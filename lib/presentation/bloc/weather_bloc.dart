import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weather_clean_architecture_tdd/domain/usecases/get_current_weather.dart';
import 'package:weather_clean_architecture_tdd/presentation/bloc/weather_even.dart';
import 'package:weather_clean_architecture_tdd/presentation/bloc/weather_state.dart';
import 'package:rxdart/rxdart.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetCurrentWeatherUsecase _getCurrentWeatherUsecase;

  WeatherBloc(this._getCurrentWeatherUsecase) : super(WeatherEmpty()) {
    on<OnCityChanged>(
      (event, emit) async {
        final citiName = event.cityName;

        emit(WeatherLoading());

        final result = await _getCurrentWeatherUsecase.execute(citiName);
        result.fold((failure) {
          emit(WeatherError(failure.message));
        }, (data) {
          emit(WeatherHasData(data));
        });
      },
      transformer: debounce(const Duration(milliseconds: 500)),
    );
  }

  EventTransformer<T> debounce<T>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
  }
}
