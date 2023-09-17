import 'package:clean_architecture_testing/data/data_sources/remote_data_source.dart';
import 'package:clean_architecture_testing/domain/repositories/weather_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;

@GenerateMocks(
  [
    WeatherRepository,
    WeatherRemoteDataSource,
  ],
  customMocks: [
    MockSpec<http.Client>(
      as: #MockHttpClient,
    ),
  ],
)
void main() {}
