import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'webrtc_signaling.dart';
import '../pages/displayDataPage.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import '../../Widget/datetime_picker_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> WebrtcRoom1() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(WebrtcRoom2());
}

class WebrtcRoom2 extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WebrtcRoom(),
    );
  }
}

class WebrtcRoom extends StatefulWidget {
  WebrtcRoom({Key key}) : super(key: key);

  @override
  _WebrtcRoomState createState() => _WebrtcRoomState();
}

class _WebrtcRoomState extends State<WebrtcRoom> {
  WebrtcSignaling signaling = WebrtcSignaling();
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String roomId;
  TextEditingController textEditingController = TextEditingController(text: '');
  Timer _timer;

  TextEditingController _scheduledDateTimeController;
  String _scheduledDateTimeValueChanged = '';
  String _scheduledDateTimeValueToValidate = '';
  String _scheduledDateTimeValueSaved = '';

  var VCHandled1;
  var VCHandled2;
  var loggedIn1;
  var loggedIn2;
  var inCall1;
  var inCall2;
  bool passed = false;

  @override
  void initState() {
    FirebaseFirestore db = FirebaseFirestore.instance;
    Intl.defaultLocale = 'pt_BR';
    _scheduledDateTimeController = TextEditingController(text: DateTime.now().toString());
    //_getDefaultDateTimeValue();

    // _localRenderer.initialize();
    // _remoteRenderer.initialize();
    initRenderers();

    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    // auto open camera & mic
    signaling.openUserMedia(_localRenderer, _remoteRenderer).whenComplete(() {
      // var agent1Active = db.collection('isActive').doc('agent1').get();
      // var agent2Active = db.collection('isActive').doc('agent2').get();
      // var handle1;
      // var login1;
      // var call1;
      // var handle2;
      // var login2;
      // var call2;
      //
      // agent1Active.then((doc){
      //     var jsonData = jsonEncode(doc.data());
      //     var parsedJson = jsonDecode(jsonData);
      //     handle1 = parsedJson['VCHandled'];
      //     login1 = parsedJson['loggedIn'];
      //     call1 = parsedJson['inCall'];
      //     // print('a1 >>>>>' + VCHandled1.toString() + loggedIn1.toString() + inCall1.toString());
      // });
      //
      // agent2Active.then((doc){
      //     var jsonData = jsonEncode(doc.data());
      //     var parsedJson = jsonDecode(jsonData);
      //     handle2 = parsedJson['VCHandled'];
      //     login2 = parsedJson['loggedIn'];
      //     call2 = parsedJson['inCall'];
      //     // print('a2 state >>>>> ' + VCHandled2.toString() + loggedIn2.toString() + inCall2.toString());
      // });
      // setState(() {
      //   VCHandled1 = handle1;
      //   VCHandled2 = handle2;
      //   loggedIn1 = login1;
      //   loggedIn2 = login2;
      //   inCall1 = call1;
      //   inCall2 = call2;
      //   passed = true;
      // });
    } );

    signaling.createRoom(_remoteRenderer, db).then((data) {
      _timer = new Timer(const Duration(seconds: 3), (){
        setState(() {
          roomId=data;
        });
      });
    });

    // _timer = new Timer(const Duration(seconds: 3), () {
    //   setState(() {
    //     signaling.createRoom(_remoteRenderer).then((data) {
    //       roomId=data;
    //     });
    //   });
    // });
    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    super.dispose();
  }

