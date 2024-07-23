import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
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
            padding: EdgeInsets.fromLTRB(
                media.width * 0.05,
                MediaQuery.of(context).padding.top + media.width * 0.05,
                media.width * 0.05,
                0),
            height: media.height * 1,
            width: media.width * 1,
            color: page,
            child: Column(children: [
              Stack(
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: media.width * 0.05),
                    width: media.width * 0.9,
                    alignment: Alignment.center,
                    child: MyText(
                      text: languages[choosenLanguage]['text_help'],
                      fontweight: FontWeight.bold,
                      size: media.width * twenty,
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
              Row(
                children: [
                  MyText(
                    text: languages[choosenLanguage]['text_you_contact']
                        .toString(),
                    size: media.width * sixteen,
                    fontweight: FontWeight.w700,
                  ),
                ],
              ),
              SizedBox(
                height: media.width * 0.03,
              ),
              Container(
                height: media.width * 0.13,
                width: media.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: topBar,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.0),
                        spreadRadius: 1,
                        blurRadius: 1)
                  ],
                ),
                padding: EdgeInsets.all(media.width * 0.03),
                child: InkWell(
                  onTap: () {
                    // ignore: deprecated_member_use
                    launch(
                        'https://wa.me/${userDetails['contact_us_whatsapp'].toString()}');
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/whatsapp.png',
                        fit: BoxFit.contain,
                        width: media.width * 0.1,
                      ),
                      SizedBox(
                        width: media.width * 0.025,
                      ),
                      MyText(
                        text: userDetails['contact_us_whatsapp'].toString(),
                        size: media.width * sixteen,
                        fontweight: FontWeight.w700,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Container(
                height: media.width * 0.13,
                width: media.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: topBar,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.0),
                        spreadRadius: 1,
                        blurRadius: 1)
                  ],
                ),
                padding: EdgeInsets.all(media.width * 0.03),
                child: InkWell(
                  onTap: () {
                    // ignore: deprecated_member_use
                    launch(
                        'https://t.me/${userDetails['contact_us_telegram'].toString()}');
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/telegram.png',
                        fit: BoxFit.contain,
                        width: media.width * 0.1,
                      ),
                      SizedBox(
                        width: media.width * 0.025,
                      ),
                      MyText(
                        text: userDetails['contact_us_telegram'].toString(),
                        size: media.width * sixteen,
                        fontweight: FontWeight.w700,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Container(
                height: media.width * 0.13,
                width: media.width * 0.9,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: topBar,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.0),
                        spreadRadius: 1,
                        blurRadius: 1)
                  ],
                ),
                padding: EdgeInsets.all(media.width * 0.03),
                child: InkWell(
                  onTap: () {
                    // ignore: deprecated_member_use
                    launch(
                        'mailto:${userDetails['contact_us_email'].toString()}');
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.mail,
                        size: media.width * 0.05,
                        color: const Color(0xFFC99B61),
                      ),
                      SizedBox(
                        width: media.width * 0.025,
                      ),
                      MyText(
                        text: userDetails['contact_us_email'].toString(),
                        size: media.width * sixteen,
                        fontweight: FontWeight.w700,
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
