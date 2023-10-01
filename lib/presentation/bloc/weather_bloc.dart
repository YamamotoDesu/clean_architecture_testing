import 'package:clean_architecture_testing/domain/usecases/get_current_weather.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clean_architecture_testing/presentation/bloc/weather_event.dart';
import 'package:clean_architecture_testing/presentation/bloc/weather_state.dart';
import 'package:rxdart/transformers.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final GetCurrentWeatherUseCase _getCurrentWeatherUseCase;
  WeatherBloc(this._getCurrentWeatherUseCase) : super(WeatherEmpty()) {
    on<OnCityChanged>(
      (event, emit) async {
        emit(WeatherLoading());
        final result = await _getCurrentWeatherUseCase.execute(event.cityName);
        result.fold(
          (failure) => emit(WeatherLoadedFailure(message: failure.message)),
          (weatherEntity) => emit(WeatherLoaded(weatherEntity: weatherEntity)),
        );
      },
      transformer: debounce(const Duration(milliseconds: 300)),
    );
  }
}

EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}
