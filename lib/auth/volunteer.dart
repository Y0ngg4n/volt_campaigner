import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:volt_campaigner/utils/api/auth.dart';
import 'package:volt_campaigner/utils/messenger.dart';
import 'package:volt_campaigner/utils/screen_utils.dart';
import 'package:volt_campaigner/utils/shared_prefs_slugs.dart';

import '../drawer.dart';

class VolunteerLogin extends StatefulWidget {
  const VolunteerLogin({Key? key}) : super(key: key);

  @override
  _VolunteerLoginState createState() => _VolunteerLoginState();
}

class _VolunteerLoginState extends State<VolunteerLogin> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  final TextEditingController dataController = new TextEditingController();
  late SharedPreferences prefs;
  bool scan = false;
  String? apiToken;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((value) => setState(() {
          prefs = value;
          apiToken = prefs.getString(SharedPrefsSlugs.restApiToken);
          if (apiToken != null) {
            print("Api TOken is not null");
            _goToDrawer(apiToken!);
          }
        }));
  }

  _pasteSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.pasteSuccess),
        backgroundColor: Colors.green));
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  _goToDrawer(String apiToken) async {
    if (await AuthApiUtils.validate(apiToken)) {
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => DrawerView(
                      apiToken: apiToken,
                      displayName: null,
                      emailAddress: null,
                      photoUrl: null,
                    )),
            (route) => false);
      });
    } else {
      Messenger.showError(context, AppLocalizations.of(context)!.invalidToken);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(children: [
          Column(
            children: <Widget>[
              Expanded(
                flex: 5,
                child: scan
                    ? _buildQrView(context)
                    : ElevatedButton(
                        onPressed: () {
                          setState(() {
                            this.scan = true;
                          });
                        },
                        child: Text("Start Scan")),
              ),
              Expanded(
                flex: 1,
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(AppLocalizations.of(context)!.scanCodeVolunteer),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: dataController,
                          readOnly: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            floatingLabelBehavior: FloatingLabelBehavior.always,
                            labelText:
                                AppLocalizations.of(context)!.orEnterCode,
                            suffixIcon: IconButton(
                                icon: Icon(Icons.content_copy),
                                onPressed: () async {
                                  ClipboardData? clipboardData =
                                      await Clipboard.getData("text/plain");
                                  if (clipboardData != null &&
                                      clipboardData.text != null) {
                                    setState(() {
                                      dataController.text = clipboardData.text!;
                                      _pasteSuccess();
                                    });
                                  }
                                }),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
              )
            ],
          ),
          Positioned(
            top: 20,
            left: 20,
            child: FloatingActionButton(
              heroTag: "Flash-FAB",
              child: Icon(Icons.flash_auto),
              onPressed: () {
                if (controller != null) {
                  controller!.toggleFlash();
                }
              },
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              heroTag: "Flip-Camera-FAB",
              child: Icon(Icons.flip_camera_android),
              onPressed: () {
                if (controller != null) {
                  controller!.flipCamera();
                }
              },
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = ScreenUtils.getScreenWidth(context) <
            ScreenUtils.getScreenHeight(context)
        ? ScreenUtils.getScreenWidth(context) - 40
        : ScreenUtils.getScreenHeight(context) - 40;

    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        dataController.text = scanData.code;
        prefs.setString(SharedPrefsSlugs.restApiToken, scanData.code);
        _goToDrawer(scanData.code);
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
