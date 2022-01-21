import 'package:flutter/material.dart';
import '../../Widget/bezierContainer.dart';
import 'loginPage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'WelcomePage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class CongratulationPage extends StatefulWidget {
  CongratulationPage({Key key, this.title, this.email}) : super(key: key);

  final String title;
  final String email;


  @override
  _CongratulationPageState createState() => _CongratulationPageState();
}

class _CongratulationPageState extends State<CongratulationPage> {
  //firestore
  String firestoreId;
  final db = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  String firestoreName;
  String firestoreNik;
  String firestoreAddress;
  String firestoreBirthdate;
  String firestoreBirthday;
  String firestoreMobilePhone;
  String firestoreEmail;

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
              child: Icon(Icons.keyboard_arrow_left, color: Colors.white),
            ),
            Text('Back',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white))
          ],
        ),
      ),
    );
  }

  Widget _submitButton() {
    return
      InkWell(
          onTap: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => WelcomePage()));
          },
          child:Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(vertical: 15),
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              //'Selesai',
              'Done',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          )
      );

  }

  Widget _title() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
          text: 'NTB Syariah',
          style: GoogleFonts.portLligatSans(
            textStyle: Theme.of(context).textTheme.headline4,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          children: [
            TextSpan(
              text: ' Bank',
              style: TextStyle(color: Colors.white, fontSize: 30),
            ),
            // TextSpan(
            //   text: 'rnz',
            //   style: TextStyle(color: Color(0xffe46b10), fontSize: 30),
            // ),
          ]),
    );
  }

  Widget buildItem(DocumentSnapshot doc) {
    return Text(
        '${(doc.data() as dynamic)['email']}',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    //String emailAddress= widget.email.toString();
    //print('INI EMAIL ADDRESS: '+emailAddress);

    return Scaffold(
      body: Container(
        height: height,
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
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                // colors: [Color(0xfffbb448), Color(0xffe46b10)]
                colors: [Colors.green, Colors.green[600], Colors.green[700], Colors.green[800]]
            )
        ),
        child: Stack(
          children: <Widget>[
            // Positioned(
            //   top: -MediaQuery.of(context).size.height * .15,
            //   right: -MediaQuery.of(context).size.width * .4,
            //   child: BezierContainer(),
            // ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: height * .1),
                    _title(),
                    SizedBox(
                      height: 50,
                    ),
                    Text(
                      //'Selamat! Anda telah berhasil membuka rekening di Bank IST!',
                      'Congratulation! You have successfully registered for a Savings Account in NTB Syariah Bank',
                      style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold), textAlign: TextAlign.left,
                    ),
                    //_emailPasswordWidget(),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      //'Proses verifikasi bapak/ibu sudah selesai. Pemberitahuan akan kami kirimkan melalui email:',
                      'Your verification process has been done. We are sending you confirmation email to:',
                      style: TextStyle(color: Colors.white, fontSize: 17), textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: db.collection('form').snapshots(),
                        builder: (context, snapshot){
                          if (snapshot.hasData) {
                            return Column(children:snapshot.data.docs.map((doc)=> buildItem(doc)).toList());
                          } else {
                            return SizedBox();
                          }
                        }
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    // Text(
                    //   //'Silahkan bapak/ibu cek di email tsb untuk melihat hasil verifikasi dari pihak Bank dalam 24 jam',
                    //   'Please keep checking your email above to follow up NTBS verification process within 24 hours',
                    //   style: TextStyle(color: Colors.white, fontSize: 17), textAlign: TextAlign.left,
                    // ),
                    SizedBox(
                      height: 20,
                    ),

                    _submitButton(),
                    SizedBox(height: height * .14),
                    //_loginAccountLabel(),
                  ],
                ),
              ),
            ),
            Positioned(top: 40, left: 0, child: _backButton()),
          ],
        ),
      ),
    );
  }
}
