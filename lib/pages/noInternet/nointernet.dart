import 'package:flutter/material.dart';
import '../../functions/functions.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';

// ignore: must_be_immutable
class NoInternet extends StatefulWidget {
  dynamic onTap;
  // ignore: use_key_in_widget_constructors
  NoInternet({required this.onTap});

  @override
  State<NoInternet> createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Container(
      height: media.height * 1,
      width: media.width * 1,
      color: topBar,
      padding: EdgeInsets.all(media.width * 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              SizedBox(
                width: media.width * 0.6,
                child: Image.asset(
                  'assets/images/noInternet.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              MyText(
                text: (languages.isNotEmpty && choosenLanguage != '')
                    ? languages[choosenLanguage]['text_nointernet']
                    : 'No Internet Connection',
                size: media.width * twentyfour,
                fontweight: FontWeight.w600,
                color: textColor,
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              MyText(
                text: (languages.isNotEmpty && choosenLanguage != '')
                    ? languages[choosenLanguage]['text_nointernetdesc']
                    : 'Please check your Internet connection, try enabling wifi or tey again later',
                size: media.width * fourteen,
                color: hintColor,
              ),
              SizedBox(
                height: media.width * 0.05,
              ),
              Button(
                  onTap: widget.onTap,
                  text: languages[choosenLanguage]['text_back_home'])
            ],
          )
        ],
      ),
    );
  }
}
