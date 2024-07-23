import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_user/functions/functions.dart';
import 'package:flutter_user/pages/onTripPage/booking_confirmation.dart';
import 'package:flutter_user/pages/onTripPage/choosegoods.dart';
import 'package:flutter_user/pages/onTripPage/map_page.dart';
import 'package:flutter_user/styles/styles.dart';
import 'package:flutter_user/translations/translation.dart';
import 'package:flutter_user/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ApplyCouponsContainer extends StatefulWidget {
  final dynamic type;
  const ApplyCouponsContainer({super.key, this.type});

  @override
  State<ApplyCouponsContainer> createState() => _ApplyCouponsContainerState();
}

class _ApplyCouponsContainerState extends State<ApplyCouponsContainer> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Container(
      padding: MediaQuery.of(context).viewInsets,
      decoration: BoxDecoration(
          color: page,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(media.width * 0.05),
              topRight: Radius.circular(media.width * 0.05))),
      // padding:
      //     EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: Container(
        padding: EdgeInsets.all(media.width * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: MyText(
                textAlign: TextAlign.center,
                text: (languages[choosenLanguage]['text_apply'] +
                    ' ' +
                    languages[choosenLanguage]['text_coupons']),
                size: media.width * sixteen,
                fontweight: FontWeight.w600,
                color: textColor,
              ),
            ),
            SizedBox(
              height: media.width * 0.06,
            ),
            Container(
              width: media.width * 0.8,
              height: media.width * 0.12,
              padding: EdgeInsets.fromLTRB(media.width * 0.025,
                  media.width * 0.01, media.width * 0.025, media.width * 0.01),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                  border: Border.all(color: textColor.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(media.width * 0.02)),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: promoKey,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: languages[choosenLanguage]['text_enterpromo'],
                        hintStyle: GoogleFonts.notoSans(
                            color: hintColor, fontSize: media.width * fourteen),
                      ),
                      style: GoogleFonts.notoSans(color: textColor),
                      onChanged: (val) {
                        setState(() {
                          promoCode = val;
                          couponerror = false;
                        });
                      },
                    ),
                  ),
                  (promoStatus == 1)
                      ? MyText(
                          text: languages[choosenLanguage]
                              ['text_promoaccepted'],
                          size: media.width * twelve,
                          color: online,
                        )
                      : Container(),
                ],
              ),
            ),
            SizedBox(
              height: media.width * 0.04,
            ),
            SizedBox(
              // width: media.width * 0.8,
              // height: media.width * 0.1,
              child: Button(
                text: (promoStatus == 1)
                    ? languages[choosenLanguage]['text_remove']
                    : languages[choosenLanguage]['text_apply'],
                fontweight: FontWeight.w500,
                onTap: () async {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    isLoading = true;
                  });

                  // promoStatus = null;)
                  if (promoStatus != 1 && promoCode != '') {
                    setState(() {
                      promoStatus = null;
                    });
                    if (widget.type != 1 && promoCode != '') {
                      await etaRequestWithPromo();
                    } else if (widget.type == 1 && promoCode != '') {
                      await rentalRequestWithPromo();
                    }
                  } else {
                    if (promoKey.text != '') {
                      if (promoStatus != 2) {
                        if (widget.type != 1) {
                          await etaRequest();
                        } else if (widget.type == 1) {
                          await rentalEta();
                        }
                        promoKey.text = '';
                        promoCode = '';
                      }
                      if (promoStatus == 1) {
                        // promoKey.text = '';
                        promoStatus = null;
                        // if (widget.type != 1) {
                        //   await etaRequest();
                        // } else if (widget.type == 1) {
                        //   await rentalEta();
                        // }
                      }
                    }
                  }
                  setState(() {
                    isLoading = false;
                  });
                },
                color: (promoKey.text == '')
                    ? Colors.grey
                    : (isDarkTheme)
                        ? Colors.white
                        : Colors.black,
                textcolor: (!isDarkTheme) ? Colors.white : Colors.black,
                borderRadius: 12.0,
              ),
            ),
            if (promoStatus != null && promoStatus == 2 && couponerror == true)
              Container(
                width: media.width * 0.9,
                padding: EdgeInsets.only(top: media.width * 0.025),
                child: MyText(
                  text: languages[choosenLanguage]['text_promorejected'],
                  size: media.width * twelve,
                  color: Colors.red,
                ),
              ),
            (choosenVehicle != null)
                ? SizedBox(
                    height: media.width * 0.025,
                  )
                : Container(),
            SizedBox(
              height: media.width * 0.04,
            ),
            InkWell(
                onTap: () {
                  if (widget.type == 1
                      ? (rentalOption[choosenVehicle]['has_discount'] == true)
                      : etaDetails[choosenVehicle]['has_discount'] == true) {
                    setState(() {
                      promoStatus = 1;
                      addCoupon = false;
                      // promoKey.clear();
                    });
                  } else {
                    setState(() {
                      promoStatus = null;
                      addCoupon = false;
                      promoKey.clear();
                    });
                  }
                  Navigator.pop(context);
                },
                child: Container(
                  alignment: Alignment.center,
                  // width: media.width * 0.8,
                  child: MyText(
                    text: languages[choosenLanguage]['text_cancel'],
                    size: media.width * sixteen,
                    color: verifyDeclined,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class CreateRequestBottomSheet extends StatefulWidget {
  final dynamic type;
  final dynamic showInfoInt;
  final dynamic fromDate;
  final dynamic toDate;
  final dynamic isOneWayTrip;
  final dynamic geo;
  final dynamic amount;
  const CreateRequestBottomSheet(
      {super.key,
      this.type,
      this.showInfoInt,
      this.fromDate,
      this.toDate,
      this.isOneWayTrip,
      this.geo,
      this.amount});

  @override
  State<CreateRequestBottomSheet> createState() =>
      _CreateRequestBottomSheetState();
}

bool rideLaterSuccess = false;

class _CreateRequestBottomSheetState extends State<CreateRequestBottomSheet> {
  TextEditingController yourAmount = TextEditingController();
  String fareError = '';
  bool iscondition = false;

  @override
  void initState() {
    yourAmount.text = widget.amount;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Container(
      padding: MediaQuery.of(context).viewInsets,
      width: media.width * 1,
      decoration: BoxDecoration(
          color: page,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(media.width * 0.05),
              topRight: Radius.circular(media.width * 0.05))),
      child: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: media.width * 0.05),
            Container(
              width: media.width * 0.95,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12), color: page),
              padding: EdgeInsets.all(media.width * 0.05),
              child: (widget.type != 1)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          etaDetails[widget.showInfoInt]['name'],
                          style: GoogleFonts.notoSans(
                              fontSize: media.width * sixteen,
                              color: textColor,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: media.width * 0.025,
                        ),
                        Text(
                          etaDetails[widget.showInfoInt]['description'],
                          style: GoogleFonts.notoSans(
                            fontSize: media.width * fourteen,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: media.width * 0.05),
                        Text(
                          languages[choosenLanguage]['text_supported_vehicles'],
                          style: GoogleFonts.notoSans(
                              fontSize: media.width * sixteen,
                              color: textColor,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: media.width * 0.025,
                        ),
                        Text(
                          etaDetails[widget.showInfoInt]['supported_vehicles'],
                          style: GoogleFonts.notoSans(
                            fontSize: media.width * fourteen,
                            color: textColor,
                          ),
                        ),
                        (isOutStation && widget.isOneWayTrip == false)
                            ? Container()
                            : SizedBox(height: media.width * 0.05),
                        (isOutStation && widget.isOneWayTrip == false)
                            ? Container()
                            : Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: media.width * 0.4,
                                    child: Text(
                                      languages[choosenLanguage]
                                          ['text_recommended_fare'],
                                      style: GoogleFonts.notoSans(
                                          fontSize: media.width * sixteen,
                                          color: textColor,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  (etaDetails[widget.showInfoInt]
                                                  ['has_discount'] !=
                                              true ||
                                          etaDetails[widget.showInfoInt]
                                                  ['enable_bidding'] ==
                                              true ||
                                          isOutStation)
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${etaDetails[widget.showInfoInt]['total'].toStringAsFixed(2)} ${etaDetails[widget.showInfoInt]['currency']}'
                                              // etaDetails[_showInfoInt]['currency'] + ' ' + etaDetails[_showInfoInt]['total'].toStringAsFixed(2),
                                              ,
                                              style: GoogleFonts.notoSans(
                                                  fontSize:
                                                      media.width * fourteen,
                                                  color: textColor,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              etaDetails[widget.showInfoInt]
                                                      ['currency'] +
                                                  ' ',
                                              style: GoogleFonts.notoSans(
                                                  fontSize:
                                                      media.width * fourteen,
                                                  color: textColor,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Text(
                                              etaDetails[widget.showInfoInt]
                                                      ['total']
                                                  .toStringAsFixed(2),
                                              style: GoogleFonts.notoSans(
                                                  fontSize:
                                                      media.width * fourteen,
                                                  color: textColor,
                                                  fontWeight: FontWeight.w600,
                                                  decoration: TextDecoration
                                                      .lineThrough),
                                            ),
                                            Text(
                                              ' ${etaDetails[widget.showInfoInt]['discounted_totel'].toStringAsFixed(2)}',
                                              style: GoogleFonts.notoSans(
                                                  fontSize:
                                                      media.width * fourteen,
                                                  color: textColor,
                                                  fontWeight: FontWeight.w600),
                                            )
                                          ],
                                        )
                                ],
                              ),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        MyText(
                            text: languages[choosenLanguage]
                                ['text_offer_your_fare'],
                            size: media.width * fourteen,
                            color: textColor,
                            fontweight: FontWeight.w600),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () {
                                if (yourAmount.text.isNotEmpty &&
                                    (etaDetails[choosenVehicle]
                                                ['bidding_low_percentage'] ==
                                            0 ||
                                        (double.parse(yourAmount.text.toString()) -
                                                ((userDetails['bidding_amount_increase_or_decrease']
                                                        .toString()
                                                        .contains('.'))
                                                    ? double.parse(
                                                        userDetails['bidding_amount_increase_or_decrease']
                                                            .toString())
                                                    : int.parse(
                                                        userDetails['bidding_amount_increase_or_decrease']
                                                            .toString()))) >=
                                            (double.parse(etaDetails[choosenVehicle]['total'].toString()) -
                                                ((double.parse(etaDetails[choosenVehicle]['bidding_low_percentage'].toString()) /
                                                        100) *
                                                    double.parse(etaDetails[choosenVehicle]['total'].toString()))))) {
                                  setState(() {
                                    yourAmount.text = (yourAmount.text.isEmpty)
                                        ? (etaDetails[choosenVehicle]['total']
                                                .toString()
                                                .contains('.'))
                                            ? (double.parse(etaDetails[choosenVehicle]['total'].toString()) -
                                                    ((userDetails['bidding_amount_increase_or_decrease']
                                                            .toString()
                                                            .contains('.'))
                                                        ? double.parse(
                                                            userDetails['bidding_amount_increase_or_decrease']
                                                                .toString())
                                                        : int.parse(userDetails['bidding_amount_increase_or_decrease']
                                                            .toString())))
                                                .toStringAsFixed(2)
                                            : (int.parse(etaDetails[choosenVehicle]['total'].toString()) -
                                                    ((userDetails['bidding_amount_increase_or_decrease']
                                                            .toString()
                                                            .contains('.'))
                                                        ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString())
                                                        : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString())))
                                                .toString()
                                        : (yourAmount.text.toString().contains('.'))
                                            ? (double.parse(yourAmount.text.toString()) - ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))).toStringAsFixed(2)
                                            : (int.parse(yourAmount.text.toString()) - ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))).toString();
                                    // updateAmount.text = (updateAmount.text.isEmpty) ? (double.parse(rideList['price'].toString()) - 10).toStringAsFixed(2) : (double.parse(updateAmount.text.toString()) - 10).toStringAsFixed(2);
                                  });
                                }
                              },
                              child: Container(
                                width: media.width * 0.2,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: (yourAmount.text.isNotEmpty &&
                                            (etaDetails[choosenVehicle]['bidding_low_percentage'] == 0 ||
                                                (double.parse(yourAmount.text.toString()) -
                                                        ((userDetails['bidding_amount_increase_or_decrease']
                                                                .toString()
                                                                .contains('.'))
                                                            ? double.parse(
                                                                userDetails['bidding_amount_increase_or_decrease']
                                                                    .toString())
                                                            : int.parse(userDetails['bidding_amount_increase_or_decrease']
                                                                .toString()))) >=
                                                    (double.parse(etaDetails[choosenVehicle]['total'].toString()) -
                                                        ((double.parse(etaDetails[choosenVehicle]['bidding_low_percentage'].toString()) /
                                                                100) *
                                                            double.parse(etaDetails[choosenVehicle]['total'].toString())))))
                                        // double.parse(updateAmount.text.toString()) > double.parse(rideList['price'].toString()))
                                        ? (isDarkTheme)
                                            ? Colors.white
                                            : Colors.black
                                        : borderLines,
                                    borderRadius: BorderRadius.circular(media.width * 0.04)),
                                padding: EdgeInsets.all(media.width * 0.025),
                                child: Text(
                                  // '-10',
                                  (userDetails[
                                              'bidding_amount_increase_or_decrease']
                                          .toString()
                                          .contains('.'))
                                      ? '-${double.parse(userDetails['bidding_amount_increase_or_decrease'].toString())}'
                                      : '-${int.parse(userDetails['bidding_amount_increase_or_decrease'].toString())}',
                                  style: GoogleFonts.notoSans(
                                      fontSize: media.width * fourteen,
                                      fontWeight: FontWeight.w600,
                                      color: (isDarkTheme)
                                          ? Colors.black
                                          : Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: media.width * 0.4,
                              child: TextField(
                                enabled: false,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                controller: yourAmount,
                                decoration: InputDecoration(
                                  hintText: etaDetails[choosenVehicle]['price']
                                      .toString(),
                                  hintStyle: GoogleFonts.notoSans(
                                      fontSize: media.width * sixteen,
                                      color: textColor),
                                  border: UnderlineInputBorder(
                                      borderSide: BorderSide(color: hintColor)),
                                ),
                                style: GoogleFonts.notoSans(
                                  color: textColor,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (etaDetails[choosenVehicle]
                                              ['bidding_high_percentage'] ==
                                          0 ||
                                      (double.parse(yourAmount.text.toString()) +
                                              ((userDetails['bidding_amount_increase_or_decrease']
                                                      .toString()
                                                      .contains('.'))
                                                  ? double.parse(
                                                      userDetails['bidding_amount_increase_or_decrease']
                                                          .toString())
                                                  : int.parse(
                                                      userDetails['bidding_amount_increase_or_decrease']
                                                          .toString()))) <=
                                          (double.parse(etaDetails[choosenVehicle]['total'].toString()) +
                                              ((double.parse(etaDetails[choosenVehicle]['bidding_high_percentage'].toString()) / 100) *
                                                  double.parse(
                                                      etaDetails[choosenVehicle]['total'].toString())))) {
                                    yourAmount.text = (yourAmount.text.isEmpty)
                                        ? (etaDetails[choosenVehicle]['price']
                                                .toString()
                                                .contains('.'))
                                            ? (double.parse(etaDetails[choosenVehicle]['price'].toString()) +
                                                    ((userDetails['bidding_amount_increase_or_decrease']
                                                            .toString()
                                                            .contains('.'))
                                                        ? double.parse(
                                                            userDetails['bidding_amount_increase_or_decrease']
                                                                .toString())
                                                        : int.parse(userDetails['bidding_amount_increase_or_decrease']
                                                            .toString())))
                                                .toStringAsFixed(2)
                                            : (int.parse(etaDetails[choosenVehicle]['price'].toString()) +
                                                    ((userDetails['bidding_amount_increase_or_decrease']
                                                            .toString()
                                                            .contains('.'))
                                                        ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString())
                                                        : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString())))
                                                .toString()
                                        : (yourAmount.text.toString().contains('.'))
                                            ? (double.parse(yourAmount.text.toString()) + ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))).toStringAsFixed(2)
                                            : (int.parse(yourAmount.text.toString()) + ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))).toString();
                                  }
                                });
                              },
                              child: Container(
                                width: media.width * 0.2,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: (etaDetails[choosenVehicle]['bidding_high_percentage'] == 0 ||
                                            (double.parse(yourAmount.text.toString()) +
                                                    ((userDetails['bidding_amount_increase_or_decrease']
                                                            .toString()
                                                            .contains('.'))
                                                        ? double.parse(
                                                            userDetails['bidding_amount_increase_or_decrease']
                                                                .toString())
                                                        : int.parse(
                                                            userDetails['bidding_amount_increase_or_decrease']
                                                                .toString()))) <=
                                                (double.parse(etaDetails[choosenVehicle]['total'].toString()) +
                                                    ((double.parse(etaDetails[choosenVehicle]['bidding_high_percentage'].toString()) /
                                                            100) *
                                                        double.parse(etaDetails[choosenVehicle]['total'].toString()))))
                                        ? (isDarkTheme)
                                            ? Colors.white
                                            : Colors.black
                                        : borderLines,
                                    borderRadius: BorderRadius.circular(media.width * 0.04)),
                                padding: EdgeInsets.all(media.width * 0.025),
                                child: Text(
                                  // '+10',
                                  (userDetails[
                                              'bidding_amount_increase_or_decrease']
                                          .toString()
                                          .contains('.'))
                                      ? '+${double.parse(userDetails['bidding_amount_increase_or_decrease'].toString())}'
                                      : '+${int.parse(userDetails['bidding_amount_increase_or_decrease'].toString())}',
                                  style: GoogleFonts.notoSans(
                                      fontSize: media.width * fourteen,
                                      fontWeight: FontWeight.w600,
                                      color: (isDarkTheme)
                                          ? Colors.black
                                          : Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        (fareError != '')
                            ? MyText(
                                text: fareError,
                                size: media.width * fourteen,
                                color: verifyDeclined,
                                textAlign: TextAlign.center,
                              )
                            : Container(),
                        SizedBox(
                          height: media.width * 0.02,
                        ),
                        (isLoading)
                            ? Container(
                                height: media.width * 0.12,
                                width: media.width * 0.9,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(
                                        media.width * 0.02)),
                                child: SizedBox(
                                  height: media.width * 0.06,
                                  width: media.width * 0.07,
                                  child: const CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                ),
                              )
                            : Button(
                                onTap: () async {
                                  if (yourAmount.text.isNotEmpty) {
                                    var g = widget.geo.encode(
                                        addressList
                                            .firstWhere((element) =>
                                                element.type == 'pickup')
                                            .latlng
                                            .longitude,
                                        addressList
                                            .firstWhere((element) =>
                                                element.type == 'pickup')
                                            .latlng
                                            .latitude);
                                    dynamic result;
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    if ((yourAmount.text.isNotEmpty &&
                                            double.parse(yourAmount.text) >=
                                                double.parse(etaDetails[widget
                                                        .showInfoInt]['total']
                                                    .toString())) ||
                                        widget.isOneWayTrip) {
                                      if (!iscondition) {
                                        setState(() {
                                          isLoading = true;
                                        });

                                        if (choosenVehicle != null) {
                                          if (isOutStation && !iscondition) {
                                            iscondition = true;
                                            if (choosenTransportType == 0) {
                                              result = await createRequestLater(
                                                  jsonEncode({
                                                    'pick_lat': addressList
                                                        .firstWhere((e) =>
                                                            e.type == 'pickup')
                                                        .latlng
                                                        .latitude,
                                                    'poly_line': polyString,
                                                    'pick_lng': addressList
                                                        .firstWhere((e) =>
                                                            e.type == 'pickup')
                                                        .latlng
                                                        .longitude,
                                                    'drop_lat': addressList
                                                        .lastWhere((e) =>
                                                            e.type == 'drop')
                                                        .latlng
                                                        .latitude,
                                                    'drop_lng': addressList
                                                        .lastWhere((e) =>
                                                            e.type == 'drop')
                                                        .latlng
                                                        .longitude,
                                                    'vehicle_type': etaDetails[
                                                            choosenVehicle]
                                                        ['zone_type_id'],
                                                    'ride_type': 1,
                                                    'is_pet_available':
                                                        (addPetPreferences ==
                                                                false)
                                                            ? false
                                                            : true,
                                                    'is_luggage_available':
                                                        (addLuggagePreferences ==
                                                                false)
                                                            ? false
                                                            : true,
                                                    'payment_opt': (etaDetails[
                                                                            choosenVehicle]
                                                                        [
                                                                        'payment_type']
                                                                    .toString()
                                                                    .split(',')
                                                                    .toList()[
                                                                payingVia] ==
                                                            'card')
                                                        ? 0
                                                        : (etaDetails[choosenVehicle]
                                                                        [
                                                                        'payment_type']
                                                                    .toString()
                                                                    .split(',')
                                                                    .toList()[payingVia] ==
                                                                'cash')
                                                            ? 1
                                                            : 2,
                                                    'pick_address': addressList
                                                        .firstWhere((e) =>
                                                            e.type == 'pickup')
                                                        .address,
                                                    'drop_address': addressList
                                                        .lastWhere((e) =>
                                                            e.type == 'drop')
                                                        .address,
                                                    'request_eta_amount':
                                                        etaDetails[
                                                                choosenVehicle]
                                                            ['total'],
                                                    'offerred_ride_fare':
                                                        yourAmount.text,
                                                    'is_bid_ride': 1,
                                                    'trip_start_time': widget
                                                        .fromDate
                                                        .toString()
                                                        .substring(0, 19),
                                                    if (widget.toDate != null)
                                                      'is_round_trip': true,
                                                    if (widget.toDate != null)
                                                      'return_time': widget
                                                          .toDate
                                                          .toString()
                                                          .substring(0, 19),
                                                    'is_later': true,
                                                    'is_out_station': true,
                                                    if (dropStopList.isNotEmpty)
                                                      'stops': jsonEncode(
                                                          dropStopList),
                                                  }),
                                                  'api/v1/request/create');
                                            } else {
                                              iscondition = true;
                                              result = await createRequestLater(
                                                  jsonEncode({
                                                    'pick_lat': addressList[0]
                                                        .latlng
                                                        .latitude,
                                                    'pick_lng': addressList[0]
                                                        .latlng
                                                        .longitude,
                                                    'drop_lat': addressList[
                                                            addressList.length -
                                                                1]
                                                        .latlng
                                                        .latitude,
                                                    'poly_line': polyString,
                                                    'drop_lng': addressList[
                                                            addressList.length -
                                                                1]
                                                        .latlng
                                                        .longitude,
                                                    'vehicle_type': etaDetails[
                                                            choosenVehicle]
                                                        ['zone_type_id'],
                                                    'ride_type': 1,
                                                    'is_pet_available':
                                                        (addPetPreferences ==
                                                                false)
                                                            ? false
                                                            : true,
                                                    'is_luggage_available':
                                                        (addLuggagePreferences ==
                                                                false)
                                                            ? false
                                                            : true,
                                                    'payment_opt': (etaDetails[
                                                                            choosenVehicle]
                                                                        [
                                                                        'payment_type']
                                                                    .toString()
                                                                    .split(',')
                                                                    .toList()[
                                                                payingVia] ==
                                                            'card')
                                                        ? 0
                                                        : (etaDetails[choosenVehicle]
                                                                        [
                                                                        'payment_type']
                                                                    .toString()
                                                                    .split(',')
                                                                    .toList()[payingVia] ==
                                                                'cash')
                                                            ? 1
                                                            : 2,
                                                    'pick_address':
                                                        addressList[0].address,
                                                    'drop_address': addressList[
                                                            addressList.length -
                                                                1]
                                                        .address,
                                                    'request_eta_amount':
                                                        etaDetails[
                                                                choosenVehicle]
                                                            ['total'],
                                                    'pickup_poc_name':
                                                        addressList[0].name,
                                                    'pickup_poc_mobile':
                                                        addressList[0].number,
                                                    'pickup_poc_instruction':
                                                        addressList[0]
                                                            .instructions,
                                                    'drop_poc_name':
                                                        addressList[addressList
                                                                    .length -
                                                                1]
                                                            .name,
                                                    'drop_poc_mobile':
                                                        addressList[addressList
                                                                    .length -
                                                                1]
                                                            .number,
                                                    'drop_poc_instruction':
                                                        addressList[addressList
                                                                    .length -
                                                                1]
                                                            .instructions,
                                                    'goods_type_id':
                                                        selectedGoodsId
                                                            .toString(),
                                                    'goods_type_quantity':
                                                        goodsSize,
                                                    'offerred_ride_fare':
                                                        yourAmount.text,
                                                    'is_bid_ride': 1,
                                                    'trip_start_time': widget
                                                        .fromDate
                                                        .toString()
                                                        .substring(0, 19),
                                                    if (widget.toDate != null)
                                                      'is_round_trip': true,
                                                    if (widget.toDate != null)
                                                      'return_time': widget
                                                          .toDate
                                                          .toString()
                                                          .substring(0, 19),
                                                    'is_later': true,
                                                    'is_out_station': true,
                                                    if (dropStopList.isNotEmpty)
                                                      'stops': jsonEncode(
                                                          dropStopList),
                                                  }),
                                                  (userDetails['is_delivery_app'] !=
                                                              null &&
                                                          userDetails[
                                                                  'is_delivery_app'] ==
                                                              true)
                                                      ? 'api/v1/request/create'
                                                      : 'api/v1/request/delivery/create');
                                            }
                                          } else {
                                            iscondition = true;

                                            if (widget.type != 1) {
                                              if (etaDetails[choosenVehicle]
                                                      ['has_discount'] ==
                                                  false) {
                                                if (choosenTransportType == 0) {
                                                  result = await createRequest(
                                                      (addressList
                                                              .where((element) =>
                                                                  element
                                                                      .type ==
                                                                  'drop')
                                                              .isNotEmpty)
                                                          ? jsonEncode({
                                                              'pick_lat': addressList
                                                                  .firstWhere((e) =>
                                                                      e.type ==
                                                                      'pickup')
                                                                  .latlng
                                                                  .latitude,
                                                              'poly_line':
                                                                  polyString,
                                                              'pick_lng': addressList
                                                                  .firstWhere((e) =>
                                                                      e.type ==
                                                                      'pickup')
                                                                  .latlng
                                                                  .longitude,
                                                              'drop_lat': addressList
                                                                  .lastWhere((e) =>
                                                                      e.type ==
                                                                      'drop')
                                                                  .latlng
                                                                  .latitude,
                                                              'drop_lng': addressList
                                                                  .lastWhere((e) =>
                                                                      e.type ==
                                                                      'drop')
                                                                  .latlng
                                                                  .longitude,
                                                              'vehicle_type':
                                                                  etaDetails[
                                                                          choosenVehicle]
                                                                      [
                                                                      'zone_type_id'],
                                                              'ride_type': 1,
                                                              'is_pet_available':
                                                                  (addPetPreferences ==
                                                                          false)
                                                                      ? false
                                                                      : true,
                                                              'is_luggage_available':
                                                                  (addLuggagePreferences ==
                                                                          false)
                                                                      ? false
                                                                      : true,
                                                              'payment_opt': (etaDetails[choosenVehicle]
                                                                              [
                                                                              'payment_type']
                                                                          .toString()
                                                                          .split(
                                                                              ',')
                                                                          .toList()[payingVia] ==
                                                                      'card')
                                                                  ? 0
                                                                  : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                      ? 1
                                                                      : 2,
                                                              'pick_address': addressList
                                                                  .firstWhere((e) =>
                                                                      e.type ==
                                                                      'pickup')
                                                                  .address,
                                                              'drop_address':
                                                                  addressList
                                                                      .lastWhere((e) =>
                                                                          e.type ==
                                                                          'drop')
                                                                      .address,
                                                              'request_eta_amount':
                                                                  etaDetails[
                                                                          choosenVehicle]
                                                                      ['total'],
                                                              'offerred_ride_fare':
                                                                  yourAmount
                                                                      .text,
                                                              'is_bid_ride': 1,
                                                              'stops': jsonEncode(
                                                                  dropStopList),
                                                            })
                                                          : jsonEncode({
                                                              'pick_lat': addressList
                                                                  .firstWhere((e) =>
                                                                      e.type ==
                                                                      'pickup')
                                                                  .latlng
                                                                  .latitude,
                                                              'pick_lng': addressList
                                                                  .firstWhere((e) =>
                                                                      e.type ==
                                                                      'pickup')
                                                                  .latlng
                                                                  .longitude,
                                                              'vehicle_type':
                                                                  etaDetails[
                                                                          choosenVehicle]
                                                                      [
                                                                      'zone_type_id'],
                                                              'ride_type': 1,
                                                              'is_pet_available':
                                                                  (addPetPreferences ==
                                                                          false)
                                                                      ? false
                                                                      : true,
                                                              'is_luggage_available':
                                                                  (addLuggagePreferences ==
                                                                          false)
                                                                      ? false
                                                                      : true,
                                                              'payment_opt': (etaDetails[choosenVehicle]
                                                                              [
                                                                              'payment_type']
                                                                          .toString()
                                                                          .split(
                                                                              ',')
                                                                          .toList()[payingVia] ==
                                                                      'card')
                                                                  ? 0
                                                                  : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                      ? 1
                                                                      : 2,
                                                              'pick_address': addressList
                                                                  .firstWhere((e) =>
                                                                      e.type ==
                                                                      'pickup')
                                                                  .address,
                                                              'request_eta_amount':
                                                                  etaDetails[
                                                                          choosenVehicle]
                                                                      ['total'],
                                                              'offerred_ride_fare':
                                                                  yourAmount
                                                                      .text,
                                                              'is_bid_ride': 1
                                                            }),
                                                      'api/v1/request/create');
                                                } else {
                                                  if (dropStopList.isNotEmpty) {
                                                    result =
                                                        await createRequest(
                                                            jsonEncode({
                                                              'pick_lat':
                                                                  addressList[0]
                                                                      .latlng
                                                                      .latitude,
                                                              'pick_lng':
                                                                  addressList[0]
                                                                      .latlng
                                                                      .longitude,
                                                              'poly_line':
                                                                  polyString,
                                                              'drop_lat':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .latlng
                                                                      .latitude,
                                                              'drop_lng': addressList[
                                                                      addressList
                                                                              .length -
                                                                          1]
                                                                  .latlng
                                                                  .longitude,
                                                              'vehicle_type':
                                                                  etaDetails[
                                                                          choosenVehicle]
                                                                      [
                                                                      'zone_type_id'],
                                                              'ride_type': 1,
                                                              'is_pet_available':
                                                                  (addPetPreferences ==
                                                                          false)
                                                                      ? false
                                                                      : true,
                                                              'is_luggage_available':
                                                                  (addLuggagePreferences ==
                                                                          false)
                                                                      ? false
                                                                      : true,
                                                              'payment_opt': (etaDetails[choosenVehicle]
                                                                              [
                                                                              'payment_type']
                                                                          .toString()
                                                                          .split(
                                                                              ',')
                                                                          .toList()[payingVia] ==
                                                                      'card')
                                                                  ? 0
                                                                  : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                      ? 1
                                                                      : 2,
                                                              'pick_address':
                                                                  addressList[0]
                                                                      .address,
                                                              'drop_address':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .address,
                                                              'request_eta_amount':
                                                                  etaDetails[
                                                                          choosenVehicle]
                                                                      ['total'],
                                                              'pickup_poc_name':
                                                                  addressList[0]
                                                                      .name,
                                                              'pickup_poc_mobile':
                                                                  addressList[0]
                                                                      .number,
                                                              'pickup_poc_instruction':
                                                                  addressList[0]
                                                                      .instructions,
                                                              'drop_poc_name':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .name,
                                                              'drop_poc_mobile':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .number,
                                                              'drop_poc_instruction':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .instructions,
                                                              'goods_type_id':
                                                                  selectedGoodsId
                                                                      .toString(),
                                                              'stops': jsonEncode(
                                                                  dropStopList),
                                                              'goods_type_quantity':
                                                                  goodsSize,
                                                              'offerred_ride_fare':
                                                                  yourAmount
                                                                      .text,
                                                              'is_bid_ride': 1
                                                            }),
                                                            (userDetails['is_delivery_app'] !=
                                                                        null &&
                                                                    userDetails[
                                                                            'is_delivery_app'] ==
                                                                        true)
                                                                ? 'api/v1/request/create'
                                                                : 'api/v1/request/delivery/create');
                                                  } else {
                                                    result =
                                                        await createRequest(
                                                            jsonEncode({
                                                              'pick_lat':
                                                                  addressList[0]
                                                                      .latlng
                                                                      .latitude,
                                                              'poly_line':
                                                                  polyString,
                                                              'pick_lng':
                                                                  addressList[0]
                                                                      .latlng
                                                                      .longitude,
                                                              'drop_lat':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .latlng
                                                                      .latitude,
                                                              'drop_lng': addressList[
                                                                      addressList
                                                                              .length -
                                                                          1]
                                                                  .latlng
                                                                  .longitude,
                                                              'vehicle_type':
                                                                  etaDetails[
                                                                          choosenVehicle]
                                                                      [
                                                                      'zone_type_id'],
                                                              'ride_type': 1,
                                                              'is_pet_available':
                                                                  (addPetPreferences ==
                                                                          false)
                                                                      ? false
                                                                      : true,
                                                              'is_luggage_available':
                                                                  (addLuggagePreferences ==
                                                                          false)
                                                                      ? false
                                                                      : true,
                                                              'payment_opt': (etaDetails[choosenVehicle]
                                                                              [
                                                                              'payment_type']
                                                                          .toString()
                                                                          .split(
                                                                              ',')
                                                                          .toList()[payingVia] ==
                                                                      'card')
                                                                  ? 0
                                                                  : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                      ? 1
                                                                      : 2,
                                                              'pick_address':
                                                                  addressList[0]
                                                                      .address,
                                                              'drop_address':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .address,
                                                              'request_eta_amount':
                                                                  etaDetails[
                                                                          choosenVehicle]
                                                                      ['total'],
                                                              'pickup_poc_name':
                                                                  addressList[0]
                                                                      .name,
                                                              'pickup_poc_mobile':
                                                                  addressList[0]
                                                                      .number,
                                                              'pickup_poc_instruction':
                                                                  addressList[0]
                                                                      .instructions,
                                                              'drop_poc_name':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .name,
                                                              'drop_poc_mobile':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .number,
                                                              'drop_poc_instruction':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .instructions,
                                                              'goods_type_id':
                                                                  selectedGoodsId
                                                                      .toString(),
                                                              'goods_type_quantity':
                                                                  goodsSize,
                                                              'offerred_ride_fare':
                                                                  yourAmount
                                                                      .text,
                                                              'is_bid_ride': 1
                                                            }),
                                                            (userDetails['is_delivery_app'] !=
                                                                        null &&
                                                                    userDetails[
                                                                            'is_delivery_app'] ==
                                                                        true)
                                                                ? 'api/v1/request/create'
                                                                : 'api/v1/request/delivery/create');
                                                  }
                                                }
                                              } else {
                                                if (choosenTransportType == 0) {
                                                  result = await createRequest(
                                                      (addressList
                                                              .where((element) =>
                                                                  element
                                                                      .type ==
                                                                  'drop')
                                                              .isNotEmpty)
                                                          ? jsonEncode({
                                                              'pick_lat': addressList
                                                                  .firstWhere((e) =>
                                                                      e.type ==
                                                                      'pickup')
                                                                  .latlng
                                                                  .latitude,
                                                              'pick_lng': addressList
                                                                  .firstWhere((e) =>
                                                                      e.type ==
                                                                      'pickup')
                                                                  .latlng
                                                                  .longitude,
                                                              'poly_line':
                                                                  polyString,
                                                              'drop_lat': addressList
                                                                  .lastWhere((e) =>
                                                                      e.type ==
                                                                      'drop')
                                                                  .latlng
                                                                  .latitude,
                                                              'drop_lng': addressList
                                                                  .lastWhere((e) =>
                                                                      e.type ==
                                                                      'drop')
                                                                  .latlng
                                                                  .longitude,
                                                              'vehicle_type':
                                                                  etaDetails[
                                                                          choosenVehicle]
                                                                      [
                                                                      'zone_type_id'],
                                                              'ride_type': 1,
                                                              'is_pet_available':
                                                                  (addPetPreferences ==
                                                                          false)
                                                                      ? false
                                                                      : true,
                                                              'is_luggage_available':
                                                                  (addLuggagePreferences ==
                                                                          false)
                                                                      ? false
                                                                      : true,
                                                              'payment_opt': (etaDetails[choosenVehicle]
                                                                              [
                                                                              'payment_type']
                                                                          .toString()
                                                                          .split(
                                                                              ',')
                                                                          .toList()[payingVia] ==
                                                                      'card')
                                                                  ? 0
                                                                  : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                      ? 1
                                                                      : 2,
                                                              'pick_address': addressList
                                                                  .firstWhere((e) =>
                                                                      e.type ==
                                                                      'pickup')
                                                                  .address,
                                                              'drop_address':
                                                                  addressList
                                                                      .lastWhere((e) =>
                                                                          e.type ==
                                                                          'drop')
                                                                      .address,
                                                              'request_eta_amount':
                                                                  etaDetails[
                                                                          choosenVehicle]
                                                                      ['total'],
                                                              'offerred_ride_fare':
                                                                  yourAmount
                                                                      .text,
                                                              'is_bid_ride': 1,
                                                              'stops': jsonEncode(
                                                                  dropStopList),
                                                            })
                                                          : jsonEncode({
                                                              'pick_lat': addressList
                                                                  .firstWhere((e) =>
                                                                      e.type ==
                                                                      'pickup')
                                                                  .latlng
                                                                  .latitude,
                                                              'pick_lng': addressList
                                                                  .firstWhere((e) =>
                                                                      e.type ==
                                                                      'pickup')
                                                                  .latlng
                                                                  .longitude,
                                                              'vehicle_type':
                                                                  etaDetails[
                                                                          choosenVehicle]
                                                                      [
                                                                      'zone_type_id'],
                                                              'ride_type': 1,
                                                              'is_pet_available':
                                                                  (addPetPreferences ==
                                                                          false)
                                                                      ? false
                                                                      : true,
                                                              'is_luggage_available':
                                                                  (addLuggagePreferences ==
                                                                          false)
                                                                      ? false
                                                                      : true,
                                                              'payment_opt': (etaDetails[choosenVehicle]
                                                                              [
                                                                              'payment_type']
                                                                          .toString()
                                                                          .split(
                                                                              ',')
                                                                          .toList()[payingVia] ==
                                                                      'card')
                                                                  ? 0
                                                                  : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                      ? 1
                                                                      : 2,
                                                              'pick_address': addressList
                                                                  .firstWhere((e) =>
                                                                      e.type ==
                                                                      'pickup')
                                                                  .address,
                                                              'request_eta_amount':
                                                                  etaDetails[
                                                                          choosenVehicle]
                                                                      ['total'],
                                                              'offerred_ride_fare':
                                                                  yourAmount
                                                                      .text,
                                                              'is_bid_ride': 1
                                                            }),
                                                      'api/v1/request/create');
                                                } else {
                                                  if (dropStopList.isNotEmpty) {
                                                    result =
                                                        await createRequest(
                                                            jsonEncode({
                                                              'pick_lat':
                                                                  addressList[0]
                                                                      .latlng
                                                                      .latitude,
                                                              'poly_line':
                                                                  polyString,
                                                              'pick_lng':
                                                                  addressList[0]
                                                                      .latlng
                                                                      .longitude,
                                                              'drop_lat':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .latlng
                                                                      .latitude,
                                                              'drop_lng': addressList[
                                                                      addressList
                                                                              .length -
                                                                          1]
                                                                  .latlng
                                                                  .longitude,
                                                              'vehicle_type':
                                                                  etaDetails[
                                                                          choosenVehicle]
                                                                      [
                                                                      'zone_type_id'],
                                                              'ride_type': 1,
                                                              'is_pet_available':
                                                                  (addPetPreferences ==
                                                                          false)
                                                                      ? false
                                                                      : true,
                                                              'is_luggage_available':
                                                                  (addLuggagePreferences ==
                                                                          false)
                                                                      ? false
                                                                      : true,
                                                              'payment_opt': (etaDetails[choosenVehicle]
                                                                              [
                                                                              'payment_type']
                                                                          .toString()
                                                                          .split(
                                                                              ',')
                                                                          .toList()[payingVia] ==
                                                                      'card')
                                                                  ? 0
                                                                  : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                      ? 1
                                                                      : 2,
                                                              'pick_address':
                                                                  addressList[0]
                                                                      .address,
                                                              'drop_address':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .address,
                                                              'request_eta_amount':
                                                                  etaDetails[
                                                                          choosenVehicle]
                                                                      ['total'],
                                                              'pickup_poc_name':
                                                                  addressList[0]
                                                                      .name,
                                                              'pickup_poc_mobile':
                                                                  addressList[0]
                                                                      .number,
                                                              'pickup_poc_instruction':
                                                                  addressList[0]
                                                                      .instructions,
                                                              'drop_poc_name':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .name,
                                                              'drop_poc_mobile':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .number,
                                                              'drop_poc_instruction':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .instructions,
                                                              'goods_type_id':
                                                                  selectedGoodsId
                                                                      .toString(),
                                                              'stops': jsonEncode(
                                                                  dropStopList),
                                                              'goods_type_quantity':
                                                                  goodsSize,
                                                              'offerred_ride_fare':
                                                                  yourAmount
                                                                      .text,
                                                              'is_bid_ride': 1
                                                            }),
                                                            (userDetails['is_delivery_app'] !=
                                                                        null &&
                                                                    userDetails[
                                                                            'is_delivery_app'] ==
                                                                        true)
                                                                ? 'api/v1/request/create'
                                                                : 'api/v1/request/delivery/create');
                                                  } else {
                                                    result =
                                                        await createRequest(
                                                            jsonEncode({
                                                              'pick_lat':
                                                                  addressList[0]
                                                                      .latlng
                                                                      .latitude,
                                                              'pick_lng':
                                                                  addressList[0]
                                                                      .latlng
                                                                      .longitude,
                                                              'poly_line':
                                                                  polyString,
                                                              'drop_lat':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .latlng
                                                                      .latitude,
                                                              'drop_lng': addressList[
                                                                      addressList
                                                                              .length -
                                                                          1]
                                                                  .latlng
                                                                  .longitude,
                                                              'vehicle_type':
                                                                  etaDetails[
                                                                          choosenVehicle]
                                                                      [
                                                                      'zone_type_id'],
                                                              'ride_type': 1,
                                                              'is_pet_available':
                                                                  (addPetPreferences ==
                                                                          false)
                                                                      ? false
                                                                      : true,
                                                              'is_luggage_available':
                                                                  (addLuggagePreferences ==
                                                                          false)
                                                                      ? false
                                                                      : true,
                                                              'payment_opt': (etaDetails[choosenVehicle]
                                                                              [
                                                                              'payment_type']
                                                                          .toString()
                                                                          .split(
                                                                              ',')
                                                                          .toList()[payingVia] ==
                                                                      'card')
                                                                  ? 0
                                                                  : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                      ? 1
                                                                      : 2,
                                                              'pick_address':
                                                                  addressList[0]
                                                                      .address,
                                                              'drop_address':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .address,
                                                              'request_eta_amount':
                                                                  etaDetails[
                                                                          choosenVehicle]
                                                                      ['total'],
                                                              'pickup_poc_name':
                                                                  addressList[0]
                                                                      .name,
                                                              'pickup_poc_mobile':
                                                                  addressList[0]
                                                                      .number,
                                                              'pickup_poc_instruction':
                                                                  addressList[0]
                                                                      .instructions,
                                                              'drop_poc_name':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .name,
                                                              'drop_poc_mobile':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .number,
                                                              'drop_poc_instruction':
                                                                  addressList[
                                                                          addressList.length -
                                                                              1]
                                                                      .instructions,
                                                              'goods_type_id':
                                                                  selectedGoodsId
                                                                      .toString(),
                                                              'goods_type_quantity':
                                                                  goodsSize,
                                                              'offerred_ride_fare':
                                                                  yourAmount
                                                                      .text,
                                                              'is_bid_ride': 1
                                                            }),
                                                            (userDetails['is_delivery_app'] !=
                                                                        null &&
                                                                    userDetails[
                                                                            'is_delivery_app'] ==
                                                                        true)
                                                                ? 'api/v1/request/create'
                                                                : 'api/v1/request/delivery/create');
                                                  }
                                                }
                                              }
                                            } else {
                                              if (rentalOption[choosenVehicle]
                                                      ['has_discount'] ==
                                                  false) {
                                                if (choosenTransportType == 0) {
                                                  result = await createRequest(
                                                      jsonEncode({
                                                        'pick_lat': addressList
                                                            .firstWhere((e) =>
                                                                e.type ==
                                                                'pickup')
                                                            .latlng
                                                            .latitude,
                                                        'poly_line': polyString,
                                                        'pick_lng': addressList
                                                            .firstWhere((e) =>
                                                                e.type ==
                                                                'pickup')
                                                            .latlng
                                                            .longitude,
                                                        'vehicle_type':
                                                            rentalOption[
                                                                    choosenVehicle]
                                                                [
                                                                'zone_type_id'],
                                                        'ride_type': 1,
                                                        'is_pet_available':
                                                            (addPetPreferences ==
                                                                    false)
                                                                ? false
                                                                : true,
                                                        'is_luggage_available':
                                                            (addLuggagePreferences ==
                                                                    false)
                                                                ? false
                                                                : true,
                                                        'payment_opt': (rentalOption[choosenVehicle]
                                                                            [
                                                                            'payment_type']
                                                                        .toString()
                                                                        .split(',')
                                                                        .toList()[
                                                                    payingVia] ==
                                                                'card')
                                                            ? 0
                                                            : (rentalOption[choosenVehicle]
                                                                            [
                                                                            'payment_type']
                                                                        .toString()
                                                                        .split(
                                                                            ',')
                                                                        .toList()[payingVia] ==
                                                                    'cash')
                                                                ? 1
                                                                : 2,
                                                        'pick_address':
                                                            addressList
                                                                .firstWhere((e) =>
                                                                    e.type ==
                                                                    'pickup')
                                                                .address,
                                                        'request_eta_amount':
                                                            rentalOption[
                                                                    choosenVehicle]
                                                                ['fare_amount'],
                                                        'rental_pack_id':
                                                            etaDetails[
                                                                    rentalChoosenOption]
                                                                ['id'],
                                                        'offerred_ride_fare':
                                                            yourAmount.text,
                                                        'is_bid_ride': 1
                                                      }),
                                                      'api/v1/request/create');
                                                } else {
                                                  result = await createRequest(
                                                      jsonEncode({
                                                        'pick_lat': addressList
                                                            .firstWhere((e) =>
                                                                e.type ==
                                                                'pickup')
                                                            .latlng
                                                            .latitude,
                                                        'poly_line': polyString,
                                                        'pick_lng': addressList
                                                            .firstWhere((e) =>
                                                                e.type ==
                                                                'pickup')
                                                            .latlng
                                                            .longitude,
                                                        'vehicle_type':
                                                            rentalOption[
                                                                    choosenVehicle]
                                                                [
                                                                'zone_type_id'],
                                                        'ride_type': 1,
                                                        'is_pet_available':
                                                            (addPetPreferences ==
                                                                    false)
                                                                ? false
                                                                : true,
                                                        'is_luggage_available':
                                                            (addLuggagePreferences ==
                                                                    false)
                                                                ? false
                                                                : true,
                                                        'payment_opt': (rentalOption[choosenVehicle]
                                                                            [
                                                                            'payment_type']
                                                                        .toString()
                                                                        .split(',')
                                                                        .toList()[
                                                                    payingVia] ==
                                                                'card')
                                                            ? 0
                                                            : (rentalOption[choosenVehicle]
                                                                            [
                                                                            'payment_type']
                                                                        .toString()
                                                                        .split(
                                                                            ',')
                                                                        .toList()[payingVia] ==
                                                                    'cash')
                                                                ? 1
                                                                : 2,
                                                        'pick_address':
                                                            addressList
                                                                .firstWhere((e) =>
                                                                    e.type ==
                                                                    'pickup')
                                                                .address,
                                                        'request_eta_amount':
                                                            rentalOption[
                                                                    choosenVehicle]
                                                                ['fare_amount'],
                                                        'rental_pack_id':
                                                            etaDetails[
                                                                    rentalChoosenOption]
                                                                ['id'],
                                                        'pickup_poc_name':
                                                            addressList[0].name,
                                                        'pickup_poc_mobile':
                                                            addressList[0]
                                                                .number,
                                                        'pickup_poc_instruction':
                                                            addressList[0]
                                                                .instructions,
                                                        'goods_type_id':
                                                            selectedGoodsId
                                                                .toString(),
                                                        'goods_type_quantity':
                                                            goodsSize,
                                                        'offerred_ride_fare':
                                                            yourAmount.text,
                                                        'is_bid_ride': 1
                                                      }),
                                                      (userDetails['is_delivery_app'] !=
                                                                  null &&
                                                              userDetails[
                                                                      'is_delivery_app'] ==
                                                                  true)
                                                          ? 'api/v1/request/create'
                                                          : 'api/v1/request/delivery/create');
                                                }
                                              } else {
                                                if (choosenTransportType == 0) {
                                                  result = await createRequest(
                                                      jsonEncode({
                                                        'pick_lat': addressList
                                                            .firstWhere((e) =>
                                                                e.type ==
                                                                'pickup')
                                                            .latlng
                                                            .latitude,
                                                        'poly_line': polyString,
                                                        'pick_lng': addressList
                                                            .firstWhere((e) =>
                                                                e.type ==
                                                                'pickup')
                                                            .latlng
                                                            .longitude,
                                                        'vehicle_type':
                                                            rentalOption[
                                                                    choosenVehicle]
                                                                [
                                                                'zone_type_id'],
                                                        'ride_type': 1,
                                                        'is_pet_available':
                                                            (addPetPreferences ==
                                                                    false)
                                                                ? false
                                                                : true,
                                                        'is_luggage_available':
                                                            (addLuggagePreferences ==
                                                                    false)
                                                                ? false
                                                                : true,
                                                        'payment_opt': (rentalOption[choosenVehicle]
                                                                            [
                                                                            'payment_type']
                                                                        .toString()
                                                                        .split(',')
                                                                        .toList()[
                                                                    payingVia] ==
                                                                'card')
                                                            ? 0
                                                            : (rentalOption[choosenVehicle]
                                                                            [
                                                                            'payment_type']
                                                                        .toString()
                                                                        .split(
                                                                            ',')
                                                                        .toList()[payingVia] ==
                                                                    'cash')
                                                                ? 1
                                                                : 2,
                                                        'pick_address':
                                                            addressList
                                                                .firstWhere((e) =>
                                                                    e.type ==
                                                                    'pickup')
                                                                .address,
                                                        'promocode_id':
                                                            rentalOption[
                                                                    choosenVehicle]
                                                                [
                                                                'promocode_id'],
                                                        'request_eta_amount':
                                                            rentalOption[
                                                                    choosenVehicle]
                                                                ['fare_amount'],
                                                        'rental_pack_id':
                                                            etaDetails[
                                                                    rentalChoosenOption]
                                                                ['id'],
                                                        'offerred_ride_fare':
                                                            yourAmount.text,
                                                        'is_bid_ride': 1
                                                      }),
                                                      'api/v1/request/create');
                                                } else {
                                                  result = await createRequest(
                                                      jsonEncode({
                                                        'pick_lat': addressList
                                                            .firstWhere((e) =>
                                                                e.type ==
                                                                'pickup')
                                                            .latlng
                                                            .latitude,
                                                        'poly_line': polyString,
                                                        'pick_lng': addressList
                                                            .firstWhere((e) =>
                                                                e.type ==
                                                                'pickup')
                                                            .latlng
                                                            .longitude,
                                                        'vehicle_type':
                                                            rentalOption[
                                                                    choosenVehicle]
                                                                [
                                                                'zone_type_id'],
                                                        'ride_type': 1,
                                                        'is_pet_available':
                                                            (addPetPreferences ==
                                                                    false)
                                                                ? false
                                                                : true,
                                                        'is_luggage_available':
                                                            (addLuggagePreferences ==
                                                                    false)
                                                                ? false
                                                                : true,
                                                        'payment_opt': (rentalOption[choosenVehicle]
                                                                            [
                                                                            'payment_type']
                                                                        .toString()
                                                                        .split(',')
                                                                        .toList()[
                                                                    payingVia] ==
                                                                'card')
                                                            ? 0
                                                            : (rentalOption[choosenVehicle]
                                                                            [
                                                                            'payment_type']
                                                                        .toString()
                                                                        .split(
                                                                            ',')
                                                                        .toList()[payingVia] ==
                                                                    'cash')
                                                                ? 1
                                                                : 2,
                                                        'pick_address':
                                                            addressList
                                                                .firstWhere((e) =>
                                                                    e.type ==
                                                                    'pickup')
                                                                .address,
                                                        'promocode_id':
                                                            rentalOption[
                                                                    choosenVehicle]
                                                                [
                                                                'promocode_id'],
                                                        'request_eta_amount':
                                                            rentalOption[
                                                                    choosenVehicle]
                                                                ['fare_amount'],
                                                        'rental_pack_id':
                                                            etaDetails[
                                                                    rentalChoosenOption]
                                                                ['id'],
                                                        'goods_type_id':
                                                            selectedGoodsId
                                                                .toString(),
                                                        'goods_type_quantity':
                                                            goodsSize,
                                                        'pickup_poc_name':
                                                            addressList[0].name,
                                                        'pickup_poc_mobile':
                                                            addressList[0]
                                                                .number,
                                                        'pickup_poc_instruction':
                                                            addressList[0]
                                                                .instructions,
                                                        'offerred_ride_fare':
                                                            yourAmount.text,
                                                        'is_bid_ride': 1
                                                      }),
                                                      (userDetails['is_delivery_app'] !=
                                                                  null &&
                                                              userDetails[
                                                                      'is_delivery_app'] ==
                                                                  true)
                                                          ? 'api/v1/request/create'
                                                          : 'api/v1/request/delivery/create');
                                                }
                                              }
                                            }
                                          }
                                        }
                                      }
                                    } else if (isOutStation &&
                                        widget.isOneWayTrip == false) {
                                      if (!iscondition) {
                                        iscondition = true;
                                        setState(() {
                                          isLoading = true;
                                        });

                                        if (choosenVehicle != null) {
                                          if (isOutStation) {
                                            if (choosenTransportType == 0) {
                                              result = await createRequestLater(
                                                  jsonEncode({
                                                    'pick_lat': addressList
                                                        .firstWhere((e) =>
                                                            e.type == 'pickup')
                                                        .latlng
                                                        .latitude,
                                                    'pick_lng': addressList
                                                        .firstWhere((e) =>
                                                            e.type == 'pickup')
                                                        .latlng
                                                        .longitude,
                                                    'poly_line': polyString,
                                                    'drop_lat': addressList
                                                        .lastWhere((e) =>
                                                            e.type == 'drop')
                                                        .latlng
                                                        .latitude,
                                                    'drop_lng': addressList
                                                        .lastWhere((e) =>
                                                            e.type == 'drop')
                                                        .latlng
                                                        .longitude,
                                                    'vehicle_type': etaDetails[
                                                            choosenVehicle]
                                                        ['zone_type_id'],
                                                    'ride_type': 1,
                                                    'is_pet_available':
                                                        (addPetPreferences ==
                                                                false)
                                                            ? false
                                                            : true,
                                                    'is_luggage_available':
                                                        (addLuggagePreferences ==
                                                                false)
                                                            ? false
                                                            : true,
                                                    'payment_opt': (etaDetails[
                                                                            choosenVehicle]
                                                                        [
                                                                        'payment_type']
                                                                    .toString()
                                                                    .split(',')
                                                                    .toList()[
                                                                payingVia] ==
                                                            'card')
                                                        ? 0
                                                        : (etaDetails[choosenVehicle]
                                                                        [
                                                                        'payment_type']
                                                                    .toString()
                                                                    .split(',')
                                                                    .toList()[payingVia] ==
                                                                'cash')
                                                            ? 1
                                                            : 2,
                                                    'pick_address': addressList
                                                        .firstWhere((e) =>
                                                            e.type == 'pickup')
                                                        .address,
                                                    'drop_address': addressList
                                                        .lastWhere((e) =>
                                                            e.type == 'drop')
                                                        .address,
                                                    'request_eta_amount':
                                                        etaDetails[
                                                                choosenVehicle]
                                                            ['total'],
                                                    'offerred_ride_fare':
                                                        yourAmount.text,
                                                    'is_bid_ride': 1,
                                                    'trip_start_time': widget
                                                        .fromDate
                                                        .toString()
                                                        .substring(0, 19),
                                                    if (dropStopList.isNotEmpty)
                                                      'stops': jsonEncode(
                                                          dropStopList),
                                                    if (widget.toDate != null)
                                                      'is_round_trip': true,
                                                    if (widget.toDate != null)
                                                      'return_time': widget
                                                          .toDate
                                                          .toString()
                                                          .substring(0, 19),
                                                    'is_later': true,
                                                    'is_out_station': true,
                                                  }),
                                                  'api/v1/request/create');
                                            } else {
                                              result = await createRequestLater(
                                                  jsonEncode({
                                                    'pick_lat': addressList[0]
                                                        .latlng
                                                        .latitude,
                                                    'pick_lng': addressList[0]
                                                        .latlng
                                                        .longitude,
                                                    'drop_lat': addressList[
                                                            addressList.length -
                                                                1]
                                                        .latlng
                                                        .latitude,
                                                    'drop_lng': addressList[
                                                            addressList.length -
                                                                1]
                                                        .latlng
                                                        .longitude,
                                                    'poly_line': polyString,
                                                    'vehicle_type': etaDetails[
                                                            choosenVehicle]
                                                        ['zone_type_id'],
                                                    'ride_type': 1,
                                                    'is_pet_available':
                                                        (addPetPreferences ==
                                                                false)
                                                            ? false
                                                            : true,
                                                    'is_luggage_available':
                                                        (addLuggagePreferences ==
                                                                false)
                                                            ? false
                                                            : true,
                                                    'payment_opt': (etaDetails[
                                                                            choosenVehicle]
                                                                        [
                                                                        'payment_type']
                                                                    .toString()
                                                                    .split(',')
                                                                    .toList()[
                                                                payingVia] ==
                                                            'card')
                                                        ? 0
                                                        : (etaDetails[choosenVehicle]
                                                                        [
                                                                        'payment_type']
                                                                    .toString()
                                                                    .split(',')
                                                                    .toList()[payingVia] ==
                                                                'cash')
                                                            ? 1
                                                            : 2,
                                                    'pick_address':
                                                        addressList[0].address,
                                                    'drop_address': addressList[
                                                            addressList.length -
                                                                1]
                                                        .address,
                                                    'request_eta_amount':
                                                        etaDetails[
                                                                choosenVehicle]
                                                            ['total'],
                                                    'pickup_poc_name':
                                                        addressList[0].name,
                                                    'pickup_poc_mobile':
                                                        addressList[0].number,
                                                    'pickup_poc_instruction':
                                                        addressList[0]
                                                            .instructions,
                                                    'drop_poc_name':
                                                        addressList[addressList
                                                                    .length -
                                                                1]
                                                            .name,
                                                    'drop_poc_mobile':
                                                        addressList[addressList
                                                                    .length -
                                                                1]
                                                            .number,
                                                    'drop_poc_instruction':
                                                        addressList[addressList
                                                                    .length -
                                                                1]
                                                            .instructions,
                                                    if (dropStopList.isNotEmpty)
                                                      'stops': jsonEncode(
                                                          dropStopList),
                                                    'goods_type_id':
                                                        selectedGoodsId
                                                            .toString(),
                                                    'goods_type_quantity':
                                                        goodsSize,
                                                    'offerred_ride_fare':
                                                        yourAmount.text,
                                                    'is_bid_ride': 1,
                                                    'trip_start_time': widget
                                                        .fromDate
                                                        .toString()
                                                        .substring(0, 19),
                                                    if (widget.toDate != null)
                                                      'is_round_trip': true,
                                                    if (widget.toDate != null)
                                                      'return_time': widget
                                                          .toDate
                                                          .toString()
                                                          .substring(0, 19),
                                                    'is_later': true,
                                                    'is_out_station': true,
                                                  }),
                                                  (userDetails['is_delivery_app'] !=
                                                              null &&
                                                          userDetails[
                                                                  'is_delivery_app'] ==
                                                              true)
                                                      ? 'api/v1/request/create'
                                                      : 'api/v1/request/delivery/create');
                                            }
                                          }
                                        }
                                      }
                                    } else {
                                      if (yourAmount.text != '') {
                                        setState(() {
                                          fareError =
                                              'offered ride fare must be greater than minimum fare';
                                        });
                                      }
                                    }

                                    if (result == 'success') {
                                      if (isOutStation) {
                                        // _showInfo = false;
                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);

                                        rideLaterSuccess = true;
                                        showModalBottomSheet(
                                            // ignore: use_build_context_synchronously
                                            context: context,
                                            isDismissible: false,
                                            builder: (context) {
                                              return const SuccessPopUp();
                                            });

                                        FirebaseDatabase.instance
                                            .ref()
                                            .child(
                                                'bid-meta/${userRequestData["id"]}')
                                            .update({
                                          'user_id':
                                              userDetails['id'].toString(),
                                          'price': yourAmount.text,
                                          'g': g,
                                          'user_name': userDetails['name'],
                                          'updated_at': ServerValue.timestamp,
                                          'user_img':
                                              userDetails['profile_picture'],
                                          'vehicle_type': userRequestData[
                                              'vehicle_type_id'],
                                          'request_id': userRequestData["id"],
                                          'request_no':
                                              userRequestData["request_number"],
                                          'pick_address':
                                              userRequestData['pick_address'],
                                          'drop_address':
                                              userRequestData['drop_address'],
                                          'trip_stops':
                                              (dropStopList.isNotEmpty)
                                                  ? jsonEncode(dropStopList)
                                                  : 'null',
                                          'goods': (userRequestData[
                                                          'transport_type'] !=
                                                      'taxi' &&
                                                  userRequestData[
                                                          'goods_type'] !=
                                                      '-')
                                              ? '${userRequestData['goods_type']} - ${userRequestData['goods_type_quantity']}'
                                              : 'null',
                                          'pick_lat':
                                              userRequestData['pick_lat'],
                                          'drop_lat':
                                              userRequestData['drop_lat'],
                                          'pick_lng':
                                              userRequestData['pick_lng'],
                                          'drop_lng':
                                              userRequestData['drop_lng'],
                                          'currency':
                                              userDetails['currency_symbol'],
                                          'trip_start_time':
                                              DateFormat('d-MMM-y, h:mm a')
                                                  .format(widget.fromDate)
                                                  .toString(),
                                          if (widget.toDate != null)
                                            'return_time':
                                                DateFormat('d-MMM-y, h:mm a')
                                                    .format(widget.toDate!)
                                                    .toString(),
                                          'is_later': true,
                                          'is_out_station': true,
                                          'distance': etaDetails[choosenVehicle]
                                                  ['distance']
                                              .toString(),
                                          'is_pet_available':
                                              (addPetPreferences == false)
                                                  ? false
                                                  : true,
                                          'is_luggage_available':
                                              (addLuggagePreferences == false)
                                                  ? false
                                                  : true,
                                        });
                                        userRequestData.clear();
                                      } else {
                                        // ignore: use_build_context_synchronously
                                        Navigator.pop(context);
                                        FirebaseDatabase.instance
                                            .ref()
                                            .child(
                                                'bid-meta/${userRequestData["id"]}')
                                            .update({
                                          'user_id':
                                              userDetails['id'].toString(),
                                          'price': userRequestData[
                                              'offerred_ride_fare'],
                                          'g': g,
                                          'user_name': userDetails['name'],
                                          'updated_at': ServerValue.timestamp,
                                          'user_img':
                                              userDetails['profile_picture'],
                                          'vehicle_type': userRequestData[
                                              'vehicle_type_id'],
                                          'request_id': userRequestData["id"],
                                          'request_no':
                                              userRequestData["request_number"],
                                          'pick_address':
                                              userRequestData['pick_address'],
                                          'drop_address':
                                              userRequestData['drop_address'],
                                          'trip_stops':
                                              (dropStopList.isNotEmpty)
                                                  ? jsonEncode(dropStopList)
                                                  : 'null',
                                          'goods': (userRequestData[
                                                          'transport_type'] !=
                                                      'taxi' &&
                                                  userRequestData[
                                                          'goods_type'] !=
                                                      '-')
                                              ? '${userRequestData['goods_type']} - ${userRequestData['goods_type_quantity']}'
                                              : 'null',
                                          'pick_lat':
                                              userRequestData['pick_lat'],
                                          'drop_lat':
                                              userRequestData['drop_lat'],
                                          'pick_lng':
                                              userRequestData['pick_lng'],
                                          'drop_lng':
                                              userRequestData['drop_lng'],
                                          'currency':
                                              userDetails['currency_symbol'],
                                          'is_out_station': false,
                                          'distance': etaDetails[choosenVehicle]
                                                  ['distance']
                                              .toString(),
                                          'is_pet_available':
                                              (addPetPreferences == false)
                                                  ? false
                                                  : true,
                                          'is_luggage_available':
                                              (addLuggagePreferences == false)
                                                  ? false
                                                  : true,
                                        });
                                      }
                                    }
                                    setState(() {
                                      // yourAmount.clear();
                                      isLoading = false;
                                      iscondition = false;
                                    });
                                  }
                                },
                                text: languages[choosenLanguage]
                                    ['text_create_request'],
                                // color: (yourAmount.text.isNotEmpty)
                                //     ? (isDarkTheme)
                                //         ? Colors.white
                                //         : Colors.black
                                //     : Colors.grey,
                              )
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rentalOption[widget.showInfoInt]['name'],
                          style: GoogleFonts.notoSans(
                              fontSize: media.width * sixteen,
                              color: textColor,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: media.width * 0.025,
                        ),
                        Text(
                          rentalOption[widget.showInfoInt]['description'],
                          style: GoogleFonts.notoSans(
                            fontSize: media.width * fourteen,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: media.width * 0.05),
                        Text(
                          languages[choosenLanguage]['text_supported_vehicles'],
                          style: GoogleFonts.notoSans(
                              fontSize: media.width * sixteen,
                              color: textColor,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: media.width * 0.025,
                        ),
                        Text(
                          rentalOption[widget.showInfoInt]
                              ['supported_vehicles'],
                          style: GoogleFonts.notoSans(
                            fontSize: media.width * fourteen,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: media.width * 0.05),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              languages[choosenLanguage]
                                  ['text_estimated_amount'],
                              style: GoogleFonts.notoSans(
                                  fontSize: media.width * sixteen,
                                  color: textColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            (rentalOption[widget.showInfoInt]['has_discount'] !=
                                    true)
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        rentalOption[widget.showInfoInt]
                                                ['currency'] +
                                            ' ' +
                                            rentalOption[widget.showInfoInt]
                                                    ['fare_amount']
                                                .toStringAsFixed(2),
                                        style: GoogleFonts.notoSans(
                                            fontSize: media.width * fourteen,
                                            color: textColor,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        rentalOption[widget.showInfoInt]
                                            ['currency'],
                                        style: GoogleFonts.notoSans(
                                            fontSize: media.width * fourteen,
                                            color: textColor,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        ' ${rentalOption[widget.showInfoInt]['fare_amount'].toStringAsFixed(2)}',
                                        style: GoogleFonts.notoSans(
                                            fontSize: media.width * fourteen,
                                            color: textColor,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.lineThrough),
                                      ),
                                      Text(
                                        ' ${rentalOption[widget.showInfoInt]['discounted_totel'].toStringAsFixed(2)}',
                                        style: GoogleFonts.notoSans(
                                            fontSize: media.width * fourteen,
                                            color: textColor,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  )
                          ],
                        )
                      ],
                    ),
            )
          ],
        ),
      ),
    );
  }
}

