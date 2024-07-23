import 'package:flutter/material.dart';
import 'package:flutter_user/pages/NavigatorPages/paymentgateways.dart';
import 'package:flutter_user/translations/translation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../widgets/widgets.dart';
import '../loadingPage/loading.dart';
import '../login/login.dart';
import '../noInternet/nointernet.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

dynamic addMoney;
TextEditingController phonenumber = TextEditingController();
TextEditingController amount = TextEditingController();
bool isLoading = false;
bool showtoast = false;

class _WalletPageState extends State<WalletPage> {
  TextEditingController addMoneyController = TextEditingController();
  dynamic _shimmer;
  bool _addPayment = false;
  int ischeckmoneytransfer = 0;
  ScrollController custom = ScrollController();

  @override
  void initState() {
    getWallet();
    _shimmer = AnimationController.unbounded(vsync: MyTickerProvider())
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
    custom.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  //get wallet details
  getWallet() async {
    walletHistory.clear();
    for (var i = 0; i < 10; i++) {
      walletHistory.add({});
    }
    var val = await getWalletHistory();
    await getCountryCode();
    if (val == 'success') {
      setState(() {
        isLoading = false;
        valueNotifierBook.incrementNotifier();
      });
    }
  }

  showToast() {
    setState(() {
      showtoast = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        showtoast = false;
      });
    });
  }

  navigateLogout() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false);
    });
  }

  bool error = false;
  String errortext = '';
  bool ispop = false;

  //show toast for copy

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Material(
      child: ValueListenableBuilder(
          valueListenable: valueNotifierHome.value,
          builder: (context, value, child) {
            return Directionality(
              textDirection: (languageDirection == 'rtl')
                  ? TextDirection.rtl
                  : TextDirection.ltr,
              child: Scaffold(
                body: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(
                          media.width * 0.05,
                          media.width * 0.05 +
                              MediaQuery.of(context).padding.top,
                          media.width * 0.05,
                          0),
                      height: media.height * 1,
                      width: media.width * 1,
                      color: page,
                      child: Column(
                        children: [
                          Expanded(
                            child: CustomScrollView(
                              controller: custom,
                              slivers: [
                                SliverAppBar(
                                  backgroundColor: page,
                                  automaticallyImplyLeading: false,
                                  // collapsedHeight: 0,
                                  collapsedHeight: media.width * 0.15 -
                                      MediaQuery.of(context).padding.top,
                                  toolbarHeight: media.width * 0.15 -
                                      MediaQuery.of(context).padding.top,
                                  // toolbarHeight: 0,
                                  expandedHeight: media.width * 0.45,
                                  pinned: true,
                                  iconTheme: IconThemeData(
                                      color: (isDarkTheme)
                                          ? Colors.white
                                          : Colors.black),

                                  // excludeHeaderSemantics: false,
                                  surfaceTintColor: page,

                                  flexibleSpace: FlexibleSpaceBar(
                                    background: Container(
                                      color: page,
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            height: media.width * 0.02,
                                          ),
                                          MyText(
                                            text: languages[choosenLanguage]
                                                ['text_enable_wallet'],
                                            size: media.width * eighteen,
                                            fontweight: FontWeight.w600,
                                          ),
                                          SizedBox(
                                            height: media.width * 0.05,
                                          ),
                                          Row(
                                            children: [
                                              MyText(
                                                text: languages[choosenLanguage]
                                                    ['text_availablebalance'],
                                                size: media.width * fourteen,
                                                fontweight: FontWeight.w800,
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: media.width * 0.03,
                                          ),
                                          if (walletBalance.isNotEmpty)
                                            Container(
                                              height: media.width * 0.1,
                                              width: media.width * 0.9,
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: Colors.grey
                                                    .withOpacity(0.1),
                                              ),
                                              child: MyText(
                                                text: walletBalance[
                                                        'currency_symbol'] +
                                                    ' ' +
                                                    walletBalance[
                                                            'wallet_balance']
                                                        .toString(),
                                                size: media.width * twenty,
                                                fontweight: FontWeight.w600,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    title: SizedBox(
                                      // color: Colors.red,
                                      width: (custom.hasClients &&
                                              custom.offset < media.width * 0.4)
                                          ? media.width * 0.4
                                          : media.width,
                                      child: MyText(
                                        text: languages[choosenLanguage]
                                            ['text_recenttransactions'],
                                        size: (custom.hasClients &&
                                                custom.offset <
                                                    media.width * 0.4)
                                            ? media.width * twelve
                                            : media.width * sixteen,
                                        textAlign: (custom.hasClients &&
                                                custom.offset <
                                                    media.width * 0.4)
                                            ? TextAlign.center
                                            : null,
                                      ),
                                    ),
                                  ),
                                ),
                                (walletHistory.isNotEmpty)
                                    ? SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                            (context, i) {
                                          return Column(
                                            children: [
                                              (walletHistory[i].isEmpty)
                                                  ? AnimatedBuilder(
                                                      animation: _shimmer,
                                                      builder:
                                                          (context, widget) {
                                                        return ShaderMask(
                                                            blendMode: BlendMode
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
                                                                      tileMode:
                                                                          TileMode
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
                                                                      BorderRadius.circular(
                                                                          media.width *
                                                                              0.02)),
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
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
                                                                        decoration: BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            color: hintColor.withOpacity(0.5)),
                                                                      ),
                                                                      SizedBox(
                                                                        width: media.width *
                                                                            0.05,
                                                                      ),
                                                                      Expanded(
                                                                        child:
                                                                            Column(
                                                                          children: [
                                                                            Container(
                                                                              height: media.width * 0.05,
                                                                              color: hintColor.withOpacity(0.5),
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 5,
                                                                            ),
                                                                            Container(
                                                                              height: media.width * 0.03,
                                                                              color: hintColor.withOpacity(0.5),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: media.width *
                                                                            0.05,
                                                                      ),
                                                                      Container(
                                                                        height: media.width *
                                                                            0.05,
                                                                        width: media.width *
                                                                            0.05,
                                                                        decoration: BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            color: hintColor.withOpacity(0.5)),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ));
                                                      })
                                                  : Container(
                                                      margin: EdgeInsets.only(
                                                          top: media.width *
                                                              0.02,
                                                          bottom: media.width *
                                                              0.02),
                                                      width: media.width * 0.9,
                                                      padding: EdgeInsets.all(
                                                          media.width * 0.025),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  borderLines,
                                                              width: 1.2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                          color: Colors.grey
                                                              .withOpacity(
                                                                  0.1)),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height:
                                                                media.width *
                                                                    0.1067,
                                                            width: media.width *
                                                                0.1067,
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: topBar),
                                                            alignment: Alignment
                                                                .center,
                                                            child: Text(
                                                              (walletHistory[i][
                                                                          'is_credit'] ==
                                                                      1)
                                                                  ? '+'
                                                                  : '-',
                                                              style: TextStyle(
                                                                  fontSize: media
                                                                          .width *
                                                                      twentyfour),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: media.width *
                                                                0.025,
                                                          ),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              MyText(
                                                                text: walletHistory[
                                                                            i][
                                                                        'remarks']
                                                                    .toString(),
                                                                size: media
                                                                        .width *
                                                                    fourteen,
                                                                fontweight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              SizedBox(
                                                                height: media
                                                                        .width *
                                                                    0.02,
                                                              ),
                                                              MyText(
                                                                text: walletHistory[
                                                                        i][
                                                                    'created_at'],
                                                                size: media
                                                                        .width *
                                                                    ten,
                                                                color: textColor
                                                                    .withOpacity(
                                                                        0.4),
                                                              )
                                                            ],
                                                          ),
                                                          Expanded(
                                                              child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              MyText(
                                                                text: walletHistory[
                                                                            i][
                                                                        'currency_symbol'] +
                                                                    ' ' +
                                                                    walletHistory[i]
                                                                            [
                                                                            'amount']
                                                                        .toString(),
                                                                size: media
                                                                        .width *
                                                                    twelve,
                                                                color: (walletHistory[i]
                                                                            [
                                                                            'is_credit'] ==
                                                                        1)
                                                                    ? online
                                                                    : verifyDeclined,
                                                              )
                                                            ],
                                                          ))
                                                        ],
                                                      ),
                                                    ),
                                              //load more button
                                              (walletPages.isNotEmpty &&
                                                      i ==
                                                          walletHistory.length -
                                                              1)
                                                  ? (walletPages[
                                                              'current_page'] <
                                                          walletPages[
                                                              'total_pages'])
                                                      ? InkWell(
                                                          onTap: () async {
                                                            setState(() {
                                                              for (var i = 0;
                                                                  i < 10;
                                                                  i++) {
                                                                walletHistory
                                                                    .add({});
                                                              }
                                                            });

                                                            var val = await getWalletHistoryPage(
                                                                (walletPages[
                                                                            'current_page'] +
                                                                        1)
                                                                    .toString());
                                                            if (val ==
                                                                'logout') {
                                                              navigateLogout();
                                                            }

                                                            setState(() {
                                                              isLoading = false;
                                                            });
                                                          },
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .all(media
                                                                        .width *
                                                                    0.025),
                                                            margin: EdgeInsets.only(
                                                                bottom: media
                                                                        .width *
                                                                    0.05),
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: page,
                                                                border: Border.all(
                                                                    color:
                                                                        borderLines,
                                                                    width:
                                                                        1.2)),
                                                            child: MyText(
                                                              text: languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_loadmore'],
                                                              size:
                                                                  media.width *
                                                                      sixteen,
                                                            ),
                                                          ),
                                                        )
                                                      : Container()
                                                  : Container()
                                            ],
                                          );
                                        }, childCount: walletHistory.length),
                                      )
                                    : SliverList(
                                        delegate: SliverChildBuilderDelegate(
                                            (context, i) {
                                          return SizedBox(
                                            height: media.height * 0.4,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  height: media.width * 0.2,
                                                ),
                                                Container(
                                                  alignment: Alignment.center,
                                                  height: media.width * 0.4,
                                                  width: media.width * 0.4,
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(
                                                          image: AssetImage(
                                                              (isDarkTheme)
                                                                  ? 'assets/images/no_transactiondark.gif'
                                                                  : 'assets/images/no_transaction.gif'),
                                                          fit: BoxFit.contain)),
                                                ),
                                                SizedBox(
                                                  width: media.width * 0.6,
                                                  child: MyText(
                                                      text: languages[
                                                              choosenLanguage]
                                                          ['text_noDataFound'],
                                                      textAlign:
                                                          TextAlign.center,
                                                      fontweight:
                                                          FontWeight.w800,
                                                      size: media.width *
                                                          sixteen),
                                                ),
                                              ],
                                            ),
                                          );
                                        }, childCount: 1),
                                      ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: media.width * 0.2,
                            width: media.width * 0.9,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  height: media.width * 0.01,
                                ),
                                MyText(
                                  text: languages[choosenLanguage]
                                          ['text_recharge_bal']
                                      .toString()
                                      .toUpperCase(),
                                  size: media.width * fourteen,
                                  fontweight: FontWeight.w800,
                                ),
                                SizedBox(
                                  height: media.width * 0.03,
                                ),
                                MyText(
                                  text: languages[choosenLanguage]
                                      ['text_rechage_text'],
                                  size: media.width * twelve,
                                  fontweight: FontWeight.w600,
                                  color: textColor.withOpacity(0.5),
                                )
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                height: media.width * 0.15,
                                width: media.width * 0.9,
                                alignment: Alignment.center,
                                color: Colors.grey.withOpacity(0.3),
                                // color: textColor,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          addMoneyController.text = '';
                                          addMoney = null;
                                        });

                                        showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) {
                                              return Container(
                                                padding: MediaQuery.of(context)
                                                    .viewInsets,
                                                decoration: BoxDecoration(
                                                    color: page,
                                                    borderRadius: BorderRadius
                                                        .only(
                                                            topLeft: Radius
                                                                .circular(media
                                                                        .width *
                                                                    0.05),
                                                            topRight: Radius
                                                                .circular(media
                                                                        .width *
                                                                    0.05))),
                                                // padding:
                                                //     EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
                                                child: Container(
                                                  padding: EdgeInsets.all(
                                                      media.width * 0.05),
                                                  child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: MyText(
                                                            textAlign: TextAlign
                                                                .center,
                                                            text: languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_add_money_wallet'],
                                                            size: media.width *
                                                                sixteen,
                                                            fontweight:
                                                                FontWeight.w600,
                                                            color: textColor,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: media.width *
                                                              0.06,
                                                        ),
                                                        Container(
                                                          height: media.width *
                                                              0.128,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            border: Border.all(
                                                                color:
                                                                    borderLines,
                                                                width: 1.2),
                                                          ),
                                                          child: Row(children: [
                                                            Container(
                                                                width: media
                                                                        .width *
                                                                    0.1,
                                                                height: media
                                                                        .width *
                                                                    0.128,
                                                                decoration:
                                                                    const BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius
                                                                                .only(
                                                                          topLeft:
                                                                              Radius.circular(12),
                                                                          bottomLeft:
                                                                              Radius.circular(12),
                                                                        ),
                                                                        color: Color(
                                                                            0xffF0F0F0)),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: MyText(
                                                                  text: walletBalance[
                                                                      'currency_symbol'],
                                                                  size: media
                                                                          .width *
                                                                      twelve,
                                                                  fontweight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: (isDarkTheme ==
                                                                          true)
                                                                      ? Colors
                                                                          .black
                                                                      : textColor,
                                                                )),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.05,
                                                            ),
                                                            Container(
                                                              height:
                                                                  media.width *
                                                                      0.128,
                                                              width:
                                                                  media.width *
                                                                      0.6,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: TextField(
                                                                controller:
                                                                    addMoneyController,
                                                                onChanged:
                                                                    (val) {
                                                                  setState(() {
                                                                    addMoney =
                                                                        int.parse(
                                                                            val);
                                                                  });
                                                                },
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                decoration:
                                                                    InputDecoration(
                                                                  border:
                                                                      InputBorder
                                                                          .none,
                                                                  hintText: languages[
                                                                          choosenLanguage]
                                                                      [
                                                                      'text_enteramount'],
                                                                  hintStyle:
                                                                      GoogleFonts
                                                                          .notoSans(
                                                                    fontSize: media
                                                                            .width *
                                                                        fourteen,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    color: textColor
                                                                        .withOpacity(
                                                                            0.4),
                                                                  ),
                                                                ),
                                                                style: GoogleFonts.notoSans(
                                                                    fontSize: media
                                                                            .width *
                                                                        fourteen,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .normal,
                                                                    color:
                                                                        textColor),
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                          ]),
                                                        ),
                                                        SizedBox(
                                                          height: media.width *
                                                              0.05,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  addMoneyController
                                                                          .text =
                                                                      '100';
                                                                  addMoney =
                                                                      100;
                                                                });
                                                              },
                                                              child: Container(
                                                                height: media
                                                                        .width *
                                                                    0.11,
                                                                width: media
                                                                        .width *
                                                                    0.17,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color:
                                                                            borderLines,
                                                                        width:
                                                                            1.2),
                                                                    color: page,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            6)),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: MyText(
                                                                  text: walletBalance[
                                                                          'currency_symbol'] +
                                                                      '100',
                                                                  size: media
                                                                          .width *
                                                                      twelve,
                                                                  fontweight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.05,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  addMoneyController
                                                                          .text =
                                                                      '500';
                                                                  addMoney =
                                                                      500;
                                                                });
                                                              },
                                                              child: Container(
                                                                height: media
                                                                        .width *
                                                                    0.11,
                                                                width: media
                                                                        .width *
                                                                    0.17,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color:
                                                                            borderLines,
                                                                        width:
                                                                            1.2),
                                                                    color: page,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            6)),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: MyText(
                                                                  text: walletBalance[
                                                                          'currency_symbol'] +
                                                                      '500',
                                                                  size: media
                                                                          .width *
                                                                      twelve,
                                                                  fontweight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.05,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  addMoneyController
                                                                          .text =
                                                                      '1000';
                                                                  addMoney =
                                                                      1000;
                                                                });
                                                              },
                                                              child: Container(
                                                                height: media
                                                                        .width *
                                                                    0.11,
                                                                width: media
                                                                        .width *
                                                                    0.17,
                                                                decoration: BoxDecoration(
                                                                    border: Border.all(
                                                                        color:
                                                                            borderLines,
                                                                        width:
                                                                            1.2),
                                                                    color: page,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            6)),
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                child: MyText(
                                                                  text: walletBalance[
                                                                          'currency_symbol'] +
                                                                      '1000',
                                                                  size: media
                                                                          .width *
                                                                      twelve,
                                                                  fontweight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height:
                                                              media.width * 0.1,
                                                        ),
                                                        Button(
                                                          onTap: () async {
                                                            FocusManager
                                                                .instance
                                                                .primaryFocus
                                                                ?.unfocus();
                                                            if (addMoney != 0 &&
                                                                addMoney !=
                                                                    null) {
                                                              Navigator.pop(
                                                                  context);
                                                              showModalBottomSheet(
                                                                  context:
                                                                      context,
                                                                  isScrollControlled:
                                                                      true,
                                                                  builder:
                                                                      (context) {
                                                                    return Container(
                                                                      padding: EdgeInsets.all(
                                                                          media.width *
                                                                              0.05),
                                                                      height:
                                                                          media.width *
                                                                              1,
                                                                      width:
                                                                          media.width *
                                                                              1,
                                                                      child:
                                                                          SingleChildScrollView(
                                                                        child:
                                                                            Column(
                                                                          children: paymentGateways
                                                                              .map((i, value) {
                                                                                return MapEntry(
                                                                                    i,
                                                                                    (paymentGateways[i]['enabled'] == true)
                                                                                        ? InkWell(
                                                                                            onTap: () async {
                                                                                              Navigator.pop(context);
                                                                                              var val = await Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentGatwaysPage(url: paymentGateways[i]['url'])));
                                                                                              if (val != null) {
                                                                                                if (val) {
                                                                                                  setState(() {
                                                                                                    isLoading = true;

                                                                                                    addMoney = null;
                                                                                                  });
                                                                                                  await getWallet();
                                                                                                }
                                                                                              }
                                                                                            },
                                                                                            child: Container(
                                                                                              height: media.width * 0.15,
                                                                                              width: media.width * 0.6,
                                                                                              margin: EdgeInsets.only(bottom: media.width * 0.02),
                                                                                              decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(paymentGateways[i]['image']))),
                                                                                            ),
                                                                                          )
                                                                                        : Container());
                                                                              })
                                                                              .values
                                                                              .toList(),
                                                                        ),
                                                                      ),
                                                                    );
                                                                  });
                                                            }
                                                          },
                                                          text: languages[
                                                                  choosenLanguage]
                                                              ['text_addmoney'],
                                                          width:
                                                              media.width * 0.4,
                                                        ),
                                                        SizedBox(
                                                          height: media.width *
                                                              0.02,
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              addMoney = null;
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                              addMoneyController
                                                                  .clear();
                                                              Navigator.pop(
                                                                  context);
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding: EdgeInsets
                                                                .all(media
                                                                        .width *
                                                                    0.02),
                                                            child: MyText(
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              text: languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_cancel'],
                                                              size:
                                                                  media.width *
                                                                      sixteen,
                                                              color:
                                                                  verifyDeclined,
                                                            ),
                                                          ),
                                                        ),
                                                      ]),
                                                ),
                                              );
                                            });
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.credit_card,
                                            color: (ischeckmoneytransfer == 1)
                                                ? const Color(0xFFFF0000)
                                                : textColor,
                                          ),
                                          MyText(
                                              text: languages[choosenLanguage]
                                                  ['text_addmoney'],
                                              size: media.width * sixteen,
                                              color: (ischeckmoneytransfer == 1)
                                                  ? const Color(0xFFFF0000)
                                                  : textColor)
                                        ],
                                      ),
                                    ),
                                    if (userDetails[
                                            'show_wallet_money_transfer_feature_on_mobile_app'] ==
                                        '1')
                                      Container(
                                        height: media.width * 0.1,
                                        width: 1,
                                        color: textColor.withOpacity(0.3),
                                      ),
                                    if (userDetails[
                                            'show_wallet_money_transfer_feature_on_mobile_app'] ==
                                        '1')
                                      InkWell(
                                        onTap: () {
                                          showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor: page,
                                              builder: (context) {
                                                return const MonetTransferBottomSheet();
                                              });
                                        },
                                        child: Row(
                                          children: [
                                            Icon(Icons.swap_horiz_outlined,
                                                color: (ischeckmoneytransfer ==
                                                        2)
                                                    ? const Color(0xFFFF0000)
                                                    : textColor),
                                            MyText(
                                                text: languages[choosenLanguage]
                                                    ['text_credit_trans'],
                                                size: media.width * sixteen,
                                                color: (ischeckmoneytransfer ==
                                                        2)
                                                    ? const Color(0xFFFF0000)
                                                    : textColor)
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: media.width * 0.1,
                              )
                            ],
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      top: media.width * 0.055 +
                          MediaQuery.of(context).padding.top,
                      left: (languageDirection == 'ltr')
                          ? media.width * 0.05
                          : null,
                      right: (languageDirection == 'rtl')
                          ? media.width * 0.05
                          : null,
                      child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            Icons.arrow_back_ios,
                            color: textColor,
                          )),
                    ),

                    //add payment
                    (_addPayment == true)
                        ? Positioned(
                            bottom: 0,
                            child: Container(
                              height: media.height * 1,
                              width: media.width * 1,
                              color: Colors.transparent.withOpacity(0.6),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                        bottom: media.width * 0.05),
                                    width: media.width * 0.9,
                                    padding:
                                        EdgeInsets.all(media.width * 0.025),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: borderLines, width: 1.2),
                                        color: page),
                                    child: Column(children: [
                                      Container(
                                        height: media.width * 0.128,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                              color: borderLines, width: 1.2),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                                width: media.width * 0.1,
                                                height: media.width * 0.128,
                                                decoration: const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(12),
                                                      bottomLeft:
                                                          Radius.circular(12),
                                                    ),
                                                    color: Color(0xffF0F0F0)),
                                                alignment: Alignment.center,
                                                child: MyText(
                                                  text: walletBalance[
                                                      'currency_symbol'],
                                                  size: media.width * twelve,
                                                  fontweight: FontWeight.w600,
                                                  color: (isDarkTheme == true)
                                                      ? Colors.black
                                                      : textColor,
                                                )),
                                            SizedBox(
                                              width: media.width * 0.05,
                                            ),
                                            Container(
                                                height: media.width * 0.128,
                                                width: media.width * 0.6,
                                                alignment: Alignment.center,
                                                child: MyTextField(
                                                  textController:
                                                      addMoneyController,
                                                  hinttext:
                                                      languages[choosenLanguage]
                                                          ['text_enteramount'],
                                                  onTap: (val) {
                                                    setState(() {
                                                      addMoney = int.parse(val);
                                                    });
                                                  },
                                                  maxline: 1,
                                                ))
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: media.width * 0.05,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                addMoneyController.text = '100';
                                                addMoney = 100;
                                              });
                                            },
                                            child: Container(
                                              height: media.width * 0.11,
                                              width: media.width * 0.17,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: borderLines,
                                                      width: 1.2),
                                                  color: page,
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                              alignment: Alignment.center,
                                              child: MyText(
                                                text: walletBalance[
                                                        'currency_symbol'] +
                                                    '100',
                                                size: media.width * twelve,
                                                fontweight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: media.width * 0.05,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                addMoneyController.text = '500';
                                                addMoney = 500;
                                              });
                                            },
                                            child: Container(
                                              height: media.width * 0.11,
                                              width: media.width * 0.17,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: borderLines,
                                                      width: 1.2),
                                                  color: page,
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                              alignment: Alignment.center,
                                              child: MyText(
                                                text: walletBalance[
                                                        'currency_symbol'] +
                                                    '500',
                                                size: media.width * twelve,
                                                fontweight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: media.width * 0.05,
                                          ),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                addMoneyController.text =
                                                    '1000';
                                                addMoney = 1000;
                                              });
                                            },
                                            child: Container(
                                              height: media.width * 0.11,
                                              width: media.width * 0.17,
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: borderLines,
                                                      width: 1.2),
                                                  color: page,
                                                  borderRadius:
                                                      BorderRadius.circular(6)),
                                              alignment: Alignment.center,
                                              child: MyText(
                                                text: walletBalance[
                                                        'currency_symbol'] +
                                                    '1000',
                                                size: media.width * twelve,
                                                fontweight: FontWeight.w600,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: media.width * 0.1,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Button(
                                            onTap: () async {
                                              setState(() {
                                                _addPayment = false;
                                                addMoney = null;
                                                FocusManager
                                                    .instance.primaryFocus
                                                    ?.unfocus();
                                                addMoneyController.clear();
                                              });
                                            },
                                            text: languages[choosenLanguage]
                                                ['text_cancel'],
                                            width: media.width * 0.4,
                                          ),
                                          Button(
                                            onTap: () async {
                                              FocusManager.instance.primaryFocus
                                                  ?.unfocus();
                                              if (addMoney != 0 &&
                                                  addMoney != null) {
                                                setState(() {
                                                  _addPayment = false;
                                                });
                                              }
                                            },
                                            text: languages[choosenLanguage]
                                                ['text_addmoney'],
                                            width: media.width * 0.4,
                                          ),
                                        ],
                                      )
                                    ]),
                                  ),
                                ],
                              ),
                            ))
                        : Container(),

                    //loader
                    (isLoading)
                        ? const Positioned(top: 0, child: Loading())
                        : Container(),
                    (showtoast == true)
                        ? PaymentSuccess(
                            onTap: () async {
                              setState(() {
                                showtoast = false;
                                // Navigator.pop(context, true);
                              });
                            },
                            transfer: true,
                          )
                        : Container(),
                    (internet == false)
                        ? Positioned(
                            top: 0,
                            child: NoInternet(
                              onTap: () {
                                setState(() {
                                  internetTrue();
                                  // _complete = false;
                                  isLoading = true;
                                  getWallet();
                                });
                              },
                            ))
                        : Container(),
                  ],
                ),
              ),
            );
          }),
    );
  }
}

