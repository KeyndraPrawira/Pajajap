part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();
  static const HOME = _Paths.PAGES + _Paths.HOME;
  static const AUTH = _Paths.PAGES + _Paths.AUTH;
  static const SPLASH_SCREEN = _Paths.PAGES + _Paths.SPLASH_SCREEN;
  static const PROFILE = _Paths.PAGES + _Paths.PROFILE;
  static const DASHBOARD = _Paths.PAGES + _Paths.DASHBOARD;
  static const PEDAGANG = _Paths.PAGES + _Paths.PEDAGANG;
  static const DRIVER = _Paths.PAGES + _Paths.DRIVER;
  static const USER = _Paths.PAGES + _Paths.USER;
  static const KIOS = _Paths.PAGES + _Paths.KIOS;
  static const KIOS_ADD = _Paths.PAGES + _Paths.KIOS_ADD;
  static const KIOS_UPDATE = _Paths.PAGES + _Paths.KIOS_UPDATE;
  static const PRODUK_LIST = _Paths.PAGES + _Paths.PRODUK_LIST;
  static const PRODUK_ADD = _Paths.PAGES + _Paths.PEDAGANG + _Paths.PRODUK_ADD;
  static const PRODUK_EDIT = _Paths.PAGES + _Paths.PEDAGANG + _Paths.PRODUK_EDIT;
  static const COMPLETE_PROFILE = _Paths.PAGES + _Paths.COMPLETE_PROFILE;
  static const CHECKOUT = _Paths.PAGES + _Paths.CHECKOUT;
  static const MENCARI_DRIVER = _Paths.PAGES + _Paths.MENCARI_DRIVER;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const AUTH = '/auth';
  static const COMPLETE_PROFILE = '/complete-profile';
  static const SPLASH_SCREEN = '/splash-screen';
  static const PROFILE = '/profile';
  static const DASHBOARD = '/dashboard';
  static const PEDAGANG = '/pedagang';
  static const DRIVER = '/driver';
  static const USER = '/user';
  static const PAGES = '';
  static const KIOS = '/kios';
  static const KIOS_ADD = '/pedagang/kios/create';
  static String kiosUpdate(int id) => '/pedagang/kios/edit/$id';
  static const KIOS_UPDATE = '/pedagang/kios/edit/:id';
  static const PRODUK_LIST = '/produk';
  static const PRODUK_ADD = '/produk/create';
  static const PRODUK_EDIT = '/produk/edit/:id';
  static String produkEdit(int id) => '/produk/edit/$id';
  static const CHECKOUT = '/checkout';
  static const MENCARI_DRIVER = '/mencari-driver';

}

abstract class AppRoutes {
  static const SPLASH = '/';
  static const LOGIN = '/login';
  static const REGISTER = '/register';
  static const COMPLETE_PROFILE = '/complete-profile';

  // Pedagang Routes
  static const PEDAGANG_HOME = '/pedagang/home';

  // Driver Routes
  static const DRIVER_HOME = '/driver/home';

  // User Routes
  static const USER_HOME = '/user/home';
  static const KIOS = '/kios';
  static const KIOS_ADD = '/pedagang/kios/create';
  static String kiosUpdate(int id, param1) => '/pedagang/kios/edit/$id';
  static const KIOS_UPDATE = '/pedagang/kios/edit/:id';

// Pedagang Routes
  static const PRODUK_LIST = '/produk';
  static const PRODUK_ADD = '/produk/create';
  static const PRODUK_EDIT = '/produk/edit/:id';
  static String produkEdit(int id) => '/produk/edit/$id';

  static const CHECKOUT = '/checkout';
  static const MENCARI_DRIVER = '/mencari-driver';
}
