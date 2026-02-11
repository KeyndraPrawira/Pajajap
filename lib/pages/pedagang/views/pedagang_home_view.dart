import 'package:flutter/material.dart';

import 'package:get/get.dart';

class PedagangHomeView extends GetView {
  const PedagangHomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PedagangHomeView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'PedagangHomeView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
