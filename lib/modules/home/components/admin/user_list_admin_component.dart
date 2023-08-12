import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/common_helper.dart';
import '../../../../providers/pagination.dart';
import '../../../../routing.dart';
import '../../../../view/components/error_display_component.dart';
import '../../../../view/components/loading_display_component.dart';
import '../../../../view/components/text_field_component.dart';
import '../../providers/list_user_provider.dart';

class UserListAdminComponent extends ConsumerWidget {
  const UserListAdminComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    final paginationController = ref.watch(listUserPaginationProvider.notifier);
    final paginationState = ref.watch(listUserPaginationProvider);

    return Builder(
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text("Daftar User",
                    style: textTheme.headlineMedium,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(listUserPaginationProvider);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Refresh"),
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
                                    label: Text('NIM'),
                                  ),
                                  DataColumn(
                                    label: Text('Nama'),
                                  ),
                                  DataColumn(
                                    label: Text('Prodi'),
                                  ),
                                  DataColumn(
                                    label: Text('Email'),
                                  ),
                                  DataColumn(
                                    label: Text('Action'),
                                  ),
                                ],
                                rows: data.map((el) {
                                  return DataRow(
                                    color: "${el['status'] ?? ''}".isEmpty ? MaterialStateProperty.all(Colors.red.shade100) : null,
                                    cells: <DataCell>[
                                      DataCell(Text("${el['nim'] ?? ''}")),
                                      DataCell(Text("${el['nama'] ?? ''}")),
                                      DataCell(Text("${el['prodi'] ?? ''}")),
                                      DataCell(Text("${el['email'] ?? ''}")),
                                      DataCell(
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                // TODO :: CALL ENDPOINT TO DELETE/INACTIVE USER.
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
