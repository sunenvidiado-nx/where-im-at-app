import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:where_im_at/config/dependency_injection/di_keys.dart';
import 'package:where_im_at/config/environment/env.dart';

@module
abstract class ApiClientProvider {
  @singleton
  @Named(DiKeys.positionStackApi)
  Dio positionStackApiClient(Env env) {
    final apiClient = Dio(
      BaseOptions(
        baseUrl: 'http://api.positionstack.com/v1',
        queryParameters: {'access_key': env.positionStackApiKey},
      ),
    )..interceptors.addAll([
        if (kDebugMode)
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: true,
            error: true,
            compact: true,
            maxWidth: 120,
          ),
      ]);

    return apiClient;
  }
}
