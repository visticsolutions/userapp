import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_user/pages/loadingPage/loading.dart';
import 'package:flutter_user/pages/referralcode/referral_code.dart';
import 'package:flutter_user/translations/translation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../widgets/widgets.dart';

class AggreementPage extends StatefulWidget {
  const AggreementPage({super.key});

  @override
  State<AggreementPage> createState() => _AggreementPageState();
}

class _AggreementPageState extends State<AggreementPage> {
  //navigate
  navigate() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Referral()),
        (route) => false);
  }

  bool ischeck = false;
  bool loginLoading = false;
  // ignore: unused_field
  String _error = '';
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      color: page,
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [theme.withOpacity(0.5), backgroundColor])),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(
                          height: media.height * 0.1,
                        ),
                        SizedBox(
                          width: media.width * 0.9,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height: media.width * 0.1,
                                  width: media.width * 0.1,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: backgroundColor),
                                  child: Icon(
                                    Icons.arrow_back,
                                    size: media.width * 0.05,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(
                          height: media.width * 0.025,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              top: media.width * 0.05,
                              bottom: media.width * 0.05),
                          child: MyText(
                            text: languages[choosenLanguage]['text_welcome_to']
                                .toString()
                                .replaceAll('5555', 'Product Name'),
                            size: media.width * sixteen,
                            fontweight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          height: media.width * 0.5,
                          width: media.width * 0.5,
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/privacyagreement.png'),
                                  fit: BoxFit.contain)),
                        ),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        SizedBox(
                            width: media.width * 0.9,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                // text: 'Hello ',
                                style: GoogleFonts.notoSans(
                                  color: textColor,
                                  fontSize: media.width * fourteen,
                                ),
                                children: [
                                  TextSpan(
                                      text: languages[choosenLanguage]
                                          ['text_agree_text1']),
                                  TextSpan(
                                      text: languages[choosenLanguage]
                                          ['text_terms_of_use'],
                                      style: GoogleFonts.notoSans(
                                        color: buttonColor,
                                        fontSize: media.width * fourteen,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          openBrowser(
                                              'terms and conditions url');
                                        }),
                                  TextSpan(
                                      text: languages[choosenLanguage]
                                          ['text_agree_text2']),
                                  TextSpan(
                                      text: languages[choosenLanguage]
                                          ['text_privacy'],
                                      style: GoogleFonts.notoSans(
                                        color: buttonColor,
                                        fontSize: media.width * fourteen,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          openBrowser('privacy policy url');
                                        }),
                                ],
                              ),
                            )),
                        Container(
                          padding: EdgeInsets.only(top: media.width * 0.1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              MyText(
                                  text: languages[choosenLanguage]
                                      ['text_iagree'],
                                  size: media.width * sixteen),
                              SizedBox(
                                width: media.width * 0.05,
                              ),
                              InkWell(
                                onTap: () {
                                  if (ischeck == false) {
                                    setState(() {
                                      ischeck = true;
                                    });
                                  } else {
                                    setState(() {
                                      ischeck = false;
                                    });
                                  }
                                },
                                child: Container(
                                  height: media.width * 0.05,
                                  width: media.width * 0.05,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: buttonColor, width: 2)),
                                  child: ischeck == false
                                      ? null
                                      : Icon(
                                          Icons.done,
                                          size: media.width * 0.04,
                                          color: buttonColor,
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),

                  if (_error != '')
                    SizedBox(
                      width: media.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: media.width * 0.025,
                          ),
                          Container(
                              // width: media.width*0.9,
                              constraints: BoxConstraints(
                                  maxWidth: media.width * 0.9,
                                  minWidth: media.width * 0.5),
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color:
                                      const Color(0xffFFFFFF).withOpacity(0.5)),
                              child: MyText(
                                text: _error,
                                size: media.width * sixteen,
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
                    ),
                  // ischeck == true
                  // ?
                  Container(
                    width: media.width,
                    padding: EdgeInsets.only(
                        top: media.width * 0.05, bottom: media.width * 0.05),
                    child: Button(
                        width: media.width * 0.5,
                        onTap: () async {
                          if (ischeck == true) {
                            setState(() {
                              loginLoading = true;
                              _error = '';
                            });

                            valueNotifierLogin.incrementNotifier();
                            var register = await registerUser();
                            if (register == 'true') {
                              //referral page
                              navigate();
                            } else {
                              _error = register.toString();
                            }
                            setState(() {
                              loginLoading = false;
                            });
                            // loginLoading = false;
                            valueNotifierLogin.incrementNotifier();
                          } else {
                            setState(() {
                              _error = 'Please tick the checkbox above';
                            });
                          }
                        },
                        text: languages[choosenLanguage]['text_next']),
                  )
                ],
              ),
            ),
            if (loginLoading == true) const Positioned(child: Loading())
          ],
        ),
      ),
    );
  }
}
