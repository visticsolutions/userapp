import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_user/pages/onTripPage/bookingwidgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:vector_math/vector_math.dart' as vector;
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:geolocator/geolocator.dart' as geolocs;
import 'package:share_plus/share_plus.dart';
import '../../functions/functions.dart';
import '../../functions/geohash.dart';
import '../../styles/styles.dart';
import '../../translations/translation.dart';
import '../../widgets/widgets.dart';
import '../NavigatorPages/pickcontacts.dart';
import '../chatPage/chat_page.dart';
import '../loadingPage/loading.dart';
import '../login/login.dart';
import '../noInternet/noInternet.dart';
import 'choosegoods.dart';
import 'drop_loc_select.dart';
import 'invoice.dart';
import 'map_page.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart' as fmlt;
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class BookingConfirmation extends StatefulWidget {
  dynamic type;

  //type = 1 is rental ride and type = null is regular ride
  BookingConfirmation({super.key, this.type});

  @override
  State<BookingConfirmation> createState() => _BookingConfirmationState();
}

bool serviceNotAvailable = false;
String promoCode = '';
dynamic promoStatus;
dynamic choosenVehicle;
int payingVia = 0;
dynamic timing;
dynamic mapPadding = 0.0;
String goodsSize = '';
bool noDriverFound = false;
var driverData = {};
var driversData = [];
dynamic choosenDateTime;
bool lowWalletBalance = false;
bool tripReqError = false;
List rentalOption = [];
int rentalChoosenOption = 0;
Animation<double>? _animation;
bool addCoupon = false;
bool isLoading = false;
List<fmlt.LatLng> fmpoly = [];
dynamic addLuggagePreferences;
dynamic addPetPreferences;

TextEditingController promoKey = TextEditingController();

class _BookingConfirmationState extends State<BookingConfirmation>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  TextEditingController updateAmount = TextEditingController();
  TextEditingController pickerName = TextEditingController();
  TextEditingController pickerNumber = TextEditingController();
  TextEditingController instructions = TextEditingController();
  final ScrollController _cont = ScrollController();
  final Map minutes = {};
  dynamic addressBottom;
  dynamic _addressBottom;
  List myMarker = [];
  Map myBearings = {};
  String _cancelReason = '';
  dynamic _controller;
  late PermissionStatus permission;
  bool bottomChooseMethod = false;
  bool islowwalletbalance = false;
  List gesture = [];
  dynamic start;
  final fm.MapController _fmController = fm.MapController();

  late Duration dateDifference;
  int daysDifferenceRoundedUp = 0;

  Location location = Location();
  bool _locationDenied = false;
  LatLng _center = const LatLng(41.4219057, -102.0840772);
  dynamic pinLocationIcon;
  dynamic pinLocationIcon2;
  dynamic animationController;
  bool _ontripBottom = false;
  bool _cancelling = false;
  bool _choosePayment = false;
  String _cancelCustomReason = '';
  dynamic timers;
  bool _dateTimePicker = false;
  bool showSos = false;
  bool notifyCompleted = false;
  bool _chooseGoodsType = false;
  dynamic _showInfoInt;
  dynamic _dist;
  bool _editUserDetails = false;
  String _cancellingError = '';
  GlobalKey iconKey = GlobalKey();
  GlobalKey iconDropKey = GlobalKey();
  GlobalKey iconDistanceKey = GlobalKey();
  var iconDropKeys = {};
  bool _cancel = false;
  List driverBck = [];
  bool currentpage = true;
  final _mapMarkerSC = StreamController<List<Marker>>();
  StreamSink<List<Marker>> get _mapMarkerSink => _mapMarkerSC.sink;
  Stream<List<Marker>> get mapMarkerStream => _mapMarkerSC.stream;
  bool dropConfirmed = false;

  bool isOneWayTrip = true;
  bool isFromDate = true;

  DateTime fromDate = DateTime.now().add(Duration(
      minutes:
          int.parse(userDetails['user_can_make_a_ride_after_x_miniutes'])));
  DateTime? toDate;
  double _isDateTimebottom = -1000;
  dynamic _dateTimeHeight = 0;
  bool nofromdate = false;
  @override
  void initState() {
    fmpoly.clear();
    WidgetsBinding.instance.addObserver(this);
    promoCode = '';
    mapPadding = 0.0;
    promoStatus = null;
    serviceNotAvailable = false;
    tripReqError = false;
    myBearings.clear();
    noDriverFound = false;
    etaDetails.clear();
    rentalOption.clear();
    currentpage = true;
    selectedGoodsId = '';
    addCoupon = false;
    choosenDateTime = null;
    confirmRideLater = false;
    promoKey.text = '';
    addPetPreferences = false;
    addLuggagePreferences = false;
    if (widget.type == 1 || widget.type == 2) {
      setState(() {
        dropConfirmed = true;
      });
    } else {
      setState(() {
        dropConfirmed = false;
      });
    }
    if (!ismulitipleride && userRequestData['accepted_at'] != null) {
      userRequestData.clear();
    }
    getLocs();

    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        _controller?.setMapStyle(mapStyle);
      }
      if (userRequestData.isNotEmpty) {
        ismulitipleride = true;
        getUserDetails(id: userRequestData['id']);
      } else {
        getUserDetails();
      }

      if (timers == null &&
          userRequestData.isNotEmpty &&
          userRequestData['accepted_at'] == null) {
        timer();
      }
      if (locationAllowed == true) {
        if (positionStream == null || positionStream!.isPaused) {
          positionStreamData();
        }
      }
    }
  }

  @override
  void dispose() {
    if (timers != null) {
      timers?.cancel;
    }

    _controller?.dispose();
    _controller = null;
    animationController?.dispose();

    super.dispose();
  }

//running timer
  timer() {
    if (userRequestData['is_bid_ride'] == 1) {
      timers = Timer.periodic(const Duration(seconds: 1), (timer) {
        valueNotifierTimer.incrementNotifier();
      });
    } else {
      timing =
          userRequestData['maximum_time_for_find_drivers_for_regular_ride'];
      if (mounted) {
        timers = Timer.periodic(const Duration(seconds: 1), (timer) async {
          if (timing != null) {
            if (userRequestData.isNotEmpty &&
                userDetails['accepted_at'] == null &&
                timing > 0) {
              timing--;
              valueNotifierBook.incrementNotifier();
            } else if (userRequestData.isNotEmpty &&
                userRequestData['accepted_at'] == null &&
                timing == 0) {
              var val = await cancelRequest();

              setState(() {
                noDriverFound = true;
              });

              timer.cancel();
              timing = null;
              if (val == 'logout') {
                navigateLogout();
              }
            } else {
              timer.cancel();
              timing = null;
            }
          } else {
            timer.cancel();
            timing = null;
          }
        });
      }
    }
  }

//create icon

  _capturePng(GlobalKey iconKeys) async {
    dynamic bitmap;

    try {
      RenderRepaintBoundary boundary =
          iconKeys.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();
      bitmap = BitmapDescriptor.fromBytes(pngBytes);
      // return pngBytes;
    } catch (e) {
      debugPrint(e.toString());
    }
    return bitmap;
  }

  addDropMarker() async {
    for (var i = 1; i < addressList.length; i++) {
      var testIcon = await _capturePng(iconDropKeys[i]);
      if (testIcon != null) {
        setState(() {
          myMarker.add(Marker(
              markerId: MarkerId((i + 1).toString()),
              icon: testIcon,
              position: addressList[i].latlng));
        });
      }
    }

    if (widget.type != 1) {
      LatLngBounds bound;
      if (userRequestData.isNotEmpty) {
        if (userRequestData['pick_lat'] > userRequestData['drop_lat'] &&
            userRequestData['pick_lng'] > userRequestData['drop_lng']) {
          bound = LatLngBounds(
              southwest: LatLng(
                  userRequestData['drop_lat'], userRequestData['drop_lng']),
              northeast: LatLng(
                  userRequestData['pick_lat'], userRequestData['pick_lng']));
        } else if (userRequestData['pick_lng'] > userRequestData['drop_lng']) {
          bound = LatLngBounds(
              southwest: LatLng(
                  userRequestData['pick_lat'], userRequestData['drop_lng']),
              northeast: LatLng(
                  userRequestData['drop_lat'], userRequestData['pick_lng']));
        } else if (userRequestData['pick_lat'] > userRequestData['drop_lat']) {
          bound = LatLngBounds(
              southwest: LatLng(
                  userRequestData['drop_lat'], userRequestData['pick_lng']),
              northeast: LatLng(
                  userRequestData['pick_lat'], userRequestData['drop_lng']));
        } else {
          bound = LatLngBounds(
              southwest: LatLng(
                  userRequestData['pick_lat'], userRequestData['pick_lng']),
              northeast: LatLng(
                  userRequestData['drop_lat'], userRequestData['drop_lng']));
        }
      } else {
        if (addressList
                    .firstWhere((element) => element.type == 'pickup')
                    .latlng
                    .latitude >
                addressList
                    .lastWhere((element) => element.type == 'drop')
                    .latlng
                    .latitude &&
            addressList
                    .firstWhere((element) => element.type == 'pickup')
                    .latlng
                    .longitude >
                addressList
                    .lastWhere((element) => element.type == 'drop')
                    .latlng
                    .longitude) {
          bound = LatLngBounds(
              southwest: addressList
                  .lastWhere((element) => element.type == 'drop')
                  .latlng,
              northeast: addressList
                  .firstWhere((element) => element.type == 'pickup')
                  .latlng);
        } else if (addressList
                .firstWhere((element) => element.type == 'pickup')
                .latlng
                .longitude >
            addressList
                .lastWhere((element) => element.type == 'drop')
                .latlng
                .longitude) {
          bound = LatLngBounds(
              southwest: LatLng(
                  addressList
                      .firstWhere((element) => element.type == 'pickup')
                      .latlng
                      .latitude,
                  addressList
                      .lastWhere((element) => element.type == 'drop')
                      .latlng
                      .longitude),
              northeast: LatLng(
                  addressList
                      .lastWhere((element) => element.type == 'drop')
                      .latlng
                      .latitude,
                  addressList
                      .firstWhere((element) => element.type == 'pickup')
                      .latlng
                      .longitude));
        } else if (addressList
                .firstWhere((element) => element.type == 'pickup')
                .latlng
                .latitude >
            addressList
                .lastWhere((element) => element.type == 'drop')
                .latlng
                .latitude) {
          bound = LatLngBounds(
              southwest: LatLng(
                  addressList
                      .lastWhere((element) => element.type == 'drop')
                      .latlng
                      .latitude,
                  addressList
                      .firstWhere((element) => element.type == 'pickup')
                      .latlng
                      .longitude),
              northeast: LatLng(
                  addressList
                      .firstWhere((element) => element.type == 'pickup')
                      .latlng
                      .latitude,
                  addressList
                      .lastWhere((element) => element.type == 'drop')
                      .latlng
                      .longitude));
        } else {
          bound = LatLngBounds(
              southwest: addressList
                  .firstWhere((element) => element.type == 'pickup')
                  .latlng,
              northeast: addressList
                  .lastWhere((element) => element.type == 'drop')
                  .latlng);
        }
      }
      CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bound, 50);
      _controller!.animateCamera(cameraUpdate);
      // CameraUpdate.newCameraPosition(CameraPosition(target: target))
    }
  }

  addMarker() async {
    var testIcon = await _capturePng(iconKey);
    if (testIcon != null) {
      setState(() {
        myMarker.add(Marker(
            markerId: const MarkerId('1'),
            icon: testIcon,
            position: (userRequestData.isEmpty)
                ? addressList
                    .firstWhere((element) => element.type == 'pickup')
                    .latlng
                : LatLng(
                    userRequestData['pick_lat'], userRequestData['pick_lng'])));
      });
    }
  }

  getPoly() async {
    fmpoly.clear();
    for (var i = 1; i < addressList.length; i++) {
      var api = await http.get(Uri.parse(
          'https://routing.openstreetmap.de/routed-car/route/v1/driving/${addressList[i - 1].latlng.longitude},${addressList[i - 1].latlng.latitude};${addressList[i].latlng.longitude},${addressList[i].latlng.latitude}?overview=false&geometries=polyline&steps=true'));
      if (api.statusCode == 200) {
        // ignore: no_leading_underscores_for_local_identifiers
        List _poly = jsonDecode(api.body)['routes'][0]['legs'][0]['steps'];
        // String polystring = _poly[5]['geometry'];
        polyline.clear();
        for (var e in _poly) {
          decodeEncodedPolyline(e['geometry']);
          // polystring = polystring + _poly[i]['geometry'];
        }

        setState(() {});
      }
    }
  }

//add distance marker
  addDistanceMarker(length) async {
    var testIcon = await _capturePng(iconDistanceKey);
    if (testIcon != null) {
      setState(() {
        if (polyList.isNotEmpty) {
          myMarker.add(Marker(
              markerId: const MarkerId('pointdistance'),
              icon: testIcon,
              position: polyList[length],
              anchor: const Offset(0.0, 1.0)));
        }
      });
    }
  }

  navigateLogout() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false);
  }

//add drop marker
  addPickDropMarker() async {
    if (mapType == 'google') {
      addMarker();
      // Future.delayed(const Duration(milliseconds: 200), () async {
      if (userRequestData.isNotEmpty &&
          userRequestData['is_rental'] != true &&
          userRequestData['drop_address'] != null) {
        addDropMarker();

        if (userRequestData.isEmpty) {
          polyline.add(
            Polyline(
                polylineId: const PolylineId('1'),
                color: buttonColor,
                points: [
                  addressList
                      .firstWhere((element) => element.id == 'pickup')
                      .latlng,
                  addressList
                      .firstWhere((element) => element.id == 'pickup')
                      .latlng
                ],
                geodesic: false,
                width: 5),
          );
        } else {
          polyline.add(
            Polyline(
                polylineId: const PolylineId('1'),
                color: buttonColor,
                points: [
                  LatLng(double.parse(userRequestData['pick_lat'].toString()),
                      double.parse(userRequestData['pick_lng'].toString())),
                  LatLng(double.parse(userRequestData['pick_lat'].toString()),
                      double.parse(userRequestData['pick_lng'].toString()))
                ],
                geodesic: false,
                width: 5),
          );
        }

        getPolylines();
        // addToast();
      } else if (widget.type == null) {
        addDropMarker();
        if (userRequestData.isEmpty) {
          polyline.add(
            Polyline(
                polylineId: const PolylineId('1'),
                color: buttonColor,
                points: [
                  addressList
                      .firstWhere((element) => element.type == 'pickup')
                      .latlng,
                  addressList
                      .firstWhere((element) => element.type == 'pickup')
                      .latlng
                ],
                geodesic: false,
                width: 5),
          );
        } else {
          polyline.add(
            Polyline(
                polylineId: const PolylineId('1'),
                color: buttonColor,
                points: [
                  LatLng(double.parse(userRequestData['pick_lat'].toString()),
                      double.parse(userRequestData['pick_lng'].toString())),
                  LatLng(double.parse(userRequestData['pick_lat'].toString()),
                      double.parse(userRequestData['pick_lng'].toString()))
                ],
                geodesic: false,
                width: 5),
          );
        }
        await getPolylines();
        // addToast();
      } else {
        if (userRequestData.isNotEmpty) {
          CameraUpdate cameraUpdate = CameraUpdate.newLatLng(
              LatLng(userRequestData['pick_lat'], userRequestData['pick_lng']));
          _controller!.animateCamera(cameraUpdate);
        } else {
          CameraUpdate cameraUpdate = CameraUpdate.newLatLng(addressList
              .firstWhere((element) => element.type == 'pickup')
              .latlng);
          _controller!.animateCamera(cameraUpdate);
        }
      }
    } else {
      if (addressList.length > 1) {
        getPoly();
        double lat = (addressList[0].latlng.latitude +
                addressList[addressList.length - 1].latlng.latitude) /
            2;
        double lon = (addressList[0].latlng.longitude +
                addressList[addressList.length - 1].latlng.longitude) /
            2;
        _center = LatLng(lat, lon);
        _fmController.move(
            fmlt.LatLng(_center.latitude, _center.longitude), 13);
        // setState(() {

        // });
      }
    }
  }

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

