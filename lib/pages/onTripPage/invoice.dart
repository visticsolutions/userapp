import 'package:flutter/material.dart';
import 'package:flutter_user/pages/NavigatorPages/paymentgateways.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../NavigatorPages/walletpage.dart';
import '../loadingPage/loading.dart';
import '../login/login.dart';
import 'booking_confirmation.dart';
import 'map_page.dart';
import 'review_page.dart';

class Invoice extends StatefulWidget {
  const Invoice({super.key});

  @override
  State<Invoice> createState() => _InvoiceState();
}

class _InvoiceState extends State<Invoice> {
  bool _choosePayment = false;
  bool _isLoading = false;
  bool _choosePaymentMethod = false;
  String _error = '';
  String myPaymentMethod = '';

  @override
  void initState() {
    myMarkers.clear();
    promoCode = '';
    payingVia = 0;
    timing = null;
    promoStatus = null;
    super.initState();
  }

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: Directionality(
        textDirection: (languageDirection == 'rtl')
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: ValueListenableBuilder(
            valueListenable: valueNotifierHome.value,
            builder: (context, value, child) {
              return Stack(
                children: [
                  if (userRequestData.isNotEmpty)
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
                      //invoice details
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                          onTap: () {
                                            Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        const Maps()),
                                                (route) => false);
                                          },
                                          child: Icon(
                                            Icons.arrow_back_ios,
                                            size: media.width * 0.07,
                                          )),
                                      MyText(
                                        text: languages[choosenLanguage]
                                            ['text_tripsummary'],
                                        size: media.width * sixteen,
                                        fontweight: FontWeight.bold,
                                      ),
                                      SizedBox(width: media.width * 0.05)
                                    ],
                                  ),
                                  SizedBox(
                                    height: media.height * 0.04,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: media.width * 0.13,
                                        width: media.width * 0.13,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: NetworkImage(
                                                    userRequestData[
                                                                'driverDetail']
                                                            ['data']
                                                        ['profile_picture']),
                                                fit: BoxFit.cover)),
                                      ),
                                      SizedBox(
                                        width: media.width * 0.05,
                                      ),
                                      MyText(
                                        text: userRequestData['driverDetail']
                                            ['data']['name'],
                                        size: media.width * eighteen,
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: media.height * 0.05,
                                  ),
                                  Container(
                                    padding: EdgeInsets.all(media.width * 0.04),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1)),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Column(
                                              children: [
                                                MyText(
                                                  text:
                                                      languages[choosenLanguage]
                                                          ['text_reference'],
                                                  size: media.width * fourteen,
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.02,
                                                ),
                                                MyText(
                                                  text: userRequestData[
                                                      'request_number'],
                                                  size: media.width * twelve,
                                                  fontweight: FontWeight.w700,
                                                )
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                MyText(
                                                  text:
                                                      languages[choosenLanguage]
                                                          ['text_rideType'],
                                                  size: media.width * fourteen,
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.02,
                                                ),
                                                MyText(
                                                  text: (userRequestData[
                                                              'is_rental'] ==
                                                          false)
                                                      ? languages[
                                                              choosenLanguage]
                                                          ['text_regular']
                                                      : languages[
                                                              choosenLanguage]
                                                          ['text_rental'],
                                                  size: media.width * twelve,
                                                  fontweight: FontWeight.w700,
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: media.height * 0.02,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Column(
                                              children: [
                                                MyText(
                                                  text:
                                                      languages[choosenLanguage]
                                                          ['text_distance'],
                                                  size: media.width * fourteen,
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.02,
                                                ),
                                                MyText(
                                                  text: userRequestData[
                                                          'total_distance'] +
                                                      ' ' +
                                                      userRequestData['unit'],
                                                  size: media.width * twelve,
                                                  fontweight: FontWeight.w700,
                                                )
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                MyText(
                                                  text:
                                                      languages[choosenLanguage]
                                                          ['text_duration'],
                                                  size: media.width * fourteen,
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.02,
                                                ),
                                                MyText(
                                                  text:
                                                      '${userRequestData['total_time']} ${languages[choosenLanguage]['text_mins']}',
                                                  size: media.width * twelve,
                                                  fontweight: FontWeight.w700,
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: media.height * 0.03,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: media.width * 0.05,
                                        width: media.width * 0.05,
                                        alignment: Alignment.center,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.green),
                                        child: Container(
                                          height: media.width * 0.025,
                                          width: media.width * 0.025,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white
                                                  .withOpacity(0.8)),
                                        ),
                                      ),
                                      SizedBox(
                                        width: media.width * 0.06,
                                      ),
                                      Expanded(
                                        child: MyText(
                                          text: userRequestData['pick_address'],
                                          size: media.width * twelve,
                                          // maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: media.width * 0.02,
                                  ),
                                  (tripStops.isNotEmpty)
                                      ? Column(
                                          children: tripStops
                                              .asMap()
                                              .map((i, value) {
                                                return MapEntry(
                                                    i,
                                                    (i < tripStops.length - 1)
                                                        ? Container(
                                                            padding: EdgeInsets.only(
                                                                top: media
                                                                        .width *
                                                                    0.02,
                                                                bottom: media
                                                                        .width *
                                                                    0.02),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  height: media
                                                                          .width *
                                                                      0.06,
                                                                  width: media
                                                                          .width *
                                                                      0.06,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  decoration: BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      color: Colors
                                                                          .red
                                                                          .withOpacity(
                                                                              0.1)),
                                                                  child: MyText(
                                                                    text: (i +
                                                                            1)
                                                                        .toString(),
                                                                    // maxLines: 1,
                                                                    color: const Color(
                                                                        0xFFFF0000),
                                                                    fontweight:
                                                                        FontWeight
                                                                            .w600,
                                                                    size: media
                                                                            .width *
                                                                        twelve,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.05,
                                                                ),
                                                                Expanded(
                                                                  child: MyText(
                                                                    text: tripStops[
                                                                            i][
                                                                        'address'],
                                                                    // maxLines: 1,
                                                                    size: media
                                                                            .width *
                                                                        twelve,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : Container());
                                              })
                                              .values
                                              .toList(),
                                        )
                                      : Container(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height: media.width * 0.05,
                                        width: media.width * 0.05,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.red.withOpacity(0.1)),
                                        child: Icon(
                                          Icons.location_on_outlined,
                                          size: media.width * 0.03,
                                          color: const Color(0xFFFF0000),
                                        ),
                                      ),
                                      SizedBox(
                                        width: media.width * 0.05,
                                      ),
                                      Expanded(
                                        child: MyText(
                                          text: userRequestData['drop_address'],
                                          size: media.width * twelve,
                                          // maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: media.height * 0.03,
                                  ),
                                  userRequestData['is_bid_ride'] == 1
                                      ? Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              (userRequestData['payment_opt'] ==
                                                      '1')
                                                  ? languages[choosenLanguage]
                                                      ['text_cash']
                                                  : (userRequestData[
                                                              'payment_opt'] ==
                                                          '2')
                                                      ? languages[
                                                              choosenLanguage]
                                                          ['text_wallet']
                                                      : languages[
                                                              choosenLanguage]
                                                          ['text_card'],
                                              style: GoogleFonts.notoSans(
                                                  fontSize:
                                                      media.width * twentyeight,
                                                  color: buttonColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: media.width * 0.05,
                                            ),
                                            Text(
                                              userRequestData['requestBill']
                                                          ['data'][
                                                      'requested_currency_symbol'] +
                                                  ' ' +
                                                  userRequestData['requestBill']
                                                              ['data']
                                                          ['total_amount']
                                                      .toString(),
                                              style: GoogleFonts.notoSans(
                                                  fontSize:
                                                      media.width * twentysix,
                                                  color: textColor,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        )
                                      : (userRequestData['requestBill'] != null)
                                          ? Column(
                                              children: [
                                                MyText(
                                                  text:
                                                      languages[choosenLanguage]
                                                          ['text_tripfare'],
                                                  size: media.width * fourteen,
                                                  fontweight: FontWeight.w700,
                                                ),
                                                SizedBox(
                                                  height: media.height * 0.03,
                                                ),
                                                (userRequestData['is_rental'] ==
                                                        true)
                                                    ? Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                bottom: media
                                                                        .width *
                                                                    0.05),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_ride_type'],
                                                              style: GoogleFonts.notoSans(
                                                                  fontSize: media
                                                                          .width *
                                                                      fourteen,
                                                                  color:
                                                                      textColor),
                                                            ),
                                                            Text(
                                                              userRequestData[
                                                                  'rental_package_name'],
                                                              style: GoogleFonts.notoSans(
                                                                  fontSize: media
                                                                          .width *
                                                                      fourteen,
                                                                  color:
                                                                      textColor),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Container(),
                                                Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        MyText(
                                                          text: languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_baseprice'],
                                                          size: media.width *
                                                              twelve,
                                                        ),
                                                        MyText(
                                                          text: (userRequestData
                                                                      .isNotEmpty &&
                                                                  userRequestData[
                                                                          'requestBill'] !=
                                                                      null)
                                                              ? userRequestData[
                                                                              'requestBill']
                                                                          [
                                                                          'data']
                                                                      [
                                                                      'requested_currency_symbol'] +
                                                                  ' ' +
                                                                  userRequestData['requestBill']
                                                                              [
                                                                              'data']
                                                                          [
                                                                          'base_price']
                                                                      .toString()
                                                              : '',
                                                          size: media.width *
                                                              twelve,
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: media.width *
                                                              0.03,
                                                          bottom: media.width *
                                                              0.03),
                                                      height: 1.5,
                                                      color: const Color(
                                                          0xffE0E0E0),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        MyText(
                                                          text: languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_distprice'],
                                                          size: media.width *
                                                              twelve,
                                                        ),
                                                        MyText(
                                                          text: (userRequestData
                                                                      .isNotEmpty &&
                                                                  userRequestData[
                                                                          'requestBill'] !=
                                                                      null)
                                                              ? userRequestData[
                                                                              'requestBill']
                                                                          [
                                                                          'data']
                                                                      [
                                                                      'requested_currency_symbol'] +
                                                                  ' ' +
                                                                  userRequestData['requestBill']
                                                                              [
                                                                              'data']
                                                                          [
                                                                          'distance_price']
                                                                      .toString()
                                                              : '',
                                                          size: media.width *
                                                              twelve,
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: media.width *
                                                              0.03,
                                                          bottom: media.width *
                                                              0.03),
                                                      height: 1.5,
                                                      color: const Color(
                                                          0xffE0E0E0),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        MyText(
                                                          text: languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_timeprice'],
                                                          size: media.width *
                                                              twelve,
                                                        ),
                                                        MyText(
                                                          text: (userRequestData
                                                                      .isNotEmpty &&
                                                                  userRequestData[
                                                                          'requestBill'] !=
                                                                      null)
                                                              ? userRequestData[
                                                                              'requestBill']
                                                                          [
                                                                          'data']
                                                                      [
                                                                      'requested_currency_symbol'] +
                                                                  ' ' +
                                                                  userRequestData['requestBill']
                                                                              [
                                                                              'data']
                                                                          [
                                                                          'time_price']
                                                                      .toString()
                                                              : '',
                                                          size: media.width *
                                                              twelve,
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: media.width *
                                                              0.03,
                                                          bottom: media.width *
                                                              0.03),
                                                      height: 1.5,
                                                      color: const Color(
                                                          0xffE0E0E0),
                                                    ),
                                                  ],
                                                ),
                                                (userRequestData[
                                                                'requestBill'] !=
                                                            null &&
                                                        userRequestData['requestBill']
                                                                    ['data'][
                                                                'cancellation_fee'] !=
                                                            0)
                                                    ? Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              MyText(
                                                                text: languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_cancelfee'],
                                                                size: media
                                                                        .width *
                                                                    twelve,
                                                              ),
                                                              MyText(
                                                                text: (userRequestData
                                                                            .isNotEmpty &&
                                                                        userRequestData['requestBill'] !=
                                                                            null)
                                                                    ? userRequestData['requestBill']['data']
                                                                            [
                                                                            'requested_currency_symbol'] +
                                                                        ' ' +
                                                                        userRequestData['requestBill']['data']['cancellation_fee']
                                                                            .toString()
                                                                    : '',
                                                                size: media
                                                                        .width *
                                                                    twelve,
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            margin: EdgeInsets.only(
                                                                top: media
                                                                        .width *
                                                                    0.03,
                                                                bottom: media
                                                                        .width *
                                                                    0.03),
                                                            height: 1.5,
                                                            color: const Color(
                                                                0xffE0E0E0),
                                                          ),
                                                        ],
                                                      )
                                                    : Container(),
                                                (userRequestData[
                                                                'requestBill'] !=
                                                            null &&
                                                        userRequestData['requestBill']
                                                                    ['data'][
                                                                'airport_surge_fee'] !=
                                                            0)
                                                    ? Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              MyText(
                                                                text: languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_surge_fee'],
                                                                size: media
                                                                        .width *
                                                                    twelve,
                                                              ),
                                                              MyText(
                                                                text: (userRequestData
                                                                            .isNotEmpty &&
                                                                        userRequestData['requestBill'] !=
                                                                            null)
                                                                    ? userRequestData['requestBill']['data']
                                                                            [
                                                                            'requested_currency_symbol'] +
                                                                        ' ' +
                                                                        userRequestData['requestBill']['data']['airport_surge_fee']
                                                                            .toString()
                                                                    : '',
                                                                size: media
                                                                        .width *
                                                                    twelve,
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            margin: EdgeInsets.only(
                                                                top: media
                                                                        .width *
                                                                    0.03,
                                                                bottom: media
                                                                        .width *
                                                                    0.03),
                                                            height: 1.5,
                                                            color: const Color(
                                                                0xffE0E0E0),
                                                          ),
                                                        ],
                                                      )
                                                    : Container(),
                                                Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        MyText(
                                                          text: languages[
                                                                      choosenLanguage][
                                                                  'text_waiting_price'] +
                                                              ' (' +
                                                              userRequestData['requestBill']
                                                                      ['data'][
                                                                  'requested_currency_symbol'] +
                                                              ' ' +
                                                              userRequestData['requestBill']
                                                                          ['data']
                                                                      [
                                                                      'waiting_charge_per_min']
                                                                  .toString() +
                                                              ' x ' +
                                                              userRequestData['requestBill']
                                                                          ['data']
                                                                      [
                                                                      'calculated_waiting_time']
                                                                  .toString() +
                                                              ' ' +
                                                              languages[
                                                                      choosenLanguage]
                                                                  ['text_mins'] +
                                                              ')',
                                                          size: media.width *
                                                              twelve,
                                                        ),
                                                        MyText(
                                                          text: userRequestData[
                                                                          'requestBill']
                                                                      ['data'][
                                                                  'requested_currency_symbol'] +
                                                              ' ' +
                                                              userRequestData['requestBill']
                                                                          [
                                                                          'data']
                                                                      [
                                                                      'waiting_charge']
                                                                  .toString(),
                                                          size: media.width *
                                                              twelve,
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: media.width *
                                                              0.03,
                                                          bottom: media.width *
                                                              0.03),
                                                      height: 1.5,
                                                      color: const Color(
                                                          0xffE0E0E0),
                                                    ),
                                                  ],
                                                ),
                                                (userRequestData[
                                                                'requestBill'] !=
                                                            null &&
                                                        userRequestData['requestBill']
                                                                    ['data'][
                                                                'admin_commision'] !=
                                                            0)
                                                    ? Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              MyText(
                                                                text: languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_convfee'],
                                                                size: media
                                                                        .width *
                                                                    twelve,
                                                              ),
                                                              MyText(
                                                                text: userRequestData['requestBill']
                                                                            [
                                                                            'data']
                                                                        [
                                                                        'requested_currency_symbol'] +
                                                                    ' ' +
                                                                    userRequestData['requestBill']['data']
                                                                            [
                                                                            'admin_commision']
                                                                        .toString(),
                                                                size: media
                                                                        .width *
                                                                    twelve,
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            margin: EdgeInsets.only(
                                                                top: media
                                                                        .width *
                                                                    0.03,
                                                                bottom: media
                                                                        .width *
                                                                    0.03),
                                                            height: 1.5,
                                                            color: const Color(
                                                                0xffE0E0E0),
                                                          ),
                                                        ],
                                                      )
                                                    : Container(),
                                                (userRequestData[
                                                                'requestBill'] !=
                                                            null &&
                                                        userRequestData['requestBill']
                                                                    ['data'][
                                                                'promo_discount'] !=
                                                            null)
                                                    ? Column(
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              MyText(
                                                                text: languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_discount'],
                                                                size: media
                                                                        .width *
                                                                    twelve,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              MyText(
                                                                text: userRequestData['requestBill']
                                                                            [
                                                                            'data']
                                                                        [
                                                                        'requested_currency_symbol'] +
                                                                    ' ' +
                                                                    userRequestData['requestBill']['data']
                                                                            [
                                                                            'promo_discount']
                                                                        .toString(),
                                                                size: media
                                                                        .width *
                                                                    twelve,
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ],
                                                          ),
                                                          Container(
                                                            margin: EdgeInsets.only(
                                                                top: media
                                                                        .width *
                                                                    0.03,
                                                                bottom: media
                                                                        .width *
                                                                    0.03),
                                                            height: 1.5,
                                                            color: const Color(
                                                                0xffE0E0E0),
                                                          ),
                                                        ],
                                                      )
                                                    : Container(),
                                                Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        MyText(
                                                          text: languages[
                                                                  choosenLanguage]
                                                              ['text_taxes'],
                                                          size: media.width *
                                                              twelve,
                                                        ),
                                                        MyText(
                                                          text: userRequestData[
                                                                          'requestBill']
                                                                      ['data'][
                                                                  'requested_currency_symbol'] +
                                                              ' ' +
                                                              userRequestData['requestBill']
                                                                          [
                                                                          'data']
                                                                      [
                                                                      'service_tax']
                                                                  .toString(),
                                                          size: media.width *
                                                              twelve,
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: media.width *
                                                              0.03,
                                                          bottom: media.width *
                                                              0.03),
                                                      height: 1.5,
                                                      color: const Color(
                                                          0xffE0E0E0),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        MyText(
                                                          text: languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_totalfare'],
                                                          size: media.width *
                                                              twelve,
                                                        ),
                                                        MyText(
                                                          text: userRequestData[
                                                                          'requestBill']
                                                                      ['data'][
                                                                  'requested_currency_symbol'] +
                                                              ' ' +
                                                              userRequestData['requestBill']
                                                                          [
                                                                          'data']
                                                                      [
                                                                      'total_amount']
                                                                  .toString(),
                                                          size: media.width *
                                                              twelve,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          : Container()
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: media.width * 0.4,
                                child: Row(
                                  children: [
                                    Text(
                                      (userRequestData['payment_opt'] == '1')
                                          ? languages[choosenLanguage]
                                              ['text_cash']
                                          : (userRequestData['payment_opt'] ==
                                                  '2')
                                              ? languages[choosenLanguage]
                                                  ['text_wallet']
                                              : languages[choosenLanguage]
                                                  ['text_card'],
                                      style: GoogleFonts.notoSans(
                                          fontSize: media.width * sixteen,
                                          color: buttonColor,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    MyText(
                                      text:
                                          ' ${userRequestData['requestBill']['data']['requested_currency_symbol']}',
                                      size: media.width * fourteen,
                                    ),
                                    MyText(
                                      text:
                                          ' ${userRequestData['requestBill']['data']['total_amount']}',
                                      size: media.width * twenty,
                                      fontweight: FontWeight.bold,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: media.width * 0.02,
                              ),
                              Expanded(
                                  child: Button(
                                      onTap: () async {
                                        if (userRequestData['is_paid'] == 0 &&
                                            userRequestData['payment_opt'] !=
                                                '2') {
                                          setState(() {
                                            myPaymentMethod = userRequestData[
                                                        'payment_opt'] ==
                                                    '0'
                                                ? 'card'
                                                : userRequestData[
                                                            'payment_opt'] ==
                                                        '1'
                                                    ? 'cash'
                                                    : '';
                                            _choosePaymentMethod = true;
                                          });
                                        } else {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      const Review()));
                                        }
                                      },
                                      text: (userRequestData['is_paid'] == 0 &&
                                              userRequestData['payment_opt'] !=
                                                  '2')
                                          ? languages[choosenLanguage]
                                              ['text_choose_payment']
                                          : languages[choosenLanguage]
                                              ['text_confirm'])),
                            ],
                          ),
                          if (userRequestData['is_paid'] == 0 &&
                              userRequestData['payment_opt'] == '0')
                            Column(
                              children: [
                                SizedBox(
                                  height: media.width * 0.025,
                                ),
                                Button(
                                    onTap: () async {
                                      setState(() {
                                        _isLoading = true;
                                      });
                                      var val = await getWalletHistory();
                                      if (val == 'logout') {
                                        navigateLogout();
                                      }
                                      setState(() {
                                        _isLoading = false;
                                        _choosePayment = true;
                                      });
                                    },
                                    text: languages[choosenLanguage]
                                        ['text_pay'])
                              ],
                            ),
                        ],
                      ),
                    ),
                  //choose payment method
                  (_choosePayment == true)
                      ? Positioned(
                          child: Container(
                          height: media.height * 1,
                          width: media.width * 1,
                          color: Colors.transparent.withOpacity(0.6),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: media.width * 0.8,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          _choosePayment = false;
                                        });
                                      },
                                      child: Container(
                                        height: media.height * 0.05,
                                        width: media.height * 0.05,
                                        decoration: BoxDecoration(
                                          color: page,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(Icons.cancel,
                                            color: buttonColor),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: media.width * 0.025),
                              Container(
                                padding: EdgeInsets.all(media.width * 0.05),
                                width: media.width * 0.8,
                                height: media.height * 0.6,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: page),
                                child: Column(
                                  children: [
                                    SizedBox(
                                        width: media.width * 0.7,
                                        child: Text(
                                          languages[choosenLanguage]
                                              ['text_choose_payment'],
                                          style: GoogleFonts.notoSans(
                                              fontSize: media.width * eighteen,
                                              fontWeight: FontWeight.w600),
                                        )),
                                    SizedBox(
                                      height: media.width * 0.05,
                                    ),
                                    Expanded(
                                      child: SingleChildScrollView(
                                        physics: const BouncingScrollPhysics(),
                                        child: Column(
                                          children: paymentGateways
                                              .map((i, value) {
                                                return MapEntry(
                                                    i,
                                                    (paymentGateways[i]
                                                                ['enabled'] ==
                                                            true)
                                                        ? InkWell(
                                                            onTap: () async {
                                                              addMoney = double.parse(
                                                                  userRequestData['requestBill']
                                                                              [
                                                                              'data']
                                                                          [
                                                                          'total_amount']
                                                                      .toStringAsFixed(
                                                                          2));
                                                              var val = await Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => PaymentGatwaysPage(
                                                                          from:
                                                                              '1',
                                                                          url: paymentGateways[i]
                                                                              [
                                                                              'url'])));

                                                              if (val != null) {
                                                                if (val) {
                                                                  setState(() {
                                                                    _isLoading =
                                                                        true;
                                                                    _choosePayment =
                                                                        false;
                                                                  });
                                                                  ismulitipleride =
                                                                      true;
                                                                  var val = await getUserDetails(
                                                                      id: userRequestData[
                                                                          'id']);
                                                                  if (val ==
                                                                      'logout') {
                                                                    navigateLogout();
                                                                  }
                                                                  setState(() {
                                                                    _isLoading =
                                                                        false;
                                                                  });
                                                                }
                                                              }
                                                            },
                                                            child: Container(
                                                              height:
                                                                  media.width *
                                                                      0.15,
                                                              width:
                                                                  media.width *
                                                                      0.6,
                                                              margin: EdgeInsets.only(
                                                                  bottom: media
                                                                          .width *
                                                                      0.02),
                                                              decoration: BoxDecoration(
                                                                  image: DecorationImage(
                                                                      image: NetworkImage(
                                                                          paymentGateways[i]
                                                                              [
                                                                              'image']))),
                                                            ),
                                                          )
                                                        : Container());
                                              })
                                              .values
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ))
                      : Container(),

                  //choose payment method
                  (_choosePaymentMethod == true)
                      ? Positioned(
                          top: 0,
                          child: Container(
                              height: media.height * 1,
                              width: media.width * 1,
                              color: Colors.transparent.withOpacity(0.6),
                              child: SizedBox(
                                  height: media.height * 1,
                                  width: media.width * 1,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: media.width * 0.9,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    _choosePaymentMethod =
                                                        false;
                                                  });
                                                },
                                                child: Container(
                                                  height: media.width * 0.1,
                                                  width: media.width * 0.1,
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: borderLines
                                                              .withOpacity(
                                                                  0.5)),
                                                      shape: BoxShape.circle,
                                                      color: page),
                                                  child: Icon(
                                                    Icons.cancel_outlined,
                                                    color: textColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: media.width * 0.05,
                                        ),
                                        Container(
                                            width: media.width * 0.9,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: borderLines
                                                      .withOpacity(0.5)),
                                              color: page,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            padding: EdgeInsets.all(
                                                media.width * 0.05),
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    languages[choosenLanguage]
                                                        ['text_paymentmethod'],
                                                    style: GoogleFonts.notoSans(
                                                        fontSize: media.width *
                                                            twenty,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        color: textColor),
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        media.height * 0.015,
                                                  ),
                                                  Column(
                                                    children:
                                                        userRequestData[
                                                                'payment_type']
                                                            .toString()
                                                            .split(',')
                                                            .toList()
                                                            .asMap()
                                                            .map((i, value) {
                                                              return MapEntry(
                                                                  i,
                                                                  (userRequestData['payment_type']
                                                                              .toString()
                                                                              .split(',')
                                                                              .toList()[i] !=
                                                                          'wallet')
                                                                      ? InkWell(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              payingVia = i;
                                                                              myPaymentMethod = userRequestData['payment_type'].toString().split(',').toList()[i].toString();
                                                                            });
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                EdgeInsets.all(media.width * 0.02),
                                                                            width:
                                                                                media.width * 0.9,
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    SizedBox(
                                                                                      width: media.width * 0.06,
                                                                                      child: (userRequestData['payment_type'].toString().split(',').toList()[i] == 'cash')
                                                                                          ? Image.asset(
                                                                                              'assets/images/cash.png',
                                                                                              fit: BoxFit.contain,
                                                                                            )
                                                                                          : (userRequestData['payment_type'].toString().split(',').toList()[i] == 'wallet')
                                                                                              ? Image.asset(
                                                                                                  'assets/images/wallet.png',
                                                                                                  fit: BoxFit.contain,
                                                                                                )
                                                                                              : (userRequestData['payment_type'].toString().split(',').toList()[i] == 'card')
                                                                                                  ? Image.asset(
                                                                                                      'assets/images/card.png',
                                                                                                      fit: BoxFit.contain,
                                                                                                    )
                                                                                                  : (userRequestData['payment_type'].toString().split(',').toList()[i] == 'upi')
                                                                                                      ? Image.asset(
                                                                                                          'assets/images/upi.png',
                                                                                                          fit: BoxFit.contain,
                                                                                                        )
                                                                                                      : Container(),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: media.width * 0.05,
                                                                                    ),
                                                                                    Column(
                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                      children: [
                                                                                        Text(
                                                                                          userRequestData['payment_type'].toString().split(',').toList()[i].toString(),
                                                                                          style: GoogleFonts.notoSans(fontSize: media.width * fourteen, fontWeight: FontWeight.w600, color: textColor),
                                                                                        ),
                                                                                        Text(
                                                                                          (userRequestData['payment_type'].toString().split(',').toList()[i] == 'cash')
                                                                                              ? languages[choosenLanguage]['text_paycash']
                                                                                              : (userRequestData['payment_type'].toString().split(',').toList()[i] == 'wallet')
                                                                                                  ? languages[choosenLanguage]['text_paywallet']
                                                                                                  : (userRequestData['payment_type'].toString().split(',').toList()[i] == 'card')
                                                                                                      ? languages[choosenLanguage]['text_paycard']
                                                                                                      : (userRequestData['payment_type'].toString().split(',').toList()[i] == 'upi')
                                                                                                          ? languages[choosenLanguage]['text_payupi']
                                                                                                          : '',
                                                                                          style: GoogleFonts.notoSans(fontSize: media.width * ten, color: textColor),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                    Expanded(
                                                                                        child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: [
                                                                                        Container(
                                                                                          height: media.width * 0.05,
                                                                                          width: media.width * 0.05,
                                                                                          decoration: BoxDecoration(shape: BoxShape.circle, color: page, border: Border.all(color: textColor, width: 1.2)),
                                                                                          alignment: Alignment.center,
                                                                                          child: (myPaymentMethod == userRequestData['payment_type'].toString().split(',').toList()[i].toString()) ? Container(height: media.width * 0.03, width: media.width * 0.03, decoration: BoxDecoration(color: textColor, shape: BoxShape.circle)) : Container(),
                                                                                        )
                                                                                      ],
                                                                                    ))
                                                                                  ],
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Container());
                                                            })
                                                            .values
                                                            .toList(),
                                                  ),
                                                  SizedBox(
                                                    height: media.height * 0.02,
                                                  ),
                                                  if (_error != '')
                                                    Container(
                                                      alignment:
                                                          Alignment.center,
                                                      padding: EdgeInsets.only(
                                                          bottom: media.height *
                                                              0.02),
                                                      child: Text(
                                                        _error,
                                                        style: GoogleFonts
                                                            .notoSans(
                                                                fontSize: media
                                                                        .width *
                                                                    fourteen,
                                                                color:
                                                                    Colors.red),
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  Button(
                                                      onTap: () async {
                                                        if ((myPaymentMethod ==
                                                                    'cash' &&
                                                                userRequestData[
                                                                        'payment_opt'] !=
                                                                    '1') ||
                                                            (myPaymentMethod ==
                                                                    'card' &&
                                                                userRequestData[
                                                                        'payment_opt'] !=
                                                                    '0')) {
                                                          if (myPaymentMethod !=
                                                              '') {
                                                            setState(() {
                                                              _isLoading = true;
                                                              _error = '';
                                                            });
                                                            var val =
                                                                await paymentMethod(
                                                                    myPaymentMethod);
                                                            if (val ==
                                                                'logout') {
                                                              navigateLogout();
                                                            } else if (val ==
                                                                'success') {
                                                              if (myPaymentMethod ==
                                                                  'card') {
                                                                if (walletBalance
                                                                    .isEmpty) {
                                                                  var val =
                                                                      await getWalletHistory();
                                                                  if (val ==
                                                                      'logout') {
                                                                    navigateLogout();
                                                                  }
                                                                }
                                                                setState(() {
                                                                  _isLoading =
                                                                      false;
                                                                  _choosePayment =
                                                                      true;
                                                                  _choosePaymentMethod =
                                                                      false;
                                                                });
                                                              } else {
                                                                _choosePaymentMethod =
                                                                    false;
                                                              }
                                                            } else {
                                                              _error = val
                                                                  .toString();
                                                            }

                                                            setState(() {
                                                              myPaymentMethod =
                                                                  '';
                                                              _isLoading =
                                                                  false;
                                                            });
                                                          }
                                                        } else {
                                                          setState(() {
                                                            _choosePaymentMethod =
                                                                false;
                                                          });
                                                        }
                                                      },
                                                      text: languages[
                                                              choosenLanguage]
                                                          ['text_confirm']),
                                                ]))
                                      ]))))
                      : Container(),

                  if (_isLoading == true) const Positioned(child: Loading())
                ],
              );
            }),
      ),
    );
  }
}
