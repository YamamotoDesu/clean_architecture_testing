import 'dart:io';

import 'package:clean_architecture_testing/core/error/exception.dart';
import 'package:clean_architecture_testing/core/error/failure.dart';
import 'package:clean_architecture_testing/data/data_sources/remote_data_source.dart';
import 'package:clean_architecture_testing/domain/entities/weather.dart';
import 'package:clean_architecture_testing/domain/repositories/weather_repository.dart';
import 'package:dartz/dartz.dart';

class WeatherRepositoryImpl extends WeatherRepository {
  final WeatherRemoteDataSource weatherRemoteDataSource;
  WeatherRepositoryImpl({
    required this.weatherRemoteDataSource,
  });

  @override
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(
      String cityName) async {
    try {
      final result = await weatherRemoteDataSource.getCurrentWeather(cityName);
      return Right(result.toEntity());
    } on ServerException {
      return const Left(ServerFailure('An error occurred on the server side.'));
    } on SocketException {
      return const Left(ConnectionFailure('Failed to connect to the network.'));
    }
  }
}
