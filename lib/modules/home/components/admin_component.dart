import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unitomo_va_payment/modules/home/components/admin/user_list_admin_component.dart';
import 'package:unitomo_va_payment/modules/home/components/admin/va_history_admin_component.dart';

import '../../../models/user_model.dart';
import '../home_screen.dart';
import 'admin/dashboard_admin_component.dart';

class SideMenuModel {
  final String title;
  final Widget widget;

  const SideMenuModel({
    required this.title,
    required this.widget,
  });
}

class AdminComponent extends ConsumerStatefulWidget {

  final UserModel? dataUser;

  const AdminComponent(this.dataUser, {super.key});

  @override
  ConsumerState<AdminComponent> createState() => _AdminComponentState();
}

class _AdminComponentState extends ConsumerState<AdminComponent> {

  @override
  void initState() {
    super.initState();
  }

  int _currentIndex = 0;

  List<SideMenuModel> get _listMenu => [
    const SideMenuModel(
      title: "Home",
      widget: DashboardAdminComponent(),
    ),
    const SideMenuModel(
      title: "Riwayat VA",
      widget: VAHistoryAdminComponent(),
    ),
    const SideMenuModel(
      title: "Daftar User",
      widget: UserListAdminComponent(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final widthScreen = MediaQuery.of(context).size.width;
    return widthScreen > 500 ? Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sideNav(),
        Expanded(
          child: _listMenu[_currentIndex].widget,
        ),
      ],
    ) : Stack(
      children: [
        Positioned.fill(
          child: _listMenu[_currentIndex].widget,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: _sideNav(),
        ),
      ],
    );
  }

  // build a side nav
  Widget _sideNav() {
    return Consumer(
      builder: (ctx, ref1, _) {
        final isSideMenuOpen = ref1.watch(providerIsSideMenuOpen);
        return AnimatedSize(
          alignment: Alignment.centerLeft,
          duration: const Duration(milliseconds: 500),
          child: SizedBox(
            width: isSideMenuOpen ? 200 : 0,
            child: Material(
              color: Colors.white,
              child: ListView(
                children: [
                  for (int i=0;i<_listMenu.length;i++)
                    ListTile(
                      onTap: () {
                        _currentIndex = i;
                        setState(() {});
                      },
                      title: Text(_listMenu[i].title),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
