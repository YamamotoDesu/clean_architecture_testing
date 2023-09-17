import 'dart:io';

import 'package:clean_architecture_testing/core/error/exception.dart';
import 'package:clean_architecture_testing/core/error/failure.dart';
import 'package:clean_architecture_testing/data/models/weather_model.dart';
import 'package:clean_architecture_testing/data/repositories/weather_repository_impl.dart';
import 'package:clean_architecture_testing/domain/entities/weather.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';

import '../../helpers/test_helper.mocks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MockWeatherRemoteDataSource mockWeatherRemoteDataSource;
  late WeatherRepositoryImpl weatherRepositoryImpl;

  setUp(() {
    mockWeatherRemoteDataSource = MockWeatherRemoteDataSource();
    weatherRepositoryImpl = WeatherRepositoryImpl(
      weatherRemoteDataSource: mockWeatherRemoteDataSource,
    );
  });

  const testWeatherModel = WeatherModel(
    cityName: 'Tokyo',
    main: 'Clear',
    description: 'clear sky',
    iconCode: '01n',
    temperature: 292.87,
    pressure: 1012,
    humidity: 70,
  );

  const testWeatherEntity = WeatherEntity(
    cityName: 'Tokyo',
    main: 'Clear',
    description: 'clear sky',
    iconCode: '01n',
    temperature: 292.87,
    pressure: 1012,
    humidity: 70,
  );

  const testCityName = 'Tokyo';

  group('get current weather', () {
    test(
      'should return current weather when a call to data source is success',
      () async {
        // arrange
        when(mockWeatherRemoteDataSource.getCurrentWeather(testCityName))
            .thenAnswer((_) async => testWeatherModel);

        // act
        final result =
            await weatherRepositoryImpl.getCurrentWeather(testCityName);

        // assert
        expect(result, equals(const Right(testWeatherEntity)));
      },
    );

    test(
      'should return current weather when a call to data source is unsuccessful',
      () async {
        // arrange
        when(mockWeatherRemoteDataSource.getCurrentWeather(testCityName))
            .thenThrow(ServerException());

        // act
        final result =
            await weatherRepositoryImpl.getCurrentWeather(testCityName);

        // assert
        expect(
            result,
            equals(const Left(
                ServerFailure('An error occurred on the server side.'))));
      },
    );

    test(
      'should return server failure weather when the device is offline',
      () async {
        // arrange
        when(mockWeatherRemoteDataSource.getCurrentWeather(testCityName))
            .thenThrow(
                const SocketException('Failed to connect to the network.'));

        // act
        final result =
            await weatherRepositoryImpl.getCurrentWeather(testCityName);

        // assert
        expect(
            result,
            equals(const Left(
                ConnectionFailure('Failed to connect to the network.'))));
      },
    );
  });
}
