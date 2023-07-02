import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/remote/api/api_provider.dart';
import '../utils/custom_exception.dart';

final providerFetchAllProdi = FutureProvider.autoDispose<List<Map>>((ref) async {
  try {
    final cancelToken = CancelToken();
    // When the provider is destroyed, cancel the http request
    ref.onDispose(() => cancelToken.cancel());

    final response = await ApiProvider().fetchAllProdi(
      cancelToken: cancelToken,
    );
    ref.keepAlive();
    return response;
  } on CustomException catch (e) {
    throw e.message;
  } catch (e) {
    if (kDebugMode) print("ERROR :: $e");
    rethrow;
  }
});