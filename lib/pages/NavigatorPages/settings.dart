import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../login/login.dart';
import 'selectlanguage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isLoading = false;
  bool deleteAccount = false;
  navigateLogout() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false);
    });
  }

  darkthemefun() async {
    if (isDarkTheme) {
      isDarkTheme = false;
    } else {
      isDarkTheme = true;
    }
    await getDetailsOfDevice();

    pref.setBool('isDarkTheme', isDarkTheme);

    // valueNotifierHome.incrementNotifier();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return ValueListenableBuilder(
        valueListenable: valueNotifierHome.value,
        builder: (context, value, child) {
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
                                text: languages[choosenLanguage]
                                    ['text_settings'],
                                size: media.width * twenty,
                                fontweight: FontWeight.w600,
                              ),
                            ),
                            Positioned(
                                child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context, true);
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
                        SubMenu(
                          icon: Icons.language_outlined,
                          text: languages[choosenLanguage]
                              ['text_change_language'],
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SelectLanguage()));
                          },
                        ),
                        SizedBox(
                          height: media.width * 0.02,
                        ),
                        InkWell(
                          onTap: () async {
                            darkthemefun();
                          },
                          child: Container(
                            color: page,
                            padding: EdgeInsets.all(media.width * 0.03),
                            child: Row(
                              children: [
                                Icon(
                                  isDarkTheme
                                      ? Icons.brightness_4_outlined
                                      : Icons.brightness_3_rounded,
                                  size: media.width * 0.075,
                                  color: textColor.withOpacity(0.5),
                                ),
                                SizedBox(
                                  width: media.width * 0.025,
                                ),
                                Expanded(
                                  child: Text(
                                    languages[choosenLanguage]
                                        ['text_select_theme'],
                                    style: GoogleFonts.notoSans(
                                        fontSize: media.width * sixteen,
                                        color: textColor.withOpacity(0.8)),
                                  ),
                                ),
                                SizedBox(
                                  height: media.width * 0.07,
                                  child: Switch(
                                      value: isDarkTheme,
                                      onChanged: (toggle) async {
                                        darkthemefun();
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: media.width * 0.02,
                        ),
                        userDetails['owner_id'] == null
                            ? SubMenu(
                                icon: Icons.delete_outline,
                                text: languages[choosenLanguage]
                                    ['text_delete_account'],
                                onTap: () {
                                  setState(() {
                                    deleteAccount = true;
                                  });
                                },
                              )
                            : Container(),
                      ],
                    )),

                //delete account
                (deleteAccount == true)
                    ? Positioned(
                        top: 0,
                        child: Container(
                          height: media.height * 1,
                          width: media.width * 1,
                          color: Colors.transparent.withOpacity(0.6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: media.width * 0.9,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                        height: media.height * 0.1,
                                        width: media.width * 0.1,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: borderLines
                                                    .withOpacity(0.5)),
                                            shape: BoxShape.circle,
                                            color: page),
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                deleteAccount = false;
                                              });
                                            },
                                            child: Icon(
                                              Icons.cancel_outlined,
                                              color: textColor,
                                            ))),
                                  ],
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(media.width * 0.05),
                                width: media.width * 0.9,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: borderLines.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(12),
                                    color: page),
                                child: Column(
                                  children: [
                                    Text(
                                      (userDetails['is_deleted_at'] == null)
                                          ? languages[choosenLanguage]
                                              ['text_delete_confirm']
                                          : userDetails['is_deleted_at']
                                              .toString(),
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.notoSans(
                                          fontSize: media.width * sixteen,
                                          color: textColor,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(
                                      height: media.width * 0.05,
                                    ),
                                    Button(
                                        onTap: () async {
                                          if (userDetails['is_deleted_at'] ==
                                              null) {
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            var result = await userDelete();
                                            if (result == 'success') {
                                              await getUserDetails();
                                              deleteAccount = false;
                                            } else if (result == 'logout') {
                                              navigateLogout();
                                            } else {
                                              deleteAccount = true;
                                            }
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          } else {
                                            setState(() {
                                              deleteAccount = false;
                                            });
                                          }
                                        },
                                        text: languages[choosenLanguage]
                                            ['text_confirm'])
                                  ],
                                ),
                              )
                            ],
                          ),
                        ))
                    : Container(),
                //loader
                (_isLoading == true)
                    ? const Positioned(top: 0, child: Loading())
                    : Container()
              ]),
            ),
          );
        });
  }
}
