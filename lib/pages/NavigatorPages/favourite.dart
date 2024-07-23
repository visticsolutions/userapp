import 'package:flutter/material.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../noInternet/noInternet.dart';

class Favorite extends StatefulWidget {
  const Favorite({super.key});

  @override
  State<Favorite> createState() => _FavoriteState();
}

class _FavoriteState extends State<Favorite> {
  bool _isLoading = false;
  bool _deletingAddress = false;
  dynamic _deletingId;
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
                    padding: EdgeInsets.fromLTRB(media.width * 0.05,
                        media.width * 0.05, media.width * 0.05, 0),
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
                            ),
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
                        Row(
                          children: [
                            MyText(
                              text: languages[choosenLanguage]
                                      ['text_fav_address']
                                  .toString()
                                  .toUpperCase(),
                              size: media.width * sixteen,
                              fontweight: FontWeight.w800,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: media.width * 0.1,
                        ),
                        (favAddress.isNotEmpty)
                            ? Expanded(
                                child: SingleChildScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  child: Column(
                                    children: favAddress
                                        .asMap()
                                        .map((i, value) {
                                          return MapEntry(
                                            i,
                                            Container(
                                              width: media.width * 0.9,
                                              margin: EdgeInsets.only(
                                                  bottom: media.width * 0.04),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  color: page,
                                                  boxShadow: [
                                                    BoxShadow(
                                                        blurRadius: 2.0,
                                                        spreadRadius: 2.0,
                                                        color: (isDarkTheme ==
                                                                true)
                                                            ? Colors.white
                                                                .withOpacity(
                                                                    0.2)
                                                            : Colors.black
                                                                .withOpacity(
                                                                    0.2))
                                                  ]),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    margin: EdgeInsets.all(
                                                        media.width * 0.03),
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          children: [
                                                            (favAddress[i][
                                                                        'address_name'] ==
                                                                    'Home')
                                                                ? Icon(
                                                                    Icons
                                                                        .home_outlined,
                                                                    size: media
                                                                            .width *
                                                                        0.075,
                                                                    color:
                                                                        textColor)
                                                                : (favAddress[i]
                                                                            [
                                                                            'address_name'] ==
                                                                        'Work')
                                                                    ? Image
                                                                        .asset(
                                                                        'assets/images/briefcase.png',
                                                                        color:
                                                                            textColor,
                                                                        width: media.width *
                                                                            0.075,
                                                                      )
                                                                    : Image
                                                                        .asset(
                                                                        'assets/images/navigation.png',
                                                                        color:
                                                                            textColor,
                                                                        width: media.width *
                                                                            0.075,
                                                                      ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.02,
                                                            ),
                                                            MyText(
                                                              text: favAddress[
                                                                      i][
                                                                  'address_name'],
                                                              size:
                                                                  media.width *
                                                                      sixteen,
                                                              fontweight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: media.width *
                                                              0.03,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.7,
                                                              child: MyText(
                                                                text: favAddress[
                                                                        i][
                                                                    'pick_address'],
                                                                size: media
                                                                        .width *
                                                                    twelve,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: media.width *
                                                              0.03,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    height: media.width * 0.08,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                              bottomLeft: Radius
                                                                  .circular(12),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          12)),
                                                      color: Colors.grey
                                                          .withOpacity(0.1),
                                                    ),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        setState(() {
                                                          _deletingId =
                                                              favAddress[i]
                                                                  ['id'];
                                                          _deletingAddress =
                                                              true;
                                                        });
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons.delete,
                                                            color: (isDarkTheme ==
                                                                    true)
                                                                ? Colors.white
                                                                : buttonColor,
                                                          ),
                                                          MyText(
                                                            text: languages[
                                                                    choosenLanguage]
                                                                ['text_delete'],
                                                            size: media.width *
                                                                twelve,
                                                            color: (isDarkTheme ==
                                                                    true)
                                                                ? Colors.white
                                                                : buttonColor,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        })
                                        .values
                                        .toList(),
                                  ),
                                ),
                              )
                            : Expanded(
                                child: Column(
                                  // mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: media.height * 0.15,
                                    ),
                                    Container(
                                      alignment: Alignment.center,
                                      height: media.width * 0.3,
                                      width: media.width * 0.3,
                                      decoration: const BoxDecoration(
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  'assets/images/nolocation.png'),
                                              fit: BoxFit.contain)),
                                    ),
                                    SizedBox(
                                      height: media.width * 0.07,
                                    ),
                                    SizedBox(
                                      width: media.width * 0.8,
                                      child: MyText(
                                          text: languages[choosenLanguage]
                                              ['text_noDataFound'],
                                          textAlign: TextAlign.center,
                                          fontweight: FontWeight.w800,
                                          size: media.width * sixteen),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),

                  //popup for delete address
                  (_deletingAddress == true)
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
                                                _deletingAddress = false;
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
                                          ['text_removeFav'],
                                      size: media.width * sixteen,
                                      fontweight: FontWeight.w600,
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(
                                      height: media.width * 0.05,
                                    ),
                                    Button(
                                        onTap: () async {
                                          setState(() {
                                            _isLoading = true;
                                          });
                                          var result = await removeFavAddress(
                                              _deletingId);
                                          if (result == 'success') {
                                            setState(() {
                                              _deletingAddress = false;
                                            });
                                          }
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        },
                                        text: languages[choosenLanguage]
                                            ['text_confirm'])
                                  ],
                                ),
                              )
                            ],
                          ),
                        ))
                      : const SizedBox(),

                  //no internet
                  (internet == false)
                      ? Positioned(
                          top: 0,
                          child: NoInternet(onTap: () {
                            setState(() {
                              internetTrue();
                            });
                          }))
                      : const SizedBox(),

                  //loader
                  (_isLoading == true)
                      ? const Positioned(child: Loading())
                      : const SizedBox()
                ],
              ),
            );
          }),
    );
  }
}
