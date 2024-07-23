// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_user/functions/notifications.dart';
import 'package:flutter_user/pages/onTripPage/invoice.dart';
import 'package:flutter_user/pages/onTripPage/map_page.dart';
import 'package:flutter_user/translations/translation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../styles/styles.dart';
import '../../functions/functions.dart';
import '../../widgets/widgets.dart';
import 'dart:math' as math;
import '../loadingPage/loading.dart';
import 'agreement.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

//code as int for getting phone dial code of choosen country
String phnumber = ''; // phone number as string entered in input field
// String phone = '';
List pages = [1, 2, 3, 4];
List images = [];
int currentPage = 0;

var values = 0;
bool isfromomobile = true;

dynamic proImageFile1;
ImagePicker picker = ImagePicker();
bool pickImage = false;
bool isverifyemail = false;
String email = ''; // email of user
String password = '';
String name = ''; //name of user

late StreamController profilepicturecontroller;
StreamSink get profilepicturesink => profilepicturecontroller.sink;
Stream get profilepicturestream => profilepicturecontroller.stream;

class _LoginState extends State<Login> with TickerProviderStateMixin {
  TextEditingController controller = TextEditingController();
  final TextEditingController _mobile = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _otp = TextEditingController();
  final TextEditingController _newPassword = TextEditingController();
  bool loginLoading = true;
  final ScrollController _scroll = ScrollController();
  // final _pinPutController2 = TextEditingController();
  dynamic aController;
  String _error = '';
  bool showSignin = false;
  // bool _resend = false;
  int signIn = 0;
  var searchVal = '';
  bool isLoginemail = true;
  bool withOtp = false;
  bool showPassword = false;
  bool showNewPassword = false;
  bool otpSent = false;
  bool _resend = false;
  int resendTimer = 60;
  bool mobileVerified = false;
  dynamic resendTime;
  bool forgotPassword = false;
  bool newPassword = false;

  resend() {
    resendTime?.cancel();
    resendTime = null;

    resendTime = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (resendTimer > 0) {
          resendTimer--;
        } else {
          _resend = true;
          resendTime?.cancel();
          timer.cancel();
          resendTime = null;
        }
      });
    });
  }

  String get timerString {
    Duration duration = aController.duration * aController.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  bool terms = true; //terms and conditions true or false

  @override
  void initState() {
    currentPage = 0;
    controller.text = '';
    proImageFile1 = null;
    gender = '';
    aController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60));
    countryCode();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  getGalleryPermission() async {
    dynamic status;
    if (platform == TargetPlatform.android) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        status = await Permission.storage.status;
        if (status != PermissionStatus.granted) {
          status = await Permission.storage.request();
        }

        /// use [Permissions.storage.status]
      } else {
        status = await Permission.photos.status;
        if (status != PermissionStatus.granted) {
          status = await Permission.photos.request();
        }
      }
    } else {
      status = await Permission.photos.status;
      if (status != PermissionStatus.granted) {
        status = await Permission.photos.request();
      }
    }
    return status;
  }

//get camera permission
  getCameraPermission() async {
    var status = await Permission.camera.status;
    if (status != PermissionStatus.granted) {
      status = await Permission.camera.request();
    }
    return status;
  }

//pick image from gallery
  pickImageFromGallery() async {
    var permission = await getGalleryPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile =
          await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

      proImageFile1 = pickedFile?.path;
      pickImage = false;
      valueNotifierLogin.incrementNotifier();
      profilepicturesink.add('');
    } else {
      valueNotifierLogin.incrementNotifier();
      profilepicturesink.add('');
    }
  }

