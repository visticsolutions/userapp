import 'package:flutter/material.dart';
import 'package:flutter_user/functions/functions.dart';
import 'package:flutter_user/pages/NavigatorPages/historyoutstationdetails.dart';
import 'package:flutter_user/pages/loadingPage/loading.dart';
import 'package:flutter_user/pages/login/login.dart';
import 'package:flutter_user/pages/onTripPage/booking_confirmation.dart';
import 'package:flutter_user/styles/styles.dart';
import 'package:flutter_user/translations/translation.dart';
import 'package:flutter_user/widgets/widgets.dart';

class OutStationRides extends StatefulWidget {
  const OutStationRides({super.key});

  @override
  State<OutStationRides> createState() => _OutStationRidesState();
}

class _OutStationRidesState extends State<OutStationRides> {
  navigate() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => BookingConfirmation()));
  }

  naviagteridewithoutdestini() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => BookingConfirmation(
                  type: 2,
                )));
  }

  naviagterental() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => BookingConfirmation(
                  type: 1,
                )));
  }

  dynamic _shimmer;

  @override
  void initState() {
    _isLoading = false;
    outstationfun();
    historyFiltter = '';
    _shimmer = AnimationController.unbounded(vsync: MyTickerProvider())
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
    super.initState();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  navigateLogout() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false);
    });
  }

