import 'package:elite_taxi_app/views/otp_verification_screen.dart';
import 'package:elite_taxi_app/widgets/green_intro_widget.dart';
import 'package:elite_taxi_app/widgets/login_widget.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final countryPicker = const FlCountryCodePicker();
  CountryCode countryCode =
      CountryCode(name: 'Syria', code: "SYR", dialCode: "+963");

  onSubmit(String? input) {
    Get.to(() => OtpVerificationScreen(countryCode.dialCode+input!));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: Get.width,
        height: Get.height,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              greenIntroWidget(),
              const SizedBox(
                height: 50,
              ),
              loginWidget(countryCode, () async {
                final picked = await countryPicker.showPicker(context: context);
                // Null check
                if (picked != null) countryCode = picked;
                setState(() {});
              }, onSubmit),
            ],
          ),
        ),
      ),
    );
  }
}