int choosenInPopUp = 0;

class ChoosePaymentMethodContainer extends StatefulWidget {
  final dynamic type;
  final dynamic onTap;
  const ChoosePaymentMethodContainer(
      {super.key, this.type, required this.onTap});

  @override
  State<ChoosePaymentMethodContainer> createState() =>
      _ChoosePaymentMethodContainerState();
}

class _ChoosePaymentMethodContainerState
    extends State<ChoosePaymentMethodContainer> {
  @override
  void initState() {
    // choosenInPopUp = 0;
    choosenInPopUp = payingVia;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Container(
      height: media.width * 0.7,
      width: media.width * 1,
      padding: EdgeInsets.all(media.width * 0.05),
      decoration: BoxDecoration(
          color: page,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(media.width * 0.05),
              topRight: Radius.circular(media.width * 0.05))),
      child: Column(
        children: [
          MyText(
            text: languages[choosenLanguage]['text_choose_payment'],
            size: media.width * sixteen,
            fontweight: FontWeight.bold,
          ),
          SizedBox(
            height: media.width * 0.03,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: (choosenVehicle != null && widget.type != 1)
                  ? Column(
                      children: etaDetails[choosenVehicle]['payment_type']
                          .toString()
                          .split(',')
                          .toList()
                          .asMap()
                          .map((i, value) {
                            return MapEntry(
                                i,
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      choosenInPopUp = i;
                                    });
                                  },
                                  child: SizedBox(
                                    height: media.width * 0.106,
                                    width: media.width * 0.9,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: (etaDetails[choosenVehicle]
                                                          ['payment_type']
                                                      .toString()
                                                      .split(',')
                                                      .toList()[i] ==
                                                  'cash')
                                              ? Image.asset(
                                                  'assets/images/cash.png',
                                                  width: media.width * 0.05,
                                                  height: media.width * 0.05,
                                                  fit: BoxFit.contain,
                                                )
                                              : (etaDetails[choosenVehicle]
                                                              ['payment_type']
                                                          .toString()
                                                          .split(',')
                                                          .toList()[i] ==
                                                      'wallet')
                                                  ? Image.asset(
                                                      'assets/images/wallet.png',
                                                      width: media.width * 0.1,
                                                      height: media.width * 0.1,
                                                      fit: BoxFit.contain,
                                                    )
                                                  : (etaDetails[choosenVehicle][
                                                                  'payment_type']
                                                              .toString()
                                                              .split(',')
                                                              .toList()[i] ==
                                                          'card')
                                                      ? Image.asset(
                                                          'assets/images/card.png',
                                                          width:
                                                              media.width * 0.1,
                                                          height:
                                                              media.width * 0.1,
                                                          fit: BoxFit.contain,
                                                        )
                                                      : (etaDetails[choosenVehicle]
                                                                      [
                                                                      'payment_type']
                                                                  .toString()
                                                                  .split(',')
                                                                  .toList()[i] ==
                                                              'upi')
                                                          ? Image.asset(
                                                              'assets/images/upi.png',
                                                              width:
                                                                  media.width *
                                                                      0.1,
                                                              height:
                                                                  media.width *
                                                                      0.1,
                                                              fit: BoxFit
                                                                  .contain,
                                                            )
                                                          : Container(),
                                        ),
                                        SizedBox(
                                          width: media.width * 0.02,
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: MyText(
                                            text: etaDetails[choosenVehicle]
                                                    ['payment_type']
                                                .toString()
                                                .split(',')
                                                .toList()[i],
                                            size: media.width * fourteen,
                                            color:
                                                // (choosenInPopUp == i)
                                                //     ? const Color(0xffFF0000)
                                                //     :
                                                (isDarkTheme == true)
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                        Expanded(
                                            child: Container(
                                          height: media.width * 0.05,
                                          width: media.width * 0.05,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: (isDarkTheme == true)
                                                    ? Colors.white
                                                    : Colors.black),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Container(
                                            height: media.width * 0.03,
                                            width: media.width * 0.03,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: (choosenInPopUp == i)
                                                    // ? const Color(0xffFF0000)
                                                    ? theme
                                                    : page),
                                          ),
                                        ))
                                      ],
                                    ),
                                  ),
                                ));
                          })
                          .values
                          .toList(),
                    )
                  : Column(
                      children: rentalOption[choosenVehicle]['payment_type']
                          .toString()
                          .split(',')
                          .toList()
                          .asMap()
                          .map((i, value) {
                            return MapEntry(
                                i,
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      choosenInPopUp = i;
                                    });
                                  },
                                  child: SizedBox(
                                    height: media.width * 0.106,
                                    width: media.width * 0.9,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: (rentalOption[choosenVehicle]
                                                          ['payment_type']
                                                      .toString()
                                                      .split(',')
                                                      .toList()[i] ==
                                                  'cash')
                                              ? Image.asset(
                                                  'assets/images/cash.png',
                                                  width: media.width * 0.05,
                                                  height: media.width * 0.05,
                                                  fit: BoxFit.contain,
                                                )
                                              : (rentalOption[choosenVehicle]
                                                              ['payment_type']
                                                          .toString()
                                                          .split(',')
                                                          .toList()[i] ==
                                                      'wallet')
                                                  ? Image.asset(
                                                      'assets/images/wallet.png',
                                                      width: media.width * 0.1,
                                                      height: media.width * 0.1,
                                                      fit: BoxFit.contain,
                                                    )
                                                  : (rentalOption[choosenVehicle]
                                                                  [
                                                                  'payment_type']
                                                              .toString()
                                                              .split(',')
                                                              .toList()[i] ==
                                                          'card')
                                                      ? Image.asset(
                                                          'assets/images/card.png',
                                                          width:
                                                              media.width * 0.1,
                                                          height:
                                                              media.width * 0.1,
                                                          fit: BoxFit.contain,
                                                        )
                                                      : (rentalOption[choosenVehicle]
                                                                      [
                                                                      'payment_type']
                                                                  .toString()
                                                                  .split(',')
                                                                  .toList()[i] ==
                                                              'upi')
                                                          ? Image.asset(
                                                              'assets/images/upi.png',
                                                              width:
                                                                  media.width *
                                                                      0.1,
                                                              height:
                                                                  media.width *
                                                                      0.1,
                                                              fit: BoxFit
                                                                  .contain,
                                                            )
                                                          : Container(),
                                        ),
                                        SizedBox(
                                          width: media.width * 0.02,
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: MyText(
                                            text: rentalOption[choosenVehicle]
                                                    ['payment_type']
                                                .toString()
                                                .split(',')
                                                .toList()[i],
                                            size: media.width * fourteen,
                                            color:
                                                // (choosenInPopUp == i)
                                                //     ? const Color(0xffFF0000)
                                                //     :
                                                (isDarkTheme == true)
                                                    ? Colors.white
                                                    : Colors.black,
                                          ),
                                        ),
                                        Expanded(
                                            child: Container(
                                          height: media.width * 0.05,
                                          width: media.width * 0.05,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                color: (isDarkTheme == true)
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                              shape: BoxShape.circle),
                                          child: Container(
                                            height: media.width * 0.03,
                                            width: media.width * 0.03,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: (choosenInPopUp == i)
                                                    // ? const Color(0xffFF0000)
                                                    ? theme
                                                    : page),
                                          ),
                                        ))
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
              onTap: widget.onTap,
              text: languages[choosenLanguage]['text_confirm'])
        ],
      ),
    );
  }
}