//get location permission and location details
  getLocs() async {
    setState(() {
      _center = (userRequestData.isEmpty)
          ? addressList.firstWhere((element) => element.type == 'pickup').latlng
          : LatLng(userRequestData['pick_lat'], userRequestData['pick_lng']);
    });
    if (await geolocs.GeolocatorPlatform.instance.isLocationServiceEnabled()) {
      serviceEnabled = true;
    } else {
      serviceEnabled = false;
    }
    final Uint8List markerIcon;
    final Uint8List markerIcon2;
    if (choosenTransportType == 0) {
      markerIcon = await getBytesFromAsset('assets/images/top-taxi.png', 40);
      pinLocationIcon = BitmapDescriptor.fromBytes(markerIcon);
      markerIcon2 = await getBytesFromAsset('assets/images/bike.png', 40);
      pinLocationIcon2 = BitmapDescriptor.fromBytes(markerIcon2);
    } else {
      markerIcon =
          await getBytesFromAsset('assets/images/deliveryicon.png', 40);
      pinLocationIcon = BitmapDescriptor.fromBytes(markerIcon);
      markerIcon2 = await getBytesFromAsset('assets/images/bike.png', 40);
      pinLocationIcon2 = BitmapDescriptor.fromBytes(markerIcon2);
    }

    choosenVehicle = null;
    _dist = null;

    if (widget.type == 2 || isOutStation == true) {
      var val = await etaRequest();
      if (val == 'logout') {
        navigateLogout();
      }
    }
    if (widget.type == 1) {
      var val = await rentalEta();
      if (val == 'logout') {
        navigateLogout();
      }
    }

    permission = await location.hasPermission();

    if (permission == PermissionStatus.denied ||
        permission == PermissionStatus.deniedForever) {
      setState(() {
        locationAllowed = false;
      });
    } else if (permission == PermissionStatus.granted ||
        permission == PermissionStatus.grantedLimited) {
      locationAllowed = true;
      if (locationAllowed == true) {
        if (positionStream == null || positionStream!.isPaused) {
          positionStreamData();
        }
      }
      setState(() {});
    }

    Future.delayed(const Duration(milliseconds: 500), () async {
      await addPickDropMarker();
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _controller = controller;
      _controller?.setMapStyle(mapStyle);
    });
  }

  @override
  Widget build(BuildContext context) {
    GeoHasher geo = GeoHasher();

    double lat = 0.0144927536231884;
    double lon = 0.0181818181818182;
    double lowerLat = (userRequestData.isEmpty && addressList.isNotEmpty)
        ? addressList
                .firstWhere((element) => element.type == 'pickup')
                .latlng
                .latitude -
            (lat * 1.24)
        : (userRequestData.isNotEmpty && addressList.isEmpty)
            ? userRequestData['pick_lat'] - (lat * 1.24)
            : 0.0;
    double lowerLon = (userRequestData.isEmpty && addressList.isNotEmpty)
        ? addressList
                .firstWhere((element) => element.type == 'pickup')
                .latlng
                .longitude -
            (lon * 1.24)
        : (userRequestData.isNotEmpty && addressList.isEmpty)
            ? userRequestData['pick_lng'] - (lon * 1.24)
            : 0.0;

    double greaterLat = (userRequestData.isEmpty && addressList.isNotEmpty)
        ? addressList
                .firstWhere((element) => element.type == 'pickup')
                .latlng
                .latitude +
            (lat * 1.24)
        : (userRequestData.isNotEmpty && addressList.isEmpty)
            ? userRequestData['pick_lat'] - (lat * 1.24)
            : 0.0;
    double greaterLon = (userRequestData.isEmpty && addressList.isNotEmpty)
        ? addressList
                .firstWhere((element) => element.type == 'pickup')
                .latlng
                .longitude +
            (lon * 1.24)
        : (userRequestData.isNotEmpty && addressList.isEmpty)
            ? userRequestData['pick_lng'] - (lat * 1.24)
            : 0.0;
    var lower = geo.encode(lowerLon, lowerLat);
    var higher = geo.encode(greaterLon, greaterLat);

    var fdb = FirebaseDatabase.instance
        .ref('drivers')
        .orderByChild('g')
        .startAt(lower)
        .endAt(higher);

    popFunction() {
      if (userRequestData.isNotEmpty &&
          userRequestData['accepted_at'] == null) {
        return true;
      } else {
        return false;
      }
    }

    var media = MediaQuery.of(context).size;
    return PopScope(
      canPop: popFunction(),
      onPopInvoked: (did) {
        noDriverFound = false;
        tripReqError = false;
        serviceNotAvailable = false;
        if (userRequestData.isNotEmpty &&
            userRequestData['accepted_at'] == null) {
        } else {
          if (widget.type == null) {
            if (dropConfirmed) {
              setState(() {
                dropConfirmed = false;
                promoStatus = false;
                addCoupon = false;
                promoKey.clear();
              });
            } else {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Maps()),
                  (route) => false);

              addressList.removeWhere((element) => element.id == 'drop');
              ismulitipleride = false;
              etaDetails.clear();
              promoKey.clear();
              promoStatus = null;
              promoStatus = false;
              addCoupon = false;
              rentalOption.clear();
              myMarker.clear();
              dropStopList.clear();
              isOutStation = false;
            }
          } else {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Maps()),
                (route) => false);
            addressList.removeWhere((element) => element.id == 'drop');
            isRentalRide = false;
            isOutStation = false;
            ismulitipleride = false;
            etaDetails.clear();
            promoKey.clear();
            promoStatus = null;
            promoStatus = false;
            addCoupon = false;
            rentalOption.clear();
            myMarker.clear();
            dropStopList.clear();
          }
        }
      },
      child: Material(
        child: Directionality(
          textDirection: (languageDirection == 'rtl')
              ? ui.TextDirection.rtl
              : ui.TextDirection.ltr,
          child: Container(
            height: media.height * 1,
            width: media.width * 1,
            color: page,
            child: ValueListenableBuilder(
                valueListenable: valueNotifierBook.value,
                builder: (context, value, child) {
                  if (_controller != null) {
                    mapPadding = media.width * 1;
                  }
                  if (cancelRequestByUser == true) {
                    myMarker.clear();
                    polyline.clear();
                    addressList
                        .removeWhere((element) => element.type == 'drop');
                    ismulitipleride = false;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const Maps()),
                          (route) => false);
                    });
                  }
                  if (userRequestData['is_completed'] == 1 &&
                      currentpage == true) {
                    currentpage = false;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Invoice()),
                          (route) => false);
                    });
                  }
                  if (userRequestData.isNotEmpty &&
                      timing == null &&
                      userRequestData['accepted_at'] == null) {
                    timer();
                  } else if (userRequestData.isNotEmpty &&
                      userRequestData['accepted_at'] != null) {
                    timing = null;
                  }
                  if (userRequestData.isNotEmpty &&
                      userRequestData['accepted_at'] != null) {
                    if (myMarker
                        .where((element) =>
                            element.markerId == const MarkerId('pointdistance'))
                        .isNotEmpty) {
                      myMarker.removeWhere((element) =>
                          element.markerId == const MarkerId('pointdistance'));
                    }
                  }
                  return StreamBuilder<DatabaseEvent>(
                      stream: (userRequestData['driverDetail'] == null &&
                              pinLocationIcon != null)
                          ? fdb.onValue.asBroadcastStream()
                          : null,
                      builder: (context, AsyncSnapshot<DatabaseEvent> event) {
                        if (event.hasData) {
                          if (event.data!.snapshot.value != null) {
                            if (userRequestData['accepted_at'] == null) {
                              DataSnapshot snapshots = event.data!.snapshot;
                              // ignore: unnecessary_null_comparison
                              if (snapshots != null &&
                                  choosenVehicle != null &&
                                  etaDetails.isNotEmpty) {
                                driversData = [];
                                // ignore: avoid_function_literals_in_foreach_calls
                                snapshots.children.forEach((element) {
                                  driversData.add(element.value);
                                });
                                // ignore: avoid_function_literals_in_foreach_calls
                                driversData.forEach((e) {
                                  if (e['is_active'] == 1 &&
                                      e['is_available'] == true) {
                                    if (((choosenTransportType == 0 && e['transport_type'] == 'taxi') ||
                                            (choosenTransportType == 0 &&
                                                e['transport_type'] ==
                                                    'both')) &&
                                        ((e['vehicle_types'] != null && ((widget.type != 1 && e['vehicle_types'].contains(etaDetails[choosenVehicle]['type_id'])) || (widget.type == 1 && e['vehicle_types'].contains(rentalOption[choosenVehicle]['type_id'])))) ||
                                            ((widget.type != 1 && e['vehicle_type'] == etaDetails[choosenVehicle]['type_id']) ||
                                                (widget.type == 1 &&
                                                    e['vehicle_type'] ==
                                                        rentalOption[choosenVehicle]
                                                            ['type_id'])))) {
                                      DateTime dt =
                                          DateTime.fromMillisecondsSinceEpoch(
                                              e['updated_at']);
                                      if (DateTime.now()
                                              .difference(dt)
                                              .inMinutes <=
                                          2) {
                                        if (myMarker
                                            .where((element) => element.markerId
                                                .toString()
                                                .contains(
                                                    'car#${e['id']}#${e['vehicle_type_icon']}'))
                                            .isEmpty) {
                                          myMarker.add(Marker(
                                            markerId: MarkerId(
                                                'car#${e['id']}#${e['vehicle_type_icon']}'),
                                            rotation: (myBearings[
                                                        e['id'].toString()] !=
                                                    null)
                                                ? myBearings[e['id'].toString()]
                                                : 0.0,
                                            position:
                                                LatLng(e['l'][0], e['l'][1]),
                                            icon: (e['vehicle_type_icon'] ==
                                                    'motor_bike')
                                                ? pinLocationIcon2
                                                : pinLocationIcon,
                                          ));
                                        } else if (_controller != null ||
                                            mapType != 'google') {
                                          var dist = calculateDistance(
                                              myMarker
                                                  .lastWhere((element) => element
                                                      .markerId
                                                      .toString()
                                                      .contains(
                                                          'car#${e['id']}#${e['vehicle_type_icon']}'))
                                                  .position
                                                  .latitude,
                                              myMarker
                                                  .lastWhere((element) => element
                                                      .markerId
                                                      .toString()
                                                      .contains(
                                                          'car#${e['id']}#${e['vehicle_type_icon']}'))
                                                  .position
                                                  .longitude,
                                              e['l'][0],
                                              e['l'][1]);
                                          if (dist > 100) {
                                            if (myMarker
                                                        .lastWhere((element) =>
                                                            element.markerId
                                                                .toString()
                                                                .contains(
                                                                    'car#${e['id']}#${e['vehicle_type_icon']}'))
                                                        .position
                                                        .latitude !=
                                                    e['l'][0] ||
                                                myMarker
                                                            .lastWhere((element) =>
                                                                element.markerId
                                                                    .toString()
                                                                    .contains(
                                                                        'car#${e['id']}#${e['vehicle_type_icon']}'))
                                                            .position
                                                            .longitude !=
                                                        e['l'][1] &&
                                                    _controller != null ||
                                                mapType != 'google') {
                                              animationController =
                                                  AnimationController(
                                                duration: const Duration(
                                                    milliseconds:
                                                        1500), //Animation duration of marker

                                                vsync: this, //From the widget
                                              );
                                              animateCar(
                                                  myMarker
                                                      .lastWhere((element) =>
                                                          element.markerId
                                                              .toString()
                                                              .contains(
                                                                  'car#${e['id']}#${e['vehicle_type_icon']}'))
                                                      .position
                                                      .latitude,
                                                  myMarker
                                                      .lastWhere((element) =>
                                                          element.markerId
                                                              .toString()
                                                              .contains(
                                                                  'car#${e['id']}#${e['vehicle_type_icon']}'))
                                                      .position
                                                      .longitude,
                                                  e['l'][0],
                                                  e['l'][1],
                                                  _mapMarkerSink,
                                                  this,
                                                  'car#${e['id']}#${e['vehicle_type_icon']}',
                                                  e['id'],
                                                  (driverData['vehicle_type_icon'] ==
                                                          'motor_bike')
                                                      ? pinLocationIcon2
                                                      : pinLocationIcon);
                                            }
                                          }
                                        }
                                      }
                                    } else if (((choosenTransportType == 1 && e['transport_type'] == 'delivery') ||
                                            choosenTransportType == 1 &&
                                                e['transport_type'] ==
                                                    'both') &&
                                        ((e['vehicle_types'] != null && ((widget.type != 1 && e['vehicle_types'].contains(etaDetails[choosenVehicle]['type_id'])) || (widget.type == 1 && e['vehicle_types'].contains(rentalOption[choosenVehicle]['type_id'])))) ||
                                            ((widget.type != 1 && e['vehicle_type'] == etaDetails[choosenVehicle]['type_id']) ||
                                                (widget.type == 1 &&
                                                    e['vehicle_type'] ==
                                                        rentalOption[choosenVehicle]
                                                            ['type_id'])))) {
                                      DateTime dt =
                                          DateTime.fromMillisecondsSinceEpoch(
                                              e['updated_at']);
                                      if (DateTime.now()
                                              .difference(dt)
                                              .inMinutes <=
                                          2) {
                                        if (myMarker
                                            .where((element) => element.markerId
                                                .toString()
                                                .contains(
                                                    'car#${e['id']}#${e['vehicle_type_icon']}'))
                                            .isEmpty) {
                                          myMarker.add(Marker(
                                            markerId: MarkerId(
                                                'car#${e['id']}#${e['vehicle_type_icon']}'),
                                            rotation: (myBearings[
                                                        e['id'].toString()] !=
                                                    null)
                                                ? myBearings[e['id'].toString()]
                                                : 0.0,
                                            position:
                                                LatLng(e['l'][0], e['l'][1]),
                                            icon: (e['vehicle_type_icon'] ==
                                                    'motor_bike')
                                                ? pinLocationIcon2
                                                : pinLocationIcon,
                                          ));
                                        } else if (_controller != null ||
                                            mapType != 'google') {
                                          var dist = calculateDistance(
                                              myMarker
                                                  .lastWhere((element) => element
                                                      .markerId
                                                      .toString()
                                                      .contains(
                                                          'car#${e['id']}#${e['vehicle_type_icon']}'))
                                                  .position
                                                  .latitude,
                                              myMarker
                                                  .lastWhere((element) => element
                                                      .markerId
                                                      .toString()
                                                      .contains(
                                                          'car#${e['id']}#${e['vehicle_type_icon']}'))
                                                  .position
                                                  .longitude,
                                              e['l'][0],
                                              e['l'][1]);
                                          if (dist > 100) {
                                            if (myMarker
                                                        .lastWhere((element) =>
                                                            element.markerId
                                                                .toString()
                                                                .contains(
                                                                    'car#${e['id']}#${e['vehicle_type_icon']}'))
                                                        .position
                                                        .latitude !=
                                                    e['l'][0] ||
                                                myMarker
                                                            .lastWhere((element) =>
                                                                element.markerId
                                                                    .toString()
                                                                    .contains(
                                                                        'car#${e['id']}#${e['vehicle_type_icon']}'))
                                                            .position
                                                            .longitude !=
                                                        e['l'][1] &&
                                                    _controller != null ||
                                                mapType != 'google') {
                                              animationController =
                                                  AnimationController(
                                                duration: const Duration(
                                                    milliseconds:
                                                        1500), //Animation duration of marker

                                                vsync: this, //From the widget
                                              );
                                              animateCar(
                                                  myMarker
                                                      .lastWhere((element) =>
                                                          element.markerId
                                                              .toString()
                                                              .contains(
                                                                  'car#${e['id']}#${e['vehicle_type_icon']}'))
                                                      .position
                                                      .latitude,
                                                  myMarker
                                                      .lastWhere((element) =>
                                                          element.markerId
                                                              .toString()
                                                              .contains(
                                                                  'car#${e['id']}#${e['vehicle_type_icon']}'))
                                                      .position
                                                      .longitude,
                                                  e['l'][0],
                                                  e['l'][1],
                                                  _mapMarkerSink,
                                                  this,
                                                  // _controller,
                                                  'car#${e['id']}#${e['vehicle_type_icon']}',
                                                  e['id'],
                                                  (driverData['vehicle_type_icon'] ==
                                                          'motor_bike')
                                                      ? pinLocationIcon2
                                                      : pinLocationIcon);
                                            }
                                          }
                                        }
                                      }
                                    } else {
                                      if (myMarker
                                          .where((element) => element.markerId
                                              .toString()
                                              .contains(
                                                  'car#${e['id']}#${e['vehicle_type_icon']}'))
                                          .isNotEmpty) {
                                        myMarker.removeWhere((element) =>
                                            element.markerId.toString().contains(
                                                'car#${e['id']}#${e['vehicle_type_icon']}'));
                                      }
                                    }
                                  } else {
                                    if (myMarker
                                        .where((element) => element.markerId
                                            .toString()
                                            .contains(
                                                'car#${e['id']}#${e['vehicle_type_icon']}'))
                                        .isNotEmpty) {
                                      myMarker.removeWhere((element) =>
                                          element.markerId.toString().contains(
                                              'car#${e['id']}#${e['vehicle_type_icon']}'));
                                    }
                                  }
                                });
                              }
                            }
                          }
                        }

                        return StreamBuilder<DatabaseEvent>(
                            stream: (userRequestData['driverDetail'] != null &&
                                    pinLocationIcon != null)
                                ? FirebaseDatabase.instance
                                    .ref(
                                        'drivers/driver_${userRequestData['driverDetail']['data']['id']}')
                                    .onValue
                                    .asBroadcastStream()
                                : null,
                            builder:
                                (context, AsyncSnapshot<DatabaseEvent> event) {
                              if (event.hasData) {
                                if (event.data!.snapshot.value != null) {
                                  if (userRequestData['accepted_at'] != null) {
                                    driversData.clear();
                                    if (myMarker.length > 3) {
                                      myMarker.removeWhere((element) => element
                                          .markerId
                                          .toString()
                                          .contains('car'));
                                    }

                                    DataSnapshot snapshots =
                                        event.data!.snapshot;
                                    // ignore: unnecessary_null_comparison
                                    if (snapshots != null) {
                                      driverData = jsonDecode(
                                          jsonEncode(snapshots.value));
                                      if (userRequestData != {}) {
                                        if (userRequestData['arrived_at'] ==
                                            null) {
                                          var distCalc = calculateDistance(
                                              userRequestData['pick_lat'],
                                              userRequestData['pick_lng'],
                                              driverData['l'][0],
                                              driverData['l'][1]);
                                          _dist = double.parse(
                                              (distCalc / 1000).toString());
                                        } else if (userRequestData[
                                                    'is_rental'] !=
                                                true &&
                                            userRequestData['drop_lat'] !=
                                                null) {
                                          var distCalc = calculateDistance(
                                            driverData['l'][0],
                                            driverData['l'][1],
                                            userRequestData['drop_lat'],
                                            userRequestData['drop_lng'],
                                          );
                                          _dist = double.parse(
                                              (distCalc / 1000).toString());
                                        }
                                        if (myMarker
                                            .where((element) => element.markerId
                                                .toString()
                                                .contains(
                                                    'car#${driverData['id']}#${driverData['vehicle_type_icon']}'))
                                            .isEmpty) {
                                          myMarker.add(Marker(
                                            markerId: MarkerId(
                                                'car#${driverData['id']}#${driverData['vehicle_type_icon']}'),
                                            rotation: (myBearings[
                                                        driverData['id']
                                                            .toString()] !=
                                                    null)
                                                ? myBearings[
                                                    driverData['id'].toString()]
                                                : 0.0,
                                            position: LatLng(driverData['l'][0],
                                                driverData['l'][1]),
                                            icon: (driverData[
                                                        'vehicle_type_icon'] ==
                                                    'motor_bike')
                                                ? pinLocationIcon2
                                                : pinLocationIcon,
                                          ));
                                        } else if (_controller != null ||
                                            mapType != 'google') {
                                          var dist = calculateDistance(
                                              myMarker
                                                  .lastWhere((element) => element
                                                      .markerId
                                                      .toString()
                                                      .contains(
                                                          'car#${driverData['id']}#${driverData['vehicle_type_icon']}'))
                                                  .position
                                                  .latitude,
                                              myMarker
                                                  .lastWhere((element) => element
                                                      .markerId
                                                      .toString()
                                                      .contains(
                                                          'car#${driverData['id']}#${driverData['vehicle_type_icon']}'))
                                                  .position
                                                  .longitude,
                                              driverData['l'][0],
                                              driverData['l'][1]);
                                          if (dist > 100) {
                                            if (myMarker
                                                        .lastWhere((element) =>
                                                            element.markerId
                                                                .toString()
                                                                .contains(
                                                                    'car#${driverData['id']}#${driverData['vehicle_type_icon']}'))
                                                        .position
                                                        .latitude !=
                                                    driverData['l'][0] ||
                                                myMarker
                                                            .lastWhere((element) =>
                                                                element.markerId
                                                                    .toString()
                                                                    .contains(
                                                                        'car#${driverData['id']}#${driverData['vehicle_type_icon']}'))
                                                            .position
                                                            .longitude !=
                                                        driverData['l'][1] &&
                                                    _controller != null ||
                                                mapType != 'google') {
                                              animationController =
                                                  AnimationController(
                                                duration: const Duration(
                                                    milliseconds:
                                                        1500), //Animation duration of marker

                                                vsync: this, //From the widget
                                              );

                                              animateCar(
                                                  myMarker
                                                      .lastWhere((element) =>
                                                          element.markerId
                                                              .toString()
                                                              .contains(
                                                                  'car#${driverData['id']}#${driverData['vehicle_type_icon']}'))
                                                      .position
                                                      .latitude,
                                                  myMarker
                                                      .lastWhere((element) =>
                                                          element.markerId
                                                              .toString()
                                                              .contains(
                                                                  'car#${driverData['id']}#${driverData['vehicle_type_icon']}'))
                                                      .position
                                                      .longitude,
                                                  driverData['l'][0],
                                                  driverData['l'][1],
                                                  _mapMarkerSink,
                                                  this,
                                                  // _controller,
                                                  'car#${driverData['id']}#${driverData['vehicle_type_icon']}',
                                                  driverData['id'],
                                                  (driverData['vehicle_type_icon'] ==
                                                          'motor_bike')
                                                      ? pinLocationIcon2
                                                      : pinLocationIcon);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                              return Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                      height: media.height * 1,
                                      width: media.width * 1,
                                      //get drivers location updates
                                      child: (mapType == 'google')
                                          ? StreamBuilder<List<Marker>>(
                                              stream: mapMarkerStream,
                                              builder: (context, snapshot) {
                                                return GoogleMap(
                                                  padding: EdgeInsets.only(
                                                      bottom: mapPadding,
                                                      top: media.height * 0.1 +
                                                          MediaQuery.of(context)
                                                              .padding
                                                              .top),
                                                  onMapCreated: _onMapCreated,
                                                  compassEnabled: false,
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                    target: _center,
                                                    zoom: 11.0,
                                                  ),
                                                  markers: Set<Marker>.from(
                                                      myMarker),
                                                  polylines: polyline,
                                                  minMaxZoomPreference:
                                                      const MinMaxZoomPreference(
                                                          0.0, 20.0),
                                                  myLocationButtonEnabled:
                                                      false,
                                                  buildingsEnabled: false,
                                                  zoomControlsEnabled: false,
                                                  myLocationEnabled: true,
                                                );
                                              })
                                          : StreamBuilder<List<Marker>>(
                                              stream: mapMarkerStream,
                                              builder: (context, snapshot) {
                                                return fm.FlutterMap(
                                                  mapController: _fmController,
                                                  options: fm.MapOptions(
                                                      // ignore: deprecated_member_use
                                                      interactiveFlags: ~fm
                                                          .InteractiveFlag
                                                          .doubleTapZoom,
                                                      initialCenter:
                                                          fmlt.LatLng(
                                                              _center.latitude,
                                                              _center
                                                                  .longitude),
                                                      initialZoom: 13,
                                                      onTap: (P, L) {
                                                        setState(() {});
                                                      }),
                                                  children: [
                                                    fm.TileLayer(
                                                      // minZoom: 10,
                                                      urlTemplate:
                                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                      userAgentPackageName:
                                                          'com.example.app',
                                                    ),

                                                    fm.PolylineLayer(
                                                      polylines: [
                                                        fm.Polyline(
                                                            points: fmpoly,
                                                            color: Colors.blue,
                                                            strokeWidth: 4),
                                                      ],
                                                    ),

                                                    fm.MarkerLayer(
                                                      markers: [
                                                        for (var k = 0;
                                                            k <
                                                                addressList
                                                                    .length;
                                                            k++)
                                                          fm.Marker(
                                                              alignment: Alignment
                                                                  .topCenter,
                                                              point: fmlt.LatLng(
                                                                  addressList[k]
                                                                      .latlng
                                                                      .latitude,
                                                                  addressList[k]
                                                                      .latlng
                                                                      .longitude),
                                                              width: (k == 0 ||
                                                                      k ==
                                                                          addressList.length -
                                                                              1)
                                                                  ? media.width *
                                                                      0.7
                                                                  : 10,
                                                              height: (k == 0 ||
                                                                      k ==
                                                                          addressList.length -
                                                                              1)
                                                                  ? media.width * 0.15 +
                                                                      10
                                                                  : 18,
                                                              child:
                                                                  (k == 0 ||
                                                                          k ==
                                                                              addressList.length - 1)
                                                                      ? Column(
                                                                          children: [
                                                                            Container(
                                                                                decoration: BoxDecoration(
                                                                                    gradient: LinearGradient(colors: [
                                                                                      (isDarkTheme == true) ? const Color(0xff000000) : const Color(0xffFFFFFF),
                                                                                      (isDarkTheme == true) ? const Color(0xff808080) : const Color(0xffEFEFEF),
                                                                                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                                                                    borderRadius: BorderRadius.circular(5)),
                                                                                width: (platform == TargetPlatform.android) ? media.width * 0.7 : media.width * 0.9,
                                                                                padding: const EdgeInsets.all(5),
                                                                                child: (userRequestData.isNotEmpty)
                                                                                    ? Text(
                                                                                        userRequestData['pick_address'],
                                                                                        maxLines: 1,
                                                                                        overflow: TextOverflow.fade,
                                                                                        softWrap: false,
                                                                                        style: GoogleFonts.notoSans(color: textColor, fontSize: (platform == TargetPlatform.android) ? media.width * twelve : media.width * sixteen),
                                                                                      )
                                                                                    : (addressList.where((element) => element.type == 'pickup').isNotEmpty)
                                                                                        ? Text(
                                                                                            addressList[k].address,
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.fade,
                                                                                            softWrap: false,
                                                                                            style: GoogleFonts.notoSans(color: textColor, fontSize: (platform == TargetPlatform.android) ? media.width * twelve : media.width * sixteen),
                                                                                          )
                                                                                        : Container()),
                                                                            const SizedBox(
                                                                              height: 10,
                                                                            ),
                                                                            Container(
                                                                              decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage((addressList[k].type == 'pickup') ? 'assets/images/pick_icon.png' : 'assets/images/drop_icon.png'), fit: BoxFit.contain)),
                                                                              height: (platform == TargetPlatform.android) ? media.width * 0.07 : media.width * 0.12,
                                                                              width: (platform == TargetPlatform.android) ? media.width * 0.07 : media.width * 0.12,
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : MyText(
                                                                          text:
                                                                              k.toString(),
                                                                          size:
                                                                              16,
                                                                          fontweight:
                                                                              FontWeight.bold,
                                                                          color:
                                                                              Colors.red,
                                                                        )),
                                                        for (var i = 0;
                                                            i < myMarker.length;
                                                            i++)
                                                          fm.Marker(
                                                              // key: Key('10'),
                                                              // rotate: true,
                                                              alignment:
                                                                  Alignment
                                                                      .topCenter,
                                                              point: fmlt.LatLng(
                                                                  myMarker[i]
                                                                      .position
                                                                      .latitude,
                                                                  myMarker[i]
                                                                      .position
                                                                      .longitude),
                                                              width:
                                                                  media.width *
                                                                      0.7,
                                                              height: 50,
                                                              child:
                                                                  RotationTransition(
                                                                      turns: AlwaysStoppedAnimation(
                                                                          myMarker[i].rotation /
                                                                              360),
                                                                      child: (myMarker[i].markerId.toString().contains('car#') ==
                                                                              true)
                                                                          ? Image
                                                                              .asset(
                                                                              (myMarker[i].markerId.toString().replaceAll('MarkerId(', '').replaceAll(')', '').split('#')[2].toString() == 'taxi')
                                                                                  ? 'assets/images/top-taxi.png'
                                                                                  : (myMarker[i].markerId.toString().replaceAll('MarkerId(', '').replaceAll(')', '').split('#')[2].toString() == 'truck')
                                                                                      ? 'assets/images/deliveryicon.png'
                                                                                      : 'assets/images/bike.png',
                                                                            )
                                                                          : Container()))
                                                      ],
                                                    ),

                                                    // fm.MarkerLayer()

                                                    const fm
                                                        .RichAttributionWidget(
                                                      attributions: [],
                                                    ),
                                                  ],
                                                );
                                              })),
                                  Positioned(
                                    top: MediaQuery.of(context).padding.top +
                                        12.5,
                                    child: SizedBox(
                                      width: media.width * 0.9,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                    color: (userRequestData
                                                                .isNotEmpty &&
                                                            userRequestData[
                                                                    'accepted_at'] ==
                                                                null)
                                                        ? Colors.transparent
                                                        : Colors.black
                                                            .withOpacity(0.2),
                                                    spreadRadius: 2,
                                                    blurRadius: 2)
                                              ],
                                              // color: (userRequestData
                                              //             .isNotEmpty &&
                                              //         userRequestData[
                                              //                 'accepted_at'] ==
                                              //             null)
                                              //     ? Colors.transparent
                                              //     : page
                                            ),
                                            child: Material(
                                              color: (userRequestData
                                                          .isNotEmpty &&
                                                      userRequestData[
                                                              'accepted_at'] ==
                                                          null)
                                                  ? Colors.transparent
                                                  : page,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      media.width * 0.05),
                                              // color: page,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        media.width * 0.05),
                                                onTap: () {
                                                  noDriverFound = false;
                                                  tripReqError = false;
                                                  serviceNotAvailable = false;
                                                  if (userRequestData
                                                          .isNotEmpty &&
                                                      userRequestData[
                                                              'accepted_at'] ==
                                                          null) {
                                                  } else {
                                                    if (widget.type == null) {
                                                      if (dropConfirmed) {
                                                        setState(() {
                                                          dropConfirmed = false;
                                                          promoStatus = false;
                                                          addCoupon = false;
                                                          promoKey.clear();
                                                        });
                                                      } else {
                                                        Navigator.pushAndRemoveUntil(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const Maps()),
                                                            (route) => false);
                                                        ismulitipleride = false;
                                                        isOutStation = false;
                                                        etaDetails.clear();
                                                        promoKey.clear();
                                                        promoStatus = null;
                                                        promoStatus = false;
                                                        addCoupon = false;

                                                        rentalOption.clear();
                                                        myMarker.clear();
                                                        dropStopList.clear();
                                                        addressList.removeWhere(
                                                            (element) =>
                                                                element.id ==
                                                                'drop');
                                                      }
                                                    } else {
                                                      Navigator.pushAndRemoveUntil(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  const Maps()),
                                                          (route) => false);
                                                      isRentalRide = false;
                                                      ismulitipleride = false;
                                                      isOutStation = false;
                                                      etaDetails.clear();
                                                      promoKey.clear();
                                                      promoStatus = null;
                                                      promoStatus = false;
                                                      addCoupon = false;
                                                      rentalOption.clear();
                                                      myMarker.clear();
                                                      dropStopList.clear();
                                                      addressList.removeWhere(
                                                          (element) =>
                                                              element.id ==
                                                              'drop');
                                                    }
                                                  }
                                                },
                                                child: SizedBox(
                                                  height: media.width * 0.1,
                                                  width: media.width * 0.1,
                                                  child: Icon(
                                                    Icons.arrow_back,
                                                    color: (userRequestData
                                                                .isNotEmpty &&
                                                            userRequestData[
                                                                    'accepted_at'] ==
                                                                null)
                                                        ? Colors.transparent
                                                        : textColor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: media.width * 1.25,
                                    // top: media.width*0.2 + MediaQuery.of(context).padding.top,
                                    child: SizedBox(
                                      width: media.width * 0.9,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          if (userRequestData.isNotEmpty &&
                                              userRequestData['accepted_at'] !=
                                                  null)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              media.width *
                                                                  0.02),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            blurRadius: 2,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.2),
                                                            spreadRadius: 2)
                                                      ],
                                                      color: page),
                                                  child: Material(
                                                    color: Colors.transparent,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            media.width * 0.02),
                                                    child: InkWell(
                                                      onTap: () async {
                                                        await Share.share(
                                                            'Your Driver is ${userRequestData['driverDetail']['data']['name']}. ${userRequestData['driverDetail']['data']['car_color']} ${userRequestData['driverDetail']['data']['car_make_name']} ${userRequestData['driverDetail']['data']['car_model_name']}, Vehicle Number: ${userRequestData['driverDetail']['data']['car_number']}. Track with link: ${url}track/request/${userRequestData['id']}');
                                                      },
                                                      child: Container(
                                                          height:
                                                              media.width * 0.1,
                                                          width:
                                                              media.width * 0.1,
                                                          alignment:
                                                              Alignment.center,
                                                          child: Icon(
                                                            Icons.share,
                                                            size: media.width *
                                                                sixteen,
                                                            color: textColor,
                                                          )),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          SizedBox(
                                            height: media.width * 0.025,
                                          ),
                                          (userRequestData.isNotEmpty &&
                                                  userRequestData[
                                                          'is_trip_start'] ==
                                                      1)
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                      boxShadow: [
                                                        BoxShadow(
                                                            blurRadius: 2,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.2),
                                                            spreadRadius: 2)
                                                      ],
                                                      color: page,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              media.width *
                                                                  0.02)),
                                                  child: Material(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            media.width * 0.02),
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                        onTap: () async {
                                                          setState(() {
                                                            showSos = true;
                                                          });
                                                        },
                                                        child: Container(
                                                          height:
                                                              media.width * 0.1,
                                                          width:
                                                              media.width * 0.1,
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                            'SOS',
                                                            style: GoogleFonts.notoSans(
                                                                fontSize: media
                                                                        .width *
                                                                    fourteen,
                                                                color:
                                                                    textColor),
                                                          ),
                                                        )),
                                                  ),
                                                )
                                              : Container(),
                                          SizedBox(
                                            height: media.width * 0.025,
                                          ),
                                          (userRequestData.isNotEmpty)
                                              ? Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              media.width *
                                                                  0.02),
                                                      boxShadow: [
                                                        BoxShadow(
                                                            blurRadius: 2,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.2),
                                                            spreadRadius: 2)
                                                      ],
                                                      color: page),
                                                  child: Material(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            media.width * 0.02),
                                                    color: Colors.transparent,
                                                    child: InkWell(
                                                      onTap: () async {
                                                        if (locationAllowed ==
                                                            true) {
                                                          if (mapType ==
                                                              'google') {
                                                            if (currentLocation !=
                                                                null) {
                                                              _controller?.animateCamera(
                                                                  CameraUpdate
                                                                      .newLatLngZoom(
                                                                          currentLocation,
                                                                          18.0));
                                                              center =
                                                                  currentLocation;
                                                            } else {
                                                              _controller?.animateCamera(
                                                                  CameraUpdate
                                                                      .newLatLngZoom(
                                                                          center,
                                                                          18.0));
                                                            }
                                                          } else {
                                                            if (currentLocation !=
                                                                null) {
                                                              _controller?.animateCamera(
                                                                  CameraUpdate
                                                                      .newLatLngZoom(
                                                                          currentLocation,
                                                                          18.0));
                                                              _fmController.move(
                                                                  fmlt.LatLng(
                                                                      currentLocation
                                                                          .latitude,
                                                                      currentLocation
                                                                          .longitude),
                                                                  14);
                                                              center =
                                                                  currentLocation;
                                                            } else {
                                                              _fmController.move(
                                                                  fmlt.LatLng(
                                                                      center
                                                                          .latitude,
                                                                      center
                                                                          .longitude),
                                                                  14);
                                                            }
                                                          }
                                                        } else {
                                                          if (serviceEnabled ==
                                                              true) {
                                                            setState(() {
                                                              _locationDenied =
                                                                  true;
                                                            });
                                                          } else {
                                                            // await location.requestService();
                                                            await geolocs
                                                                    .Geolocator
                                                                .getCurrentPosition(
                                                                    desiredAccuracy:
                                                                        geolocs
                                                                            .LocationAccuracy
                                                                            .low);
                                                            if (await geolocs
                                                                .GeolocatorPlatform
                                                                .instance
                                                                .isLocationServiceEnabled()) {
                                                              setState(() {
                                                                _locationDenied =
                                                                    true;
                                                              });
                                                            }
                                                          }
                                                        }
                                                      },
                                                      child: SizedBox(
                                                        height:
                                                            media.width * 0.1,
                                                        width:
                                                            media.width * 0.1,
                                                        child: Icon(
                                                            Icons
                                                                .my_location_sharp,
                                                            color: textColor),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                    ),
                                  ),
                                  (etaDetails.isNotEmpty &&
                                          userRequestData.isEmpty &&
                                          dropConfirmed &&
                                          widget.type != 1)
                                      ? AnimatedPositioned(
                                          duration:
                                              const Duration(milliseconds: 500),
                                          right: media.width * 0.05,
                                          top: (_ontripBottom)
                                              ? media.width * 0.2
                                              : media.width * 0.8,
                                          child: InkWell(
                                            onTap: () async {
                                              if (_ontripBottom) {
                                                if (userRequestData[
                                                        'is_trip_start'] ==
                                                    1) {
                                                } else {}
                                                _ontripBottom = false;
                                              } else {
                                                _ontripBottom = true;
                                              }

                                              setState(() {});
                                            },
                                            child: Container(
                                              height: media.width * 0.1,
                                              width: media.width * 0.1,
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                        blurRadius: 2,
                                                        color: Colors.black
                                                            .withOpacity(0.2),
                                                        spreadRadius: 2)
                                                  ],
                                                  color: page,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          media.width * 0.02)),
                                              child: Icon(
                                                (_ontripBottom)
                                                    ? Icons.zoom_in_map
                                                    : Icons.zoom_out_map,
                                                color: textColor,
                                              ),
                                            ),
                                          ))
                                      : Container(),

                                  //show bottom nav bar for choosing ride type and vehicles
                                  (isLoading == false &&
                                          addressList.isNotEmpty &&
                                          etaDetails.isNotEmpty &&
                                          userRequestData.isEmpty &&
                                          noDriverFound == false &&
                                          tripReqError == false &&
                                          dropConfirmed == true &&
                                          lowWalletBalance == false)
                                      ? (_chooseGoodsType == true ||
                                              choosenTransportType == 0)
                                          ? Positioned(
                                              bottom: 0 +
                                                  MediaQuery.of(context)
                                                      .viewInsets
                                                      .bottom,
                                              child: AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 200),
                                                padding: EdgeInsets.only(
                                                    top: media.width * 0.02,
                                                    bottom: media.width * 0.0),
                                                width: media.width * 1,
                                                height: (bottomChooseMethod ==
                                                            false &&
                                                        widget.type != 1)
                                                    ? (_ontripBottom == true)
                                                        ? media.width * 1.5
                                                        : media.width * 1
                                                    : (bottomChooseMethod ==
                                                                false &&
                                                            widget.type == 1)
                                                        ? media.height * 0.6
                                                        : media.height * 0.9,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    25),
                                                            topRight:
                                                                Radius.circular(
                                                                    25)),
                                                    color: page),
                                                child:
                                                    (isRentalRide == true &&
                                                            etaDetails
                                                                .isNotEmpty)
                                                        ? Column(
                                                            children: [
                                                              SizedBox(
                                                                height: media
                                                                        .width *
                                                                    0.025,
                                                              ),
                                                              SizedBox(
                                                                width: media
                                                                        .width *
                                                                    1,
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Container(
                                                                      margin: EdgeInsets.only(
                                                                          left: media.width *
                                                                              0.05,
                                                                          right:
                                                                              media.width * 0.05),
                                                                      width: media
                                                                              .width *
                                                                          0.9,
                                                                      child:
                                                                          MyText(
                                                                        text: languages[choosenLanguage]
                                                                            [
                                                                            'text_availablerides'],
                                                                        size: media.width *
                                                                            fourteen,
                                                                        fontweight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.9,
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      // scrollDirection:
                                                                      //     Axis.horizontal,
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: etaDetails
                                                                            .asMap()
                                                                            .map((i, value) {
                                                                              return MapEntry(
                                                                                  i,
                                                                                  Padding(
                                                                                    padding: EdgeInsets.only(top: 10, left: media.width * 0.05, right: media.width * 0.05),
                                                                                    child: Material(
                                                                                      color: Colors.transparent,
                                                                                      child: InkWell(
                                                                                        onTap: () {
                                                                                          if (rentalChoosenOption != i) {
                                                                                            setState(() {
                                                                                              rentalOption = etaDetails[i]['typesWithPrice']['data'];
                                                                                              rentalChoosenOption = i;
                                                                                              choosenVehicle = null;
                                                                                              payingVia = 0;
                                                                                            });
                                                                                          } else {
                                                                                            // showModalBottomSheet(
                                                                                            //     context: context,
                                                                                            //     isScrollControlled: true,
                                                                                            //     builder: (context) {
                                                                                            //       return VehicleInfoBottomSheet(
                                                                                            //         i: i,
                                                                                            //         width: media.width,
                                                                                            //         isOneway: isOneWayTrip,
                                                                                            //         type: widget.type,
                                                                                            //       );
                                                                                            //     });
                                                                                          }
                                                                                        },
                                                                                        child: Container(
                                                                                          padding: EdgeInsets.all(media.width * 0.02),
                                                                                          // margin: EdgeInsets.only(top: 10, left: media.width * 0.05, right: media.width * 0.05),
                                                                                          // height: media.width * 0.157,
                                                                                          width: media.width * 0.8,
                                                                                          decoration: BoxDecoration(
                                                                                            borderRadius: BorderRadius.circular(media.width * 0.01),
                                                                                            border: Border.all(
                                                                                                color: (rentalChoosenOption != i)
                                                                                                    ? (isDarkTheme == true)
                                                                                                        ? Colors.white
                                                                                                        : hintColor
                                                                                                    : theme),
                                                                                            // color: page,
                                                                                          ),

                                                                                          child: Row(
                                                                                            children: [
                                                                                              Expanded(
                                                                                                child: Column(
                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    Text(
                                                                                                      etaDetails[i]['package_name'].toString(),
                                                                                                      style: GoogleFonts.notoSans(
                                                                                                        fontSize: media.width * sixteen,
                                                                                                        fontWeight: FontWeight.w600,
                                                                                                        color: (rentalChoosenOption == i)
                                                                                                            ? (isDarkTheme == true)
                                                                                                                ? Colors.white
                                                                                                                : textColor
                                                                                                            : (isDarkTheme == true)
                                                                                                                ? const Color(0xff8A8A8A)
                                                                                                                : textColor,
                                                                                                      ),
                                                                                                    ),
                                                                                                    Text(
                                                                                                      etaDetails[i]['short_description'].toString(),
                                                                                                      style: GoogleFonts.notoSans(fontSize: media.width * fourteen, fontWeight: FontWeight.w600, color: greyText),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                              Text(
                                                                                                '${etaDetails[i]['currency']} ${etaDetails[i]['min_price']} - ${etaDetails[i]['currency']}${etaDetails[i]['max_price']}',
                                                                                                style: GoogleFonts.notoSans(fontSize: media.width * fourteen, fontWeight: FontWeight.w600, color: greyText),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ));
                                                                            })
                                                                            .values
                                                                            .toList(),
                                                                      ),
                                                                    )),
                                                              ),
                                                              SizedBox(
                                                                height: media
                                                                        .width *
                                                                    0.025,
                                                              ),
                                                              Button(
                                                                  width: media
                                                                          .width *
                                                                      0.5,
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      isRentalRide =
                                                                          false;
                                                                      rentalOption =
                                                                          etaDetails[rentalChoosenOption]['typesWithPrice']
                                                                              [
                                                                              'data'];
                                                                      // rentalChoosenOption = i;
                                                                      choosenVehicle =
                                                                          null;
                                                                      payingVia =
                                                                          0;
                                                                    });
                                                                  },
                                                                  text: languages[
                                                                          choosenLanguage]
                                                                      [
                                                                      'text_confirm']),
                                                              SizedBox(
                                                                height: media
                                                                        .width *
                                                                    0.05,
                                                              )
                                                            ],
                                                          )

                                                        // child:
                                                        : (isRentalRide ==
                                                                    false &&
                                                                etaDetails
                                                                    .isNotEmpty)
                                                            ? Column(
                                                                children: [
                                                                  (isOutStation ==
                                                                          true)
                                                                      ? SizedBox(
                                                                          height:
                                                                              media.width * 0.02,
                                                                        )
                                                                      : const SizedBox(),
                                                                  (isOutStation ==
                                                                          true)
                                                                      ? Material(
                                                                          elevation:
                                                                              5,
                                                                          borderRadius:
                                                                              BorderRadius.circular(media.width * 0.02),
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                media.width * 0.9,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: page,
                                                                              borderRadius: BorderRadius.circular(media.width * 0.02),
                                                                            ),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Expanded(
                                                                                  child: InkWell(
                                                                                    onTap: () {
                                                                                      setState(() {
                                                                                        isOneWayTrip = true;
                                                                                        toDate = null;
                                                                                      });
                                                                                    },
                                                                                    child: Container(
                                                                                      padding: EdgeInsets.all(media.width * 0.03),
                                                                                      decoration: BoxDecoration(border: Border.all(color: isOneWayTrip ? theme : page), borderRadius: BorderRadius.circular(media.width * 0.02)),
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            children: [
                                                                                              MyText(
                                                                                                text: languages[choosenLanguage]['text_one_way_trip'],
                                                                                                size: media.width * fourteen,
                                                                                                fontweight: FontWeight.bold,
                                                                                              ),
                                                                                              (isOneWayTrip)
                                                                                                  ? Container(
                                                                                                      height: media.width * 0.04,
                                                                                                      width: media.width * 0.04,
                                                                                                      alignment: Alignment.center,
                                                                                                      decoration: BoxDecoration(shape: BoxShape.circle, color: theme),
                                                                                                      child: Icon(
                                                                                                        Icons.done,
                                                                                                        size: media.width * 0.03,
                                                                                                        color: page,
                                                                                                      ),
                                                                                                    )
                                                                                                  : Container()
                                                                                            ],
                                                                                          ),
                                                                                          MyText(
                                                                                            text: languages[choosenLanguage]['text_get_drop_off'],
                                                                                            size: media.width * twelve,
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Expanded(
                                                                                  child: InkWell(
                                                                                    onTap: () {
                                                                                      setState(() {
                                                                                        isOneWayTrip = false;
                                                                                      });
                                                                                    },
                                                                                    child: Container(
                                                                                      padding: EdgeInsets.all(media.width * 0.03),
                                                                                      decoration: BoxDecoration(border: Border.all(color: (!isOneWayTrip) ? theme : page), borderRadius: BorderRadius.circular(media.width * 0.02)),
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        children: [
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            children: [
                                                                                              Expanded(
                                                                                                child: MyText(
                                                                                                  text: languages[choosenLanguage]['text_round_trip'],
                                                                                                  size: media.width * fourteen,
                                                                                                  fontweight: FontWeight.bold,
                                                                                                  maxLines: 1,
                                                                                                ),
                                                                                              ),
                                                                                              (!isOneWayTrip)
                                                                                                  ? Container(
                                                                                                      height: media.width * 0.04,
                                                                                                      width: media.width * 0.04,
                                                                                                      alignment: Alignment.center,
                                                                                                      decoration: BoxDecoration(shape: BoxShape.circle, color: theme),
                                                                                                      child: Icon(
                                                                                                        Icons.done,
                                                                                                        size: media.width * 0.03,
                                                                                                        color: page,
                                                                                                      ),
                                                                                                    )
                                                                                                  : Container()
                                                                                            ],
                                                                                          ),
                                                                                          MyText(
                                                                                            text: languages[choosenLanguage]['text_car_return'],
                                                                                            size: media.width * twelve,
                                                                                            maxLines: 1,
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Container(),
                                                                  (isOutStation ==
                                                                          true)
                                                                      ? SizedBox(
                                                                          height:
                                                                              media.width * 0.02,
                                                                        )
                                                                      : const SizedBox(),
                                                                  (isOutStation ==
                                                                          true)
                                                                      ? InkWell(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              _isDateTimebottom = 0;
                                                                            });
                                                                            Future.delayed(const Duration(milliseconds: 200),
                                                                                () {
                                                                              setState(() {
                                                                                if (isOneWayTrip) {
                                                                                  _dateTimeHeight = media.height * 0.45;
                                                                                } else {
                                                                                  _dateTimeHeight = media.height * 0.5;
                                                                                }
                                                                              });
                                                                            });
                                                                          },
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                media.width * 0.9,
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                MyText(
                                                                                  text: languages[choosenLanguage]['text_booking_for'],
                                                                                  size: media.width * twelve,
                                                                                  fontweight: FontWeight.w500,
                                                                                ),
                                                                                SizedBox(
                                                                                  width: media.width * 0.07,
                                                                                ),
                                                                                MyText(
                                                                                  // ignore: unnecessary_null_comparison
                                                                                  text: (fromDate != null) ? DateFormat('d MMM, h:mm a').format(fromDate).toString() : DateFormat('d MMM, h:mm a').format(DateTime.now().add(Duration(minutes: int.parse(userDetails['user_can_make_a_ride_after_x_miniutes'])))).toString(),
                                                                                  size: media.width * twelve,
                                                                                  // color: buttonColor,
                                                                                  color: theme,
                                                                                ),
                                                                                (!isOneWayTrip)
                                                                                    ? MyText(
                                                                                        text: ' -- ${(toDate != null) ? DateFormat('d MMM, h:mm a').format(toDate!).toString() : languages[choosenLanguage]['text_select']}',
                                                                                        size: media.width * twelve,
                                                                                        // color: buttonColor,
                                                                                        color: theme,
                                                                                      )
                                                                                    : const SizedBox(),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : Container(),
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.02,
                                                                  ),
                                                                  if (isRentalRide ==
                                                                          false &&
                                                                      etaDetails
                                                                          .isNotEmpty &&
                                                                      widget.type !=
                                                                          1)
                                                                    SizedBox(
                                                                      width:
                                                                          media.width *
                                                                              1,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Container(
                                                                            margin:
                                                                                EdgeInsets.only(left: media.width * 0.05, right: media.width * 0.05),
                                                                            width:
                                                                                media.width * 0.9,
                                                                            child:
                                                                                MyText(
                                                                              text: languages[choosenLanguage]['text_availablerides'],
                                                                              size: media.width * fourteen,
                                                                              fontweight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.02,
                                                                  ),
                                                                  (etaDetails.isNotEmpty &&
                                                                          widget.type !=
                                                                              1)
                                                                      ? Expanded(
                                                                          child: SizedBox(
                                                                              width: media.width * 1,
                                                                              child: SingleChildScrollView(
                                                                                  physics: const BouncingScrollPhysics(),
                                                                                  child: Column(
                                                                                    children: [
                                                                                      Column(
                                                                                        children: etaDetails
                                                                                            .asMap()
                                                                                            .map((i, value) {
                                                                                              return MapEntry(
                                                                                                  i,
                                                                                                  StreamBuilder<DatabaseEvent>(
                                                                                                      stream: fdb.onValue,
                                                                                                      builder: (context, AsyncSnapshot event) {
                                                                                                        if (event.data != null) {
                                                                                                          minutes[etaDetails[i]['type_id']] = '';
                                                                                                          List vehicleList = [];
                                                                                                          List vehicles = [];
                                                                                                          List<double> minsList = [];
                                                                                                          event.data!.snapshot.children.forEach((e) {
                                                                                                            vehicleList.add(e.value);
                                                                                                          });
                                                                                                          if (vehicleList.isNotEmpty) {
                                                                                                            // ignore: avoid_function_literals_in_foreach_calls
                                                                                                            vehicleList.forEach(
                                                                                                              (e) async {
                                                                                                                if (e['is_active'] == 1 && e['is_available'] == true && ((e['vehicle_types'] != null && e['vehicle_types'].contains(etaDetails[i]['type_id'])) || e['vehicle_type'] == etaDetails[i]['type_id'])) {
                                                                                                                  DateTime dt = DateTime.fromMillisecondsSinceEpoch(e['updated_at']);
                                                                                                                  if (DateTime.now().difference(dt).inMinutes <= 2) {
                                                                                                                    vehicles.add(e);
                                                                                                                    if (vehicles.isNotEmpty) {
                                                                                                                      var dist = calculateDistance(addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude, addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude, e['l'][0], e['l'][1]);

                                                                                                                      minsList.add(double.parse((dist / 1000).toString()));
                                                                                                                      var minDist = minsList.reduce(min);
                                                                                                                      if (minDist > 0 && minDist <= 1) {
                                                                                                                        minutes[etaDetails[i]['type_id']] = '2 mins';
                                                                                                                      } else if (minDist > 1 && minDist <= 3) {
                                                                                                                        minutes[etaDetails[i]['type_id']] = '5 mins';
                                                                                                                      } else if (minDist > 3 && minDist <= 5) {
                                                                                                                        minutes[etaDetails[i]['type_id']] = '8 mins';
                                                                                                                      } else if (minDist > 5 && minDist <= 7) {
                                                                                                                        minutes[etaDetails[i]['type_id']] = '11 mins';
                                                                                                                      } else if (minDist > 7 && minDist <= 10) {
                                                                                                                        minutes[etaDetails[i]['type_id']] = '14 mins';
                                                                                                                      } else if (minDist > 10) {
                                                                                                                        minutes[etaDetails[i]['type_id']] = '15 mins';
                                                                                                                      }
                                                                                                                    } else {
                                                                                                                      minutes[etaDetails[i]['type_id']] = '';
                                                                                                                    }
                                                                                                                  }
                                                                                                                }
                                                                                                              },
                                                                                                            );
                                                                                                          } else {
                                                                                                            minutes[etaDetails[i]['type_id']] = '';
                                                                                                          }
                                                                                                        } else {
                                                                                                          minutes[etaDetails[i]['type_id']] = '';
                                                                                                        }
                                                                                                        return Padding(
                                                                                                          padding: EdgeInsets.only(top: 10, left: media.width * 0.05, right: media.width * 0.05),
                                                                                                          child: Material(
                                                                                                            color: Colors.transparent,
                                                                                                            child: InkWell(
                                                                                                              onTap: () {
                                                                                                                if (choosenVehicle != i) {
                                                                                                                  setState(() {
                                                                                                                    choosenVehicle = i;
                                                                                                                    // myMarker.clear();
                                                                                                                  });
                                                                                                                  myMarker.removeWhere((element) => element.markerId.toString().contains('car'));
                                                                                                                } else {
                                                                                                                  showModalBottomSheet(
                                                                                                                      context: context,
                                                                                                                      isScrollControlled: true,
                                                                                                                      builder: (context) {
                                                                                                                        return VehicleInfoBottomSheet(
                                                                                                                          i: i,
                                                                                                                          width: media.width,
                                                                                                                          isOneway: isOneWayTrip,
                                                                                                                          type: widget.type,
                                                                                                                        );
                                                                                                                      });
                                                                                                                }
                                                                                                              },
                                                                                                              child: Container(
                                                                                                                padding: EdgeInsets.all(media.width * 0.02),
                                                                                                                // margin: EdgeInsets.only(top: 10, left: media.width * 0.05, right: media.width * 0.05),
                                                                                                                height: media.width * 0.157,
                                                                                                                decoration: BoxDecoration(
                                                                                                                    borderRadius: BorderRadius.circular(media.width * 0.01),
                                                                                                                    border: Border.all(
                                                                                                                        color: (choosenVehicle != i)
                                                                                                                            ? (isDarkTheme == true)
                                                                                                                                ? Colors.white
                                                                                                                                : hintColor
                                                                                                                            : theme),
                                                                                                                    // : Colors.black),
                                                                                                                    // color: page,
                                                                                                                    color: choosenVehicle == i ? theme.withOpacity(0.2) : null),
                                                                                                                child: Row(
                                                                                                                  children: [
                                                                                                                    SizedBox(
                                                                                                                      width: media.width * 0.12,
                                                                                                                      child: (etaDetails[i]['icon'] != null)
                                                                                                                          ? Image.network(
                                                                                                                              etaDetails[i]['icon'],
                                                                                                                              fit: BoxFit.contain,
                                                                                                                              // width: media.width*0.07,
                                                                                                                            )
                                                                                                                          : Container(),
                                                                                                                    ),
                                                                                                                    SizedBox(
                                                                                                                      width: media.width * 0.02,
                                                                                                                    ),
                                                                                                                    Column(
                                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                      children: [
                                                                                                                        Row(
                                                                                                                          children: [
                                                                                                                            SizedBox(
                                                                                                                              width: media.width * 0.3,
                                                                                                                              child: Text(etaDetails[i]['name'],
                                                                                                                                  style: GoogleFonts.notoSans(
                                                                                                                                      fontSize: media.width * fourteen,
                                                                                                                                      fontWeight: FontWeight.w600,
                                                                                                                                      color: (choosenVehicle != i)
                                                                                                                                          ? (isDarkTheme == true)
                                                                                                                                              ? hintColor
                                                                                                                                              : textColor
                                                                                                                                          : textColor)),
                                                                                                                            ),
                                                                                                                          ],
                                                                                                                        ),
                                                                                                                        Row(
                                                                                                                          children: [
                                                                                                                            // Icon(
                                                                                                                            //   Icons.timelapse,
                                                                                                                            //   size: media.width * 0.04,
                                                                                                                            //   color: const Color(0xff8A8A8A),
                                                                                                                            // ),
                                                                                                                            // SizedBox(
                                                                                                                            //   width: media.width * 0.01,
                                                                                                                            // ),
                                                                                                                            Row(
                                                                                                                              children: [
                                                                                                                                (minutes[etaDetails[i]['type_id']] != null && minutes[etaDetails[i]['type_id']] != '')
                                                                                                                                    ? Text(
                                                                                                                                        minutes[etaDetails[i]['type_id']].toString(),
                                                                                                                                        style: GoogleFonts.notoSans(fontSize: media.width * twelve, color: const Color(0xff8A8A8A)),
                                                                                                                                      )
                                                                                                                                    : Text(
                                                                                                                                        '--',
                                                                                                                                        style: GoogleFonts.notoSans(
                                                                                                                                            fontSize: media.width * twelve,
                                                                                                                                            color: (choosenVehicle != i)
                                                                                                                                                ? (isDarkTheme == true)
                                                                                                                                                    ? hintColor
                                                                                                                                                    : const Color(0xff8A8A8A)
                                                                                                                                                : const Color(0xff8A8A8A)),
                                                                                                                                      ),
                                                                                                                                SizedBox(
                                                                                                                                  width: media.width * 0.02,
                                                                                                                                ),
                                                                                                                                Icon(
                                                                                                                                  (etaDetails[i]['transport_type'] == 'delivery') ? CupertinoIcons.bag : Icons.person,
                                                                                                                                  size: media.width * 0.04,
                                                                                                                                  color: const Color(0xff8A8A8A),
                                                                                                                                ),
                                                                                                                                Text(
                                                                                                                                  (etaDetails[i]['transport_type'] == 'delivery') ? etaDetails[i]['size'].toString() : etaDetails[i]['capacity'].toString(),
                                                                                                                                  style: GoogleFonts.notoSans(
                                                                                                                                      fontSize: media.width * twelve,
                                                                                                                                      color: (choosenVehicle != i)
                                                                                                                                          ? (isDarkTheme == true)
                                                                                                                                              ? hintColor
                                                                                                                                              : const Color(0xff8A8A8A)
                                                                                                                                          : const Color(0xff8A8A8A)),
                                                                                                                                ),
                                                                                                                              ],
                                                                                                                            ),
                                                                                                                          ],
                                                                                                                        )
                                                                                                                        // SizedBox(width: media.width * 0.5, child: MyText(maxLines: 1, text: etaDetails[i]['short_description'], size: media.width * twelve)),
                                                                                                                      ],
                                                                                                                    ),
                                                                                                                    (widget.type != 2)
                                                                                                                        ? Expanded(
                                                                                                                            child: (etaDetails[i]['has_discount'] != true || etaDetails[i]['enable_bidding'] == true)
                                                                                                                                ? (isOneWayTrip)
                                                                                                                                    ? Row(
                                                                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                                                                        children: [
                                                                                                                                          Text(
                                                                                                                                            etaDetails[i]['currency'] + etaDetails[i]['total'].toString()
                                                                                                                                            // : (daysDifferenceRoundedUp != 0) ? (double.parse(etaDetails[i]['total'].toString()) * daysDifferenceRoundedUp).toStringAsFixed(2) : etaDetails[i]['total'].toStringAsFixed(2)} ${etaDetails[i]['currency']}'

                                                                                                                                            // daysDifferenceRoundedUp    etaDetails[i]['total'].toStringAsFixed(2) +
                                                                                                                                            ,
                                                                                                                                            style: GoogleFonts.notoSans(
                                                                                                                                                fontSize: media.width * fourteen,
                                                                                                                                                fontWeight: FontWeight.w700,
                                                                                                                                                color: (choosenVehicle != i)
                                                                                                                                                    ? (isDarkTheme == true)
                                                                                                                                                        ? const Color(0xff8A8A8A)
                                                                                                                                                        : textColor
                                                                                                                                                    : textColor),
                                                                                                                                          ),
                                                                                                                                        ],
                                                                                                                                      )
                                                                                                                                    : Container()
                                                                                                                                : Row(
                                                                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                                                                    children: [
                                                                                                                                      Text(
                                                                                                                                        etaDetails[i]['currency'] + ' ',
                                                                                                                                        style: GoogleFonts.notoSans(
                                                                                                                                            fontSize: media.width * fourteen,
                                                                                                                                            color: (choosenVehicle != i)
                                                                                                                                                ? (isDarkTheme == true)
                                                                                                                                                    ? const Color(0xff8A8A8A)
                                                                                                                                                    : textColor
                                                                                                                                                : (isDarkTheme == true)
                                                                                                                                                    ? Colors.white
                                                                                                                                                    : textColor,
                                                                                                                                            fontWeight: FontWeight.w600),
                                                                                                                                      ),
                                                                                                                                      Column(
                                                                                                                                        children: [
                                                                                                                                          Text(
                                                                                                                                            etaDetails[i]['total'].toString(),
                                                                                                                                            style: GoogleFonts.notoSans(
                                                                                                                                                fontSize: media.width * fourteen,
                                                                                                                                                color: (choosenVehicle != i)
                                                                                                                                                    ? (isDarkTheme == true)
                                                                                                                                                        ? const Color(0xff8A8A8A)
                                                                                                                                                        : textColor
                                                                                                                                                    : (isDarkTheme == true)
                                                                                                                                                        ? Colors.white
                                                                                                                                                        : textColor,
                                                                                                                                                fontWeight: FontWeight.w600,
                                                                                                                                                decoration: TextDecoration.lineThrough),
                                                                                                                                          ),
                                                                                                                                          Text(
                                                                                                                                            etaDetails[i]['discounted_totel'].toString(),
                                                                                                                                            style: GoogleFonts.notoSans(
                                                                                                                                                fontSize: media.width * fourteen,
                                                                                                                                                color: (choosenVehicle != i)
                                                                                                                                                    ? (isDarkTheme == true)
                                                                                                                                                        ? const Color(0xff8A8A8A)
                                                                                                                                                        : textColor
                                                                                                                                                    : (isDarkTheme == true)
                                                                                                                                                        ? Colors.white
                                                                                                                                                        : textColor,
                                                                                                                                                fontWeight: FontWeight.w700),
                                                                                                                                          )
                                                                                                                                        ],
                                                                                                                                      ),
                                                                                                                                    ],
                                                                                                                                  ))
                                                                                                                        : Container()
                                                                                                                  ],
                                                                                                                ),
                                                                                                              ),
                                                                                                            ),
                                                                                                          ),
                                                                                                        );
                                                                                                      }));
                                                                                            })
                                                                                            .values
                                                                                            .toList(),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: media.width * 0.05,
                                                                                      )
                                                                                    ],
                                                                                  ))),
                                                                        )
                                                                      : (etaDetails.isNotEmpty &&
                                                                              widget.type == 1)
                                                                          ? Expanded(
                                                                              child: SizedBox(
                                                                                  width: media.width * 1,
                                                                                  child: Column(
                                                                                    children: [
                                                                                      // SizedBox(
                                                                                      //   height: media.width * 0.025,
                                                                                      // ),
                                                                                      Container(
                                                                                        padding: EdgeInsets.fromLTRB(media.width * 0.05, media.width * 0.0, media.width * 0.05, media.width * 0.025),
                                                                                        child: Column(
                                                                                          children: [
                                                                                            Row(
                                                                                              children: [
                                                                                                Expanded(
                                                                                                  child: MyText(
                                                                                                    text: languages[choosenLanguage]['text_select_package'],
                                                                                                    size: media.width * fourteen,
                                                                                                    fontweight: FontWeight.bold,
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                            SizedBox(
                                                                                              height: media.width * 0.025,
                                                                                            ),
                                                                                            Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              children: [
                                                                                                Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(25), color: theme.withOpacity(0.14)), padding: EdgeInsets.fromLTRB(media.width * 0.05, media.width * 0.025, media.width * 0.05, media.width * 0.025), child: MyText(text: etaDetails[rentalChoosenOption]['package_name'].toString(), size: media.width * fifteen, fontweight: FontWeight.w500)),
                                                                                                InkWell(
                                                                                                    onTap: () {
                                                                                                      setState(() {
                                                                                                        isRentalRide = true;
                                                                                                      });
                                                                                                    },
                                                                                                    child: MyText(text: languages[choosenLanguage]['text_edit'], size: media.width * fifteen, fontweight: FontWeight.w500)),
                                                                                              ],
                                                                                            )
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        width: media.width * 1,
                                                                                        child: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          children: [
                                                                                            InkWell(
                                                                                              onTap: () {
                                                                                                setState(() {
                                                                                                  isRentalRide = true;
                                                                                                });
                                                                                              },
                                                                                              child: Container(
                                                                                                margin: EdgeInsets.only(left: media.width * 0.05, right: media.width * 0.05),
                                                                                                width: media.width * 0.9,
                                                                                                child: MyText(
                                                                                                  text: languages[choosenLanguage]['text_availablerides'],
                                                                                                  size: media.width * fourteen,
                                                                                                  fontweight: FontWeight.bold,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      SizedBox(
                                                                                        height: media.width * 0.025,
                                                                                      ),

                                                                                      Expanded(
                                                                                        child: SizedBox(
                                                                                          width: media.width * 0.9,
                                                                                          child: SingleChildScrollView(
                                                                                            // scrollDirection:
                                                                                            //     Axis.horizontal,
                                                                                            physics: const BouncingScrollPhysics(),
                                                                                            child: Column(
                                                                                              children: [
                                                                                                Column(
                                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                                    children: rentalOption
                                                                                                        .asMap()
                                                                                                        .map((i, value) {
                                                                                                          return MapEntry(
                                                                                                              i,
                                                                                                              StreamBuilder<DatabaseEvent>(
                                                                                                                  stream: fdb.onValue,
                                                                                                                  builder: (context, AsyncSnapshot event) {
                                                                                                                    if (event.data != null) {
                                                                                                                      minutes[rentalOption[i]['type_id']] = '';
                                                                                                                      List vehicleList = [];
                                                                                                                      List vehicles = [];
                                                                                                                      List<double> minsList = [];
                                                                                                                      event.data!.snapshot.children.forEach((e) {
                                                                                                                        vehicleList.add(e.value);
                                                                                                                      });
                                                                                                                      if (vehicleList.isNotEmpty) {
                                                                                                                        // ignore: avoid_function_literals_in_foreach_calls
                                                                                                                        vehicleList.forEach(
                                                                                                                          (e) async {
                                                                                                                            if (e['is_active'] == 1 && e['is_available'] == true && ((e['vehicle_types'] != null && e['vehicle_types'].contains(rentalOption[i]['type_id'])) || e['vehicle_type'] == rentalOption[i]['type_id'])) {
                                                                                                                              DateTime dt = DateTime.fromMillisecondsSinceEpoch(e['updated_at']);
                                                                                                                              if (DateTime.now().difference(dt).inMinutes <= 2) {
                                                                                                                                vehicles.add(e);
                                                                                                                                if (vehicles.isNotEmpty) {
                                                                                                                                  var dist = calculateDistance(addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude, addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude, e['l'][0], e['l'][1]);

                                                                                                                                  minsList.add(double.parse((dist / 1000).toString()));
                                                                                                                                  var minDist = minsList.reduce(min);
                                                                                                                                  if (minDist > 0 && minDist <= 1) {
                                                                                                                                    minutes[rentalOption[i]['type_id']] = '2 mins';
                                                                                                                                  } else if (minDist > 1 && minDist <= 3) {
                                                                                                                                    minutes[rentalOption[i]['type_id']] = '5 mins';
                                                                                                                                  } else if (minDist > 3 && minDist <= 5) {
                                                                                                                                    minutes[rentalOption[i]['type_id']] = '8 mins';
                                                                                                                                  } else if (minDist > 5 && minDist <= 7) {
                                                                                                                                    minutes[rentalOption[i]['type_id']] = '11 mins';
                                                                                                                                  } else if (minDist > 7 && minDist <= 10) {
                                                                                                                                    minutes[rentalOption[i]['type_id']] = '14 mins';
                                                                                                                                  } else if (minDist > 10) {
                                                                                                                                    minutes[rentalOption[i]['type_id']] = '15 mins';
                                                                                                                                  }
                                                                                                                                } else {
                                                                                                                                  minutes[rentalOption[i]['type_id']] = '';
                                                                                                                                }
                                                                                                                              }
                                                                                                                            }
                                                                                                                          },
                                                                                                                        );
                                                                                                                      } else {
                                                                                                                        minutes[rentalOption[i]['type_id']] = '';
                                                                                                                      }
                                                                                                                    } else {
                                                                                                                      minutes[rentalOption[i]['type_id']] = '';
                                                                                                                    }
                                                                                                                    return Padding(
                                                                                                                      padding: const EdgeInsets.only(
                                                                                                                        top: 10,
                                                                                                                      ),
                                                                                                                      child: Material(
                                                                                                                        color: Colors.transparent,
                                                                                                                        child: InkWell(
                                                                                                                          onTap: () {
                                                                                                                            if (choosenVehicle != i) {
                                                                                                                              setState(() {
                                                                                                                                choosenVehicle = i;
                                                                                                                              });
                                                                                                                            } else {
                                                                                                                              showModalBottomSheet(
                                                                                                                                  context: context,
                                                                                                                                  isScrollControlled: true,
                                                                                                                                  builder: (context) {
                                                                                                                                    return VehicleInfoBottomSheet(
                                                                                                                                      i: i,
                                                                                                                                      width: media.width,
                                                                                                                                      isOneway: isOneWayTrip,
                                                                                                                                      type: widget.type,
                                                                                                                                    );
                                                                                                                                  });
                                                                                                                            }
                                                                                                                          },
                                                                                                                          child: Container(
                                                                                                                            padding: EdgeInsets.all(media.width * 0.02),
                                                                                                                            // margin: EdgeInsets.only(top: 10, left: media.width * 0.05, right: media.width * 0.05),
                                                                                                                            height: media.width * 0.157,
                                                                                                                            decoration: BoxDecoration(
                                                                                                                                borderRadius: BorderRadius.circular(media.width * 0.01),
                                                                                                                                border: Border.all(
                                                                                                                                    color: (choosenVehicle != i)
                                                                                                                                        ? (isDarkTheme == true)
                                                                                                                                            ? Colors.white
                                                                                                                                            : hintColor
                                                                                                                                        : theme),
                                                                                                                                // : Colors.black),
                                                                                                                                // color: page,
                                                                                                                                color: choosenVehicle == i ? theme.withOpacity(0.2) : null),
                                                                                                                            child: Row(
                                                                                                                              children: [
                                                                                                                                SizedBox(
                                                                                                                                  width: media.width * 0.12,
                                                                                                                                  child: (rentalOption[i]['icon'] != null)
                                                                                                                                      ? Image.network(
                                                                                                                                          rentalOption[i]['icon'],
                                                                                                                                          fit: BoxFit.contain,
                                                                                                                                          // width: media.width*0.07,
                                                                                                                                        )
                                                                                                                                      : Container(),
                                                                                                                                ),
                                                                                                                                SizedBox(
                                                                                                                                  width: media.width * 0.02,
                                                                                                                                ),
                                                                                                                                Column(
                                                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                                                  children: [
                                                                                                                                    Row(
                                                                                                                                      children: [
                                                                                                                                        SizedBox(
                                                                                                                                          width: media.width * 0.3,
                                                                                                                                          child: Text(rentalOption[i]['name'],
                                                                                                                                              style: GoogleFonts.notoSans(
                                                                                                                                                  fontSize: media.width * fourteen,
                                                                                                                                                  fontWeight: FontWeight.w600,
                                                                                                                                                  color: (choosenVehicle != i)
                                                                                                                                                      ? (isDarkTheme == true)
                                                                                                                                                          ? hintColor
                                                                                                                                                          : textColor
                                                                                                                                                      : textColor)),
                                                                                                                                        ),
                                                                                                                                      ],
                                                                                                                                    ),
                                                                                                                                    Row(
                                                                                                                                      children: [
                                                                                                                                        // Icon(
                                                                                                                                        //   Icons.timelapse,
                                                                                                                                        //   size: media.width * 0.04,
                                                                                                                                        //   color: const Color(0xff8A8A8A),
                                                                                                                                        // ),
                                                                                                                                        // SizedBox(
                                                                                                                                        //   width: media.width * 0.01,
                                                                                                                                        // ),
                                                                                                                                        Row(
                                                                                                                                          children: [
                                                                                                                                            (minutes[rentalOption[i]['type_id']] != null && minutes[rentalOption[i]['type_id']] != '')
                                                                                                                                                ? Text(
                                                                                                                                                    minutes[rentalOption[i]['type_id']].toString(),
                                                                                                                                                    style: GoogleFonts.notoSans(fontSize: media.width * twelve, color: const Color(0xff8A8A8A)),
                                                                                                                                                  )
                                                                                                                                                : Text(
                                                                                                                                                    '--',
                                                                                                                                                    style: GoogleFonts.notoSans(
                                                                                                                                                        fontSize: media.width * twelve,
                                                                                                                                                        color: (choosenVehicle != i)
                                                                                                                                                            ? (isDarkTheme == true)
                                                                                                                                                                ? hintColor
                                                                                                                                                                : const Color(0xff8A8A8A)
                                                                                                                                                            : const Color(0xff8A8A8A)),
                                                                                                                                                  ),
                                                                                                                                            SizedBox(
                                                                                                                                              width: media.width * 0.02,
                                                                                                                                            ),
                                                                                                                                            Icon(
                                                                                                                                              Icons.person,
                                                                                                                                              size: media.width * 0.04,
                                                                                                                                              color: const Color(0xff8A8A8A),
                                                                                                                                            ),
                                                                                                                                            Text(
                                                                                                                                              rentalOption[i]['capacity'].toString(),
                                                                                                                                              style: GoogleFonts.notoSans(
                                                                                                                                                  fontSize: media.width * twelve,
                                                                                                                                                  color: (choosenVehicle != i)
                                                                                                                                                      ? (isDarkTheme == true)
                                                                                                                                                          ? hintColor
                                                                                                                                                          : const Color(0xff8A8A8A)
                                                                                                                                                      : const Color(0xff8A8A8A)),
                                                                                                                                            ),
                                                                                                                                          ],
                                                                                                                                        ),
                                                                                                                                      ],
                                                                                                                                    )
                                                                                                                                    // SizedBox(width: media.width * 0.5, child: MyText(maxLines: 1, text: etaDetails[i]['short_description'], size: media.width * twelve)),
                                                                                                                                  ],
                                                                                                                                ),
                                                                                                                                (widget.type != 2)
                                                                                                                                    ? Expanded(
                                                                                                                                        child: (rentalOption[i]['has_discount'] != true || rentalOption[i]['enable_bidding'] == true)
                                                                                                                                            ? (isOneWayTrip)
                                                                                                                                                ? Row(
                                                                                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                                                                                    children: [
                                                                                                                                                      Text(
                                                                                                                                                        rentalOption[i]['currency'] + rentalOption[i]['fare_amount'].toString()
                                                                                                                                                        // : (daysDifferenceRoundedUp != 0) ? (double.parse(etaDetails[i]['total'].toString()) * daysDifferenceRoundedUp).toStringAsFixed(2) : etaDetails[i]['total'].toStringAsFixed(2)} ${etaDetails[i]['currency']}'

                                                                                                                                                        // daysDifferenceRoundedUp    etaDetails[i]['total'].toStringAsFixed(2) +
                                                                                                                                                        ,
                                                                                                                                                        style: GoogleFonts.notoSans(
                                                                                                                                                            fontSize: media.width * fourteen,
                                                                                                                                                            fontWeight: FontWeight.w700,
                                                                                                                                                            color: (choosenVehicle != i)
                                                                                                                                                                ? (isDarkTheme == true)
                                                                                                                                                                    ? Colors.white
                                                                                                                                                                    : textColor
                                                                                                                                                                : textColor),
                                                                                                                                                      ),
                                                                                                                                                    ],
                                                                                                                                                  )
                                                                                                                                                : Container()
                                                                                                                                            : Row(
                                                                                                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                                                                                                                children: [
                                                                                                                                                  Text(
                                                                                                                                                    rentalOption[i]['currency'] + ' ',
                                                                                                                                                    style: GoogleFonts.notoSans(fontSize: media.width * fourteen, color: (choosenVehicle != i) ? Colors.white : Colors.black, fontWeight: FontWeight.w600),
                                                                                                                                                  ),
                                                                                                                                                  Column(
                                                                                                                                                    children: [
                                                                                                                                                      Text(
                                                                                                                                                        rentalOption[i]['fare_amount'].toString(),
                                                                                                                                                        style: GoogleFonts.notoSans(
                                                                                                                                                            fontSize: media.width * fourteen,
                                                                                                                                                            color: (choosenVehicle != i)
                                                                                                                                                                ? (isDarkTheme == true)
                                                                                                                                                                    ? Colors.white
                                                                                                                                                                    : textColor
                                                                                                                                                                : Colors.black,
                                                                                                                                                            fontWeight: FontWeight.w600,
                                                                                                                                                            decoration: TextDecoration.lineThrough),
                                                                                                                                                      ),
                                                                                                                                                      Text(
                                                                                                                                                        rentalOption[i]['discounted_totel'].toString(),
                                                                                                                                                        style: GoogleFonts.notoSans(
                                                                                                                                                            fontSize: media.width * fourteen,
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
                                                                                                                                              ))
                                                                                                                                    : Container()
                                                                                                                              ],
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    );
                                                                                                                  }));
                                                                                                        })
                                                                                                        .values
                                                                                                        .toList()),
                                                                                                SizedBox(
                                                                                                  height: media.width * 0.05,
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  )),
                                                                            )
                                                                          : Container(),
                                                                  Container(
                                                                    width: media
                                                                        .width,
                                                                    padding: EdgeInsets.all(
                                                                        media.width *
                                                                            0.03),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      boxShadow: [
                                                                        BoxShadow(
                                                                            blurRadius:
                                                                                2,
                                                                            color:
                                                                                Colors.black.withOpacity(0.2),
                                                                            spreadRadius: 2)
                                                                      ],
                                                                      color:
                                                                          page,
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        (choosenTransportType ==
                                                                                1)
                                                                            ? Column(
                                                                                children: [
                                                                                  // SizedBox(
                                                                                  //   height: media.width * 0.01,
                                                                                  // ),
                                                                                  InkWell(
                                                                                    onTap: () {
                                                                                      pickerName.text = addressList[0].name;
                                                                                      pickerNumber.text = addressList[0].number;
                                                                                      instructions.text = (addressList[0].instructions != null) ? addressList[0].instructions : '';
                                                                                      _editUserDetails = true;
                                                                                      setState(() {});
                                                                                    },
                                                                                    child: Column(
                                                                                      children: [
                                                                                        SizedBox(
                                                                                          width: media.width * 0.9,
                                                                                          child: Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                            children: [
                                                                                              SizedBox(
                                                                                                width: media.width * 0.35,
                                                                                                child: Text(
                                                                                                  addressList[0].name,
                                                                                                  style: GoogleFonts.notoSans(fontSize: media.width * twelve, color: buttonColor, fontWeight: FontWeight.w600),
                                                                                                  maxLines: 1,
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(
                                                                                                width: media.width * 0.35,
                                                                                                child: Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                                                  children: [
                                                                                                    Text(
                                                                                                      addressList[0].number,
                                                                                                      style: GoogleFonts.notoSans(fontSize: media.width * twelve, color: buttonColor, fontWeight: FontWeight.w600),
                                                                                                      textAlign: TextAlign.end,
                                                                                                      maxLines: 1,
                                                                                                      overflow: TextOverflow.ellipsis,
                                                                                                    ),
                                                                                                    SizedBox(
                                                                                                      width: media.width * 0.025,
                                                                                                    ),
                                                                                                    Icon(
                                                                                                      Icons.edit,
                                                                                                      size: media.width * 0.04,
                                                                                                      color: buttonColor,
                                                                                                    )
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          height: media.width * 0.0,
                                                                                        ),
                                                                                        (addressList[0].instructions != null)
                                                                                            ? SizedBox(
                                                                                                width: media.width * 0.9,
                                                                                                child: Text(
                                                                                                  languages[choosenLanguage]['text_instructions'] + ' : ' + addressList[0].instructions,
                                                                                                  style: GoogleFonts.notoSans(fontSize: media.width * twelve, color: verifyDeclined, fontWeight: FontWeight.w600),
                                                                                                  maxLines: 1,
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                ))
                                                                                            : Container()
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            : Container(),
                                                                        (selectedGoodsId !=
                                                                                '')
                                                                            ? Container(
                                                                                padding: EdgeInsets.only(top: media.width * 0.03),
                                                                                width: media.width * 0.9,
                                                                                child: Column(
                                                                                  children: [
                                                                                    SizedBox(
                                                                                      width: media.width * 0.9,
                                                                                      child: Text(
                                                                                        languages[choosenLanguage]['text_goods_type'],
                                                                                        style: GoogleFonts.notoSans(
                                                                                          color: textColor,
                                                                                          fontSize: media.width * fourteen,
                                                                                        ),
                                                                                        maxLines: 1,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(height: media.width * 0.02),
                                                                                    InkWell(
                                                                                      onTap: () async {
                                                                                        var val = await Navigator.push(context, MaterialPageRoute(builder: (context) => const ChooseGoods()));
                                                                                        if (val) {
                                                                                          setState(() {});
                                                                                        }
                                                                                      },
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          SizedBox(
                                                                                            width: media.width * 0.7,
                                                                                            child: Text(
                                                                                              goodsTypeList.firstWhere((e) => e['id'] == int.parse(selectedGoodsId))['goods_type_name'] + ' (' + goodsSize + ')',
                                                                                              style: GoogleFonts.notoSans(fontSize: media.width * twelve, color: buttonColor),
                                                                                              maxLines: 1,
                                                                                              overflow: TextOverflow.ellipsis,
                                                                                            ),
                                                                                          ),
                                                                                          Icon(
                                                                                            Icons.arrow_forward_ios,
                                                                                            size: media.width * 0.04,
                                                                                            color: buttonColor,
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              )
                                                                            : Container(),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            (choosenVehicle != null && widget.type != 1)
                                                                                ? SizedBox(
                                                                                    height: media.width * 0.106,
                                                                                    width: media.width * 0.4,
                                                                                    child: SingleChildScrollView(
                                                                                        scrollDirection: Axis.horizontal,
                                                                                        child: InkWell(
                                                                                          onTap: () {
                                                                                            showModalBottomSheet(
                                                                                                context: context,
                                                                                                isScrollControlled: true,
                                                                                                builder: (context) {
                                                                                                  return ChoosePaymentMethodContainer(
                                                                                                    type: widget.type,
                                                                                                    onTap: () {
                                                                                                      setState(() {
                                                                                                        payingVia = choosenInPopUp;
                                                                                                      });
                                                                                                      Navigator.pop(context);
                                                                                                    },
                                                                                                  );
                                                                                                });
                                                                                          },
                                                                                          child: SizedBox(
                                                                                            // height: media.width * 0.106,
                                                                                            width: media.width * 0.3,
                                                                                            child: Row(
                                                                                              // mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                    ? Image.asset(
                                                                                                        'assets/images/cash.png',
                                                                                                        width: media.width * 0.07,
                                                                                                        height: media.width * 0.7,
                                                                                                        fit: BoxFit.contain,
                                                                                                      )
                                                                                                    : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'wallet')
                                                                                                        ? Image.asset(
                                                                                                            'assets/images/wallet.png',
                                                                                                            width: media.width * 0.07,
                                                                                                            height: media.width * 0.07,
                                                                                                            fit: BoxFit.contain,
                                                                                                          )
                                                                                                        : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                            ? Image.asset(
                                                                                                                'assets/images/card.png',
                                                                                                                width: media.width * 0.07,
                                                                                                                height: media.width * 0.07,
                                                                                                                fit: BoxFit.contain,
                                                                                                              )
                                                                                                            : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'upi')
                                                                                                                ? Image.asset(
                                                                                                                    'assets/images/upi.png',
                                                                                                                    width: media.width * 0.07,
                                                                                                                    height: media.width * 0.07,
                                                                                                                    fit: BoxFit.contain,
                                                                                                                  )
                                                                                                                : Container(),
                                                                                                SizedBox(
                                                                                                  width: media.width * 0.02,
                                                                                                ),
                                                                                                MyText(
                                                                                                  text: (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                      ? languages[choosenLanguage]['text_cash']
                                                                                                      : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'wallet')
                                                                                                          ? languages[choosenLanguage]['text_wallet']
                                                                                                          : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                              ? languages[choosenLanguage]['text_card']
                                                                                                              : languages[choosenLanguage]['text_upi'],
                                                                                                  size: media.width * sixteen,
                                                                                                  fontweight: FontWeight.w600,
                                                                                                  color: (isDarkTheme == true) ? Colors.white : Colors.black,
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  width: media.width * 0.03,
                                                                                                ),
                                                                                                RotatedBox(
                                                                                                  quarterTurns: 1,
                                                                                                  child: Icon(
                                                                                                    Icons.arrow_forward_ios,
                                                                                                    color: textColor,
                                                                                                    size: media.width * 0.03,
                                                                                                  ),
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        )),
                                                                                  )
                                                                                : (choosenVehicle != null && widget.type == 1)
                                                                                    ? InkWell(
                                                                                        onTap: () {
                                                                                          showModalBottomSheet(
                                                                                              context: context,
                                                                                              isScrollControlled: true,
                                                                                              builder: (context) {
                                                                                                return ChoosePaymentMethodContainer(
                                                                                                  type: widget.type,
                                                                                                  onTap: () {
                                                                                                    setState(() {
                                                                                                      payingVia = choosenInPopUp;
                                                                                                    });
                                                                                                    Navigator.pop(context);
                                                                                                  },
                                                                                                );
                                                                                              });
                                                                                        },
                                                                                        child: SizedBox(
                                                                                          height: media.width * 0.106,
                                                                                          width: media.width * 0.4,
                                                                                          child: SingleChildScrollView(
                                                                                            scrollDirection: Axis.horizontal,
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                                              children: [
                                                                                                (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                    ? Image.asset(
                                                                                                        'assets/images/cash.png',
                                                                                                        width: media.width * 0.07,
                                                                                                        height: media.width * 0.07,
                                                                                                        fit: BoxFit.contain,
                                                                                                      )
                                                                                                    : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'wallet')
                                                                                                        ? Image.asset(
                                                                                                            'assets/images/wallet.png',
                                                                                                            width: media.width * 0.07,
                                                                                                            height: media.width * 0.07,
                                                                                                            fit: BoxFit.contain,
                                                                                                          )
                                                                                                        : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                            ? Image.asset(
                                                                                                                'assets/images/card.png',
                                                                                                                width: media.width * 0.07,
                                                                                                                height: media.width * 0.07,
                                                                                                                fit: BoxFit.contain,
                                                                                                              )
                                                                                                            : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'upi')
                                                                                                                ? Image.asset(
                                                                                                                    'assets/images/upi.png',
                                                                                                                    width: media.width * 0.07,
                                                                                                                    height: media.width * 0.07,
                                                                                                                    fit: BoxFit.contain,
                                                                                                                  )
                                                                                                                : Container(),
                                                                                                SizedBox(
                                                                                                  width: media.width * 0.02,
                                                                                                ),
                                                                                                MyText(
                                                                                                  text: (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                      ? languages[choosenLanguage]['text_cash']
                                                                                                      : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'wallet')
                                                                                                          ? languages[choosenLanguage]['text_wallet']
                                                                                                          : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                              ? languages[choosenLanguage]['text_card']
                                                                                                              : languages[choosenLanguage]['text_upi'],
                                                                                                  size: media.width * sixteen,
                                                                                                  fontweight: FontWeight.w600,
                                                                                                  color: (isDarkTheme == true) ? Colors.white : Colors.black,
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  width: media.width * 0.03,
                                                                                                ),
                                                                                                RotatedBox(
                                                                                                  quarterTurns: 1,
                                                                                                  child: Icon(
                                                                                                    Icons.arrow_forward_ios,
                                                                                                    color: textColor,
                                                                                                    size: media.width * 0.03,
                                                                                                  ),
                                                                                                )
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      )
                                                                                    : Container(),
                                                                            (choosenVehicle != null && (widget.type == 1 || etaDetails[choosenVehicle]['enable_bidding'] == null || etaDetails[choosenVehicle]['enable_bidding'] == false) && widget.type != 2 && isOneWayTrip == true)
                                                                                ? InkWell(
                                                                                    onTap: () {
                                                                                      // setState(() {
                                                                                      //   addCoupon =
                                                                                      //       true;
                                                                                      // });

                                                                                      showModalBottomSheet(
                                                                                          context: context,
                                                                                          isScrollControlled: true,
                                                                                          builder: (context) {
                                                                                            return ApplyCouponsContainer(
                                                                                              type: widget.type,
                                                                                            );
                                                                                          });
                                                                                    },
                                                                                    child: SizedBox(
                                                                                      height: media.width * 0.106,
                                                                                      width: media.width * 0.4,
                                                                                      // decoration:
                                                                                      //     const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xffF3F3F3), width: 1.1))),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                                        children: [
                                                                                          MyText(
                                                                                            text: languages[choosenLanguage]['text_coupons'],
                                                                                            size: media.width * fourteen,
                                                                                            fontweight: FontWeight.w600,
                                                                                            // color: page,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: media.width * 0.025,
                                                                                          ),
                                                                                          RotatedBox(
                                                                                            quarterTurns: 1,
                                                                                            child: Icon(
                                                                                              Icons.arrow_forward_ios,
                                                                                              color: textColor,
                                                                                              size: media.width * 0.03,
                                                                                            ),
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                : Container(),
                                                                          ],
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              media.width * 0.015,
                                                                        ),
                                                                        ((userDetails['enable_driver_preference_for_user'] != '1' && userDetails['enable_pet_preference_for_user'] != '1' && userDetails['enable_luggage_preference_for_user'] != '1') ||
                                                                                choosenTransportType == 1 ||
                                                                                userDetails['enable_modules_for_applications'] == 'delivery')
                                                                            ? Container()
                                                                            : Column(
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      InkWell(
                                                                                        onTap: () {
                                                                                          if (addPetPreferences == true) {
                                                                                            choosePets = true;
                                                                                          } else {
                                                                                            choosePets = false;
                                                                                          }
                                                                                          if (addLuggagePreferences == true) {
                                                                                            chooseLuggages = true;
                                                                                          } else {
                                                                                            chooseLuggages = false;
                                                                                          }
                                                                                          showModalBottomSheet(
                                                                                              context: context,
                                                                                              isScrollControlled: true,
                                                                                              builder: (context) {
                                                                                                return ChoosePreferencesContainer(
                                                                                                  type: widget.type,
                                                                                                  onTap: () {
                                                                                                    setState(() {
                                                                                                      addLuggagePreferences = chooseLuggages;
                                                                                                      addPetPreferences = choosePets;
                                                                                                    });
                                                                                                    Navigator.pop(context);
                                                                                                  },
                                                                                                );
                                                                                              });
                                                                                        },
                                                                                        child: Row(
                                                                                          children: [
                                                                                            SizedBox(
                                                                                              height: media.width * 0.05,
                                                                                              width: media.width * 0.075,
                                                                                              child: Image.asset(
                                                                                                'assets/images/Tune.png',
                                                                                                color: textColor,
                                                                                              ),
                                                                                            ),
                                                                                            MyText(
                                                                                              text: languages[choosenLanguage]['text_ride_preference'],
                                                                                              size: media.width * fourteen,
                                                                                              fontweight: FontWeight.w600,
                                                                                            ),
                                                                                            if (addPetPreferences == true || addLuggagePreferences == true)
                                                                                              MyText(
                                                                                                text: ' :- ',
                                                                                                size: media.width * fourteen,
                                                                                                fontweight: FontWeight.w600,
                                                                                              ),
                                                                                            SizedBox(
                                                                                              width: media.width * 0.025,
                                                                                            ),
                                                                                            if (addPetPreferences == true)
                                                                                              MyText(
                                                                                                text: languages[choosenLanguage]['text_pets'],
                                                                                                size: media.width * fourteen,
                                                                                                fontweight: FontWeight.w600,
                                                                                                color: theme,
                                                                                              ),
                                                                                            if (addPetPreferences == true && addLuggagePreferences == true)
                                                                                              MyText(
                                                                                                text: ', ',
                                                                                                size: media.width * fourteen,
                                                                                                fontweight: FontWeight.w600,
                                                                                                color: theme,
                                                                                              ),
                                                                                            if (addLuggagePreferences == true)
                                                                                              MyText(
                                                                                                text: languages[choosenLanguage]['text_luggages'],
                                                                                                size: media.width * fourteen,
                                                                                                fontweight: FontWeight.w600,
                                                                                                color: theme,
                                                                                              ),
                                                                                            SizedBox(
                                                                                              width: media.width * 0.025,
                                                                                            ),
                                                                                            (addPetPreferences == false && addLuggagePreferences == false)
                                                                                                ? Container()
                                                                                                : Icon(
                                                                                                    // Icons.arrow_forward_ios,
                                                                                                    Icons.edit,
                                                                                                    size: media.width * 0.03,
                                                                                                    color: theme,
                                                                                                  )
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  SizedBox(
                                                                                    height: media.width * 0.05,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                        (selectedGoodsId == '' &&
                                                                                choosenTransportType == 1)
                                                                            ? Button(
                                                                                width: media.width * 0.9,
                                                                                onTap: () async {
                                                                                  var val = await Navigator.push(context, MaterialPageRoute(builder: (context) => const ChooseGoods()));
                                                                                  if (val) {
                                                                                    setState(() {});
                                                                                  }
                                                                                },
                                                                                text: languages[choosenLanguage]['text_choose_goods'],
                                                                              )
                                                                            : SizedBox(
                                                                                width: media.width * 0.9,
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    (userDetails['show_ride_later_feature'] == true && ((widget.type == null) ? (etaDetails[choosenVehicle]['enable_bidding'] == null || etaDetails[choosenVehicle]['enable_bidding'] == false) : true) && isOutStation == false)
                                                                                        ? InkWell(
                                                                                            onTap: () async {
                                                                                              if (((rentalOption.isEmpty && (etaDetails[choosenVehicle]['user_wallet_balance'] >= etaDetails[choosenVehicle]['total'] && etaDetails[choosenVehicle]['has_discount'] == false) || (rentalOption.isEmpty && etaDetails[choosenVehicle]['has_discount'] == true && etaDetails[choosenVehicle]['user_wallet_balance'] >= etaDetails[choosenVehicle]['discounted_totel'])) || (rentalOption.isEmpty && etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] != 'wallet')) || ((rentalOption.isNotEmpty && (etaDetails[0]['user_wallet_balance'] >= rentalOption[choosenVehicle]['fare_amount']) && rentalOption[choosenVehicle]['has_discount'] == false) || (rentalOption.isNotEmpty && rentalOption[choosenVehicle]['has_discount'] == true && etaDetails[0]['user_wallet_balance'] >= rentalOption[choosenVehicle]['discounted_totel']) || rentalOption.isNotEmpty && rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] != 'wallet')) {
                                                                                                if (choosenVehicle != null) {
                                                                                                  setState(() {
                                                                                                    choosenDateTime = DateTime.now().add(Duration(minutes: int.parse(userDetails['user_can_make_a_ride_after_x_miniutes'])));
                                                                                                    // _dateTimePicker = true;
                                                                                                  });

                                                                                                  showModalBottomSheet(
                                                                                                      context: context,
                                                                                                      isScrollControlled: true,
                                                                                                      // isDismissible: false,
                                                                                                      builder: (context) {
                                                                                                        return RideLaterBottomSheet(
                                                                                                          type: widget.type,
                                                                                                        );
                                                                                                      });
                                                                                                }
                                                                                              } else {
                                                                                                setState(() {
                                                                                                  islowwalletbalance = true;
                                                                                                });
                                                                                              }
                                                                                            },
                                                                                            child: (!confirmRideLater)
                                                                                                ? Container(
                                                                                                    height: media.width * 0.12,
                                                                                                    width: media.width * 0.12,
                                                                                                    decoration: BoxDecoration(color: page, borderRadius: BorderRadius.circular(media.width * 0.02), border: Border.all(color: textColor)),
                                                                                                    padding: EdgeInsets.all(media.width * 0.02),
                                                                                                    child: (confirmRideLater == false)
                                                                                                        ? Image.asset(
                                                                                                            'assets/images/ride_later.png',
                                                                                                            color: textColor,
                                                                                                          )
                                                                                                        : MyText(
                                                                                                            text: DateFormat().format(choosenDateTime).toString(),
                                                                                                            size: media.width * twelve,
                                                                                                          ),
                                                                                                  )
                                                                                                : Container(
                                                                                                    height: media.width * 0.12,
                                                                                                    width: media.width * 0.2,
                                                                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: textColor)),
                                                                                                    alignment: Alignment.center,
                                                                                                    child: Column(
                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                      children: [
                                                                                                        MyText(text: DateFormat().format(choosenDateTime).toString().split(" ")[1] + DateFormat().format(choosenDateTime).toString().split(" ")[2], size: media.width * twelve, fontweight: FontWeight.w400),
                                                                                                        MyText(text: DateFormat().format(choosenDateTime).toString().split(" ")[3], size: media.width * twelve, fontweight: FontWeight.w400),
                                                                                                      ],
                                                                                                    ),
                                                                                                  ),
                                                                                          )
                                                                                        : Container(),
                                                                                    Button(
                                                                                        borcolor: Colors.black,
                                                                                        width: ((userDetails['show_ride_later_feature'] == true))
                                                                                            ? ((widget.type == null) ? (etaDetails[choosenVehicle]['enable_bidding'] == null || etaDetails[choosenVehicle]['enable_bidding'] == false) : true) && !isOutStation
                                                                                                ? (confirmRideLater == false)
                                                                                                    ? media.width * 0.75
                                                                                                    : media.width * 0.68
                                                                                                : media.width * 0.89
                                                                                            : media.width * 0.89,
                                                                                        onTap: () async {
                                                                                          if ((widget.type == 2) || (((rentalOption.isEmpty && (etaDetails[choosenVehicle]['user_wallet_balance'] >= etaDetails[choosenVehicle]['total'] && etaDetails[choosenVehicle]['has_discount'] == false) || (rentalOption.isEmpty && etaDetails[choosenVehicle]['has_discount'] == true && etaDetails[choosenVehicle]['user_wallet_balance'] >= etaDetails[choosenVehicle]['discounted_totel'])) || (rentalOption.isEmpty && etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] != 'wallet')) || ((rentalOption.isNotEmpty && (etaDetails[0]['user_wallet_balance'] >= rentalOption[choosenVehicle]['fare_amount']) && rentalOption[choosenVehicle]['has_discount'] == false) || (rentalOption.isNotEmpty && rentalOption[choosenVehicle]['has_discount'] == true && etaDetails[0]['user_wallet_balance'] >= rentalOption[choosenVehicle]['discounted_totel']) || rentalOption.isNotEmpty && rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] != 'wallet'))) {
                                                                                            if (((widget.type == null) ? (etaDetails[choosenVehicle]['enable_bidding'] == true) : false) || isOutStation) {
                                                                                              if (isOutStation) {
                                                                                                if (isOneWayTrip && nofromdate) {
                                                                                                  setState(() {
                                                                                                    _showInfoInt = choosenVehicle;
                                                                                                    // _showInfo = true;
                                                                                                    showModalBottomSheet(
                                                                                                        context: context,
                                                                                                        isScrollControlled: true,
                                                                                                        builder: (context) {
                                                                                                          return CreateRequestBottomSheet(
                                                                                                            type: widget.type,
                                                                                                            showInfoInt: _showInfoInt,
                                                                                                            fromDate: fromDate,
                                                                                                            geo: geo,
                                                                                                            isOneWayTrip: isOneWayTrip,
                                                                                                            toDate: toDate,
                                                                                                            amount: etaDetails[choosenVehicle]['total'].toString(),
                                                                                                          );
                                                                                                        });
                                                                                                  });
                                                                                                } else {
                                                                                                  if (!nofromdate || toDate == null) {
                                                                                                    setState(() {
                                                                                                      _isDateTimebottom = 0;
                                                                                                      if (!nofromdate) {
                                                                                                        isFromDate = true;
                                                                                                      } else {
                                                                                                        isFromDate = false;
                                                                                                        toDate = fromDate.add(const Duration(days: 1, minutes: 2));
                                                                                                      }
                                                                                                    });
                                                                                                    Future.delayed(const Duration(milliseconds: 200), () {
                                                                                                      setState(() {
                                                                                                        if (isOneWayTrip) {
                                                                                                          _dateTimeHeight = media.height * 0.45;
                                                                                                        } else {
                                                                                                          _dateTimeHeight = media.height * 0.5;
                                                                                                        }
                                                                                                      });
                                                                                                    });
                                                                                                  } else {
                                                                                                    setState(() {
                                                                                                      _showInfoInt = choosenVehicle;
                                                                                                      // _showInfo = true;
                                                                                                      showModalBottomSheet(
                                                                                                          context: context,
                                                                                                          isScrollControlled: true,
                                                                                                          builder: (context) {
                                                                                                            return CreateRequestBottomSheet(
                                                                                                              type: widget.type,
                                                                                                              showInfoInt: _showInfoInt,
                                                                                                              fromDate: fromDate,
                                                                                                              geo: geo,
                                                                                                              isOneWayTrip: isOneWayTrip,
                                                                                                              toDate: toDate,
                                                                                                              amount: etaDetails[choosenVehicle]['total'].toString(),
                                                                                                            );
                                                                                                          });
                                                                                                    });
                                                                                                  }
                                                                                                }
                                                                                              } else {
                                                                                                setState(() {
                                                                                                  _showInfoInt = choosenVehicle;
                                                                                                  // _showInfo = true;
                                                                                                });
                                                                                                showModalBottomSheet(
                                                                                                    context: context,
                                                                                                    isScrollControlled: true,
                                                                                                    builder: (context) {
                                                                                                      return CreateRequestBottomSheet(
                                                                                                        type: widget.type,
                                                                                                        showInfoInt: _showInfoInt,
                                                                                                        fromDate: fromDate,
                                                                                                        geo: geo,
                                                                                                        isOneWayTrip: isOneWayTrip,
                                                                                                        toDate: toDate,
                                                                                                        amount: etaDetails[choosenVehicle]['total'].toString(),
                                                                                                      );
                                                                                                    });
                                                                                              }
                                                                                            } else {
                                                                                              setState(() {
                                                                                                isLoading = true;
                                                                                              });
                                                                                              dynamic result;
                                                                                              if (choosenVehicle != null) {
                                                                                                if (confirmRideLater == true) {
                                                                                                  if (widget.type != 1) {
                                                                                                    if (etaDetails[choosenVehicle]['has_discount'] == false) {
                                                                                                      dynamic val;
                                                                                                      setState(() {
                                                                                                        isLoading = true;
                                                                                                      });
                                                                                                      if (choosenTransportType == 0) {
                                                                                                        val = await createRequestLater(
                                                                                                            (addressList.where((element) => element.type == 'drop').isNotEmpty)
                                                                                                                ? jsonEncode({
                                                                                                                    'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                                    'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                                    'drop_lat': addressList.firstWhere((e) => e.type == 'drop').latlng.latitude,
                                                                                                                    'drop_lng': addressList.firstWhere((e) => e.type == 'drop').latlng.longitude,
                                                                                                                    'poly_line': polyString,
                                                                                                                    'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                    'ride_type': 1,
                                                                                                                    'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                        ? 0
                                                                                                                        : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                            ? 1
                                                                                                                            : 2,
                                                                                                                    'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                                    'drop_address': addressList.firstWhere((e) => e.type == 'drop').address,
                                                                                                                    'trip_start_time': choosenDateTime.toString().substring(0, 19),
                                                                                                                    'is_later': true,
                                                                                                                    'stops': jsonEncode(dropStopList),
                                                                                                                    'request_eta_amount': etaDetails[choosenVehicle]['total'],
                                                                                                                    'is_pet_available': (addPetPreferences == false) ? false : true,
                                                                                                                    'is_luggage_available': (addLuggagePreferences == false) ? false : true
                                                                                                                  })
                                                                                                                : jsonEncode({
                                                                                                                    'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                                    'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                                    'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                    'ride_type': 1,
                                                                                                                    'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                        ? 0
                                                                                                                        : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                            ? 1
                                                                                                                            : 2,
                                                                                                                    'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                                    'trip_start_time': choosenDateTime.toString().substring(0, 19),
                                                                                                                    'is_later': true,
                                                                                                                    'request_eta_amount': etaDetails[choosenVehicle]['total'],
                                                                                                                    'is_pet_available': (addPetPreferences == false) ? false : true,
                                                                                                                    'is_luggage_available': (addLuggagePreferences == false) ? false : true
                                                                                                                  }),
                                                                                                            'api/v1/request/create');
                                                                                                      } else {
                                                                                                        if (dropStopList.isNotEmpty) {
                                                                                                          val = await createRequestLater(
                                                                                                              jsonEncode({
                                                                                                                'pick_lat': addressList[0].latlng.latitude,
                                                                                                                'pick_lng': addressList[0].latlng.longitude,
                                                                                                                'drop_lat': addressList[addressList.length - 1].latlng.latitude,
                                                                                                                'drop_lng': addressList[addressList.length - 1].latlng.longitude,
                                                                                                                'poly_line': polyString,
                                                                                                                'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                'ride_type': 1,
                                                                                                                'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                    ? 0
                                                                                                                    : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                        ? 1
                                                                                                                        : 2,
                                                                                                                'pick_address': addressList[0].address,
                                                                                                                'drop_address': addressList[addressList.length - 1].address,
                                                                                                                'trip_start_time': choosenDateTime.toString().substring(0, 19),
                                                                                                                'is_later': true,
                                                                                                                'pickup_poc_name': addressList[0].name,
                                                                                                                'pickup_poc_mobile': addressList[0].number,
                                                                                                                'pickup_poc_instruction': addressList[0].instructions,
                                                                                                                'drop_poc_name': addressList[addressList.length - 1].name,
                                                                                                                'drop_poc_mobile': addressList[addressList.length - 1].number,
                                                                                                                'drop_poc_instruction': addressList[addressList.length - 1].instructions,
                                                                                                                'goods_type_id': selectedGoodsId.toString(),
                                                                                                                'stops': jsonEncode(dropStopList),
                                                                                                                'goods_type_quantity': goodsSize
                                                                                                              }),
                                                                                                              (userDetails['is_delivery_app'] != null && userDetails['is_delivery_app'] == true) ? 'api/v1/request/create' : 'api/v1/request/delivery/create');
                                                                                                        } else {
                                                                                                          val = await createRequestLater(
                                                                                                              jsonEncode({
                                                                                                                'pick_lat': addressList[0].latlng.latitude,
                                                                                                                'pick_lng': addressList[0].latlng.longitude,
                                                                                                                'drop_lat': addressList[addressList.length - 1].latlng.latitude,
                                                                                                                'drop_lng': addressList[addressList.length - 1].latlng.longitude,
                                                                                                                'poly_line': polyString,
                                                                                                                'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                'ride_type': 1,
                                                                                                                'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                    ? 0
                                                                                                                    : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                        ? 1
                                                                                                                        : 2,
                                                                                                                'pick_address': addressList[0].address,
                                                                                                                'drop_address': addressList[addressList.length - 1].address,
                                                                                                                'trip_start_time': choosenDateTime.toString().substring(0, 19),
                                                                                                                'is_later': true,
                                                                                                                'pickup_poc_name': addressList[0].name,
                                                                                                                'pickup_poc_mobile': addressList[0].number,
                                                                                                                'pickup_poc_instruction': addressList[0].instructions,
                                                                                                                'drop_poc_name': addressList[addressList.length - 1].name,
                                                                                                                'drop_poc_mobile': addressList[addressList.length - 1].number,
                                                                                                                'drop_poc_instruction': addressList[addressList.length - 1].instructions,
                                                                                                                'goods_type_id': selectedGoodsId.toString(),
                                                                                                                'goods_type_quantity': goodsSize
                                                                                                              }),
                                                                                                              (userDetails['is_delivery_app'] != null && userDetails['is_delivery_app'] == true) ? 'api/v1/request/create' : 'api/v1/request/delivery/create');
                                                                                                        }
                                                                                                      }
                                                                                                      setState(() {
                                                                                                        if (val == 'success') {
                                                                                                          isLoading = false;
                                                                                                          showModalBottomSheet(
                                                                                                              context: context,
                                                                                                              isScrollControlled: false,
                                                                                                              isDismissible: false,
                                                                                                              builder: (context) {
                                                                                                                return const SuccessPopUp();
                                                                                                              });
                                                                                                        }
                                                                                                      });
                                                                                                    } else {
                                                                                                      dynamic val;
                                                                                                      setState(() {
                                                                                                        isLoading = true;
                                                                                                      });

                                                                                                      if (choosenTransportType == 0) {
                                                                                                        val = await createRequestLater(
                                                                                                            (addressList.where((element) => element.type == 'drop').isNotEmpty)
                                                                                                                ? jsonEncode({
                                                                                                                    'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                                    'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                                    'drop_lat': addressList.firstWhere((e) => e.type == 'drop').latlng.latitude,
                                                                                                                    'drop_lng': addressList.firstWhere((e) => e.type == 'drop').latlng.longitude,
                                                                                                                    'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                    'poly_line': polyString,
                                                                                                                    'ride_type': 1,
                                                                                                                    'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                        ? 0
                                                                                                                        : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                            ? 1
                                                                                                                            : 2,
                                                                                                                    'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                                    'drop_address': addressList.firstWhere((e) => e.type == 'drop').address,
                                                                                                                    'promocode_id': etaDetails[choosenVehicle]['promocode_id'],
                                                                                                                    'trip_start_time': choosenDateTime.toString().substring(0, 19),
                                                                                                                    'is_later': true,
                                                                                                                    'request_eta_amount': etaDetails[choosenVehicle]['total'],
                                                                                                                    'is_pet_available': (addPetPreferences == false) ? false : true,
                                                                                                                    'is_luggage_available': (addLuggagePreferences == false) ? false : true
                                                                                                                  })
                                                                                                                : jsonEncode({
                                                                                                                    'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                                    'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                                    'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                    'ride_type': 1,
                                                                                                                    'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                        ? 0
                                                                                                                        : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                            ? 1
                                                                                                                            : 2,
                                                                                                                    'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                                    'promocode_id': etaDetails[choosenVehicle]['promocode_id'],
                                                                                                                    'trip_start_time': choosenDateTime.toString().substring(0, 19),
                                                                                                                    'is_later': true,
                                                                                                                    'request_eta_amount': etaDetails[choosenVehicle]['total'],
                                                                                                                    'is_pet_available': (addPetPreferences == false) ? false : true,
                                                                                                                    'is_luggage_available': (addLuggagePreferences == false) ? false : true
                                                                                                                  }),
                                                                                                            'api/v1/request/create');
                                                                                                      } else {
                                                                                                        if (dropStopList.isNotEmpty) {
                                                                                                          val = await createRequestLater(
                                                                                                              jsonEncode({
                                                                                                                'pick_lat': addressList[0].latlng.latitude,
                                                                                                                'pick_lng': addressList[0].latlng.longitude,
                                                                                                                'drop_lat': addressList[addressList.length - 1].latlng.latitude,
                                                                                                                'drop_lng': addressList[addressList.length - 1].latlng.longitude,
                                                                                                                'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                'ride_type': 1,
                                                                                                                'poly_line': polyString,
                                                                                                                'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                    ? 0
                                                                                                                    : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                        ? 1
                                                                                                                        : 2,
                                                                                                                'pick_address': addressList[0].address,
                                                                                                                'drop_address': addressList[addressList.length - 1].address,
                                                                                                                'promocode_id': etaDetails[choosenVehicle]['promocode_id'],
                                                                                                                'trip_start_time': choosenDateTime.toString().substring(0, 19),
                                                                                                                'is_later': true,
                                                                                                                'pickup_poc_name': addressList[0].name,
                                                                                                                'pickup_poc_mobile': addressList[0].number,
                                                                                                                'pickup_poc_instruction': addressList[0].instructions,
                                                                                                                'drop_poc_name': addressList[addressList.length - 1].name,
                                                                                                                'drop_poc_mobile': addressList[addressList.length - 1].number,
                                                                                                                'drop_poc_instruction': addressList[addressList.length - 1].instructions,
                                                                                                                'goods_type_id': selectedGoodsId.toString(),
                                                                                                                'stops': jsonEncode(dropStopList),
                                                                                                                'goods_type_quantity': goodsSize
                                                                                                              }),
                                                                                                              (userDetails['is_delivery_app'] != null && userDetails['is_delivery_app'] == true) ? 'api/v1/request/create' : 'api/v1/request/delivery/create');
                                                                                                        } else {
                                                                                                          val = await createRequestLater(
                                                                                                              jsonEncode({
                                                                                                                'pick_lat': addressList[0].latlng.latitude,
                                                                                                                'pick_lng': addressList[0].latlng.longitude,
                                                                                                                'drop_lat': addressList[addressList.length - 1].latlng.latitude,
                                                                                                                'drop_lng': addressList[addressList.length - 1].latlng.longitude,
                                                                                                                'poly_line': polyString,
                                                                                                                'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                'ride_type': 1,
                                                                                                                'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                    ? 0
                                                                                                                    : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                        ? 1
                                                                                                                        : 2,
                                                                                                                'pick_address': addressList[0].address,
                                                                                                                'drop_address': addressList[addressList.length - 1].address,
                                                                                                                'promocode_id': etaDetails[choosenVehicle]['promocode_id'],
                                                                                                                'trip_start_time': choosenDateTime.toString().substring(0, 19),
                                                                                                                'is_later': true,
                                                                                                                'pickup_poc_name': addressList[0].name,
                                                                                                                'pickup_poc_mobile': addressList[0].number,
                                                                                                                'pickup_poc_instruction': addressList[0].instructions,
                                                                                                                'drop_poc_name': addressList[addressList.length - 1].name,
                                                                                                                'drop_poc_mobile': addressList[addressList.length - 1].number,
                                                                                                                'drop_poc_instruction': addressList[addressList.length - 1].instructions,
                                                                                                                'goods_type_id': selectedGoodsId.toString(),
                                                                                                                'goods_type_quantity': goodsSize
                                                                                                              }),
                                                                                                              (userDetails['is_delivery_app'] != null && userDetails['is_delivery_app'] == true) ? 'api/v1/request/create' : 'api/v1/request/delivery/create');
                                                                                                        }
                                                                                                      }
                                                                                                      setState(() {
                                                                                                        if (val == 'success') {
                                                                                                          isLoading = false;
                                                                                                          showModalBottomSheet(
                                                                                                              context: context,
                                                                                                              isScrollControlled: false,
                                                                                                              isDismissible: false,
                                                                                                              builder: (context) {
                                                                                                                return const SuccessPopUp();
                                                                                                              });
                                                                                                        }
                                                                                                      });
                                                                                                    }
                                                                                                  } else {
                                                                                                    if (rentalOption[choosenVehicle]['has_discount'] == false) {
                                                                                                      dynamic val;
                                                                                                      setState(() {
                                                                                                        isLoading = true;
                                                                                                      });

                                                                                                      if (choosenTransportType == 0) {
                                                                                                        val = await createRequestLater(
                                                                                                            jsonEncode({
                                                                                                              'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                              'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                              'vehicle_type': rentalOption[choosenVehicle]['zone_type_id'],
                                                                                                              'ride_type': 1,
                                                                                                              'payment_opt': (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                  ? 0
                                                                                                                  : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                      ? 1
                                                                                                                      : 2,
                                                                                                              'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                              'trip_start_time': choosenDateTime.toString().substring(0, 19),
                                                                                                              'is_later': true,
                                                                                                              'request_eta_amount': rentalOption[choosenVehicle]['fare_amount'],
                                                                                                              'rental_pack_id': etaDetails[rentalChoosenOption]['id'],
                                                                                                              'is_pet_available': (addPetPreferences == false) ? false : true,
                                                                                                              'is_luggage_available': (addLuggagePreferences == false) ? false : true
                                                                                                            }),
                                                                                                            'api/v1/request/create');
                                                                                                      } else {
                                                                                                        val = await createRequestLater(
                                                                                                            jsonEncode({
                                                                                                              'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                              'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                              'vehicle_type': rentalOption[choosenVehicle]['zone_type_id'],
                                                                                                              'ride_type': 1,
                                                                                                              'payment_opt': (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                  ? 0
                                                                                                                  : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                      ? 1
                                                                                                                      : 2,
                                                                                                              'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                              'trip_start_time': choosenDateTime.toString().substring(0, 19),
                                                                                                              'is_later': true,
                                                                                                              'request_eta_amount': rentalOption[choosenVehicle]['fare_amount'],
                                                                                                              'rental_pack_id': etaDetails[rentalChoosenOption]['id'],
                                                                                                              'goods_type_id': selectedGoodsId.toString(),
                                                                                                              'goods_type_quantity': goodsSize,
                                                                                                              'pickup_poc_name': addressList[0].name,
                                                                                                              'pickup_poc_mobile': addressList[0].number,
                                                                                                              'pickup_poc_instruction': addressList[0].instructions,
                                                                                                            }),
                                                                                                            (userDetails['is_delivery_app'] != null && userDetails['is_delivery_app'] == true) ? 'api/v1/request/create' : 'api/v1/request/delivery/create');
                                                                                                      }

                                                                                                      if (val == 'success') {
                                                                                                        setState(() {
                                                                                                          if (val == 'success') {
                                                                                                            isLoading = false;
                                                                                                            showModalBottomSheet(
                                                                                                                context: context,
                                                                                                                isScrollControlled: false,
                                                                                                                isDismissible: false,
                                                                                                                builder: (context) {
                                                                                                                  return const SuccessPopUp();
                                                                                                                });
                                                                                                          }
                                                                                                        });
                                                                                                      } else if (val == 'logout') {
                                                                                                        navigateLogout();
                                                                                                      }
                                                                                                    } else {
                                                                                                      dynamic val;
                                                                                                      setState(() {
                                                                                                        isLoading = true;
                                                                                                      });

                                                                                                      if (choosenTransportType == 0) {
                                                                                                        val = await createRequestLater(
                                                                                                            jsonEncode({
                                                                                                              'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                              'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                              'vehicle_type': rentalOption[choosenVehicle]['zone_type_id'],
                                                                                                              'ride_type': 1,
                                                                                                              'payment_opt': (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                  ? 0
                                                                                                                  : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                      ? 1
                                                                                                                      : 2,
                                                                                                              'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                              'promocode_id': rentalOption[choosenVehicle]['promocode_id'],
                                                                                                              'trip_start_time': choosenDateTime.toString().substring(0, 19),
                                                                                                              'is_later': true,
                                                                                                              'request_eta_amount': rentalOption[choosenVehicle]['fare_amount'],
                                                                                                              'rental_pack_id': etaDetails[rentalChoosenOption]['id'],
                                                                                                              'is_pet_available': (addPetPreferences == false) ? false : true,
                                                                                                              'is_luggage_available': (addLuggagePreferences == false) ? false : true
                                                                                                            }),
                                                                                                            'api/v1/request/create');
                                                                                                      } else {
                                                                                                        val = await createRequestLater(
                                                                                                            jsonEncode({
                                                                                                              'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                              'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                              'vehicle_type': rentalOption[choosenVehicle]['zone_type_id'],
                                                                                                              'ride_type': 1,
                                                                                                              'payment_opt': (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                  ? 0
                                                                                                                  : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                      ? 1
                                                                                                                      : 2,
                                                                                                              'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                              'promocode_id': rentalOption[choosenVehicle]['promocode_id'],
                                                                                                              'trip_start_time': choosenDateTime.toString().substring(0, 19),
                                                                                                              'is_later': true,
                                                                                                              'request_eta_amount': rentalOption[choosenVehicle]['fare_amount'],
                                                                                                              'rental_pack_id': etaDetails[rentalChoosenOption]['id'],
                                                                                                              'goods_type_id': selectedGoodsId.toString(),
                                                                                                              'goods_type_quantity': goodsSize,
                                                                                                              'pickup_poc_name': addressList[0].name,
                                                                                                              'pickup_poc_mobile': addressList[0].number,
                                                                                                              'pickup_poc_instruction': addressList[0].instructions,
                                                                                                            }),
                                                                                                            (userDetails['is_delivery_app'] != null && userDetails['is_delivery_app'] == true) ? 'api/v1/request/create' : 'api/v1/request/delivery/create');
                                                                                                      }

                                                                                                      if (val == 'success') {
                                                                                                        setState(() {
                                                                                                          if (val == 'success') {
                                                                                                            isLoading = false;
                                                                                                            showModalBottomSheet(
                                                                                                                context: context,
                                                                                                                isScrollControlled: false,
                                                                                                                isDismissible: false,
                                                                                                                builder: (context) {
                                                                                                                  return const SuccessPopUp();
                                                                                                                });
                                                                                                          }
                                                                                                          //  else if (val == 'logout') {
                                                                                                          //   navigateLogout();
                                                                                                          // }
                                                                                                        });
                                                                                                      } else if (val == 'logout') {
                                                                                                        navigateLogout();
                                                                                                      }
                                                                                                    }
                                                                                                    // setState(() {
                                                                                                    //   dropConfirmed =
                                                                                                    //       false;
                                                                                                    //       etaDetails.clear();
                                                                                                    // });
                                                                                                  }
                                                                                                } else {
                                                                                                  if (widget.type != 1) {
                                                                                                    if (etaDetails[choosenVehicle]['has_discount'] == false) {
                                                                                                      if (choosenTransportType == 0) {
                                                                                                        dropStopList.clear();
                                                                                                        if (addressList.length > 2) {
                                                                                                          for (var i = 1; i < addressList.length; i++) {
                                                                                                            dropStopList.add(DropStops(
                                                                                                              order: addressList[i].id,
                                                                                                              latitude: addressList[i].latlng.latitude,
                                                                                                              longitude: addressList[i].latlng.longitude,
                                                                                                              address: addressList[i].address,
                                                                                                            ));
                                                                                                          }

                                                                                                          result = await createRequest(
                                                                                                              jsonEncode({
                                                                                                                'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                                'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                                'drop_lat': addressList.lastWhere((e) => e.type == 'drop').latlng.latitude,
                                                                                                                'drop_lng': addressList.lastWhere((e) => e.type == 'drop').latlng.longitude,
                                                                                                                'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                'ride_type': 1,
                                                                                                                'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                    ? 0
                                                                                                                    : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                        ? 1
                                                                                                                        : 2,
                                                                                                                'stops': jsonEncode(dropStopList),
                                                                                                                'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                                'drop_address': addressList.lastWhere((e) => e.type == 'drop').address,
                                                                                                                'request_eta_amount': etaDetails[choosenVehicle]['total'],
                                                                                                                'poly_line': polyString,
                                                                                                                'is_pet_available': (addPetPreferences == false) ? false : true,
                                                                                                                'is_luggage_available': (addLuggagePreferences == false) ? false : true
                                                                                                              }),
                                                                                                              'api/v1/request/create');
                                                                                                        } else {
                                                                                                          result = await createRequest(
                                                                                                              (addressList.where((element) => element.type == 'drop').isNotEmpty)
                                                                                                                  ? jsonEncode({
                                                                                                                      'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                                      'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                                      'drop_lat': addressList.lastWhere((e) => e.type == 'drop').latlng.latitude,
                                                                                                                      'drop_lng': addressList.lastWhere((e) => e.type == 'drop').latlng.longitude,
                                                                                                                      'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                      'ride_type': 1,
                                                                                                                      'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                          ? 0
                                                                                                                          : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                              ? 1
                                                                                                                              : 2,
                                                                                                                      'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                                      'drop_address': addressList.lastWhere((e) => e.type == 'drop').address,
                                                                                                                      'request_eta_amount': etaDetails[choosenVehicle]['total'],
                                                                                                                      'poly_line': polyString,
                                                                                                                      'is_pet_available': (addPetPreferences == false) ? false : true,
                                                                                                                      'is_luggage_available': (addLuggagePreferences == false) ? false : true
                                                                                                                    })
                                                                                                                  : jsonEncode({
                                                                                                                      'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                                      'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                                      'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                      'ride_type': 1,
                                                                                                                      'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                          ? 0
                                                                                                                          : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                              ? 1
                                                                                                                              : 2,
                                                                                                                      'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                                      'request_eta_amount': etaDetails[choosenVehicle]['total'],
                                                                                                                      'is_pet_available': (addPetPreferences == false) ? false : true,
                                                                                                                      'is_luggage_available': (addLuggagePreferences == false) ? false : true
                                                                                                                    }),
                                                                                                              'api/v1/request/create');
                                                                                                        }
                                                                                                      } else {
                                                                                                        if (dropStopList.isNotEmpty) {
                                                                                                          result = await createRequest(
                                                                                                              jsonEncode({
                                                                                                                'pick_lat': addressList[0].latlng.latitude,
                                                                                                                'pick_lng': addressList[0].latlng.longitude,
                                                                                                                'drop_lat': addressList[addressList.length - 1].latlng.latitude,
                                                                                                                'drop_lng': addressList[addressList.length - 1].latlng.longitude,
                                                                                                                'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                'ride_type': 1,
                                                                                                                'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                    ? 0
                                                                                                                    : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                        ? 1
                                                                                                                        : 2,
                                                                                                                'pick_address': addressList[0].address,
                                                                                                                'drop_address': addressList[addressList.length - 1].address,
                                                                                                                'poly_line': polyString,
                                                                                                                'request_eta_amount': etaDetails[choosenVehicle]['total'],
                                                                                                                'pickup_poc_name': addressList[0].name,
                                                                                                                'pickup_poc_mobile': addressList[0].number,
                                                                                                                'pickup_poc_instruction': addressList[0].instructions,
                                                                                                                'drop_poc_name': addressList[addressList.length - 1].name,
                                                                                                                'drop_poc_mobile': addressList[addressList.length - 1].number,
                                                                                                                'drop_poc_instruction': addressList[addressList.length - 1].instructions,
                                                                                                                'goods_type_id': selectedGoodsId.toString(),
                                                                                                                'stops': jsonEncode(dropStopList),
                                                                                                                'goods_type_quantity': goodsSize
                                                                                                              }),
                                                                                                              (userDetails['is_delivery_app'] != null && userDetails['is_delivery_app'] == true) ? 'api/v1/request/create' : 'api/v1/request/delivery/create');
                                                                                                        } else {
                                                                                                          result = await createRequest(
                                                                                                              jsonEncode({
                                                                                                                'pick_lat': addressList[0].latlng.latitude,
                                                                                                                'pick_lng': addressList[0].latlng.longitude,
                                                                                                                'drop_lat': addressList[addressList.length - 1].latlng.latitude,
                                                                                                                'drop_lng': addressList[addressList.length - 1].latlng.longitude,
                                                                                                                'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                'ride_type': 1,
                                                                                                                'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                    ? 0
                                                                                                                    : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                        ? 1
                                                                                                                        : 2,
                                                                                                                'pick_address': addressList[0].address,
                                                                                                                'drop_address': addressList[addressList.length - 1].address,
                                                                                                                'poly_line': polyString,
                                                                                                                'request_eta_amount': etaDetails[choosenVehicle]['total'],
                                                                                                                'pickup_poc_name': addressList[0].name,
                                                                                                                'pickup_poc_mobile': addressList[0].number,
                                                                                                                'pickup_poc_instruction': addressList[0].instructions,
                                                                                                                'drop_poc_name': addressList[addressList.length - 1].name,
                                                                                                                'drop_poc_mobile': addressList[addressList.length - 1].number,
                                                                                                                'drop_poc_instruction': addressList[addressList.length - 1].instructions,
                                                                                                                'goods_type_id': selectedGoodsId.toString(),
                                                                                                                'goods_type_quantity': goodsSize
                                                                                                              }),
                                                                                                              (userDetails['is_delivery_app'] != null && userDetails['is_delivery_app'] == true) ? 'api/v1/request/create' : 'api/v1/request/delivery/create');
                                                                                                        }
                                                                                                      }
                                                                                                    } else {
                                                                                                      if (choosenTransportType == 0) {
                                                                                                        dropStopList.clear();
                                                                                                        if (addressList.length > 2) {
                                                                                                          for (var i = 1; i < addressList.length; i++) {
                                                                                                            dropStopList.add(DropStops(
                                                                                                              order: addressList[i].id,
                                                                                                              latitude: addressList[i].latlng.latitude,
                                                                                                              longitude: addressList[i].latlng.longitude,
                                                                                                              address: addressList[i].address,
                                                                                                            ));
                                                                                                          }

                                                                                                          result = await createRequest(
                                                                                                              jsonEncode({
                                                                                                                'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                                'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                                'drop_lat': addressList.lastWhere((e) => e.type == 'drop').latlng.latitude,
                                                                                                                'drop_lng': addressList.lastWhere((e) => e.type == 'drop').latlng.longitude,
                                                                                                                'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                'ride_type': 1,
                                                                                                                'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                    ? 0
                                                                                                                    : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                        ? 1
                                                                                                                        : 2,
                                                                                                                'stops': jsonEncode(dropStopList),
                                                                                                                'promocode_id': etaDetails[choosenVehicle]['promocode_id'],
                                                                                                                'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                                'drop_address': addressList.lastWhere((e) => e.type == 'drop').address,
                                                                                                                'request_eta_amount': etaDetails[choosenVehicle]['total'],
                                                                                                                'discounted_total': etaDetails[choosenVehicle]['discounted_totel'],
                                                                                                                'poly_line': polyString,
                                                                                                                'is_pet_available': (addPetPreferences == false) ? false : true,
                                                                                                                'is_luggage_available': (addLuggagePreferences == false) ? false : true
                                                                                                              }),
                                                                                                              'api/v1/request/create');
                                                                                                        } else {
                                                                                                          result = await createRequest(
                                                                                                              (addressList.where((element) => element.type == 'drop').isNotEmpty)
                                                                                                                  ? jsonEncode({
                                                                                                                      'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                                      'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                                      'drop_lat': addressList.lastWhere((e) => e.type == 'drop').latlng.latitude,
                                                                                                                      'drop_lng': addressList.lastWhere((e) => e.type == 'drop').latlng.longitude,
                                                                                                                      'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                      'ride_type': 1,
                                                                                                                      'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                          ? 0
                                                                                                                          : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                              ? 1
                                                                                                                              : 2,
                                                                                                                      'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                                      'drop_address': addressList.lastWhere((e) => e.type == 'drop').address,
                                                                                                                      'promocode_id': etaDetails[choosenVehicle]['promocode_id'],
                                                                                                                      'request_eta_amount': etaDetails[choosenVehicle]['total'],
                                                                                                                      'discounted_total': etaDetails[choosenVehicle]['discounted_totel'],
                                                                                                                      'poly_line': polyString,
                                                                                                                      'is_pet_available': (addPetPreferences == false) ? false : true,
                                                                                                                      'is_luggage_available': (addLuggagePreferences == false) ? false : true
                                                                                                                    })
                                                                                                                  : jsonEncode({
                                                                                                                      'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                                      'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                                      'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                      'ride_type': 1,
                                                                                                                      'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                          ? 0
                                                                                                                          : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                              ? 1
                                                                                                                              : 2,
                                                                                                                      'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                                      'promocode_id': etaDetails[choosenVehicle]['promocode_id'],
                                                                                                                      'request_eta_amount': etaDetails[choosenVehicle]['total'],
                                                                                                                      'discounted_total': etaDetails[choosenVehicle]['discounted_totel'],
                                                                                                                      'is_pet_available': (addPetPreferences == false) ? false : true,
                                                                                                                      'is_luggage_available': (addLuggagePreferences == false) ? false : true
                                                                                                                    }),
                                                                                                              'api/v1/request/create');
                                                                                                        }
                                                                                                      } else {
                                                                                                        if (dropStopList.isNotEmpty) {
                                                                                                          result = await createRequest(
                                                                                                              jsonEncode({
                                                                                                                'pick_lat': addressList[0].latlng.latitude,
                                                                                                                'pick_lng': addressList[0].latlng.longitude,
                                                                                                                'drop_lat': addressList[addressList.length - 1].latlng.latitude,
                                                                                                                'drop_lng': addressList[addressList.length - 1].latlng.longitude,
                                                                                                                'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                'ride_type': 1,
                                                                                                                'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                    ? 0
                                                                                                                    : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                        ? 1
                                                                                                                        : 2,
                                                                                                                'pick_address': addressList[0].address,
                                                                                                                'drop_address': addressList[addressList.length - 1].address,
                                                                                                                'promocode_id': etaDetails[choosenVehicle]['promocode_id'],
                                                                                                                'request_eta_amount': etaDetails[choosenVehicle]['total'],
                                                                                                                'pickup_poc_name': addressList[0].name,
                                                                                                                'pickup_poc_mobile': addressList[0].number,
                                                                                                                'pickup_poc_instruction': addressList[0].instructions,
                                                                                                                'drop_poc_name': addressList[addressList.length - 1].name,
                                                                                                                'drop_poc_mobile': addressList[addressList.length - 1].number,
                                                                                                                'drop_poc_instruction': addressList[addressList.length - 1].instructions,
                                                                                                                'goods_type_id': selectedGoodsId.toString(),
                                                                                                                'stops': jsonEncode(dropStopList),
                                                                                                                'goods_type_quantity': goodsSize,
                                                                                                                'discounted_total': etaDetails[choosenVehicle]['discounted_totel'],
                                                                                                                'poly_line': polyString
                                                                                                              }),
                                                                                                              (userDetails['is_delivery_app'] != null && userDetails['is_delivery_app'] == true) ? 'api/v1/request/create' : 'api/v1/request/delivery/create');
                                                                                                        } else {
                                                                                                          result = await createRequest(
                                                                                                              jsonEncode({
                                                                                                                'pick_lat': addressList[0].latlng.latitude,
                                                                                                                'pick_lng': addressList[0].latlng.longitude,
                                                                                                                'drop_lat': addressList[addressList.length - 1].latlng.latitude,
                                                                                                                'drop_lng': addressList[addressList.length - 1].latlng.longitude,
                                                                                                                'vehicle_type': etaDetails[choosenVehicle]['zone_type_id'],
                                                                                                                'ride_type': 1,
                                                                                                                'payment_opt': (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                    ? 0
                                                                                                                    : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                        ? 1
                                                                                                                        : 2,
                                                                                                                'pick_address': addressList[0].address,
                                                                                                                'drop_address': addressList[addressList.length - 1].address,
                                                                                                                'promocode_id': etaDetails[choosenVehicle]['promocode_id'],
                                                                                                                'request_eta_amount': etaDetails[choosenVehicle]['total'],
                                                                                                                'pickup_poc_name': addressList[0].name,
                                                                                                                'pickup_poc_mobile': addressList[0].number,
                                                                                                                'pickup_poc_instruction': addressList[0].instructions,
                                                                                                                'drop_poc_name': addressList[addressList.length - 1].name,
                                                                                                                'drop_poc_mobile': addressList[addressList.length - 1].number,
                                                                                                                'drop_poc_instruction': addressList[addressList.length - 1].instructions,
                                                                                                                'goods_type_id': selectedGoodsId.toString(),
                                                                                                                'goods_type_quantity': goodsSize,
                                                                                                                'discounted_total': etaDetails[choosenVehicle]['discounted_totel'],
                                                                                                                'poly_line': polyString
                                                                                                              }),
                                                                                                              (userDetails['is_delivery_app'] != null && userDetails['is_delivery_app'] == true) ? 'api/v1/request/create' : 'api/v1/request/delivery/create');
                                                                                                        }
                                                                                                      }
                                                                                                    }
                                                                                                  } else {
                                                                                                    if (rentalOption[choosenVehicle]['has_discount'] == false) {
                                                                                                      if (choosenTransportType == 0) {
                                                                                                        result = await createRequest(
                                                                                                            jsonEncode({
                                                                                                              'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                              'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                              'vehicle_type': rentalOption[choosenVehicle]['zone_type_id'],
                                                                                                              'ride_type': 1,
                                                                                                              'payment_opt': (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                  ? 0
                                                                                                                  : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                      ? 1
                                                                                                                      : 2,
                                                                                                              'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                              'request_eta_amount': rentalOption[choosenVehicle]['fare_amount'],
                                                                                                              'rental_pack_id': etaDetails[rentalChoosenOption]['id'],
                                                                                                              'is_pet_available': (addPetPreferences == false) ? false : true,
                                                                                                              'is_luggage_available': (addLuggagePreferences == false) ? false : true
                                                                                                            }),
                                                                                                            'api/v1/request/create');
                                                                                                      } else {
                                                                                                        result = await createRequest(
                                                                                                            jsonEncode({
                                                                                                              'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                              'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                              'vehicle_type': rentalOption[choosenVehicle]['zone_type_id'],
                                                                                                              'ride_type': 1,
                                                                                                              'payment_opt': (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                  ? 0
                                                                                                                  : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                      ? 1
                                                                                                                      : 2,
                                                                                                              'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                              'request_eta_amount': rentalOption[choosenVehicle]['fare_amount'],
                                                                                                              'rental_pack_id': etaDetails[rentalChoosenOption]['id'],
                                                                                                              'pickup_poc_name': addressList[0].name,
                                                                                                              'pickup_poc_mobile': addressList[0].number,
                                                                                                              'pickup_poc_instruction': addressList[0].instructions,
                                                                                                              'goods_type_id': selectedGoodsId.toString(),
                                                                                                              'goods_type_quantity': goodsSize
                                                                                                            }),
                                                                                                            (userDetails['is_delivery_app'] != null && userDetails['is_delivery_app'] == true) ? 'api/v1/request/create' : 'api/v1/request/delivery/create');
                                                                                                      }
                                                                                                    } else {
                                                                                                      if (choosenTransportType == 0) {
                                                                                                        result = await createRequest(
                                                                                                            jsonEncode({
                                                                                                              'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                              'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                              'vehicle_type': rentalOption[choosenVehicle]['zone_type_id'],
                                                                                                              'ride_type': 1,
                                                                                                              'payment_opt': (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                  ? 0
                                                                                                                  : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                      ? 1
                                                                                                                      : 2,
                                                                                                              'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                              'promocode_id': rentalOption[choosenVehicle]['promocode_id'],
                                                                                                              'request_eta_amount': rentalOption[choosenVehicle]['fare_amount'],
                                                                                                              'rental_pack_id': etaDetails[rentalChoosenOption]['id'],
                                                                                                              'discounted_total': rentalOption[choosenVehicle]['discounted_totel'],
                                                                                                              'is_pet_available': (addPetPreferences == false) ? false : true,
                                                                                                              'is_luggage_available': (addLuggagePreferences == false) ? false : true
                                                                                                            }),
                                                                                                            'api/v1/request/create');
                                                                                                      } else {
                                                                                                        result = await createRequest(
                                                                                                            jsonEncode({
                                                                                                              'pick_lat': addressList.firstWhere((e) => e.type == 'pickup').latlng.latitude,
                                                                                                              'pick_lng': addressList.firstWhere((e) => e.type == 'pickup').latlng.longitude,
                                                                                                              'vehicle_type': rentalOption[choosenVehicle]['zone_type_id'],
                                                                                                              'ride_type': 1,
                                                                                                              'payment_opt': (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'card')
                                                                                                                  ? 0
                                                                                                                  : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[payingVia] == 'cash')
                                                                                                                      ? 1
                                                                                                                      : 2,
                                                                                                              'pick_address': addressList.firstWhere((e) => e.type == 'pickup').address,
                                                                                                              'promocode_id': rentalOption[choosenVehicle]['promocode_id'],
                                                                                                              'request_eta_amount': rentalOption[choosenVehicle]['fare_amount'],
                                                                                                              'rental_pack_id': etaDetails[rentalChoosenOption]['id'],
                                                                                                              'goods_type_id': selectedGoodsId.toString(),
                                                                                                              'goods_type_quantity': goodsSize,
                                                                                                              'pickup_poc_name': addressList[0].name,
                                                                                                              'pickup_poc_mobile': addressList[0].number,
                                                                                                              'pickup_poc_instruction': addressList[0].instructions,
                                                                                                              'discounted_total': rentalOption[choosenVehicle]['discounted_totel']
                                                                                                            }),
                                                                                                            (userDetails['is_delivery_app'] != null && userDetails['is_delivery_app'] == true) ? 'api/v1/request/create' : 'api/v1/request/delivery/create');
                                                                                                      }
                                                                                                    }
                                                                                                  }
                                                                                                }
                                                                                                if (result == 'logout') {
                                                                                                  navigateLogout();
                                                                                                } else if (result == 'success') {
                                                                                                  timer();
                                                                                                }
                                                                                                setState(() {
                                                                                                  isLoading = false;
                                                                                                });
                                                                                              }
                                                                                            }
                                                                                          } else {
                                                                                            setState(() {
                                                                                              islowwalletbalance = true;
                                                                                            });
                                                                                          }
                                                                                        },
                                                                                        text: (confirmRideLater == true || isOutStation) ? languages[choosenLanguage]['text_schedule'] : languages[choosenLanguage]['text_book_now']),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            : Container(),
                                              ))
                                          : Container()
                                      : Container(),

                                  //no driver found
                                  (noDriverFound == true)
                                      ? Positioned(
                                          bottom: 0,
                                          child: Container(
                                            width: media.width * 1,
                                            padding: EdgeInsets.all(
                                                media.width * 0.05),
                                            decoration: BoxDecoration(
                                                color: page,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(12),
                                                        topRight:
                                                            Radius.circular(
                                                                12))),
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: media.width * 0.18,
                                                  width: media.width * 0.18,
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Color(
                                                              0xffFEF2F2)),
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    height: media.width * 0.14,
                                                    width: media.width * 0.14,
                                                    decoration:
                                                        const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Color(
                                                                0xffFF0000)),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.error,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                Text(
                                                  languages[choosenLanguage]
                                                      ['text_nodriver'],
                                                  style: GoogleFonts.notoSans(
                                                      fontSize: media.width *
                                                          eighteen,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: textColor),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                Button(
                                                    onTap: () {
                                                      setState(() {
                                                        noDriverFound = false;
                                                      });
                                                    },
                                                    text: languages[
                                                            choosenLanguage]
                                                        ['text_tryagain'])
                                              ],
                                            ),
                                          ))
                                      : Container(),

                                  //internal server error
                                  (tripReqError == true)
                                      ? Positioned(
                                          bottom: 0,
                                          child: Container(
                                            width: media.width * 1,
                                            padding: EdgeInsets.all(
                                                media.width * 0.05),
                                            decoration: BoxDecoration(
                                                color: page,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(12),
                                                        topRight:
                                                            Radius.circular(
                                                                12))),
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: media.width * 0.18,
                                                  width: media.width * 0.18,
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Color(
                                                              0xffFEF2F2)),
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    height: media.width * 0.14,
                                                    width: media.width * 0.14,
                                                    decoration:
                                                        const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Color(
                                                                0xffFF0000)),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.error,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                SizedBox(
                                                  width: media.width * 0.8,
                                                  child: Text(tripError,
                                                      style: GoogleFonts
                                                          .notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      eighteen,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: textColor),
                                                      textAlign:
                                                          TextAlign.center),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                Button(
                                                    onTap: () {
                                                      setState(() {
                                                        tripReqError = false;
                                                      });
                                                    },
                                                    text: languages[
                                                            choosenLanguage]
                                                        ['text_tryagain'])
                                              ],
                                            ),
                                          ))
                                      : Container(),

                                  //service not available

                                  (serviceNotAvailable)
                                      ? Positioned(
                                          bottom: 0,
                                          child: Container(
                                            width: media.width * 1,
                                            padding: EdgeInsets.all(
                                                media.width * 0.05),
                                            decoration: BoxDecoration(
                                                color: page,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(12),
                                                        topRight:
                                                            Radius.circular(
                                                                12))),
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: media.width * 0.18,
                                                  width: media.width * 0.18,
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Color(
                                                              0xffFEF2F2)),
                                                  alignment: Alignment.center,
                                                  child: Container(
                                                    height: media.width * 0.14,
                                                    width: media.width * 0.14,
                                                    decoration:
                                                        const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Color(
                                                                0xffFF0000)),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.error,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                SizedBox(
                                                  width: media.width * 0.8,
                                                  child: Text(
                                                      languages[choosenLanguage]
                                                          ['text_no_service'],
                                                      style: GoogleFonts
                                                          .notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      eighteen,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: textColor),
                                                      textAlign:
                                                          TextAlign.center),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                Button(
                                                    onTap: () async {
                                                      setState(() {
                                                        serviceNotAvailable =
                                                            false;
                                                      });
                                                      if (widget.type != 1) {
                                                        var val =
                                                            await etaRequest();
                                                        if (val == 'logout') {
                                                          navigateLogout();
                                                        }
                                                      } else {
                                                        var val =
                                                            await rentalEta();
                                                        if (val == 'logout') {
                                                          navigateLogout();
                                                        }
                                                      }
                                                      setState(() {});
                                                    },
                                                    text: languages[
                                                            choosenLanguage]
                                                        ['text_tryagain'])
                                              ],
                                            ),
                                          ))
                                      : Container(),

                                  //islowwallet balance popup
                                  (islowwalletbalance == true)
                                      ? Positioned(
                                          bottom: 0,
                                          child: Container(
                                            width: media.width * 1,
                                            height: media.height * 1,
                                            color:
                                                Colors.black.withOpacity(0.4),
                                            padding: EdgeInsets.all(
                                                media.width * 0.05),
                                            alignment: Alignment.center,
                                            child: Container(
                                              width: media.width * 0.9,
                                              height: media.width * 0.4,
                                              padding: EdgeInsets.all(
                                                  media.width * 0.05),
                                              decoration: BoxDecoration(
                                                  color: page,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          media.width * 0.04)),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                      languages[
                                                              choosenLanguage]
                                                          [
                                                          'text_wallet_balance_low'],
                                                      style: GoogleFonts
                                                          .notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      sixteen,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: textColor),
                                                      textAlign:
                                                          TextAlign.center),
                                                  Button(
                                                      width: media.width * 0.4,
                                                      height: media.width * 0.1,
                                                      onTap: () {
                                                        setState(() {
                                                          islowwalletbalance =
                                                              false;
                                                        });
                                                      },
                                                      text: languages[
                                                              choosenLanguage]
                                                          ['text_ok'])
                                                ],
                                              ),
                                            ),
                                          ))
                                      : Container(),
                                  //choose payment method
                                  (_choosePayment == true)
                                      ? Positioned(
                                          top: 0,
                                          child: Container(
                                            height: media.height * 1,
                                            width: media.width * 1,
                                            color: Colors.transparent
                                                .withOpacity(0.6),
                                            child: Scaffold(
                                              backgroundColor:
                                                  Colors.transparent,
                                              body: SingleChildScrollView(
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                child: SizedBox(
                                                  height: media.height * 1,
                                                  width: media.width * 1,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.9,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  _choosePayment =
                                                                      false;
                                                                  promoKey
                                                                      .clear();
                                                                });
                                                              },
                                                              child: Container(
                                                                height: media
                                                                        .width *
                                                                    0.1,
                                                                width: media
                                                                        .width *
                                                                    0.1,
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color:
                                                                        page),
                                                                child: const Icon(
                                                                    Icons
                                                                        .cancel_outlined),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            media.width * 0.05,
                                                      ),
                                                      Container(
                                                        width:
                                                            media.width * 0.9,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: page,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(12),
                                                        ),
                                                        padding: EdgeInsets.all(
                                                            media.width * 0.05),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_paymentmethod'],
                                                              style: GoogleFonts.notoSans(
                                                                  fontSize: media
                                                                          .width *
                                                                      twenty,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      textColor),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  media.height *
                                                                      0.015,
                                                            ),
                                                            Text(
                                                              languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_choose_paynoworlater'],
                                                              style: GoogleFonts.notoSans(
                                                                  fontSize: media
                                                                          .width *
                                                                      twelve,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color:
                                                                      textColor),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  media.height *
                                                                      0.015,
                                                            ),
                                                            (widget.type != 1)
                                                                ? Column(
                                                                    children: etaDetails[choosenVehicle]
                                                                            [
                                                                            'payment_type']
                                                                        .toString()
                                                                        .split(
                                                                            ',')
                                                                        .toList()
                                                                        .asMap()
                                                                        .map((i,
                                                                            value) {
                                                                          return MapEntry(
                                                                              i,
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    payingVia = i;
                                                                                  });
                                                                                },
                                                                                child: Container(
                                                                                  padding: EdgeInsets.all(media.width * 0.02),
                                                                                  width: media.width * 0.9,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Row(
                                                                                        children: [
                                                                                          SizedBox(
                                                                                            width: media.width * 0.06,
                                                                                            child: (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[i] == 'cash')
                                                                                                ? Image.asset(
                                                                                                    'assets/images/cash.png',
                                                                                                    fit: BoxFit.contain,
                                                                                                  )
                                                                                                : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[i] == 'wallet')
                                                                                                    ? Image.asset(
                                                                                                        'assets/images/wallet.png',
                                                                                                        fit: BoxFit.contain,
                                                                                                      )
                                                                                                    : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[i] == 'card')
                                                                                                        ? Image.asset(
                                                                                                            'assets/images/card.png',
                                                                                                            fit: BoxFit.contain,
                                                                                                          )
                                                                                                        : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[i] == 'upi')
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
                                                                                                etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[i].toString(),
                                                                                                style: GoogleFonts.notoSans(fontSize: media.width * fourteen, fontWeight: FontWeight.w600),
                                                                                              ),
                                                                                              Text(
                                                                                                (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[i] == 'cash')
                                                                                                    ? languages[choosenLanguage]['text_paycash']
                                                                                                    : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[i] == 'wallet')
                                                                                                        ? languages[choosenLanguage]['text_paywallet']
                                                                                                        : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[i] == 'card')
                                                                                                            ? languages[choosenLanguage]['text_paycard']
                                                                                                            : (etaDetails[choosenVehicle]['payment_type'].toString().split(',').toList()[i] == 'upi')
                                                                                                                ? languages[choosenLanguage]['text_payupi']
                                                                                                                : '',
                                                                                                style: GoogleFonts.notoSans(
                                                                                                  fontSize: media.width * ten,
                                                                                                ),
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
                                                                                                decoration: BoxDecoration(shape: BoxShape.circle, color: page, border: Border.all(color: Colors.black, width: 1.2)),
                                                                                                alignment: Alignment.center,
                                                                                                child: (payingVia == i) ? Container(height: media.width * 0.03, width: media.width * 0.03, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)) : Container(),
                                                                                              )
                                                                                            ],
                                                                                          ))
                                                                                        ],
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ));
                                                                        })
                                                                        .values
                                                                        .toList(),
                                                                  )
                                                                : Column(
                                                                    children: rentalOption[choosenVehicle]
                                                                            [
                                                                            'payment_type']
                                                                        .toString()
                                                                        .split(
                                                                            ',')
                                                                        .toList()
                                                                        .asMap()
                                                                        .map((i,
                                                                            value) {
                                                                          return MapEntry(
                                                                              i,
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    payingVia = i;
                                                                                  });
                                                                                },
                                                                                child: Container(
                                                                                  padding: EdgeInsets.all(media.width * 0.02),
                                                                                  width: media.width * 0.9,
                                                                                  child: Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Row(
                                                                                        children: [
                                                                                          SizedBox(
                                                                                            width: media.width * 0.06,
                                                                                            child: (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[i] == 'cash')
                                                                                                ? Image.asset(
                                                                                                    'assets/images/cash.png',
                                                                                                    fit: BoxFit.contain,
                                                                                                  )
                                                                                                : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[i] == 'wallet')
                                                                                                    ? Image.asset(
                                                                                                        'assets/images/wallet.png',
                                                                                                        fit: BoxFit.contain,
                                                                                                      )
                                                                                                    : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[i] == 'card')
                                                                                                        ? Image.asset(
                                                                                                            'assets/images/card.png',
                                                                                                            fit: BoxFit.contain,
                                                                                                          )
                                                                                                        : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[i] == 'upi')
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
                                                                                                rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[i].toString(),
                                                                                                style: GoogleFonts.notoSans(fontSize: media.width * fourteen, fontWeight: FontWeight.w600),
                                                                                              ),
                                                                                              Text(
                                                                                                (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[i] == 'cash')
                                                                                                    ? languages[choosenLanguage]['text_paycash']
                                                                                                    : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[i] == 'wallet')
                                                                                                        ? languages[choosenLanguage]['text_paywallet']
                                                                                                        : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[i] == 'card')
                                                                                                            ? languages[choosenLanguage]['text_paycard']
                                                                                                            : (rentalOption[choosenVehicle]['payment_type'].toString().split(',').toList()[i] == 'upi')
                                                                                                                ? languages[choosenLanguage]['text_payupi']
                                                                                                                : '',
                                                                                                style: GoogleFonts.notoSans(
                                                                                                  fontSize: media.width * ten,
                                                                                                ),
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
                                                                                                decoration: BoxDecoration(shape: BoxShape.circle, color: page, border: Border.all(color: Colors.black, width: 1.2)),
                                                                                                alignment: Alignment.center,
                                                                                                child: (payingVia == i) ? Container(height: media.width * 0.03, width: media.width * 0.03, decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle)) : Container(),
                                                                                              )
                                                                                            ],
                                                                                          ))
                                                                                        ],
                                                                                      )
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ));
                                                                        })
                                                                        .values
                                                                        .toList(),
                                                                  ),
                                                            SizedBox(
                                                              height:
                                                                  media.height *
                                                                      0.02,
                                                            ),
                                                            Container(
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
                                                              padding: EdgeInsets
                                                                  .fromLTRB(
                                                                      media.width *
                                                                          0.025,
                                                                      0,
                                                                      media.width *
                                                                          0.025,
                                                                      0),
                                                              width:
                                                                  media.width *
                                                                      0.9,
                                                              child: Row(
                                                                children: [
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.06,
                                                                    child: Image.asset(
                                                                        'assets/images/promocode.png',
                                                                        fit: BoxFit
                                                                            .contain),
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.05,
                                                                  ),
                                                                  Expanded(
                                                                    child: (promoStatus ==
                                                                            null)
                                                                        ? TextField(
                                                                            controller:
                                                                                promoKey,
                                                                            onChanged:
                                                                                (val) {
                                                                              setState(() {
                                                                                promoCode = val;
                                                                              });
                                                                            },
                                                                            decoration: InputDecoration(
                                                                                border: InputBorder.none,
                                                                                hintText: languages[choosenLanguage]['text_enterpromo'],
                                                                                hintStyle: GoogleFonts.notoSans(fontSize: media.width * twelve, color: hintColor)),
                                                                          )
                                                                        : (promoStatus ==
                                                                                1)
                                                                            ? Container(
                                                                                padding: EdgeInsets.fromLTRB(0, media.width * 0.045, 0, media.width * 0.045),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: [
                                                                                    Column(
                                                                                      children: [
                                                                                        Text(promoKey.text, style: GoogleFonts.notoSans(fontSize: media.width * ten, color: const Color(0xff319900))),
                                                                                        Text(languages[choosenLanguage]['text_promoaccepted'], style: GoogleFonts.notoSans(fontSize: media.width * ten, color: const Color(0xff319900))),
                                                                                      ],
                                                                                    ),
                                                                                    InkWell(
                                                                                      onTap: () async {
                                                                                        setState(() {
                                                                                          isLoading = true;
                                                                                        });
                                                                                        dynamic result;
                                                                                        if (widget.type != 1) {
                                                                                          result = await etaRequest();
                                                                                        } else {
                                                                                          result = await rentalEta();
                                                                                        }
                                                                                        setState(() {
                                                                                          isLoading = false;
                                                                                          if (result == true) {
                                                                                            promoStatus = null;
                                                                                            promoCode = '';
                                                                                          } else if (result == 'logout') {
                                                                                            navigateLogout();
                                                                                          }
                                                                                        });
                                                                                      },
                                                                                      child: Text(languages[choosenLanguage]['text_remove'], style: GoogleFonts.notoSans(fontSize: media.width * twelve, color: const Color(0xff319900))),
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              )
                                                                            : (promoStatus == 2)
                                                                                ? Container(
                                                                                    padding: EdgeInsets.fromLTRB(0, media.width * 0.045, 0, media.width * 0.045),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: [
                                                                                        Text(promoKey.text, style: GoogleFonts.notoSans(fontSize: media.width * twelve, color: const Color(0xffFF0000))),
                                                                                        InkWell(
                                                                                          onTap: () async {
                                                                                            setState(() {
                                                                                              promoStatus = null;
                                                                                              promoCode = '';
                                                                                              promoKey.clear();
                                                                                            });
                                                                                            dynamic val;
                                                                                            // promoKey.text = promoCode;
                                                                                            if (widget.type != 1) {
                                                                                              val = await etaRequest();
                                                                                            } else {
                                                                                              val = await rentalEta();
                                                                                            }
                                                                                            if (val == 'logout') {
                                                                                              navigateLogout();
                                                                                            }
                                                                                            setState(() {});
                                                                                          },
                                                                                          child: Text(languages[choosenLanguage]['text_remove'], style: GoogleFonts.notoSans(fontSize: media.width * twelve, color: const Color(0xffFF0000))),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                : Container(),
                                                                  )
                                                                ],
                                                              ),
                                                            ),

                                                            //promo code status
                                                            (promoStatus == 2)
                                                                ? Container(
                                                                    width: media
                                                                            .width *
                                                                        0.9,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    padding: EdgeInsets.only(
                                                                        top: media.height *
                                                                            0.02),
                                                                    child: Text(
                                                                        languages[choosenLanguage]
                                                                            [
                                                                            'text_promorejected'],
                                                                        style: GoogleFonts.notoSans(
                                                                            fontSize: media.width *
                                                                                ten,
                                                                            color:
                                                                                const Color(0xffFF0000))),
                                                                  )
                                                                : Container(),
                                                            SizedBox(
                                                              height:
                                                                  media.height *
                                                                      0.02,
                                                            ),
                                                            Button(
                                                                onTap:
                                                                    () async {
                                                                  if (promoCode ==
                                                                      '') {
                                                                    setState(
                                                                        () {
                                                                      _choosePayment =
                                                                          false;
                                                                    });
                                                                  } else {
                                                                    setState(
                                                                        () {
                                                                      isLoading =
                                                                          true;
                                                                    });
                                                                    dynamic val;
                                                                    if (widget
                                                                            .type !=
                                                                        1) {
                                                                      val =
                                                                          await etaRequestWithPromo();
                                                                    } else {
                                                                      val =
                                                                          await rentalRequestWithPromo();
                                                                    }
                                                                    if (val ==
                                                                        'logout') {
                                                                      navigateLogout();
                                                                    }
                                                                    setState(
                                                                        () {
                                                                      isLoading =
                                                                          false;
                                                                    });
                                                                  }
                                                                },
                                                                text: languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_confirm'])
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ))
                                      : Container(),

                                  (userRequestData.isNotEmpty &&
                                              userRequestData['is_later'] ==
                                                  null &&
                                              userRequestData['accepted_at'] ==
                                                  null ||
                                          userRequestData.isNotEmpty &&
                                              userRequestData['is_later'] ==
                                                  0 &&
                                              userRequestData['accepted_at'] ==
                                                  null)
                                      ? userRequestData.isNotEmpty &&
                                              userRequestData['is_bid_ride'] ==
                                                  1
                                          ? Positioned(
                                              bottom: 0,
                                              child: StreamBuilder<Object>(
                                                  stream: FirebaseDatabase
                                                      .instance
                                                      .ref()
                                                      .child(
                                                          'bid-meta/${userRequestData["id"]}')
                                                      .onValue
                                                      .asBroadcastStream(),
                                                  builder: (context,
                                                      AsyncSnapshot event) {
                                                    List driverList = [];
                                                    Map rideList = {};

                                                    // rideList = event.data!.snapshot;
                                                    if (event.data != null) {
                                                      DataSnapshot snapshots =
                                                          event.data!.snapshot;
                                                      if (snapshots.value !=
                                                          null) {
                                                        rideList = jsonDecode(
                                                            jsonEncode(snapshots
                                                                .value));
                                                        if (updateAmount
                                                            .text.isEmpty) {
                                                          updateAmount.text =
                                                              rideList['price']
                                                                  .toString();
                                                        }
                                                        if (rideList[
                                                                'drivers'] !=
                                                            null) {
                                                          Map driver = rideList[
                                                              'drivers'];
                                                          driver.forEach(
                                                              (key, value) {
                                                            if (driver[key][
                                                                    'is_rejected'] ==
                                                                'none') {
                                                              driverList
                                                                  .add(value);

                                                              if (driverList
                                                                  .isNotEmpty) {
                                                                audioPlayers.play(
                                                                    AssetSource(
                                                                        audio));
                                                              }
                                                            }
                                                          });

                                                          if (driverList
                                                              .isNotEmpty) {
                                                            if (driverBck
                                                                    .isNotEmpty &&
                                                                driverList[0][
                                                                        'user_id'] !=
                                                                    driverBck[0]
                                                                        [
                                                                        'user_id']) {
                                                              driverBck =
                                                                  driverList;
                                                            } else if (driverBck
                                                                .isEmpty) {
                                                              driverBck =
                                                                  driverList;
                                                            }
                                                          } else {
                                                            driverBck =
                                                                driverList;
                                                          }
                                                        } else {
                                                          driverBck =
                                                              driverList;
                                                        }
                                                      }
                                                    }

                                                    return Container(
                                                      width: media.width * 1,
                                                      height: media.height * 1,
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: Container(
                                                        width: media.width * 1,
                                                        height: (driverList
                                                                .isNotEmpty)
                                                            ? media.height * 1
                                                            : media.width *
                                                                0.72,
                                                        // height:(driverList.isNotEmpty) ? media.height*1 : media.width*1,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          12),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          12)),
                                                          color: page,
                                                        ),
                                                        padding: (driverList
                                                                .isNotEmpty)
                                                            ? EdgeInsets.fromLTRB(
                                                                0,
                                                                media.width *
                                                                        0.1 +
                                                                    MediaQuery.of(
                                                                            context)
                                                                        .padding
                                                                        .top,
                                                                0,
                                                                0)
                                                            : EdgeInsets
                                                                .fromLTRB(
                                                                    0,
                                                                    media.width *
                                                                        0.05,
                                                                    0,
                                                                    media.width *
                                                                        0.05),
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              width:
                                                                  media.width *
                                                                      0.9,
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  setState(() {
                                                                    _cancel =
                                                                        true;
                                                                  });
                                                                },
                                                                child: Text(
                                                                  languages[
                                                                          choosenLanguage]
                                                                      [
                                                                      'text_cancel'],
                                                                  style: GoogleFonts.notoSans(
                                                                      fontSize:
                                                                          media.width *
                                                                              sixteen,
                                                                      color: Colors
                                                                          .red),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height:
                                                                  media.width *
                                                                      0.02,
                                                            ),
                                                            Text(
                                                              languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_findingdriver'],
                                                              style: GoogleFonts.notoSans(
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  color:
                                                                      textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                            (driverList
                                                                    .isNotEmpty)
                                                                ? Expanded(
                                                                    child:
                                                                        Container(
                                                                      width:
                                                                          media.width *
                                                                              1,
                                                                      padding: EdgeInsets.fromLTRB(
                                                                          media.width *
                                                                              0.05,
                                                                          media.width * 0.05 +
                                                                              MediaQuery.of(context)
                                                                                  .padding
                                                                                  .top,
                                                                          media.width *
                                                                              0.05,
                                                                          media.width *
                                                                              0.05),
                                                                      // color: Colors.transparent.withOpacity(0.4),
                                                                      child:
                                                                          SingleChildScrollView(
                                                                        child: Column(
                                                                            children: driverList
                                                                                .asMap()
                                                                                .map((key, value) {
                                                                                  return MapEntry(
                                                                                      key,
                                                                                      ValueListenableBuilder(
                                                                                          valueListenable: valueNotifierTimer.value,
                                                                                          builder: (context, value, child) {
                                                                                            var val = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(driverList[key]['bid_time'])).inSeconds;
                                                                                            var calcDistance = calculateDistance(userRequestData['pick_lat'], userRequestData['pick_lng'], double.parse(driverList[key]['lat'].toString()), double.parse(driverList[key]['lng'].toString()));
                                                                                            if (int.parse(val.toString()) >= int.parse(userDetails['maximum_time_for_find_drivers_for_bitting_ride'].toString()) + 5) {
                                                                                              FirebaseDatabase.instance.ref().child('bid-meta/${userRequestData["id"]}/drivers/driver_${driverList[key]["driver_id"]}').update({
                                                                                                "is_rejected": 'by_user'
                                                                                              });
                                                                                            }
                                                                                            return Container(
                                                                                              margin: EdgeInsets.only(bottom: media.width * 0.025),
                                                                                              decoration:
                                                                                                  BoxDecoration(
                                                                                                      // borderRadius: BorderRadius.circular(10),
                                                                                                      color: page,
                                                                                                      boxShadow: [
                                                                                                    BoxShadow(blurRadius: 2, spreadRadius: 2, color: Colors.black.withOpacity(0.2))
                                                                                                  ]),
                                                                                              child: Column(
                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                children: [
                                                                                                  Container(
                                                                                                    height: 5,
                                                                                                    width: (val < int.parse(userDetails['maximum_time_for_find_drivers_for_bitting_ride'].toString())) ? (media.width * 0.85 / int.parse(userDetails['maximum_time_for_find_drivers_for_bitting_ride'].toString())) * (int.parse(userDetails['maximum_time_for_find_drivers_for_bitting_ride'].toString()) - double.parse(val.toString())) : 0,
                                                                                                    color: buttonColor,
                                                                                                  ),
                                                                                                  Container(
                                                                                                    padding: EdgeInsets.all(media.width * 0.05),
                                                                                                    child: Column(
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
                                                                                                            Expanded(
                                                                                                              child: Column(
                                                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                children: [
                                                                                                                  Text(
                                                                                                                    driverList[key]['driver_name'],
                                                                                                                    style: GoogleFonts.notoSans(fontSize: media.width * fourteen, color: textColor, fontWeight: FontWeight.w600),
                                                                                                                    textAlign: TextAlign.left,
                                                                                                                    maxLines: 1,
                                                                                                                  ),
                                                                                                                  SizedBox(
                                                                                                                    height: media.width * 0.025,
                                                                                                                  ),
                                                                                                                  Text(
                                                                                                                    '${driverList[key]['vehicle_make']} ${driverList[key]['vehicle_model']}',
                                                                                                                    style: GoogleFonts.notoSans(fontSize: media.width * fourteen, color: textColor, fontWeight: FontWeight.w600),
                                                                                                                    textAlign: TextAlign.left,
                                                                                                                    maxLines: 1,
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                            SizedBox(
                                                                                                              width: media.width * 0.01,
                                                                                                            ),
                                                                                                            Expanded(
                                                                                                              child: Column(
                                                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                                                                                children: [
                                                                                                                  Text(
                                                                                                                    rideList['currency'] + driverList[key]['price'],
                                                                                                                    style: GoogleFonts.notoSans(fontSize: media.width * twelve, color: textColor, fontWeight: FontWeight.w600),
                                                                                                                    textAlign: TextAlign.center,
                                                                                                                    maxLines: 1,
                                                                                                                  ),
                                                                                                                  SizedBox(
                                                                                                                    height: media.width * 0.025,
                                                                                                                  ),
                                                                                                                  Text(
                                                                                                                    (calcDistance != null) ? '${double.parse((calcDistance / 1000).toString()).toStringAsFixed(0)} km' : '',
                                                                                                                    style: GoogleFonts.notoSans(fontSize: media.width * fourteen, color: textColor, fontWeight: FontWeight.w600),
                                                                                                                    textAlign: TextAlign.center,
                                                                                                                    maxLines: 1,
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            )
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
                                                                                                                  isLoading = true;
                                                                                                                });
                                                                                                                var val = await acceptRequest(jsonEncode({
                                                                                                                  'driver_id': driverList[key]['driver_id'],
                                                                                                                  'request_id': userRequestData['id'],
                                                                                                                  'accepted_ride_fare': driverList[key]['price'].toString(),
                                                                                                                  'offerred_ride_fare': rideList['price'],
                                                                                                                }));
                                                                                                                if (val == 'success') {
                                                                                                                  await FirebaseDatabase.instance.ref().child('bid-meta/${userRequestData["id"]}').remove();
                                                                                                                }
                                                                                                                setState(() {
                                                                                                                  isLoading = false;
                                                                                                                });
                                                                                                              },
                                                                                                              text: languages[choosenLanguage]['text_accept'],
                                                                                                              width: media.width * 0.35,
                                                                                                              color: online,
                                                                                                              borcolor: online,
                                                                                                              textcolor: page,
                                                                                                            ),
                                                                                                            // SizedBox(height: media.width*0.025,),
                                                                                                            Button(
                                                                                                              onTap: () async {
                                                                                                                setState(() {
                                                                                                                  isLoading = true;
                                                                                                                });
                                                                                                                await FirebaseDatabase.instance.ref().child('bid-meta/${userRequestData["id"]}/drivers/driver_${driverList[key]["driver_id"]}').update({"is_rejected": 'by_user'});
                                                                                                                setState(() {
                                                                                                                  isLoading = false;
                                                                                                                });
                                                                                                              },
                                                                                                              text: languages[choosenLanguage]['text_decline'],
                                                                                                              width: media.width * 0.35,
                                                                                                              color: verifyDeclined,
                                                                                                              borcolor: verifyDeclined,
                                                                                                              textcolor: page,
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
                                                                      ),
                                                                    ),
                                                                  )
                                                                : Container(),
                                                            if (driverList
                                                                .isEmpty)
                                                              Column(
                                                                children: [
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.01,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.9,
                                                                    child: Text(
                                                                      '${languages[choosenLanguage]['text_offered_fare']} : ${rideList['currency']} ${rideList['price']}',
                                                                      style: GoogleFonts.notoSans(
                                                                          fontSize: media.width *
                                                                              sixteen,
                                                                          color:
                                                                              textColor,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.01,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.9,
                                                                    child: Text(
                                                                      languages[
                                                                              choosenLanguage]
                                                                          [
                                                                          'text_current_fare'],
                                                                      style: GoogleFonts.notoSans(
                                                                          fontSize: media.width *
                                                                              eighteen,
                                                                          color:
                                                                              textColor,
                                                                          fontWeight:
                                                                              FontWeight.w600),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    width: media
                                                                            .width *
                                                                        0.9,
                                                                    padding: EdgeInsets.only(
                                                                        top: media.width *
                                                                            0.02),
                                                                    child: (updateAmount.text.isNotEmpty &&
                                                                            updateAmount.text !=
                                                                                'null')
                                                                        ? Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceEvenly,
                                                                            children: [
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  if (updateAmount.text.isNotEmpty &&
                                                                                      (userRequestData['bidding_low_percentage'] == 0 ||
                                                                                          (double.parse(updateAmount.text.toString()) -
                                                                                                  // 10
                                                                                                  ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))) >=
                                                                                              (double.parse(userRequestData['request_eta_amount'].toString()) - ((double.parse(userRequestData['bidding_low_percentage'].toString()) / 100) * double.parse(userRequestData['request_eta_amount'].toString()))))) {
                                                                                    setState(() {
                                                                                      updateAmount.text = (updateAmount.text.isEmpty)
                                                                                          ? (rideList['price'].toString().contains('.'))
                                                                                              ? (double.parse(rideList['price'].toString()) -
                                                                                                      // 10
                                                                                                      ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString())))
                                                                                                  .toStringAsFixed(2)
                                                                                              : (int.parse(rideList['price'].toString()) -
                                                                                                      // 10
                                                                                                      ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString())))
                                                                                                  .toString()
                                                                                          : (updateAmount.text.toString().contains('.'))
                                                                                              ? (double.parse(updateAmount.text.toString()) -
                                                                                                      // 10
                                                                                                      ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString())))
                                                                                                  .toStringAsFixed(2)
                                                                                              : (int.parse(updateAmount.text.toString()) -
                                                                                                      // 10
                                                                                                      ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString())))
                                                                                                  .toString();
                                                                                      // updateAmount.text = (updateAmount.text.isEmpty) ? (double.parse(rideList['price'].toString()) - 10).toStringAsFixed(2) : (double.parse(updateAmount.text.toString()) - 10).toStringAsFixed(2);
                                                                                    });
                                                                                  }
                                                                                },
                                                                                child: Container(
                                                                                  width: media.width * 0.2,
                                                                                  alignment: Alignment.center,
                                                                                  decoration: BoxDecoration(
                                                                                      color: (updateAmount.text.isNotEmpty &&
                                                                                              (userRequestData['bidding_low_percentage'] == 0 ||
                                                                                                  (double.parse(updateAmount.text.toString()) -
                                                                                                          // 10
                                                                                                          ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))) >=
                                                                                                      (double.parse(userRequestData['request_eta_amount'].toString()) - ((double.parse(userRequestData['bidding_low_percentage'].toString()) / 100) * double.parse(userRequestData['request_eta_amount'].toString())))))
                                                                                          // double.parse(updateAmount.text.toString()) > double.parse(rideList['price'].toString()))
                                                                                          ? (isDarkTheme)
                                                                                              ? Colors.white
                                                                                              : Colors.black
                                                                                          : borderLines,
                                                                                      borderRadius: BorderRadius.circular(media.width * 0.04)),
                                                                                  padding: EdgeInsets.all(media.width * 0.025),
                                                                                  child: Text(
                                                                                    // '-10',
                                                                                    (userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? '-${double.parse(userDetails['bidding_amount_increase_or_decrease'].toString())}' : '-${int.parse(userDetails['bidding_amount_increase_or_decrease'].toString())}',
                                                                                    style: GoogleFonts.notoSans(fontSize: media.width * fourteen, fontWeight: FontWeight.w600, color: (isDarkTheme) ? Colors.black : Colors.white),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              SizedBox(
                                                                                width: media.width * 0.4,
                                                                                child: TextField(
                                                                                  enabled: false,
                                                                                  textAlign: TextAlign.center,
                                                                                  keyboardType: TextInputType.number,
                                                                                  controller: updateAmount,
                                                                                  decoration: InputDecoration(
                                                                                    hintText: (rideList.isNotEmpty) ? rideList['price'].toString() : '',
                                                                                    hintStyle: GoogleFonts.notoSans(fontSize: media.width * sixteen, color: textColor),
                                                                                    border: UnderlineInputBorder(borderSide: BorderSide(color: hintColor)),
                                                                                  ),
                                                                                  style: GoogleFonts.notoSans(
                                                                                    color: textColor,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              InkWell(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    if (userRequestData['bidding_high_percentage'] == 0 ||
                                                                                        (double.parse(updateAmount.text.toString()) +
                                                                                                // 10
                                                                                                ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))) <=
                                                                                            (double.parse(userRequestData['request_eta_amount'].toString()) + ((double.parse(userRequestData['bidding_high_percentage'].toString()) / 100) * double.parse(userRequestData['request_eta_amount'].toString())))) {
                                                                                      updateAmount.text = (updateAmount.text.isEmpty)
                                                                                          ? (rideList['price'].toString().contains('.'))
                                                                                              ? (double.parse(rideList['price'].toString()) +
                                                                                                      // 10
                                                                                                      ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString())))
                                                                                                  .toStringAsFixed(2)
                                                                                              : (int.parse(rideList['price'].toString()) +
                                                                                                      // 10
                                                                                                      ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString())))
                                                                                                  .toString()
                                                                                          : (updateAmount.text.toString().contains('.'))
                                                                                              ? (double.parse(updateAmount.text.toString()) + ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))).toStringAsFixed(2)
                                                                                              : (int.parse(updateAmount.text.toString()) + ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))).toString();
                                                                                    }
                                                                                  });
                                                                                },
                                                                                child: Container(
                                                                                  width: media.width * 0.2,
                                                                                  alignment: Alignment.center,
                                                                                  decoration: BoxDecoration(
                                                                                      color: (userRequestData['bidding_high_percentage'] == 0 || (double.parse(updateAmount.text.toString()) + ((userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? double.parse(userDetails['bidding_amount_increase_or_decrease'].toString()) : int.parse(userDetails['bidding_amount_increase_or_decrease'].toString()))) <= (double.parse(userRequestData['request_eta_amount'].toString()) + ((double.parse(userRequestData['bidding_high_percentage'].toString()) / 100) * double.parse(userRequestData['request_eta_amount'].toString()))))
                                                                                          ? (isDarkTheme)
                                                                                              ? Colors.white
                                                                                              : Colors.black
                                                                                          : borderLines,
                                                                                      borderRadius: BorderRadius.circular(media.width * 0.04)),
                                                                                  padding: EdgeInsets.all(media.width * 0.025),
                                                                                  child: Text(
                                                                                    (userDetails['bidding_amount_increase_or_decrease'].toString().contains('.')) ? '+${double.parse(userDetails['bidding_amount_increase_or_decrease'].toString())}' : '+${int.parse(userDetails['bidding_amount_increase_or_decrease'].toString())}',
                                                                                    // '+10',
                                                                                    style: GoogleFonts.notoSans(fontSize: media.width * fourteen, fontWeight: FontWeight.w600, color: (isDarkTheme) ? Colors.black : Colors.white),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          )
                                                                        : Container(),
                                                                  ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.02,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.9,
                                                                    child:
                                                                        Button(
                                                                      onTap:
                                                                          () async {
                                                                        if (updateAmount
                                                                            .text
                                                                            .isNotEmpty) {
                                                                          setState(
                                                                              () {
                                                                            isLoading =
                                                                                true;
                                                                          });
                                                                          await FirebaseDatabase
                                                                              .instance
                                                                              .ref()
                                                                              .child('bid-meta/${userRequestData["id"]}')
                                                                              .update({
                                                                            'price':
                                                                                updateAmount.text,
                                                                            'updated_at':
                                                                                ServerValue.timestamp,
                                                                          });
                                                                          await FirebaseDatabase
                                                                              .instance
                                                                              .ref()
                                                                              .child('bid-meta/${userRequestData["id"]}/drivers')
                                                                              .remove();
                                                                          setState(
                                                                              () {
                                                                            updateAmount.clear();
                                                                            isLoading =
                                                                                false;
                                                                          });
                                                                        }
                                                                      },
                                                                      text: languages[
                                                                              choosenLanguage]
                                                                          [
                                                                          'text_update'],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                            )
                                          : Positioned(
                                              bottom: 0,
                                              child: Container(
                                                width: media.width * 1,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  12),
                                                          topRight:
                                                              Radius.circular(
                                                                  12)),
                                                  color: page,
                                                ),
                                                padding: EdgeInsets.all(
                                                    media.width * 0.05),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      width: media.width * 0.9,
                                                      child: MyText(
                                                        text: languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_search_captain'],
                                                        size: media.width *
                                                            fourteen,
                                                        fontweight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          media.height * 0.02,
                                                    ),
                                                    MyText(
                                                      text: languages[
                                                              choosenLanguage][
                                                          'text_finddriverdesc'],
                                                      size: media.width *
                                                          fourteen,
                                                      // textAlign: TextAlign.center,
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          media.height * 0.02,
                                                    ),
                                                    SizedBox(
                                                      height: media.width * 0.4,
                                                      child: Image.asset(
                                                        'assets/images/ridesearching.png',
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          media.height * 0.02,
                                                    ),
                                                    Container(
                                                      height:
                                                          media.width * 0.048,
                                                      width: media.width * 0.9,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(media
                                                                          .width *
                                                                      0.024),
                                                          color: Colors.grey),
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Container(
                                                        height:
                                                            media.width * 0.048,
                                                        width: (media.width *
                                                            0.9 *
                                                            (timing /
                                                                userDetails[
                                                                    'maximum_time_for_find_drivers_for_regular_ride'])),
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius
                                                                .circular(media
                                                                        .width *
                                                                    0.024),
                                                            color: buttonColor),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          media.height * 0.02,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        (timing != null)
                                                            ? Text(
                                                                '${Duration(seconds: timing).toString().substring(3, 7)} mins',
                                                                style: GoogleFonts.notoSans(
                                                                    fontSize:
                                                                        media.width *
                                                                            ten,
                                                                    color: textColor
                                                                        .withOpacity(
                                                                            0.4)),
                                                              )
                                                            : Container()
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          media.height * 0.02,
                                                    ),
                                                    Button(
                                                        width:
                                                            media.width * 0.5,
                                                        onTap: () async {
                                                          var val =
                                                              await cancelRequest();
                                                          if (val == 'logout') {
                                                            navigateLogout();
                                                          }
                                                        },
                                                        text: languages[
                                                                choosenLanguage]
                                                            ['text_cancel'])
                                                  ],
                                                ),
                                              ),
                                            )
                                      : Container(),
                                  (userRequestData.isNotEmpty &&
                                          userRequestData['accepted_at'] !=
                                              null)
                                      ? AnimatedPositioned(
                                          duration:
                                              const Duration(milliseconds: 250),
                                          bottom: addressBottom != null
                                              ? -addressBottom
                                              : -(media.height - media.width),
                                          child: GestureDetector(
                                            onVerticalDragStart: (v) {
                                              // if(_cont.position. == false){

                                              // };
                                              _cont.jumpTo(0.0);
                                              start = v.globalPosition.dy;
                                              if (addressBottom != null) {
                                                _addressBottom = addressBottom;
                                              } else {
                                                addressBottom = (media.height -
                                                    media.width);
                                                _addressBottom = addressBottom;
                                              }
                                              gesture.clear();
                                            },
                                            onVerticalDragUpdate: (v) {
                                              // if (v.globalPosition.dy < (media.width * 0.8)) {
                                              //   _addressBottom = media.height -
                                              //       (media.height - v.globalPosition.dy);
                                              // } else {
                                              //   _addressBottom = media.width * 0.8;
                                              // }
                                              if ((_addressBottom +
                                                          (v.globalPosition.dy -
                                                              start)) >
                                                      media.height * 0.2 &&
                                                  (_addressBottom +
                                                          (v.globalPosition.dy -
                                                              start)) <
                                                      ((media.height * 1.2) -
                                                          media.width)) {
                                                addressBottom = _addressBottom +
                                                    (v.globalPosition.dy -
                                                        start);
                                              }
                                              setState(() {});
                                            },
                                            onVerticalDragEnd: (v) {},
                                            child: Container(
                                                padding: EdgeInsets.fromLTRB(
                                                    media.width * 0.025,
                                                    media.width * 0.02,
                                                    media.width * 0.025,
                                                    0),
                                                width: media.width * 1,
                                                height: media.height * 1.2,
                                                decoration: BoxDecoration(
                                                    color: page,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    12),
                                                            topRight:
                                                                Radius.circular(
                                                                    12))),
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Container(
                                                          height: 5,
                                                          width:
                                                              media.width * 0.2,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              color: hintColor),
                                                        )
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          media.height * 0.01,
                                                    ),
                                                    SizedBox(
                                                        width:
                                                            media.width * 0.9,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            (userRequestData[
                                                                            'is_trip_start'] !=
                                                                        1 &&
                                                                    userRequestData[
                                                                            'show_otp_feature'] ==
                                                                        true)
                                                                ? Container(
                                                                    width: media
                                                                            .width *
                                                                        0.3,
                                                                    height:
                                                                        media.width *
                                                                            0.1,
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(media.width *
                                                                                0.02),
                                                                        color: Colors
                                                                            .grey
                                                                            .withOpacity(0.2)),
                                                                    child: (userRequestData['is_trip_start'] !=
                                                                                1 &&
                                                                            userRequestData['show_otp_feature'] ==
                                                                                true)
                                                                        ? MyText(
                                                                            text:
                                                                                'Otp : ${userRequestData['ride_otp']}',
                                                                            size:
                                                                                media.width * fourteen,
                                                                            textAlign:
                                                                                TextAlign.end,
                                                                            fontweight:
                                                                                FontWeight.bold,
                                                                            maxLines:
                                                                                1,
                                                                          )
                                                                        : Container(),
                                                                  )
                                                                : Container(),
                                                          ],
                                                        )),
                                                    SizedBox(
                                                      height:
                                                          media.width * 0.025,
                                                    ),

                                                    ((widget.type == null ||
                                                                (widget.type !=
                                                                            1 ||
                                                                        widget.type !=
                                                                            2) &&
                                                                    userRequestData[
                                                                            'is_trip_start'] ==
                                                                        0) &&
                                                            userRequestData[
                                                                        'waiting_charge']
                                                                    .toString() !=
                                                                '0')
                                                        ? Container(
                                                            width: media.width *
                                                                0.9,
                                                            padding: EdgeInsets
                                                                .all(media
                                                                        .width *
                                                                    0.05),
                                                            color: borderColor
                                                                .withOpacity(
                                                                    0.1),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: MyText(
                                                                    text: ((userRequestData['accepted_at'] != null &&
                                                                            userRequestData['arrived_at'] ==
                                                                                null &&
                                                                            userRequestData['is_trip_start'] ==
                                                                                0))
                                                                        ? languages[choosenLanguage]
                                                                            [
                                                                            'text_captain_arrive']
                                                                        : (userRequestData['accepted_at'] != null &&
                                                                                userRequestData['arrived_at'] != null &&
                                                                                userRequestData['is_trip_start'] == 0)
                                                                            ? (userRequestData['is_bid_ride'] == 1)
                                                                                ? languages[choosenLanguage]['text_captain_arrived']
                                                                                : '${languages[choosenLanguage]['text_captain_arrived']}, ${languages[choosenLanguage]['text_waiting_time_text'].toString().replaceAll('5', userRequestData['free_waiting_time_in_mins_before_trip_start'].toString()).replaceAll('**', (userRequestData['requested_currency_symbol'].toString() + userRequestData['waiting_charge'].toString()))}'
                                                                            : (_dist != null)
                                                                                ? languages[choosenLanguage]['text_reaching_destination'].toString().replaceAll('1111', double.parse(((_dist * 2)).toString()).round().toString())
                                                                                : languages[choosenLanguage]['text_onride'],
                                                                    // : 'Reaching Destination in ${double.parse(((_dist * 2)).toString()).round()} mins',
                                                                    size: media
                                                                            .width *
                                                                        fourteen,
                                                                    color:
                                                                        greyText,
                                                                  ),
                                                                ),
                                                                if ((userRequestData['accepted_at'] != null &&
                                                                        userRequestData['arrived_at'] !=
                                                                            null &&
                                                                        userRequestData['is_trip_start'] ==
                                                                            0) &&
                                                                    (waitingTime /
                                                                                60)
                                                                            .toStringAsFixed(0) !=
                                                                        '0')
                                                                  Container(
                                                                    padding: EdgeInsets.all(
                                                                        media.width *
                                                                            0.025),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                12),
                                                                        color: const Color(0xff5BDD0A)
                                                                            .withOpacity(0.24)),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        MyText(
                                                                          text: languages[choosenLanguage]
                                                                              [
                                                                              'text_waiting_time'],
                                                                          size: media.width *
                                                                              twelve,
                                                                          color:
                                                                              greyText,
                                                                        ),
                                                                        MyText(
                                                                          text:
                                                                              // '${double.parse(((_dist * 2)).toString()).round()} ${languages[choosenLanguage]['text_mins']}',
                                                                              '${(waitingTime / 60).toStringAsFixed(0)} ${languages[choosenLanguage]['text_mins']}',
                                                                          size: media.width *
                                                                              twelve,
                                                                          fontweight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              theme,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                              ],
                                                            ),
                                                          )
                                                        : Container(),
                                                    SizedBox(
                                                      height:
                                                          media.height * 0.01,
                                                    ),

                                                    Container(
                                                      padding: EdgeInsets.all(
                                                          media.width * 0.025),
                                                      width: media.width * 0.9,
                                                      color: borderColor
                                                          .withOpacity(0.1),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .end,
                                                                children: [
                                                                  MyText(
                                                                    text: userRequestData[
                                                                            'vehicle_type_name']
                                                                        .toString(),
                                                                    size: media
                                                                            .width *
                                                                        fourteen,
                                                                    fontweight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.025,
                                                                  ),
                                                                  Container(
                                                                    padding: EdgeInsets.only(
                                                                        left: media.width *
                                                                            0.025,
                                                                        right: media.width *
                                                                            0.025),
                                                                    // width: media.width * 0.35,
                                                                    height: media
                                                                            .width *
                                                                        0.07,
                                                                    decoration: BoxDecoration(
                                                                        color:
                                                                            boxColors,
                                                                        border: Border.all(
                                                                            color:
                                                                                Colors.black,
                                                                            width: 0.2)),
                                                                    child: Row(
                                                                      children: [
                                                                        MyText(
                                                                          text:
                                                                              '${userRequestData['driverDetail']['data']['car_number']}',
                                                                          size: media.width *
                                                                              fourteen,
                                                                          fontweight:
                                                                              FontWeight.w400,
                                                                          textAlign:
                                                                              TextAlign.end,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: media
                                                                        .width *
                                                                    0.02,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                      child:
                                                                          MyText(
                                                                    text:
                                                                        '${userRequestData['driverDetail']['data']['car_color']} | ${userRequestData['driverDetail']['data']['car_make_name']} | ${userRequestData['driverDetail']['data']['car_model_name']}',
                                                                    size: media
                                                                            .width *
                                                                        fourteen,
                                                                    fontweight:
                                                                        FontWeight
                                                                            .w500,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .end,
                                                                    maxLines: 2,
                                                                  )),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    height: media
                                                                            .width *
                                                                        0.15,
                                                                    width: media
                                                                            .width *
                                                                        0.15,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      shape: BoxShape
                                                                          .circle,
                                                                      image: DecorationImage(
                                                                          image: NetworkImage(
                                                                            userRequestData['driverDetail']['data']['profile_picture'],
                                                                          ),
                                                                          fit: BoxFit.cover),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.03,
                                                                  ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.01,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        MyText(
                                                                            text: userRequestData['driverDetail']['data'][
                                                                                'name'],
                                                                            size: media.width *
                                                                                sixteen,
                                                                            fontweight:
                                                                                FontWeight.w500),
                                                                        SizedBox(
                                                                          height:
                                                                              media.width * 0.01,
                                                                        ),
                                                                        Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            Icon(
                                                                              Icons.star,
                                                                              color: theme,
                                                                              size: media.width * 0.05,
                                                                            ),
                                                                            SizedBox(
                                                                              width: media.width * 0.005,
                                                                            ),
                                                                            Expanded(
                                                                              child: MyText(
                                                                                color: greyText,
                                                                                text: (userRequestData['driverDetail']['data']['rating'] == 0) ? languages[choosenLanguage]['text_no_rating'] : userRequestData['driverDetail']['data']['rating'].toString(),
                                                                                size: media.width * fourteen,
                                                                                fontweight: FontWeight.w600,
                                                                                maxLines: 1,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.025,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height:
                                                                media.width *
                                                                    0.03,
                                                          ),
                                                          if (userRequestData[
                                                                  'is_trip_start'] ==
                                                              0)
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                    child:
                                                                        InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    var result = await Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                const ChatPage()));
                                                                    if (result) {
                                                                      setState(
                                                                          () {});
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: media
                                                                            .width *
                                                                        0.12,
                                                                    padding: EdgeInsets.only(
                                                                        left: media.width *
                                                                            0.05,
                                                                        right: media.width *
                                                                            0.05),
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(media.width *
                                                                              0.07),
                                                                      color: Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.2),
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Stack(
                                                                          children: [
                                                                            SizedBox(
                                                                              width: media.width * 0.1,
                                                                              child: const Icon(
                                                                                Icons.message,
                                                                                color: Colors.grey,
                                                                              ),
                                                                            ),
                                                                            if (chatList.where((element) => element['from_type'] == 2 && element['seen'] == 0).isNotEmpty)
                                                                              Positioned(
                                                                                  top: media.width * 0.01,
                                                                                  right: media.width * 0.01,
                                                                                  child: Container(
                                                                                    height: media.width * 0.02,
                                                                                    width: media.width * 0.02,
                                                                                    decoration: BoxDecoration(shape: BoxShape.circle, color: verifyDeclined),
                                                                                  ))
                                                                          ],
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              media.width * 0.03,
                                                                        ),
                                                                        Expanded(
                                                                            child:
                                                                                MyText(
                                                                          text: languages[choosenLanguage]
                                                                              [
                                                                              'text_chatwithdriver'],
                                                                          size: media.width *
                                                                              fourteen,
                                                                          color:
                                                                              hintColor,
                                                                        ))
                                                                      ],
                                                                    ),
                                                                  ),
                                                                )),
                                                                SizedBox(
                                                                  width: media
                                                                          .width *
                                                                      0.05,
                                                                ),
                                                                InkWell(
                                                                  onTap: () {
                                                                    makingPhoneCall(userRequestData['driverDetail']
                                                                            [
                                                                            'data']
                                                                        [
                                                                        'mobile']);
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    height: media
                                                                            .width *
                                                                        0.096,
                                                                    width: media
                                                                            .width *
                                                                        0.096,
                                                                    decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color: const Color(
                                                                                0xff5BDD0A),
                                                                            width:
                                                                                1),
                                                                        shape: BoxShape
                                                                            .circle),
                                                                    alignment:
                                                                        Alignment
                                                                            .center,
                                                                    child: Image
                                                                        .asset(
                                                                      'assets/images/call.png',
                                                                      color: const Color(
                                                                          0xff5BDD0A),
                                                                      height: media
                                                                              .width *
                                                                          0.05,
                                                                      width: media
                                                                              .width *
                                                                          0.05,
                                                                      fit: BoxFit
                                                                          .contain,
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                                    ),

                                                    (userRequestData[
                                                                'is_trip_start'] !=
                                                            1)
                                                        ? Column(
                                                            children: [
                                                              SizedBox(
                                                                height: media
                                                                        .width *
                                                                    0.05,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  (userRequestData[
                                                                              'is_trip_start'] !=
                                                                          1)
                                                                      ? InkWell(
                                                                          onTap:
                                                                              () async {
                                                                            setState(() {
                                                                              isLoading = true;
                                                                            });
                                                                            var reason = await cancelReason((userRequestData['is_driver_arrived'] == 0)
                                                                                ? 'before'
                                                                                : 'after');
                                                                            if (reason ==
                                                                                true) {
                                                                              setState(() {
                                                                                _cancellingError = '';
                                                                                _cancelReason = '';
                                                                                _cancelling = true;
                                                                              });
                                                                            }
                                                                            setState(() {
                                                                              isLoading = false;
                                                                            });
                                                                          },
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              Image.asset(
                                                                                'assets/images/cancelimage.png',
                                                                                height: media.width * 0.064,
                                                                                width: media.width * 0.064,
                                                                                fit: BoxFit.contain,
                                                                                color: verifyDeclined,
                                                                                // width: media.width * 0.064,
                                                                                // fit: BoxFit.contain,
                                                                              ),
                                                                              SizedBox(
                                                                                width: media.width * 0.025,
                                                                              ),
                                                                              MyText(
                                                                                text: languages[choosenLanguage]['text_cancel_booking'],
                                                                                // size: media.width * twelve,

                                                                                // color: const Color(0xffF95858),
                                                                                size: media.width * twelve,
                                                                                fontweight: FontWeight.w400,
                                                                                color: verifyDeclined,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      : Container(),
                                                                ],
                                                              ),
                                                            ],
                                                          )
                                                        : Container(),
                                                    // if (_ontripBottom ==
                                                    //     true)
                                                    SizedBox(
                                                      height:
                                                          media.width * 0.05,
                                                    ),

                                                    // if (_ontripBottom ==
                                                    //     true)
                                                    Expanded(
                                                      child:
                                                          SingleChildScrollView(
                                                        controller: _cont,
                                                        physics: (addressBottom !=
                                                                    null &&
                                                                addressBottom <=
                                                                    (media.height *
                                                                        0.25))
                                                            ? const BouncingScrollPhysics()
                                                            : const NeverScrollableScrollPhysics(),
                                                        child: Column(
                                                          children: [
                                                            if (userRequestData[
                                                                    'transport_type'] ==
                                                                'delivery')
                                                              Column(
                                                                children: [
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.02,
                                                                  ),
                                                                  SizedBox(
                                                                    width: media
                                                                            .width *
                                                                        0.9,
                                                                    child: Text(
                                                                      '${userRequestData['goods_type']} - ${userRequestData['goods_type_quantity']}',
                                                                      style: GoogleFonts.notoSans(
                                                                          fontSize: media.width *
                                                                              fourteen,
                                                                          fontWeight: FontWeight
                                                                              .w600,
                                                                          color:
                                                                              buttonColor),
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      maxLines:
                                                                          2,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: media
                                                                            .width *
                                                                        0.02,
                                                                  ),
                                                                ],
                                                              ),
                                                            (userRequestData[
                                                                            'is_rental'] !=
                                                                        true &&
                                                                    userRequestData[
                                                                            'drop_address'] !=
                                                                        null)
                                                                ? Column(
                                                                    children: [
                                                                      Container(
                                                                        padding:
                                                                            EdgeInsets.all(media.width *
                                                                                0.03),
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.grey.withOpacity(0.1),
                                                                            borderRadius: BorderRadius.circular(media.width * 0.02)),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              height: media.width * 0.05,
                                                                              width: media.width * 0.05,
                                                                              alignment: Alignment.center,
                                                                              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.withOpacity(0.4)
                                                                                  // color: online.withOpacity(0.4)
                                                                                  ),
                                                                              child: Container(
                                                                                height: media.width * 0.025,
                                                                                width: media.width * 0.025,
                                                                                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.green.withOpacity(0.4)
                                                                                    // color: online
                                                                                    ),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: media.width * 0.03,
                                                                            ),
                                                                            Expanded(
                                                                                child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                MyText(
                                                                                  text: languages[choosenLanguage]['text_pick_up_location'],
                                                                                  size: media.width * fourteen,
                                                                                  fontweight: FontWeight.w600,
                                                                                ),
                                                                                MyText(
                                                                                  text: userRequestData['pick_address'],
                                                                                  size: media.width * twelve,
                                                                                  color: greyText,
                                                                                  // maxLines: 1,
                                                                                ),
                                                                              ],
                                                                            )),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: media.width *
                                                                            0.02,
                                                                      ),
                                                                      (tripStops
                                                                              .isNotEmpty)
                                                                          ? Column(
                                                                              children: tripStops
                                                                                  .asMap()
                                                                                  .map((i, value) {
                                                                                    return MapEntry(
                                                                                        i,
                                                                                        (i < tripStops.length - 1)
                                                                                            ? Container(
                                                                                                // height: media.width * 0.15,
                                                                                                padding: EdgeInsets.all(media.width * 0.03),
                                                                                                margin: EdgeInsets.only(bottom: media.width * 0.02),
                                                                                                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(media.width * 0.02)),
                                                                                                child: Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                                  // crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                  children: [
                                                                                                    Container(
                                                                                                      height: media.width * 0.05,
                                                                                                      width: media.width * 0.05,
                                                                                                      alignment: Alignment.center,
                                                                                                      // decoration: BoxDecoration(shape: BoxShape.circle, color: online.withOpacity(0.4)),
                                                                                                      child: MyText(
                                                                                                        text: (i + 1).toString(),
                                                                                                        size: media.width * fourteen,
                                                                                                        color: verifyDeclined,
                                                                                                        fontweight: FontWeight.w600,
                                                                                                      ),
                                                                                                    ),
                                                                                                    SizedBox(
                                                                                                      width: media.width * 0.03,
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                        child: MyText(
                                                                                                      text: tripStops[i]['address'],
                                                                                                      size: media.width * twelve,
                                                                                                      color: greyText,
                                                                                                      // maxLines: 1,
                                                                                                    )),
                                                                                                  ],
                                                                                                ),
                                                                                              )
                                                                                            : Container());
                                                                                  })
                                                                                  .values
                                                                                  .toList(),
                                                                            )
                                                                          : Container(),
                                                                      Container(
                                                                        padding:
                                                                            EdgeInsets.all(media.width *
                                                                                0.03),
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Colors.grey.withOpacity(0.1),
                                                                            borderRadius: BorderRadius.circular(media.width * 0.02)),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              height: media.width * 0.05,
                                                                              width: media.width * 0.05,
                                                                              alignment: Alignment.center,
                                                                              // decoration: BoxDecoration(shape: BoxShape.circle, color: online.withOpacity(0.4)),
                                                                              child: const Icon(Icons.location_on,
                                                                                  // color: verifyDeclined,
                                                                                  color: Color(0xffF52D56)),
                                                                            ),
                                                                            SizedBox(
                                                                              width: media.width * 0.03,
                                                                            ),
                                                                            Expanded(
                                                                                child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                MyText(
                                                                                  text: languages[choosenLanguage]['text_drop'],
                                                                                  size: media.width * fourteen,
                                                                                  fontweight: FontWeight.w600,
                                                                                ),
                                                                                MyText(
                                                                                  text: userRequestData['drop_address'],
                                                                                  size: media.width * twelve,
                                                                                  color: greyText,
                                                                                  // maxLines: 1,
                                                                                ),
                                                                              ],
                                                                            )),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                                : Container(
                                                                    padding: EdgeInsets.all(
                                                                        media.width *
                                                                            0.03),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .grey
                                                                            .withOpacity(
                                                                                0.1),
                                                                        borderRadius:
                                                                            BorderRadius.circular(media.width *
                                                                                0.02)),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Container(
                                                                          height:
                                                                              media.width * 0.05,
                                                                          width:
                                                                              media.width * 0.05,
                                                                          alignment:
                                                                              Alignment.center,
                                                                          decoration: BoxDecoration(
                                                                              shape: BoxShape.circle,
                                                                              color: Colors.green.withOpacity(0.4)
                                                                              // color: online.withOpacity(0.4)
                                                                              ),
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                media.width * 0.025,
                                                                            width:
                                                                                media.width * 0.025,
                                                                            decoration: BoxDecoration(
                                                                                shape: BoxShape.circle,
                                                                                color: Colors.green.withOpacity(0.4)
                                                                                // color: online
                                                                                ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              media.width * 0.03,
                                                                        ),
                                                                        Expanded(
                                                                            child:
                                                                                Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            MyText(
                                                                              text: languages[choosenLanguage]['text_pick_up_location'],
                                                                              size: media.width * fourteen,
                                                                              fontweight: FontWeight.w600,
                                                                            ),
                                                                            MyText(
                                                                              text: userRequestData['pick_address'],
                                                                              size: media.width * twelve,
                                                                              color: greyText,
                                                                              // maxLines: 1,
                                                                            ),
                                                                          ],
                                                                        )),
                                                                      ],
                                                                    ),
                                                                  ),
                                                            if (widget.type !=
                                                                2)
                                                              Container(
                                                                margin: EdgeInsets.only(
                                                                    top: media
                                                                            .width *
                                                                        0.02),
                                                                padding: EdgeInsets
                                                                    .all(media
                                                                            .width *
                                                                        0.03),
                                                                decoration: BoxDecoration(
                                                                    color: Colors
                                                                        .grey
                                                                        .withOpacity(
                                                                            0.1),
                                                                    borderRadius:
                                                                        BorderRadius.circular(media.width *
                                                                            0.02)),
                                                                child: Column(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Expanded(
                                                                            child:
                                                                                MyText(
                                                                          text: languages[choosenLanguage]
                                                                              [
                                                                              'text_payingvia'],
                                                                          size: media.width *
                                                                              fourteen,
                                                                          fontweight:
                                                                              FontWeight.w600,
                                                                        )),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height: media
                                                                              .width *
                                                                          0.025,
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              Row(
                                                                            children: [
                                                                              (userRequestData['payment_opt'] == '1')
                                                                                  ? Image.asset(
                                                                                      'assets/images/cash.png',
                                                                                      width: media.width * 0.07,
                                                                                      height: media.width * 0.07,
                                                                                      fit: BoxFit.contain,
                                                                                    )
                                                                                  : (userRequestData['payment_opt'] == '2')
                                                                                      ? Image.asset(
                                                                                          'assets/images/wallet.png',
                                                                                          width: media.width * 0.07,
                                                                                          height: media.width * 0.07,
                                                                                          fit: BoxFit.contain,
                                                                                        )
                                                                                      : (userRequestData['payment_opt'] == '0')
                                                                                          ? Image.asset(
                                                                                              'assets/images/card.png',
                                                                                              width: media.width * 0.07,
                                                                                              height: media.width * 0.07,
                                                                                              fit: BoxFit.contain,
                                                                                            )
                                                                                          : Container(),
                                                                              SizedBox(
                                                                                width: media.width * 0.02,
                                                                              ),
                                                                              MyText(
                                                                                text: (userRequestData['payment_opt'] == '1')
                                                                                    ? languages[choosenLanguage]['text_cash']
                                                                                    : (userRequestData['payment_opt'] == '2')
                                                                                        ? languages[choosenLanguage]['text_wallet']
                                                                                        : languages[choosenLanguage]['text_card'],
                                                                                // userRequestData['payment_type_string'],
                                                                                size: media.width * sixteen,
                                                                                fontweight: FontWeight.w600,
                                                                                color: (isDarkTheme == true) ? Colors.white : Colors.black,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.end,
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                (userRequestData['is_bid_ride'] == 1)
                                                                                    ? MyText(
                                                                                        textAlign: TextAlign.end,
                                                                                        text: userRequestData['requested_currency_symbol'] + ' ' + userRequestData['accepted_ride_fare'].toString(),
                                                                                        size: media.width * sixteen,
                                                                                        fontweight: FontWeight.w500,
                                                                                        color: textColor,
                                                                                      )
                                                                                    : (userRequestData['discounted_total'] != null)
                                                                                        ? MyText(
                                                                                            textAlign: TextAlign.end,
                                                                                            text: userRequestData['requested_currency_symbol'] + ' ' + userRequestData['discounted_total'].toString(),
                                                                                            size: media.width * sixteen,
                                                                                            fontweight: FontWeight.w500,
                                                                                            color: textColor,
                                                                                            maxLines: 1,
                                                                                          )
                                                                                        : MyText(
                                                                                            textAlign: TextAlign.end,
                                                                                            text: userRequestData['requested_currency_symbol'] + ' ' + userRequestData['request_eta_amount'].toString(),
                                                                                            size: media.width * sixteen,
                                                                                            fontweight: FontWeight.w500,
                                                                                            color: textColor,
                                                                                            maxLines: 1,
                                                                                          ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            SizedBox(
                                                              height:
                                                                  media.height *
                                                                      0.25,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )),
                                          ))
                                      : Container(),

                                  //cancel request
                                  (_cancelling == true)
                                      ? Positioned(
                                          child: Container(
                                          height: media.height * 1,
                                          width: media.width * 1,
                                          color: Colors.transparent
                                              .withOpacity(0.6),
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(
                                                    media.width * 0.05),
                                                width: media.width * 0.9,
                                                decoration: BoxDecoration(
                                                    color: page,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)),
                                                child: Column(children: [
                                                  Container(
                                                    height: media.width * 0.18,
                                                    width: media.width * 0.18,
                                                    decoration:
                                                        const BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Color(
                                                                0xffFEF2F2)),
                                                    alignment: Alignment.center,
                                                    child: Container(
                                                      height:
                                                          media.width * 0.14,
                                                      width: media.width * 0.14,
                                                      decoration:
                                                          const BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              color: Color(
                                                                  0xffFF0000)),
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.cancel_outlined,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Column(
                                                    children: cancelReasonsList
                                                        .asMap()
                                                        .map((i, value) {
                                                          return MapEntry(
                                                              i,
                                                              InkWell(
                                                                onTap: () {
                                                                  setState(() {
                                                                    _cancelReason =
                                                                        cancelReasonsList[i]
                                                                            [
                                                                            'reason'];
                                                                  });
                                                                },
                                                                child:
                                                                    Container(
                                                                  padding: EdgeInsets
                                                                      .all(media
                                                                              .width *
                                                                          0.01),
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        height: media.height *
                                                                            0.05,
                                                                        width: media.width *
                                                                            0.05,
                                                                        decoration: BoxDecoration(
                                                                            shape:
                                                                                BoxShape.circle,
                                                                            border: Border.all(color: textColor, width: 1.2)),
                                                                        alignment:
                                                                            Alignment.center,
                                                                        child: (_cancelReason ==
                                                                                cancelReasonsList[i]['reason'])
                                                                            ? Container(
                                                                                height: media.width * 0.03,
                                                                                width: media.width * 0.03,
                                                                                decoration: BoxDecoration(
                                                                                  shape: BoxShape.circle,
                                                                                  color: textColor,
                                                                                ),
                                                                              )
                                                                            : Container(),
                                                                      ),
                                                                      SizedBox(
                                                                        width: media.width *
                                                                            0.05,
                                                                      ),
                                                                      SizedBox(
                                                                          width: media.width *
                                                                              0.65,
                                                                          child:
                                                                              MyText(
                                                                            text:
                                                                                cancelReasonsList[i]['reason'],
                                                                            size:
                                                                                media.width * twelve,
                                                                          ))
                                                                    ],
                                                                  ),
                                                                ),
                                                              ));
                                                        })
                                                        .values
                                                        .toList(),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        _cancelReason =
                                                            'others';
                                                      });
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                          media.width * 0.01),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height:
                                                                media.height *
                                                                    0.05,
                                                            width: media.width *
                                                                0.05,
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                border: Border.all(
                                                                    color:
                                                                        textColor,
                                                                    width:
                                                                        1.2)),
                                                            alignment: Alignment
                                                                .center,
                                                            child:
                                                                (_cancelReason ==
                                                                        'others')
                                                                    ? Container(
                                                                        height: media.width *
                                                                            0.03,
                                                                        width: media.width *
                                                                            0.03,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          shape:
                                                                              BoxShape.circle,
                                                                          color:
                                                                              textColor,
                                                                        ),
                                                                      )
                                                                    : Container(),
                                                          ),
                                                          SizedBox(
                                                            width: media.width *
                                                                0.05,
                                                          ),
                                                          MyText(
                                                            text: languages[
                                                                    choosenLanguage]
                                                                ['text_others'],
                                                            size: media.width *
                                                                twelve,
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  (_cancelReason == 'others')
                                                      ? Container(
                                                          margin: EdgeInsets
                                                              .fromLTRB(
                                                                  0,
                                                                  media.width *
                                                                      0.025,
                                                                  0,
                                                                  media.width *
                                                                      0.025),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  media.width *
                                                                      0.05),
                                                          // height: media.width*0.2,
                                                          width:
                                                              media.width * 0.9,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: (isDarkTheme ==
                                                                          true)
                                                                      ? textColor
                                                                      : borderLines,
                                                                  width: 1.2),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12)),
                                                          child: TextField(
                                                            decoration: InputDecoration(
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                hintText: languages[
                                                                        choosenLanguage]
                                                                    [
                                                                    'text_cancelRideReason'],
                                                                hintStyle: GoogleFonts.notoSans(
                                                                    color: textColor
                                                                        .withOpacity(
                                                                            0.4),
                                                                    fontSize: media
                                                                            .width *
                                                                        twelve)),
                                                            style: GoogleFonts
                                                                .notoSans(
                                                                    color:
                                                                        textColor),
                                                            maxLines: 4,
                                                            minLines: 2,
                                                            onChanged: (val) {
                                                              setState(() {
                                                                _cancelCustomReason =
                                                                    val;
                                                              });
                                                            },
                                                          ),
                                                        )
                                                      : Container(),
                                                  (_cancellingError != '')
                                                      ? Container(
                                                          padding: EdgeInsets.only(
                                                              top: media.width *
                                                                  0.02,
                                                              bottom:
                                                                  media.width *
                                                                      0.02),
                                                          width:
                                                              media.width * 0.9,
                                                          child: Text(
                                                              _cancellingError,
                                                              style: GoogleFonts.notoSans(
                                                                  fontSize: media
                                                                          .width *
                                                                      twelve,
                                                                  color: Colors
                                                                      .red)))
                                                      : Container(),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Button(
                                                          color: page,
                                                          textcolor:
                                                              buttonColor,
                                                          borcolor: buttonColor,
                                                          width: media.width *
                                                              0.39,
                                                          onTap: () async {
                                                            setState(() {
                                                              isLoading = true;
                                                            });
                                                            if (_cancelReason !=
                                                                '') {
                                                              if (_cancelReason ==
                                                                  'others') {
                                                                if (_cancelCustomReason !=
                                                                        '' &&
                                                                    _cancelCustomReason
                                                                        .isNotEmpty) {
                                                                  _cancellingError =
                                                                      '';
                                                                  var val =
                                                                      await cancelRequestWithReason(
                                                                          _cancelCustomReason);
                                                                  if (val ==
                                                                      'logout') {
                                                                    navigateLogout();
                                                                  }
                                                                  setState(() {
                                                                    _cancelling =
                                                                        false;
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    _cancellingError =
                                                                        languages[choosenLanguage]
                                                                            [
                                                                            'text_add_cancel_reason'];
                                                                  });
                                                                }
                                                              } else {
                                                                var val =
                                                                    await cancelRequestWithReason(
                                                                        _cancelReason);
                                                                if (val ==
                                                                    'logout') {
                                                                  navigateLogout();
                                                                }
                                                                setState(() {
                                                                  _cancelling =
                                                                      false;
                                                                });
                                                              }
                                                            } else {}
                                                            setState(() {
                                                              isLoading = false;
                                                            });
                                                          },
                                                          text: languages[
                                                                  choosenLanguage]
                                                              ['text_cancel']),
                                                      Button(
                                                          width: media.width *
                                                              0.39,
                                                          onTap: () {
                                                            setState(() {
                                                              _cancelling =
                                                                  false;
                                                            });
                                                          },
                                                          text: languages[
                                                                  choosenLanguage]
                                                              [
                                                              'tex_dontcancel'])
                                                    ],
                                                  )
                                                ]),
                                              ),
                                            ],
                                          ),
                                        ))
                                      : Container(),

                                  //date picker for ride later
                                  (_dateTimePicker == true)
                                      ? Positioned(
                                          top: 0,
                                          child: Container(
                                            height: media.height * 1,
                                            width: media.width * 1,
                                            color: Colors.transparent
                                                .withOpacity(0.6),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: media.width * 0.9,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                          height: media.height *
                                                              0.1,
                                                          width: media.width *
                                                              0.1,
                                                          decoration:
                                                              BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: page),
                                                          child: InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  _dateTimePicker =
                                                                      false;
                                                                });
                                                              },
                                                              child: Icon(
                                                                  Icons
                                                                      .cancel_outlined,
                                                                  color:
                                                                      textColor))),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  height: media.width * 0.5,
                                                  width: media.width * 0.9,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      color: topBar),
                                                  child: CupertinoDatePicker(
                                                      minimumDate: DateTime.now()
                                                          .add(Duration(
                                                              minutes: int.parse(
                                                                  userDetails[
                                                                      'user_can_make_a_ride_after_x_miniutes']))),
                                                      initialDateTime: DateTime.now()
                                                          .add(Duration(
                                                              minutes: int.parse(
                                                                  userDetails[
                                                                      'user_can_make_a_ride_after_x_miniutes']))),
                                                      maximumDate:
                                                          DateTime.now().add(
                                                              const Duration(
                                                                  days: 4)),
                                                      onDateTimeChanged: (val) {
                                                        choosenDateTime = val;
                                                      }),
                                                ),
                                                Container(
                                                    padding: EdgeInsets.all(
                                                        media.width * 0.05),
                                                    child: Button(
                                                        onTap: () {
                                                          setState(() {
                                                            _dateTimePicker =
                                                                false;
                                                          });
                                                        },
                                                        text: languages[
                                                                choosenLanguage]
                                                            ['text_confirm']))
                                              ],
                                            ),
                                          ))
                                      : Container(),

                                  AnimatedPositioned(
                                      duration: const Duration(milliseconds: 1),
                                      bottom: _isDateTimebottom,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _dateTimeHeight = 0;
                                          });
                                          Future.delayed(
                                              const Duration(milliseconds: 200),
                                              () {
                                            setState(() {
                                              _isDateTimebottom = -1000;
                                            });
                                          });
                                        },
                                        child: Container(
                                          height: media.height * 1,
                                          width: media.width * 1,
                                          color: Colors.black.withOpacity(0.3),
                                          alignment: Alignment.bottomCenter,
                                          child: AnimatedContainer(
                                            padding: EdgeInsets.all(
                                                media.width * 0.05),
                                            duration: const Duration(
                                                milliseconds: 200),
                                            width: media.width * 1,
                                            height: _dateTimeHeight == 0
                                                ? 0
                                                : _dateTimeHeight,
                                            color: page,
                                            constraints: BoxConstraints(
                                                minHeight: 0,
                                                maxHeight: media.height * 0.5),
                                            curve: Curves.easeOut,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  MyText(
                                                      text:
                                                          '${(isOneWayTrip) ? languages[choosenLanguage]['text_schedule_trip'] : languages[choosenLanguage]['text_schedule_round_trip']}',
                                                      size: media.width *
                                                          eighteen),
                                                  (isOneWayTrip)
                                                      ? MyText(
                                                          text:
                                                              '${languages[choosenLanguage]['text_starting']} ${(isOneWayTrip) ? DateFormat('d MMM, h:mm a').format(fromDate).toString() : DateFormat('d MMM, h:mm a').format(DateTime.now().add(Duration(minutes: int.parse(userDetails['user_can_make_a_ride_after_x_miniutes'])))).toString()}',
                                                          size: media.width *
                                                              sixteen,
                                                          color: hintColor,
                                                        )
                                                      : MyText(
                                                          text:
                                                              '${languages[choosenLanguage]['text_starting']} ${DateFormat('d MMM, h:mm a').format(fromDate).toString()} to ${(toDate != null) ? DateFormat('d MMM, h:mm a').format(toDate!) : languages[choosenLanguage]['text_select']}',
                                                          size: media.width *
                                                              sixteen,
                                                          color: hintColor,
                                                        ),
                                                  (!isOneWayTrip)
                                                      ? Row(
                                                          children: [
                                                            InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  isFromDate =
                                                                      true;
                                                                  toDate = null;
                                                                });
                                                              },
                                                              child: Container(
                                                                height: media
                                                                        .width *
                                                                    0.1,
                                                                padding: EdgeInsets
                                                                    .all(media
                                                                            .width *
                                                                        0.02),
                                                                decoration: BoxDecoration(
                                                                    border: Border(
                                                                        bottom: BorderSide(
                                                                            color: (isFromDate)
                                                                                ? hintColor
                                                                                : page))),
                                                                child: MyText(
                                                                  text: languages[
                                                                          choosenLanguage]
                                                                      [
                                                                      'text_leave_on'],
                                                                  size: media
                                                                          .width *
                                                                      fourteen,
                                                                  color: (isFromDate)
                                                                      ? textColor
                                                                      : hintColor,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  media.width *
                                                                      0.04,
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  isFromDate =
                                                                      false;
                                                                  toDate = fromDate.add(
                                                                      const Duration(
                                                                          days:
                                                                              1,
                                                                          minutes:
                                                                              2));
                                                                });
                                                              },
                                                              child: Container(
                                                                height: media
                                                                        .width *
                                                                    0.1,
                                                                padding: EdgeInsets
                                                                    .all(media
                                                                            .width *
                                                                        0.02),
                                                                decoration: BoxDecoration(
                                                                    border: Border(
                                                                        bottom: BorderSide(
                                                                            color: (!isFromDate)
                                                                                ? hintColor
                                                                                : page))),
                                                                child: MyText(
                                                                  text: languages[
                                                                          choosenLanguage]
                                                                      [
                                                                      'text_return_by'],
                                                                  size: media
                                                                          .width *
                                                                      fourteen,
                                                                  color: (!isFromDate)
                                                                      ? textColor
                                                                      : hintColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : Container(),
                                                  (isFromDate)
                                                      ? Container(
                                                          height:
                                                              media.width * 0.5,
                                                          width:
                                                              media.width * 0.9,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              color: topBar),
                                                          child:
                                                              CupertinoDatePicker(
                                                                  minimumDate: DateTime.now().add(Duration(
                                                                      minutes: int.parse(userDetails[
                                                                          'user_can_make_a_ride_after_x_miniutes']))),
                                                                  initialDateTime:
                                                                      DateTime.now().add(Duration(
                                                                          minutes: int.parse(userDetails[
                                                                              'user_can_make_a_ride_after_x_miniutes']))),
                                                                  maximumDate: DateTime.now().add(
                                                                      const Duration(
                                                                          days:
                                                                              4)),
                                                                  onDateTimeChanged:
                                                                      (val) {
                                                                    fromDate =
                                                                        val;

                                                                    // choosenDateTime = val;
                                                                    //     .toString());
                                                                  }),
                                                        )
                                                      : Container(
                                                          height:
                                                              media.width * 0.5,
                                                          width:
                                                              media.width * 0.9,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              color: topBar),
                                                          child:
                                                              CupertinoDatePicker(
                                                                  minimumDate: fromDate.add(
                                                                      const Duration(
                                                                          days:
                                                                              1,
                                                                          minutes:
                                                                              10)),
                                                                  initialDateTime:
                                                                      fromDate.add(const Duration(
                                                                          days:
                                                                              1,
                                                                          minutes:
                                                                              10)),
                                                                  maximumDate: fromDate.add(
                                                                      const Duration(
                                                                          days:
                                                                              7)),
                                                                  onDateTimeChanged:
                                                                      (val) {
                                                                    toDate =
                                                                        val;
                                                                  }),
                                                        ),
                                                  Container(
                                                      padding: EdgeInsets.all(
                                                          media.width * 0.05),
                                                      child: Button(
                                                          onTap: () {
                                                            if (!isOneWayTrip &&
                                                                toDate ==
                                                                    null) {
                                                              setState(() {
                                                                isFromDate =
                                                                    false;
                                                                toDate = fromDate.add(
                                                                    const Duration(
                                                                        days: 1,
                                                                        minutes:
                                                                            2));
                                                              });
                                                            } else {
                                                              setState(() {
                                                                nofromdate =
                                                                    true;
                                                                _dateTimeHeight =
                                                                    0;
                                                              });
                                                              if (toDate !=
                                                                  null) {
                                                                dateDifference =
                                                                    toDate!.difference(
                                                                        fromDate);

                                                                daysDifferenceRoundedUp =
                                                                    (dateDifference.inHours /
                                                                            24)
                                                                        .ceil();
                                                              }

                                                              Future.delayed(
                                                                  const Duration(
                                                                      milliseconds:
                                                                          200),
                                                                  () {
                                                                setState(() {
                                                                  _isDateTimebottom =
                                                                      -1000;
                                                                });
                                                              });
                                                            }
                                                          },
                                                          text: (isFromDate)
                                                              ? languages[
                                                                      choosenLanguage]
                                                                  ['text_next']
                                                              : languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_confirm'])),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )),

                                  //sos popup
                                  (showSos == true)
                                      ? Positioned(
                                          top: 0,
                                          child: Container(
                                            height: media.height * 1,
                                            width: media.width * 1,
                                            color: Colors.transparent
                                                .withOpacity(0.6),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  SizedBox(
                                                    width: media.width * 0.7,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              notifyCompleted =
                                                                  false;
                                                              showSos = false;
                                                            });
                                                          },
                                                          child: Container(
                                                            height:
                                                                media.width *
                                                                    0.1,
                                                            width: media.width *
                                                                0.1,
                                                            decoration:
                                                                BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color:
                                                                        page),
                                                            child: Icon(
                                                              Icons
                                                                  .cancel_outlined,
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
                                                    padding: EdgeInsets.all(
                                                        media.width * 0.05),
                                                    height: media.height * 0.5,
                                                    width: media.width * 0.7,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        color: page),
                                                    child:
                                                        SingleChildScrollView(
                                                            physics:
                                                                const BouncingScrollPhysics(),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    setState(
                                                                        () {
                                                                      notifyCompleted =
                                                                          false;
                                                                    });
                                                                    var val =
                                                                        await notifyAdmin();
                                                                    if (val ==
                                                                        true) {
                                                                      setState(
                                                                          () {
                                                                        notifyCompleted =
                                                                            true;
                                                                      });
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding: EdgeInsets.all(
                                                                        media.width *
                                                                            0.05),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              languages[choosenLanguage]['text_notifyadmin'],
                                                                              style: GoogleFonts.notoSans(fontSize: media.width * sixteen, color: textColor, fontWeight: FontWeight.w600),
                                                                            ),
                                                                            (notifyCompleted == true)
                                                                                ? Container(
                                                                                    padding: EdgeInsets.only(top: media.width * 0.01),
                                                                                    child: Text(
                                                                                      languages[choosenLanguage]['text_notifysuccess'],
                                                                                      style: GoogleFonts.notoSans(
                                                                                        fontSize: media.width * twelve,
                                                                                        color: const Color(0xff319900),
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                                : Container()
                                                                          ],
                                                                        ),
                                                                        Icon(
                                                                          Icons
                                                                              .notification_add,
                                                                          color:
                                                                              textColor,
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                (sosData.isNotEmpty)
                                                                    ? Column(
                                                                        children: sosData
                                                                            .asMap()
                                                                            .map((i, value) {
                                                                              return MapEntry(
                                                                                  i,
                                                                                  InkWell(
                                                                                    onTap: () {
                                                                                      makingPhoneCall(sosData[i]['number'].toString().replaceAll(' ', ''));
                                                                                    },
                                                                                    child: Container(
                                                                                      padding: EdgeInsets.all(media.width * 0.05),
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          Column(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              SizedBox(
                                                                                                width: media.width * 0.4,
                                                                                                child: Text(
                                                                                                  sosData[i]['name'],
                                                                                                  style: GoogleFonts.notoSans(fontSize: media.width * fourteen, color: textColor, fontWeight: FontWeight.w600),
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(
                                                                                                height: media.width * 0.01,
                                                                                              ),
                                                                                              Text(
                                                                                                sosData[i]['number'],
                                                                                                style: GoogleFonts.notoSans(
                                                                                                  fontSize: media.width * twelve,
                                                                                                  color: textColor,
                                                                                                ),
                                                                                              )
                                                                                            ],
                                                                                          ),
                                                                                          Icon(
                                                                                            Icons.call,
                                                                                            color: textColor,
                                                                                          )
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                  ));
                                                                            })
                                                                            .values
                                                                            .toList(),
                                                                      )
                                                                    : Container(
                                                                        width: media.width *
                                                                            0.7,
                                                                        alignment:
                                                                            Alignment.center,
                                                                        child:
                                                                            Text(
                                                                          languages[choosenLanguage]
                                                                              [
                                                                              'text_noDataFound'],
                                                                          style: GoogleFonts.notoSans(
                                                                              fontSize: media.width * eighteen,
                                                                              fontWeight: FontWeight.w600,
                                                                              color: textColor),
                                                                        ),
                                                                      ),
                                                              ],
                                                            )),
                                                  )
                                                ]),
                                          ))
                                      : Container(),

                                  (_locationDenied == true)
                                      ? Positioned(
                                          child: Container(
                                          height: media.height * 1,
                                          width: media.width * 1,
                                          color: Colors.transparent
                                              .withOpacity(0.6),
                                          child: Column(
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
                                                          _locationDenied =
                                                              false;
                                                        });
                                                      },
                                                      child: Container(
                                                        height:
                                                            media.height * 0.05,
                                                        width:
                                                            media.height * 0.05,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: page,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                            Icons.cancel,
                                                            color: buttonColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                  height: media.width * 0.025),
                                              Container(
                                                padding: EdgeInsets.all(
                                                    media.width * 0.05),
                                                width: media.width * 0.9,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    color: page,
                                                    boxShadow: [
                                                      BoxShadow(
                                                          blurRadius: 2.0,
                                                          spreadRadius: 2.0,
                                                          color: Colors.black
                                                              .withOpacity(0.2))
                                                    ]),
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                        width:
                                                            media.width * 0.8,
                                                        child: Text(
                                                          languages[
                                                                  choosenLanguage]
                                                              [
                                                              'text_open_loc_settings'],
                                                          style: GoogleFonts
                                                              .notoSans(
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  color:
                                                                      textColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                        )),
                                                    SizedBox(
                                                        height:
                                                            media.width * 0.05),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        InkWell(
                                                            onTap: () async {
                                                              await perm
                                                                  .openAppSettings();
                                                            },
                                                            child: Text(
                                                              languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_open_settings'],
                                                              style: GoogleFonts.notoSans(
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  color:
                                                                      buttonColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            )),
                                                        InkWell(
                                                            onTap: () async {
                                                              setState(() {
                                                                _locationDenied =
                                                                    false;
                                                                isLoading =
                                                                    true;
                                                              });

                                                              if (locationAllowed ==
                                                                  true) {
                                                                if (positionStream ==
                                                                        null ||
                                                                    positionStream!
                                                                        .isPaused) {
                                                                  positionStreamData();
                                                                }
                                                              }
                                                            },
                                                            child: Text(
                                                              languages[
                                                                      choosenLanguage]
                                                                  ['text_done'],
                                                              style: GoogleFonts.notoSans(
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  color:
                                                                      buttonColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ))
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ))
                                      : Container(),

                                  //displaying address details for edit
                                  ((_chooseGoodsType == false &&
                                              userRequestData.isEmpty &&
                                              addressList.isNotEmpty &&
                                              choosenTransportType == 1) ||
                                          (dropConfirmed == false &&
                                              userRequestData.isEmpty))
                                      ? Positioned(
                                          bottom: 0,
                                          child: Container(
                                              width: media.width * 1,
                                              color: page,
                                              padding: EdgeInsets.all(
                                                  media.width * 0.05),
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    width: media.width * 0.9,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                            languages[choosenLanguage]
                                                                [
                                                                'text_confirm_details'],
                                                            style: GoogleFonts.notoSans(
                                                                fontSize: media
                                                                        .width *
                                                                    sixteen,
                                                                color:
                                                                    textColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                        (addressList.length <
                                                                    5 &&
                                                                widget.type !=
                                                                    1)
                                                            ? InkWell(
                                                                onTap:
                                                                    () async {
                                                                  var nav = await Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => DropLocation(
                                                                                from: 'add stop',
                                                                              )));
                                                                  if (nav) {
                                                                    setState(
                                                                        () {});
                                                                    Future.delayed(
                                                                        const Duration(
                                                                            milliseconds:
                                                                                500),
                                                                        () {
                                                                      addPickDropMarker();
                                                                    });
                                                                  }
                                                                },
                                                                child: Text(
                                                                    languages[choosenLanguage]
                                                                            [
                                                                            'text_add_stop'] +
                                                                        ' +',
                                                                    style: GoogleFonts.notoSans(
                                                                        fontSize:
                                                                            media.width *
                                                                                sixteen,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w600,
                                                                        color:
                                                                            buttonColor)),
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: media.width * 0.025,
                                                  ),
                                                  InkWell(
                                                    onTap: () async {
                                                      var nav =
                                                          await Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          DropLocation(
                                                                            from:
                                                                                0,
                                                                          )));
                                                      if (nav) {
                                                        setState(() {});
                                                        Future.delayed(
                                                            const Duration(
                                                                milliseconds:
                                                                    500), () {
                                                          addPickDropMarker();
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      margin: EdgeInsets.only(
                                                          bottom: media.width *
                                                              0.025),
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              media.width *
                                                                  0.03,
                                                              media.width *
                                                                  0.02,
                                                              media.width *
                                                                  0.03,
                                                              media.width *
                                                                  0.02),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors.grey,
                                                            width: 1.5,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      media.width *
                                                                          0.02),
                                                          color: page),
                                                      alignment:
                                                          Alignment.center,
                                                      height: media.width * 0.1,
                                                      width: media.width * 0.9,
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            height:
                                                                media.width *
                                                                    0.025,
                                                            width: media.width *
                                                                0.025,
                                                            alignment: Alignment
                                                                .center,
                                                            decoration: BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: const Color(
                                                                        0xff319900)
                                                                    .withOpacity(
                                                                        0.3)),
                                                            child: Container(
                                                              height:
                                                                  media.width *
                                                                      0.01,
                                                              width:
                                                                  media.width *
                                                                      0.01,
                                                              decoration: const BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: Color(
                                                                      0xff319900)),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: media.width *
                                                                0.05,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              addressList[0]
                                                                  .address
                                                                  .toString(),
                                                              style: GoogleFonts.notoSans(
                                                                  color:
                                                                      textColor,
                                                                  fontSize: media
                                                                          .width *
                                                                      twelve),
                                                              maxLines: 1,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: media.width *
                                                                0.02,
                                                          ),
                                                          SizedBox(
                                                              height:
                                                                  media.width *
                                                                      0.07,
                                                              child: Icon(
                                                                Icons.edit,
                                                                color:
                                                                    textColor,
                                                                size: media
                                                                        .width *
                                                                    0.05,
                                                              ))
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: (addressList
                                                                .length <=
                                                            4)
                                                        ? media.width *
                                                            0.125 *
                                                            (addressList
                                                                    .length -
                                                                1)
                                                        : media.width *
                                                            0.125 *
                                                            4,
                                                    child: ReorderableListView(
                                                        onReorder: (oldIndex,
                                                            newIndex) {
                                                          if (newIndex <
                                                              oldIndex) {
                                                            var val1 =
                                                                addressList[
                                                                    oldIndex]; //1
                                                            var id1 =
                                                                addressList[
                                                                        oldIndex]
                                                                    .id;
                                                            var val2 =
                                                                addressList[
                                                                    oldIndex -
                                                                        1]; //2
                                                            var id2 = addressList[
                                                                    oldIndex -
                                                                        1]
                                                                .id;

                                                            addressList[
                                                                    oldIndex] =
                                                                val2; //2
                                                            addressList[
                                                                    oldIndex]
                                                                .id = id1; //1
                                                            addressList[
                                                                    oldIndex -
                                                                        1] =
                                                                val1; //1
                                                            addressList[
                                                                    oldIndex -
                                                                        1]
                                                                .id = id2; //2
                                                            // GetMapData().addressMarkers(context);
                                                          } else if (newIndex >
                                                              oldIndex) {
                                                            // var newIndexEdit =
                                                            //     addressList
                                                            //             .length -
                                                            //         1;

                                                            var val1 =
                                                                addressList[
                                                                    oldIndex +
                                                                        1]; //1
                                                            var id1 = addressList[
                                                                    oldIndex +
                                                                        1]
                                                                .id;
                                                            var val2 =
                                                                addressList[
                                                                    oldIndex]; //2
                                                            var id2 =
                                                                addressList[
                                                                        oldIndex]
                                                                    .id;
                                                            addressList[
                                                                    oldIndex +
                                                                        1] =
                                                                val2; //2
                                                            addressList[
                                                                    oldIndex +
                                                                        1]
                                                                .id = id1; //1
                                                            addressList[
                                                                    oldIndex] =
                                                                val1; //1
                                                            addressList[
                                                                    oldIndex]
                                                                .id = id2; //2
                                                            // GetMapData().addressMarkers(context);
                                                          }

                                                          setState(() {
                                                            addPickDropMarker();
                                                          });
                                                        },
                                                        children: addressList
                                                            .asMap()
                                                            .map((i, value) {
                                                              return MapEntry(
                                                                i,
                                                                (i != 0)
                                                                    ? Column(
                                                                        key: ValueKey(
                                                                            i),
                                                                        children: [
                                                                          Container(
                                                                            key:
                                                                                ValueKey(i),
                                                                            alignment:
                                                                                Alignment.center,
                                                                            height:
                                                                                media.width * 0.1,
                                                                            color:
                                                                                page,
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                              children: [
                                                                                InkWell(
                                                                                  onTap: () async {
                                                                                    var val = await Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                            builder: (context) => DropLocation(
                                                                                                  from: i,
                                                                                                )));
                                                                                    if (val) {
                                                                                      setState(() {});
                                                                                      Future.delayed(const Duration(milliseconds: 500), () {
                                                                                        addPickDropMarker();
                                                                                      });
                                                                                    }
                                                                                  },
                                                                                  child: Container(
                                                                                    padding: EdgeInsets.fromLTRB(media.width * 0.03, media.width * 0.02, media.width * 0.03, media.width * 0.02),
                                                                                    decoration: BoxDecoration(
                                                                                        border: Border.all(
                                                                                          color: Colors.grey,
                                                                                          width: 1.5,
                                                                                        ),
                                                                                        borderRadius: BorderRadius.circular(media.width * 0.02),
                                                                                        color: page),
                                                                                    alignment: Alignment.center,
                                                                                    height: media.width * 0.1,
                                                                                    width: (addressList.length > 2) ? media.width * 0.8 : media.width * 0.9,
                                                                                    child: Row(
                                                                                      children: [
                                                                                        Container(
                                                                                          height: media.width * 0.025,
                                                                                          width: media.width * 0.025,
                                                                                          alignment: Alignment.center,
                                                                                          decoration: BoxDecoration(shape: BoxShape.circle, color: (i == 0) ? const Color(0xff319900).withOpacity(0.3) : const Color(0xffFF0000).withOpacity(0.3)),
                                                                                          child: Container(
                                                                                            height: media.width * 0.01,
                                                                                            width: media.width * 0.01,
                                                                                            decoration: BoxDecoration(shape: BoxShape.circle, color: (i == 0) ? const Color(0xff319900) : const Color(0xffFF0000)),
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: media.width * 0.05,
                                                                                        ),
                                                                                        Expanded(
                                                                                          child: Text(
                                                                                            addressList[i].address.toString(),
                                                                                            style: GoogleFonts.notoSans(
                                                                                              fontSize: media.width * twelve,
                                                                                              color: textColor,
                                                                                            ),
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                          ),
                                                                                        ),
                                                                                        SizedBox(
                                                                                          width: media.width * 0.02,
                                                                                        ),
                                                                                        SizedBox(
                                                                                            height: media.width * 0.07,
                                                                                            child: (addressList.length > 2)
                                                                                                ? Icon(
                                                                                                    Icons.move_down_rounded,
                                                                                                    size: media.width * 0.05,
                                                                                                    color: textColor,
                                                                                                  )
                                                                                                : Icon(
                                                                                                    Icons.edit,
                                                                                                    color: textColor,
                                                                                                    size: media.width * 0.05,
                                                                                                  ))
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                (addressList.length > 2)
                                                                                    ? InkWell(
                                                                                        onTap: () {
                                                                                          setState(() {
                                                                                            addressList.removeAt(i);
                                                                                            myMarker.removeWhere((element) => element.markerId.toString().contains('car') != true);
                                                                                            addPickDropMarker();
                                                                                          });
                                                                                        },
                                                                                        child: Icon(
                                                                                          Icons.delete,
                                                                                          size: media.width * 0.07,
                                                                                          color: textColor,
                                                                                        ))
                                                                                    : Container()
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            height:
                                                                                media.width * 0.02,
                                                                            color:
                                                                                page,
                                                                          )
                                                                        ],
                                                                      )
                                                                    : Container(
                                                                        key: ValueKey(
                                                                            addressList[i].id),
                                                                      ),
                                                              );
                                                            })
                                                            .values
                                                            .toList()),
                                                  ),
                                                  Button(
                                                      onTap: () async {
                                                        choosePets = false;
                                                        chooseLuggages = false;
                                                        setState(() {
                                                          isLoading = true;
                                                          dropStopList.clear();
                                                          if (addressList
                                                                  .length >
                                                              2) {
                                                            for (var i = 1;
                                                                i <
                                                                    addressList
                                                                        .length;
                                                                i++) {
                                                              dropStopList.add(DropStops(
                                                                  order: i
                                                                      .toString(),
                                                                  latitude:
                                                                      addressList[i]
                                                                          .latlng
                                                                          .latitude,
                                                                  longitude:
                                                                      addressList[i]
                                                                          .latlng
                                                                          .longitude,
                                                                  pocName:
                                                                      addressList[i]
                                                                          .name
                                                                          .toString(),
                                                                  pocNumber:
                                                                      addressList[i]
                                                                          .number
                                                                          .toString(),
                                                                  pocInstruction: (addressList[i]
                                                                              .instructions !=
                                                                          null)
                                                                      ? addressList[
                                                                              i]
                                                                          .instructions
                                                                      : null,
                                                                  address: addressList[
                                                                          i]
                                                                      .address
                                                                      .toString()));
                                                            }
                                                          }
                                                        });

                                                        if (widget.type != 1) {
                                                          var val =
                                                              await etaRequest();
                                                          if (val == 'logout') {
                                                            navigateLogout();
                                                          }
                                                        } else {
                                                          var val =
                                                              await rentalEta();
                                                          if (val == 'logout') {
                                                            navigateLogout();
                                                          }
                                                        }
                                                        if (choosenTransportType ==
                                                            0) {
                                                          setState(() {
                                                            dropConfirmed =
                                                                true;
                                                            isLoading = false;
                                                          });
                                                        } else {
                                                          setState(() {
                                                            dropConfirmed =
                                                                true;
                                                            selectedGoodsId =
                                                                '';
                                                            _chooseGoodsType =
                                                                true;
                                                            isLoading = false;
                                                          });
                                                        }
                                                      },
                                                      text: languages[
                                                              choosenLanguage]
                                                          ['text_confirm'])
                                                ],
                                              )),
                                        )
                                      : Container(),

                                  //edit pick user contact

                                  (_editUserDetails == true)
                                      ? Positioned(
                                          child: Scaffold(
                                          backgroundColor: Colors.transparent,
                                          body: Container(
                                            height: media.height * 1,
                                            width: media.width * 1,
                                            color: Colors.transparent
                                                .withOpacity(0.6),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
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
                                                            _editUserDetails =
                                                                false;
                                                          });
                                                        },
                                                        child: Container(
                                                          height:
                                                              media.width * 0.1,
                                                          width:
                                                              media.width * 0.1,
                                                          decoration:
                                                              BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  color: page),
                                                          child: Icon(
                                                              Icons
                                                                  .cancel_outlined,
                                                              color: textColor),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                    height: media.width * 0.05),
                                                Container(
                                                  color: page,
                                                  width: media.width * 1,
                                                  padding: EdgeInsets.all(
                                                      media.width * 0.05),
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        width:
                                                            media.width * 0.9,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              languages[
                                                                      choosenLanguage]
                                                                  [
                                                                  'text_give_user_data'],
                                                              style: GoogleFonts.notoSans(
                                                                  color:
                                                                      textColor,
                                                                  fontSize: media
                                                                          .width *
                                                                      sixteen,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                            InkWell(
                                                                onTap:
                                                                    () async {
                                                                  var nav = await Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              const PickContact(from: '1')));
                                                                  if (nav) {
                                                                    setState(
                                                                        () {
                                                                      pickerName
                                                                              .text =
                                                                          pickedName;
                                                                      pickerNumber
                                                                              .text =
                                                                          pickedNumber;
                                                                    });
                                                                  }
                                                                },
                                                                child: Icon(
                                                                    Icons
                                                                        .contact_page_rounded,
                                                                    color:
                                                                        textColor))
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            media.width * 0.025,
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets.fromLTRB(
                                                            media.width * 0.03,
                                                            (languageDirection ==
                                                                    'rtl')
                                                                ? media.width *
                                                                    0.04
                                                                : 0,
                                                            media.width * 0.03,
                                                            media.width * 0.01),
                                                        height:
                                                            media.width * 0.1,
                                                        width:
                                                            media.width * 0.9,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 1.5,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        media.width *
                                                                            0.02),
                                                                color: page),
                                                        child: TextField(
                                                          controller:
                                                              pickerName,
                                                          decoration:
                                                              InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            hintText: languages[
                                                                    choosenLanguage]
                                                                ['text_name'],
                                                            hintStyle:
                                                                GoogleFonts
                                                                    .notoSans(
                                                              fontSize:
                                                                  media.width *
                                                                      twelve,
                                                              color: textColor
                                                                  .withOpacity(
                                                                      0.4),
                                                            ),
                                                          ),
                                                          textAlignVertical:
                                                              TextAlignVertical
                                                                  .center,
                                                          style: GoogleFonts
                                                              .notoSans(
                                                                  color:
                                                                      textColor,
                                                                  fontSize: media
                                                                          .width *
                                                                      twelve),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            media.width * 0.025,
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets.fromLTRB(
                                                            media.width * 0.03,
                                                            (languageDirection ==
                                                                    'rtl')
                                                                ? media.width *
                                                                    0.04
                                                                : 0,
                                                            media.width * 0.03,
                                                            media.width * 0.01),
                                                        height:
                                                            media.width * 0.1,
                                                        width:
                                                            media.width * 0.9,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 1.5,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        media.width *
                                                                            0.02),
                                                                color: page),
                                                        child: TextField(
                                                          controller:
                                                              pickerNumber,
                                                          keyboardType:
                                                              TextInputType
                                                                  .number,
                                                          decoration:
                                                              InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            counterText: '',
                                                            hintText: languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_givenumber'],
                                                            hintStyle: GoogleFonts.notoSans(
                                                                color: textColor
                                                                    .withOpacity(
                                                                        0.4),
                                                                fontSize: media
                                                                        .width *
                                                                    twelve),
                                                          ),
                                                          maxLength: 20,
                                                          textAlignVertical:
                                                              TextAlignVertical
                                                                  .center,
                                                          style: GoogleFonts
                                                              .notoSans(
                                                                  color:
                                                                      textColor,
                                                                  fontSize: media
                                                                          .width *
                                                                      twelve),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            media.width * 0.025,
                                                      ),
                                                      Container(
                                                        padding: EdgeInsets.fromLTRB(
                                                            media.width * 0.03,
                                                            (languageDirection ==
                                                                    'rtl')
                                                                ? media.width *
                                                                    0.04
                                                                : 0,
                                                            media.width * 0.03,
                                                            media.width * 0.01),
                                                        // height: media.width * 0.1,
                                                        width:
                                                            media.width * 0.9,
                                                        alignment:
                                                            Alignment.center,
                                                        decoration:
                                                            BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: 1.5,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        media.width *
                                                                            0.02),
                                                                color: page),
                                                        child: TextField(
                                                          controller:
                                                              instructions,
                                                          decoration:
                                                              InputDecoration(
                                                            border: InputBorder
                                                                .none,
                                                            counterText: '',
                                                            hintText: languages[
                                                                    choosenLanguage]
                                                                [
                                                                'text_instructions'],
                                                            hintStyle: GoogleFonts.notoSans(
                                                                color: textColor
                                                                    .withOpacity(
                                                                        0.4),
                                                                fontSize: media
                                                                        .width *
                                                                    twelve),
                                                          ),
                                                          textAlignVertical:
                                                              TextAlignVertical
                                                                  .center,
                                                          style: GoogleFonts
                                                              .notoSans(
                                                                  color:
                                                                      textColor,
                                                                  fontSize: media
                                                                          .width *
                                                                      twelve),
                                                          maxLines: 4,
                                                          minLines: 2,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            media.width * 0.03,
                                                      ),
                                                      Button(
                                                          onTap: () async {
                                                            setState(() {
                                                              addressList[0]
                                                                      .name =
                                                                  pickerName
                                                                      .text;
                                                              addressList[0]
                                                                      .number =
                                                                  pickerNumber
                                                                      .text;
                                                              addressList[0]
                                                                      .instructions =
                                                                  (instructions
                                                                          .text
                                                                          .isNotEmpty)
                                                                      ? instructions
                                                                          .text
                                                                      : null;
                                                              _editUserDetails =
                                                                  false;
                                                            });
                                                          },
                                                          text: languages[
                                                                  choosenLanguage]
                                                              ['text_confirm'])
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ))
                                      : Container(),

                                  if (_cancel == true)
                                    Positioned(
                                        child: Container(
                                      height: media.height * 1,
                                      width: media.width * 1,
                                      color:
                                          Colors.transparent.withOpacity(0.2),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: media.width * 0.9,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
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
                                                            _cancel = false;
                                                          });
                                                        },
                                                        child: const Icon(Icons
                                                            .cancel_outlined))),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.all(
                                                media.width * 0.05),
                                            width: media.width * 0.9,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: page),
                                            child: Column(
                                              children: [
                                                Text(
                                                  languages[choosenLanguage][
                                                      'text_cancel_confirmation'],
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.notoSans(
                                                      fontSize:
                                                          media.width * sixteen,
                                                      color: textColor,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                                SizedBox(
                                                  height: media.width * 0.05,
                                                ),
                                                Button(
                                                    onTap: () async {
                                                      setState(() {
                                                        isLoading = true;
                                                      });
                                                      var val =
                                                          await cancelRequest();
                                                      updateAmount.clear();

                                                      if (val == 'logout') {
                                                        navigateLogout();
                                                        setState(() {
                                                          // yourAmount.clear();
                                                        });
                                                      }
                                                      setState(() {
                                                        isLoading = false;
                                                        _cancel = false;
                                                      });
                                                    },
                                                    text: languages[
                                                            choosenLanguage]
                                                        ['text_confirm'])
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    )),

                                  //driver cancelled request
                                  (requestCancelledByDriver == true)
                                      ? Positioned(
                                          top: 0,
                                          child: Container(
                                            height: media.height * 1,
                                            width: media.width * 1,
                                            color: Colors.transparent
                                                .withOpacity(0.6),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                  width: media.width * 0.9,
                                                  padding: EdgeInsets.all(
                                                      media.width * 0.05),
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      color: page),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        languages[
                                                                choosenLanguage]
                                                            [
                                                            'text_drivercancelled'],
                                                        style: GoogleFonts
                                                            .notoSans(
                                                                fontSize: media
                                                                        .width *
                                                                    fourteen,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    textColor),
                                                      ),
                                                      SizedBox(
                                                        height:
                                                            media.width * 0.05,
                                                      ),
                                                      Button(
                                                          onTap: () {
                                                            setState(() {
                                                              requestCancelledByDriver =
                                                                  false;
                                                              if (userRequestData[
                                                                          'is_bid_ride']
                                                                      .toString() ==
                                                                  '1') {
                                                                userRequestData =
                                                                    {};
                                                              }
                                                            });
                                                          },
                                                          text: languages[
                                                                  choosenLanguage]
                                                              ['text_ok'])
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ))
                                      : Container(),

                                  //loader
                                  (isLoading == true)
                                      ? const Positioned(
                                          top: 0, child: Loading())
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

                                  //pick drop marker
                                  Positioned(
                                    top: media.height * 1.6,
                                    child: RepaintBoundary(
                                        key: iconKey,
                                        child: Column(
                                          children: [
                                            Container(
                                                decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        colors: [
                                                          (isDarkTheme == true)
                                                              ? const Color(
                                                                  0xff000000)
                                                              : const Color(
                                                                  0xffFFFFFF),
                                                          (isDarkTheme == true)
                                                              ? const Color(
                                                                  0xff808080)
                                                              : const Color(
                                                                  0xffEFEFEF),
                                                        ],
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5)),
                                                width: (platform ==
                                                        TargetPlatform.android)
                                                    ? media.width * 0.4
                                                    : media.width * 0.5,
                                                padding:
                                                    const EdgeInsets.all(5),
                                                child: (userRequestData
                                                        .isNotEmpty)
                                                    ? Text(
                                                        userRequestData[
                                                            'pick_address'],
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.fade,
                                                        softWrap: false,
                                                        style: GoogleFonts.notoSans(
                                                            color: textColor,
                                                            fontSize: (platform ==
                                                                    TargetPlatform
                                                                        .android)
                                                                ? media.width *
                                                                    twelve
                                                                : media.width *
                                                                    sixteen),
                                                      )
                                                    : (addressList
                                                            .where((element) =>
                                                                element.type ==
                                                                'pickup')
                                                            .isNotEmpty)
                                                        ? Text(
                                                            addressList
                                                                .firstWhere(
                                                                    (element) =>
                                                                        element
                                                                            .type ==
                                                                        'pickup')
                                                                .address,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .fade,
                                                            softWrap: false,
                                                            style: GoogleFonts.notoSans(
                                                                color:
                                                                    textColor,
                                                                fontSize: (platform ==
                                                                        TargetPlatform
                                                                            .android)
                                                                    ? media.width *
                                                                        twelve
                                                                    : media.width *
                                                                        sixteen),
                                                          )
                                                        : Container()),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Container(
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  image: DecorationImage(
                                                      image: AssetImage(
                                                          'assets/images/pick_icon.png'),
                                                      fit: BoxFit.contain)),
                                              height: (platform ==
                                                      TargetPlatform.android)
                                                  ? media.width * 0.07
                                                  : media.width * 0.12,
                                              width: (platform ==
                                                      TargetPlatform.android)
                                                  ? media.width * 0.07
                                                  : media.width * 0.12,
                                            ),
                                          ],
                                        )),
                                  ),
                                  (widget.type != 1)
                                      ? Positioned(
                                          top: media.height * 2,
                                          child: Column(
                                            children: addressList
                                                .asMap()
                                                .map((i, value) {
                                                  iconDropKeys[i] = GlobalKey();
                                                  return MapEntry(
                                                    i,
                                                    (i > 0)
                                                        ? RepaintBoundary(
                                                            key:
                                                                iconDropKeys[i],
                                                            child: Column(
                                                              children: [
                                                                (i ==
                                                                        addressList.length -
                                                                            1)
                                                                    ? Column(
                                                                        children: [
                                                                          Container(
                                                                            decoration: BoxDecoration(
                                                                                gradient: LinearGradient(colors: [
                                                                                  (isDarkTheme == true) ? const Color(0xff000000) : const Color(0xffFFFFFF),
                                                                                  (isDarkTheme == true) ? const Color(0xff808080) : const Color(0xffEFEFEF),
                                                                                ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                                                                                borderRadius: BorderRadius.circular(5)),
                                                                            width: (platform == TargetPlatform.android)
                                                                                ? media.width * 0.5
                                                                                : media.width * 0.7,
                                                                            padding:
                                                                                const EdgeInsets.all(5),
                                                                            child: (addressList[i].address.isNotEmpty)
                                                                                ? Text(
                                                                                    addressList[i].address,
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.fade,
                                                                                    softWrap: false,
                                                                                    style: GoogleFonts.notoSans(fontSize: (platform == TargetPlatform.android) ? media.width * twelve : media.width * sixteen, color: textColor),
                                                                                  )
                                                                                : Container(),
                                                                          ),
                                                                          const SizedBox(
                                                                            height:
                                                                                10,
                                                                          ),
                                                                          Container(
                                                                            decoration:
                                                                                const BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: AssetImage('assets/images/drop_icon.png'), fit: BoxFit.contain)),
                                                                            height: (platform == TargetPlatform.android)
                                                                                ? media.width * 0.07
                                                                                : media.width * 0.12,
                                                                            width: (platform == TargetPlatform.android)
                                                                                ? media.width * 0.07
                                                                                : media.width * 0.12,
                                                                          ),
                                                                        ],
                                                                      )
                                                                    : Text(
                                                                        (i).toString(),
                                                                        style: GoogleFonts.notoSans(
                                                                            fontSize: media.width *
                                                                                sixteen,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                            color: Colors.red),
                                                                      ),
                                                              ],
                                                            ))
                                                        : Container(),
                                                  );
                                                })
                                                .values
                                                .toList(),
                                          ))
                                      : Container(),

                                  (widget.type != 1)
                                      ? Positioned(
                                          top: media.height * 2,
                                          child: RepaintBoundary(
                                              key: iconDistanceKey,
                                              child: Stack(
                                                children: [
                                                  Icon(Icons.chat_bubble,
                                                      size: media.width * 0.2,
                                                      color: page,
                                                      shadows: [
                                                        BoxShadow(
                                                            spreadRadius: 2,
                                                            blurRadius: 2,
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.2))
                                                      ]),
                                                  if (etaDetails.isNotEmpty)
                                                    if (etaDetails[0]
                                                            ['distance'] !=
                                                        null)
                                                      Positioned(
                                                          left: media.width *
                                                              0.03,
                                                          top: media.width *
                                                              0.03,
                                                          child: Container(
                                                              width:
                                                                  media.width *
                                                                      0.14,
                                                              height:
                                                                  media.width *
                                                                      0.1,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              child: Text(
                                                                "${etaDetails[0]['distance'].toString()} ${etaDetails[0]['unit_in_words'].toString()} ",
                                                                style: GoogleFonts.notoSans(
                                                                    fontSize: media
                                                                            .width *
                                                                        twelve,
                                                                    color:
                                                                        textColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600),
                                                              )))
                                                ],
                                              )),
                                        )
                                      : Container()
                                ],
                              );
                            });
                      });
                }),
          ),
        ),
      ),
    );
  }

  double getBearing(LatLng begin, LatLng end) {
    double lat = (begin.latitude - end.latitude).abs();

    double lng = (begin.longitude - end.longitude).abs();

    if (begin.latitude < end.latitude && begin.longitude < end.longitude) {
      return vector.degrees(atan(lng / lat));
    } else if (begin.latitude >= end.latitude &&
        begin.longitude < end.longitude) {
      return (90 - vector.degrees(atan(lng / lat))) + 90;
    } else if (begin.latitude >= end.latitude &&
        begin.longitude >= end.longitude) {
      return vector.degrees(atan(lng / lat)) + 180;
    } else if (begin.latitude < end.latitude &&
        begin.longitude >= end.longitude) {
      return (90 - vector.degrees(atan(lng / lat))) + 270;
    }

    return -1;
  }

  animateCar(
      double fromLat, //Starting latitude

      double fromLong, //Starting longitude

      double toLat, //Ending latitude

      double toLong, //Ending longitude

      StreamSink<List<Marker>>
          mapMarkerSink, //Stream build of map to update the UI

      TickerProvider
          provider, //Ticker provider of the widget. This is used for animation

      // GoogleMapController controller, //Google map controller of our widget

      markerid,
      markerBearing,
      icon) async {
    final double bearing =
        getBearing(LatLng(fromLat, fromLong), LatLng(toLat, toLong));

    myBearings[markerBearing.toString()] = bearing;

    var carMarker = Marker(
        markerId: MarkerId(markerid),
        position: LatLng(fromLat, fromLong),
        icon: icon,
        anchor: const Offset(0.5, 0.5),
        flat: true,
        draggable: false);

    myMarker.add(carMarker);

    mapMarkerSink.add(Set<Marker>.from(myMarker).toList());

    Tween<double> tween = Tween(begin: 0, end: 1);

    _animation = tween.animate(animationController)
      ..addListener(() async {
        myMarker
            .removeWhere((element) => element.markerId == MarkerId(markerid));

        final v = _animation!.value;

        double lng = v * toLong + (1 - v) * fromLong;

        double lat = v * toLat + (1 - v) * fromLat;

        LatLng newPos = LatLng(lat, lng);

        //New marker location

        carMarker = Marker(
            markerId: MarkerId(markerid),
            position: newPos,
            icon: icon,
            anchor: const Offset(0.5, 0.5),
            flat: true,
            rotation: bearing,
            draggable: false);

        //Adding new marker to our list and updating the google map UI.

        myMarker.add(carMarker);

        mapMarkerSink.add(Set<Marker>.from(myMarker).toList());
        if (userRequestData.isNotEmpty &&
            userRequestData['accepted_at'] != null) {
          if (mapType == 'google') {
            LatLngBounds l2 = await _controller.getVisibleRegion();
            if (l2.contains(newPos)) {
            } else {
              _controller
                  ?.animateCamera(CameraUpdate.newLatLngZoom(newPos, 18.0));
            }
          } else {
            _fmController.move(
                fmlt.LatLng(newPos.latitude, newPos.longitude), 16);
          }
        }
        mapMarkerSink.add(Set<Marker>.from(myMarker).toList());
      });
    //Starting the animation

    animationController.forward();
  }
}

List decodeEncodedPolyline(String encoded) {
  // List poly = [];
  int index = 0, len = encoded.length;
  int lat = 0, lng = 0;

  while (index < len) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lat += dlat;

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
    lng += dlng;
    LatLng p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
    fmpoly.add(
      fmlt.LatLng(p.latitude, p.longitude),
    );
  }

  // valueNotifierBook.incrementNotifier();
  return fmpoly;
}
