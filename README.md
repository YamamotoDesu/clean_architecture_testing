# 🚧 Flutter Clean Architecutre & TDD

## [Add Packages & Create Folders | PART1](https://www.youtube.com/watch?v=Nh88g4FqQyY&list=WL&index=15)

### Project Tree
```dart
- lib
  - core
    - error
      - failure.dart
  - data
  - domain
    - entities
      - weather.dart
    - repositories
      - weather_repository.dart
    - usecases
      - get_current_weather.dart
  - main.dart
  - presentation
```

### 📦️ Configuration Settings
pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter

  cupertino_icons: ^1.0.2
  dartz: ^0.10.1
  equatable: ^2.0.3
  flutter_bloc: ^8.0.1
  get_it: ^7.2.0
  http: ^0.13.3
  rxdart: ^0.27.3

dev_dependencies:
  bloc_test: ^9.0.2
  build_runner: ^2.1.2
  flutter_test:
    sdk: flutter
  mockito: ^5.0.15
  mocktail: ^0.2.0
  flutter_lints: ^2.0.0
```

### 🏗️ Prepare clean architecture classes for testing
lib/domain/entities/weather.dart
```dart
import 'package:equatable/equatable.dart';

class WeatherEntity extends Equatable {
  const WeatherEntity({
    required this.cityName,
    required this.main,
    required this.description,
    required this.iconCode,
    required this.temperature,
    required this.pressure,
    required this.humidity,
  });

  final String cityName;
  final String main;
  final String description;
  final String iconCode;
  final double temperature;
  final int pressure;
  final int humidity;

  @override
  List<Object?> get props => [
        cityName,
        main,
        description,
        iconCode,
        temperature,
        pressure,
        humidity,
      ];
}
```

lib/domain/repositories/weather_repository.dart
```dart

import 'package:clean_architecture_testing/core/error/failure.dart';
import 'package:clean_architecture_testing/domain/entities/weather.dart';
import 'package:dartz/dartz.dart';

abstract class WeatherRepository {
  Future<Either<Failure, WeatherEntity>> getCurrentWeather(
    String cityName,
  );
}
```

lib/domain/usecases/get_current_weather.dart
```dart
import 'package:clean_architecture_testing/core/error/failure.dart';
import 'package:clean_architecture_testing/domain/entities/weather.dart';
import 'package:dartz/dartz.dart';

import '../repositories/weather_repository.dart';

class GetCurrentWeatherUseCase {
  final WeatherRepository repository;

  GetCurrentWeatherUseCase(this.repository);

  Future<Either<Failure, WeatherEntity>> execute(String cityName) {
    return repository.getCurrentWeather(cityName);
  }
}
```

## [Use Case Testing | PART 2](https://www.youtube.com/watch?v=PQ4Bk3ocdeI)

### Project Tree
```
- test
  - data
  - domain
    - usecases
      - get_current_weather_test.dart
  - helpers
    - test_helper.dart
    - test_helper.mocks.dart
  - presentation
```

### 🧑‍💻 Create test helpers
test/helpers/test_helper.dart
```dart
import 'package:clean_architecture_testing/domain/repositories/weather_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

@GenerateMocks(
  [WeatherRepository],
  customMocks: [
    MockSpec<http.Client>(
      as: #MockHttpClient,
    ),
  ],
)
void main() {}
```

Generate `test_helper.mocks.dart`
```
flutter packages pub run build_runner build
```

### ✅ Add a test class for an abstract class using a mock

test/domain/usecases/get_current_weather_test.dart
```dart
import 'package:clean_architecture_testing/domain/entities/weather.dart';
import 'package:clean_architecture_testing/domain/usecases/get_current_weather.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helpers/test_helper.mocks.dart';