bool confirmRideLater = false;

class RideLaterBottomSheet extends StatefulWidget {
  final dynamic type;
  const RideLaterBottomSheet({super.key, this.type});

  @override
  State<RideLaterBottomSheet> createState() => _RideLaterBottomSheetState();
}

class _RideLaterBottomSheetState extends State<RideLaterBottomSheet> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Container(
      height: media.width * 1,
      width: media.width * 1,
      padding: EdgeInsets.all(media.width * 0.03),
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
          color: page,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(media.width * 0.05),
              topRight: Radius.circular(media.width * 0.05))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              MyText(
                text: languages[choosenLanguage]['text_choose_date'],
                size: media.width * eighteen,
                fontweight: FontWeight.w600,
              ),
              (confirmRideLater)
                  ? Row(
                      children: [
                        InkWell(
                          onTap: () {
                            confirmRideLater = false;

                            Navigator.pop(context);
                            valueNotifierBook.incrementNotifier();
                          },
                          child: MyText(
                            text: languages[choosenLanguage]['text_reset_now'],
                            size: media.width * fourteen,
                            color: Colors.blue,
                          ),
                        )
                      ],
                    )
                  : Container(),
              Container(
                height: media.width * 0.5,
                width: media.width * 0.9,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12), color: topBar),
                child: CupertinoDatePicker(
                    minimumDate: DateTime.now().add(Duration(
                        minutes: int.parse(userDetails[
                            'user_can_make_a_ride_after_x_miniutes']))),
                    initialDateTime: DateTime.now().add(Duration(
                        minutes: int.parse(userDetails[
                            'user_can_make_a_ride_after_x_miniutes']))),
                    maximumDate: DateTime.now().add(const Duration(days: 4)),
                    onDateTimeChanged: (val) {
                      // setState(() {
                      choosenDateTime = val;
                      // });
                    }),
              ),
            ],
          ),
          Container(
              padding: EdgeInsets.all(media.width * 0.05),
              child: Button(
                  onTap: () async {
                    // setState(() {
                    confirmRideLater = true;
                    // });
                    Navigator.pop(context);
                    valueNotifierBook.incrementNotifier();
                  },
                  text: languages[choosenLanguage]['text_confirm'])),
          if (!confirmRideLater && !rideLaterSuccess)
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: SizedBox(
                height: media.width * 0.06,
                width: media.width * 0.9,
                child: MyText(
                  textAlign: TextAlign.center,
                  text: languages[choosenLanguage]['text_cancel'],
                  size: media.width * fourteen,
                  color: verifyDeclined,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SuccessPopUp extends StatefulWidget {
  const SuccessPopUp({super.key});

  @override
  State<SuccessPopUp> createState() => _SuccessPopUpState();
}

class _SuccessPopUpState extends State<SuccessPopUp> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Container(
        height: media.width * 0.4,
        width: media.width * 1,
        padding: EdgeInsets.all(media.width * 0.05),
        decoration: BoxDecoration(
            color: page,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(media.width * 0.05),
                topRight: Radius.circular(media.width * 0.05))),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            MyText(
                text: languages[choosenLanguage]['text_rideLaterSuccess'],
                size: media.width * sixteen),
            Button(
                onTap: () {
                  addressList.removeWhere((element) => element.type == 'drop');
                  confirmRideLater = false;
                  ismulitipleride = false;
                  etaDetails.clear();
                  userRequestData.clear();
                  isOutStation = false;

                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const Maps()),
                      (route) => false);
                },
                text: languages[choosenLanguage]['text_confirm'])
          ],
        ));
  }
}

