import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/remote/api/api_provider.dart';
import '../../../providers/pagination.dart';
import '../../../utils/custom_exception.dart';

final listUserPaginationProvider = StateNotifierProvider.autoDispose<ListUserPaginationController, ListUserPagination<Map>>((ref) {

  final cancelToken = CancelToken();

  ref.onDispose(() {
    cancelToken.cancel();
  });

  ref.keepAlive();
  return ListUserPaginationController(cancelToken);
});

class ListUserPagination<T> {

  final ResponseState responseState;
  final List<T> dataList;
  final int page;
  final String search;
  final String errorMessage;

  ListUserPagination.initial()
      : responseState = ResponseState.loading,
        dataList = [],
        page = 1,
        search = '',
        errorMessage = '';

  const ListUserPagination({
    required this.responseState,
    required this.dataList,
    required this.page,
    required this.search,
    required this.errorMessage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          (other is ListUserPagination &&
              runtimeType == other.runtimeType &&
              responseState == other.responseState &&
              dataList == other.dataList &&
              page == other.page &&
              search == other.search &&
              errorMessage == other.errorMessage);

  @override
  int get hashCode =>
      responseState.hashCode ^
      dataList.hashCode ^
      page.hashCode ^
      search.hashCode ^
      errorMessage.hashCode;

  @override
  String toString() {
    return 'ListUserPagination{ responseState: $responseState, dataList: $dataList, page: $page, search: $search, errorMessage: $errorMessage,}';
  }

  ListUserPagination<T> copyWith({
    ResponseState? responseState,
    List<T>? dataList,
    int? page,
    String? search,
    String? errorMessage,
  }) {
    return ListUserPagination<T>(
      responseState: responseState ?? this.responseState,
      dataList: dataList ?? this.dataList,
      page: page ?? this.page,
      search: search ?? this.search,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ListUserPaginationController extends StateNotifier<ListUserPagination<Map>> {

  final CancelToken cancelToken;

  ListUserPaginationController(this.cancelToken, [
    ListUserPagination<Map>? state,
  ]) : super(state ?? ListUserPagination<Map>.initial()) {
    _apiProvider = ApiProvider();
    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
    cancelToken.cancel();
  }

  late ApiProvider _apiProvider;

  // example how to mutating data inside state notifier
  void updateState({
    String? search,
    bool refresh = true,
  }) {
    state = state.copyWith(
      search: search ?? state.search,
    );
    if (refresh) {
      fetchData(refresh: refresh);
    }
  }

  Future<void> fetchData({refresh = true}) async {
    if (mounted) {
      try {
        if (refresh) {
          state = state.copyWith(
            responseState: ResponseState.loading,
            dataList: [],
            page: 1,
          );
        }

        final responseList = await _fetchListFromApi();
        state = state.copyWith(
          responseState: ResponseState.complete,
          dataList: [if (!refresh) ...state.dataList, ...responseList],
          page: state.page + 1,
        );
      } catch (e) {
        String message = "";
        if (e is CustomException) {
          message = e.message;
        } else {
          message = "$e";
        }
        if (refresh) {
          state = state.copyWith(
            responseState: ResponseState.error,
            errorMessage: message,
          );
        }
      }
    }
  }

  Future<List<Map>> _fetchListFromApi() async {
    try {
      final response = await _apiProvider.fetchAllUsers(
        page: state.page,
        limit: 100,
        search: state.search,
        cancelToken: cancelToken,
      );

      return List<Map>.from(response['data']);
    } catch (e) {
      throw CustomException.catchError(e);
    }
  }

}