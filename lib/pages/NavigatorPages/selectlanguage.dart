import 'package:flutter/material.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({super.key});

  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  var _choosenLanguage = choosenLanguage;

  //navigate pop
  pop() {
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return PopScope(
      canPop: true,
      child: Material(
        child: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(
                    media.width * 0.05,
                    media.width * 0.05 + MediaQuery.of(context).padding.top,
                    media.width * 0.05,
                    media.width * 0.05),
                color: page,
                child: Row(
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back_ios, color: textColor)),
                    Expanded(
                      child: MyText(
                        textAlign: TextAlign.center,
                        text: languages[choosenLanguage]
                            ['text_change_language'],
                        size: media.width * twenty,
                        maxLines: 1,
                        fontweight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: media.width * 1,
                  padding: EdgeInsets.fromLTRB(media.width * 0.05,
                      media.width * 0.03, media.width * 0.05, 0),
                  color: (isDarkTheme)
                      ? Colors.grey
                      : Colors.grey.withOpacity(0.2),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(media.width * 0.02),
                          decoration: BoxDecoration(
                              color: page,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(media.width * 0.03),
                                  topRight:
                                      Radius.circular(media.width * 0.03))),
                          child: Column(
                            children: [
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    children: languages
                                        .map((i, value) {
                                          return MapEntry(
                                              i,
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _choosenLanguage = i;
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(
                                                      media.width * 0.025),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      MyText(
                                                        text: languagesCode
                                                            .firstWhere((e) =>
                                                                e['code'] ==
                                                                i)['name']
                                                            .toString(),
                                                        size: media.width *
                                                            sixteen,
                                                      ),
                                                      Container(
                                                        height:
                                                            media.width * 0.05,
                                                        width:
                                                            media.width * 0.05,
                                                        decoration: BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            border: Border.all(
                                                                color:
                                                                    textColor,
                                                                width: 1.2)),
                                                        alignment:
                                                            Alignment.center,
                                                        child:
                                                            (_choosenLanguage ==
                                                                    i)
                                                                ? Container(
                                                                    height: media
                                                                            .width *
                                                                        0.03,
                                                                    width: media
                                                                            .width *
                                                                        0.03,
                                                                    decoration: BoxDecoration(
                                                                        shape: BoxShape
                                                                            .circle,
                                                                        color:
                                                                            textColor),
                                                                  )
                                                                : Container(),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ));
                                        })
                                        .values
                                        .toList(),
                                  ),
                                ),
                              ),
                              Button(
                                  onTap: () async {
                                    choosenLanguage = _choosenLanguage;
                                    if (choosenLanguage == 'ar' ||
                                        choosenLanguage == 'ur' ||
                                        choosenLanguage == 'iw') {
                                      languageDirection = 'rtl';
                                    } else {
                                      languageDirection = 'ltr';
                                    }
                                    await getlangid();
                                    pref.setString(
                                        'languageDirection', languageDirection);
                                    pref.setString(
                                        'choosenLanguage', _choosenLanguage);
                                    valueNotifierHome.incrementNotifier();
                                    pop();
                                  },
                                  text: languages[choosenLanguage]
                                      ['text_confirm'])
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
