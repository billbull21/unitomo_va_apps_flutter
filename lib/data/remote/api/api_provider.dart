import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unitomo_va_payment/utils/custom_exception.dart';

import '../../../environtment.dart';
import '../../../models/user_model.dart';

class ApiProvider {

  late Dio _dio;

  static final ApiProvider _apiProvider = ApiProvider._internal();

  factory ApiProvider(
      {String baseUrl = "http://103.117.56.237:5000/v1", Map<String, dynamic>? headers}) {
    _apiProvider._dio = Dio();
    _apiProvider._dio.interceptors.clear();
    _apiProvider._dio.interceptors.add(InterceptorsWrapper(onRequest:
        (RequestOptions options, RequestInterceptorHandler handler) async {
      // set baseUrl
      options.baseUrl = baseUrl;

      options.connectTimeout = const Duration(seconds: 30); //30s
      options.receiveTimeout = const Duration(seconds: 30); //30s

      String? token;
      // initialize token
      if (Hive.isBoxOpen(boxName)) {
        final box = Hive.box(boxName);
        token = box.get(apiKeyPref);
      }
      if (token != null) {
        options.headers['authorization'] = token;
      }

      // require this, if u don't add this. it will have empty body in expressjs server
      // options.headers.addAll({
      //   HttpHeaders.acceptHeader: "json/application/json",
      //   HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded",
      // });

      // to make it as json
      options.contentType = Headers.jsonContentType;

      // add header
      if (headers != null) options.headers.addAll(headers);

      return handler.next(options);
    }, onResponse: (Response resp, ResponseInterceptorHandler handler) {
      // print("RESP : $resp");
      return handler.next(resp);
    }, onError: (DioException error, ErrorInterceptorHandler handler) {
      // print("ERROR: $error");
      return handler.next(error);
    }));

    if (kDebugMode) {
      _apiProvider._dio.interceptors.add(LogInterceptor(
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: true,
        request: true,
        requestBody: true,
        logPrint: (obj) => debugPrint("$obj"),
      ));
    }

    return _apiProvider;
  }

  ApiProvider._internal();

  Future doLogin(nim, password) async {
    try {
      final response = await _dio.post(
        "/user/login",
        data: {
          'nim': nim,
          'password': password,
        },
      );
      return response.data;
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future doRegister(Map data) async {
    try {
      final response = await _dio.post(
        "/user",
        // data: jsonDecode(jsonEncode(data)),
        data: data,
      );
      return response.data;
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future updateProfile(Map data) async {
    try {
      final response = await _dio.put(
        "/user",
        // data: jsonDecode(jsonEncode(data)),
        data: data,
      );
      return response.data;
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future forgotPassword(Map data) async {
    try {
      final response = await _dio.post(
        "/user/forgot-password",
        data: data,
      );
      return response.data;
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future resetPassword(Map data) async {
    try {
      final response = await _dio.post(
        "/user/reset-password",
        data: data,
      );
      return response.data;
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future saveVA(Map data) async {
    try {
      final response = await _dio.post(
        "/va",
        data: data,
      );
      return response.data;
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future deleteVA(String id) async {
    try {
      final response = await _dio.delete(
        "/va/$id",
      );
      return response.data;
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future<UserModel> fetchUserData({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get("/user/data",
        cancelToken: cancelToken,
      );
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future<UserModel> fetchUserDataByID(String id, {CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get("/user/data/$id",
        cancelToken: cancelToken,
      );
      return UserModel.fromJson(response.data['data']);
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future<Map> verificationRegister(String otp, {CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get("/user/verification/$otp",
        cancelToken: cancelToken,
      );
      return Map.from(response.data);
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future<Map> resendOtp({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get("/user/resend-verification",
        cancelToken: cancelToken,
      );
      return Map.from(response.data);
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future<List<Map>> fetchAllProdi({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get("/prodi",
        cancelToken: cancelToken,
      );
      return List<Map>.from(response.data['data']);
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future<List<Map>> fetchAllPaymentCode({CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get("/paycode",
        cancelToken: cancelToken,
      );
      return List<Map>.from(response.data['data']);
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future changePassword(Map data) async {
    try {
      final response = await _dio.post(
        "/user/change-password",
        data: data,
      );
      return response.data;
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future<Map> fetchAllUsers({
    int page = 1,
    int limit = 100,
    String search = '',
    CancelToken? cancelToken
  }) async {
    try {
      final response = await _dio.get("/user?search=$search&page=$page&limit=$limit",
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future<Map> fetchAllVAHistory({
    int page = 1,
    int limit = 100,
    String search = '',
    CancelToken? cancelToken,
  }) async {
    String url = "/all-va?search=$search&page=$page&limit=$limit";
    try {
      final response = await _dio.get(url,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future<Map> fetchListVAHistoryByUser({
    int page = 1,
    int limit = 100,
    String search = '',
    CancelToken? cancelToken,
  }) async {
    String url = "/va?search=$search&page=$page&limit=$limit";
    try {
      final response = await _dio.get(url,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future<Map> fetchVAHistoryByID(String id, {CancelToken? cancelToken}) async {
    try {
      final response = await _dio.get("/va/$id",
        cancelToken: cancelToken,
      );
      return Map.from(response.data['data']);
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

  Future deleteUser(String id) async {
    try {
      final response = await _dio.delete(
        "/user/$id",
      );
      return response.data;
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

}
