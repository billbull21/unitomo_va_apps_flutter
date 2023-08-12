import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/common_helper.dart';
import '../../../models/user_model.dart';
import '../../../routing.dart';
import '../../../view/components/empty_list_component.dart';
import '../../../view/components/error_display_component.dart';
import '../../../view/components/key_value_component.dart';
import '../../../view/components/loading_display_component.dart';
import '../home_screen.dart';

class UserComponent extends ConsumerWidget {

  final UserModel? dataUser;

  const UserComponent(this.dataUser, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 400,
      ),
      child: Column(
        children: [
          Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            color: Colors.yellow,
            elevation: 5,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hi, ${dataUser?.nama}",
                          style: textTheme.headlineMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text("${dataUser?.prodi}",
                          style: textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  IconButton.outlined(
                    onPressed: () {
                      context.goNamed(AppRoute.userProfile);
                    },
                    color: Colors.blue,
                    tooltip: "Profile",
                    icon: const Icon(Icons.account_circle),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: _historyVA(context, ref),
          ),
        ],
      ),
    );
  }

  Widget _historyVA(BuildContext context, WidgetRef ref) {
    final asyncFetchAllVAHistory = ref.watch(providerFetchVAHistory);
    return asyncFetchAllVAHistory.when(
      skipLoadingOnRefresh: false,
      data: (data) {
        return RefreshIndicator(
          onRefresh: () async {
            return ref.invalidate(providerFetchVAHistory);
          },
          child: Stack(
            children: [
              if (data.isEmpty) const EmptyListComponent(),
              Positioned.fill(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (ctx, i) {
                    return Card(
                      color: "${data[i]['status'] ?? ''}".isEmpty ? Colors.red.shade100 : null,
                      child: InkWell(
                        onTap: () async {
                          context.goNamed(AppRoute.detailVaRoute,
                            pathParameters: {
                              'id': data[i]['id'],
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              // if (isAdmin)
                              //   KeyValueComponent(
                              //     keyString: "Nama",
                              //     value: "${data[i]['va_name']}",
                              //   ),
                              KeyValueComponent(
                                keyString: "VA",
                                value: "${data[i]['va']}",
                              ),
                              KeyValueComponent(
                                keyString: "Kategori",
                                value: "${data[i]['payment_category']}",
                              ),
                              KeyValueComponent(
                                keyString: "Nominal",
                                value: rupiahNumberFormatter("${data[i]['nominal']}"),
                                noMargin: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      error: (error, st) => ErrorDisplayComponent(
        onPressed: () => ref.invalidate(providerFetchVAHistory),
        errorMsg: "$error",
      ),
      loading: () => const LoadingDisplayComponent(),
    );
  }

}
