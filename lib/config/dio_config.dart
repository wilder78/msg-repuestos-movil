import 'dart:developer' as developer;
import 'package:dio/dio.dart';

class DioConfig {
  // Web:            http://localhost:8080/api/
  // Emulador Android: http://10.0.2.2:8080/api/
  // Celular físico:   http://192.168.1.107:8080/api/
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/', // 👈 default para Flutter Web
  );

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  )..interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (message) =>
            developer.log(message.toString(), name: 'DioConfig'),
      ),
    );
}