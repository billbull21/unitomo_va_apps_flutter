import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unitomo_va_payment/data/remote/api/api_provider.dart';
import 'package:unitomo_va_payment/helpers/flushbar_helper.dart';
import 'package:unitomo_va_payment/main.dart';
import 'package:unitomo_va_payment/modules/home/components/admin_component.dart';
import 'package:unitomo_va_payment/routing.dart';
import 'package:unitomo_va_payment/view/components/error_display_component.dart';
import 'package:unitomo_va_payment/view/components/loading_display_component.dart';

import '../../environtment.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../utils/custom_exception.dart';
import 'components/user_component.dart';

final providerCheckUserStatus = FutureProvider.autoDispose<UserModel?>((ref) async {
  try {
    final cancelToken = CancelToken();
    // When the provider is destroyed, cancel the http request
    ref.onDispose(() => cancelToken.cancel());
    final usersProvider = ref.read(providerUser.notifier);
    // // check first before recalling api.
    // i want re-fetch every time this provider get called
    // if (usersProvider.state != null) return usersProvider.state;
    final response = await ApiProvider().fetchUserData(
      cancelToken: cancelToken,
    );
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

final providerFetchDataUserByID = FutureProvider.autoDispose.family<UserModel?, String>((ref, id) async {
  try {
    final cancelToken = CancelToken();
    // When the provider is destroyed, cancel the http request
    ref.onDispose(() => cancelToken.cancel());
    final response = await ApiProvider().fetchUserDataByID(id,
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

final providerFetchVAHistory = FutureProvider.autoDispose<List<Map>>((ref) async {
  try {
    final cancelToken = CancelToken();
    // When the provider is destroyed, cancel the http request
    ref.onDispose(() => cancelToken.cancel());
    final response = await ApiProvider().fetchListVAHistoryByUser(
      cancelToken: cancelToken,
    );
    return List<Map>.from(response['data']);
  } on CustomException catch (e) {
    throw e.message;
  } catch (e) {
    if (kDebugMode) print("ERROR :: $e");
    rethrow;
  }
});

final providerIsSideMenuOpen = StateProvider((ref) => false);

class HomeScreen extends ConsumerStatefulWidget {

  final String? messageExtra;

  const HomeScreen({Key? key, this.messageExtra}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {

  late TextTheme textTheme;

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
    textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Consumer(
              builder: (_, ref1, __) {
                final asyncFetchUser = ref1.watch(providerCheckUserStatus);
                return asyncFetchUser.whenOrNull(
                  data: (data) {
                    if (data?.isAdmin ?? false) {
                      return IconButton.outlined(
                        onPressed: () {
                          final currState = ref.read(providerIsSideMenuOpen);
                          ref.read(providerIsSideMenuOpen.notifier).state = !currState;
                        },
                        style: IconButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.menu),
                      );
                    }
                    return Image.asset('assets/images/unitomo_logo.png',
                      width: 35,
                      height: 35,
                    );
                  }
                ) ?? Image.asset('assets/images/unitomo_logo.png',
                  width: 35,
                  height: 35,
                );
              },
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
        child: Consumer(
          builder: (_, ref1, __) {
            final asyncFetchUser = ref1.watch(providerCheckUserStatus);
            return asyncFetchUser.when(
              skipLoadingOnRefresh: false,
              data: (dataUser) {
                if (dataUser?.isAdmin ?? false) {
                  return AdminComponent(dataUser);
                } else {
                  return UserComponent(dataUser);
                }
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
      floatingActionButton: Consumer(
        builder: (_, ref1, __) {
          final asyncFetchUser = ref1.watch(providerCheckUserStatus);
          return asyncFetchUser.whenOrNull(
            data: (data) {
              if (!(data?.isAdmin ?? false)) {
                return FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () async {
                    context.goNamed(AppRoute.formGenerateVaRoute);
                  },
                );
              }
              return null;
            },
          ) ?? const SizedBox.shrink();
        },
      ),
    );
  }

  // Widget isAdmin(BuildContext context, WidgetRef ref) {
  //   return Column(
  //     children: [
  //       Row(
  //         children: [
  //           Expanded(
  //             child: OutlinedButton(
  //               onPressed: () => setState(() {
  //                 _menuType = 1;
  //               }),
  //               style: OutlinedButton.styleFrom(
  //                 backgroundColor: _menuType == 1 ? Colors.blue.shade100 : null,
  //               ),
  //               child: const Text("VA History"),
  //             ),
  //           ),
  //           const SizedBox(
  //             width: 16,
  //           ),
  //           Expanded(
  //             child: OutlinedButton(
  //               onPressed: () => setState(() {
  //                 _menuType = 2;
  //               }),
  //               style: OutlinedButton.styleFrom(
  //                 backgroundColor: _menuType == 2 ? Colors.blue.shade100 : null,
  //               ),
  //               child: const Text("Daftar User"),
  //             ),
  //           ),
  //         ],
  //       ),
  //       Expanded(
  //         child: _menuType == 1 ? _historyVA(ref, true) : _listUser(ref),
  //       ),
  //     ],
  //   );
  // }
  //
  // Widget _listUser(WidgetRef ref) {
  //   final asyncFetchAllUsers = ref.watch(providerFetchAllUsers);
  //   return asyncFetchAllUsers.when(
  //     skipLoadingOnRefresh: false,
  //     data: (data) {
  //       return RefreshIndicator(
  //         onRefresh: () async {
  //           return ref.invalidate(providerFetchAllUsers);
  //         },
  //         child: Stack(
  //           children: [
  //             if (data.isEmpty) const EmptyListComponent(),
  //             Positioned.fill(
  //               child: ListView.builder(
  //                 padding: const EdgeInsets.all(16.0),
  //                 physics: const AlwaysScrollableScrollPhysics(),
  //                 itemCount: data.length,
  //                 itemBuilder: (ctx, i) {
  //                   return Card(
  //                     child: InkWell(
  //                       onTap: () async {
  //
  //                       },
  //                       child: Padding(
  //                         padding: const EdgeInsets.all(8.0),
  //                         child: Column(
  //                           children: [
  //                             KeyValueComponent(
  //                               keyString: "NIM",
  //                               value: "${data[i]['nim']}",
  //                             ),
  //                             KeyValueComponent(
  //                               keyString: "Nama",
  //                               value: "${data[i]['nama']}",
  //                             ),
  //                             KeyValueComponent(
  //                               keyString: "Prodi",
  //                               value: "${data[i]['namaprodi']}",
  //                               noMargin: true,
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   );
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //     error: (error, st) => ErrorDisplayComponent(
  //       onPressed: () => ref.invalidate(providerFetchAllUsers),
  //       errorMsg: "$error",
  //     ),
  //     loading: () => const LoadingDisplayComponent(),
  //   );
  // }
  //

}