class VehicleInfoBottomSheet extends StatelessWidget {
  final int i;
  final double width;
  final bool isOneway;
  final dynamic type;
  const VehicleInfoBottomSheet({
    super.key,
    required this.i,
    required this.width,
    required this.isOneway,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width * 1,
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
          color: page,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(width * 0.08),
              topRight: Radius.circular(width * 0.08))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.network(
            (type != 1)
                ? etaDetails[i]['icon']
                : rentalOption[choosenVehicle]['icon'],
            width: width * 0.4,
          ),
          SizedBox(
            height: width * 0.02,
          ),
          MyText(
            text: (type != 1)
                ? etaDetails[i]['name']
                : '${rentalOption[choosenVehicle]['name']} (${etaDetails[rentalChoosenOption]['package_name']})',
            // : '${etaDetails[i]['typesWithPrice']['data'][0]['name']} (${etaDetails[i]['package_name']})',
            size: width * sixteen,
            fontweight: FontWeight.bold,
          ),
          SizedBox(
            height: width * 0.03,
          ),
          MyText(
              text: ((type != 1))
                  ? etaDetails[i]['short_description']
                  : rentalOption[choosenVehicle]['short_description'],
              size: width * fourteen),
          SizedBox(
            height: width * 0.05,
          ),
          (((etaDetails[i]['enable_bidding'] == false && isOneway) ||
                  (type == 1 || type == 2)))
              ? Container(
                  width: width * 0.9,
                  padding: EdgeInsets.all(width * 0.02),
                  decoration: BoxDecoration(
                      color: hintColor.withOpacity(0.1).withOpacity(0.1)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (type != 2)
                            MyText(text: 'Fare', size: width * fourteen),
                          if (type != 2)
                            (etaDetails[i]['has_discount'] != true)
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      (type != 1)
                                          ? Text(
                                              (etaDetails[i]['currency'] +
                                                  etaDetails[i]['total']
                                                      .toString()),
                                              style: GoogleFonts.notoSans(
                                                  fontSize: width * fourteen,
                                                  fontWeight: FontWeight.w700,
                                                  color: (choosenVehicle != i)
                                                      ? (isDarkTheme == true)
                                                          ? Colors.white
                                                          : textColor
                                                      : textColor),
                                            )
                                          : Text(
                                              etaDetails[i]['currency'] +
                                                  rentalOption[choosenVehicle]
                                                          ['fare_amount']
                                                      .toString(),
                                              style: GoogleFonts.notoSans(
                                                  fontSize: width * fourteen,
                                                  fontWeight: FontWeight.w700,
                                                  color: (choosenVehicle != i)
                                                      ? (isDarkTheme == true)
                                                          ? Colors.white
                                                          : textColor
                                                      : textColor),
                                            ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        etaDetails[i]['currency'] + ' ',
                                        style: GoogleFonts.notoSans(
                                            fontSize: width * fourteen,
                                            color: (choosenVehicle != i)
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            (type != 1)
                                                ? etaDetails[i]['total']
                                                    .toString()
                                                : rentalOption[choosenVehicle]
                                                        ['fare_amount']
                                                    .toString(),
                                            style: GoogleFonts.notoSans(
                                                fontSize: width * fourteen,
                                                color: (choosenVehicle != i)
                                                    ? (isDarkTheme == true)
                                                        ? Colors.white
                                                        : textColor
                                                    : Colors.black,
                                                fontWeight: FontWeight.w600,
                                                decoration:
                                                    TextDecoration.lineThrough),
                                          ),
                                          Text(
                                            (type != 1)
                                                ? etaDetails[i]
                                                        ['discounted_totel']
                                                    .toString()
                                                : rentalOption[choosenVehicle]
                                                        ['discounted_totel']
                                                    .toString(),
                                            style: GoogleFonts.notoSans(
                                                fontSize: width * fourteen,
                                                color: (choosenVehicle != i)
                                                    ? (isDarkTheme == true)
                                                        ? Colors.white
                                                        : textColor
                                                    : Colors.black,
                                                fontWeight: FontWeight.w700),
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                        ],
                      ),
                      SizedBox(
                        height: width * 0.02,
                      ),
                      FareBreakupDetails(
                          width: width,
                          heading: 'Time Price',
                          value: (type != 1)
                              ? '${etaDetails[i]['currency']} ${etaDetails[i]['price_per_time']} / min'
                              : '${etaDetails[choosenVehicle]['currency']} ${rentalOption[choosenVehicle]['time_price_per_min'].toString()} / min'),
                      SizedBox(
                        height: width * 0.02,
                      ),
                      FareBreakupDetails(
                          width: width,
                          heading: 'Distance Price',
                          value: (type != 1)
                              ? '${etaDetails[i]['currency']} ${etaDetails[i]['price_per_distance']} / ${etaDetails[i]['unit_in_words']}'
                              : '${etaDetails[choosenVehicle]['currency']} ${rentalOption[choosenVehicle]['distance_price_per_km'].toString()} / ${rentalOption[choosenVehicle]['unit_in_words']}'),
                      SizedBox(
                        height: width * 0.02,
                      ),
                      FareBreakupDetails(
                          width: width,
                          heading: 'Payment Types',
                          value: (type != 1)
                              ? etaDetails[i]['payment_type'].toString()
                              : rentalOption[choosenVehicle]['payment_type']
                                  .toString()),
                    ],
                  ),
                )
              : Container(),
          SizedBox(
            height: width * 0.05,
          ),
          Row(
            children: [
              Expanded(
                child: MyText(
                    text: ((type != 1))
                        ? etaDetails[i]['description']
                        : rentalOption[choosenVehicle]['description'],
                    color: textColor.withOpacity(0.6),
                    size: width * fourteen),
              )
            ],
          )
        ],
      ),
    );
  }
}

