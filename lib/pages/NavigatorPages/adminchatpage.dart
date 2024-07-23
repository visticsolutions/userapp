import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import 'dart:ui' as ui;
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';

class AdminChatPage extends StatefulWidget {
  const AdminChatPage({super.key});

  @override
  State<AdminChatPage> createState() => _AdminChatPageState();
}

String adminChatmessage = '';

class _AdminChatPageState extends State<AdminChatPage> {
  TextEditingController adminchatText = TextEditingController();
  ScrollController controller = ScrollController();
  bool _loading = false;
  bool contactus = false;
  @override
  void initState() {
    //get messages
    _loading = true;
    getmessage();
    super.initState();
  }

  getmessage() async {
    adminChatList.clear();
    if (chatid != null && unSeenChatCount != '0') {
      adminmessageseen();
    }
    var result = await getadminCurrentMessages();
    if (result == 'success') {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          unSeenChatCount = '0';
          if (chatid != null) {
            adminmessageseen();
          }
          // Navigator.pop(context, true);
          valueNotifierChat.incrementNotifier();
        },
        child: Material(
          child: Scaffold(
            body: ValueListenableBuilder(
                valueListenable: valueNotifierChat.value,
                builder: (context, value, child) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    controller.animateTo(controller.position.maxScrollExtent,
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease);
                  });
                  //call for message seen
                  // messageSeen();

                  return Directionality(
                    textDirection: (languageDirection == 'rtl')
                        ? ui.TextDirection.rtl
                        : ui.TextDirection.ltr,
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              media.width * 0.05,
                              MediaQuery.of(context).padding.top +
                                  media.width * 0.05,
                              media.width * 0.05,
                              media.width * 0.05),
                          height: media.height * 1,
                          width: media.width * 1,
                          color: page,
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                      width: media.width * 0.9,
                                      alignment: Alignment.center,
                                      child: Column(
                                        children: [
                                          MyText(
                                            text: languages[choosenLanguage]
                                                ['text_admin_chat'],
                                            size: media.width * sixteen,
                                            fontweight: FontWeight.bold,
                                          ),
                                          SizedBox(
                                            height: media.width * 0.025,
                                          ),
                                        ],
                                      )),
                                  Positioned(
                                    child: InkWell(
                                      onTap: () {
                                        if (contactus == false) {
                                          setState(() {
                                            contactus = true;
                                          });
                                        } else {
                                          setState(() {
                                            contactus = false;
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: media.width * 0.1,
                                        width: media.width,
                                        alignment: Alignment.centerRight,
                                        child:
                                            Icon(Icons.call, color: textColor),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    child: InkWell(
                                      onTap: () {
                                        unSeenChatCount = '0';
                                        if (chatid != null &&
                                            unSeenChatCount != '0') {
                                          adminmessageseen();
                                        }
                                        valueNotifierChat.incrementNotifier();
                                        Navigator.pop(context, true);
                                      },
                                      child: Container(
                                        height: media.width * 0.1,
                                        width: media.width * 0.1,
                                        alignment: Alignment.center,
                                        child: Icon(Icons.arrow_back_ios,
                                            color: textColor),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: media.width * 0.05,
                              ),
                              Expanded(
                                  child: SingleChildScrollView(
                                controller: controller,
                                child: Column(
                                  children: adminChatList
                                      .asMap()
                                      .map((i, value) {
                                        return MapEntry(
                                            i,
                                            Container(
                                              padding: EdgeInsets.only(
                                                  top: media.width * 0.01),
                                              width: media.width * 0.9,
                                              alignment: (adminChatList[i]
                                                              ['from_id']
                                                          .toString() ==
                                                      userDetails['id']
                                                          .toString())
                                                  ? Alignment.centerRight
                                                  : Alignment.centerLeft,
                                              child: Column(
                                                crossAxisAlignment:
                                                    (adminChatList[i]['from_id']
                                                                .toString() ==
                                                            userDetails['id']
                                                                .toString())
                                                        ? CrossAxisAlignment.end
                                                        : CrossAxisAlignment
                                                            .start,
                                                children: [
                                                  Card(
                                                    elevation: 5,
                                                    child: Container(
                                                      width: media.width * 0.5,
                                                      padding: EdgeInsets.all(
                                                          media.width * 0.03),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft: (adminChatList[i]
                                                                            [
                                                                            'from_id']
                                                                        .toString() ==
                                                                    userDetails[
                                                                            'id']
                                                                        .toString())
                                                                ? Radius.circular(
                                                                    media.width *
                                                                        0.02)
                                                                : const Radius
                                                                    .circular(
                                                                    0),
                                                            topRight: (adminChatList[i]
                                                                            [
                                                                            'from_id']
                                                                        .toString() ==
                                                                    userDetails[
                                                                            'id']
                                                                        .toString())
                                                                ? const Radius
                                                                    .circular(0)
                                                                : Radius.circular(
                                                                    media.width *
                                                                        0.02),
                                                            bottomRight: Radius
                                                                .circular(media
                                                                        .width *
                                                                    0.02),
                                                            bottomLeft: Radius
                                                                .circular(media
                                                                        .width *
                                                                    0.02),
                                                          ),
                                                          color: (adminChatList[
                                                                              i]
                                                                          [
                                                                          'from_id']
                                                                      .toString() ==
                                                                  userDetails[
                                                                          'id']
                                                                      .toString())
                                                              ? buttonColor
                                                              : const Color(
                                                                  0xffE7EDEF)),
                                                      child: MyText(
                                                        text: adminChatList[i]
                                                            ['message'],
                                                        size: media.width *
                                                            fourteen,
                                                        color: (isDarkTheme ==
                                                                true)
                                                            ? Colors.black
                                                            : textColor,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.01,
                                                  ),
                                                  MyText(
                                                    text: adminChatList[i]
                                                        ['user_timezone'],
                                                    size: media.width * ten,
                                                  )
                                                ],
                                              ),
                                            ));
                                      })
                                      .values
                                      .toList(),
                                ),
                              )),

                              //text field
                              Container(
                                margin:
                                    EdgeInsets.only(top: media.width * 0.025),
                                padding: EdgeInsets.fromLTRB(
                                    media.width * 0.025,
                                    media.width * 0.01,
                                    media.width * 0.025,
                                    media.width * 0.01),
                                width: media.width * 0.9,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: borderLines, width: 1.2),
                                    color: page),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                      width: media.width * 0.7,
                                      child: TextField(
                                        controller: adminchatText,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: languages[choosenLanguage]
                                              ['text_entermessage'],
                                          hintStyle: GoogleFonts.notoSans(
                                            color: textColor.withOpacity(0.4),
                                            fontSize: media.width * twelve,
                                          ),
                                        ),
                                        style: GoogleFonts.notoSans(
                                          color: textColor,
                                        ),
                                        minLines: 1,
                                        maxLines: 4,
                                        onChanged: (val) {
                                          setState(() {
                                            adminChatmessage =
                                                adminchatText.text;
                                          });
                                        },
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () async {
                                        FocusManager.instance.primaryFocus
                                            ?.unfocus();

                                        setState(() {
                                          _loading = true;
                                        });
                                        adminchatText.clear();
                                        var val = await sendadminMessage(
                                            adminChatmessage);
                                        if (val == 'success') {
                                          setState(() {
                                            _loading = false;
                                          });
                                        }
                                      },
                                      child: Image.asset(
                                        'assets/images/send.png',
                                        fit: BoxFit.contain,
                                        width: media.width * 0.075,
                                        color: textColor,
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        (contactus == true)
                            ? Positioned(
                                right: 10,
                                top: 110,
                                child: InkWell(
                                  onTap: () async {},
                                  child: Container(
                                      padding: const EdgeInsets.all(10),
                                      height: media.width * 0.3,
                                      width: media.width * 0.45,
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                blurRadius: 2,
                                                color: Colors.black
                                                    .withOpacity(0.2),
                                                spreadRadius: 2)
                                          ],
                                          color: page,
                                          borderRadius: BorderRadius.circular(
                                              media.width * 0.02)),
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              makingPhoneCall(userDetails[
                                                  'contact_us_mobile1']);
                                            },
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    flex: 20,
                                                    child: Icon(
                                                      Icons.call,
                                                      color: textColor,
                                                    )),
                                                Expanded(
                                                    flex: 80,
                                                    child: Text(
                                                      userDetails[
                                                          'contact_us_mobile1'],
                                                      style:
                                                          GoogleFonts.notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      fourteen,
                                                              color: textColor),
                                                    ))
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              makingPhoneCall(userDetails[
                                                  'contact_us_mobile1']);
                                            },
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    flex: 20,
                                                    child: Icon(Icons.call,
                                                        color: textColor)),
                                                Expanded(
                                                    flex: 80,
                                                    child: Text(
                                                      userDetails[
                                                          'contact_us_mobile2'],
                                                      style:
                                                          GoogleFonts.notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      fourteen,
                                                              color: textColor),
                                                    ))
                                              ],
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              openBrowser(
                                                  userDetails['contact_us_link']
                                                      .toString());
                                            },
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    flex: 20,
                                                    child: Icon(
                                                        Icons.vpn_lock_rounded,
                                                        color: textColor)),
                                                Expanded(
                                                    flex: 80,
                                                    child: Text(
                                                      languages[choosenLanguage]
                                                          ['text_goto_url'],
                                                      maxLines: 1,
                                                      style:
                                                          GoogleFonts.notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      fourteen,
                                                              color: textColor),
                                                    ))
                                              ],
                                            ),
                                          )
                                        ],
                                      )),
                                ),
                              )
                            : Container(),
                        //loader
                        (_loading == true)
                            ? const Positioned(top: 0, child: Loading())
                            : Container()
                      ],
                    ),
                  );
                }),
          ),
        ));
  }
}
