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

### 🤡 prepare a dummy JSON and a helper class for reading


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