class FareBreakupDetails extends StatelessWidget {
  final double width;
  final String heading;
  final String value;
  const FareBreakupDetails(
      {super.key,
      required this.width,
      required this.heading,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        MyText(text: heading, size: width * fourteen),
        MyText(
            text: value.toString(),
            fontweight: FontWeight.bold,
            size: width * fourteen)
      ],
    );
  }
}

bool choosePets = false;
bool chooseLuggages = false;

class ChoosePreferencesContainer extends StatefulWidget {
  final dynamic type;
  final dynamic onTap;
  const ChoosePreferencesContainer({super.key, this.type, required this.onTap});

  @override
  State<ChoosePreferencesContainer> createState() =>
      _ChoosePreferencesContainerState();
}

class _ChoosePreferencesContainerState
    extends State<ChoosePreferencesContainer> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Container(
      height: media.width * 0.6,
      width: media.width * 1,
      padding: EdgeInsets.all(media.width * 0.05),
      decoration: BoxDecoration(
          color: page,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(media.width * 0.05),
              topRight: Radius.circular(media.width * 0.05))),
      child: Column(
        children: [
          MyText(
            text: languages[choosenLanguage]['text_choose_preference'],
            size: media.width * sixteen,
            fontweight: FontWeight.bold,
          ),
          SizedBox(
            height: media.width * 0.03,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  (userDetails['enable_pet_preference_for_user'] != '1')
                      ? Container()
                      : Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (choosePets == false) {
                                    choosePets = true;
                                  } else {
                                    choosePets = false;
                                  }
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.pets,
                                        size: media.width * 0.05,
                                        color: (choosePets == true)
                                            ? theme
                                            : (isDarkTheme)
                                                ? Colors.white
                                                : Colors.black,
                                      ),
                                      SizedBox(
                                        width: media.width * 0.025,
                                      ),
                                      MyText(
                                        text: languages[choosenLanguage]
                                            ['text_pets'],
                                        size: media.width * sixteen,
                                        fontweight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: media.width * 0.05,
                                    width: media.width * 0.05,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: theme),
                                        color: (choosePets == true)
                                            ? theme
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(2.5)),
                                    child: Icon(
                                      Icons.done,
                                      size: media.width * 0.035,
                                      color: (choosePets == true)
                                          ? topBar
                                          : Colors.transparent,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(
                              height: media.width * 0.05,
                            ),
                          ],
                        ),
                  (userDetails['enable_luggage_preference_for_user'] != '1')
                      ? Container()
                      : Column(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (chooseLuggages == false) {
                                    chooseLuggages = true;
                                  } else {
                                    chooseLuggages = false;
                                  }
                                });
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: media.width * 0.05,
                                        width: media.width * 0.05,
                                        child: Image.asset(
                                          'assets/images/luggages.png',
                                          color: (chooseLuggages == true)
                                              ? theme
                                              : (isDarkTheme)
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                      SizedBox(
                                        width: media.width * 0.025,
                                      ),
                                      MyText(
                                        text: languages[choosenLanguage]
                                            ['text_luggages'],
                                        size: media.width * sixteen,
                                        fontweight: FontWeight.w600,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: media.width * 0.05,
                                    width: media.width * 0.05,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: theme),
                                        color: (chooseLuggages == true)
                                            ? theme
                                            : Colors.transparent,
                                        borderRadius:
                                            BorderRadius.circular(2.5)),
                                    child: Icon(
                                      Icons.done,
                                      size: media.width * 0.035,
                                      color: (chooseLuggages == true)
                                          ? topBar
                                          : Colors.transparent,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
          Button(
              onTap: widget.onTap,
              text: languages[choosenLanguage]['text_confirm'])
        ],
      ),
    );
  }
}
