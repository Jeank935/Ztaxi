import 'package:elite_taxi_app/utlis/app_constant.dart';
import 'package:elite_taxi_app/widgets/text_wiget.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget loginWidget(CountryCode countryCode, Function onCountryChange,Function onSubmit) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textWidget(text: AppConstant.helloNiceToMeetYou),
        textWidget(
            text: AppConstant.getMovingWhiteGreenTaxi,
            fontSize: 20,
            fontWeight: FontWeight.bold),
        const SizedBox(
          height: 40,
        ),
        Container(
          width: double.infinity,
          height: 55,
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 3,
                    blurRadius: 3)
              ],
              borderRadius: BorderRadius.circular(8)),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: InkWell(
                  onTap: () => onCountryChange(),
                  child: Container(
                    child: Row(
                      children: [
                        const SizedBox(width: 5),
                        Expanded(
                            child: Container(
                          child: countryCode.flagImage(),
                        )),
                        textWidget(text: countryCode.dialCode),
                        Icon(Icons.arrow_downward_rounded)
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 55,
                color: Colors.black.withOpacity(0.2),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    onSubmitted: (String? input)=>onSubmit(input),

                    decoration: InputDecoration(
                      hintStyle: GoogleFonts.poppins(
                          fontSize: 15, fontWeight: FontWeight.normal),
                      hintText: AppConstant.enterMobileNumber,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                  style: GoogleFonts.poppins(color: Colors.black, fontSize: 12),
                  children: [
                    TextSpan(
                      text: "${AppConstant.byCreating}  ",
                    ),
                    TextSpan(
                        text: "${AppConstant.termsOfService}  ",
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: "and ",
                    ),
                    TextSpan(
                        text: "${AppConstant.privacyPolicy} ",
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  ])),
        ),
      ],
    ),
  );
}
