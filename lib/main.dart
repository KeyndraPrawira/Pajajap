// lib/main.dart
import 'package:e_pasar/app/services/auth_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app/routes/app_pages.dart';
import 'firebase_options.dart';

void main() async {
  // Pastikan Flutter binding sudah initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage untuk local storage
  await initializeDateFormatting('id');
  await GetStorage.init();
  await _ensureFirebaseInitialized();
  Get.put(AuthService(), permanent: true);
  runApp(const MyApp());
}

Future<FirebaseApp> _ensureFirebaseInitialized() async {
  if (Firebase.apps.isNotEmpty) {
    return Firebase.app();
  }

  try {
    return await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (error) {
    if (error.code == 'duplicate-app' && Firebase.apps.isNotEmpty) {
      return Firebase.app();
    }
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'E-Pasar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF0D47A1),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
          ),
        ),
      ),
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
    );
  }
}
