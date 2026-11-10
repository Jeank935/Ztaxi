import 'dart:io';

import 'package:elite_taxi_app/driver/car_registration/car_registration_template.dart';
import 'package:elite_taxi_app/driver/profile_setup.dart';
import 'package:elite_taxi_app/home.dart';
import 'package:elite_taxi_app/models/user_model/user_model.dart';
import 'package:elite_taxi_app/views/profile_settings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoding/geocoding.dart' as geoCoding;
import 'package:get/get.dart';
import 'dart:developer'; // لإصلاح استخدام log()
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as gmp;
import 'package:path/path.dart' as path;

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
    PhoneAuthCredential credential =
        PhoneAuthProvider.credential(verificationId: verId, smsCode: otpNumber);
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
    isDecided = true;
    print("called");

    ///step 1- Check user login?
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      /// step 2- Check whether user profile exists?

      ///isLoginAsDriver == true means navigate it to the driver module

      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then((value) {
        ///isLoginAsDriver == true means navigate it to driver module

        if (isLoginAsDriver) {
          if (value.exists) {
            print("Driver HOme Screen");
          } else {
            Get.offAll(() => DriverProfileSetup());
          }
        } else {
          if (value.exists) {
            Get.offAll(() => HomeScreen());
          } else {
            Get.offAll(() => ProfileSettingScreen());
          }
        }
      }).catchError((e) {
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
    FirebaseFirestore.instance.collection('users').doc(uid).set(
        {'image': urlNew, 'name': name, 'email': email, 'isDriver': true},
        SetOptions(merge: true)).then((value) {
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

  storeUserInfo(File? selectedImage, String name, String home, String business,
      String shop,
      {String url = '',
      LatLng? homeLatLng,
      LatLng? businessLatLng,
      LatLng? shoppingLatLng}) async {
    String urlNew = url;
    if (selectedImage != null) {
      urlNew = await uploadImage(selectedImage); // ✅ الآن أكيد مش null
    }
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('users').doc().set({
      'image': urlNew,
      'name': name,
      'home_address': home,
      'business_address': business,
      'shopping_address': shop,
      'home_latlng': GeoPoint(homeLatLng!.latitude, homeLatLng.longitude),
      'business_latlng':
          GeoPoint(businessLatLng!.latitude, businessLatLng.longitude),
      'shopping_latlng':
          GeoPoint(shoppingLatLng!.latitude, shoppingLatLng.longitude),
    }).then((value) {
      isProfileUploading(false);
      Get.to(() => HomeScreen());
    });
  }

  var myUser = UserModel().obs;

  getUserInfo() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance
        .collection('useres')
        .doc(uid)
        .snapshots()
        .listen((event) {
      myUser.value = UserModel.fromJson(event.data()!);
    });
  }

  Future<gmp.Prediction?> showGoogleAutoComplete(BuildContext context) async {
    const kGoogleApiKey = 'YOUR_GOOGLE_MAPS_API_KEY';

    gmp.Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: kGoogleApiKey,
      mode: Mode.overlay,
      radius: 1000,
      offset: 0,
      hint: "Search City",
      types: ["(cities)"],
      strictbounds: false,
      language: 'en',
      region: "us",
      components: [gmp.Component(gmp.Component.country, "us")],
    );
    return p;
  }

  Future<LatLng> buildLatLngFromAddress(String place) async {
    List<geoCoding.Location> locations =
        await geoCoding.locationFromAddress(place);
    return LatLng(locations.first.latitude, locations.first.longitude);
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
