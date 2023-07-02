import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unitomo_va_payment/modules/auth/login/login_screen.dart';
import 'package:unitomo_va_payment/modules/auth/otp/forgot_password_otp_screen.dart';
import 'package:unitomo_va_payment/modules/auth/otp/register_otp_screen.dart';
import 'package:unitomo_va_payment/modules/auth/register/register_screen.dart';
import 'package:unitomo_va_payment/modules/detail_va_payment/detail_va_payment.dart';
import 'package:unitomo_va_payment/modules/form_generate_va/form_generate_va_screen.dart';
import 'package:unitomo_va_payment/modules/home/home_screen.dart';
import 'package:unitomo_va_payment/modules/payment_code/payment_code_screen.dart';

import 'environtment.dart';
import 'modules/auth/reset_password/reset_password_screen.dart';

class AppRoute {

  static const loginRoute = "/login";
  static const registerRoute = "/register";
  static const registerOtpRoute = "/register-otp";
  static const forgotPasswordOtpRoute = "/forgot-password-otp";
  static const resetPassword = "/reset-password";
  static const formGenerateVaRoute = "/form-generate-va";
  static const paymentCodeRoute = "/payment-code";
  static const detailVaRoute = "/detail-va";

}

final router = GoRouter(
  routes: [
    GoRoute(
      path: "/",
      name: "/",
      builder: (context, state) => const HomeScreen(),
      redirect: (ctx, state) async {
        if (!Hive.isBoxOpen(boxName)) await Hive.openBox(boxName);
        final box = Hive.box(boxName);
        if (box.get(apiKeyPref) == null) return '/login';
        return null;
      },
    ),
    GoRoute(
      path: AppRoute.loginRoute,
      name: AppRoute.loginRoute,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoute.registerRoute,
      name: AppRoute.registerRoute,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoute.registerOtpRoute,
      name: AppRoute.registerOtpRoute,
      builder: (context, state) => const RegisterOtpScreen(),
    ),
    GoRoute(
      path: AppRoute.forgotPasswordOtpRoute,
      name: AppRoute.forgotPasswordOtpRoute,
      builder: (context, state) => ForgotPasswordOtpScreen(
        email: state.queryParameters['email'] ?? '',
      ),
    ),
    GoRoute(
      path: AppRoute.formGenerateVaRoute,
      name: AppRoute.formGenerateVaRoute,
      builder: (context, state) => const FormGenerateVaScreen(),
    ),
    GoRoute(
      path: AppRoute.paymentCodeRoute,
      name: AppRoute.paymentCodeRoute,
      builder: (context, state) => const PaymentCodeScreen(),
    ),
    GoRoute(
      path: AppRoute.resetPassword,
      name: AppRoute.resetPassword,
      builder: (context, state) => ResetPasswordScreen(
        email: state.queryParameters['email'] ?? '',
        otp: state.queryParameters['otp'] ?? '',
      ),
    ),
    GoRoute(
      path: AppRoute.detailVaRoute,
      name: AppRoute.detailVaRoute,
      builder: (context, state) => DetailVaPayment(
        idVa: state.queryParameters['id'] ?? '',
      ),
    ),
  ],
);