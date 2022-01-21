import 'package:flutter/material.dart';
import 'package:flutter_webrtc_demo/src/nodeflux/models/dukcapilFail.dart';
import 'package:flutter_webrtc_demo/src/nodeflux/models/dukcapilOngoing.dart';
import 'package:flutter_webrtc_demo/src/nodeflux/screens/coreBankingPageNTBS.dart';
import 'package:flutter_webrtc_demo/src/pages/congratulationPage.dart';
import 'package:flutter_webrtc_demo/src/pages/prepPage.dart';
import 'package:flutter_webrtc_demo/src/pages/welcomePage.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Widget/bezierContainer.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:email_validator/email_validator.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/nodeflux_data_model.dart';
import '../models/nodeflux_job_model.dart';
import '../models/nodeflux_result_model.dart';
import '../models/nodeflux_result2_model.dart';
import 'dart:convert';
import '../../webrtc_room/webrtc_room.dart';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import '../../../Widget/datetime_picker_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../models/livenessUnderqualified.dart';
import '../models/messageModel.dart';
import '../models/modelLivenessNathan.dart';
import '../models/face_pair_not_match.dart';
import '../models/no_face_detected.dart';
import '../models/dukcapilFaceMatch.dart';

class NodefluxOcrKtpResultPage extends StatefulWidget {
  final NodefluxResult2Model model;
  File ektpImage;
  // File _selfieImage;

  // NodefluxOcrKtpResultPage(this.model, this.ektpImage);

  NodefluxOcrKtpResultPage({Key key, @required this.ektpImage, this.model}) : super(key: key);

  @override
  _NodefluxOcrKtpResultPageState createState() => _NodefluxOcrKtpResultPageState();
}

class _NodefluxOcrKtpResultPageState extends State<NodefluxOcrKtpResultPage> {
  DateTime selectedbirthdate=null;
  File _imageFile;

  File ektpImage;
  File _selfieImage;
  File _npwpImage;
  File _selfieEktpImage;

  bool isEmail = false;

  TextEditingController nikController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController birthplaceController = TextEditingController();
  TextEditingController mobilePhoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController, genderController, rtrwController, kecamatanController, religionController, maritalStatusController, workfieldController, provinceController, expiryController,
      bloodTypeController, kabupatenKotaController, kelurahanDesaController, nationalityController;

  //firestore
  String firestoreId;
  final db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String firestoreName;
  String firestoreNik;
  String firestoreAddress;
  String firestoreBirthdate;
  String firestoreBirthplace;
  String firestoreGender;
  String firestoreRtRw;
  String firestoreKecamatan;
  String firestoreReligion;
  String firestoreMaritalStatus;
  String firestoreWorkfield;
  String firestoreProvince;
  String firestoreExpiry;
  String firestoreBloodType;
  String firestoreKabupatenKota;
  String firestoreKelurahanDesa;
  String firestoreNationality;
  String firestoreMobilePhone;
  String firestoreEmail;

  int minPhotoSize=256000; // 250KB
  int maxPhotoSize=512000; // 500KB

  String ocrNama, ocrNik, ocrTempatLahir, ocrTanggalLahir, ocrJenisKelamin, ocrAlamat, ocrRtrw, ocrKecamatan, ocrAgama, ocrStatusPerkawinan,
      ocrPekerjaan, ocrProvinsi, ocrBerlakuHingga, ocrGolonganDarah, ocrKabupatenKota, ocrKelurahanDesa, ocrKewarganegaraan;


  TextEditingController scheduledDateTimeController = new TextEditingController(text: 'Anonymous');
  DatetimePickerWidget datetimePickerWidget = DatetimePickerWidget();

