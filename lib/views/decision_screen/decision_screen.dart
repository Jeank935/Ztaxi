import 'package:ztaxi/controller/auth_controller.dart';
import 'package:ztaxi/driver/car_registration/car_registration_template.dart';
import 'package:ztaxi/views/login_screen.dart';
import 'package:ztaxi/widgets/my_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
 import '../../widgets/green_intro_widget.dart';

class DecisionScreen extends StatelessWidget {
    DecisionScreen({super.key});


    AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            greenIntroWidget(),

            const SizedBox(height: 50,),

            DecisionButton(
              'assets/driver.png',
              'Login As Driver',
                (){
                authController.isLoginAsDriver = true;
                  Get.to(()=> CarRegistrationTemplate());
                },
              Get.width*0.8
            ),

            const SizedBox(height: 20,),
            DecisionButton(
                'assets/customer.png',
                'Login As User',
                    (){
                      authController.isLoginAsDriver = false;
                   Get.to(()=> LoginScreen());



                    },
                Get.width*0.8
            ),
          ],
        ),
      ),
    );
  }
}