void main() {
  late GetCurrentWeatherUseCase getCurrentWeatherUseCase;
  late MockWeatherRepository mockWeatherRepository;

  setUp(() {
    mockWeatherRepository = MockWeatherRepository();
    getCurrentWeatherUseCase = GetCurrentWeatherUseCase(mockWeatherRepository);
  });

  const testWeatherDetail = WeatherEntity(
    cityName: 'Tokyo',
    main: 'Clouds',
    description: 'scattered clouds',
    iconCode: '03n',
    temperature: 279.32,
    pressure: 1016,
    humidity: 93,
  );

  const testCityName = 'Tokyo';

  test('should get current weather detail from the repository', () async {
    // arrange
    when(
      mockWeatherRepository.getCurrentWeather(testCityName),
    ).thenAnswer((_) async => const Right(testWeatherDetail));

    // act
    final result = await getCurrentWeatherUseCase.execute(testCityName);

    // assert
    expect(result, const Right(testWeatherDetail));
  });
}
```

## [Model Testing | Part 3](https://www.youtube.com/watch?v=0MbGFiOUGGg)

```
- lib
  - data
    - data_sources
    - models
      - weather_model.dart
    - repositories

- test
  - data
    - data_sources
    - models
      - weather_model_test.dart
    - repositories
  - helpers
    - dummy_data
      - dummy_weather_response.json
    - json_reader.dart
```

lib/data/models/weather_model.dart
### 🏗️ Prepare a model class for testing
```dart
import 'package:clean_architecture_testing/domain/entities/weather.dart';

class WeatherModel extends WeatherEntity {
  const WeatherModel({
    required super.cityName,
    required super.main,
    required super.description,
    required super.iconCode,
    required super.temperature,
    required super.pressure,
    required super.humidity,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> jsonMap) {
    return WeatherModel(
      cityName: jsonMap['name'],
      main: jsonMap['weather'][0]['main'],
      description: jsonMap['weather'][0]['description'],
      iconCode: jsonMap['weather'][0]['icon'],
      temperature: jsonMap['main']['temp'].toDouble(),
      pressure: jsonMap['main']['pressure'],
      humidity: jsonMap['main']['humidity'],
    );
  }

  Map<String, dynamic> toJson() => {
        'weather': [
          {
            'main': main,
            'description': description,
            'icon': iconCode,
          }
        ],
        'main': {
          'temp': temperature,
          'pressure': pressure,
          'humidity': humidity,
        },
        'name': cityName,
      };
}
```

### 🤡 Prepare a dummy JSON and a helper class for reading it

test/helpers/dummy_data/dummy_weather_response.json
```json
{
       "coord": {
              "lon": -74.006,
              "lat": 40.7143
       },
       "weather": [
              {
                     "id": 800,
                     "main": "Clear",
                     "description": "clear sky",
                     "icon": "01n"
              }
       ],
       "base": "stations",
       "main": {
              "temp": 292.87,
              "feels_like": 292.73,
              "temp_min": 290.47,
              "temp_max": 294.25,
              "pressure": 1012,
              "humidity": 70
       },
       "visibility": 10000,
       "wind": {
              "speed": 6.26,
              "deg": 319,
              "gust": 8.94
       },
       "clouds": {
              "all": 0
       },
       "dt": 1690708177,
       "sys": {
              "type": 2,
              "id": 2008101,
              "country": "JP",
              "sunrise": 1690710627,
              "sunset": 1690762457
       },
       "timezone": -14400,
       "id": 5128581,
       "name": "Tokyo",
       "cod": 200
}
```

test/helpers/json_reader.dart
```dart
import 'dart:io';

String readJson(String name) {
  var dir = Directory.current.path;
  if (dir.endsWith('/test')) {
    dir = dir.replaceAll('/test', '');
  }
  return File('$dir/test/$name').readAsStringSync();
}

```

✅ Add a test class for a model class 

test/data/models/weather_model_test.dart
```dart
import 'dart:convert';

import 'package:clean_architecture_testing/data/models/weather_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/json_reader.dart';

void main() {
  const testWeatherModel = WeatherModel(
    cityName: 'Tokyo',
    main: 'Clear',
    description: 'clear sky',
    iconCode: '01n',
    temperature: 292.87,
    pressure: 1012,
    humidity: 70,
  );
  test(
    'should be a subclass of weather entity',
    () async {
      // assert
      expect(testWeatherModel, isA<WeatherModel>());
    },
  );

  test(
    'should return a valid model from json',
    () async {
      // arrange
      final Map<String, dynamic> jsonMap = json.decode(
        readJson('helpers/dummy_data/dummy_weather_response.json'),
      );

      // act
      final result = WeatherModel.fromJson(jsonMap);

      // expect
      expect(result, testWeatherModel);
    },
  );

  test('should return a json map containing proper data', () async {
    // act
    final result = testWeatherModel.toJson();

    // assert
    final expectedJsonMap = {
      "weather": [
        {
          "main": "Clear",
          "description": "clear sky",
          "icon": "01n",
        }
      ],
      "main": {
        "temp": 292.87,
        "pressure": 1012,
        "humidity": 70,
      },
      "name": "Tokyo",
    };

    expect(result, expectedJsonMap);
  });
}
```

## [API Calling Testing | PART 4](https://youtu.be/5YQg1MpXpmE)

### 🏗️ Prepare a model class for testing
```dart
import 'package:clean_architecture_testing/constants/constants.dart';
import 'package:clean_architecture_testing/core/error/exception.dart';
import 'package:clean_architecture_testing/data/data_sources/remote_data_source.dart';
import 'package:clean_architecture_testing/data/models/weather_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import '../../helpers/json_reader.dart';
import '../../helpers/test_helper.mocks.dart';

void main() {
  late MockHttpClient mockHttpClient;
  late WeatherRemoteDataSourceImpl weatherRemoteDataSourceImpl;

  setUp(() {
    mockHttpClient = MockHttpClient();
    weatherRemoteDataSourceImpl =
        WeatherRemoteDataSourceImpl(client: mockHttpClient);
  });

  const testCityName = 'New York';

  group('get current weather', () {
    test('should return weather model when the response code is 200', () async {
      //arrange
      when(mockHttpClient
              .get(Uri.parse(Urls.currentWeatherByName(testCityName))))
          .thenAnswer((_) async => http.Response(
              readJson('helpers/dummy_data/dummy_weather_response.json'), 200));

      //act
      final result =
          await weatherRemoteDataSourceImpl.getCurrentWeather(testCityName);

      //assert
      expect(result, isA<WeatherModel>());
    });

    test(
      'should throw a server exception when the response code is 404 or other',
      () async {
        //arrange
        when(
          mockHttpClient
              .get(Uri.parse(Urls.currentWeatherByName(testCityName))),
        ).thenAnswer((_) async => http.Response('Not found', 404));

        //act
        final result =
            weatherRemoteDataSourceImpl.getCurrentWeather(testCityName);

        //assert
        expect(result, throwsA(isA<ServerException>()));
      },
    );
  });
}
```

✅ Add a test class for a datasource class 

lib/data/data_sources/remote_data_source.dart
```dart
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constants/constants.dart';
import '../../core/error/exception.dart';
import '../models/weather_model.dart';

abstract class WeatherRemoteDataSource {
  Future<WeatherModel> getCurrentWeather(String cityName);
}

class WeatherRemoteDataSourceImpl extends WeatherRemoteDataSource {
  final http.Client client;
  WeatherRemoteDataSourceImpl({required this.client});