  NodefluxResult2Model _nodefluxResult2Model = null;
  bool isLive;
  bool isMatched;
  bool nodefluxSelfie = false;
  double livenessValue;
  double similarityValue;
  String matchLivenessFeedback="";
  String message = '';
  bool noFace = false;
  bool underQualified = false;
  bool changeColor = false;
  String ktpDetected = '';
  Color textColorRed = Colors.red;
  String messageDukcapil = '';
  bool dukcapil = false;
  String selfieProcessed = '';
  String dukcapilStatus = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setup();
  }

  setup() {
    nikController= TextEditingController(text: widget.model.nik);
    nameController= TextEditingController(text: widget.model.nama);
    birthdateController= TextEditingController(text: widget.model.tanggal_lahir);
    birthplaceController= TextEditingController(text: widget.model.tempat_lahir);
    genderController= TextEditingController(text: widget.model.jenis_kelamin);
    addressController= TextEditingController(text: widget.model.alamat);
    rtrwController= TextEditingController(text: widget.model.rt_rw);
    kecamatanController= TextEditingController(text: widget.model.kecamatan);
    religionController= TextEditingController(text: widget.model.agama);
    maritalStatusController= TextEditingController(text: widget.model.status_perkawinan);
    workfieldController= TextEditingController(text: widget.model.pekerjaan);
    provinceController= TextEditingController(text: widget.model.provinsi);
    expiryController= TextEditingController(text: widget.model.berlaku_hingga);
    bloodTypeController= TextEditingController(text: widget.model.golongan_darah);
    kabupatenKotaController= TextEditingController(text: widget.model.kabupaten_kota);
    kelurahanDesaController= TextEditingController(text: widget.model.kelurahan_desa);
    nationalityController= TextEditingController(text: widget.model.kewarganegaraan);

    //datetimePickerWidget = DatetimePickerWidget();
    initializeDateFormatting();
  }

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500))
          ],
        ),
      ),
    );
  }

  Widget _entryField(String title, {bool isPassword = false}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
              obscureText: isPassword,
              decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  filled: true))
        ],
      ),
    );
  }

  Widget _submitButton() {
    return
      InkWell(
          onTap: () {
            // Navigator.push(
            //     context, MaterialPageRoute(builder: (context) => VideoCallPage()));;

            Navigator.push(
                context,
                MaterialPageRoute(
                  //builder: (BuildContext context) => CallSample(host: 'demo.cloudwebrtc.com')));
                    builder: (BuildContext context) => WebrtcRoom()));
          },
          child:

          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Colors.grey.shade200,
                      offset: Offset(2, 4),
                      blurRadius: 5,
                      spreadRadius: 2)
                ],
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xfffbb448), Color(0xfff7892b)])),
            child: Text(
              'Saya siap melakukan video call',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ));
  }

  Widget _divider() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 20,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          Text('or'),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Divider(
                thickness: 1,
              ),
            ),
          ),
          SizedBox(
            width: 20,
          ),
        ],
      ),
    );
  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'eKTP & Contact ',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            // color: Color(0xffe46b10),
            color: Colors.black
          ),
          children: [
            TextSpan(
              text: 'Information',
              style: TextStyle(color: Colors.black, fontSize: 30),
            ),
            // TextSpan(
            //   text: 'Form',
            //   style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
            // ),
          ]),
    );
  }


  Widget showUploadSelfieButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 0.0),
        child: Container(
          height: 40.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: new ElevatedButton(
              child: new Text(
                  'Take Selfie Photo',
                  style: new TextStyle(fontSize: 12.0, color: Colors.white)),
              onPressed: () {
                nodefluxSelfie? changeColor :
                _getSelfieImage(this.context, ImageSource.camera);
              },
              style: ElevatedButton.styleFrom(
                  primary: changeColor? Colors.grey : Colors.green[700]
              )
          ),
        ));
  }

  createAlertDialog(BuildContext context, String title, String message) {
    Widget okButton = FlatButton(
      child: Text("Close"),
      onPressed: () {Navigator.of(context).pop(); },
    );

    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(title: Text(title), content: Text(message),  actions: [
            okButton,
          ],);
        });
  }

  _getSelfieImage(BuildContext context, ImageSource source) async{
    this.setState(() {
      //loading = true;
    });
    try{
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      if (await tempDir.exists())
        tempDir.delete(recursive: false);

      Directory appdocdir= await getApplicationSupportDirectory();
      String test=appdocdir.path;

      if (await appdocdir.exists())
        appdocdir.delete(recursive: false);

      var picture =  await ImagePicker.pickImage(source: source);

      int appFileDirectory=picture.path.lastIndexOf('/');
      String resultDirectory=picture.path.substring(0,appFileDirectory+1); // = appdocdir+'/Pictures/'
      String resultPath=resultDirectory+DateFormat('yyyyMMddHHmmss').format(DateTime.now())+'.jpg';

      int photoQuality=90;
      if(picture != null) {
        try {
          var result = await FlutterImageCompress.compressAndGetFile(
            picture.absolute.path, resultPath,
            quality: photoQuality,
          );

          int pictureLength=picture.lengthSync();
          int resultLength=result.lengthSync();

          var i = 1;

          while ((resultLength < minPhotoSize || resultLength > maxPhotoSize) && photoQuality>0 && photoQuality<100) {
            if (result!=null)
              await result.delete();
            resultPath=resultDirectory+DateFormat('yyyyMMddHHmmss').format(DateTime.now())+'.jpg';
            photoQuality=(resultLength>maxPhotoSize)? photoQuality-10:photoQuality+10;
            result = await FlutterImageCompress.compressAndGetFile(
              picture.absolute.path, resultPath,
              quality: photoQuality,
            );
            resultLength=result.lengthSync();
          }

          double sizeinKb=resultLength.toDouble()/1024;
          debugPrint('Photo compressed size is '+sizeinKb.toString()+' kb');
          //print(pictureLength+resultLength);
          await picture.delete();
          this.setState(() {
            //_imageFileProfile = cropped;
            _selfieImage = result;
            selfieProcessed = 'lagi proses';
            //loading = false;
          });
        } catch (e) {
          print (e);
          debugPrint("Error $e");
        }
      }else{
        this.setState(() {
          //loading = false;
        });
      }
    } catch (e) {
      print (e);
      debugPrint("Error $e");
    }
    await nodefluxSelfieMatchLivenessProcess(context);
    // await nodefluxDukcapilProcess(context);
    await uploadImage(_selfieImage, "selfie");
  }

  nodefluxDukcapilProcess(BuildContext context) async{
    String authorization = 'NODEFLUX-HMAC-SHA256 Credential=ZP027QNHTVI7Z72JN8HWZQXOJ/20220110/nodeflux.api.v1beta1.ImageAnalytic/StreamImageAnalytic, SignedHeaders=x-nodeflux-timestamp, Signature= a2ccd7d7a08a19454a52dbcb043ef28f9c6ac06ba9af58aa97b6aa53d7cbb362';
    String nodefluxTimestamp = '20220110T034835Z';
    final imageBytesSelfie = _selfieImage.readAsBytesSync();
    String base64ImageSelfie = 'data:image/jpeg;base64,'+base64Encode(imageBytesSelfie);
    String currentStatus = '';
    String contentType = 'application/json';
    String accept = 'application/json';
    DukcapilFaceMatch dukcapilFaceMatch = DukcapilFaceMatch();
    DukcapilFail dukcapilFail = DukcapilFail();
    DukcapilOngoing dukcapilOngoing = DukcapilOngoing();
    bool okValue;
    String url = 'https://api.cloud.nodeflux.io/v1/analytics/dukcapil-validation';
    var response;

    try{
      while (currentStatus == 'on going' || currentStatus == '') {
        response = await http.post(
            Uri.parse(url),
            body: json.encode({
              "additional_params": {
                "nik": widget.model.nik,
                "transaction_id": "{random digit}",
                "transaction_source": "{device}",
                "dukcapil": {
                  "user_id": "{encrypted_user_id}",
                  "password": "{encrypted_password}",
                  "image": base64ImageSelfie
                }
              },
              "images": [
                base64ImageSelfie
              ]
            }),
            headers: {
              'Accept': accept,
              'Content-Type': contentType,
              'Authorization': authorization,
              'x-nodeflux-timestamp': nodefluxTimestamp
            }
        );

        print(response.body);
        print(widget.model.nik);

        dukcapilOngoing = DukcapilOngoing.fromJson(jsonDecode(response.body));
        okValue = dukcapilOngoing.ok;
        var status = dukcapilOngoing.job.result.status;
        if(okValue){
          currentStatus = status;
          dukcapilStatus = status;
        }
      }

          if(currentStatus == "success"){
            dukcapilFaceMatch = DukcapilFaceMatch.fromJson(jsonDecode(response.body));
            setState(() {
              similarityValue = dukcapilFaceMatch.job.result.result[0].faceMatch.similarity;
              messageDukcapil = dukcapilFaceMatch.message;
              nodefluxSelfie = true;
              changeColor = true;
              dukcapil = true;
              selfieProcessed = 'selfie ada';
            });

            double similarityPercentage=similarityValue*100;
            String isMatchedString = (similarityPercentage>=75)? "matched": "not matched";
            matchLivenessFeedback += "\nDukcapil verification face " + isMatchedString +" ("+similarityPercentage.toStringAsFixed(2)+" %)";
          }
          else if(currentStatus == 'failed' || currentStatus == 'incompleted'){
            dukcapilFail = DukcapilFail.fromJson(jsonDecode(response.body));
            setState(() {
              messageDukcapil = dukcapilFail.message;
              nodefluxSelfie = true;
              changeColor = true;
              similarityValue = 0.0;
              dukcapil = false;
              selfieProcessed = 'selfie ada';
            });

            if(messageDukcapil == 'Please ensure image format is JPEG, or NIK is registered on Dukcapil'){
              matchLivenessFeedback += "\nNIK doesn't match with face or NIK not registered on Dukcapil, please check your NIK";
            }
            else if(messageDukcapil == "NIK is not found, please check your NIK"){
              matchLivenessFeedback += '\n$messageDukcapil';
            }
            else if(messageDukcapil == 'NIK data not found'){
              matchLivenessFeedback += '\n$messageDukcapil';
            }
            else if(messageDukcapil == 'Invalid Response from Gateway'){
              matchLivenessFeedback += 'Face doesn\'t match with Dukcapil';
            }
            else if(messageDukcapil == 'Gateway not Responding'){
              matchLivenessFeedback += 'Dukcapil verification server error';
            }
          }
          // await nodefluxSelfieMatchLivenessProcess(context);
    }
    catch(e){
      print('Error: $e');
    }
  }

  nodefluxSelfieMatchLivenessProcess(BuildContext context) async{
    setState(() {
      //loading = true;
    });
    //String trx_id = 'Liveness_' + DateFormat('yyyyMMddHHmmss').format(DateTime.now());
    String authorization = 'NODEFLUX-HMAC-SHA256 Credential=ZZC8MB2EHH01G3FX60ZNZS7KA/20201110/nodeflux.api.v1beta1.ImageAnalytic/StreamImageAnalytic, SignedHeaders=x-nodeflux-timestamp, Signature=5a6b903b95b8f3c9677169d69b13b4f790799ffba897405b7826770f51fd4a21';
    String contentType = 'application/json';
    String xnodefluxtimestamp='20201110T135945Z';
    final imageBytesSelfie = _selfieImage.readAsBytesSync();
    String base64ImageSelfie = 'data:image/jpeg;base64,'+base64Encode(imageBytesSelfie);
    final imageBytesEktp = widget.ektpImage.readAsBytesSync();
    String base64ImageEktp = 'data:image/jpeg;base64,'+base64Encode(imageBytesEktp);
    String dialog = "";
    bool isPassed=false;
    String currentStatus='';
    LivenessModelUnderqualified livenessModelUnderqualified = LivenessModelUnderqualified();
    MessageModel messageModel = MessageModel();
    LivenessModel livenessModel = LivenessModel();
    FacePairNotMatch facePairNotMatch = FacePairNotMatch();
    NoFaceDetected noFaceDetected = NoFaceDetected();
    bool okValue=false;

    try{
      var url='https://api.cloud.nodeflux.io/syncv2/analytics/face-match-liveness';
      List<String> photoBase64List=List<String>();
      photoBase64List.add(base64ImageEktp);
      photoBase64List.add(base64ImageSelfie);

      var response;
      // while (currentStatus!='success' && okValue) {
      response = await http
          .post(Uri.parse(url), body: json.encode({
        "images":photoBase64List
          }),
          headers: {"Accept": "application/json",  "Content-Type": "application/json",
        "x-nodeflux-timestamp": "20201110T135945Z",
        "Authorization": authorization
          });

      print(response.body);

      var respbody=response.body;
      messageModel = MessageModel.fromJson(jsonDecode(response.body));
      message = messageModel.message;
      okValue = messageModel.ok;
      var status = messageModel.status;
      print(message + ' ' + okValue.toString());
      if (okValue) {
        currentStatus= status;

        if (currentStatus == "success") {
          if(message == 'Face Liveness Underqualified'){
            livenessModelUnderqualified = LivenessModelUnderqualified.fromJson(jsonDecode(response.body));
            setState(() {
              livenessValue = livenessModelUnderqualified.result[0].faceLiveness.liveness;
              isLive = livenessModelUnderqualified.result[0].faceLiveness.live;
              underQualified = true;
              nodefluxSelfie = true;
              changeColor = true;
              selfieProcessed = 'selfie ada';
              messageDukcapil = ' ';
            });

            double livenessPercentage=livenessValue*100;
            String isLiveString = (livenessPercentage>=75)? "from live ": "not from live ";
            matchLivenessFeedback= "Selfie is taken " + isLiveString +"person!";
            matchLivenessFeedback+= '\nOR';
            matchLivenessFeedback+= '\nLow photo quality';
            matchLivenessFeedback += '\nLiveness Percentage (' + livenessPercentage.toStringAsFixed(2) + '%)';
          }
          else if(message == 'Face Match Liveness Success'){
            livenessModel = LivenessModel.fromJson(jsonDecode(response.body));
            setState(() {
              similarityValue = livenessModel.result[1].faceMatch.similarity;
              isMatched = livenessModel.result[1].faceMatch.match;
              livenessValue = livenessModel.result[0].faceLiveness.liveness;
              isLive = livenessModel.result[0].faceLiveness.live;
              nodefluxSelfie = true;
              changeColor = true;
            });

            double similarityPercentage=similarityValue*100;
            double livenessPercentage=livenessValue*100;
            String isLiveString = (livenessPercentage>=75)? "from live ": "not from live ";
            // String isMatchedString = (similarityPercentage>=75)? "matched": "not matched";
            matchLivenessFeedback = "Selfie is taken " + isLiveString +"person ("+livenessPercentage.toStringAsFixed(2)+" %)";
            // matchLivenessFeedback+= "\neKTP photo is " + isMatchedString +" with selfie ("+similarityPercentage.toStringAsFixed(2)+" %)";
            nodefluxDukcapilProcess(context);
          }
          else if(message == "The Face Pair Not Match"){
            facePairNotMatch = FacePairNotMatch.fromJson(jsonDecode(response.body));
            setState(() {
              similarityValue = facePairNotMatch.result[1].faceMatch.similarity;
              livenessValue = facePairNotMatch.result[0].faceLiveness.liveness;
              isMatched = facePairNotMatch.result[1].faceMatch.match;
              isLive = facePairNotMatch.result[0].faceLiveness.live;
              nodefluxSelfie = true;
              changeColor = true;
            });

            double similarityPercentage = similarityValue*100;
            double livenessPercentage = livenessValue*100;
            String isLiveString = (livenessPercentage>=75)? "from live ": "not from live ";
            // String isMatchedString = (similarityPercentage>=75)? "matched": "not matched";
            matchLivenessFeedback = "Selfie is taken " + isLiveString +"person ("+livenessPercentage.toStringAsFixed(2)+" %)";
            // matchLivenessFeedback+= "\neKTP photo is " + isMatchedString +" with selfie ("+similarityPercentage.toStringAsFixed(2)+" %)";
            nodefluxDukcapilProcess(context);
          }
        } else {
          noFaceDetected = NoFaceDetected.fromJson(jsonDecode(response.body));
          matchLivenessFeedback = noFaceDetected.message;
          setState(() {
            message = noFaceDetected.message;
            noFace = true;
            changeColor = true;
            selfieProcessed = 'selfie ada';
            livenessValue = 0.0;
          });
        }
      } else {
        dialog= messageModel.message;
        matchLivenessFeedback= messageModel.message;
        isPassed=false;
        print(ektpImage.exists());
      }
    }
    catch(e){
      debugPrint('Error $e');
      dialog=e;
    }
    setState(() {
      print(matchLivenessFeedback);
    });
  }


  _getSelfieEktpImage(BuildContext context, ImageSource source) async{
    this.setState(() {
      //loading = true;
    });
    try{
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;

      if (await tempDir.exists())
        tempDir.delete(recursive: false);

      Directory appdocdir= await getApplicationSupportDirectory();
      String test=appdocdir.path;

      if (await appdocdir.exists())
        appdocdir.delete(recursive: false);

      var picture =  await ImagePicker.pickImage(source: source);

      int appFileDirectory=picture.path.lastIndexOf('/');
      String resultDirectory=picture.path.substring(0,appFileDirectory+1); // = appdocdir+'/Pictures/'
      String resultPath=resultDirectory+DateFormat('yyyyMMddHHmmss').format(DateTime.now())+'.jpg';
      //String resultPath='/storage/emulated/0/Android/data/com.smartherd.flutter_app_section2/files/Pictures/'+DateFormat('yyyyMMddHHmmss').format(DateTime.now())+'.jpg';

      int photoQuality=50;
      if(picture != null) {
        try {
          var result = await FlutterImageCompress.compressAndGetFile(
            picture.absolute.path, resultPath,
            quality: photoQuality,
          );

          int pictureLength=picture.lengthSync();
          int resultLength=result.lengthSync();

          var i = 1;

          while ((resultLength < minPhotoSize || resultLength > maxPhotoSize) && photoQuality>0 && photoQuality<100) {
            if (result!=null)
              await result.delete();
            resultPath=resultDirectory+DateFormat('yyyyMMddHHmmss').format(DateTime.now())+'.jpg';
            photoQuality=(resultLength>maxPhotoSize)? photoQuality-10:photoQuality+10;
            result = await FlutterImageCompress.compressAndGetFile(
              picture.absolute.path, resultPath,
              quality: photoQuality,
            );
            resultLength=result.lengthSync();
          }

          double sizeinKb=resultLength.toDouble()/1024;
          debugPrint('Photo compressed size is '+sizeinKb.toString()+' kb');
          //print(pictureLength+resultLength);
          await picture.delete();
          this.setState(() {
            //_imageFileProfile = cropped;
            _selfieEktpImage = result;
            //loading = false;
          });
        } catch (e) {
          print (e);
          debugPrint("Error $e");
        }
      }else{
        this.setState(() {
          //loading = false;
        });
      }
    } catch (e) {
      print (e);
      debugPrint("Error $e");
    }
    //Navigator.of(context).pop();
    uploadImage(_selfieEktpImage, "selfieEktp");
  }

  Widget showUploadSelfieEktpButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 0.0),
        child: SizedBox(
          height: 40.0,
          child: new ElevatedButton(
              child: new Text(
                //'Ambil Foto Selfie',
                  'Take Selfie With eKTP Photo',
                  style: new TextStyle(fontSize: 12.0, color: Colors.white)),
              //onPressed: () { navigateToPage('Login Face');}
              onPressed: () {
                nodefluxSelfie? changeColor :
                _getSelfieEktpImage(this.context, ImageSource.camera);
              },
              style: ElevatedButton.styleFrom(
                  primary: changeColor? Colors.grey : Colors.green[700]
              )
          ),
        ));
  }

  Future getImage() async {

    File registerSelfieimage;
    //Future<bool> faceMatchFound=Future<bool>.value(false);
    bool faceMatchFound1 = false;
    registerSelfieimage= await ImagePicker.pickImage(source: ImageSource.camera);
    if(registerSelfieimage != null) {
      File cropped = await ImageCropper.cropImage(
          sourcePath: registerSelfieimage.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          compressQuality: 80,
          maxWidth: 300,
          maxHeight: 400,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
            toolbarColor: Colors.blueAccent,
            toolbarTitle: "Adjust Like Passport Photo",
            statusBarColor: Colors.blue,
            backgroundColor: Colors.white,
          )
      );

      registerSelfieimage=cropped;
      // _errorMessage='';
    }

    setState(() {
      _imageFile = registerSelfieimage;
    });

  }

  Widget showUploadPhotoButton(String photoTypeName){
    return Padding(
        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
        child: RaisedButton(
          color: Colors.orange,
          textColor: Colors.white,
          child:
          photoTypeName=='selfie'?
          Text(
            'Take Selfie',
            textScaleFactor: 1.5,
          ):
          Text(
            'Take eKTP Photo',
            textScaleFactor: 1.5,
          ),
          onPressed: () {
            getImage;
            //_getImage(this.context, ImageSource.camera);
//        setState(() {
//          debugPrint("Photo button clicked");
//
//        });
          },
        )
    );
  }

  Widget showPhotoUploadedInfo() {
    if (_imageFile != null) {
      return new Padding(
          padding: EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 0.0),
          child: new Center(
              child:
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const <Widget>[
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                  Text(
                    'This photo is successfully uploaded',
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.green,
                        height: 1.0,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )
          ));
    } else {
      return new Padding(
          padding: EdgeInsets.fromLTRB(15.0, 5.0, 0.0, 0.0),
          child: new Center(
              child:
              Row(
                //mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const <Widget>[
                  Icon(
                    Icons.info,
                    color: Colors.lightBlue,
                    size: 20.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                  Text(
                    ' Must upload this photo',
                    style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.lightBlue,
                        height: 1.0,
                        fontWeight: FontWeight.bold),
                  )
                ],
              )
          ));
    }
  }

  Widget tryAgainButton(){
    return new Padding(
        padding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 0.0),
        child: Container(
          height: 40.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: new ElevatedButton(
            child: new Text(
              //'Ambil Foto eKTP',
                'Try again',
                style: new TextStyle(fontSize: 12.0, color: Colors.white)),
            //onPressed: () { navigateToPage('Login Face');}
            onPressed:  () {
              // Navigator.of(context).push(MaterialPageRoute(
              //     builder: (context) => PrepPage()));
              _getSelfieImage(this.context, ImageSource.camera);
              matchLivenessFeedback = "";
              selfieProcessed = "";
              message = "";
              underQualified = false;
            },
            style: ElevatedButton.styleFrom(
                primary: changeColor? Colors.red : Colors.red
            ),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body:
        // firestore start
        ListView(
          padding: EdgeInsets.all(8),
          children: <Widget>[
            Form(
                key: _formKey,
                child: Column (
                  children: <Widget>[
                    SizedBox(height: 60),
                    _title(),
                    SizedBox(height: 50),
                    buildTextFormFieldName(),
                    SizedBox(height: 15),
                    buildTextFormFieldNik(),
                    buildTextFormFieldBirthplace(),
                    SizedBox(height: 15),
                    buildTextFormFieldBirthdate(),
                    SizedBox(height: 15),
                    buildTextFormFieldGender(),
                    SizedBox(height: 15),
                    buildTextFormFieldAddress(),
                    SizedBox(height: 15),
                    buildTextFormFieldRtRw(),
                    SizedBox(height: 15),
                    buildTextFormFieldKelurahanDesa(),
                    SizedBox(height: 15),
                    buildTextFormFieldKecamatan(),
                    SizedBox(height: 15),
                    buildTextFormFieldKabupatenKota(),
                    SizedBox(height: 15),
                    buildTextFormFieldProvince(),
                    SizedBox(height: 15),
                    buildTextFormFieldReligion(),
                    SizedBox(height: 15),
                    buildTextFormFieldMaritalStatus(),
                    SizedBox(height: 15),
                    buildTextFormFieldWorkfield(),
                    SizedBox(height: 15),
                    buildTextFormFieldExpiry(),
                    SizedBox(height: 15),
                    buildTextFormFieldBloodType(),
                    SizedBox(height: 15),
                    buildTextFormFieldNationality(),
                    SizedBox(height: 15),
                    buildTextFormFieldEmail(),
                    SizedBox(height: 15),
                    buildTextFormFieldMobilePhone(),
                    Column (
                        children: <Widget> [
                          showUploadSelfieEktpButton(),
                          (_selfieEktpImage != null)? showUploadSelfieButton() : Container(),
                          (selfieProcessed == 'lagi proses')? Text('Processing.. Please wait a moment..',
                              style: new TextStyle(fontSize: 12.0, color: Colors.black)):Container(),
                          (selfieProcessed == 'selfie ada')? Text('Processed',
                              style: new TextStyle(fontSize: 12.0, color: Colors.black)):Container(),
                          SizedBox(height: 10),
                          (matchLivenessFeedback!="")?
                          Container(
                            child: (dukcapilStatus != '' && selfieProcessed == 'selfie ada')? Container(
                                child: (message == 'Face Match Liveness Success' && messageDukcapil == 'Dukcapil Validation Success')? Text(matchLivenessFeedback,
                                  style: new TextStyle(fontSize: 12.0, color: Colors.black),
                                  textAlign: TextAlign.center,
                                ) : Text(matchLivenessFeedback,
                                  style: new TextStyle(fontSize: 12.0, color: textColorRed),
                                  textAlign: TextAlign.center,
                                )
                            ):Container(),
                          ):Container(),
                          (similarityValue != null && livenessValue != null && dukcapilStatus == 'success' &&
                              _selfieImage != null && similarityValue >= 0.75 && livenessValue >= 0.75
                          )?
                          InkWell(
                              onTap: createData,
                              child:Container(
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(vertical: 15),
                                margin: EdgeInsets.only(top: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(Radius.circular(5)),
                                  border: Border.all(color: Colors.black, width: 2),
                                ),
                                child: Text(
                                  //'Selesai',
                                  'Submit Registration Data',
                                  style: TextStyle(fontSize: 20, color: Colors.black),
                                ),
                              )
                          )
                              :
                          Container(
                              child: (noFace && message == 'No face detected')? tryAgainButton()
                                  :
                              ((nodefluxSelfie)?
                              ((underQualified)? tryAgainButton()
                                  :
                              ((similarityValue < 75 && livenessValue < 75 && dukcapilStatus != 'success' && selfieProcessed == 'selfie ada')? Column(
                                children: [
                                  SizedBox(height: 10),
                                  Text('Liveness or face match do not pass the requirement',
                                    style: TextStyle(fontSize: 15.0, color: Colors.red),
                                    textAlign: TextAlign.center,
                                  ),
                                  // SizedBox(height: 5),
                                  tryAgainButton()
                                ],
                              ):Container())) : Container())
                          ),
                        ]
                    ),
                  ],
                )


            ),
            SizedBox(height: 15),
            // (_selfieEktpImage != null) ?
            // Column (
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: <Widget>[
            //     RaisedButton(
            //       onPressed: createData,
            //       child: Text(
            //           'Submit registration data',
            //           style: TextStyle(color: Colors.white, fontSize: 20)),
            //       color: Colors.green,
            //     ),
                //SizedBox(height: 10),
                //     Text("- or -"),
                // //SizedBox(height: 10),
                // Text("Please choose date and time when we will contact you:"),
                // DatetimePickerWidget(),
                // RaisedButton(
                //   onPressed: createData, // MAYA: SCHEDULE
                //   child: Text(
                //     //'Ok Saya Siap Melakukan Video Call',
                //     //'OK, I am ready to have Video Call',
                //       'Yes, call me at above time',
                //       style: TextStyle(color: Colors.white, fontSize: 20)),
                //   color: Colors.orange,
                // ),
                //(DateTimePickerWidget!=null)?Text(DateTimePickerWidget.toString()):Container(),
                //Text(scheduledDateTimeController.text),
                //     RaisedButton(
                //       onPressed: () {
                //         showDatePicker(
                //           context:this.context,
                //           initialDate:DateTime.now(),
                //           firstDate: DateTime.now(),
                //           lastDate: DateTime(DateTime.now().month+1),
                //           //lastDate:DateTime.now(),
                //         ).then((selectedDate){
                //           //selectedcertificatedate=selectedDate;
                //           scheduledDateTimeController.text= DateFormat('dd-MM-yyyy').format(selectedDate).toString();
                //           //new DateFormat.yMMMd().format(selectedDate);
                //
                //         });
                //
                //       },
                //       //onPressed:
                //       // DateTimePicker(
                //       //   type: DateTimePickerType.dateTime,
                //       //   dateMask: 'd MMMM yyyy - hh:mm',
                //       //   controller: _scheduledDateTimeController,
                //       //   //initialValue: _initialValue,
                //       //   firstDate: DateTime(2000),
                //       //   lastDate: DateTime(2100),
                //       //   //icon: Icon(Icons.event),
                //       //   dateLabelText: 'Date Time',
                //       //   use24HourFormat: false,
                //       //   locale: Locale('en', 'US'),
                //       //   onChanged: (val) => setState(() => _scheduledDateTimeValueChanged = val),
                //       //   validator: (val) {
                //       //     setState(() => _scheduledDateTimeValueToValidate = val ?? '');
                //       //     return null;
                //       //   },
                //       //   onSaved: (val) => setState(() => _scheduledDateTimeValueSaved = val ?? ''),
                //       // )
                //       child: Text(
                //           'Call me at my chosen date and time',
                //           style: TextStyle(color: Colors.white, fontSize: 20)),
                //       color: Colors.orange,
                //     ),
              // ],
            // ) : Container()
          ],
        )
      // firestore end
    );
  }

  Card buildItem(DocumentSnapshot doc) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:<Widget> [
                  Text(
                      'name: ${(doc.data() as dynamic)['name']}',
                      style: TextStyle(fontSize: 24)
                  ),
                  Text(
                      'nik: ${(doc.data() as dynamic)['nik']}',
                      style: TextStyle(fontSize: 24)
                  ),
                  Text(
                      'birthdate: ${(doc.data() as dynamic)['birthdate']}',
                      style: TextStyle(fontSize: 24)
                  ),
                  Text(
                      'birthday: ${(doc.data() as dynamic)['birthday']}',
                      style: TextStyle(fontSize: 24)
                  ),
                  Text(
                      'email: ${(doc.data() as dynamic)['email']}',
                      style: TextStyle(fontSize: 24)
                  ),
                  Text(
                      'mobilePhone: ${(doc.data() as dynamic)['mobilePhone']}',
                      style: TextStyle(fontSize: 24)
                  ),
                  SizedBox(height: 12),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: <Widget>[
                  //     FlatButton(
                  //       onPressed: () =>
                  //     )
                  //   ],
                  // )
                ]
            )
        )
    );
  }

  Widget build2(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned(
                  top: -height * .15,
                  right: -MediaQuery.of(context).size.width * .4,
                  child: BezierContainer()),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * .2),
                      _title(),
                      SizedBox(height: 50),
                      // _ektpFormWidget(),
                      SizedBox(height: 20),
                      _submitButton(),
                      SizedBox(height: 20)
                      // Container(
                      //   padding: EdgeInsets.symmetric(vertical: 10),
                      //   alignment: Alignment.centerRight,
                      //   child: Text('Forgot Password ?',
                      //       style: TextStyle(
                      //           fontSize: 14, fontWeight: FontWeight.w500)),
                      // ),
                      //_divider(),
                      //_facebookButton(),
                      //SizedBox(height: height * .055),
                      //_createAccountLabel(),
                    ],
                  ),
                ),
              ),
              Positioned(top: 40, left: 0, child: _backButton()),
              // firestore start
              ListView(
                padding: EdgeInsets.all(8),
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: buildTextFormFieldName(),
                  ),
                  Row (
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        onPressed: createData,
                        child: Text('Create', style: TextStyle(color: Colors.black)),
                        color: Colors.green,
                      ),
                      RaisedButton(
                        onPressed: firestoreId != null? readData: null,
                        child: Text('Read', style: TextStyle(color: Colors.black)),
                        color: Colors.blue,
                      )

                    ],
                  ),
                ],
              )
              // firestore end
            ],
          ),
        ));
  }

  void createData() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      await db.collection('form').doc('user').update({
        'name': '$firestoreName',
        'nik': '$firestoreNik',
        'address': '$firestoreAddress',
        'dob': '$firestoreBirthdate',
        'pob': '$firestoreBirthplace',
        'gender': '$firestoreGender',
        'rtrw': '$firestoreRtRw',
        'kecamatan': '$firestoreKecamatan',
        'religion': '$firestoreReligion',
        'maritalstatus': '$firestoreMaritalStatus',
        'workfield': '$firestoreWorkfield',
        'province': '$firestoreProvince',
        'expiry': '$firestoreExpiry',
        'bloodtype': '$firestoreBloodType',
        'kabupatenkota': '$firestoreKabupatenKota',
        'kelurahandesa': '$firestoreKelurahanDesa',
        'nationality': '$firestoreNationality',
        'mobile': '$firestoreMobilePhone',
        'email': '$firestoreEmail'});
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => coreBanking()));
    }
  }

  void readData() async {
    DocumentSnapshot snapshot = await db.collection('form').doc(firestoreId).get();
    print ((snapshot.data as dynamic)['name']);
  }

  TextFormField buildTextFormFieldName(){
    return TextFormField (
      controller: nameController,
      decoration: new InputDecoration(
          hintText: 'Nama',
          icon: new Icon(
            Icons.person,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please input nama';
        }
        return null;
      },
      onSaved: (value) => firestoreName = value,
    );
  }

  TextFormField buildTextFormFieldNik(){
    return TextFormField (
      maxLength: 16,
      controller: nikController,
      onChanged: (value){
        widget.model.nik = value;
        print(value);
      },
      keyboardType: TextInputType.number,
      decoration: new InputDecoration(
          hintText: 'NIK',
          icon: new Icon(
            Icons.credit_card,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty || value.length < 16) {
          return 'Please input NIK';
        }
        return null;
      },
      onSaved: (value) => firestoreNik = value,
    );
  }

  TextFormField buildTextFormFieldAddress(){
    return TextFormField (
      controller: addressController,
      decoration: new InputDecoration(
          hintText: 'Address',
          icon: new Icon(
            Icons.home,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please input alamat';
        }
        return null;
      },
      onSaved: (value) => firestoreAddress = value,
    );
  }

  TextFormField buildTextFormFieldBirthdate(){
    return TextFormField (
      controller: birthdateController,
      decoration: new InputDecoration(
          hintText: 'Date of Birth',
          icon: new Icon(
            Icons.calendar_today,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please input tanggal lahir';
        }
        return null;
      },
      onSaved: (value) => firestoreBirthdate = value,
    );
  }

  TextFormField buildTextFormFieldBirthplace(){
    return TextFormField (
      controller: birthplaceController,
      decoration: new InputDecoration(
          hintText: 'Tempat Lahir',
          icon: new Icon(
            Icons.location_city,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please input tempat lahir';
        }
        return null;
      },
      onSaved: (value) => firestoreBirthplace = value,
    );
  }

  TextFormField buildTextFormFieldGender(){
    return TextFormField (
      controller: genderController,
      decoration: new InputDecoration(
          hintText: 'Jenis Kelamin',
          icon: new Icon(
            Icons.person,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please input gender';
        }
        return null;
      },
      onSaved: (value) => firestoreGender = value,
    );
  }

  TextFormField buildTextFormFieldRtRw(){
    return TextFormField (
      controller:rtrwController,
      //maxLength: 16,
      decoration: new InputDecoration(
          hintText: 'RT / RW',
          icon: new Icon(
            Icons.map,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please input RT/RW';
        }
        return null;
      },
      onSaved: (value) => firestoreRtRw = value,
    );
  }

  TextFormField buildTextFormFieldKecamatan(){
    return TextFormField (
      controller:kecamatanController,
      //maxLength: 16,
      decoration: new InputDecoration(
          hintText: 'Kecamatan',
          icon: new Icon(
            Icons.map,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please input Kecamatan';
        }
        return null;
      },
      onSaved: (value) => firestoreKecamatan = value,
    );
  }

  TextFormField buildTextFormFieldReligion(){
    return TextFormField (
      //maxLength: 16,
      controller:religionController,
      decoration: new InputDecoration(
          hintText: 'Agama',
          icon: new Icon(
            Icons.home_outlined,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please input agama';
        }
        return null;
      },
      onSaved: (value) => firestoreReligion = value,
    );
  }

  TextFormField buildTextFormFieldMaritalStatus(){
    return TextFormField (
      //maxLength: 16,
      controller:maritalStatusController,
      decoration: new InputDecoration(
          hintText: 'Status Perkawinan',
          icon: new Icon(
            Icons.home_outlined,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please input status perkawinan';
        }
        return null;
      },
      onSaved: (value) => firestoreMaritalStatus = value,
    );
  }

  TextFormField buildTextFormFieldWorkfield(){
    return TextFormField (
      controller:workfieldController,
      //maxLength: 16,
      decoration: new InputDecoration(
          hintText: 'Pekerjaan',
          icon: new Icon(
            Icons.location_city,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please input pekerjaan';
        }
        return null;
      },
      onSaved: (value) => firestoreWorkfield = value,
    );
  }

  TextFormField buildTextFormFieldProvince(){
    return TextFormField (
      controller:provinceController,
      //maxLength: 16,
      decoration: new InputDecoration(
          hintText: 'Provinsi',
          icon: new Icon(
            Icons.map,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please input provinsi';
        }
        return null;
      },
      onSaved: (value) => firestoreProvince = value,
    );
  }

  TextFormField buildTextFormFieldExpiry(){
    return TextFormField (
      //maxLength: 16,
      controller:expiryController,
      decoration: new InputDecoration(
          hintText: 'Berlaku Hingga',
          icon: new Icon(
            Icons.calendar_today,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please input tanggal berlaku';
        }
        return null;
      },
      onSaved: (value) => firestoreExpiry = value,
    );
  }

  TextFormField buildTextFormFieldBloodType(){
    return TextFormField (
      controller:bloodTypeController,
      //maxLength: 16,
      decoration: new InputDecoration(
          hintText: 'Golongan Darah',
          icon: new Icon(
            Icons.account_box_rounded,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please gol. darah';
        }
        return null;
      },
      onSaved: (value) => firestoreBloodType = value,
    );
  }

  TextFormField buildTextFormFieldKabupatenKota(){
    return TextFormField (
      //maxLength: 16,
      controller: kabupatenKotaController,
      decoration: new InputDecoration(
          hintText: 'Kabupaten / Kota',
          icon: new Icon(
            Icons.person,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please input kabupaten/kota';
        }
        return null;
      },
      onSaved: (value) => firestoreKabupatenKota = value,
    );
  }

  TextFormField buildTextFormFieldKelurahanDesa(){
    return TextFormField (
      controller:kelurahanDesaController,
      //maxLength: 16,
      decoration: new InputDecoration(
          hintText: 'Kelurahan / Desa',
          icon: new Icon(
            Icons.location_city,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please input kelurahan/desa';
        }
        return null;
      },
      onSaved: (value) => firestoreKelurahanDesa = value,
    );
  }


  TextFormField buildTextFormFieldNationality(){
    return TextFormField (
      //maxLength: 16,
      controller:nationalityController,
      decoration: new InputDecoration(
          hintText: 'Kewarganegaraan',
          icon: new Icon(
            Icons.credit_card,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty) {
          return 'Please input kewarganegaraan';
        }
        return null;
      },
      onSaved: (value) => firestoreNationality = value,
    );
  }


  TextFormField buildTextFormFieldEmail(){
    return TextFormField (
      controller:emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: new InputDecoration(
          hintText: 'Email',
          icon: new Icon(
            Icons.mail,
            color: Colors.grey,
          )),
      validator: (value){
        isEmail = EmailValidator.validate(value);

        if (value.isEmpty || !isEmail) {
          return 'Please input a valid email address';
        }
        return null;
      },
      onSaved: (value) => firestoreEmail = value,
    );
  }

  TextFormField buildTextFormFieldMobilePhone(){
    return TextFormField (
      controller:mobilePhoneController,
      keyboardType: TextInputType.phone,
      decoration: new InputDecoration(
          hintText: 'Mobile Phone Number (e.g. 08xxxx)',
          icon: new Icon(
            Icons.phone_android,
            color: Colors.grey,
          )),
      validator: (value) {
        if (value.isEmpty || value.length < 11 || value.length > 12) {
          return 'Input a proper phone number';
        }
        return null;
      },
      onSaved: (value) => firestoreMobilePhone = value,
    );
  }

  Future uploadImage(File fileVar, String fileName) async {
    Reference _reference = FirebaseStorage.instance.ref().child(fileName+'.jpg');
    UploadTask uploadTask = _reference.putFile(fileVar);
    TaskSnapshot taskSnapshot = await uploadTask; // so when the upload task is complete we can have a snapshot [Maya note]
    setState(() {
      //_uploaded = true;
    });
  }


}
