import 'dart:async';
import 'dart:io';

import 'package:elite_taxi_app/driver/car_registration/car_registration_template.dart';
import 'package:elite_taxi_app/driver/profile_setup.dart';
import 'package:elite_taxi_app/home.dart';
import 'package:elite_taxi_app/models/user_model/user_model.dart';
import 'package:elite_taxi_app/views/profile_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer'; // لإصلاح استخدام log()
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import '../maps/geo_coordinate.dart';

class AuthController extends GetxController {
  String userUid = '';
  String verId = '';
  int? resendTokenId;
  bool phoneAuthCheck = false;
  dynamic credentials;
  var isProfileUploading = false.obs;
  bool isLoginAsDriver = false;

  Future<void> phoneAuth(String phone) async {
    try {
      credentials = null;
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendTokenId,
        verificationCompleted: (PhoneAuthCredential credential) async {
          log("Verification completed");
          credentials = credential;
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          log('Verification failed');
          if (e.code == 'invalid-phone-number') {
            debugPrint('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          log('Code sent');
          verId = verificationId;
          resendTokenId = resendToken;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          log('Auto retrieval timeout');
        },
      );
    } catch (e) {
      log('Error occurred: $e');
    }
  }

  verifyOtp(String otpNumber) async {
    log('Called');
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verId,
      smsCode: otpNumber,
    );
    log("LogedIn");
    await FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      decideRoute();
    });
  }

  var isDecided = false;
  decideRoute() {
    if (isDecided) {
      return;
    }

    ///step 1- Check user login?
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      isDecided = true;
      getUserInfo();

      /// step 2- Check whether user profile exists?

      ///isLoginAsDriver == true means navigate it to the driver module

      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((value) {
            final profile = value.data();
            if (profile != null) myUser.value = UserModel.fromJson(profile);

            ///isLoginAsDriver == true means navigate it to driver module

            if (isLoginAsDriver) {
              if (value.exists) {
                print("Driver HOme Screen");
              } else {
                Get.offAll(() => DriverProfileSetup());
              }
            } else {
              if (value.exists) {
                Get.offAll(
                  () => HomeScreen(
                    onOpenProfile:
                        () => Get.to(() => const ProfileSettingScreen()),
                  ),
                );
              } else {
                Get.offAll(() => ProfileSettingScreen());
              }
            }
          })
          .catchError((e) {
            isDecided = false;
            print("Error while decideRoute is $e");
          });
    }
  }
  //store profile

  storeDriverProfile(
    File? selectedImage,
    String name,
    String email, {
    String url = '',
  }) async {
    String urlNew = url;
    if (selectedImage != null) {
      urlNew = await uploadImage(selectedImage);
    }
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
          'image': urlNew,
          'name': name,
          'email': email,
          'isDriver': true,
        }, SetOptions(merge: true))
        .then((value) {
          isProfileUploading(false);

          Get.off(() => CarRegistrationTemplate());
        });
  }

  var isCarEntryUploading = false.obs;

  Future<bool> uploadCarEntry(Map<String, dynamic> carData) async {
    bool isUploaded = false;
    String uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(carData, SetOptions(merge: true));

    isUploaded = true;

    return isUploaded;
  }

  uploadImage(File image) async {
    String imageUrl = '';
    String fileName = path.basename(image.path);
    var reference = FirebaseStorage.instance.ref().child('users/$fileName');
    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    await taskSnapshot.ref.getDownloadURL().then((value) {
      imageUrl = value;
      print("Download URL : $value");
    });
    return imageUrl;
  }

  storeUserInfo(
    File? selectedImage,
    String name,
    String home,
    String business,
    String shop, {
    String url = '',
    GeoCoordinate? homeLatLng,
    GeoCoordinate? businessLatLng,
    GeoCoordinate? shoppingLatLng,
  }) async {
    if (homeLatLng == null ||
        businessLatLng == null ||
        shoppingLatLng == null ||
        !homeLatLng.isValid ||
        !businessLatLng.isValid ||
        !shoppingLatLng.isValid) {
      throw ArgumentError('Selecciona las tres ubicaciones en el mapa.');
    }
    String urlNew = url;
    if (selectedImage != null) {
      urlNew = await uploadImage(selectedImage); // ✅ الآن أكيد مش null
    }
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({
          'image': urlNew,
          'name': name,
          'home_address': home,
          'business_address': business,
          'shopping_address': shop,
          'home_latlng': GeoPoint(homeLatLng.latitude, homeLatLng.longitude),
          'business_latlng': GeoPoint(
            businessLatLng.latitude,
            businessLatLng.longitude,
          ),
          'shopping_latlng': GeoPoint(
            shoppingLatLng.latitude,
            shoppingLatLng.longitude,
          ),
        }, SetOptions(merge: true))
        .then((value) {
          isProfileUploading(false);
          Get.to(
            () => HomeScreen(
              onOpenProfile: () => Get.to(() => const ProfileSettingScreen()),
            ),
          );
        });
  }

  var myUser = UserModel().obs;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSubscription;

  void getUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _userSubscription?.cancel();
    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((event) {
          final data = event.data();
          if (data != null) myUser.value = UserModel.fromJson(data);
        });
  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    super.onClose();
  }

  storeUserCard(String number, String expiry, String cvv, String name) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cards')
        .add({'name': name, 'number': number, 'cvv': cvv, 'expiry': expiry});

    return true;
  }

  RxList userCards = [].obs;

  getUserCards() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('cards')
        .snapshots()
        .listen((event) {
          userCards.value = event.docs;
        });
  }
}
