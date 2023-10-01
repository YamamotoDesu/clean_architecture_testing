import 'package:clean_architecture_testing/domain/entities/weather.dart';
import 'package:equatable/equatable.dart';

abstract class WeatherState extends Equatable {
  const WeatherState();

  @override
  List<Object?> get props => [];
}

class WeatherEmpty extends WeatherState {}

class WeatherLoading extends WeatherState {}

class WeatherLoaded extends WeatherState {
  final WeatherEntity weatherEntity;

  const WeatherLoaded({
    required this.weatherEntity,
  });

  @override
  List<Object?> get props => [weatherEntity];
}

class WeatherLoadedFailure extends WeatherState {
  final String message;

  const WeatherLoadedFailure({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