  @override
  Future<WeatherModel> getCurrentWeather(String cityName) async {
    final response =
        await client.get(Uri.parse(Urls.currentWeatherByName(cityName)));

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
}
```

## [Repository Implementation Testing | PART 5](https://youtu.be/NxC9bd9Bp4Q?si=rTnCeRve04wkKA_j)

test/helpers/test_helper.dart
```dart
@GenerateMocks(
  [
    WeatherRepository,
    WeatherRemoteDataSource, // added
  ],
  customMocks: [
    MockSpec<http.Client>(
      as: #MockHttpClient,
    ),
  ],
)
void main() {}

```

test/data/repositories/weather_repository_impl_test.dart
```dart

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
  });
}

lib/data/repositories/weather_repository_impl.dart
```dart

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
}
```

lib/data/repositories/weather_repository_impl.dart
```dart
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
```

## [Flutter Clean Architecture & TDD | PART 6](https://youtu.be/aAchV1sAHgU?si=enwZ39LbQEmKsckn)

test/presentation/bloc/weather_bloc_test.dart
```dart

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
```

lib/presentation/bloc/weather_bloc.dart
```dart
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
```

lib/presentation/bloc/weather_event.dart
```dart
abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

class OnCityChanged extends WeatherEvent {
  final String cityName;

  const OnCityChanged({
    required this.cityName,
  });

  @override
  List<Object?> get props => [cityName];
}
```

lib/presentation/bloc/weather_state.dart
```dart
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
```
