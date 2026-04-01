import 'package:e_pasar/pages/auth/bindings/complete_profile_binding.dart';
import 'package:e_pasar/pages/auth/bindings/login_binding.dart';
import 'package:e_pasar/pages/auth/views/complete_profile.dart';
import 'package:e_pasar/pages/driver/bindings/delivery_binding.dart';
import 'package:e_pasar/pages/driver/views/delivery_send_view.dart';
import 'package:e_pasar/pages/driver/views/delivery_view.dart';
import 'package:e_pasar/pages/driver/views/driver_home_view.dart';
import 'package:e_pasar/pages/pedagang/controllers/pedagang_controller.dart';
import 'package:e_pasar/pages/pedagang/controllers/produk_controller.dart';
import 'package:e_pasar/pages/pedagang/controllers/produk_form_controller.dart';
import 'package:e_pasar/pages/pedagang/views/kios_edit_view.dart';
import 'package:e_pasar/pages/pedagang/views/produk_add_view.dart';
import 'package:e_pasar/pages/pedagang/views/produk_edit_view.dart';
import 'package:e_pasar/pages/pedagang/views/produk_list_view.dart';
import 'package:e_pasar/pages/user/controllers/checkout_controller.dart';
import 'package:e_pasar/pages/user/views/checkout_view.dart';
import 'package:e_pasar/pages/user/views/user_delivery_view.dart';
import 'package:e_pasar/pages/user/views/mencari_driver_view.dart';
import 'package:e_pasar/pages/user/views/user_delivery_view.dart';
import 'package:e_pasar/pages/user/views/user_home_view.dart';
import 'package:get/get.dart';

import '../../pages/auth/bindings/auth_binding.dart';
import '../../pages/auth/views/login_view.dart';
import '../../pages/auth/views/register_view.dart';
import '../../pages/dashboard/bindings/dashboard_binding.dart';
import '../../pages/dashboard/views/dashboard_view.dart';
import '../../pages/driver/bindings/driver_binding.dart';
import '../../pages/driver/views/driver_view.dart';

import '../../pages/home/bindings/home_binding.dart';
import '../../pages/home/views/home_view.dart';
import '../../pages/pedagang/bindings/pedagang_binding.dart';

import '../../pages/pedagang/views/kios_add_view.dart';
import '../../pages/pedagang/views/pedagang_view.dart';
import '../../pages/profile/bindings/profile_binding.dart';
import '../../pages/profile/views/profile_view.dart';
import '../../pages/splash_screen/bindings/splash_screen_binding.dart';
import '../../pages/splash_screen/views/splash_screen_view.dart';
import '../../pages/user/bindings/user_binding.dart';
import '../../pages/user/views/user_view.dart';
import '../middlewares/auth_middleware.dart';
import '../middlewares/guest_middlewar.dart';
import '../middlewares/kios_middleware.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      children: [
        GetPage(
          name: _Paths.HOME,
          page: () => const HomeView(),
          binding: HomeBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => const SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(name: _Paths.CHECKOUT, 
    page: () => const CheckoutView(),
    binding: BindingsBuilder(() {
      Get.lazyPut<CheckoutController>(() => CheckoutController());
    })),
    GetPage(
  name: AppRoutes.MENCARI_DRIVER,
  page: () => const MencariDriverView(),
  middlewares: [AuthMiddleware(requiredRole: 'user')],
),  
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
      children: [
        GetPage(
          name: _Paths.DASHBOARD,
          page: () => const DashboardView(),
          binding: DashboardBinding(),
        ),
      ],
    ),
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      middlewares: [
        GuestMiddleware()
      ], // Kalau udah login, ga bisa akses login page
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => const RegisterView(),
      binding: LoginBinding(),
      middlewares: [GuestMiddleware()],
    ),
    GetPage(
      name: AppRoutes.COMPLETE_PROFILE,
      page: () =>const CompleteProfileView(),
      binding: CompleteProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.PEDAGANG_HOME,
      page: () => const PedagangView(),
      binding: PedagangBinding(),
      middlewares: [
        AuthMiddleware(requiredRole: 'pedagang')
      ], // Harus login dulu
    ),
    GetPage(
      name: AppRoutes.DRIVER_HOME,
      page: () => const DriverView(),
      binding: DriverBinding(),
      middlewares: [AuthMiddleware(requiredRole: 'driver')],


    ),
    GetPage(
      name: AppRoutes.USER_HOME,
      page: () => const UserView(),
      binding: UserBinding(),
      middlewares: [AuthMiddleware(requiredRole: 'user')],
    ),
    GetPage(
  name: _Paths.PEDAGANG,
  page: () => const PedagangView(),
  binding: PedagangBinding(),
  children: [
    GetPage(
      name: '/produk',
      page: () => const ProdukListView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProdukController>(() => ProdukController());
      }),
    ),
    GetPage(
      name: '/produk/create',
      page: () => const ProdukAddView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProdukFormController>(() => ProdukFormController());
      }),
    ),
    GetPage(
      name: '/produk/edit/:id',
      page: () => const ProdukEditView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProdukFormController>(() => ProdukFormController());
      }),
    ),
    ],
  ),
    GetPage(
      name: _Paths.DRIVER,
      page: () => const DriverView(),
      binding: DriverBinding(),


    ),
GetPage(
      name: _Paths.DELIVERY_CHECK,
      page: () => const DeliveryView(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: _Paths.USER_DELIVERY,
      page: () => const UserDeliveryView(),
      binding: UserBinding(),
      middlewares: [AuthMiddleware(requiredRole: 'user')],
    ),
GetPage(name: AppRoutes.DELIVERY_SEND,
     page: () => const DeliverySendView(),
     binding: DeliveryBinding()),
    GetPage(
      name: AppRoutes.USER_DELIVERY,
      page: () => const UserDeliveryView(),
      binding: UserBinding(),
    ),
    GetPage(
      name: _Paths.USER,
      page: () => const UserView(),
      binding: UserBinding(),
    ),
   
    GetPage(
        name: _Paths.KIOS_ADD,
        page: () => const KiosAddView(),
        binding: PedagangBinding(),
        middlewares: [KiosMiddleware()]),
  ];

  static get middlewares => null;
}
