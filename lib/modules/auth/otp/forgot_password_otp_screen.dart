import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:unitomo_va_payment/routing.dart';

import '../../../helpers/flushbar_helper.dart';
import '../../../utils/custom_exception.dart';
import '../../../view/components/text_field_component.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {

  final String email;

  const ForgotPasswordOtpScreen({super.key, required this.email});

  @override
  State<ForgotPasswordOtpScreen> createState() => _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {

  final List<FocusNode> _otpFocusNode = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];
  final List<String> _otpValues = ['', '', '', ''];

  final List<TextInputFormatter> _inputFormatters = [
    LengthLimitingTextInputFormatter(1),
  ];

  bool _isLoading = false;
  bool _isErrorMode = false;

  void _verifyOtp() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });
    String? errorMessage;
    if (_otpValues.where((e) => e.trim().isEmpty).isEmpty) {
      try {
        final otp = _otpValues.join("");
        context.goNamed(AppRoute.resetPassword,
          pathParameters: {
            'email': widget.email,
            'otp': otp,
          }
        );
      } on CustomException catch (e) {
        errorMessage = "$e";
      } catch (e) {
        errorMessage = "$e";
      }
      if (errorMessage != null && mounted) {
        if (kDebugMode) print("ERROR : $errorMessage");
        setState(() {
          _isLoading = false;
        });
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

  String validateErrorOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the OTP';
    }
    return '';
  }

  @override
  void dispose() {
    _otpFocusNode.map((e) => e.dispose()).toList();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Reset Password",
                      style: textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "Masukkan 4 digit kode Aktivasi yang telah kami kirim ke email ",
                        children: [
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        ],
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 36,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _otpValues.length,
                        (index) => Container(
                      width: 55,
                      height: 55,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: SizedBox(
                        height: 55,
                        child: TextFieldComponent(
                          focusNode: _otpFocusNode[index],
                          textAlign: TextAlign.center,
                          isNum: true,
                          isNumWithoutCurrency: true,
                          inputFormatters: _inputFormatters,
                          onChanged: (value) {
                            setState(() {
                              _otpValues[index] = value;
                            });
                            if (value.isNotEmpty) {
                              if (index < 3) {
                                FocusScope.of(context).requestFocus(_otpFocusNode[index + 1]);
                              } else {
                                FocusScope.of(context).unfocus();
                                // Perform any necessary action with the OTP8
                              }
                            } else {
                              if (index > 0) {
                                FocusScope.of(context).requestFocus(_otpFocusNode[index - 1]);
                              }
                            }
                          },
                          error: _isErrorMode ? validateErrorOTP(_otpValues[index]) : '',
                          showError: false,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    minimumSize: const Size(150, 55),
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
                    ),
                  )
                      : const Text("Verify"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}