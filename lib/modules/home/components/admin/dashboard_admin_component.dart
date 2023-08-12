import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../providers/user_provider.dart';
import '../../../../routing.dart';

class DashboardAdminComponent extends ConsumerWidget {

  const DashboardAdminComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataUser = ref.watch(providerUser);
    final textTheme = Theme.of(context).textTheme;
    return ListView(
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
                      // Text("${dataUser?.prodi}",
                      //   style: textTheme.bodyMedium,
                      // ),
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
      ],
    );
  }
}
