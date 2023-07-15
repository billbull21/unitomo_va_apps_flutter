import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unitomo_va_payment/models/user_model.dart';
import 'package:unitomo_va_payment/providers/user_provider.dart';
import 'package:unitomo_va_payment/view/components/outlined_dropdown_component.dart';
import 'package:unitomo_va_payment/view/components/text_field_component.dart';

import '../../../data/remote/api/api_provider.dart';
import '../../../helpers/common_helper.dart';
import '../../../helpers/flushbar_helper.dart';
import '../../../providers/prodi_provider.dart';
import '../../../utils/custom_exception.dart';
import '../home/home_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  final _nimController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isErrorMode = false;
  bool _isEditMode = false;
  bool _isChangePasswordMode = false;
  Map? _selectedProdi;

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    final user = ref.read(providerCheckUserStatus.future);
    final listProdi = ref.read(providerFetchAllProdi.future);
    user.then((data) {
      _nimController.text = data?.nim ?? "";
      _nameController.text = data?.nama ?? "";
      _phoneNumberController.text = data?.noHp ?? "";
      _emailController.text = data?.email ?? "";
      listProdi.then((value) {
        _selectedProdi = value.firstWhere((el) => el['kdprodi'] == data?.prodiId);
        setState(() {});
      });
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nimController.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _updatePassword() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    String? errorMessage;
    if (_passwordValidator().isEmpty) {
      try {
        final apiProvider = ApiProvider();
        final response = await apiProvider.changePassword({
          'password': _currentPasswordController.text,
          'new_password': _newPasswordController.text,
        });

        if (!mounted) return;
        await showSuccessFlushbar(
        context,
        "Yeay!",
        "${response['message']}",
        );
      } on CustomException catch (e) {
        errorMessage = "$e";
      } catch (e) {
        errorMessage = "$e";
      }
      setState(() {
        _isLoading = false;
      });
      if (errorMessage != null && mounted) {
        if (kDebugMode) print("ERROR : $errorMessage");
        showErrorFlushbar(
          context,
          "Oops!",
          errorMessage,
        );
      } else {
        setState(() {
          _isChangePasswordMode = false;
          _isEditMode = false;
        });
        // ref.invalidate(providerCheckUserStatus);
        // if (kIsWeb) html.window.location.reload();
      }
    } else {
      setState(() {
        _isErrorMode = true;
        _isLoading = false;
      });
    }
  }

  void _updateProfile() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    String? errorMessage;
    if (_profileValidator().isEmpty) {
      try {
        final apiProvider = ApiProvider();
        final response = await apiProvider.updateProfile({
          'nim': _nimController.text,
          'nama': _nameController.text,
          'prodi': _selectedProdi!['kdprodi'],
          'no_hp': _phoneNumberController.text,
          'email': _emailController.text,
        });

        if (!mounted) return;
        await showSuccessFlushbar(
          context,
          "Yeay!",
          "${response['message']}",
        );
      } on CustomException catch (e) {
        errorMessage = "$e";
      } catch (e) {
        errorMessage = "$e";
      }
      setState(() {
        _isLoading = false;
      });
      if (errorMessage != null && mounted) {
        if (kDebugMode) print("ERROR : $errorMessage");
        showErrorFlushbar(
          context,
          "Oops!",
          errorMessage,
        );
      } else {
        setState(() {_isEditMode = false;});
        ref.invalidate(providerCheckUserStatus);
        // if (kIsWeb) html.window.location.reload();
      }
    } else {
      setState(() {
        _isErrorMode = true;
        _isLoading = false;
      });
    }
  }

  String _profileValidator([String? field]) {
    if ((field == null || field == 'nim') && _nimController.text.isEmpty) {
      return 'Mohon masukkan NIM Anda';
    }
    if ((field == null || field == 'name') && _nameController.text.isEmpty) {
      return 'Mohon masukkan Nama Anda';
    }
    if ((field == null || field == 'prodi') && _selectedProdi == null) {
      return 'Mohon pilih Prodi Anda';
    }
    if ((field == null || field == 'email')) {
      if (_emailController.text.isEmpty) {
        return 'Mohon masukkan Email Anda';
      } else if (!isValidEmail(_emailController.text)) {
        return 'Mohon masukkan Email Anda yang valid';
      }
    }
    return '';
  }

  String _passwordValidator([String? field]) {
    if ((field == null || field == 'current_password')) {
      if (_currentPasswordController.text.isEmpty) {
        return 'Mohon masukkan Password Sekarang Anda';
      } else if (_currentPasswordController.text.length < 6) {
        return 'Password minimal wajib 6 karakter';
      }
    }
    if ((field == null || field == 'new_password')) {
      if (_newPasswordController.text.isEmpty) {
        return 'Mohon masukkan Password Baru Anda';
      } else if (_newPasswordController.text.length < 6) {
        return 'Password minimal wajib 6 karakter';
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(providerUser);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
          ),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (_isChangePasswordMode) ..._changePasswordView()
              else ..._profileView(userData),
              if (_isEditMode) ...[
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _isChangePasswordMode ? _updatePassword : _updateProfile,
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
                    ),
                  ) : Text(_isChangePasswordMode ? "Update Password" : "Update Profile"),
                ),
                const SizedBox(height: 16.0),
                OutlinedButton(
                  onPressed: () => setState(() {
                    _isEditMode = false;
                    _isChangePasswordMode = false;
                  }),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(double.infinity, 55),
                    foregroundColor: Colors.red,
                  ),
                  child: const Text("Batal"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _changePasswordView() {
    final textTheme = Theme.of(context).textTheme;
    return [
      TextFieldComponent(
        controller: _currentPasswordController,
        obscureText: _obscureCurrentPassword,
        label: 'Password Sekarang',
        hint: 'masukkan password Anda',
        error: _isErrorMode ? _passwordValidator('current_password') : '',
        suffixWidget: IconButton(
          onPressed: () {
            setState(() {
              _obscureCurrentPassword = !_obscureCurrentPassword;
            });
          },
          icon: Text(_obscureCurrentPassword ? "Show" : "Hide",
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.blue,
            ),
          ),
        ),
      ),
      const SizedBox(height: 16.0),
      TextFieldComponent(
        controller: _newPasswordController,
        obscureText: _obscureNewPassword,
        label: 'Password',
        hint: 'masukkan password Anda',
        error: _isErrorMode ? _passwordValidator('new_password') : '',
        suffixWidget: IconButton(
          onPressed: () {
            setState(() {
              _obscureNewPassword = !_obscureNewPassword;
            });
          },
          icon: Text(_obscureNewPassword ? "Show" : "Hide",
            style: textTheme.bodyLarge?.copyWith(
              color: Colors.blue,
            ),
          ),
        ),
      ),
    ];
  }

  List<Widget> _profileView(UserModel? userData) {
    return [
      if (!_isEditMode)
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _isEditMode = true;
                }),
                child: const Text("Update Profile"),
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _isEditMode = true;
                  _isChangePasswordMode = true;
                }),
                child: const Text("Update Password"),
              ),
            ),
          ],
        ),
      const SizedBox(height: 16.0),
      TextFieldComponent(
        controller: _nimController,
        label: 'NIM',
        hint: "masukkan NIM Anda",
        readonly: !_isEditMode,
        error: _isErrorMode ? _profileValidator('nim') : '',
      ),
      const SizedBox(height: 16.0),
      TextFieldComponent(
        controller: _nameController,
        label: 'Nama',
        hint: "masukkan nama Anda",
        readonly: !_isEditMode,
        error: _isErrorMode ? _profileValidator('name') : '',
      ),
      const SizedBox(height: 16.0),
      Consumer(
        builder: (ctx, ref2, _) {
          final asyncFetchAllProdi = ref2.watch(providerFetchAllProdi);
          ref2.listen(providerFetchAllProdi, (previous, next) {
            _selectedProdi = next.value?.firstWhere((e) => e['kdprodi'] == userData?.prodiId);
          });
          return OutlinedDropdownComponent(
            label: "Prodi",
            hint: 'silahkan pilih prodi anda',
            keyName: 'namaprodi',
            selectedData: _selectedProdi,
            readonly: !_isEditMode,
            enabled: (asyncFetchAllProdi.asData?.value ?? []).isNotEmpty,
            onWidgetTap: () {
              // request if the list still empty
              if ((asyncFetchAllProdi.asData?.value ?? []).isEmpty) {
                return ref2.refresh(providerFetchAllProdi);
              }
            },
            dataList: asyncFetchAllProdi.asData?.value ?? [],
            error: _isErrorMode ? _profileValidator('prodi') : '',
            onSelected: (value) {
              setState(() {
                _selectedProdi = value;
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
        readonly: !_isEditMode,
      ),
      const SizedBox(height: 16.0),
      TextFieldComponent(
        controller: _emailController,
        label: 'Email',
        hint: "masukkan email Anda",
        readonly: !_isEditMode,
        error: _isErrorMode ? _profileValidator('email') : '',
      ),
    ];
  }

}
