import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import 'adminchatpage.dart';
import 'faq.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
        child: Directionality(
            textDirection: (languageDirection == 'rtl')
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: Stack(children: [
              Container(
                  padding: EdgeInsets.all(media.width * 0.05),
                  height: media.height * 1,
                  width: media.width * 1,
                  color: page,
                  child: Column(
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
                              text: languages[choosenLanguage]['text_support'],
                              size: media.width * twenty,
                              fontweight: FontWeight.w600,
                            ),
                          ),
                          Positioned(
                              child: InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Icon(
                                    Icons.arrow_back_ios,
                                    color: textColor,
                                  )))
                        ],
                      ),
                      SizedBox(
                        height: media.width * 0.05,
                      ),
                      //Admin chat

                      ValueListenableBuilder(
                          valueListenable: valueNotifierChat.value,
                          builder: (context, value, child) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const AdminChatPage()));
                              },
                              child: Container(
                                color: page,
                                padding: EdgeInsets.all(media.width * 0.03),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.chat,
                                            size: media.width * 0.07,
                                            color: textColor.withOpacity(0.5)),
                                        SizedBox(
                                          width: media.width * 0.025,
                                        ),
                                        Expanded(
                                          child: MyText(
                                            text: languages[choosenLanguage]
                                                ['text_chat_us'],
                                            overflow: TextOverflow.ellipsis,
                                            size: media.width * sixteen,
                                            color: textColor.withOpacity(0.8),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            (unSeenChatCount == '0')
                                                ? Container()
                                                : Container(
                                                    height: 20,
                                                    width: 20,
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: buttonColor,
                                                    ),
                                                    child: Text(
                                                      unSeenChatCount,
                                                      style:
                                                          GoogleFonts.notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      fourteen,
                                                              color:
                                                                  buttonText),
                                                    ),
                                                  ),
                                            Icon(
                                              Icons.arrow_right_rounded,
                                              size: media.width * 0.05,
                                              color: textColor.withOpacity(0.8),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                      SizedBox(
                        height: media.width * 0.02,
                      ),
                      //faq
                      SubMenu(
                        icon: Icons.warning_amber,
                        text: languages[choosenLanguage]['text_faq'],
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Faq()));
                        },
                      ),
                      SizedBox(
                        height: media.width * 0.02,
                      ),
                      //privacy policy

                      SubMenu(
                        onTap: () {
                          openBrowser('privacy policy url');
                        },
                        text: languages[choosenLanguage]['text_privacy'],
                        icon: Icons.privacy_tip_outlined,
                      ),
                    ],
                  )),
            ])));
  }
}
