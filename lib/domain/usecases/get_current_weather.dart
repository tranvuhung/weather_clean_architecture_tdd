import 'package:dartz/dartz.dart';
import 'package:weather_clean_architecture_tdd/core/error/failure.dart';
import 'package:weather_clean_architecture_tdd/domain/entities/weather.dart';
import 'package:weather_clean_architecture_tdd/domain/repositories/weather_repository.dart';

class GetCurrentWeatherUsecase {
  final WeatherRepository weatherRepository;

  GetCurrentWeatherUsecase(this.weatherRepository);

  Future<Either<Failure, WeatherEntity>> execute(String citiName) {
    return weatherRepository.getCurrentWeather(citiName);
  }
}
