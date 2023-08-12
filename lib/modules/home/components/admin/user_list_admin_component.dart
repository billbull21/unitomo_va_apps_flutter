import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../data/remote/api/api_provider.dart';
import '../../../../helpers/flushbar_helper.dart';
import '../../../../helpers/loading_dialog.dart';
import '../../../../providers/pagination.dart';
import '../../../../utils/custom_exception.dart';
import '../../../../view/components/error_display_component.dart';
import '../../../../view/components/loading_display_component.dart';
import '../../../../view/components/text_field_component.dart';
import '../../providers/list_user_provider.dart';

class UserListAdminComponent extends ConsumerStatefulWidget {
  const UserListAdminComponent({Key? key}) : super(key: key);
  @override
  ConsumerState<UserListAdminComponent> createState() => _UserListAdminComponentState();
}

class _UserListAdminComponentState extends ConsumerState<UserListAdminComponent> {

  void _delete(String id) async {
    LoadingDialog.showLoadingDialog(context);
    String? errorMessage;
    try {
      await ApiProvider().deleteUser(id);
    } on CustomException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      if (kDebugMode) print("ERROR :: $e");
      errorMessage = "$e";
    }
    if (mounted) LoadingDialog.hideLoadingDialog(context);
    if (errorMessage == null && mounted) {
      ref.invalidate(listUserPaginationProvider);
      showSuccessFlushbar(context, "Yeayy!", "berhasil menghapus user!");
    } else {
      showErrorFlushbar(context, "Oops!", errorMessage ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final textTheme = Theme.of(context).textTheme;

    final paginationController = ref.watch(listUserPaginationProvider.notifier);
    final paginationState = ref.watch(listUserPaginationProvider);

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
                              SingleChildScrollView(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
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
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: const Text("Hapus!"),
                                                          content: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              const Text("apakah anda yakin ingin menghapus user ini?"),
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
