import 'package:bloc_test/bloc_test.dart';
import 'package:clean_architecture_testing/core/error/failure.dart';
import 'package:clean_architecture_testing/domain/entities/weather.dart';
import 'package:clean_architecture_testing/presentation/bloc/weather_bloc.dart';
import 'package:clean_architecture_testing/presentation/bloc/weather_event.dart';
import 'package:clean_architecture_testing/presentation/bloc/weather_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  late MockGetCurrentWeatherUseCase mockGetCurrentWeatherUseCase;
  late WeatherBloc weatherBloc;

  setUp(() {
    mockGetCurrentWeatherUseCase = MockGetCurrentWeatherUseCase();
    weatherBloc = WeatherBloc(mockGetCurrentWeatherUseCase);
  });

  const testWeather = WeatherEntity(
    cityName: 'London',
    temperature: 10,
    humidity: 10,
    description: 'few clouds',
    iconCode: '02d',
    main: 'Clouds',
    pressure: 1009,
  );

  const testCityName = 'London';

  test('initial state should be WeatherEmpty', () {
    expect(weatherBloc.state, WeatherEmpty());
  });

  blocTest<WeatherBloc, WeatherState>(
    'should emit [WeatherLoading, WeatherLoaded] when data is gotten successfully',
    build: () {
      when(mockGetCurrentWeatherUseCase.execute(testCityName))
          .thenAnswer((_) async => const Right(testWeather));
      return weatherBloc;
    },
    act: (bloc) => bloc.add(const OnCityChanged(cityName: testCityName)),
    wait: const Duration(milliseconds: 300),
    expect: () => [
      WeatherLoading(),
      const WeatherLoaded(weatherEntity: testWeather),
    ],
  );

  blocTest(
    'should emit [WeatherLoading, WeatherLoadFaiure] when get data is failure',
    build: () {
      when(mockGetCurrentWeatherUseCase.execute(testCityName))
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
      return weatherBloc;
    },
    act: (bloc) => bloc.add(const OnCityChanged(cityName: testCityName)),
    wait: const Duration(milliseconds: 300),
    expect: () => [
      WeatherLoading(),
      const WeatherLoadedFailure(message: 'Server Failure'),
    ],
  );
}
