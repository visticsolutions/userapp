import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';

class OutStationDetails extends StatefulWidget {
  final dynamic requestId;
  final dynamic i;
  const OutStationDetails({super.key, this.requestId, this.i});

  @override
  State<OutStationDetails> createState() => _OutStationDetailsState();
}

class _OutStationDetailsState extends State<OutStationDetails> {
  bool _isLoading = false;
  TextEditingController updateAmount = TextEditingController();
  List driverBck = [];
  bool _cancelRide = false;
  List _tripStops = [];

  navigate() {
    Navigator.pop(context, true);
  }

  @override
  void initState() {
    _isLoading = false;
    _tripStops = outStationList[widget.i]['requestStops']['data'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: StreamBuilder<Object>(
          stream: FirebaseDatabase.instance
              .ref()
              .child('bid-meta/${widget.requestId}')
              .onValue
              .asBroadcastStream(),
          builder: (context, AsyncSnapshot event) {
            List driverList = [];
            Map rideList = {};
            // rideList = event.data!.snapshot;
            if (event.data != null) {
              DataSnapshot snapshots = event.data!.snapshot;
              if (snapshots.value != null) {
                rideList = jsonDecode(jsonEncode(snapshots.value));
                if (rideList['drivers'] != null) {
                  Map driver = rideList['drivers'];
                  driver.forEach((key, value) {
                    if (driver[key]['is_rejected'] == 'none') {
                      driverList.add(value);
                    }
                  });

                  if (driverList.isNotEmpty) {
                    if (driverBck.isNotEmpty &&
                        driverList[0]['user_id'] != driverBck[0]['user_id']) {
                      driverBck = driverList;
                    } else if (driverBck.isEmpty) {
                      driverBck = driverList;
                    }
                  } else {
                    driverBck = driverList;
                  }
                } else {
                  driverBck = driverList;
                }
              }
            }

            return Stack(
              children: [
                if (outStationList.isNotEmpty)
                  Container(
                    width: media.width * 1,
                    height: media.height * 1,
                    color: page,
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.fromLTRB(
                              media.width * 0.05,
                              media.width * 0.05 +
                                  MediaQuery.of(context).padding.top,
                              media.width * 0.05,
                              media.width * 0.05),
                          color: page,
                          child: Row(
                            children: [
                              InkWell(
                                  onTap: () async {
                                    Navigator.pop(context, true);
                                  },
                                  child: Icon(Icons.arrow_back_ios,
                                      color: textColor)),
                              Expanded(
                                child: MyText(
                                  textAlign: TextAlign.center,
                                  text: (outStationList[widget.i]
                                              ['driverDetail'] !=
                                          null)
                                      ? languages[choosenLanguage]
                                          ['text_outstation']
                                      : languages[choosenLanguage]
                                          ['text_bidded_drivers'],
                                  size: media.width * twenty,
                                  maxLines: 1,
                                  fontweight: FontWeight.w600,
                                ),
                              ),
                              Container()
                            ],
                          ),
                        ),
                        Expanded(
                            child: (outStationList[widget.i]['driverDetail'] !=
                                    null)
                                ? Container(
                                    padding: EdgeInsets.all(media.width * 0.05),
                                    width: media.width * 1,
                                    color: Colors.grey.withOpacity(0.5),
                                    child: Container(
                                      padding:
                                          EdgeInsets.all(media.width * 0.05),
                                      color: page,
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                MyText(
                                                  text: outStationList[widget.i]
                                                      ['trip_start_time'],
                                                  size: media.width * twelve,
                                                  fontweight: FontWeight.w600,
                                                ),
                                                (outStationList[widget.i]
                                                            ['is_round_trip'] ==
                                                        1)
                                                    ? MyText(
                                                        text:
                                                            ' TO ${outStationList[widget.i]['return_time']}',
                                                        size: media.width *
                                                            twelve,
                                                        fontweight:
                                                            FontWeight.w600,
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                            SizedBox(
                                              height: media.width * 0.02,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                MyText(
                                                  text: outStationList[widget.i]
                                                      ['request_number'],
                                                  size: media.width * twelve,
                                                  color: hintColor,
                                                ),
                                                MyText(
                                                  text: (outStationList[
                                                                  widget.i][
                                                              'is_round_trip'] ==
                                                          1)
                                                      ? languages[
                                                              choosenLanguage]
                                                          ['text_round_trip']
                                                      : languages[
                                                              choosenLanguage]
                                                          ['text_one_way_trip'],
                                                  size: media.width * sixteen,
                                                  color: Colors.orange,
                                                  fontweight: FontWeight.w600,
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: media.width * 0.02,
                                            ),
                                            const MySeparator(),
                                            SizedBox(
                                              height: media.width * 0.02,
                                            ),
                                            Column(
                                              children: [
                                                SizedBox(
                                                  height: media.width * 0.02,
                                                ),
                                                Row(
                                                  children: [
                                                    SizedBox(
                                                      width: media.width * 0.7,
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height:
                                                                media.width *
                                                                    0.1,
                                                            width: media.width *
                                                                0.1,
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                image: DecorationImage(
                                                                    image: NetworkImage(outStationList[widget.i]['driverDetail']
                                                                            [
                                                                            'data']
                                                                        [
                                                                        'profile_picture']),
                                                                    fit: BoxFit
                                                                        .cover)),
                                                          ),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                MyText(
                                                                    text: outStationList[widget.i]['driverDetail']['data']
                                                                            [
                                                                            'name']
                                                                        .toString(),
                                                                    size: media
                                                                            .width *
                                                                        sixteen),
                                                                Row(
                                                                  children: [
                                                                    MyText(
                                                                      text: outStationList[widget.i]
                                                                              [
                                                                              'vehicle_type_name']
                                                                          .toString(),
                                                                      size: media
                                                                              .width *
                                                                          twelve,
                                                                      fontweight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color:
                                                                          textColor,
                                                                    ),
                                                                    Container(
                                                                      height: media
                                                                              .width *
                                                                          0.05,
                                                                      width: 1,
                                                                      color:
                                                                          underline,
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              5,
                                                                          right:
                                                                              5),
                                                                    ),
                                                                    MyText(
                                                                      text: outStationList[widget.i]
                                                                              [
                                                                              'car_number']
                                                                          .toString(),
                                                                      size: media
                                                                              .width *
                                                                          twelve,
                                                                      fontweight:
                                                                          FontWeight
                                                                              .w600,
                                                                      color:
                                                                          textColor,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    MyText(
                                                      text: outStationList[
                                                                  widget.i][
                                                              'ride_user_rating']
                                                          .toString(),
                                                      size: media.width *
                                                          eighteen,
                                                      fontweight:
                                                          FontWeight.w600,
                                                      color: textColor,
                                                    ),
                                                    Icon(
                                                      Icons.star,
                                                      size:
                                                          media.width * twenty,
                                                      color: Colors.yellow[600],
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.02,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              media.width * 0.1,
                                                        ),
                                                        MyText(
                                                            text: outStationList[widget.i]
                                                                            [
                                                                            'driverDetail']
                                                                        ['data']
                                                                    ['mobile']
                                                                .toString(),
                                                            fontweight:
                                                                FontWeight.bold,
                                                            size: media.width *
                                                                fourteen),
                                                      ],
                                                    ),
                                                    InkWell(
                                                      onTap: () {
                                                        makingPhoneCall(
                                                            outStationList[
                                                                        widget
                                                                            .i]
                                                                    [
                                                                    'driverDetail']
                                                                [
                                                                'data']['mobile']);
                                                      },
                                                      child: Icon(
                                                        Icons.call,
                                                        color: textColor,
                                                        size: media.width *
                                                            twentyfour,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.02,
                                                ),
                                                const MySeparator(),
                                                SizedBox(
                                                  height: media.width * 0.04,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height:
                                                          media.width * 0.05,
                                                      width: media.width * 0.05,
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Colors.green
                                                              .withOpacity(
                                                                  0.4)),
                                                      child: Container(
                                                        height:
                                                            media.width * 0.025,
                                                        width:
                                                            media.width * 0.025,
                                                        decoration:
                                                            const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Colors
                                                                    .green),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: media.width * 0.03,
                                                    ),
                                                    Expanded(
                                                      child: MyText(
                                                        text: outStationList[
                                                                widget.i]
                                                            ['pick_address'],
                                                        maxLines: 1,
                                                        size: media.width *
                                                            twelve,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.03,
                                                ),
                                                Column(
                                                  children: _tripStops
                                                      .asMap()
                                                      .map((i, value) {
                                                        return MapEntry(
                                                            i,
                                                            (i <
                                                                    _tripStops
                                                                            .length -
                                                                        1)
                                                                ? Column(
                                                                    children: [
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                media.width * 0.06,
                                                                            width:
                                                                                media.width * 0.06,
                                                                            alignment:
                                                                                Alignment.center,
                                                                            decoration:
                                                                                BoxDecoration(shape: BoxShape.circle, color: Colors.red.withOpacity(0.3)),
                                                                            child:
                                                                                MyText(
                                                                              text: (i + 1).toString(),
                                                                              size: media.width * twelve,
                                                                              maxLines: 1,
                                                                              color: verifyDeclined,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                media.width * 0.05,
                                                                          ),
                                                                          Expanded(
                                                                            child:
                                                                                MyText(
                                                                              text: _tripStops[i]['address'],
                                                                              size: media.width * twelve,
                                                                              // maxLines: 1,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                        height: media.width *
                                                                            0.02,
                                                                      ),
                                                                    ],
                                                                  )
                                                                : Container());
                                                      })
                                                      .values
                                                      .toList(),
                                                ),
                                                if (outStationList[widget.i]
                                                        ['drop_address'] !=
                                                    null)
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        height:
                                                            media.width * 0.06,
                                                        width:
                                                            media.width * 0.06,
                                                        alignment:
                                                            Alignment.center,
                                                        child: Icon(
                                                          Icons.location_on,
                                                          color: const Color(
                                                              0xFFFF0000),
                                                          size: media.width *
                                                              eighteen,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.03,
                                                      ),
                                                      Expanded(
                                                        child: MyText(
                                                          text: outStationList[
                                                                  widget.i]
                                                              ['drop_address'],
                                                          maxLines: 1,
                                                          size: media.width *
                                                              twelve,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                SizedBox(
                                                  height: media.width * 0.02,
                                                ),
                                                (outStationList[widget.i]
                                                            ['goods_type'] !=
                                                        '-')
                                                    ? Row(
                                                        children: [
                                                          Expanded(
                                                            child: MyText(
                                                              maxLines: 1,
                                                              text:
                                                                  '${languages[choosenLanguage]['text_goods_type']}  : ${outStationList[widget.i]['goods_type']}',
                                                              size:
                                                                  media.width *
                                                                      twelve,
                                                              color:
                                                                  verifyDeclined,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Container(),
                                                SizedBox(
                                                  height: media.width * 0.1,
                                                ),
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          media.height * 0.02,
                                                    ),
                                                    MyText(
                                                      text: (outStationList[
                                                                      widget.i][
                                                                  'payment_opt'] ==
                                                              '1')
                                                          ? languages[choosenLanguage]
                                                              ['text_cash']
                                                          : (outStationList[widget.i][
                                                                      'payment_opt'] ==
                                                                  '2')
                                                              ? languages[choosenLanguage][
                                                                  'text_wallet']
                                                              : (outStationList[widget.i][
                                                                          'payment_opt'] ==
                                                                      '0')
                                                                  ? languages[
                                                                          choosenLanguage]
                                                                      ['text_card']
                                                                  : '',
                                                      size: media.width *
                                                          twentyeight,
                                                      fontweight:
                                                          FontWeight.w600,
                                                      color: textColor,
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          media.width * 0.03,
                                                    ),
                                                    MyText(
                                                      text: outStationList[
                                                                  widget.i][
                                                              'requested_currency_symbol'] +
                                                          ' ' +
                                                          outStationList[
                                                                      widget.i][
                                                                  'accepted_ride_fare']
                                                              .toString(),
                                                      size: media.width *
                                                          twentysix,
                                                      fontweight:
                                                          FontWeight.w600,
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: EdgeInsets.all(media.width * 0.05),
                                    width: media.width * 1,
                                    color: (driverList.isEmpty)
                                        ? (!isDarkTheme)
                                            ? Colors.white
                                            : Colors.black
                                        : (isDarkTheme)
                                            ? Colors.grey
                                            : Colors.grey.withOpacity(0.2),
                                    child: (driverList.isNotEmpty)
                                        ? SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(
                                                      media.width * 0.02),
                                                  decoration: BoxDecoration(
                                                      color: page,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              media.width *
                                                                  0.02)),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      MyText(
                                                        text: languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_my_bid_amount'],
                                                        color: textColor,
                                                        fontweight:
                                                            FontWeight.w600,
                                                        size: media.width *
                                                            fourteen,
                                                      ),
                                                      MyText(
                                                        text: rideList[
                                                                'currency'] +
                                                            rideList['price']
                                                                .toString(),
                                                        color: textColor,
                                                        fontweight:
                                                            FontWeight.w600,
                                                        size: media.width *
                                                            fourteen,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.03,
                                                ),
                                                Column(
                                                    children: driverList
                                                        .asMap()
                                                        .map((key, value) {
                                                          return MapEntry(
                                                              key,
                                                              ValueListenableBuilder(
                                                                  valueListenable:
                                                                      valueNotifierTimer
                                                                          .value,
                                                                  builder:
                                                                      (context,
                                                                          value,
                                                                          child) {
                                                                    if (driverList
                                                                        .isNotEmpty) {
                                                                      audioPlayers
                                                                          .play(
                                                                              AssetSource(audio));
                                                                    }
                                                                    return Container(
                                                                      margin: EdgeInsets.only(
                                                                          bottom:
                                                                              media.width * 0.025),
                                                                      decoration: BoxDecoration(
                                                                          // borderRadius: BorderRadius.circular(10),
                                                                          color: page,
                                                                          borderRadius: BorderRadius.circular(media.width * 0.02)),
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Container(
                                                                            padding:
                                                                                EdgeInsets.all(media.width * 0.05),
                                                                            child:
                                                                                Column(
                                                                              children: [
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Container(
                                                                                      width: media.width * 0.1,
                                                                                      height: media.width * 0.1,
                                                                                      decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(driverList[key]['driver_img']), fit: BoxFit.cover)),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: media.width * 0.05,
                                                                                    ),
                                                                                    Column(
                                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                                      children: [
                                                                                        SizedBox(
                                                                                          width: media.width * 0.4,
                                                                                          child: MyText(
                                                                                            text: driverList[key]['driver_name'],
                                                                                            size: media.width * fourteen,
                                                                                            fontweight: FontWeight.w600,
                                                                                            maxLines: 1,
                                                                                            textAlign: TextAlign.left,
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          height: media.width * 0.025,
                                                                                        ),
                                                                                        SizedBox(
                                                                                            width: media.width * 0.4,
                                                                                            child: MyText(
                                                                                              text: '${driverList[key]['vehicle_make']} ${driverList[key]['vehicle_model']}',
                                                                                              size: media.width * fourteen,
                                                                                              color: textColor,
                                                                                              fontweight: FontWeight.w600,
                                                                                              textAlign: TextAlign.left,
                                                                                              maxLines: 1,
                                                                                            )),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: media.width * 0.05,
                                                                                    ),
                                                                                    SizedBox(
                                                                                        width: media.width * 0.15,
                                                                                        child: MyText(
                                                                                          text: rideList['currency'] + driverList[key]['price'],
                                                                                          size: media.width * fourteen,
                                                                                          fontweight: FontWeight.w600,
                                                                                          textAlign: TextAlign.center,
                                                                                          maxLines: 1,
                                                                                        ))
                                                                                  ],
                                                                                ),
                                                                                SizedBox(
                                                                                  height: media.width * 0.05,
                                                                                ),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Button(
                                                                                      onTap: () async {
                                                                                        setState(() {
                                                                                          _isLoading = true;
                                                                                        });
                                                                                        var val = await acceptRequest(jsonEncode({
                                                                                          'driver_id': driverList[key]['driver_id'],
                                                                                          'request_id': widget.requestId,
                                                                                          'accepted_ride_fare': driverList[key]['price'].toString(),
                                                                                          'offerred_ride_fare': rideList['price'],
                                                                                        }));
                                                                                        if (val == 'success') {
                                                                                          await FirebaseDatabase.instance.ref().child('bid-meta/${widget.requestId}').remove();

                                                                                          var res = await outStationListFun();
                                                                                          if (res == 'success') {
                                                                                            setState(() {
                                                                                              _isLoading = false;
                                                                                            });
                                                                                            navigate();
                                                                                          }

                                                                                          // ignore: use_build_context_synchronously
                                                                                        }
                                                                                      },
                                                                                      color: online,
                                                                                      borcolor: online,
                                                                                      textcolor: page,
                                                                                      text: languages[choosenLanguage]['text_accept'],
                                                                                      width: media.width * 0.35,
                                                                                    ),
                                                                                    // SizedBox(height: media.width*0.025,),
                                                                                    Button(
                                                                                      onTap: () async {
                                                                                        setState(() {
                                                                                          _isLoading = true;
                                                                                        });
                                                                                        await FirebaseDatabase.instance.ref().child('bid-meta/${widget.requestId}/drivers/driver_${driverList[key]["driver_id"]}').update({
                                                                                          "is_rejected": 'by_user'
                                                                                        });
                                                                                        setState(() {
                                                                                          _isLoading = false;
                                                                                        });
                                                                                      },
                                                                                      color: verifyDeclined,
                                                                                      borcolor: verifyDeclined,
                                                                                      textcolor: page,
                                                                                      text: languages[choosenLanguage]['text_decline'],
                                                                                      width: media.width * 0.35,
                                                                                    )
                                                                                  ],
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }));
                                                        })
                                                        .values
                                                        .toList()),
                                              ],
                                            ),
                                          )
                                        : SizedBox(
                                            height: media.height * 0.6,
                                            child: Column(children: [
                                              Container(
                                                alignment: Alignment.center,
                                                height: media.width * 0.6,
                                                width: media.width * 0.6,
                                                decoration: BoxDecoration(
                                                    image: DecorationImage(
                                                        image: AssetImage((isDarkTheme)
                                                            ? 'assets/images/nodatafounddark.gif'
                                                            : 'assets/images/nodatafound.gif'),
                                                        fit: BoxFit.contain)),
                                              ),
                                              SizedBox(
                                                width: media.width * 0.6,
                                                child: MyText(
                                                    text: languages[
                                                            choosenLanguage]
                                                        ['text_no_bids'],
                                                    textAlign: TextAlign.center,
                                                    fontweight: FontWeight.w800,
                                                    size:
                                                        media.width * sixteen),
                                              ),
                                            ]),
                                          ),
                                  )),
                        Container(
                          margin: EdgeInsets.all(media.width * 0.05),
                          color: page,
                          child: Button(
                              onTap: () {
                                setState(() {
                                  _cancelRide = true;
                                });
                              },
                              text: languages[choosenLanguage]
                                  ['text_cancel_ride']),
                        )
                      ],
                    ),
                  ),

                (_cancelRide == true)
                    ? Positioned(
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
                                            shape: BoxShape.circle,
                                            color: page),
                                        child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                _cancelRide = false;
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
                                    borderRadius: BorderRadius.circular(12),
                                    color: page),
                                child: Column(
                                  children: [
                                    MyText(
                                      text: languages[choosenLanguage]
                                          ['text_ridecancel'],
                                      size: media.width * eighteen,
                                    ),
                                    SizedBox(
                                      height: media.width * 0.05,
                                    ),
                                    Button(
                                        onTap: () async {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          var val = await cancelLaterRequest(
                                              widget.requestId);
                                          if (val == 'success') {
                                            var res = await outStationListFun();
                                            if (res == 'success') {
                                              var result =
                                                  await getUserDetails();
                                              if (result == true) {
                                                setState(() {
                                                  _cancelRide = false;
                                                  _isLoading = false;
                                                });
                                                navigate();
                                              }
                                            }
                                            // ignore: use_build_context_synchronously
                                          }
                                        },
                                        text: languages[choosenLanguage]
                                            ['text_cancel_ride'])
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    : Container(),
                //loader
                (_isLoading == true)
                    ? const Positioned(top: 0, child: Loading())
                    : Container(),
              ],
            );
          }),
    );
  }
}
