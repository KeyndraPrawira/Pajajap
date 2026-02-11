import 'package:flutter/material.dart';

import 'package:get/get.dart';

class KiosAddView extends GetView {
  const KiosAddView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KiosAddView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'KiosAddView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