  void initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  Future<void> _getDefaultDateTimeValue() async {
    await Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        //_initialValue = '2000-10-22 14:30';
        _scheduledDateTimeController.text = '2001-10-21 15:31';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Call with Agent"),
      ),
      body:
      (_remoteRenderer.srcObject==null)?
      Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 280),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation <Color> (Colors.blue)
                ),
              ],
            ),
            SizedBox(height: 160),
            Text("Connecting you to our agent"),
            Text("Please wait.."),
            SizedBox(height: 20),
            //       Text("or"),
            //       SizedBox(height: 20),
            //       Text("Do you want us to contact you at another time?"),
            //       RaisedButton(
            //         onPressed: () {
            //   // Navigator.push(
            //   //     context, MaterialPageRoute(builder: (context) => NodefluxOcrKtpResultPage()));
            //           Navigator.pop(context);
            // },
            //         child: Text(
            //             'Go back to choose another time',
            //             style: TextStyle(color: Colors.white, fontSize: 20)),
            //         color: Colors.orange,
            //       ),
            //showCalendarScheduleButton(),
            //DatetimePickerWidget(),
            // DateTimePicker(
            //   type: DateTimePickerType.dateTime,
            //   dateMask: 'd MMMM yyyy - hh:mm',
            //   controller: _scheduledDateTimeController,
            //   //initialValue: _initialValue,
            //   firstDate: DateTime(2000),
            //   lastDate: DateTime(2100),
            //   //icon: Icon(Icons.event),
            //   dateLabelText: 'Date Time',
            //   use24HourFormat: false,
            //   locale: Locale('en', 'US'),
            //   onChanged: (val) => setState(() => _scheduledDateTimeValueChanged = val),
            //   validator: (val) {
            //     setState(() => _scheduledDateTimeValueToValidate = val ?? '');
            //     return null;
            //   },
            //   onSaved: (val) => setState(() => _scheduledDateTimeValueSaved = val ?? ''),
            // ),
          ]
      )
          :
      Column(
        children: [
          //START
          // Expanded(
          //   child:
          //   Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Expanded(
          //             child:
          //         RTCVideoView(_localRenderer, mirror: true)
          //         ),
          //         Expanded(child: RTCVideoView(_remoteRenderer)),
          //       ],
          //     ),
          //
          //   ),
          // ),
          // END
          SizedBox(height: 178),
          Expanded(
            child:
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child:RTCVideoView(_localRenderer, mirror: true),
                  ),
                  Expanded(child: RTCVideoView(_remoteRenderer)),
                ],
              ),
            ),
          ),
          (_remoteRenderer.srcObject!=null)?Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Client Video                             "),
                    Text("Agent Video")]
              ),
            ],
          ):
          Container(),
          SizedBox(height: 148),
          Row (
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // START: Comment button hangup
              (_remoteRenderer.srcObject!=null)?
              ElevatedButton(
                onPressed: () {
                  signaling.hangUp(_localRenderer);
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => DisplayDataPage()));
                },
                //child: Text("Hangup"),
                child: Icon(Icons.call_end_rounded),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(CircleBorder()),
                  padding: MaterialStateProperty.all(EdgeInsets.all(20)),
                  backgroundColor: MaterialStateProperty.all(Colors.red), // <-- Button color
                  overlayColor: MaterialStateProperty.resolveWith<Color>((states) {
                    if (states.contains(MaterialState.pressed)) return Colors.red; // <-- Splash color
                  }),
                ),
              ):Container(),
              // END: Comment button hangup
            ],
          ),
          SizedBox(height: 8)
        ],
      ),
    );
  }

  Widget showCalendarScheduleButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.lightBlue,
            child: new Text(
              //'Ambil Foto Selfie',
                'Schedule Video Call',
                style: new TextStyle(fontSize: 12.0, color: Colors.white)),
            //onPressed: () { navigateToPage('Login Face');}
            onPressed: () {
              DateTimePicker(
                type: DateTimePickerType.dateTime,
                dateMask: 'd MMMM yyyy - hh:mm',
                controller: _scheduledDateTimeController,
                //initialValue: _initialValue,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                //icon: Icon(Icons.event),
                dateLabelText: 'Date Time',
                use24HourFormat: false,
                locale: Locale('en', 'US'),
                onChanged: (val) => setState(() => _scheduledDateTimeValueChanged = val),
                validator: (val) {
                  setState(() => _scheduledDateTimeValueToValidate = val ?? '');
                  return null;
                },
                onSaved: (val) => setState(() => _scheduledDateTimeValueSaved = val ?? ''),
              );
              //pop up calendar and time
            },
          ),
        ));
  }
}
