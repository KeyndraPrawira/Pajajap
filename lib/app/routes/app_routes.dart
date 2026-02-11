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
}


abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const AUTH = '/auth';
  static const SPLASH_SCREEN = '/splash-screen';
  static const PROFILE = '/profile';
  static const DASHBOARD = '/dashboard';
  static const PEDAGANG = '/pedagang';
  static const DRIVER = '/driver';
  static const USER = '/user';
  static const PAGES = '';
}

abstract class AppRoutes {
  static const SPLASH = '/';
  static const LOGIN = '/login';
  static const REGISTER = '/register';

  // Pedagang Routes
  static const PEDAGANG_HOME = '/pedagang/home';

  // Driver Routes
  static const DRIVER_HOME = '/driver/home';

  // User Routes
  static const USER_HOME = '/user/home';
}
