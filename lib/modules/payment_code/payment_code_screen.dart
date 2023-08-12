import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unitomo_va_payment/view/components/error_display_component.dart';
import 'package:unitomo_va_payment/view/components/loading_display_component.dart';

import '../../data/remote/api/api_provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/custom_exception.dart';
import '../../view/components/empty_list_component.dart';

final providerFetchAllPaymentCode = FutureProvider.autoDispose<List<Map>>((ref) async {
  try {
    final cancelToken = CancelToken();
    // When the provider is destroyed, cancel the http request
    ref.onDispose(() => cancelToken.cancel());

    ref.watch(providerUser);

    final response = await ApiProvider().fetchAllPaymentCode(
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

class PaymentCodeScreen extends ConsumerStatefulWidget {

  const PaymentCodeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PaymentCodeScreen> createState() => _PaymentCodeScreenState();
}

class _PaymentCodeScreenState extends ConsumerState<PaymentCodeScreen> {

  final _searchController = TextEditingController();

  // late AsyncData<List<Map>> asyncFetchAllPaymentCode;
  bool _isInit = true;
  String search = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      // asyncFetchAllPaymentCode = ref.watch(providerFetchAllPaymentCode);
      _isInit = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncFetchAllPaymentCode = ref.watch(providerFetchAllPaymentCode);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            suffixIcon: _searchController.text.isEmpty ? const Icon(Icons.search, color: Colors.black,) : GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {});
              },
              child: const Icon(Icons.clear, color: Colors.black,),
            ),
            border: InputBorder.none,
            hintText: "search...",
            hintStyle: const TextStyle(
              color: Colors.black,
            ),
          ),
          style: const TextStyle(
            color: Colors.black,
          ),
          maxLines: 1,
          onChanged: (val) {
            search = val;
            setState(() {});
          },
        ),
      ),
      body: asyncFetchAllPaymentCode.when(
        data: (data) {
          final filteredData = data.where((el) => el['deskripsi'].toString().toLowerCase().contains(_searchController.text.toLowerCase())).toList();
          return filteredData.isEmpty ? const EmptyListComponent() : ListView.separated(
            itemCount: filteredData.length,
            separatorBuilder: (_, __) {
              return Container(
                color: Colors.grey,
                width: double.infinity,
                height: 0.5,
              );
            },
            itemBuilder: (ctx, pos) {
              return ListTile(
                onTap: () {
                  Navigator.of(context).pop(filteredData[pos]);
                },
                title: Text(filteredData[pos]['deskripsi']),
              );
            },
          );
        },
        error: (error, st) {
          return ErrorDisplayComponent(
            onPressed: () => ref.refresh(providerFetchAllPaymentCode),
          );
        },
        loading: () => const LoadingDisplayComponent(),
      ),
    );
  }
}
