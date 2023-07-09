import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unitomo_va_payment/modules/auth/login/forgot_password_dialog.dart';
import 'package:unitomo_va_payment/routing.dart';

import '../../../data/remote/api/api_provider.dart';
import '../../../environtment.dart';
import '../../../helpers/flushbar_helper.dart';
import '../../../models/user_model.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/custom_exception.dart';
import '../../../view/components/text_field_component.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {

  final _nimController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isErrorMode = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  late final Box box;

  @override
  void initState() {
    super.initState();
    box = Hive.box(boxName);
    box.delete(apiKeyPref);
  }

  @override
  void dispose() {
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    String? errorMessage;
    if (
      _nimController.text.isNotEmpty
      && _passwordController.text.isNotEmpty
    ) {
      try {
        final apiProvider = ApiProvider();
        final response = await apiProvider.doLogin(
          _nimController.text,
          _passwordController.text,
        );

        box.put(apiKeyPref, response['jwt_token']);

        final usersProvider = ref.read(providerUser.notifier);
        usersProvider.state = UserModel.fromJson(response['data']);

        if (!mounted) return;
        if ((usersProvider.state!.status ?? 0) != 1) {
          context.go('/otp');
        } else {
          context.go('/');
        }
      } on CustomException catch (e) {
        if (kDebugMode) print("ERROR : $e");
        setState(() {_isLoading = false;});
        errorMessage = "$e";
      } catch (e) {
        if (kDebugMode) print("ERROR : $e");
        setState(() {_isLoading = false;});
        errorMessage = "$e";
      }
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
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFieldComponent(
                  controller: _nimController,
                  label: 'NIM',
                  hint: 'masukkan nim anda',
                  error: _isErrorMode && _nimController.text.isEmpty ? 'Mohon masukkan NIM Anda' : '',
                ),
                const SizedBox(height: 16.0),
                TextFieldComponent(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  label: 'Password',
                  hint: 'masukkan password anda',
                  error: _isErrorMode && _passwordController.text.isEmpty ? 'Mohon masukkan Password Anda' : '',
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
                  onPressed: _isLoading ? null : _login,
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
                      : const Text("MASUK"),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    // forgot password dialog
                    // create dialog to show email
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          backgroundColor: Colors.white,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: 400,
                            ),
                            child: const ForgotPasswordDialog(),
                          ),
                        );
                      },
                    );
                  },
                  child: Text("Lupa Password?",
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => context.go(AppRoute.registerRoute),
                  child: Text("Belum punya akun? Daftar disini",
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
