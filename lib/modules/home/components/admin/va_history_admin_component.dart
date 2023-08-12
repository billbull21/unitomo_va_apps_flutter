import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unitomo_va_payment/helpers/common_helper.dart';
import 'package:unitomo_va_payment/modules/home/providers/va_history_provider.dart';
import 'package:unitomo_va_payment/view/components/text_field_component.dart';

import '../../../../data/remote/api/api_provider.dart';
import '../../../../helpers/flushbar_helper.dart';
import '../../../../helpers/loading_dialog.dart';
import '../../../../providers/pagination.dart';
import '../../../../routing.dart';
import '../../../../utils/custom_exception.dart';
import '../../../../view/components/error_display_component.dart';
import '../../../../view/components/loading_display_component.dart';

class VAHistoryAdminComponent extends ConsumerStatefulWidget {

  const VAHistoryAdminComponent({Key? key}) : super(key: key);

  @override
  ConsumerState<VAHistoryAdminComponent> createState() => _VAHistoryAdminComponentState();
}

class _VAHistoryAdminComponentState extends ConsumerState<VAHistoryAdminComponent> {

  void _delete(String id) async {
    LoadingDialog.showLoadingDialog(context);
    String? errorMessage;
    try {
      await ApiProvider().deleteVA(id);
    } on CustomException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      if (kDebugMode) print("ERROR :: $e");
      errorMessage = "$e";
    }
    if (mounted) LoadingDialog.hideLoadingDialog(context);
    if (errorMessage == null && mounted) {
      ref.invalidate(vaHistoryPaginationProvider);
      context.pop();
      showSuccessFlushbar(context, "Yeayy!", "Berhasil menghapus nomor VA");
      // context.goNamed("/", extra: );
    } else {
      showErrorFlushbar(context, "Oops!", errorMessage ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final textTheme = Theme.of(context).textTheme;

    final paginationController = ref.watch(vaHistoryPaginationProvider.notifier);
    final paginationState = ref.watch(vaHistoryPaginationProvider);

    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (width > 800)
                    Expanded(
                      child: Text("Riwayat VA",
                        style: textTheme.headlineMedium,
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.invalidate(vaHistoryPaginationProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.refresh),
                    label: const Text("Refresh"),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.goNamed(AppRoute.formGenerateVaRoute);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text("Generate VA"),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        constraints: const BoxConstraints(
                          maxWidth: 300,
                        ),
                        child: TextFieldComponent(
                          hint: "Masukkan pencarian",
                          suffixWidget: const Icon(Icons.search),
                          onChanged: (val) {
                            paginationController.updateState(
                              search: val,
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Builder(
                        builder: (ctx) {
                          Widget? extra;
                          if (paginationState.responseState == ResponseState.error) {
                            extra = Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ErrorDisplayComponent(
                                    onPressed: () => paginationController.fetchData(),
                                    errorMsg: paginationState.errorMessage,
                                  ),
                                ],
                              ),
                            );
                          } else if (paginationState.responseState == ResponseState.loading) {
                            extra = Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.white,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  LoadingDisplayComponent(),
                                ],
                              ),
                            );
                          }
                          final data = paginationState.dataList;
                          if (data.isEmpty && paginationState.responseState == ResponseState.complete) {
                            extra = Container(
                              padding: const EdgeInsets.all(8),
                              color: Colors.white,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Belum ada data!"),
                                ],
                              ),
                            );
                          }
                          return Column(
                            children: [
                              SingleChildScrollView(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    headingRowColor: MaterialStateProperty.all(Colors.blue.shade300),
                                    columns: const <DataColumn>[
                                      DataColumn(
                                        label: Text('Nama'),
                                      ),
                                      DataColumn(
                                        label: Text('VA'),
                                      ),
                                      DataColumn(
                                        label: Text('Kategori'),
                                      ),
                                      DataColumn(
                                        label: Text('Nominal'),
                                      ),
                                      DataColumn(
                                        label: Text('Action'),
                                      ),
                                    ],
                                    rows: data.map((el) {
                                      return DataRow(
                                        color: "${el['status'] ?? ''}".isEmpty ? MaterialStateProperty.all(Colors.red.shade100) : null,
                                        cells: <DataCell>[
                                          DataCell(Text("${el['va_name'] ?? ''}")),
                                          DataCell(Text("${el['va'] ?? ''}")),
                                          DataCell(Text("${el['payment_category'] ?? ''}")),
                                          DataCell(Text(rupiahNumberFormatter("${el['nominal'] ?? ''}"))),
                                          DataCell(
                                            Row(
                                              children: [
                                                IconButton(
                                                  onPressed: () {
                                                    context.goNamed(AppRoute.detailVaRoute,
                                                      pathParameters: {
                                                        'id': el['id'],
                                                      },
                                                    );
                                                  },
                                                  color: Colors.blue,
                                                  icon: const Icon(Icons.arrow_forward),
                                                ),
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
                                                              const Text("apakah anda yakin ingin menghapus nomor VA ini?"),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                children: [
                                                                  ElevatedButton(
                                                                    onPressed: () {
                                                                      _delete(el['id']);
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
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                              if (extra != null) extra,
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
