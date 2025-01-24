import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:where_im_at/config/dependency_injection/di_keys.dart';
import 'package:where_im_at/config/environment/env.dart';

@module
abstract class ApiClientProvider {
  @singleton
  PrettyDioLogger get prettyDioLogger {
    return PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: true,
      error: true,
      compact: true,
      maxWidth: 120,
    );
  }

  @singleton
  @Named(DiKeys.geocodingApi)
  Dio geocodingApiClient(Env env, PrettyDioLogger logger) {
    final apiClient = Dio(
      BaseOptions(
        baseUrl: 'https://geocode.maps.co',
        queryParameters: {'access_key': env.geocodingApiKey},
      ),
    )..interceptors.addAll([if (kDebugMode) logger]);

    return apiClient;
  }

  @singleton
  @Named(DiKeys.projectOsrmApi)
  Dio projectOsrmClient(PrettyDioLogger logger) {
    final apiClient = Dio(
      BaseOptions(baseUrl: 'https://router.project-osrm.org/route/v1'),
    )..interceptors.addAll([if (kDebugMode) logger]);

    return apiClient;
  }
}
