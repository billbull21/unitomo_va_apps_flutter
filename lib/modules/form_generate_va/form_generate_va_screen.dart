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

import '../../view/components/key_value_component.dart';
import '../home/home_screen.dart';

class FormGenerateVaScreen extends ConsumerStatefulWidget {
  const FormGenerateVaScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FormGenerateVaScreen> createState() => _FormGenerateVaScreenState();
}

class _FormGenerateVaScreenState extends ConsumerState<FormGenerateVaScreen> {

  String? va;
  Map? paymentData;
  String defaultPrefixVATeknik = "10096";
  late UserModel? _userModel;

  @override
  void initState() {
    super.initState();
    _userModel = ref.read(providerUser);
  }

  void _save() async {
    LoadingDialog.showLoadingDialog(context);
    String? errorMessage;
    try {
      // save to the our server first
      final dataVA = {
        "user_id": _userModel?.id,
        "va": va,
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
      ref.refresh(providerFetchAllVAHistory);
      context.goNamed("/",
        extra: "berhasil membuat nomor pembayaran baru!",
      );
    } else {
      showErrorFlushbar(context, "Oops!", errorMessage ?? "");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Generate VA"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await context.pushNamed(AppRoute.paymentCodeRoute);
                  if (result is Map) {
                    paymentData = result;
                    va = "$defaultPrefixVATeknik${paymentData!['kode']}${(_userModel?.nim?.length ?? 0) > 4 ? "${_userModel?.nim?.substring(2, 4)}${_userModel?.nim?.substring(6)}" : _userModel?.nim}";
                    setState(() {});
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
              value: "${_userModel?.nama}",
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
}
