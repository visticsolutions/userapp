import 'package:flutter/material.dart';
import 'package:flutter_user/pages/loadingPage/loading.dart';
import 'package:flutter_user/pages/onTripPage/booking_confirmation.dart';
import 'package:flutter_user/pages/onTripPage/map_page.dart';
import 'package:flutter_user/styles/styles.dart';
import 'package:flutter_user/translations/translation.dart';
import 'package:flutter_user/widgets/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../functions/functions.dart';

class OnGoingRides extends StatefulWidget {
  const OnGoingRides({super.key});

  @override
  State<OnGoingRides> createState() => _OnGoingRidesState();
}

class _OnGoingRidesState extends State<OnGoingRides> {
  dynamic _shimmer;
  bool _isLoading = false;
  final List _tripStops = [];
  @override
  void initState() {
    getHistoryData();
    _shimmer = AnimationController.unbounded(vsync: MyTickerProvider())
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
    super.initState();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

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

  getHistoryData() async {
    setState(() {
      // _isLoading = false;
      myHistoryPage.clear();
      myHistory.clear();
    });
    for (var i = 0; i < 10; i++) {
      myHistory.add({});
    }
    historyFiltter = 'on_trip=1';
    var val = await getHistory();
    if (val == 'success' && myHistory.isNotEmpty) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Material(
      child: RefreshIndicator(
        color: Colors.blue,
        onRefresh: () async {
          setState(() {
            _isLoading = true;
            myHistoryPage.clear();
            myHistory.clear();
          });
          historyFiltter = 'on_trip=1';
          var val = await getHistory();
          if (val == 'success' && myHistory.isNotEmpty) {
            setState(() {
              _isLoading = false;
            });
          }
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
                                  ['text_ongoing_rides'],
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
                        color: (myHistory.isEmpty)
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
                              (myHistory.isNotEmpty)
                                  ? Column(
                                      children: myHistory
                                          .asMap()
                                          .map((i, value) {
                                            return MapEntry(
                                                i,

                                                //completed ride history
                                                (myHistory[i].isEmpty)
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
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          InkWell(
                                                            onTap: () async {
                                                              setState(() {
                                                                _isLoading =
                                                                    true;
                                                              });
                                                              addressList
                                                                  .clear();
                                                              // selectedHistory = i;
                                                              addressList.add(AddressList(
                                                                  id: '1',
                                                                  type:
                                                                      'pickup',
                                                                  address:
                                                                      myHistory[
                                                                              i]
                                                                          [
                                                                          'pick_address'],
                                                                  pickup: true,
                                                                  latlng: LatLng(
                                                                      myHistory[
                                                                              i]
                                                                          [
                                                                          'pick_lat'],
                                                                      myHistory[
                                                                              i]
                                                                          [
                                                                          'pick_lng']),
                                                                  name: userDetails[
                                                                      'name'],
                                                                  number: userDetails[
                                                                      'mobile']));
                                                              if (_tripStops
                                                                  .isNotEmpty) {
                                                                for (var i = 0;
                                                                    i <
                                                                        _tripStops
                                                                            .length;
                                                                    i++) {
                                                                  addressList.add(AddressList(
                                                                      id: _tripStops[i][
                                                                              'id']
                                                                          .toString(),
                                                                      type:
                                                                          'drop',
                                                                      address: _tripStops[
                                                                              i][
                                                                          'address'],
                                                                      latlng: LatLng(
                                                                          _tripStops[i]
                                                                              [
                                                                              'latitude'],
                                                                          _tripStops[i]
                                                                              [
                                                                              'longitude']),
                                                                      name: '',
                                                                      number:
                                                                          '',
                                                                      instructions:
                                                                          null,
                                                                      pickup:
                                                                          false));
                                                                }
                                                              }

                                                              if (myHistory[i][
                                                                          'drop_address'] !=
                                                                      null &&
                                                                  _tripStops
                                                                      .isEmpty) {
                                                                addressList.add(AddressList(
                                                                    id: '2',
                                                                    type:
                                                                        'drop',
                                                                    pickup:
                                                                        false,
                                                                    address: myHistory[
                                                                            i][
                                                                        'drop_address'],
                                                                    latlng: LatLng(
                                                                        myHistory[i]
                                                                            [
                                                                            'drop_lat'],
                                                                        myHistory[i]
                                                                            [
                                                                            'drop_lng'])));
                                                              }

                                                              ismulitipleride =
                                                                  true;

                                                              var val =
                                                                  await getUserDetails(
                                                                      id: myHistory[
                                                                              i]
                                                                          [
                                                                          'id']);

                                                              //login page
                                                              if (val == true) {
                                                                setState(() {
                                                                  _isLoading =
                                                                      false;
                                                                });
                                                                if (myHistory[i]
                                                                        [
                                                                        'is_rental'] ==
                                                                    true) {
                                                                  naviagterental();
                                                                } else if (myHistory[i]
                                                                            [
                                                                            'is_rental'] ==
                                                                        false &&
                                                                    myHistory[i]
                                                                            [
                                                                            'drop_address'] ==
                                                                        null) {
                                                                  naviagteridewithoutdestini();
                                                                } else {
                                                                  navigate();
                                                                }
                                                              }
                                                            },
                                                            child: Container(
                                                              margin: EdgeInsets.only(
                                                                  top: media
                                                                          .width *
                                                                      0.025,
                                                                  bottom: media
                                                                          .width *
                                                                      0.05,
                                                                  left: media
                                                                          .width *
                                                                      0.03,
                                                                  right: media
                                                                          .width *
                                                                      0.03),
                                                              padding: EdgeInsets.fromLTRB(
                                                                  media.width *
                                                                      0.025,
                                                                  media.width *
                                                                      0.025,
                                                                  media.width *
                                                                      0.025,
                                                                  media.width *
                                                                      0.025),
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            12),
                                                                color: page,
                                                              ),
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
                                                                        text: myHistory[i]
                                                                            [
                                                                            'request_number'],
                                                                        size: media.width *
                                                                            fourteen,
                                                                        fontweight:
                                                                            FontWeight.w600,
                                                                        color:
                                                                            textColor,
                                                                      ),
                                                                      MyText(
                                                                        textAlign:
                                                                            TextAlign.end,
                                                                        text:
                                                                            'Otp : ${myHistory[i]['ride_otp']}',
                                                                        size: media.width *
                                                                            twelve,
                                                                        fontweight:
                                                                            FontWeight.w600,
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
                                                                      MyText(
                                                                          text: (myHistory[i]['accepted_at'] != null && myHistory[i]['is_driver_arrived'] == 0)
                                                                              ? 'Accepted'
                                                                              : (myHistory[i]['is_driver_arrived'] == 1 && myHistory[i]['is_trip_start'] == 0)
                                                                                  ? 'Arrived'
                                                                                  : (myHistory[i]['is_completed'] == 1)
                                                                                      ? 'Completed'
                                                                                      : 'Trip Started',
                                                                          color: (myHistory[i]['accepted_at'] != null && myHistory[i]['is_driver_arrived'] == 0)
                                                                              ? Colors.yellow
                                                                              : (myHistory[i]['is_driver_arrived'] == 1 && myHistory[i]['is_trip_start'] == 0)
                                                                                  ? Colors.orange
                                                                                  : online,
                                                                          fontweight: FontWeight.w600,
                                                                          size: media.width * fourteen),
                                                                      MyText(
                                                                        text: myHistory[i]
                                                                            [
                                                                            'accepted_at'],
                                                                        size: media.width *
                                                                            twelve,
                                                                        fontweight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.04,
                                                                  ),
                                                                  const MySeparator(),
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.04,
                                                                  ),
                                                                  Container(
                                                                    padding: EdgeInsets.all(
                                                                        media.width *
                                                                            0.02),
                                                                    margin: EdgeInsets.only(
                                                                        bottom: media.width *
                                                                            0.03),
                                                                    decoration: BoxDecoration(
                                                                        color: hintColor.withOpacity(
                                                                            0.1),
                                                                        borderRadius:
                                                                            BorderRadius.circular(media.width *
                                                                                0.02)),
                                                                    child: Row(
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              media.width * 0.13,
                                                                          width:
                                                                              media.width * 0.13,
                                                                          decoration: BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              image: DecorationImage(image: NetworkImage(myHistory[i]['driverDetail']['data']['profile_picture']), fit: BoxFit.cover)),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              media.width * 0.02,
                                                                        ),
                                                                        Expanded(
                                                                            child:
                                                                                Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            MyText(
                                                                              text: myHistory[i]['driverDetail']['data']['name'],
                                                                              size: media.width * eighteen,
                                                                              fontweight: FontWeight.w600,
                                                                            ),
                                                                            SizedBox(
                                                                              width: media.width * 0.8,
                                                                              child: Row(
                                                                                children: [
                                                                                  Image.network(
                                                                                    myHistory[i]['vehicle_type_image'].toString(),
                                                                                    width: media.width * 0.1,
                                                                                  ),
                                                                                  SizedBox(
                                                                                    width: media.width * 0.03,
                                                                                  ),
                                                                                  MyText(
                                                                                    text: myHistory[i]['vehicle_type_name'],
                                                                                    size: media.width * twelve,
                                                                                    fontweight: FontWeight.w600,
                                                                                    color: (isDarkTheme == true) ? Colors.black : textColor,
                                                                                  ),
                                                                                  Container(
                                                                                    margin: const EdgeInsets.only(left: 5, right: 5),
                                                                                    height: media.width * 0.05,
                                                                                    width: 1,
                                                                                    color: hintColor,
                                                                                  ),
                                                                                  MyText(
                                                                                    text: myHistory[i]['car_number'].toString(),
                                                                                    size: media.width * twelve,
                                                                                    fontweight: FontWeight.w600,
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ))
                                                                      ],
                                                                    ),
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
                                                                            color: Colors.green.withOpacity(0.3)),
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
                                                                            0.06,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            MyText(
                                                                          text: myHistory[i]
                                                                              [
                                                                              'pick_address'],
                                                                          // maxLines:
                                                                          //     1,
                                                                          size: media.width *
                                                                              twelve,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.02,
                                                                  ),
                                                                  Column(
                                                                    children: _tripStops
                                                                        .asMap()
                                                                        .map((i, value) {
                                                                          return MapEntry(
                                                                              i,
                                                                              (i < _tripStops.length - 1)
                                                                                  ? Column(
                                                                                      children: [
                                                                                        Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          children: [
                                                                                            Container(
                                                                                              height: media.width * 0.06,
                                                                                              width: media.width * 0.06,
                                                                                              alignment: Alignment.center,
                                                                                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withOpacity(0.1)),
                                                                                              child: MyText(
                                                                                                text: (i + 1).toString(),
                                                                                                size: media.width * twelve,
                                                                                                maxLines: 1,
                                                                                              ),
                                                                                            ),
                                                                                            SizedBox(
                                                                                              width: media.width * 0.05,
                                                                                            ),
                                                                                            Expanded(
                                                                                              child: MyText(
                                                                                                text: _tripStops[i]['address'],
                                                                                                size: media.width * twelve,
                                                                                                // maxLines: 1,
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                        SizedBox(
                                                                                          height: media.width * 0.02,
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  : Container());
                                                                        })
                                                                        .values
                                                                        .toList(),
                                                                  ),
                                                                  (myHistory[i][
                                                                              'drop_address'] !=
                                                                          null)
                                                                      ? Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              height: media.width * 0.06,
                                                                              width: media.width * 0.06,
                                                                              alignment: Alignment.center,
                                                                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withOpacity(0.1)),
                                                                              child: Icon(
                                                                                Icons.location_on,
                                                                                color: const Color(0xFFFF0000),
                                                                                size: media.width * eighteen,
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: media.width * 0.05,
                                                                            ),
                                                                            Expanded(
                                                                              child: MyText(
                                                                                text: myHistory[i]['drop_address'],
                                                                                size: media.width * twelve,
                                                                                // maxLines:
                                                                                //     1,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : Container(),
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.02,
                                                                  ),
                                                                  (myHistory[i][
                                                                              'goods_type'] !=
                                                                          '-')
                                                                      ? MyText(
                                                                          text: myHistory[i]
                                                                              [
                                                                              'goods_type'],
                                                                          size: media.width *
                                                                              twelve,
                                                                          color:
                                                                              verifyDeclined,
                                                                        )
                                                                      : Container(),
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.02,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .end,
                                                                    children: [
                                                                      MyText(
                                                                        text: (myHistory[i]['is_bid_ride'] == 1 &&
                                                                                myHistory[i]['is_out_station'].toString() == '0')
                                                                            ? languages[choosenLanguage]['text_bidding']
                                                                            : myHistory[i]['is_out_station'].toString() == '1'
                                                                                ? languages[choosenLanguage]['text_outstation']
                                                                                : (myHistory[i]['is_rental'] == true)
                                                                                    ? languages[choosenLanguage]['text_rental']
                                                                                    : 'normal',
                                                                        size: media.width *
                                                                            fourteen,
                                                                        color: textColor
                                                                            .withOpacity(0.5),
                                                                      ),
                                                                      SizedBox(
                                                                        width: media.width *
                                                                            0.01,
                                                                      ),
                                                                      Container(
                                                                        height: media.width *
                                                                            0.05,
                                                                        width:
                                                                            2,
                                                                        color:
                                                                            textColor,
                                                                      ),
                                                                      SizedBox(
                                                                        width: media.width *
                                                                            0.01,
                                                                      ),
                                                                      (myHistory[i]['drop_address'] !=
                                                                              null)
                                                                          ? Row(
                                                                              children: [
                                                                                SizedBox(
                                                                                  width: media.width * 0.06,
                                                                                  child: (myHistory[i]['payment_type_string'] == 'cash')
                                                                                      ? Image.asset(
                                                                                          'assets/images/cash.png',
                                                                                          fit: BoxFit.contain,
                                                                                        )
                                                                                      : (myHistory[i]['payment_type_string'] == 'wallet')
                                                                                          ? Image.asset(
                                                                                              'assets/images/wallet.png',
                                                                                              fit: BoxFit.contain,
                                                                                            )
                                                                                          : (myHistory[i]['payment_type_string'] == 'card')
                                                                                              ? Image.asset(
                                                                                                  'assets/images/card.png',
                                                                                                  fit: BoxFit.contain,
                                                                                                )
                                                                                              : (myHistory[i]['payment_type_string'] == 'upi')
                                                                                                  ? Image.asset(
                                                                                                      'assets/images/upi.png',
                                                                                                      fit: BoxFit.contain,
                                                                                                    )
                                                                                                  : Container(),
                                                                                ),
                                                                                SizedBox(
                                                                                  width: media.width * 0.01,
                                                                                ),
                                                                                MyText(
                                                                                  text: '${userDetails['currency_symbol']} ${(myHistory[i]['is_bid_ride'] == 1) ? myHistory[i]['accepted_ride_fare'].toString() : myHistory[i]['request_eta_amount'].toString()}',
                                                                                  size: media.width * fourteen,
                                                                                  fontweight: FontWeight.w600,
                                                                                  maxLines: 1,
                                                                                )
                                                                              ],
                                                                            )
                                                                          : Container(),
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
                                      : Container(),

                              //load more button
                              (myHistoryPage['pagination'] != null)
                                  ? (myHistoryPage['pagination']
                                              ['current_page'] <
                                          myHistoryPage['pagination']
                                              ['total_pages'])
                                      ? InkWell(
                                          onTap: () async {
                                            setState(() {
                                              // _isLoading = true;
                                              for (var i = 0; i < 10; i++) {
                                                myHistory.add({});
                                              }
                                            });
                                            // dynamic val;
                                            historyFiltter = 'on_trip=1';
                                            await getHistoryPages(
                                                '$historyFiltter&page=${myHistoryPage['pagination']['current_page'] + 1}');
                                            // if (val == 'logout') {
                                            //   navigateLogout();
                                            // }
                                            setState(() {
                                              // _isLoading = false;
                                            });
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(
                                                media.width * 0.025),
                                            margin: EdgeInsets.only(
                                                bottom: media.width * 0.05),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: page,
                                                border: Border.all(
                                                    color: borderLines,
                                                    width: 1.2)),
                                            child: MyText(
                                              text: languages[choosenLanguage]
                                                  ['text_loadmore'],
                                              size: media.width * sixteen,
                                            ),
                                          ),
                                        )
                                      : Container()
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
