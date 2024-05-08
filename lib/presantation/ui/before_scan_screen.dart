// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:near_pay_app/app_icons.dart';
import 'package:near_pay_app/utils/user_data_util.dart';


class BeforeScanScreen extends StatefulWidget {
  const BeforeScanScreen({super.key});

  @override
  _BeforeScanScreenState createState() => _BeforeScanScreenState();
}

class _BeforeScanScreenState extends State<BeforeScanScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 150), () async {
      String scanResult = await UserDataUtil.getQRData(DataType.MANTA_ADDRESS, context);
      Navigator.pop(context, scanResult);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Hero(
        tag: 'scanButton',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(0),
          ),
          child: const Icon(
            AppIcons.scan,
            size: 50,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
