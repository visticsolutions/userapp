import 'package:flutter/material.dart';
import 'package:flutter_user/widgets/widgets.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return SafeArea(
      child: Material(
        child: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Container(
            padding: EdgeInsets.all(media.width * 0.05),
            height: media.height * 1,
            width: media.width * 1,
            color: page,
            child: Column(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: MediaQuery.of(context).padding.top),
                      Stack(
                        children: [
                          Container(
                            padding:
                                EdgeInsets.only(bottom: media.width * 0.05),
                            width: media.width * 1,
                            alignment: Alignment.center,
                            child: MyText(
                              text: languages[choosenLanguage]['text_about'],
                              size: media.width * twenty,
                              color: textColor,
                              fontweight: FontWeight.w600,
                            ),
                          ),
                          Positioned(
                              child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Icon(Icons.arrow_back_ios)))
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      SizedBox(
                        width: media.width * 0.9,
                        height: media.height * 0.16,
                        child: Image.asset(
                          'assets/images/aboutImage.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(
                        height: media.width * 0.1,
                      ),
                      //terms and condition
                      InkWell(
                          onTap: () {
                            openBrowser('terms and conditions url');
                          },
                          child: MyText(
                            text: languages[choosenLanguage]
                                ['text_termsandconditions'],
                            size: media.width * sixteen,
                            fontweight: FontWeight.w600,
                            color: textColor,
                          )),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      //privacy policy
                      InkWell(
                          onTap: () {
                            openBrowser('privacy policy url');
                          },
                          child: MyText(
                            text: languages[choosenLanguage]['text_privacy'],
                            size: media.width * sixteen,
                            fontweight: FontWeight.w600,
                          )),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      InkWell(
                          onTap: () {
                            openBrowser('website url');
                          },
                          child: MyText(
                            text: languages[choosenLanguage]['text_about'],
                            size: media.width * sixteen,
                            fontweight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
