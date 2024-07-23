import 'package:flutter/material.dart';
import 'package:flutter_user/functions/functions.dart';
import 'package:flutter_user/pages/NavigatorPages/walletpage.dart';
import 'package:flutter_user/pages/noInternet/nointernet.dart';
import 'package:flutter_user/styles/styles.dart';
import 'package:flutter_user/translations/translation.dart';
import 'package:flutter_user/widgets/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class PaymentGatwaysPage extends StatefulWidget {
  dynamic from;
  dynamic url;
  PaymentGatwaysPage({super.key, this.from, this.url});

  @override
  State<PaymentGatwaysPage> createState() => _PaymentGatwaysPageState();
}

class _PaymentGatwaysPageState extends State<PaymentGatwaysPage> {
  bool pop = true;
  bool _success = false;
  late final WebViewController _controller;

  @override
  void initState() {
    // #docregion platform_features
    dynamic paymentUrl;
    if (widget.from == '1') {
      paymentUrl =
          '${widget.url}?amount=$addMoney&payment_for=request&currency=${userRequestData['requested_currency_symbol']}&user_id=${userDetails['id'].toString()}&request_id=${userRequestData['id'].toString()}';

      // PaymentGatwaysPage-checkout?amount=$addMoney&user_id=${userDetails['id']}&request_for=${userRequestData['id']}';
    } else {
      paymentUrl =
          '${widget.url}?amount=$addMoney&payment_for=wallet&currency=${walletBalance['currency_symbol']}&user_id=${userDetails['id'].toString()}';
    }
    late final PlatformWebViewControllerCreationParams params;

    params = const PlatformWebViewControllerCreationParams();

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('${widget.url}/payment/success')) {
              setState(() {
                pop = true;
                _success = true;
              });
            } else if (request.url.startsWith('${url}failure')) {
              setState(() {
                pop = false;
              });
            } else if (request.url.startsWith('${url}failure')) {
              setState(() {
                pop = true;
              });
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(paymentUrl));

    _controller = controller;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return PopScope(
      canPop: false,
      child: Material(
        child: Stack(
          children: [
            Container(
              height: media.height,
              width: media.width,
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              child: Column(
                children: [
                  if (pop == true)
                    Container(
                      width: media.width,
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.all(media.width * 0.05),
                      child: InkWell(
                          onTap: () {
                            Navigator.pop(context, true);
                          },
                          child: const Icon(Icons.arrow_back)),
                    ),
                  Expanded(
                    child: WebViewWidget(
                      controller: _controller,
                    ),
                  ),
                ],
              ),
            ),
            //payment success
            (_success == true)
                ? Positioned(
                    top: 0,
                    child: Container(
                      alignment: Alignment.center,
                      height: media.height * 1,
                      width: media.width * 1,
                      color: Colors.transparent.withOpacity(0.6),
                      child: Container(
                        padding: EdgeInsets.all(media.width * 0.05),
                        width: media.width * 0.9,
                        height: media.width * 0.8,
                        decoration: BoxDecoration(
                            color: page,
                            borderRadius:
                                BorderRadius.circular(media.width * 0.03)),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/images/paymentsuccess.png',
                              fit: BoxFit.contain,
                              width: media.width * 0.5,
                            ),
                            MyText(
                              text: languages[choosenLanguage]
                                  ['text_paymentsuccess'],
                              textAlign: TextAlign.center,
                              size: media.width * sixteen,
                              fontweight: FontWeight.w600,
                            ),
                            SizedBox(
                              height: media.width * 0.07,
                            ),
                            Button(
                                onTap: () {
                                  setState(() {
                                    _success = false;
                                    // super.detachFromGLContext();
                                    Navigator.pop(context, true);
                                  });
                                },
                                text: languages[choosenLanguage]['text_ok'])
                          ],
                        ),
                      ),
                    ))
                : Container(),

            //no internet
            (internet == false)
                ? Positioned(
                    top: 0,
                    child: NoInternet(
                      onTap: () {
                        setState(() {
                          internetTrue();
                        });
                      },
                    ))
                : Container(),
          ],
        ),
      ),
    );
  }
}