//get history
  outstationfun() async {
    if (mounted) {
      setState(() {
        outStationList.clear();
        for (var i = 0; i < 10; i++) {
          outStationList.add({});
        }
      });
    }
    var val = await outStationListFun();
    if (val == 'logout') {
      navigateLogout();
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: RefreshIndicator(
        color: Colors.blue,
        onRefresh: () async {
          setState(() {
            _isLoading = true;
            outStationList.clear();
          });
          outstationfun();
        },
        child: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: SizedBox(
            height: media.height * 1,
            width: media.width * 1,
            child: Stack(
              children: [
                Column(
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
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child:
                                  Icon(Icons.arrow_back_ios, color: textColor)),
                          Expanded(
                            child: MyText(
                              textAlign: TextAlign.center,
                              text: languages[choosenLanguage]
                                  ['text_outstation'],
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
                        padding: const EdgeInsets.all(1),
                        width: media.width * 1,
                        color: (outStationList.isEmpty)
                            ? (!isDarkTheme)
                                ? Colors.white
                                : Colors.black
                            : (isDarkTheme)
                                ? Colors.grey
                                : Colors.grey.withOpacity(0.2),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              SizedBox(
                                height: media.width * 0.03,
                              ),
                              (outStationList.isNotEmpty)
                                  ? Column(
                                      children: outStationList
                                          .asMap()
                                          .map((i, value) {
                                            return MapEntry(
                                                i,
                                                (outStationList[i].isEmpty)
                                                    ? AnimatedBuilder(
                                                        animation: _shimmer,
                                                        builder:
                                                            (context, widget) {
                                                          return ShaderMask(
                                                              blendMode:
                                                                  BlendMode
                                                                      .srcATop,
                                                              shaderCallback:
                                                                  (bounds) {
                                                                return LinearGradient(
                                                                        colors:
                                                                            shaderColor,
                                                                        stops:
                                                                            shaderStops,
                                                                        begin:
                                                                            shaderBegin,
                                                                        end:
                                                                            shaderEnd,
                                                                        tileMode: TileMode
                                                                            .clamp,
                                                                        transform: SlidingGradientTransform(
                                                                            slidePercent: _shimmer
                                                                                .value))
                                                                    .createShader(
                                                                        bounds);
                                                              },
                                                              child: Container(
                                                                margin: EdgeInsets
                                                                    .all(media
                                                                            .width *
                                                                        0.03),
                                                                padding: EdgeInsets
                                                                    .all(media
                                                                            .width *
                                                                        0.03),
                                                                decoration: BoxDecoration(
                                                                    color: page,
                                                                    borderRadius:
                                                                        BorderRadius.circular(media.width *
                                                                            0.02)),
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              media.width * 0.05,
                                                                          width:
                                                                              media.width * 0.15,
                                                                          color:
                                                                              hintColor.withOpacity(0.5),
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              media.width * 0.05,
                                                                          width:
                                                                              media.width * 0.15,
                                                                          color:
                                                                              hintColor.withOpacity(0.5),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height: media
                                                                              .width *
                                                                          0.02,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              media.width * 0.05,
                                                                          width:
                                                                              media.width * 0.2,
                                                                          color:
                                                                              hintColor.withOpacity(0.5),
                                                                        ),
                                                                        Container(
                                                                          height:
                                                                              media.width * 0.05,
                                                                          width:
                                                                              media.width * 0.2,
                                                                          color:
                                                                              hintColor.withOpacity(0.5),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height: media
                                                                              .width *
                                                                          0.02,
                                                                    ),
                                                                    const MySeparator(),
                                                                    // Container(
                                                                    //   height: 1,
                                                                    //   width: media.width * 0.8,
                                                                    //   color: hintColor,
                                                                    // ),
                                                                    SizedBox(
                                                                      height: media
                                                                              .width *
                                                                          0.02,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              media.width * 0.05,
                                                                          width:
                                                                              media.width * 0.05,
                                                                          decoration: BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: hintColor.withOpacity(0.5)),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              media.width * 0.05,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                media.width * 0.05,
                                                                            color:
                                                                                hintColor.withOpacity(0.5),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height: media
                                                                              .width *
                                                                          0.03,
                                                                    ),

                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              media.width * 0.05,
                                                                          width:
                                                                              media.width * 0.05,
                                                                          decoration: BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: hintColor.withOpacity(0.5)),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              media.width * 0.05,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                media.width * 0.05,
                                                                            color:
                                                                                hintColor.withOpacity(0.5),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ));
                                                        })
                                                    : Column(
                                                        children: [
                                                          InkWell(
                                                            onTap: () async {
                                                              var result = await Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (context) => OutStationDetails(
                                                                            requestId:
                                                                                outStationList[i]['id'],
                                                                            i: i,
                                                                          )));
                                                              if (result) {
                                                                setState(() {});
                                                              }
                                                              // }
                                                            },
                                                            child: Container(
                                                              margin: EdgeInsets.only(
                                                                  top: 0,
                                                                  bottom: media
                                                                          .width *
                                                                      0.05,
                                                                  left: media
                                                                          .width *
                                                                      0.05,
                                                                  right: media
                                                                          .width *
                                                                      0.05),
                                                              width:
                                                                  media.width *
                                                                      0.95,
                                                              padding: EdgeInsets
                                                                  .all(media
                                                                          .width *
                                                                      0.04),
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          media.width *
                                                                              0.03),
                                                                  color: page),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      MyText(
                                                                        text: (outStationList[i]['is_round_trip'] ==
                                                                                1)
                                                                            ? languages[choosenLanguage]['text_round_trip']
                                                                            : languages[choosenLanguage]['text_one_way_trip'],
                                                                        size: media.width *
                                                                            sixteen,
                                                                        color: Colors
                                                                            .orange,
                                                                        fontweight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Icon(
                                                                            Icons.alarm_rounded,
                                                                            size:
                                                                                media.width * fourteen,
                                                                            color:
                                                                                hintColor,
                                                                          ),
                                                                          MyText(
                                                                            text:
                                                                                outStationList[i]['trip_start_time'],
                                                                            size:
                                                                                media.width * twelve,
                                                                            color:
                                                                                hintColor,
                                                                            fontweight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.02,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Row(
                                                                        children: [
                                                                          (outStationList[i]['driverDetail'] != null)
                                                                              ? Container(
                                                                                  height: media.width * 0.1,
                                                                                  width: media.width * 0.1,
                                                                                  decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(outStationList[i]['driverDetail']['data']['profile_picture']), fit: BoxFit.cover)),
                                                                                )
                                                                              : Container(
                                                                                  height: media.width * 0.1,
                                                                                  width: media.width * 0.1,
                                                                                  decoration: const BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage('assets/images/driver.png'), fit: BoxFit.cover)),
                                                                                ),
                                                                          SizedBox(
                                                                            width:
                                                                                media.width * 0.03,
                                                                          ),
                                                                          (outStationList[i]['driverDetail'] != null)
                                                                              ? Icon(
                                                                                  Icons.done,
                                                                                  size: media.width * twenty,
                                                                                  color: online,
                                                                                )
                                                                              : MyText(text: '---', size: media.width * twenty)
                                                                        ],
                                                                      ),
                                                                      MyText(
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        text:
                                                                            '${outStationList[i]['payment_type_string'].toString()}  ${userDetails['currency_symbol']} ${(outStationList[i]['is_bid_ride'] == 1) ? (outStationList[i]['driverDetail'] != null) ? outStationList[i]['accepted_ride_fare'].toString() : outStationList[i]['offerred_ride_fare'].toString() : outStationList[i]['request_eta_amount'].toString()}',
                                                                        size: media.width *
                                                                            fourteen,
                                                                        fontweight:
                                                                            FontWeight.w600,
                                                                        maxLines:
                                                                            1,
                                                                      )
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.02,
                                                                  ),
                                                                  const MySeparator(),
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.02,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Container(
                                                                        height: media.width *
                                                                            0.05,
                                                                        width: media.width *
                                                                            0.05,
                                                                        alignment:
                                                                            Alignment.center,
                                                                        decoration: BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            color: Colors.green.withOpacity(0.4)),
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              media.width * 0.025,
                                                                          width:
                                                                              media.width * 0.025,
                                                                          decoration: const BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: Colors.green),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: media.width *
                                                                            0.03,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            MyText(
                                                                          text: outStationList[i]
                                                                              [
                                                                              'pick_address'],
                                                                          maxLines:
                                                                              1,
                                                                          size: media.width *
                                                                              twelve,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.03,
                                                                  ),
                                                                  if (outStationList[
                                                                              i]
                                                                          [
                                                                          'drop_address'] !=
                                                                      null)
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              media.width * 0.06,
                                                                          width:
                                                                              media.width * 0.06,
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Icon(
                                                                            Icons.location_on,
                                                                            color:
                                                                                const Color(0xFFFF0000),
                                                                            size:
                                                                                media.width * eighteen,
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              media.width * 0.03,
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              MyText(
                                                                            text:
                                                                                outStationList[i]['drop_address'],
                                                                            maxLines:
                                                                                1,
                                                                            size:
                                                                                media.width * twelve,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ));
                                          })
                                          .values
                                          .toList(),
                                    )
                                  : (_isLoading == false)
                                      ? SizedBox(
                                          height: media.height * 0.6,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: media.width * 0.2,
                                              ),
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
                                                        ['text_noDataFound'],
                                                    textAlign: TextAlign.center,
                                                    fontweight: FontWeight.w800,
                                                    size:
                                                        media.width * sixteen),
                                              ),
                                            ],
                                          ),
                                        )
                                      : Container()
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                //loader
                (_isLoading == true)
                    ? const Positioned(top: 0, child: Loading())
                    : Container()
              ],
            ),
          ),
        ),
      ),
    );
  }
}
