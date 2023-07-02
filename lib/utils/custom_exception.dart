import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../main.dart';

class CustomException implements Exception {

  CustomException.catchError(error) {
    if (kDebugMode) {
      print("ERROR :: $error");
    }
    if (error is SocketException) {
      message = "Couldn't connect to server, please check your connectivity!";
    } else if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.cancel:
          message = "Request to API server was cancelled";
          break;
        case DioExceptionType.connectionTimeout:
          message = "Connection timeout with API server";
          break;
        case DioExceptionType.connectionError:
          message =
              "Connection to API server failed due to internet connection";
          break;
        case DioExceptionType.receiveTimeout:
          message = "Receive timeout in connection with API server";
          break;
        case DioExceptionType.badResponse:
          message = _handleError(error.response!.statusCode!, error.response?.data);
          break;
        case DioExceptionType.sendTimeout:
          message = "Send timeout in connection with API server";
          break;
        default:
          message = "Something went wrong";
          break;
      }
      // FirebaseCrashlytics.instance.recordError(
      //     error,
      //     null,
      //     reason: 'a non-fatal error',
      // );
    } else {
      // FirebaseCrashlytics.instance.recordError(
      //     error,
      //     null,
      //     reason: 'a fatal error',
      //     // Pass in 'fatal' argument
      //     fatal: true
      // );
      message = "Oops!, Something went wrong";
    }
  }

  String message = "";

  String _handleError(int statusCode, dynamic data) {
    if (data is List<int>) {
      data = jsonDecode(String.fromCharCodes(data));
    }
    String? errorMsg;
    if (data is Map && data['message'] != null) {
      errorMsg = data['message'];
    }
    switch (statusCode) {
      case 400:
        return errorMsg ?? 'Bad request';
      case 401:
        MyApp.ctx?.go('/login');
        return errorMsg ?? 'Unauthorized';
      case 403:
        MyApp.ctx?.go('/login');
        return errorMsg ?? 'Forbidden';
      case 404:
        return errorMsg ?? 'The requested resource was not found';
      case 500:
        return errorMsg ?? 'Internal server error';
      default:
        return 'Oops, something went wrong!';
    }
  }

  @override
  String toString() => message;
}