import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unitomo_va_payment/routing.dart';

import '../../../data/remote/api/api_provider.dart';
import '../../../helpers/common_helper.dart';
import '../../../helpers/flushbar_helper.dart';
import '../../../helpers/loading_dialog.dart';
import '../../../utils/custom_exception.dart';
import '../../../view/components/text_field_component.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {

  final _emailController = TextEditingController();

  bool _isErrorMode = false;

  void _submit() async {
    FocusScope.of(context).unfocus();
    // validate input
    if (validateEmail.isNotEmpty) {
      if (!_isErrorMode) {
        setState(() {
          _isErrorMode = true;
        });
      }
      return;
    }

    LoadingDialog.showLoadingDialog(context);
    String? errorMessage;
    try {
      final data = {
        'email': _emailController.text,
      };
      await ApiProvider().forgotPassword(data);
    } on CustomException catch (e) {
      errorMessage = e.message;
    } catch (e) {
      if (kDebugMode) print("ERROR :: $e");
      errorMessage = "$e";
    }
    if (mounted) LoadingDialog.hideLoadingDialog(context);
    if (errorMessage == null && mounted) {
      context.pushNamed(AppRoute.forgotPasswordOtpRoute,
        queryParameters: {
          'email': _emailController.text,
        },
      );
    } else {
      showErrorFlushbar(context, "Oops!", errorMessage ?? "");
    }
  }

  String get validateEmail {
    final value = _emailController.text;
    if (value.isEmpty) {
      return 'Mohon masukkan Email Anda';
    } else if (!isValidEmail(value)) {
      return 'Mohon masukkan Email Anda yang valid';
    }
    return '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFieldComponent(
            controller: _emailController,
            label: 'Masukkan Email',
            hint: 'masukkan email anda',
            error: _isErrorMode ? validateEmail : '',
          ),
          const SizedBox(
            height: 16,
          ),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text("KIRIM"),
          ),
        ],
      ),
    );
  }
}
