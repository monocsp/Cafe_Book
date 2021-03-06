import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cafebooking/Alter/alterMainPage.dart';

class PasswordPage extends StatefulWidget {
  final Function setPasswordCallback;
  final bool correctPassword;
  PasswordPage({Key key, this.correctPassword, this.setPasswordCallback})
      : super(key: key);

  @override
  _PasswordPageState createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final scaffoldGlobalKey = GlobalKey<ScaffoldState>();
  final passwordDocumentID = "password";
  TextEditingController textEditingControllerPassword;

  Function setTempPasswordCallback;
  bool isCorrectPassword;
  @override
  void initState() {
    super.initState();
    textEditingControllerPassword = TextEditingController();
    // tempSavePassword = widget.receivePassword ?? "";

    setTempPasswordCallback = widget.setPasswordCallback;
    isCorrectPassword = widget.correctPassword ?? false;
  }

  @override
  void dispose() {
    super.dispose();
    textEditingControllerPassword.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return !isCorrectPassword
        ? Scaffold(
            resizeToAvoidBottomInset: false,
            key: scaffoldGlobalKey,
            body: setFuturebuilder(),
          )
        : AlterPage();
  }

  fetchData() {
    return FirebaseFirestore.instance
        .collection("Password")
        .doc(passwordDocumentID)
        .get();
  }

  setFuturebuilder() {
    return FutureBuilder(
        future: fetchData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Center(child: CupertinoActivityIndicator());
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    children: [
                      Text("데이터 불러오기에 실패하였습니다."),
                      Text("${snapshot.hasError}")
                    ],
                  ),
                );
              } else {
                // print();
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Text("비밀번호"),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: TextField(
                          obscureText: true,
                          controller: textEditingControllerPassword,
                        ),
                      ),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 0, primary: Colors.yellow),
                          child: Text(
                            "로그인",
                            style: TextStyle(color: Colors.blueAccent),
                          ),
                          onPressed: () {
                            FocusScope.of(context).unfocus();
                            if (snapshot.data["password"] ==
                                textEditingControllerPassword.text) {
                              setState(() {
                                isCorrectPassword = true;
                                setTempPasswordCallback(true);
                              });
                            }
                            // return AlterPage();

                            else {
                              textEditingControllerPassword..text = '';
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text("비밀번호가 일치하지 않습니다."),
                                behavior: SnackBarBehavior.floating,
                              ));
                            }
                          })
                    ],
                  ),
                );
              }
          }
        });
  }
}
