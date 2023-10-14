import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unitomo_va_payment/data/remote/api/api_provider.dart';
import 'package:unitomo_va_payment/helpers/common_helper.dart';
import 'package:unitomo_va_payment/helpers/flushbar_helper.dart';
import 'package:unitomo_va_payment/helpers/loading_dialog.dart';
import 'package:unitomo_va_payment/models/user_model.dart';
import 'package:unitomo_va_payment/providers/user_provider.dart';
import 'package:unitomo_va_payment/routing.dart';
import 'package:unitomo_va_payment/utils/custom_exception.dart';
import 'package:unitomo_va_payment/view/components/loading_display_component.dart';

import '../../view/components/error_display_component.dart';
import '../../view/components/key_value_component.dart';
import '../../view/components/text_field_component.dart';
import '../home/home_screen.dart';
import '../home/providers/va_history_provider.dart';

class FormGenerateVaScreen extends ConsumerStatefulWidget {
  const FormGenerateVaScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FormGenerateVaScreen> createState() => _FormGenerateVaScreenState();
}

class _FormGenerateVaScreenState extends ConsumerState<FormGenerateVaScreen> {

  final _nimTextController = TextEditingController();
  final _namaTextController = TextEditingController();

  String? va;
  bool isAdmin = false;
  Map? paymentData;
  String defaultPrefixVATeknik = "11111";
  bool _isErrorMode = false;

  @override
  void initState() {
    super.initState();
  }

  void _save() async {
    LoadingDialog.showLoadingDialog(context);
    String? errorMessage;
    try {
      // save to the our server first
      final user = ref.read(providerUser);
      String vaName = user?.nama ?? "";
      if (user?.isAdmin ?? false) {
        vaName = _namaTextController.text;
      }
      final dataVA = {
        "user_id": user?.id,
        "va": va,
        "va_name": vaName,
        "payment_category": paymentData!['deskripsi'],
        "nominal": paymentData!['nominal'],
        "parsial": paymentData!['cicilan'],
      };
      await ApiProvider().saveVA(dataVA);
    } on CustomException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      if (kDebugMode) print("ERROR :: $e");
      errorMessage = "$e";
    }
    if (mounted) LoadingDialog.hideLoadingDialog(context);
    if (errorMessage == null && mounted) {
      ref.invalidate(providerFetchVAHistory);
      ref.invalidate(vaHistoryPaginationProvider);
      context.pop();
      showSuccessFlushbar(context, "Yeayy!", "berhasil membuat nomor pembayaran baru!");
    } else {
      showErrorFlushbar(context, "Oops!", errorMessage ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncDataUser = ref.watch(providerCheckUserStatus);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Generate VA"),
      ),
      body: asyncDataUser.when(
        data: (data) {
          // update the variable
          isAdmin = data?.isAdmin ?? false;
          return _content(context, data);
        },
        error: (error, st) {
          return ErrorDisplayComponent(
            errorMsg: "$error",
            onPressed: () => ref.invalidate(providerCheckUserStatus),
          );
        },
        loading: () => const LoadingDisplayComponent(),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        child: ElevatedButton(
          onPressed: paymentData == null ? null : () async {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Simpan!"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("apakah anda yakin ingin membuat nomor pembayaran baru?"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              context.pop(); // dismiss the dialog
                              _save();
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
          child: const Text("SIMPAN"),
        ),
      ),
    );
  }

  String validator([String? field]) {
    if (isAdmin) {
      if ((field == null || field == 'nim') && _nimTextController.text.isEmpty) {
        return 'Mohon masukkan NIM Anda';
      }
      if ((field == null || field == 'name') && _namaTextController.text.isEmpty) {
        return 'Mohon masukkan Nama Anda';
      }
    }
    return '';
  }

  Widget _content(BuildContext context, UserModel? userModel) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // show field NAMA and NIM if the user log in is an Admin
          if (userModel?.isAdmin ?? false) ...[
            TextFieldComponent(
              controller: _nimTextController,
              label: 'NIM',
              hint: "masukkan NIM Anda",
              height: 40,
              error: _isErrorMode ? validator('nim') : '',
              onChanged: (value) {
                setState(() {
                  if (paymentData != null) {
                    String nim = _nimTextController.text;
                    String editedNim = nim.length > 4 ? nim.substring(2) : nim;
                    va = "$defaultPrefixVATeknik${paymentData!['kode']}$editedNim";
                    setState(() {});
                  }
                });
              },
            ),
            const SizedBox(height: 16.0),
            TextFieldComponent(
              controller: _namaTextController,
              label: 'Nama',
              hint: "masukkan nama Anda",
              height: 40,
              error: _isErrorMode ? validator('name') : '',
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 16.0),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                if (validator().isEmpty) {
                  String nim = userModel?.nim ?? "";
                  if (userModel?.isAdmin ?? false) {
                    nim = _nimTextController.text;
                  }
                  String editedNim = nim.length > 4 ? nim.substring(2) : nim;
                  final result = await context.pushNamed(
                    AppRoute.paymentCodeRoute,
                  );
                  if (result is Map) {
                    paymentData = result;
                    va = "$defaultPrefixVATeknik${paymentData!['kode']}$editedNim";
                    setState(() {});
                  }
                } else {
                  setState(() {
                    _isErrorMode = true;
                  });
                }
              },
              child: Text(paymentData != null ? "Ubah Kategori Pembayaran" : "Pilih Kategori Pembayaran"),
            ),
          ),
          const Divider(),
          KeyValueComponent(
            keyString: "VA",
            value: va ?? "-",
          ),
          KeyValueComponent(
            keyString: "Nama",
            value: "${(userModel?.isAdmin ?? false) ? _namaTextController.text : userModel?.nama}",
          ),
          KeyValueComponent(
            keyString: "Deskripsi",
            value: paymentData != null ? paymentData!['deskripsi'] : "-",
          ),
          KeyValueComponent(
            keyString: "Nominal",
            value: paymentData != null ? rupiahNumberFormatter("${paymentData!['nominal']}") : "-",
          ),
        ],
      ),
    );
  }

}
