import 'dart:io';

import 'package:elite_taxi_app/controller/auth_controller.dart';
import 'package:elite_taxi_app/utlis/app_colors.dart';
import 'package:elite_taxi_app/widgets/green_intro_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController homeController = TextEditingController();
  TextEditingController businessController = TextEditingController();
  TextEditingController ShopeController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  AuthController authController = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      selectedImage = File(image.path);
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    nameController.text = authController.myUser.value.name ?? "";
    homeController.text = authController.myUser.value.hAddress ?? "";
    ShopeController.text = authController.myUser.value.mallAddress ?? "";
    businessController.text = authController.myUser.value.bAddress ?? "";
  }

  late LatLng homeAddress;
  late LatLng businessAddress;
  late LatLng shoppingAddress;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: Get.height * 0.4,
              child: Stack(
                children: [
                  greenIntroWidgetWithoutLogos(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: InkWell(
                      onTap: () {
                        getImage(ImageSource.camera);
                      },
                      child: selectedImage == null
                          ? Container(
                              width: 120,
                              height: 120,
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xffD6D6D6)),
                              child: Center(
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Container(
                              width: 120,
                              height: 120,
                              margin: EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: FileImage(selectedImage!),
                                      fit: BoxFit.cover),
                                  shape: BoxShape.circle,
                                  color: Color(0xffD6D6D6)),
                            ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 23),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFieldWidget(
                        'Name',
                        Icons.person_outlined,
                        nameController,
                        (String? input) {
                          if (input!.isEmpty) {
                            return 'Name is required';
                          }
                          if (input.length < 5) {
                            return 'Please enter a valid name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 10),
                      TextFieldWidget('Business Address', Icons.card_travel,
                          businessController, (String? input) {
                        if (input!.isEmpty) {
                          return 'Business Address is required';
                        }
                        return null;
                      }),
                      SizedBox(height: 10),
                      TextFieldWidget('Home Address', Icons.home_max_rounded,
                          homeController, (String? input) {
                        if (input!.isEmpty) {
                          return ' Home Address is required';
                        }
                        return null;
                      }, onTap: () async {
                        Prediction? p = await authController
                            .showGoogleAutoComplete(context);

                        /// now  let's translate this selected address and convert  it to latlg obj

                        LatLng homeAddress = await authController
                            .buildLatLngFromAddress(p!.description!);
                            homeController.text = p.description!;



                        /// store the information into the firebase together once update is clicked
                      }, readOnly: true),
                      SizedBox(height: 10),
                      TextFieldWidget(
                          'Shopping Center',
                          Icons.shopping_cart_outlined,
                          ShopeController, (String? input) {
                        if (input!.isEmpty) {
                          return 'Shopping Center is required';
                        }
                        return null;
                      }),
                      SizedBox(height: 10),
                      const SizedBox(height: 30),
                      Obx(
                        () => authController.isProfileUploading.value
                            ? Center(child: CircularProgressIndicator())
                            : greenButton("Update", () {
                                if (!formKey.currentState!.validate()) {
                                  return;
                                }

                                authController.isProfileUploading(true);

                                authController.storeUserInfo(
                                    selectedImage,
                                    nameController.text,
                                    homeController.text,
                                    businessController.text,
                                    ShopeController.text,
                                    url: authController.myUser.value.image ??
                                        "",homeLatLng: homeAddress,
                                        shoppingLatLng: shoppingAddress,
                                        businessLatLng: businessAddress);
                              }),
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}

TextFieldWidget(String title, IconData iconData,
    TextEditingController controller, Function validator,
    {Function? onTap, bool readOnly = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xffA7A7A7)),
      ),
      const SizedBox(
        height: 6,
      ),
      Container(
        width: Get.width,
        // height: 50,
        decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  spreadRadius: 1,
                  blurRadius: 1)
            ],
            borderRadius: BorderRadius.circular(8)),
        child: TextFormField(
          readOnly: readOnly,
          onTap: () => onTap!(),
          validator: (input) => validator(input),
          controller: controller,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xffA7A7A7)),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Icon(
                iconData,
                color: AppColors.greenColor,
              ),
            ),
            border: InputBorder.none,
          ),
        ),
      )
    ],
  );
}

Widget greenButton(String title, Function onPressed) {
  return MaterialButton(
    minWidth: Get.width,
    height: 50,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    color: const Color(0xFF2DBB54),
    onPressed: () => onPressed(),
    child: Text(
      title,
      style: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    ),
  );
}
