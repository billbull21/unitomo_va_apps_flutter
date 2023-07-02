import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unitomo_va_payment/routing.dart';
import 'package:unitomo_va_payment/view/components/outlined_dropdown_component.dart';
import 'package:unitomo_va_payment/view/components/text_field_component.dart';

import '../../../data/remote/api/api_provider.dart';
import '../../../environtment.dart';
import '../../../helpers/common_helper.dart';
import '../../../helpers/flushbar_helper.dart';
import '../../../models/user_model.dart';
import '../../../providers/prodi_provider.dart';
import '../../../providers/user_provider.dart';
import '../../../utils/custom_exception.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {

  final _nimController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isErrorMode = false;
  bool _obscurePassword = true;
  Map? selectedProdi;

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
    _nameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    String? errorMessage;
    if (validator().isEmpty) {
      try {
        final apiProvider = ApiProvider();
        final response = await apiProvider.doRegister({
          'nim': _nimController.text,
          'nama': _nameController.text,
          'prodi': selectedProdi!['kdprodi'],
          'no_hp': _phoneNumberController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
        });

        box.put(apiKeyPref, response['jwt_token']);

        final usersProvider = ref.read(providerUser.notifier);
        usersProvider.state = UserModel.fromJson(response['data']);

        if (!mounted) return;
        await showSuccessFlushbar(
          context,
          "Yeay!",
          "${response['message']}",
        );
        if (!mounted) return;
        context.go(AppRoute.registerOtpRoute);
      } on CustomException catch (e) {
        if (kDebugMode) print("ERROR : $e");
        setState(() {
          _isLoading = false;
        });
        errorMessage = "$e";
      } catch (e) {
        if (kDebugMode) print("ERROR : $e");
        setState(() {
          _isLoading = false;
        });
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

  String validator([String? field]) {
    if ((field == null || field == 'nim') && _nimController.text.isEmpty) {
      return 'Mohon masukkan NIM Anda';
    }
    if ((field == null || field == 'name') && _nameController.text.isEmpty) {
      return 'Mohon masukkan Nama Anda';
    }
    if ((field == null || field == 'prodi') && selectedProdi == null) {
      return 'Mohon pilih Prodi Anda';
    }
    if ((field == null || field == 'email')) {
      if (_emailController.text.isEmpty) {
        return 'Mohon masukkan Email Anda';
      } else if (!isValidEmail(_emailController.text)) {
        return 'Mohon masukkan Email Anda yang valid';
      }
    }
    if ((field == null || field == 'password')) {
      if (_passwordController.text.isEmpty) {
        return 'Mohon masukkan Password Anda';
      } else if (_passwordController.text.length < 6) {
        return 'Password minimal wajib 6 karakter';
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFieldComponent(
            controller: _nimController,
            label: 'NIM',
            hint: "masukkan NIM Anda",
            error: _isErrorMode ? validator('nim') : '',
          ),
          const SizedBox(height: 16.0),
          TextFieldComponent(
            controller: _nameController,
            label: 'Nama',
            hint: "masukkan nama Anda",
            error: _isErrorMode ? validator('name') : '',
          ),
          const SizedBox(height: 16.0),
          Consumer(
            builder: (ctx, ref2, _) {
              final asyncFetchAllProdi = ref2.watch(providerFetchAllProdi);
              return OutlinedDropdownComponent(
                label: "Prodi",
                hint: 'silahkan pilih prodi anda',
                keyName: 'namaprodi',
                selectedData: selectedProdi,
                enabled: (asyncFetchAllProdi.asData?.value ?? []).isNotEmpty,
                onWidgetTap: () {
                  // request if the list still empty
                  if ((asyncFetchAllProdi.asData?.value ?? []).isEmpty) {
                    return ref2.refresh(providerFetchAllProdi);
                  }
                },
                dataList: asyncFetchAllProdi.asData?.value ?? [],
                error: _isErrorMode ? validator('prodi') : '',
                onSelected: (value) {
                  setState(() {
                    selectedProdi = value;
                  });
                },
              );
            },
          ),
          const SizedBox(height: 16.0),
          TextFieldComponent(
            controller: _phoneNumberController,
            hint: "masukkan nomor hp Anda",
            label: 'No. HP',
          ),
          const SizedBox(height: 16.0),
          TextFieldComponent(
            controller: _emailController,
            label: 'Email',
            hint: "masukkan email Anda",
            error: _isErrorMode ? validator('email') : '',
          ),
          const SizedBox(height: 16.0),
          TextFieldComponent(
            controller: _passwordController,
            obscureText: _obscurePassword,
            label: 'Password',
            hint: 'masukkan password Anda',
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
          const SizedBox(height: 24.0),
          ElevatedButton(
            onPressed: _isLoading ? null : _register,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              minimumSize: const Size(double.infinity, 55),
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: _isLoading ? Container(
                width: 24,
                height: 24,
                padding: const EdgeInsets.all(2.0),
                child: const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                )
            ) : const Text("Daftar"),
          ),
          const SizedBox(
            height: 16,
          ),
          Center(
            child: RichText(
              text: TextSpan(
                text: "Sudah punya akun? ",
                children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => context.go(AppRoute.loginRoute),
                      child: Text('Masuk',
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.blue,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
