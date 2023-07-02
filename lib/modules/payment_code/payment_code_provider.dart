// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// import '../../data/remote/api/api_provider.dart';
//
// class _PaymentCodeStateModel {
//
//   final String search;
//   final String search;
//   final String search;
//
// }
//
// final providerPaymentCode = StateNotifierProvider.autoDispose<_PaymentCodeProvider, Map>((ref) {
//
//   final cancelToken = CancelToken();
//
//   ref.onDispose(() {
//     cancelToken.cancel();
//   });
//
//   ref.keepAlive();
//   return _PaymentCodeProvider(cancelToken);
// });
//
// class _PaymentCodeProvider extends StateNotifier<Map> {
//
//   final CancelToken cancelToken;
//
//   late ApiProvider _apiProvider;
//
//   _PaymentCodeProvider(this.cancelToken) : super() {
//     _apiProvider = ApiProvider();
//     getCustomers();
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     cancelToken.cancel();
//   }
//
//   // example how to mutating data inside state notifier
//   void updateState({
//     String? search,
//     bool? isSearch,
//     List<String>? divisionList,
//     String? selectedAchieve,
//     Map? selectedSort,
//     bool refresh = true,
//   }) {
//     state = state.copyWith(
//       search: search ?? state.search,
//       isSearch: isSearch ?? state.isSearch,
//       divisionList: divisionList ?? state.divisionList,
//       selectedAchieve: selectedAchieve ?? state.selectedAchieve,
//       selectedSort: selectedSort ?? state.selectedSort,
//     );
//     if (refresh) {
//       getCustomers(refresh: refresh);
//     }
//   }
//
//   Future<void> getCustomers({refresh = true}) async {
//     if (mounted) {
//       try {
//         if (refresh) {
//           state = state.copyWith(
//             isFetchNewData: false,
//             responseState: ResponseState.loading,
//             dataList: [],
//             page: 1,
//             lastPage: 0,
//           );
//         } else {
//           state = state.copyWith(
//             isFetchNewData: true,
//             lastPage: state.page,
//           );
//         }
//
//         // await LocationUtils.requestLocationPermission();
//         // final position = await LocationUtils.getCurrentLocation();
//
//         final responseList = await _fetchListFromApi();
//
//         if (responseList.isNotEmpty) {
//           // final filteredList = responseList.map((e) {
//           //   if (e.geoLat != null && e.geoLng != null && e.geoLat != "" && e.geoLng != "") {
//           //     e = e.copyWith(
//           //       jarak: Geolocator.distanceBetween(
//           //         position.latitude,
//           //         position.longitude,
//           //         double.parse("${e.geoLat}"),
//           //         double.parse("${e.geoLng}"),
//           //       ),
//           //     );
//           //   } else {
//           //     e = e.copyWith(
//           //       jarak: 1000000000.0, // so it will be the last of the list.
//           //     );
//           //   }
//           //   return e;
//           // }).toList();
//           // filteredList.sort((a, b) => (a.jarak ?? 0).compareTo((b.jarak ?? 0)));
//
//           // SAVE TO OFFLINE
//           final custBox = await Hive.openBox<Map>(collectionBoxNameCustomer);
//           // await custBox.clear();
//           for (var o in responseList) {
//             // use cust id as index
//             await custBox.put(o.mCustId, o.toJson());
//           }
//           custBox.close();
//           // END TO SAVE OFFLINE
//
//           state = state.copyWith(
//             responseState: ResponseState.complete,
//             dataList: [if (!refresh) ...state.dataList, ...responseList],
//             page: state.page + 1,
//             isFetchNewData: false,
//           );
//         } else {
//           state = state.copyWith(
//             responseState: ResponseState.complete,
//             isFetchNewData: false,
//           );
//         }
//       } catch (e) {
//         String message = "";
//         if (e is CustomException) {
//           message = e.message;
//         } else {
//           message = "$e";
//         }
//         if (state.dataList.isEmpty) {
//           state = state.copyWith(
//             responseState: ResponseState.error,
//             errorMessage: message,
//             isFetchNewData: false,
//           );
//         } else {
//           state = state.copyWith(
//             lastPage: state.page-1,
//             isFetchNewData: false,
//           );
//         }
//       }
//     }
//   }
//
//   Future<List<ListCustomerModel>> _fetchListFromApi() async {
//     try {
//       final response = await _apiProvider.fetchListCustomer(
//         pageNumber: state.page,
//         employeeId: _userModel?.dtUser?.first.mEmployeeId,
//         search: state.search,
//         periode: fetchPeriode,
//         filterDivision: state.divisionList.implode(),
//         filterMitra: state.selectedAchieve,
//         sortType: state.selectedSort['id'],
//         cancelToken: cancelToken,
//       );
//
//       return (response['data'] as Iterable).map((e) => ListCustomerModel.fromJson(e)).toList();
//     } catch (e) {
//       throw CustomException.catchError(e);
//     }
//   }
//
// }