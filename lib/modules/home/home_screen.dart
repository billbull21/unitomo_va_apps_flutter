import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unitomo_va_payment/data/remote/api/api_provider.dart';
import 'package:unitomo_va_payment/helpers/flushbar_helper.dart';
import 'package:unitomo_va_payment/main.dart';
import 'package:unitomo_va_payment/routing.dart';
import 'package:unitomo_va_payment/view/components/empty_list_component.dart';
import 'package:unitomo_va_payment/view/components/error_display_component.dart';
import 'package:unitomo_va_payment/view/components/key_value_component.dart';
import 'package:unitomo_va_payment/view/components/loading_display_component.dart';

import '../../environtment.dart';
import '../../helpers/common_helper.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../utils/custom_exception.dart';

final providerCheckUserStatus =
    FutureProvider.autoDispose<UserModel?>((ref) async {
  try {
    final cancelToken = CancelToken();
    // When the provider is destroyed, cancel the http request
    ref.onDispose(() => cancelToken.cancel());
    final usersProvider = ref.read(providerUser.notifier);
    // check first before recalling api.
    if (usersProvider.state != null) return usersProvider.state;
    final response = await ApiProvider().fetchUserData();
    // update into global state manager for user provider
    usersProvider.state = response;

    if ((usersProvider.state!.status ?? 0) != 1) {
      MyApp.ctx?.go(AppRoute.registerOtpRoute);
    }

    return usersProvider.state;
  } on CustomException catch (e) {
    throw e.message;
  } catch (e) {
    if (kDebugMode) print("ERROR :: $e");
    rethrow;
  }
});

final providerFetchAllVAHistory =
    FutureProvider.autoDispose<List<Map>>((ref) async {
  try {
    final cancelToken = CancelToken();
    // When the provider is destroyed, cancel the http request
    ref.onDispose(() => cancelToken.cancel());
    final response = await ApiProvider().fetchAllVAHistory(
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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final asyncFetchUser = ref.watch(providerCheckUserStatus);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/unitomo_logo.png',
              width: 35,
              height: 35,
            ),
            const Spacer(
              flex: 3,
            ),
            Text("FAKULTAS TEKNIK",
              style: textTheme.titleMedium?.copyWith(
                height: 1.2,
              ),
            ),
            const Spacer(
              flex: 2,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (!Hive.isBoxOpen(boxName)) await Hive.openBox(boxName);
              final box = Hive.box(boxName);
              box.delete(apiKeyPref);
              if (context.mounted) context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: asyncFetchUser.when(
        data: (dataUser) {
          final asyncFetchAllVAHistory = ref.watch(providerFetchAllVAHistory);
          return Column(
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
                        onPressed: () {},
                        color: Colors.blue,
                        tooltip: "Profile",
                        icon: const Icon(Icons.account_circle),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                child: asyncFetchAllVAHistory.when(
                  data: (data) {
                    return RefreshIndicator(
                      onRefresh: () async {
                        return ref.refresh(providerFetchAllVAHistory);
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
                                  child: InkWell(
                                    onTap: () async {
                                      final resultMessage = await context.pushNamed(AppRoute.detailVaRoute,
                                        queryParameters: {
                                          'id': data[i]['id'],
                                        }
                                      );
                                      if (resultMessage is String && context.mounted) {
                                        showSuccessFlushbar(context, "Yeayy!", resultMessage);
                                        return ref.refresh(providerFetchAllVAHistory);
                                      }
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
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
                    onPressed: () => ref.refresh(providerFetchAllVAHistory),
                    errorMsg: "$error",
                  ),
                  loading: () => const LoadingDisplayComponent(),
                ),
              ),
            ],
          );
        },
        error: (error, st) => ErrorDisplayComponent(
          onPressed: () => ref.refresh(providerCheckUserStatus),
          errorMsg: "$error",
        ),
        loading: () => const LoadingDisplayComponent(),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final res = await context.pushNamed(AppRoute.formGenerateVaRoute);
          if (res != null && context.mounted) {
            showSuccessFlushbar(context, "Yeayy!", "berhasil membuat nomor pembayaran baru!");
            return ref.refresh(providerFetchAllVAHistory);
          }
        },
      ),
    );
  }
}
