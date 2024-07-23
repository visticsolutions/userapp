import 'package:flutter/material.dart';
import 'package:flutter_user/pages/login/login.dart';
import 'package:flutter_user/widgets/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:location/location.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../loadingPage/loading.dart';
import '../noInternet/noInternet.dart';
import '../onTripPage/map_page.dart';

class Faq extends StatefulWidget {
  const Faq({super.key});

  @override
  State<Faq> createState() => _FaqState();
}

class _FaqState extends State<Faq> {
  bool _faqCompleted = false;
  bool _isLoading = true;
  dynamic _selectedQuestion;

  @override
  void initState() {
    faqDatas();
    super.initState();
  }

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false);
  }

//get faq data
  faqDatas() async {
    if (currentLocation != null) {
      await getFaqData(currentLocation.latitude, currentLocation.longitude);
      setState(() {
        _faqCompleted = true;
        _isLoading = false;
      });
    } else {
      var loc = await Location.instance.getLocation();
      await getFaqData(loc.latitude, loc.longitude);
      setState(() {
        _faqCompleted = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: ValueListenableBuilder(
          valueListenable: valueNotifierBook.value,
          builder: (context, value, child) {
            return Directionality(
              textDirection: (languageDirection == 'rtl')
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Stack(
                children: [
                  Container(
                    height: media.height * 1,
                    width: media.width * 1,
                    color: page,
                    padding: EdgeInsets.fromLTRB(media.width * 0.05,
                        media.width * 0.05, media.width * 0.05, 0),
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
                                  text: languages[choosenLanguage]['text_faq'],
                                  size: media.width * twenty,
                                  fontweight: FontWeight.w600,
                                )),
                            Positioned(
                                child: InkWell(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Icon(Icons.arrow_back_ios,
                                        color: textColor)))
                          ],
                        ),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        SizedBox(
                          width: media.width * 0.9,
                          height: media.height * 0.16,
                          child: Image.asset(
                            'assets/images/faqPage.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(
                          height: media.width * 0.05,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: (faqData.isNotEmpty)
                                ? Column(
                                    children: [
                                      Column(
                                        children: faqData
                                            .asMap()
                                            .map((i, value) {
                                              return MapEntry(
                                                  i,
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        _selectedQuestion = i;
                                                      });
                                                    },
                                                    child: Container(
                                                      width: media.width * 0.9,
                                                      margin: EdgeInsets.only(
                                                          top: media.width *
                                                              0.025,
                                                          bottom: media.width *
                                                              0.025),
                                                      padding: EdgeInsets.all(
                                                          media.width * 0.05),
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: page,
                                                          border: Border.all(
                                                              color:
                                                                  borderLines,
                                                              width: 1.2)),
                                                      child: Column(
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.7,
                                                                  child: MyText(
                                                                    text: faqData[
                                                                            i][
                                                                        'question'],
                                                                    size: media
                                                                            .width *
                                                                        fourteen,
                                                                    fontweight:
                                                                        FontWeight
                                                                            .w600,
                                                                  )),
                                                              RotatedBox(
                                                                  quarterTurns:
                                                                      (_selectedQuestion ==
                                                                              i)
                                                                          ? 2
                                                                          : 0,
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/images/chevron-down.png',
                                                                    width: media
                                                                            .width *
                                                                        0.075,
                                                                  ))
                                                            ],
                                                          ),
                                                          AnimatedContainer(
                                                            duration:
                                                                const Duration(
                                                                    milliseconds:
                                                                        200),
                                                            child: (_selectedQuestion ==
                                                                    i)
                                                                ? Container(
                                                                    padding: EdgeInsets.only(
                                                                        top: media.width *
                                                                            0.025),
                                                                    child:
                                                                        MyText(
                                                                      text: faqData[
                                                                              i]
                                                                          [
                                                                          'answer'],
                                                                      size: media
                                                                              .width *
                                                                          twelve,
                                                                    ))
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
                                      (myFaqPage['pagination'] != null)
                                          ? (myFaqPage['pagination']
                                                      ['current_page'] <
                                                  myFaqPage['pagination']
                                                      ['total_pages'])
                                              ? InkWell(
                                                  onTap: () async {
                                                    dynamic val;
                                                    setState(() {
                                                      _isLoading = true;
                                                    });
                                                    val = await getFaqPages(
                                                        '${center.latitude}/${center.longitude}?page=${myFaqPage['pagination']['current_page'] + 1}');
                                                    if (val == 'logout') {
                                                      navigateLogout();
                                                    }
                                                    setState(() {
                                                      _isLoading = false;
                                                    });
                                                  },
                                                  child: Container(
                                                    padding: EdgeInsets.all(
                                                        media.width * 0.025),
                                                    margin: EdgeInsets.only(
                                                        bottom:
                                                            media.width * 0.05),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: page,
                                                        border: Border.all(
                                                            color: borderLines,
                                                            width: 1.2)),
                                                    child: Text(
                                                      languages[choosenLanguage]
                                                          ['text_loadmore'],
                                                      style:
                                                          GoogleFonts.notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              color: textColor),
                                                    ),
                                                  ),
                                                )
                                              : Container()
                                          : Container()
                                    ],
                                  )
                                : (_faqCompleted == true)
                                    ? MyText(
                                        text: languages[choosenLanguage]
                                            ['text_noDataFound'],
                                        size: media.width * eighteen,
                                        fontweight: FontWeight.w600,
                                      )
                                    : Container(),
                          ),
                        )
                      ],
                    ),
                  ),

                  //no internet
                  (internet == false)
                      ? Positioned(
                          top: 0,
                          child: NoInternet(
                            onTap: () {
                              setState(() {
                                internetTrue();
                                _isLoading = true;
                                _faqCompleted = false;
                                faqDatas();
                              });
                            },
                          ))
                      : Container(),

                  //loader
                  (_isLoading == true)
                      ? const Positioned(top: 0, child: Loading())
                      : Container()
                ],
              ),
            );
          }),
    );
  }
}