//pick image from camera
  pickImageFromCamera() async {
    var permission = await getCameraPermission();
    if (permission == PermissionStatus.granted) {
      final pickedFile =
          await picker.pickImage(source: ImageSource.camera, imageQuality: 50);

      proImageFile1 = pickedFile?.path;
      pickImage = false;
      valueNotifierLogin.incrementNotifier();
      profilepicturesink.add('');
    } else {
      valueNotifierLogin.incrementNotifier();
      profilepicturesink.add('');
    }
  }

  navigate(verify) {
    if (verify == true) {
      if (userRequestData.isNotEmpty && userRequestData['is_completed'] == 1) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Invoice()),
            (route) => false);
      } else {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const Maps()),
            (route) => false);
      }
    } else if (verify == false) {
      setState(() {
        _error =
            'User Doesn\'t exists with this number, please Signup to continue';
      });
    } else {
      _error = verify.toString();
    }
    loginLoading = false;
    valueNotifierLogin.incrementNotifier();
  }

  countryCode() async {
    isverifyemail = false;
    isfromomobile = true;
    var result = await getCountryCode();
    if (loginImages.isNotEmpty) {
      images.clear();
      for (var e in loginImages) {
        images.add(Image.network(
          e['onboarding_image'],
          gaplessPlayback: true,
          fit: BoxFit.cover,
        ));
      }
    }
    if (result == 'success') {
      setState(() {
        loginLoading = false;
      });
    } else {
      setState(() {
        loginLoading = false;
      });
    }
  }

  List landings = [
    {
      'heading': 'ASSURANCE',
      'text':
          'Customer safety first,Always and forever our pledge,Your well-being, our priority,With you every step, edge to edge.'
    },
    {
      'heading': 'CLARITY',
      'text':
          'Fair pricing, crystal clear, Your trust, our promise sincere. With us, you\'ll find no hidden fee, Transparency is our guarantee.'
    },
    {
      'heading': 'INTUTIVE',
      'text':
          'Seamless journeys, Just a tap away, Explore hassle-free, Every step of the way.'
    },
    {
      'heading': 'SUPPORT',
      'text':
          'Embark on your journey with confidence, knowing that our commitment to your satisfaction is unwavering'
    },
  ];

  var verifyEmailError = '';
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: ValueListenableBuilder(
              valueListenable: valueNotifierLogin.value,
              builder: (context, value, child) {
                return Stack(
                  children: [
                    SizedBox(
                      height: media.height,
                      child: (loginImages.isNotEmpty)
                          ? Column(
                              children: [
                                SizedBox(
                                  height: media.height * 0.6,
                                  width: media.width,
                                  child: ClipPath(
                                      clipper: ShapePainter(),
                                      child: images[currentPage]),
                                ),
                                SizedBox(
                                  height: media.height * 0.18,
                                  child: PageView(
                                    onPageChanged: (v) {
                                      setState(() {
                                        currentPage = v;
                                      });
                                    },
                                    children: loginImages
                                        .asMap()
                                        .map((k, value) => MapEntry(
                                              k,
                                              Column(
                                                children: [
                                                  MyText(
                                                    text: loginImages[k]
                                                        ['title'],
                                                    size: media.height * 0.02,
                                                    fontweight: FontWeight.w600,
                                                  ),
                                                  SizedBox(
                                                    height: media.height * 0.02,
                                                  ),
                                                  SizedBox(
                                                      width: media.width * 0.6,
                                                      child: MyText(
                                                        text: loginImages[k]
                                                            ['description'],
                                                        size: media.height *
                                                            0.015,
                                                        maxLines: 4,
                                                        textAlign:
                                                            TextAlign.center,
                                                      )),
                                                ],
                                              ),
                                            ))
                                        .values
                                        .toList(),
                                  ),
                                ),
                                SizedBox(
                                  width: media.width,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: loginImages
                                        .asMap()
                                        .map((k, value) => MapEntry(
                                              k,
                                              Container(
                                                margin: EdgeInsets.only(
                                                  right: (k <
                                                          loginImages.length -
                                                              1)
                                                      ? media.width * 0.025
                                                      : 0,
                                                ),
                                                height: media.height * 0.01,
                                                width: media.height * 0.01,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: (currentPage == k)
                                                        ? const Color(
                                                            0xffFFD302)
                                                        : Colors.grey),
                                              ),
                                            ))
                                        .values
                                        .toList(),
                                  ),
                                )
                              ],
                            )
                          : Container(),
                    ),
                    Positioned(
                        child: (showSignin == true)
                            ? InkWell(
                                onTap: () {
                                  setState(() {
                                    showSignin = false;
                                  });
                                },
                                child: Container(
                                  height: media.height,
                                  width: media.width,
                                  color: Colors.transparent.withOpacity(0.8),
                                ),
                              )
                            : Container()),
                    Positioned(
                        bottom: 0,
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 100),
                              height: media.height * 0.2,
                              width: media.width,
                              child: ClipPath(
                                clipper: ShapePainterBottom(),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (showSignin == false) {
                                        showSignin = true;
                                      }
                                    });
                                  },
                                  onVerticalDragStart: (v) {
                                    setState(() {
                                      if (showSignin == false) {
                                        showSignin = true;
                                      }
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border:
                                          Border.all(color: theme, width: 0),
                                      color: theme,
                                    ),
                                    child: (showSignin == false)
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              MyText(
                                                text: languages[choosenLanguage]
                                                    ['text_sign_in'],
                                                size: media.width * sixteen,
                                                color: Colors.white,
                                                fontweight: FontWeight.w600,
                                              ),
                                              SizedBox(
                                                height: media.height * 0.01,
                                              ),
                                              Icon(
                                                Icons
                                                    .keyboard_double_arrow_up_rounded,
                                                size: media.width * 0.07,
                                                color: Colors.white,
                                              ),
                                              SizedBox(
                                                height: media.height * 0.01,
                                              ),
                                            ],
                                          )
                                        : Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              SizedBox(
                                                width: media.width * 0.7,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    InkWell(
                                                        onTap: () {
                                                          if (signIn == 1) {
                                                            setState(() {
                                                              forgotPassword =
                                                                  false;
                                                              newPassword =
                                                                  false;
                                                              otpSent = false;
                                                              withOtp = false;
                                                              isLoginemail =
                                                                  true;
                                                              _error = '';
                                                              _email.clear();
                                                              _password.clear();
                                                              _name.clear();
                                                              _mobile.clear();
                                                              signIn = 0;
                                                            });
                                                          }
                                                        },
                                                        child: MyText(
                                                          text: languages[
                                                                  choosenLanguage]
                                                              ['text_sign_in'],
                                                          size: media.width *
                                                              sixteen,
                                                          color: (signIn == 0)
                                                              ? Colors.white
                                                              : Colors.white
                                                                  .withOpacity(
                                                                      0.5),
                                                          fontweight:
                                                              FontWeight.w600,
                                                        )),
                                                    InkWell(
                                                        onTap: () {
                                                          if (signIn == 0) {
                                                            setState(() {
                                                              forgotPassword =
                                                                  false;
                                                              otpSent = false;
                                                              newPassword =
                                                                  false;
                                                              proImageFile1 =
                                                                  null;
                                                              isLoginemail =
                                                                  true;
                                                              withOtp = false;
                                                              _error = '';
                                                              _email.clear();
                                                              _password.clear();
                                                              _name.clear();
                                                              _mobile.clear();
                                                              gender = '';
                                                              signIn = 1;
                                                            });
                                                          }
                                                        },
                                                        child: MyText(
                                                          text: languages[
                                                                  choosenLanguage]
                                                              ['text_sign_up'],
                                                          size: media.width *
                                                              sixteen,
                                                          color: (signIn == 1)
                                                              ? Colors.white
                                                              : Colors.white
                                                                  .withOpacity(
                                                                      0.5),
                                                          fontweight:
                                                              FontWeight.w600,
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: media.height * 0.05,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              height: (showSignin == true)
                                  ? (signIn == 0)
                                      ? media.height * 0.6 +
                                          (MediaQuery.of(context)
                                                  .viewInsets
                                                  .bottom /
                                              2)
                                      : media.height * 0.7 +
                                          (MediaQuery.of(context)
                                              .viewInsets
                                              .bottom)
                                  : 0,
                              width: media.width,
                              decoration: BoxDecoration(
                                  color: theme,
                                  border: Border.all(color: theme, width: 0)),
                              child: SingleChildScrollView(
                                controller: _scroll,
                                child: Column(
                                  children: [
                                    AnimatedCrossFade(
                                        firstChild: Container(),
                                        secondChild: Column(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  pickImage = true;
                                                });
                                              },
                                              child: Stack(
                                                children: [
                                                  Container(
                                                    height: media.width * 0.2,
                                                    width: media.width * 0.2,
                                                    decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: Colors.white,
                                                        image: (proImageFile1 ==
                                                                null)
                                                            ? const DecorationImage(
                                                                image:
                                                                    AssetImage(
                                                                  'assets/images/default-profile-picture.jpeg',
                                                                ),
                                                                fit: BoxFit
                                                                    .cover)
                                                            : DecorationImage(
                                                                image: FileImage(
                                                                    File(
                                                                        proImageFile1)),
                                                                fit: BoxFit
                                                                    .cover)),
                                                    // padding: EdgeInsets.only(right: media.width*0.025,left:media.width*0.025 ),
                                                    // child: TextField(

                                                    //   decoration: InputDecoration(
                                                    //     hintText: 'Mobile',
                                                    //     border: InputBorder.none
                                                    //   ),
                                                    // ),
                                                  ),
                                                  Positioned(
                                                      bottom: 0,
                                                      right: 0,
                                                      child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  media.width *
                                                                      0.015),
                                                          decoration:
                                                              const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Colors
                                                                      .grey),
                                                          child: Icon(
                                                            Icons.edit,
                                                            size: media.width *
                                                                0.025,
                                                          )))
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              height: media.width * 0.05,
                                            ),
                                          ],
                                        ),
                                        crossFadeState: (signIn == 0)
                                            ? CrossFadeState.showFirst
                                            : CrossFadeState.showSecond,
                                        duration:
                                            const Duration(milliseconds: 200)),

                                    AnimatedCrossFade(
                                        firstChild: Container(),
                                        secondChild: Column(
                                          children: [
                                            Container(
                                              height: media.width * 0.12,
                                              width: media.width * 0.8,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Colors.white),
                                              padding: EdgeInsets.only(
                                                  right: media.width * 0.025,
                                                  left: media.width * 0.025),
                                              child: TextField(
                                                controller: _name,
                                                decoration: InputDecoration(
                                                    hintText: languages[
                                                            choosenLanguage]
                                                        ['text_name'],
                                                    border: InputBorder.none),
                                              ),
                                            ),
                                            SizedBox(
                                              height: media.width * 0.05,
                                            ),
                                          ],
                                        ),
                                        crossFadeState: (signIn == 0)
                                            ? CrossFadeState.showFirst
                                            : CrossFadeState.showSecond,
                                        duration:
                                            const Duration(milliseconds: 200)),

                                    Container(
                                      height: media.width * 0.12,
                                      width: media.width * 0.8,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.white),
                                      padding: EdgeInsets.only(
                                          right: media.width * 0.025,
                                          left: media.width * 0.025),
                                      child: Row(
                                        children: [
                                          if (isLoginemail == false &&
                                              phcode != null)
                                            InkWell(
                                              onTap: () {
                                                if (otpSent == false) {
                                                  showModalBottomSheet(
                                                      context: context,
                                                      builder: (builder) {
                                                        return Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  media.width *
                                                                      0.05),
                                                          width: media.width,
                                                          color: page,
                                                          child: Directionality(
                                                            textDirection:
                                                                (languageDirection ==
                                                                        'rtl')
                                                                    ? TextDirection
                                                                        .rtl
                                                                    : TextDirection
                                                                        .ltr,
                                                            child: Column(
                                                              children: [
                                                                Container(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              20,
                                                                          right:
                                                                              20),
                                                                  height: 40,
                                                                  width: media
                                                                          .width *
                                                                      0.9,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                      border: Border.all(
                                                                          color: Colors
                                                                              .grey,
                                                                          width:
                                                                              1.5)),
                                                                  child:
                                                                      TextField(
                                                                    decoration: InputDecoration(
                                                                        contentPadding: (languageDirection ==
                                                                                'rtl')
                                                                            ? EdgeInsets.only(
                                                                                bottom: media.width *
                                                                                    0.035)
                                                                            : EdgeInsets.only(
                                                                                bottom: media.width *
                                                                                    0.04),
                                                                        border: InputBorder
                                                                            .none,
                                                                        hintText:
                                                                            languages[choosenLanguage][
                                                                                'text_search'],
                                                                        hintStyle: GoogleFonts.notoSans(
                                                                            fontSize: media.width *
                                                                                sixteen,
                                                                            color:
                                                                                hintColor)),
                                                                    style: GoogleFonts.notoSans(
                                                                        fontSize:
                                                                            media.width *
                                                                                sixteen,
                                                                        color:
                                                                            textColor),
                                                                    onChanged:
                                                                        (val) {
                                                                      setState(
                                                                          () {
                                                                        searchVal =
                                                                            val;
                                                                      });
                                                                    },
                                                                  ),
                                                                ),
                                                                const SizedBox(
                                                                    height: 20),
                                                                Expanded(
                                                                  child:
                                                                      SingleChildScrollView(
                                                                    child:
                                                                        Column(
                                                                      children: countries
                                                                          .asMap()
                                                                          .map((i, value) {
                                                                            return MapEntry(
                                                                                i,
                                                                                // MyText(text: 'ttwer', size: 14)
                                                                                SizedBox(
                                                                                  width: media.width * 0.9,
                                                                                  child: (searchVal == '' && countries[i]['flag'] != null)
                                                                                      ? InkWell(
                                                                                          onTap: () {
                                                                                            setState(() {
                                                                                              phcode = i;
                                                                                            });
                                                                                            Navigator.pop(context);
                                                                                          },
                                                                                          child: Container(
                                                                                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                                            color: page,
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              children: [
                                                                                                Row(
                                                                                                  children: [
                                                                                                    Image.network(countries[i]['flag']),
                                                                                                    SizedBox(
                                                                                                      width: media.width * 0.02,
                                                                                                    ),
                                                                                                    SizedBox(
                                                                                                      width: media.width * 0.4,
                                                                                                      child: MyText(
                                                                                                        text: countries[i]['name'],
                                                                                                        size: media.width * sixteen,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                                MyText(text: countries[i]['dial_code'], size: media.width * sixteen)
                                                                                              ],
                                                                                            ),
                                                                                          ))
                                                                                      : (countries[i]['flag'] != null && countries[i]['name'].toLowerCase().contains(searchVal.toLowerCase()))
                                                                                          ? InkWell(
                                                                                              onTap: () {
                                                                                                setState(() {
                                                                                                  phcode = i;
                                                                                                });
                                                                                                Navigator.pop(context);
                                                                                              },
                                                                                              child: Container(
                                                                                                padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                                                color: page,
                                                                                                child: Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                  children: [
                                                                                                    Row(
                                                                                                      children: [
                                                                                                        Image.network(countries[i]['flag']),
                                                                                                        SizedBox(
                                                                                                          width: media.width * 0.02,
                                                                                                        ),
                                                                                                        SizedBox(
                                                                                                          width: media.width * 0.4,
                                                                                                          child: MyText(text: countries[i]['name'], size: media.width * sixteen),
                                                                                                        ),
                                                                                                      ],
                                                                                                    ),
                                                                                                    MyText(text: countries[i]['dial_code'], size: media.width * sixteen)
                                                                                                  ],
                                                                                                ),
                                                                                              ))
                                                                                          : Container(),
                                                                                ));
                                                                          })
                                                                          .values
                                                                          .toList(),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                }
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    right: media.width * 0.025),
                                                child: Row(
                                                  children: [
                                                    Image.network(
                                                      countries[phcode]['flag'],
                                                      width: media.width * 0.06,
                                                    ),
                                                    SizedBox(
                                                      width:
                                                          media.width * 0.015,
                                                    ),
                                                    Icon(
                                                      Icons.arrow_drop_down,
                                                      size: media.width * 0.05,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          Expanded(
                                            child: SizedBox(
                                              height: media.width * 0.12,
                                              child: TextField(
                                                keyboardType:
                                                    TextInputType.emailAddress,
                                                enabled: (otpSent == true &&
                                                        signIn == 0)
                                                    ? false
                                                    : true,
                                                controller: _email,
                                                onChanged: (v) {
                                                  String pattern =
                                                      r'(^(?:[+0]9)?[0-9]{1,12}$)';
                                                  RegExp regExp =
                                                      RegExp(pattern);
                                                  if (regExp.hasMatch(
                                                          _email.text) &&
                                                      isLoginemail == true &&
                                                      signIn == 0) {
                                                    setState(() {
                                                      isLoginemail = false;
                                                    });
                                                  } else if (isLoginemail ==
                                                          false &&
                                                      regExp.hasMatch(
                                                              _email.text) ==
                                                          false) {
                                                    setState(() {
                                                      isLoginemail = true;
                                                    });
                                                  }
                                                },
                                                decoration: InputDecoration(
                                                    hintText: (signIn == 0)
                                                        ? languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_email_mobile']
                                                        : languages[
                                                                choosenLanguage]
                                                            ['text_email'],
                                                    border: InputBorder.none),
                                              ),
                                            ),
                                          ),
                                          if (otpSent == true && signIn == 0)
                                            IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    _error = '';
                                                    otpSent = false;
                                                    _password.clear();
                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.edit,
                                                  size: media.width * 0.05,
                                                ))
                                        ],
                                      ),
                                    ),
                                    if ((withOtp == false ||
                                            otpSent == true ||
                                            signIn == 1) &&
                                        newPassword == false)
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: media.width * 0.05,
                                          ),
                                          Container(
                                            height: media.width * 0.12,
                                            width: media.width * 0.8,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                color: Colors.white),
                                            padding: EdgeInsets.only(
                                                right: media.width * 0.025,
                                                left: media.width * 0.025),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: TextField(
                                                    controller: _password,
                                                    decoration: InputDecoration(
                                                        hintText: (otpSent ==
                                                                true)
                                                            ? languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_driver_otp']
                                                            : languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_enter_password'],
                                                        border:
                                                            InputBorder.none),
                                                    keyboardType: (otpSent ==
                                                            true)
                                                        ? TextInputType.number
                                                        : TextInputType
                                                            .emailAddress,
                                                    obscureText: ((withOtp ==
                                                                    false ||
                                                                signIn == 1) &&
                                                            showPassword ==
                                                                false)
                                                        ? true
                                                        : false,
                                                  ),
                                                ),
                                                if (withOtp == false ||
                                                    signIn == 1)
                                                  IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          if (showPassword) {
                                                            showPassword =
                                                                false;
                                                          } else {
                                                            showPassword = true;
                                                          }
                                                        });
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .remove_red_eye_sharp,
                                                        color: (showPassword ==
                                                                true)
                                                            ? const Color(
                                                                0xffFFD302)
                                                            : null,
                                                      ))
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                    AnimatedCrossFade(
                                        firstChild: Container(),
                                        secondChild: Column(
                                          children: [
                                            SizedBox(
                                              height: media.width * 0.05,
                                            ),
                                            Container(
                                              height: media.width * 0.12,
                                              width: media.width * 0.8,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Colors.white),
                                              padding: EdgeInsets.only(
                                                  right: media.width * 0.025,
                                                  left: media.width * 0.025),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: TextField(
                                                      controller: _newPassword,
                                                      decoration: InputDecoration(
                                                          hintText: languages[
                                                                  choosenLanguage]
                                                              [
                                                              'Enter New Password'],
                                                          border:
                                                              InputBorder.none),
                                                      keyboardType:
                                                          TextInputType
                                                              .emailAddress,
                                                      obscureText:
                                                          (showNewPassword ==
                                                                  false)
                                                              ? true
                                                              : false,
                                                    ),
                                                  ),
                                                  // if(withOtp == false || signIn == 1)
                                                  IconButton(
                                                      onPressed: () {
                                                        setState(() {
                                                          if (showNewPassword) {
                                                            showNewPassword =
                                                                false;
                                                          } else {
                                                            showNewPassword =
                                                                true;
                                                          }
                                                        });
                                                      },
                                                      icon: Icon(
                                                        Icons
                                                            .remove_red_eye_sharp,
                                                        color:
                                                            (showNewPassword ==
                                                                    true)
                                                                ? const Color(
                                                                    0xffFFD302)
                                                                : null,
                                                      ))
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        crossFadeState: (newPassword == false)
                                            ? CrossFadeState.showFirst
                                            : CrossFadeState.showSecond,
                                        duration:
                                            const Duration(milliseconds: 200)),

                                    AnimatedCrossFade(
                                        firstChild: Container(),
                                        secondChild: Column(
                                          children: [
                                            SizedBox(
                                              height: media.width * 0.05,
                                            ),
                                            Container(
                                              height: media.width * 0.12,
                                              width: media.width * 0.8,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Colors.white),
                                              padding: EdgeInsets.only(
                                                  right: media.width * 0.025,
                                                  left: media.width * 0.025),
                                              child: Row(
                                                children: [
                                                  // if(isLoginemail == false && phcode != null)
                                                  InkWell(
                                                    onTap: () {
                                                      if (otpSent == false) {
                                                        showModalBottomSheet(
                                                            context: context,
                                                            builder: (builder) {
                                                              return Container(
                                                                padding: EdgeInsets
                                                                    .all(media
                                                                            .width *
                                                                        0.05),
                                                                width:
                                                                    media.width,
                                                                color: page,
                                                                child:
                                                                    Directionality(
                                                                  textDirection: (languageDirection ==
                                                                          'rtl')
                                                                      ? TextDirection
                                                                          .rtl
                                                                      : TextDirection
                                                                          .ltr,
                                                                  child: Column(
                                                                    children: [
                                                                      Container(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                20,
                                                                            right:
                                                                                20),
                                                                        height:
                                                                            40,
                                                                        width: media.width *
                                                                            0.9,
                                                                        decoration: BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(20),
                                                                            border: Border.all(color: Colors.grey, width: 1.5)),
                                                                        child:
                                                                            TextField(
                                                                          decoration: InputDecoration(
                                                                              contentPadding: (languageDirection == 'rtl') ? EdgeInsets.only(bottom: media.width * 0.035) : EdgeInsets.only(bottom: media.width * 0.04),
                                                                              border: InputBorder.none,
                                                                              hintText: languages[choosenLanguage]['text_search'],
                                                                              hintStyle: GoogleFonts.notoSans(fontSize: media.width * sixteen, color: hintColor)),
                                                                          style: GoogleFonts.notoSans(
                                                                              fontSize: media.width * sixteen,
                                                                              color: textColor),
                                                                          onChanged:
                                                                              (val) {
                                                                            setState(() {
                                                                              searchVal = val;
                                                                            });
                                                                          },
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              20),
                                                                      Expanded(
                                                                        child:
                                                                            SingleChildScrollView(
                                                                          child:
                                                                              Column(
                                                                            children: countries
                                                                                .asMap()
                                                                                .map((i, value) {
                                                                                  return MapEntry(
                                                                                      i,
                                                                                      // MyText(text: 'ttwer', size: 14)
                                                                                      SizedBox(
                                                                                        width: media.width * 0.9,
                                                                                        child: (searchVal == '' && countries[i]['flag'] != null)
                                                                                            ? InkWell(
                                                                                                onTap: () {
                                                                                                  setState(() {
                                                                                                    phcode = i;
                                                                                                  });
                                                                                                  Navigator.pop(context);
                                                                                                },
                                                                                                child: Container(
                                                                                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                                                  color: page,
                                                                                                  child: Row(
                                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                    children: [
                                                                                                      Row(
                                                                                                        children: [
                                                                                                          Image.network(countries[i]['flag']),
                                                                                                          SizedBox(
                                                                                                            width: media.width * 0.02,
                                                                                                          ),
                                                                                                          SizedBox(
                                                                                                            width: media.width * 0.4,
                                                                                                            child: MyText(
                                                                                                              text: countries[i]['name'],
                                                                                                              size: media.width * sixteen,
                                                                                                            ),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                      MyText(text: countries[i]['dial_code'], size: media.width * sixteen)
                                                                                                    ],
                                                                                                  ),
                                                                                                ))
                                                                                            : (countries[i]['flag'] != null && countries[i]['name'].toLowerCase().contains(searchVal.toLowerCase()))
                                                                                                ? InkWell(
                                                                                                    onTap: () {
                                                                                                      setState(() {
                                                                                                        phcode = i;
                                                                                                      });
                                                                                                      Navigator.pop(context);
                                                                                                    },
                                                                                                    child: Container(
                                                                                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                                                                      color: page,
                                                                                                      child: Row(
                                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                        children: [
                                                                                                          Row(
                                                                                                            children: [
                                                                                                              Image.network(countries[i]['flag']),
                                                                                                              SizedBox(
                                                                                                                width: media.width * 0.02,
                                                                                                              ),
                                                                                                              SizedBox(
                                                                                                                width: media.width * 0.4,
                                                                                                                child: MyText(text: countries[i]['name'], size: media.width * sixteen),
                                                                                                              ),
                                                                                                            ],
                                                                                                          ),
                                                                                                          MyText(text: countries[i]['dial_code'], size: media.width * sixteen)
                                                                                                        ],
                                                                                                      ),
                                                                                                    ))
                                                                                                : Container(),
                                                                                      ));
                                                                                })
                                                                                .values
                                                                                .toList(),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                      }
                                                    },
                                                    child: Padding(
                                                      padding: EdgeInsets.only(
                                                          right: media.width *
                                                              0.025),
                                                      child: Row(
                                                        children: [
                                                          (phcode != null)
                                                              ? Image.network(
                                                                  countries[
                                                                          phcode]
                                                                      ['flag'],
                                                                  width: media
                                                                          .width *
                                                                      0.06,
                                                                )
                                                              : Container(),
                                                          SizedBox(
                                                            width: media.width *
                                                                0.015,
                                                          ),
                                                          Icon(
                                                            Icons
                                                                .arrow_drop_down,
                                                            size: media.width *
                                                                0.05,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),

                                                  Expanded(
                                                    child: TextField(
                                                      controller: _mobile,
                                                      decoration: InputDecoration(
                                                          hintText: languages[
                                                                  choosenLanguage]
                                                              ['text_mobile'],
                                                          border:
                                                              InputBorder.none),
                                                      keyboardType:
                                                          TextInputType.number,
                                                      enabled: (otpSent == true)
                                                          ? false
                                                          : true,
                                                    ),
                                                  ),

                                                  if (otpSent == true)
                                                    IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            _error = '';
                                                            otpSent = false;
                                                            mobileVerified =
                                                                false;
                                                            _otp.clear();
                                                          });
                                                        },
                                                        icon: Icon(
                                                          Icons.edit,
                                                          size: media.width *
                                                              0.05,
                                                        ))
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        crossFadeState: (signIn == 0)
                                            ? CrossFadeState.showFirst
                                            : CrossFadeState.showSecond,
                                        duration:
                                            const Duration(milliseconds: 200)),
                                    AnimatedCrossFade(
                                        firstChild: Container(),
                                        secondChild: Column(
                                          children: [
                                            SizedBox(
                                              height: media.width * 0.05,
                                            ),
                                            Container(
                                              height: media.width * 0.12,
                                              width: media.width * 0.8,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  color: Colors.white),
                                              padding: EdgeInsets.only(
                                                  right: media.width * 0.025,
                                                  left: media.width * 0.025),
                                              child: TextField(
                                                controller: _otp,
                                                keyboardType:
                                                    TextInputType.number,
                                                decoration: InputDecoration(
                                                    hintText: languages[
                                                            choosenLanguage]
                                                        ['text_driver_otp'],
                                                    border: InputBorder.none),
                                              ),
                                            ),
                                          ],
                                        ),
                                        crossFadeState: (signIn == 1 &&
                                                otpSent == true &&
                                                mobileVerified == false)
                                            ? CrossFadeState.showSecond
                                            : CrossFadeState.showFirst,
                                        duration:
                                            const Duration(milliseconds: 200)),

                                    if (signIn == 0 && forgotPassword == false)
                                      Column(
                                        children: [
                                          SizedBox(
                                            height: media.width * 0.01,
                                          ),
                                          SizedBox(
                                            width: media.width * 0.8,
                                            child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _error = '';
                                                    _password.clear();
                                                    _email.text = '';
                                                    if (withOtp == false) {
                                                      withOtp = true;
                                                    } else {
                                                      otpSent = false;
                                                      withOtp = false;
                                                    }
                                                  });
                                                },
                                                child: MyText(
                                                  text: (withOtp == false)
                                                      ? languages[
                                                              choosenLanguage]
                                                          ['text_sign_in_otp']
                                                      : languages[
                                                              choosenLanguage][
                                                          'text_sign_in_password'],
                                                  size: media.width * fourteen,
                                                  textAlign: TextAlign.end,
                                                  color: Colors.white,
                                                )),
                                          ),
                                        ],
                                      ),
                                    AnimatedCrossFade(
                                        firstChild: Container(),
                                        secondChild: Column(
                                          children: [
                                            SizedBox(
                                              width: media.width * 0.8,
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    height: media.width * 0.05,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        languages[
                                                                choosenLanguage]
                                                            ['text_gender'],
                                                        // 'Gender',
                                                        style:
                                                            GoogleFonts.roboto(
                                                                fontSize: media
                                                                        .width *
                                                                    fourteen,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                        maxLines: 1,
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.025,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            gender = 'male';
                                                          });
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              height:
                                                                  media.width *
                                                                      0.05,
                                                              width:
                                                                  media.width *
                                                                      0.05,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                    width: 1.2,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              // decoration: BoxDecoration(
                                                              //     border: Border.all(
                                                              //         color: Colors
                                                              //             .black,
                                                              //         width:
                                                              //             1.2)),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: (gender ==
                                                                      'male')
                                                                  ? Container(
                                                                      height: media
                                                                              .width *
                                                                          0.03,
                                                                      width: media
                                                                              .width *
                                                                          0.03,
                                                                      decoration: const BoxDecoration(
                                                                          shape: BoxShape
                                                                              .circle,
                                                                          color:
                                                                              Colors.white),
                                                                    )
                                                                  // ? Center(
                                                                  //     child:
                                                                  //         Icon(
                                                                  //     Icons
                                                                  //         .done,
                                                                  //     size: media.width *
                                                                  //         0.04,
                                                                  //   ))
                                                                  : Container(),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.015,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.15,
                                                              child: Text(
                                                                languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_male'],
                                                                // 'Male',
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        fourteen,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            gender = 'female';
                                                          });
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              height:
                                                                  media.width *
                                                                      0.05,
                                                              width:
                                                                  media.width *
                                                                      0.05,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                    width: 1.2,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              // decoration: BoxDecoration(
                                                              //     border: Border.all(
                                                              //         color: Colors
                                                              //             .black,
                                                              //         width:
                                                              //             1.2)),
                                                              child: (gender ==
                                                                      'female')
                                                                  ? Container(
                                                                      height: media
                                                                              .width *
                                                                          0.03,
                                                                      width: media
                                                                              .width *
                                                                          0.03,
                                                                      decoration: const BoxDecoration(
                                                                          shape: BoxShape
                                                                              .circle,
                                                                          color:
                                                                              Colors.white),
                                                                    )
                                                                  // ? Center(
                                                                  //     child:
                                                                  //         Icon(
                                                                  //     Icons
                                                                  //         .done,
                                                                  //     size: media.width *
                                                                  //         0.04,
                                                                  //   ))
                                                                  : Container(),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.015,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.15,
                                                              child: Text(
                                                                languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_female'],
                                                                // 'Female',
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        fourteen,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            gender = 'others';
                                                          });
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Container(
                                                              height:
                                                                  media.width *
                                                                      0.05,
                                                              width:
                                                                  media.width *
                                                                      0.05,
                                                              decoration:
                                                                  BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                    width: 1.2,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                              // decoration: BoxDecoration(
                                                              //     border: Border.all(
                                                              //         color: Colors
                                                              //             .black,
                                                              //         width:
                                                              //             1.2)),
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: (gender ==
                                                                      'others')
                                                                  ? Container(
                                                                      height: media
                                                                              .width *
                                                                          0.03,
                                                                      width: media
                                                                              .width *
                                                                          0.03,
                                                                      decoration: const BoxDecoration(
                                                                          shape: BoxShape
                                                                              .circle,
                                                                          color:
                                                                              Colors.white),
                                                                    )
                                                                  // ? Center(
                                                                  //     child:
                                                                  //         Icon(
                                                                  //     Icons
                                                                  //         .done,
                                                                  //     size: media.width *
                                                                  //         0.04,
                                                                  //   ))
                                                                  : Container(),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.015,
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.25,
                                                              child: Text(
                                                                languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_others'],
                                                                // 'Neutral/Unknown',
                                                                // 'text_other_gender',
                                                                style: GoogleFonts.roboto(
                                                                    fontSize: media
                                                                            .width *
                                                                        fourteen,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        crossFadeState: (signIn == 0)
                                            ? CrossFadeState.showFirst
                                            : CrossFadeState.showSecond,
                                        duration:
                                            const Duration(milliseconds: 200)),
                                    SizedBox(
                                      height: media.width * 0.025,
                                    ),
                                    if (_error != '')
                                      Column(
                                        children: [
                                          Container(
                                              // width: media.width*0.9,
                                              constraints: BoxConstraints(
                                                  maxWidth: media.width * 0.9,
                                                  minWidth: media.width * 0.5),
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: const Color(0xffFFFFFF)
                                                      .withOpacity(0.5)),
                                              child: MyText(
                                                text: _error,
                                                size: media.width * fourteen,
                                                color: Colors.red,
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                                fontweight: FontWeight.w500,
                                              )),
                                          SizedBox(
                                            height: media.width * 0.025,
                                          ),
                                        ],
                                      ),
                                    Button(
                                        width: media.width * 0.5,
                                        borcolor: Colors.black,
                                        onTap: () async {
                                          setState(() {
                                            _error = '';
                                            loginLoading = true;
                                          });

                                          if (newPassword == true) {
                                            if (_newPassword.text.length >= 8) {
                                              var val = await updatePassword(
                                                  _email.text,
                                                  _newPassword.text,
                                                  isLoginemail);
                                              if (val == true) {
                                                withOtp = false;
                                                otpSent = false;
                                                _password.clear();
                                                _email.clear();
                                                forgotPassword = false;
                                                newPassword = false;
                                                showModalBottomSheet(
                                                    context: context,
                                                    // isScrollControlled: true,
                                                    backgroundColor: page,
                                                    builder: (context) {
                                                      return Container(
                                                        width: media.width,
                                                        padding: EdgeInsets.all(
                                                            media.width * 0.05),
                                                        child: MyText(
                                                          text: languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_password_update_successfully'],
                                                          size: media.width *
                                                              fourteen,
                                                          maxLines: 4,
                                                          color: textColor,
                                                        ),
                                                      );
                                                    });
                                              } else {
                                                _error = val.toString();
                                              }
                                            } else {
                                              setState(() {
                                                _error =
                                                    'Password must be 8 character length';
                                              });
                                            }
                                          } else if (signIn == 0) {
                                            if (withOtp == true) {
                                              if (otpSent == true) {
                                                if (_email.text.isNotEmpty &&
                                                    _password.text.isNotEmpty &&
                                                    _password.text.length ==
                                                        6) {
                                                  if (phoneAuthCheck == true) {
                                                    if (isLoginemail == true) {
                                                      // var val = await emailVerify(_email.text,_password.text);
                                                      // if(val == 'success'){
                                                      if (forgotPassword ==
                                                          true) {
                                                        var val =
                                                            await emailVerify(
                                                                _email.text,
                                                                _password.text);
                                                        if (val == 'success') {
                                                          _password.clear();
                                                          newPassword = true;
                                                          showNewPassword =
                                                              false;
                                                        } else {
                                                          _error = val;
                                                        }
                                                      } else {
                                                        var val =
                                                            await verifyUser(
                                                                _email.text,
                                                                (isLoginemail ==
                                                                        true)
                                                                    ? 1
                                                                    : 0,
                                                                _password.text,
                                                                '',
                                                                withOtp,
                                                                forgotPassword);

                                                        navigate(val);
                                                      }
                                                      // }
                                                      // }else{
                                                      //   _error = val;
                                                      // }
                                                    } else {
                                                      if (isCheckFireBaseOTP ==
                                                          true) {
                                                        try {
                                                          PhoneAuthCredential
                                                              credential =
                                                              PhoneAuthProvider.credential(
                                                                  verificationId:
                                                                      verId,
                                                                  smsCode:
                                                                      _password
                                                                          .text);

                                                          // Sign the user in (or link) with the credential
                                                          await FirebaseAuth
                                                              .instance
                                                              .signInWithCredential(
                                                                  credential);

                                                          var verify =
                                                              await verifyUser(
                                                                  _email.text,
                                                                  0,
                                                                  '',
                                                                  '',
                                                                  withOtp,
                                                                  forgotPassword);
                                                          if (forgotPassword ==
                                                              true) {
                                                            if (verify ==
                                                                true) {
                                                              _password.clear();
                                                              newPassword =
                                                                  true;
                                                              showNewPassword =
                                                                  false;
                                                            }
                                                          } else {
                                                            navigate(verify);
                                                          }

                                                          values = 0;
                                                        } on FirebaseAuthException catch (error) {
                                                          if (error.code ==
                                                              'invalid-verification-code') {
                                                            setState(() {
                                                              _password.clear();
                                                              // otpNumber = '';
                                                              _error =
                                                                  'Please enter correct Otp or resend';
                                                            });
                                                          }
                                                        }
                                                      } else {
                                                        var val =
                                                            await validateSmsOtp(
                                                                _email.text,
                                                                _password.text);
                                                        if (val == 'success') {
                                                          var verify =
                                                              await verifyUser(
                                                                  _email.text,
                                                                  0,
                                                                  '',
                                                                  '',
                                                                  withOtp,
                                                                  forgotPassword);
                                                          if (forgotPassword ==
                                                              true) {
                                                            if (verify ==
                                                                true) {
                                                              _password.clear();
                                                              newPassword =
                                                                  true;
                                                              showNewPassword =
                                                                  false;
                                                            }
                                                          } else {
                                                            navigate(verify);
                                                          }
                                                        } else {
                                                          _error =
                                                              val.toString();
                                                        }
                                                      }
                                                    }
                                                  } else {
                                                    if (_password.text ==
                                                        '123456') {
                                                      var val =
                                                          await verifyUser(
                                                              _email.text,
                                                              (isLoginemail ==
                                                                      true)
                                                                  ? 1
                                                                  : 0,
                                                              _password.text,
                                                              '',
                                                              withOtp,
                                                              forgotPassword);
                                                      if (forgotPassword ==
                                                          true) {
                                                        if (val == true) {
                                                          _password.clear();
                                                          newPassword = true;
                                                          showNewPassword =
                                                              false;
                                                        }
                                                      } else {
                                                        navigate(val);
                                                      }
                                                    } else {
                                                      _error =
                                                          'Please enter correct otp';
                                                    }
                                                  }
                                                } else {
                                                  setState(() {
                                                    if (_password
                                                        .text.isEmpty) {
                                                      _error =
                                                          'Please enter otp';
                                                    } else {
                                                      _error =
                                                          'Please enter correct otp';
                                                    }
                                                  });
                                                }
                                              } else if (withOtp == true) {
                                                var exist = true;
                                                if (forgotPassword == true) {
                                                  var ver = await verifyUser(
                                                      _email.text,
                                                      (isLoginemail == true)
                                                          ? 1
                                                          : 0,
                                                      _password.text,
                                                      '',
                                                      withOtp,
                                                      forgotPassword);
                                                  if (ver == true) {
                                                    exist = true;
                                                  } else {
                                                    exist = false;
                                                  }
                                                }
                                                if (exist == true) {
                                                  if (isLoginemail == false) {
                                                    String pattern =
                                                        r'(^(?:[+0]9)?[0-9]{1,12}$)';
                                                    RegExp regExp =
                                                        RegExp(pattern);
                                                    if (regExp.hasMatch(
                                                            _email.text) &&
                                                        _email.text.length <=
                                                            countries[phcode][
                                                                'dial_max_length'] &&
                                                        _email.text.length >=
                                                            countries[phcode][
                                                                'dial_min_length']) {
                                                      // setState(() {
                                                      //   _error = '';
                                                      //   loginLoading = true;
                                                      // });
                                                      var val = await otpCall();

                                                      if (val.value == true) {
                                                        if (isCheckFireBaseOTP ==
                                                            true) {
                                                          await phoneAuth(
                                                              countries[phcode][
                                                                      'dial_code'] +
                                                                  _email.text);
                                                          phoneAuthCheck = true;
                                                          _resend = false;
                                                          otpSent = true;
                                                          resendTimer = 60;
                                                          resend();
                                                        } else {
                                                          var val = await sendOTPtoMobile(
                                                              _email.text,
                                                              countries[phcode][
                                                                      'dial_code']
                                                                  .toString());
                                                          if (val ==
                                                              'success') {
                                                            phoneAuthCheck =
                                                                true;
                                                            _resend = false;
                                                            otpSent = true;
                                                            resendTimer = 60;
                                                            resend();
                                                          } else {
                                                            _error = val;
                                                          }
                                                        }
                                                      } else {
                                                        phoneAuthCheck = false;
                                                        RemoteNotification
                                                            noti =
                                                            const RemoteNotification(
                                                                title:
                                                                    'Otp for Login',
                                                                body:
                                                                    'Login to your account with test OTP 123456');
                                                        showOtpNotification(
                                                            noti);
                                                      }
                                                      // setState(() {
                                                      _resend = false;
                                                      otpSent = true;
                                                      resendTimer = 60;
                                                      resend();

                                                      // });
                                                    } else {
                                                      //  setState(() {
                                                      _error =
                                                          'Please enter valid mobile number';
                                                      // });
                                                    }
                                                  } else {
                                                    String pattern =
                                                        r"^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])*$";
                                                    RegExp regex =
                                                        RegExp(pattern);
                                                    if (regex.hasMatch(
                                                        _email.text)) {
                                                      phoneAuthCheck = true;
                                                      var val =
                                                          await sendOTPtoEmail(
                                                              _email.text);
                                                      if (val == 'success') {
                                                        _resend = false;
                                                        otpSent = true;
                                                        resendTimer = 60;
                                                        resend();
                                                      } else {
                                                        _error = val;
                                                      }
                                                      // setState(() {
                                                      // _error = '';
                                                      // });
                                                    } else {
                                                      // setState(() {
                                                      _error =
                                                          'Please enter valid email address';
                                                      // });
                                                    }
                                                  }
                                                } else {
                                                  _error = (isLoginemail ==
                                                          false)
                                                      ? 'Mobile Number doesn\'t exists'
                                                      : 'Email doesn\'t exists';
                                                }
                                              }
                                            } else {
                                              if (_password.text.isNotEmpty &&
                                                  _password.text.length >= 8 &&
                                                  _email.text.isNotEmpty) {
                                                String pattern =
                                                    r'(^(?:[+0]9)?[0-9]{1,12}$)';
                                                RegExp regExp = RegExp(pattern);
                                                String pattern1 =
                                                    r"^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])*$";
                                                RegExp regex = RegExp(pattern1);
                                                if ((regExp.hasMatch(
                                                            _email.text) &&
                                                        _email.text.length <=
                                                            countries[phcode][
                                                                'dial_max_length'] &&
                                                        _email.text.length >=
                                                            countries[phcode][
                                                                'dial_min_length'] &&
                                                        isLoginemail ==
                                                            false) ||
                                                    (isLoginemail == true &&
                                                        regex.hasMatch(
                                                            _email.text))) {
                                                  var val = await verifyUser(
                                                      _email.text,
                                                      (isLoginemail == true)
                                                          ? 1
                                                          : 0,
                                                      _password.text,
                                                      '',
                                                      withOtp,
                                                      forgotPassword);
                                                  navigate(val);
                                                } else {
                                                  if (isLoginemail == false) {
                                                    _error =
                                                        'Please enter valid mobile number';
                                                  } else {
                                                    _error =
                                                        'please enter valid email address';
                                                  }
                                                }
                                              } else {
                                                setState(() {
                                                  _error =
                                                      'Password must be 8 character length';
                                                });
                                              }
                                            }
                                          } else {
                                            if (mobileVerified == true) {
                                              dynamic val;
                                              if (email != _email.text) {
                                                val = await verifyUser(
                                                    _mobile.text,
                                                    0,
                                                    _password.text,
                                                    _email.text,
                                                    withOtp,
                                                    forgotPassword);
                                              } else {
                                                val = false;
                                              }
                                              if (val == false) {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const AggreementPage()));
                                              } else {
                                                _error = val;
                                              }
                                            } else if (otpSent == false) {
                                              if (_name.text.isNotEmpty &&
                                                  _email.text.isNotEmpty &&
                                                  _mobile.text.isNotEmpty &&
                                                  _password.text.length >= 8 &&
                                                  gender.isNotEmpty &&
                                                  gender != '') {
                                                // ef;
                                                String pattern =
                                                    r'(^(?:[+0]9)?[0-9]{1,12}$)';
                                                RegExp regExp = RegExp(pattern);
                                                if (regExp.hasMatch(
                                                        _mobile.text) &&
                                                    _mobile.text.length <=
                                                        countries[phcode][
                                                            'dial_max_length'] &&
                                                    _mobile.text.length >=
                                                        countries[phcode][
                                                            'dial_min_length']) {
                                                  // fd;
                                                  String pattern =
                                                      r"^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])*$";
                                                  RegExp regex =
                                                      RegExp(pattern);
                                                  if (regex
                                                      .hasMatch(_email.text)) {
                                                    name = _name.text;
                                                    email = _email.text;
                                                    password = _password.text;
                                                    phnumber = _mobile.text;
                                                    var verify =
                                                        await verifyUser(
                                                            _mobile.text,
                                                            0,
                                                            '',
                                                            _email.text,
                                                            withOtp,
                                                            forgotPassword);
                                                    if (verify == false) {
                                                      var val = await otpCall();
                                                      if (val.value == true) {
                                                        if (isCheckFireBaseOTP ==
                                                            true) {
                                                          await phoneAuth(
                                                              countries[phcode][
                                                                      'dial_code'] +
                                                                  _mobile.text);
                                                          phoneAuthCheck = true;
                                                          _resend = false;
                                                          otpSent = true;
                                                          resendTimer = 60;
                                                          resend();
                                                        } else {
                                                          var val = await sendOTPtoMobile(
                                                              _mobile.text,
                                                              countries[phcode][
                                                                      'dial_code']
                                                                  .toString());
                                                          if (val ==
                                                              'success') {
                                                            phoneAuthCheck =
                                                                true;
                                                            _resend = false;
                                                            otpSent = true;
                                                            resendTimer = 60;
                                                            resend();
                                                          } else {
                                                            _error = val;
                                                          }
                                                        }
                                                      } else {
                                                        phoneAuthCheck = false;
                                                        RemoteNotification
                                                            noti =
                                                            const RemoteNotification(
                                                                title:
                                                                    'Otp for Login',
                                                                body:
                                                                    'Login to your account with test OTP 123456');
                                                        showOtpNotification(
                                                            noti);
                                                      }
                                                      // setState(() {
                                                      _resend = false;
                                                      otpSent = true;
                                                      resendTimer = 60;
                                                      resend();
                                                      Future.delayed(
                                                          const Duration(
                                                              seconds: 1), () {
                                                        _scroll.position.moveTo(
                                                            _scroll.position
                                                                .maxScrollExtent);
                                                      });
                                                    } else {
                                                      _error = verify;
                                                    }
                                                  } else {
                                                    _error =
                                                        'please enter valid email address';
                                                  }
                                                } else {
                                                  _error =
                                                      'please enter valid mobile number';
                                                }
                                              } else if (_password.text.length <
                                                  8) {
                                                _error =
                                                    'password length must be 8 characters';
                                              } else {
                                                _error =
                                                    'please enter all fields to proceed';
                                              }
                                            } else {
                                              // iorejie

                                              if (_otp.text.isNotEmpty &&
                                                  _otp.text.length == 6) {
                                                dynamic val;
                                                if (email != _email.text) {
                                                  val = await verifyUser(
                                                      _mobile.text,
                                                      0,
                                                      _password.text,
                                                      _email.text,
                                                      withOtp,
                                                      forgotPassword);
                                                } else {
                                                  val = false;
                                                }
                                                if (val == false) {
                                                  if (phoneAuthCheck == true) {
                                                    if (isCheckFireBaseOTP ==
                                                        true) {
                                                      try {
                                                        PhoneAuthCredential
                                                            credential =
                                                            PhoneAuthProvider
                                                                .credential(
                                                                    verificationId:
                                                                        verId,
                                                                    smsCode: _otp
                                                                        .text);

                                                        // Sign the user in (or link) with the credential
                                                        await FirebaseAuth
                                                            .instance
                                                            .signInWithCredential(
                                                                credential);

                                                        // var verify = await verifyUser(_email.text,0,'','');
                                                        // navigate(verify);
                                                        mobileVerified = true;
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const AggreementPage()));

                                                        values = 0;
                                                      } on FirebaseAuthException catch (error) {
                                                        if (error.code ==
                                                            'invalid-verification-code') {
                                                          setState(() {
                                                            _otp.clear();
                                                            // otpNumber = '';
                                                            _error =
                                                                'Please enter correct Otp or resend';
                                                          });
                                                        }
                                                      }
                                                    } else {
                                                      var val =
                                                          await validateSmsOtp(
                                                              _email.text,
                                                              _otp.text);
                                                      if (val == 'success') {
                                                        //                                       var verify = await verifyUser(_email.text,0,'','');
                                                        // navigate(verify);
                                                        mobileVerified = true;
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const AggreementPage()));
                                                      } else {
                                                        _error = val.toString();
                                                      }
                                                    }
                                                  } else {
                                                    mobileVerified = true;
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                const AggreementPage()));

                                                    //  var val = await verifyUser(_email.text, (isLoginemail == true) ? 1 : 0,_password.text,'');
                                                    //  navigate(val);
                                                  }
                                                } else {
                                                  _error = val;
                                                }
                                              } else {
                                                // setState(() {
                                                _error = 'Please enter otp';
                                                // });
                                              }
                                            }
                                          }
                                          setState(() {
                                            loginLoading = false;
                                          });
                                        },
                                        text: (signIn == 0)
                                            ? (newPassword == true)
                                                ? languages[choosenLanguage]
                                                    ['text_update_password']
                                                : (withOtp == false)
                                                    ? languages[choosenLanguage]
                                                        ['text_sign_in']
                                                    : (otpSent == true)
                                                        ? languages[
                                                                choosenLanguage]
                                                            ['text_verify_otp']
                                                        : languages[
                                                                choosenLanguage]
                                                            ['text_get_otp']
                                            : (otpSent == false &&
                                                    mobileVerified == false)
                                                ? languages[choosenLanguage]
                                                    ['text_verify_mobile']
                                                : languages[choosenLanguage]
                                                    ['text_confirm']),
                                    // SizedBox(height: media.width*0.01,),
                                    if (otpSent == true && newPassword == false)
                                      Container(
                                        alignment: Alignment.center,
                                        width: media.width * 0.5,
                                        height: media.width * 0.1,
                                        child: (_resend == true)
                                            ? TextButton(
                                                onPressed: () async {
                                                  var exist = true;
                                                  if (forgotPassword == true) {
                                                    var ver = await verifyUser(
                                                        _email.text,
                                                        (isLoginemail == true)
                                                            ? 1
                                                            : 0,
                                                        _password.text,
                                                        '',
                                                        withOtp,
                                                        forgotPassword);
                                                    if (ver == true) {
                                                      exist = true;
                                                    } else {
                                                      exist = false;
                                                    }
                                                  }
                                                  if (exist == true) {
                                                    if (isLoginemail == false) {
                                                      String pattern =
                                                          r'(^(?:[+0]9)?[0-9]{1,12}$)';
                                                      RegExp regExp =
                                                          RegExp(pattern);
                                                      if (regExp.hasMatch(
                                                              _email.text) &&
                                                          _email.text.length <=
                                                              countries[phcode][
                                                                  'dial_max_length'] &&
                                                          _email.text.length >=
                                                              countries[phcode][
                                                                  'dial_min_length']) {
                                                        // setState(() {
                                                        //   _error = '';
                                                        //   loginLoading = true;
                                                        // });
                                                        var val =
                                                            await otpCall();

                                                        if (val.value == true) {
                                                          if (isCheckFireBaseOTP ==
                                                              true) {
                                                            await phoneAuth(
                                                                countries[phcode]
                                                                        [
                                                                        'dial_code'] +
                                                                    _email
                                                                        .text);
                                                            phoneAuthCheck =
                                                                true;
                                                            _resend = false;
                                                            otpSent = true;
                                                            resendTimer = 60;
                                                            resend();
                                                          } else {
                                                            var val = await sendOTPtoMobile(
                                                                _email.text,
                                                                countries[phcode]
                                                                        [
                                                                        'dial_code']
                                                                    .toString());
                                                            if (val ==
                                                                'success') {
                                                              phoneAuthCheck =
                                                                  true;
                                                              _resend = false;
                                                              otpSent = true;
                                                              resendTimer = 60;
                                                              resend();
                                                            } else {
                                                              _error = val;
                                                            }
                                                          }
                                                        } else {
                                                          phoneAuthCheck =
                                                              false;
                                                          RemoteNotification noti =
                                                              const RemoteNotification(
                                                                  title:
                                                                      'Otp for Login',
                                                                  body:
                                                                      'Login to your account with test OTP 123456');
                                                          showOtpNotification(
                                                              noti);
                                                        }
                                                        // setState(() {
                                                        _resend = false;
                                                        otpSent = true;
                                                        resendTimer = 60;
                                                        resend();

                                                        // });
                                                      } else {
                                                        //  setState(() {
                                                        _error =
                                                            'Please enter valid mobile number';
                                                        // });
                                                      }
                                                    } else {
                                                      String pattern =
                                                          r"^[a-zA-Z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])*$";
                                                      RegExp regex =
                                                          RegExp(pattern);
                                                      if (regex.hasMatch(
                                                          _email.text)) {
                                                        phoneAuthCheck = true;
                                                        var val =
                                                            await sendOTPtoEmail(
                                                                _email.text);
                                                        if (val == 'success') {
                                                          _resend = false;
                                                          otpSent = true;
                                                          resendTimer = 60;
                                                          resend();
                                                        } else {
                                                          _error = val;
                                                        }
                                                        // setState(() {
                                                        // _error = '';
                                                        // });
                                                      } else {
                                                        // setState(() {
                                                        _error =
                                                            'Please enter valid email address';
                                                        // });
                                                      }
                                                    }
                                                  } else {
                                                    _error = (isLoginemail ==
                                                            false)
                                                        ? 'Mobile Number doesn\'t exists'
                                                        : 'Email doesn\'t exists';
                                                  }
                                                },
                                                child: MyText(
                                                  text:
                                                      languages[choosenLanguage]
                                                          ['text_resend_otp'],
                                                  size: media.width * fourteen,
                                                  textAlign: TextAlign.center,
                                                  color: Colors.white,
                                                ))
                                            : (otpSent == true)
                                                ? MyText(
                                                    text: languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_resend_otp_in']
                                                        .toString()
                                                        .replaceAll(
                                                            '1111',
                                                            resendTimer
                                                                .toString()),
                                                    // 'Resend OTP in $resendTimer',
                                                    size:
                                                        media.width * fourteen,
                                                    textAlign: TextAlign.center,
                                                    color: Colors.white,
                                                  )
                                                : Container(),
                                      ),
                                    SizedBox(
                                      height: media.width * 0.025,
                                    ),
                                    if ((withOtp == false && (signIn == 0)) ||
                                        forgotPassword == true)
                                      SizedBox(
                                        width: media.width * 0.5,
                                        child: TextButton(
                                            onPressed: () {
                                              _error = '';
                                              setState(() {
                                                if (forgotPassword == true) {
                                                  _email.clear();
                                                  _password.clear();
                                                  isLoginemail = true;
                                                  otpSent = false;
                                                  withOtp = false;
                                                  forgotPassword = false;
                                                  newPassword = false;
                                                } else {
                                                  _email.clear();
                                                  _password.clear();
                                                  isLoginemail = true;
                                                  otpSent = false;
                                                  withOtp = true;
                                                  forgotPassword = true;
                                                }
                                              });
                                            },
                                            child: MyText(
                                              text: (forgotPassword == true)
                                                  ? languages[choosenLanguage]
                                                      ['text_sign_in']
                                                  : languages[choosenLanguage]
                                                      ['text_forgot_password'],
                                              size: media.width * fourteen,
                                              textAlign: TextAlign.end,
                                              color: Colors.white,
                                            )),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )),
                    (pickImage == true)
                        ? Positioned(
                            bottom: 0,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  pickImage = false;
                                });
                              },
                              child: Container(
                                height: media.height * 1,
                                width: media.width * 1,
                                color: Colors.transparent.withOpacity(0.6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.all(media.width * 0.05),
                                      width: media.width * 1,
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(25),
                                              topRight: Radius.circular(25)),
                                          border: Border.all(
                                            color: borderLines,
                                            width: 1.2,
                                          ),
                                          color: page),
                                      child: Column(
                                        children: [
                                          Container(
                                            height: media.width * 0.02,
                                            width: media.width * 0.15,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      media.width * 0.01),
                                              color: Colors.grey,
                                            ),
                                          ),
                                          SizedBox(
                                            height: media.width * 0.05,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Column(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      pickImageFromCamera();
                                                    },
                                                    child: Container(
                                                        height:
                                                            media.width * 0.171,
                                                        width:
                                                            media.width * 0.171,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color:
                                                                    borderLines,
                                                                width: 1.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                        child: Icon(
                                                          Icons
                                                              .camera_alt_outlined,
                                                          size: media.width *
                                                              0.064,
                                                          color: textColor,
                                                        )),
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.02,
                                                  ),
                                                  MyText(
                                                    text: languages[
                                                            choosenLanguage]
                                                        ['text_camera'],
                                                    size: media.width * ten,
                                                    color: textColor
                                                        .withOpacity(0.4),
                                                  )
                                                ],
                                              ),
                                              Column(
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      pickImageFromGallery();
                                                    },
                                                    child: Container(
                                                        height:
                                                            media.width * 0.171,
                                                        width:
                                                            media.width * 0.171,
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color:
                                                                    borderLines,
                                                                width: 1.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12)),
                                                        child: Icon(
                                                          Icons.image_outlined,
                                                          size: media.width *
                                                              0.064,
                                                          color: textColor,
                                                        )),
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.02,
                                                  ),
                                                  MyText(
                                                    text: languages[
                                                            choosenLanguage]
                                                        ['text_gallery'],
                                                    size: media.width * ten,
                                                    color: textColor
                                                        .withOpacity(0.4),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                        : Container(),
                    (loginLoading == true)
                        ? const Positioned(top: 0, child: Loading())
                        : Container()
                  ],
                );
              })),
    );
  }
}

class ShapePainter extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width * 0.05, size.height * 0.9,
        size.width * 0.2, size.height * 0.9);
    path.lineTo(size.width * 0.8, size.height * 0.9);
    path.quadraticBezierTo(
        size.width * 0.95, size.height * 0.9, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class ShapePainterBottom extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    path.lineTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.95, size.height * 0.25,
        size.width * 0.8, size.height * 0.25);
    path.lineTo(size.width * 0.2, size.height * 0.25);
    path.quadraticBezierTo(size.width * 0.05, size.height * 0.25, 0, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class CustomTimerPainter extends CustomPainter {
  CustomTimerPainter({
    required this.animation,
    required this.backgroundColor,
    required this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(CustomTimerPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
