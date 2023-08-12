import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unitomo_va_payment/helpers/common_helper.dart';
import 'package:unitomo_va_payment/modules/home/providers/va_history_provider.dart';
import 'package:unitomo_va_payment/view/components/text_field_component.dart';

import '../../../../providers/pagination.dart';
import '../../../../routing.dart';
import '../../../../view/components/error_display_component.dart';
import '../../../../view/components/loading_display_component.dart';

class VAHistoryAdminComponent extends ConsumerWidget {

  const VAHistoryAdminComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    final paginationController = ref.watch(vaHistoryPaginationProvider.notifier);
    final paginationState = ref.watch(vaHistoryPaginationProvider);

    return Builder(
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
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
                            SizedBox(
                              width: double.infinity,
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
                                              icon: const Icon(Icons.remove_red_eye),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
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
        );
      },
    );
  }
}