class MonetTransferBottomSheet extends StatefulWidget {
  const MonetTransferBottomSheet({super.key});

  @override
  State<MonetTransferBottomSheet> createState() =>
      _MonetTransferBottomSheetState();
}

class _MonetTransferBottomSheetState extends State<MonetTransferBottomSheet> {
  List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = const [
      DropdownMenuItem(value: "user", child: Text("User")),
      DropdownMenuItem(value: "driver", child: Text("Driver")),
    ];
    return menuItems;
  }

  String dropdownValue = 'user';
  bool error = false;
  String errortext = '';

  @override
  void initState() {
    setState(() {
      amount.text = '';
      phonenumber.text = '';
      dropdownValue = 'user';
    });
    super.initState();
  }

  getWallet() async {
    var val = await getWalletHistory();
    await getCountryCode();
    if (val == 'success') {
      isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Container(
        padding: EdgeInsets.all(media.width * 0.05),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(mainAxisSize: MainAxisSize.min, children: [
                DropdownButtonFormField(
                  decoration: InputDecoration(
                    filled: false,
                    fillColor: page,
                  ),
                  dropdownColor: page,
                  value: dropdownValue,
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                    });
                  },
                  items: dropdownItems,
                  style: GoogleFonts.notoSans(
                    fontSize: media.width * sixteen,
                    color: textColor,
                  ),
                ),
                TextFormField(
                  controller: amount,
                  style: GoogleFonts.notoSans(
                    fontSize: media.width * sixteen,
                    color: textColor,
                    letterSpacing: 1,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: languages[choosenLanguage]['text_enteramount'],
                    counterText: '',
                    hintStyle: GoogleFonts.notoSans(
                      fontSize: media.width * sixteen,
                      color: textColor.withOpacity(0.7),
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: (isDarkTheme == true)
                          ? textColor.withOpacity(0.2)
                          : inputfocusedUnderline,
                      width: 1.2,
                      style: BorderStyle.solid,
                    )),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: (isDarkTheme == true)
                          ? textColor.withOpacity(0.1)
                          : inputUnderline,
                      width: 1.2,
                      style: BorderStyle.solid,
                    )),
                  ),
                ),
                TextFormField(
                  controller: phonenumber,
                  onChanged: (val) {},
                  style: GoogleFonts.notoSans(
                    fontSize: media.width * sixteen,
                    color: textColor,
                    letterSpacing: 1,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: languages[choosenLanguage]['text_phone_number'],
                    counterText: '',
                    hintStyle: GoogleFonts.notoSans(
                      fontSize: media.width * sixteen,
                      color: textColor.withOpacity(0.7),
                    ),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: (isDarkTheme == true)
                          ? textColor.withOpacity(0.2)
                          : inputfocusedUnderline,
                      width: 1.2,
                      style: BorderStyle.solid,
                    )),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                      color: (isDarkTheme == true)
                          ? textColor.withOpacity(0.1)
                          : inputUnderline,
                      width: 1.2,
                      style: BorderStyle.solid,
                    )),
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                (error == true)
                    ? Text(
                        errortext,
                        style: const TextStyle(color: Colors.red),
                      )
                    : Container(),
                SizedBox(
                  height: media.width * 0.05,
                ),
                (isLoading == false)
                    ? Button(
                        onTap: () async {
                          // Navigator.pop(context);
                          setState(() {
                            isLoading = true;
                          });
                          if (phonenumber.text == '' || amount.text == '') {
                            setState(() {
                              error = true;
                              errortext = languages[choosenLanguage]
                                  ['text_fill_fileds'];
                              isLoading = false;
                            });
                          } else {
                            // Navigator.pop(context);
                            var result = await sharewalletfun(
                                amount: amount.text,
                                mobile: phonenumber.text,
                                role: dropdownValue);
                            if (result == 'success') {
                              // ignore: use_build_context_synchronously
                              Navigator.pop(context);
                              setState(() {
                                dropdownValue = 'user';
                                error = false;
                                errortext = '';

                                getWallet();
                                showtoast = true;
                              });
                            } else {
                              setState(() {
                                error = true;
                                errortext = result.toString();
                                isLoading = false;
                              });
                            }
                          }
                        },
                        text: languages[choosenLanguage]['text_credit_trans'],
                        width: media.width * 0.9,
                      )
                    : Container(
                        height: media.width * 0.12,
                        width: media.width * 0.9,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.circular(media.width * 0.02)),
                        child: SizedBox(
                          height: media.width * 0.06,
                          width: media.width * 0.07,
                          child: const CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        ),
                      ),
                SizedBox(
                  height: media.width * 0.02,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(media.width * 0.02),
                    child: MyText(
                      textAlign: TextAlign.center,
                      text: languages[choosenLanguage]['text_cancel'],
                      size: media.width * sixteen,
                      color: verifyDeclined,
                    ),
                  ),
                ),
              ]),
            ]),
      ),
    );
  }
}
