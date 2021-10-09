import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:volt_campaigner/utils/api/auth.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class VolunteerView extends StatefulWidget {
  String apiToken;

  VolunteerView({Key? key, required this.apiToken}) : super(key: key);

  @override
  _VolunteerViewState createState() => _VolunteerViewState();
}

class _VolunteerViewState extends State<VolunteerView> {
  String? volunterToken;
  final TextEditingController dataController = new TextEditingController();

  _copySuccess() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(AppLocalizations.of(context)!.copySuccess),
        backgroundColor: Colors.green));
  }

  @override
  void initState() {
    super.initState();
    AuthApiUtils.getVolunteerToken(widget.apiToken).then((value) => {
          setState(() {
            this.volunterToken = value;
            if (value != null) dataController.text = value;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            AppLocalizations.of(context)!.scanThisVolunteer,
            style: TextStyle(fontSize: 20),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              volunterToken == null
                  ? CircularProgressIndicator()
                  : QrImage(
                      size: 300,
                      data: volunterToken!,
                      version: QrVersions.auto,
                    ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextFormField(
              controller: dataController,
              readOnly: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                labelText: AppLocalizations.of(context)!.volunteerCopy,
                suffixIcon: IconButton(
                    icon: Icon(Icons.content_copy),
                    onPressed: () {
                      Clipboard.setData(
                          new ClipboardData(text: dataController.text));
                      _copySuccess();
                    }),
              )),
        )
      ],
    );
  }
}
