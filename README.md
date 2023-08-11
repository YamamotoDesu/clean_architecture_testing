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


