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
    // // check first before recalling api.
    // i want re-fetch every time this provider get called
    // if (usersProvider.state != null) return usersProvider.state;
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

class HomeScreen extends ConsumerStatefulWidget {

  final String? messageExtra;

  const HomeScreen({Key? key, this.messageExtra}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // refresh || because using .pop() result is not working while you use .go method
      if (widget.messageExtra != null) {
        showSuccessFlushbar(context, "Yeayy!", widget.messageExtra!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/unitomo_logo.png',
              width: 35,
              height: 35,
            ),
            Expanded(
              child: Text("FAKULTAS TEKNIK",
                style: textTheme.titleMedium?.copyWith(
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              onPressed: () async {
                if (!Hive.isBoxOpen(boxName)) await Hive.openBox(boxName);
                final box = Hive.box(boxName);
                box.delete(apiKeyPref);
                if (context.mounted) context.go(AppRoute.loginRoute);
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: Consumer(
            builder: (_, ref1, __) {
              final asyncFetchUser = ref1.watch(providerCheckUserStatus);
              return asyncFetchUser.when(
                skipLoadingOnRefresh: false,
                data: (dataUser) {
                  final asyncFetchAllVAHistory = ref1.watch(providerFetchAllVAHistory);
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
                        child: asyncFetchAllVAHistory.when(
                          skipLoadingOnRefresh: false,
                          data: (data) {
                            return RefreshIndicator(
                              onRefresh: () async {
                                return ref.invalidate(providerFetchAllVAHistory);
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
                            onPressed: () => ref.invalidate(providerFetchAllVAHistory),
                            errorMsg: "$error",
                          ),
                          loading: () => const LoadingDisplayComponent(),
                        ),
                      ),
                    ],
                  );
                },
                error: (error, st) => ErrorDisplayComponent(
                  onPressed: () => ref.invalidate(providerCheckUserStatus),
                  errorMsg: "$error",
                ),
                loading: () => const LoadingDisplayComponent(),
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          context.goNamed(AppRoute.formGenerateVaRoute);
        },
      ),
    );
  }
}
