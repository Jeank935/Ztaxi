import 'package:elite_taxi_app/utlis/app_constant.dart';
import 'package:elite_taxi_app/widgets/pinput_widget.dart';
import 'package:elite_taxi_app/widgets/text_wiget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

Widget otpVerificationWidget() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          textWidget(text: AppConstant.phoneVerification),
          textWidget(
              text: AppConstant.enterOtp,
              fontSize: 20,
              fontWeight: FontWeight.bold),
          const SizedBox(
            height: 40,
          ),
          SizedBox(width: Get.width, height: 50, child: RoundedWithShadow()),
          const SizedBox(
            height: 40,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                    style:
                        GoogleFonts.poppins(color: Colors.black, fontSize: 12),
                    children: [
                      TextSpan(
                        text: "${AppConstant.resendCode}  ",
                      ),
                      TextSpan(
                          text: " 10 Seconds ",
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    ])),
          ),
        ],
      ),
    ),
  );
}
