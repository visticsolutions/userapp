import 'package:flutter/material.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../onTripPage/map_page.dart';

class Referral extends StatefulWidget {
  const Referral({super.key});

  @override
  State<Referral> createState() => _ReferralState();
}

dynamic referralCode;

class _ReferralState extends State<Referral> {
  bool _loading = false;
  String _error = '';
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    referralCode = '';
    super.initState();
  }

  //navigate
  navigate() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Maps()));
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                  left: media.width * 0.08, right: media.width * 0.08),
              height: media.height * 1,
              width: media.width * 1,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [theme.withOpacity(0.5), backgroundColor])),
              child: Column(
                children: [
                  SizedBox(
                    height: media.height * 0.05 +
                        MediaQuery.of(context).padding.top,
                  ),
                  SizedBox(
                      width: media.width * 1,
                      child: MyText(
                        text: languages[choosenLanguage]['text_apply_referral'],
                        size: media.width * twenty,
                        fontweight: FontWeight.bold,
                      )),
                  const SizedBox(height: 10),
                  Container(
                    height: media.width * 0.12,
                    width: media.width * 0.8,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white),
                    padding: EdgeInsets.only(
                        right: media.width * 0.025, left: media.width * 0.025),
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                          hintText: languages[choosenLanguage]
                              ['text_enter_referral'],
                          border: InputBorder.none),
                    ),
                  ),
                  (_error != '' && controller.text.isNotEmpty)
                      ? Container(
                          margin: EdgeInsets.only(top: media.height * 0.02),
                          child: MyText(
                            text: _error,
                            size: media.width * sixteen,
                            color: Colors.red,
                          ),
                        )
                      : Container(),
                  const SizedBox(
                    height: 40,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //skip
                      Button(
                          width: media.width * 0.4,
                          onTap: () async {
                            setState(() {
                              _loading = true;
                            });
                            // var val = await registerUser();
                            FocusManager.instance.primaryFocus?.unfocus();
                            _error = '';
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Maps()));

                            setState(() {
                              _loading = false;
                            });
                          },
                          text: languages[choosenLanguage]['text_skip']),
                      //apply code
                      Button(
                        width: media.width * 0.4,
                        onTap: () async {
                          if (controller.text.isNotEmpty) {
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() {
                              _error = '';
                              _loading = true;
                            });

                            var result = await updateReferral();
                            if (result == 'true') {
                              navigate();
                            } else {
                              setState(() {
                                _error = languages[choosenLanguage]
                                    ['text_referral_code'];
                              });
                            }
                            setState(() {
                              _loading = false;
                            });
                          } else {}
                        },
                        text: languages[choosenLanguage]['text_apply'],
                        color: (controller.text.isNotEmpty)
                            ? buttonColor
                            : Colors.grey,
                      )
                    ],
                  )
                ],
              ),
            ),
            //loader
            (_loading == true)
                ? const Positioned(top: 0, child: Loading())
                : Container()
          ],
        ),
      ),
    );
  }
}
