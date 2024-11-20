import 'package:go_router/go_router.dart';
import 'package:mbosswater/features/active_success/active_success_page.dart';
import 'package:mbosswater/features/customer/presentation/page/customer_detail_page.dart';
import 'package:mbosswater/features/customer/presentation/page/customer_list_page.dart';
import 'package:mbosswater/features/guarantee/data/model/customer.dart';
import 'package:mbosswater/features/guarantee/data/model/guarantee.dart';
import 'package:mbosswater/features/guarantee/data/model/product.dart';
import 'package:mbosswater/features/guarantee/presentation/page/guarantee_activate_page.dart';
import 'package:mbosswater/features/guarantee/presentation/page/guarantee_history_page.dart';
import 'package:mbosswater/features/home/home_page.dart';
import 'package:mbosswater/features/login/presentation/page/login_page.dart';
import 'package:mbosswater/features/qrcode_scanner/presentation/page/qrcode_scanner_page.dart';
import 'package:mbosswater/features/recovery/presentation/page/change_password_page.dart';
import 'package:mbosswater/features/recovery/presentation/page/forgot_password_page.dart';
import 'package:mbosswater/features/splash/presentation/page/splash_page.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (context, state) => ChangePasswordPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomePage(),
    ),
    GoRoute(
      path: '/guarantee-active',
      builder: (context, state) {
        final data = state.extra as Product?;
        return GuaranteeActivatePage(product: data);
      },
    ),
    GoRoute(
      path: '/active-success',
      builder: (context, state) => const ActiveSuccessPage(),
    ),
    GoRoute(
      path: '/customer-detail',
      builder: (context, state) {
        final data = state.extra as Customer?;
        return CustomerDetailPage(customer: data);
      },
    ),
    GoRoute(
      path: '/guarantee-history',
      builder: (context, state) {
        final data = state.extra as Guarantee;
        return GuaranteeHistoryPage(guarantee: data);
      },
    ),
    GoRoute(
      path: '/customer-list',
      builder: (context, state) => const CustomerListPage(),
    ),
  ],
);
