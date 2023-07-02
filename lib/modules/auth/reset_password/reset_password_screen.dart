import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:unitomo_va_payment/routing.dart';

import '../../../data/remote/api/api_provider.dart';
import '../../../helpers/flushbar_helper.dart';
import '../../../utils/custom_exception.dart';
import '../../../view/components/text_field_component.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {

  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {

  final _passwordController = TextEditingController();
  final _repeatPasswordController = TextEditingController();

  bool _isErrorMode = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _repeatPasswordController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    String? errorMessage;
    if (validator().isEmpty) {
      try {
        final data = {
          'email': widget.email,
          'otp': widget.otp,
          'password': _passwordController.text,
        };
        final apiProvider = ApiProvider();
        final response = await apiProvider.resetPassword(data);

        if (!mounted) return;
        await showSuccessFlushbar(
          context,
          "Yeay!",
          "${response['message']}",
        );
        if (!mounted) return;
        context.go(AppRoute.loginRoute);
      } on CustomException catch (e) {
        if (kDebugMode) print("ERROR : $e");
        errorMessage = "$e";
      } catch (e) {
        if (kDebugMode) print("ERROR : $e");
        errorMessage = "$e";
      }
      setState(() {_isLoading = false;});
      if (errorMessage != null && mounted) {
        showErrorFlushbar(
          context,
          "Oops!",
          errorMessage,
        );
      }
    } else {
      setState(() {
        _isErrorMode = true;
        _isLoading = false;
      });
    }
  }

  String validator([String? field]) {
    if ((field == null || field == 'password')) {
      if (_passwordController.text.isEmpty) {
        return 'Mohon masukkan Password Anda';
      } else if (_passwordController.text.length < 6) {
        return 'Password minimal wajib 6 karakter';
      }
    }
    if ((field == null || field == 'repeat-password')) {
      if (_repeatPasswordController.text.isEmpty) {
        return 'Mohon Ulangi Password Anda';
      } else if (_repeatPasswordController.text != _passwordController.text) {
        return 'Ulangi Password tidak sama dengan Password';
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(116),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/unitomo_logo.png',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(
                  width: 24,
                ),
                Image.asset('assets/images/kampus_merdeka_logo.png',
                  height: 100,
                ),
              ],
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFieldComponent(
                controller: _passwordController,
                obscureText: _obscurePassword,
                label: 'Password',
                hint: 'masukkan password anda',
                error: _isErrorMode ? validator('password') : '',
                suffixWidget: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Text(_obscurePassword ? "Show" : "Hide",
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFieldComponent(
                controller: _repeatPasswordController,
                obscureText: _obscurePassword,
                label: 'Ulangi Password',
                hint: 'ulangi password anda',
                error: _isErrorMode ? validator('repeat-password') : '',
                suffixWidget: IconButton(
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                  icon: Text(_obscurePassword ? "Show" : "Hide",
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _resetPassword,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? Container(
                        width: 24,
                        height: 24,
                        padding: const EdgeInsets.all(2.0),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ))
                    : const Text("Reset"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
