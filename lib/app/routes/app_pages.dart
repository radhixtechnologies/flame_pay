import '../../modules/legal/views/legal_policy_view.dart';
import 'package:get/get.dart';
import 'app_routes.dart';
import 'auth_middleware.dart';

// Phase 1
import '../../modules/splash/splash_binding.dart';
import '../../modules/splash/views/splash_view.dart';
import '../../modules/onboarding/onboarding_binding.dart';
import '../../modules/onboarding/views/onboarding_view.dart';
import '../../modules/auth/auth_binding.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/otp_view.dart';
import '../../modules/auth/views/registration_view.dart';
import '../../modules/auth/views/mpin_setup_view.dart';

// Phase 2
import '../../modules/home/home_binding.dart';
import '../../modules/home/views/home_shell_view.dart';
import '../../modules/home/views/all_services_view.dart';
import '../../modules/wallet/wallet_binding.dart';
import '../../modules/wallet/views/wallet_view.dart';
import '../../modules/wallet/views/add_money_view.dart';
import '../../modules/wallet/views/send_money_view.dart';

// Phase 3
import '../../modules/recharge/recharge_binding.dart';
import '../../modules/recharge/views/recharge_view.dart';
import '../../modules/bill_payment/bill_payment_binding.dart';
import '../../modules/bill_payment/views/bill_payment_view.dart';

// Phase 4
import '../../modules/cibil/cibil_binding.dart';
import '../../modules/cibil/views/cibil_view.dart';
import '../../modules/credit_card/credit_card_binding.dart';
import '../../modules/credit_card/views/credit_card_view.dart';
import '../../modules/loan/loan_binding.dart';
import '../../modules/loan/views/loan_view.dart';
import '../../modules/insurance/insurance_binding.dart';
import '../../modules/insurance/views/insurance_view.dart';

// Phase 5
import '../../modules/history/history_binding.dart';
import '../../modules/history/views/history_view.dart';
import '../../modules/offers/offers_binding.dart';
import '../../modules/offers/views/offers_view.dart';
import '../../modules/notifications/notifications_binding.dart';
import '../../modules/notifications/views/notifications_view.dart';
import '../../modules/profile/profile_binding.dart';
import '../../modules/profile/views/profile_view.dart';
import '../../modules/kyc/kyc_binding.dart';
import '../../modules/kyc/views/kyc_view.dart';
import '../../modules/support/support_binding.dart';
import '../../modules/support/views/support_view.dart';

class AppPages {
  AppPages._();

  static const String initial = AppRoutes.splash;

  static final List<GetPage> pages = [
    // Phase 1
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fade,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpView(),
      binding: OtpBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.registration,
      page: () => const RegistrationView(),
      binding: RegistrationBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.mpinSetup,
      page: () => const MpinSetupView(),
      binding: MpinSetupBinding(),
      transition: Transition.rightToLeft,
    ),

    // Phase 2: Home Dashboard, All Services, Wallet & Bottom Navigation
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeShellView(),
      binding: HomeBinding(),
      middlewares: [AuthMiddleware()],
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.allServices,
      page: () => const AllServicesView(),
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.wallet,
      page: () => const WalletView(),
      binding: WalletBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.sendMoney,
      page: () => const SendMoneyView(),
      binding: WalletBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: '/wallet/add-money',
      page: () => const AddMoneyView(),
      binding: WalletBinding(),
      transition: Transition.rightToLeft,
    ),

    // Phase 3: Mobile / DTH Recharge & Bill Payment
    GetPage(
      name: AppRoutes.recharge,
      page: () => const RechargeView(),
      binding: RechargeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.billPayment,
      page: () => const BillPaymentView(),
      binding: BillPaymentBinding(),
      transition: Transition.rightToLeft,
    ),

    // Phase 4: Financial Services (CIBIL, Credit Cards, Instant Loans, Insurance)
    GetPage(
      name: AppRoutes.cibil,
      page: () => const CibilView(),
      binding: CibilBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.creditCard,
      page: () => const CreditCardView(),
      binding: CreditCardBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.loan,
      page: () => const LoanView(),
      binding: LoanBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.insurance,
      page: () => const InsuranceView(),
      binding: InsuranceBinding(),
      transition: Transition.rightToLeft,
    ),

    // Phase 5: History, Offers, Notifications, Profile, KYC & Support
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.offers,
      page: () => const OffersView(),
      binding: OffersBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.kyc,
      page: () => const KycView(),
      binding: KycBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.support,
      page: () => const SupportView(),
      binding: SupportBinding(),
      transition: Transition.rightToLeft,
    ),

    // Legal
    GetPage(
      name: AppRoutes.terms,
      page: () => const LegalPolicyView(initialTabIndex: 0),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.privacy,
      page: () => const LegalPolicyView(initialTabIndex: 1),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.refundPolicy,
      page: () => const LegalPolicyView(initialTabIndex: 2),
      transition: Transition.rightToLeft,
    ),
  ];
}
