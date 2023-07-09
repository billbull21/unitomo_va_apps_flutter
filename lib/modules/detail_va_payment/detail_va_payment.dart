import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/remote/api/api_provider.dart';
import '../../helpers/common_helper.dart';
import '../../helpers/flushbar_helper.dart';
import '../../helpers/loading_dialog.dart';
import '../../utils/custom_exception.dart';
import '../../view/components/error_display_component.dart';
import '../../view/components/key_value_component.dart';
import '../../view/components/loading_display_component.dart';
import '../home/home_screen.dart';

final providerFetchVAHistoryByID =
FutureProvider.autoDispose.family<Map, String>((ref, id) async {
  try {
    final cancelToken = CancelToken();
    // When the provider is destroyed, cancel the http request
    ref.onDispose(() => cancelToken.cancel());
    final response = await ApiProvider().fetchVAHistoryByID(
      id,
      cancelToken: cancelToken,
    );
    return response;
  } on CustomException catch (e) {
    throw e.message;
  } catch (e) {
    if (kDebugMode) print("ERROR :: $e");
    rethrow;
  }
});

class DetailVaPayment extends ConsumerStatefulWidget {

  final String idVa;

  const DetailVaPayment({Key? key, required this.idVa}) : super(key: key);

  @override
  ConsumerState<DetailVaPayment> createState() => _DetailVaPaymentState();
}

class _DetailVaPaymentState extends ConsumerState<DetailVaPayment> {

  void _delete() async {
    LoadingDialog.showLoadingDialog(context);
    String? errorMessage;
    try {
      await ApiProvider().deleteVA(widget.idVa);
    } on CustomException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      if (kDebugMode) print("ERROR :: $e");
      errorMessage = "$e";
    }
    if (mounted) LoadingDialog.hideLoadingDialog(context);
    if (errorMessage == null && mounted) {
      ref.refresh(providerFetchAllVAHistory);
      context.goNamed("/", extra: "Berhasil menghapus nomor VA");
    } else {
      showErrorFlushbar(context, "Oops!", errorMessage ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncFetchDetail = ref.watch(providerFetchVAHistoryByID(widget.idVa));
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail VA"),
        elevation: 5,
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Hapus!"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text("apakah anda yakin ingin menghapus nomor pembayaran ini?"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                context.pop(); // dismiss the dialog
                                _delete();
                              },
                              child: const Text("Ya"),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            OutlinedButton(
                              onPressed: context.pop,
                              child: const Text("Tidak"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            color: Colors.red,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: asyncFetchDetail.when(
            data: (data) {
              return RefreshIndicator(
                onRefresh: () async => ref.refresh(providerFetchVAHistoryByID(widget.idVa)),
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    KeyValueComponent(
                      keyString: "VA",
                      value: "${data['va']}",
                      noMargin: true,
                    ),
                    const Divider(),
                    KeyValueComponent(
                      keyString: "Kategori",
                      value: "${data['payment_category']}",
                      noMargin: true,
                    ),
                    const Divider(),
                    KeyValueComponent(
                      keyString: "Nominal",
                      value: rupiahNumberFormatter("${data['nominal']}"),
                      noMargin: true,
                    ),
                    const Divider(),
                    KeyValueComponent(
                      keyString: "Due Date",
                      value: dateFormat("${data['expired_date']}"),
                      noMargin: true,
                    ),
                    const Divider(),
                    KeyValueComponent(
                      keyString: "Status",
                      value: "${data['status'] ?? ''}".isEmpty ? "UNDONE" : data['status'],
                      noMargin: true,
                    ),
                    const Divider(),
                    KeyValueComponent(
                      keyString: "Created At",
                      value: dateFormat("${data['created_at']}"),
                      noMargin: true,
                    ),
                    const Divider(),
                    OutlinedButton.icon(
                      onPressed: () {
                        final clipboardData = ClipboardData(text: "${data['va']}");
                        Clipboard.setData(clipboardData);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No. VA copied to clipboard')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text("Salin no. VA"),
                    ),
                  ],
                ),
              );
            },
            error: (error, st) => ErrorDisplayComponent(
              onPressed: () => ref.refresh(providerFetchVAHistoryByID(widget.idVa)),
              errorMsg: "$error",
            ),
            loading: () => const LoadingDisplayComponent(),
          ),
        ),
      ),
    );
  }
}
