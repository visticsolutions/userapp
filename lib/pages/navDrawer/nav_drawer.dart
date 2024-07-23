import 'package:flutter/material.dart';
import 'package:flutter_user/pages/NavigatorPages/fav_address.dart';
import 'package:flutter_user/pages/NavigatorPages/makecomplaint.dart';
import 'package:flutter_user/pages/NavigatorPages/outstation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../NavigatorPages/editprofile.dart';
import '../NavigatorPages/history.dart';
import '../NavigatorPages/notification.dart';
import '../NavigatorPages/referral.dart';
import '../NavigatorPages/settings.dart';
import '../NavigatorPages/sos.dart';
import '../NavigatorPages/support.dart';
import '../NavigatorPages/walletpage.dart';
import '../onTripPage/map_page.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});
  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return ValueListenableBuilder(
        valueListenable: valueNotifierHome.value,
        builder: (context, value, child) {
          return SizedBox(
            width: media.width * 0.8,
            child: Directionality(
              textDirection: (languageDirection == 'rtl')
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Container(
                color: Colors.white,
                child: Container(
                  height: media.height,
                  width: media.width * 0.8,
                  decoration: BoxDecoration(color: page),
                  child: Column(
                    children: [
                      SizedBox(
                        height: media.width * 0.05 +
                            MediaQuery.of(context).padding.top,
                      ),
                      InkWell(
                        onTap: () async {
                          var val = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const EditProfile()));
                          if (val) {
                            setState(() {});
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(media.width * 0.025),
                          width: media.width * 0.7,
                          decoration: BoxDecoration(
                            color: const Color(0xffD88D0D).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: media.width * 0.15,
                                height: media.width * 0.15,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            userDetails['profile_picture']),
                                        fit: BoxFit.cover)),
                              ),
                              SizedBox(
                                width: media.width * 0.025,
                              ),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: userDetails['name'],
                                    size: media.width * fourteen,
                                    fontweight: FontWeight.w600,
                                    maxLines: 1,
                                  ),
                                  MyText(
                                    text: userDetails['mobile'],
                                    size: media.width * fourteen,
                                    fontweight: FontWeight.w500,
                                    maxLines: 1,
                                  ),
                                ],
                              )),
                              SizedBox(
                                width: media.width * 0.025,
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: media.width * 0.04,
                                color: textColor,
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                          child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              width: media.width * 0.7,
                              child: NavMenu(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const FavAddressPage()));
                                },
                                text: languages[choosenLanguage]
                                    ['text_fav_address'],
                                icon: Icons.stars_outlined,
                              ),
                            ),
                            SizedBox(
                              width: media.width * 0.7,
                              child: NavMenu(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const History()));
                                },
                                text: languages[choosenLanguage]
                                    ['text_enable_history'],
                                icon: Icons.view_list_outlined,
                              ),
                            ),
                            ValueListenableBuilder(
                                valueListenable:
                                    valueNotifierNotification.value,
                                builder: (context, value, child) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const NotificationPage()));
                                      setState(() {
                                        userDetails['notifications_count'] = 0;
                                      });
                                    },
                                    child: Container(
                                      width: media.width * 0.7,
                                      padding: EdgeInsets.only(
                                          top: media.width * 0.07),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.notifications_none,
                                            size: media.width * 0.04,
                                            color: textColor,
                                          ),
                                          SizedBox(
                                            width: media.width * 0.025,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: (userDetails[
                                                            'notifications_count'] ==
                                                        0)
                                                    ? media.width * 0.55
                                                    : media.width * 0.495,
                                                child: MyText(
                                                    text: languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_notification']
                                                        .toString(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    size: media.width * sixteen,
                                                    color: textColor),
                                              ),
                                              (userDetails[
                                                          'notifications_count'] ==
                                                      0)
                                                  ? Container()
                                                  : Container(
                                                      height: 25,
                                                      width: 25,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: buttonColor,
                                                      ),
                                                      child: Text(
                                                        userDetails[
                                                                'notifications_count']
                                                            .toString(),
                                                        style: GoogleFonts.notoSans(
                                                            fontSize:
                                                                media.width *
                                                                    twelve,
                                                            color: (isDarkTheme)
                                                                ? Colors.black
                                                                : buttonText),
                                                      ),
                                                    ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                            if (userDetails['show_outstation_ride_feature']
                                    .toString() ==
                                "1")
                              SizedBox(
                                width: media.width * 0.7,
                                child: NavMenu(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const OutStationRides()));
                                  },
                                  text: languages[choosenLanguage]
                                      ['text_outstation'],
                                  icon: Icons.luggage_outlined,
                                ),
                              ),

                            //wallet page

                            (userDetails['owner_id'] == null &&
                                    userDetails['show_wallet_feature_on_mobile_app']
                                            .toString() ==
                                        '1')
                                ? SizedBox(
                                    width: media.width * 0.7,
                                    child: NavMenu(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const WalletPage()));
                                      },
                                      text: languages[choosenLanguage]
                                          ['text_enable_wallet'],
                                      icon: Icons.payment,
                                    ),
                                  )
                                : Container(),

                            //sos page
                            SizedBox(
                              width: media.width * 0.7,
                              child: NavMenu(
                                onTap: () async {
                                  var nav = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => const Sos()));
                                  if (nav) {
                                    setState(() {});
                                  }
                                },
                                text: languages[choosenLanguage]['text_sos'],
                                icon: Icons.connect_without_contact,
                              ),
                            ),
                            //makecomplaints
                            SizedBox(
                              width: media.width * 0.7,
                              child: NavMenu(
                                icon: Icons.toc,
                                text: languages[choosenLanguage]
                                    ['text_make_complaints'],
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const MakeComplaint()));
                                },
                              ),
                            ),

                            //settings
                            SizedBox(
                              width: media.width * 0.7,
                              child: NavMenu(
                                onTap: () async {
                                  var nav = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SettingsPage()));
                                  if (nav) {
                                    setState(() {});
                                  }
                                },
                                text: languages[choosenLanguage]
                                    ['text_settings'],
                                icon: Icons.settings,
                              ),
                            ),

                            //support
                            ValueListenableBuilder(
                                valueListenable: valueNotifierChat.value,
                                builder: (context, value, child) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SupportPage()));
                                    },
                                    child: Container(
                                      width: media.width * 0.7,
                                      padding: EdgeInsets.only(
                                          top: media.width * 0.07),
                                      child: Row(
                                        children: [
                                          Icon(Icons.support_agent,
                                              size: media.width * 0.04,
                                              color: textColor),
                                          SizedBox(
                                            width: media.width * 0.025,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                width: (unSeenChatCount == '0')
                                                    ? media.width * 0.55
                                                    : media.width * 0.495,
                                                child: MyText(
                                                  text:
                                                      languages[choosenLanguage]
                                                          ['text_support'],
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  size: media.width * sixteen,
                                                  color: textColor,
                                                ),
                                              ),
                                              (unSeenChatCount == '0')
                                                  ? Container()
                                                  : Container(
                                                      height: 20,
                                                      width: 20,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color: buttonColor,
                                                      ),
                                                      child: Text(
                                                        unSeenChatCount,
                                                        style: GoogleFonts.notoSans(
                                                            fontSize:
                                                                media.width *
                                                                    fourteen,
                                                            color: (isDarkTheme)
                                                                ? Colors.black
                                                                : buttonText),
                                                      ),
                                                    ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                            //referral page
                            SizedBox(
                              width: media.width * 0.7,
                              child: NavMenu(
                                onTap: () {
                                  Future.delayed(
                                      const Duration(microseconds: 500), () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ReferralPage()));
                                  });
                                },
                                text: languages[choosenLanguage]
                                    ['text_referral'],
                                image: 'assets/images/referral.png',
                              ),
                            ),

                            SizedBox(
                              // padding: EdgeInsets.only(top: 100),
                              width: media.width * 0.7,
                              child: NavMenu(
                                onTap: () {
                                  setState(() {
                                    logout = true;
                                  });
                                  valueNotifierHome.incrementNotifier();
                                  Navigator.pop(context);
                                },
                                text: languages[choosenLanguage]
                                    ['text_sign_out'],
                                icon: Icons.logout,
                                textcolor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ))
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
