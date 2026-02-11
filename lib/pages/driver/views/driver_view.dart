import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/driver_controller.dart';

class DriverView extends GetView<DriverController> {
  const DriverView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DriverView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'DriverView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
