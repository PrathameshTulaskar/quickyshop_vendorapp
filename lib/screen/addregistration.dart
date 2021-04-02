import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quickyshop_vendorapp/models/credentials.dart';
import 'package:quickyshop_vendorapp/screen/home.dart';
import 'package:quickyshop_vendorapp/widgets/colors.dart';
import 'package:quickyshop_vendorapp/widgets/customWidgets.dart';
import 'package:quickyshop_vendorapp/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:quickyshop_vendorapp/providers/appstate.dart';
import 'package:quickyshop_vendorapp/models/phoneAuth.dart';

class AddRegistrationDetail extends StatefulWidget {
  @required
  final Credentials userData;
  AddRegistrationDetail({Key key, this.userData}) : super(key: key);

  @override
  _AddRegistrationDetailState createState() => _AddRegistrationDetailState();
}

class _AddRegistrationDetailState extends State<AddRegistrationDetail> {
  final GlobalKey<ScaffoldState> _scaffoldKeyReg =
      new GlobalKey<ScaffoldState>();
  File _imageFile;
  final picker = ImagePicker();
  bool phoneAuth = false;
  bool googleAuth = false;
  bool facebookAuth = false;
  bool isSuccess;
  String profileUrl = "";
  final _formKey = GlobalKey<FormState>();

  // @override
  // void initState() {
  //   super.initState();
  //   // Provider.of<AppState>(context, listen: false).fetchHomepageSlides();
  //   // Provider.of<AppState>(context, listen: false).fetchUserDetails(widget.userData.userId);
  //   Provider.of<AppState>(context, listen: false).checkLogin();
  // }
  // }
  // Navigator.push(
  //   context, new MaterialPageRoute(
  //     builder: (context) => new SecondPage()));

  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("grocery/vendors/vendorList")
            .doc(widget.userData.userId)
            .get(),
        //appState.getUserDetails(),
        // stream: Firestore.instance
        //     .collection("grocery/customers/customersList")
        //     .document(userData.userId)
        //     .snapshots(),
        builder: (context, snapshot) {
          var children;
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              children = Scaffold(
                body: Container(
                    width: fullWidth(context),
                    height: fullHeight(context),
                    child: Center(child: CircularProgressIndicator())),
              );
              break;
            default:
              if (snapshot.hasError)
                children = [Text('Error: ${snapshot.error}')];
              else {
                if (snapshot.hasData && snapshot.data.exists) {
                  // appState.getUserDetails();
                  print("stream running on add registration : ");
                  //Provider.of<AppState>(context, listen: false).checkLogin();
                  //PROVIDERS IF ADDED ANYWHERE HERE OR HOMEPAGE IT CREATES ISSUE.
                  return Homepage();
                  // Navigator.pushReplacementNamed(context, '/home');
                } else {
                  switch (widget.userData.identifier) {
                    case "phone":
                      {
                        //setState(() {
                        phoneAuth = true;
                        //});
                      }
                      break;
                    case "fb":
                      {
                        //setState(() {
                        facebookAuth = true;
                        //  });
                      }
                      break;
                    default:
                      {
                        // setState(() {
                        googleAuth = true;
                        // });
                      }
                  }
                  print("else statement in future running...");
                  children = SafeArea(
                    child: Scaffold(
                      key: _scaffoldKeyReg,
                      appBar: AppBar(
                        title: Text("User Information"),
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(Icons.done),
                            onPressed: () async {
                              if (_formKey.currentState.validate()) {
                                switch (widget.userData.identifier) {
                                  case "phone":
                                    {
                                      if (profileUrl.length > 1) {
                                        print("phone auth data store with user ID:${widget.userData.userId}");
                                        appState
                                            .userDataStore(
                                                contactNumber: widget
                                                    .userData.contactNumber,
                                                userIdReg: widget.userData.userId,
                                                checkAuth: 1,
                                                otpData: PhoneAuthModel(
                                                    profileUrl: profileUrl))
                                            .then((value) {
                                          if (value) {
                                            Navigator.of(context)
                                                .pushNamedAndRemoveUntil(
                                                    '/home',
                                                    (Route<dynamic> route) =>
                                                        false);
                                          } else {
                                            setState(() {
                                              isSuccess = value;
                                            });
                                          }
                                        });
                                      } else {
                                        _scaffoldKeyReg.currentState
                                                    .hideCurrentSnackBar();
                                        _scaffoldKeyReg.currentState
                                            .showSnackBar(SnackBar(
                                                backgroundColor:
                                                    Colors.yellow[900],
                                                //duration: Duration(seconds: 240),
                                                behavior:
                                                    SnackBarBehavior.fixed,
                                                content: Text(
                                                    "Profile Pic Required.")));
                                      }
                                    }
                                    break;
                                  case "fb":
                                    {
                                      appState
                                          .userDataStore(
                                        facebookSignIn:
                                            widget.userData.fbSignIn,
                                        userIdReg: widget.userData.userId,
                                      )
                                          .then((value) {
                                        if (value) {
                                          // Navigator.pushReplacementNamed(
                                          //     context, '/home');
                                           Navigator.of(context)
                                                .pushNamedAndRemoveUntil(
                                                    '/home',
                                                    (Route<dynamic> route) =>
                                                        false);
                                        } else {
                                          setState(() {
                                            isSuccess = value;
                                          });
                                        }
                                      });
                                    }
                                    break;
                                  default:
                                    {
                                      appState
                                          .userDataStore(
                                              googleSignIn:
                                                  widget.userData.googleSignIn,
                                              userIdReg: widget.userData.userId,
                                              checkAuth: 2)
                                          .then((value) {
                                        if (value) {
                                          // Navigator.pushReplacementNamed(
                                          //     context, '/home');
                                           Navigator.of(context)
                                                .pushNamedAndRemoveUntil(
                                                    '/home',
                                                    (Route<dynamic> route) =>
                                                        false);
                                        } else {
                                          setState(() {
                                            isSuccess = value;
                                          });
                                        }
                                      });
                                    }
                                }
                              }
                            },
                          )
                        ],
                      ),
                      body: SingleChildScrollView(
                        child: Form(
                          key: _formKey,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  facebookAuth || googleAuth
                                      ? SizedBox(height: 20)
                                      : Container(),
                                  facebookAuth || googleAuth
                                      ? Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: TextFieldIcon(
                                                controllerName:
                                                    appState.contactNumberReg,
                                                showIcon: true,
                                                iconPrefix: Icon(Icons.phone),
                                                label: "Contact Number",
                                                validate: (value) {
                                                  if (value.length < 10) {
                                                    return "Invalid phone number";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  (_imageFile == null && phoneAuth)
                                      ? SizedBox(height: 30)
                                      : Container(),
                                  (phoneAuth)
                                      ? ElevatedButton(
                                          onPressed: () async {
                                            var selected =
                                                await picker.getImage(
                                                    source:
                                                        ImageSource.gallery);
                                            setState(() {
                                              _imageFile = File(selected.path);
                                            });
                                            var response = '';
                                            // await appState
                                            //     .uploadToStore(_imageFile);
                                            _scaffoldKeyReg.currentState
                                                .showSnackBar(SnackBar(
                                                    backgroundColor:
                                                        Colors.yellow[900],
                                                    duration:
                                                        Duration(seconds: 240),
                                                    behavior:
                                                        SnackBarBehavior.fixed,
                                                    content: Text(
                                                        "Profile Pic Uploading...")));
                                            if (response != null) {
                                              setState(() {
                                                profileUrl = response;
                                              });
                                               _scaffoldKeyReg.currentState
                                                    .hideCurrentSnackBar();
                                              _scaffoldKeyReg.currentState
                                                  .showSnackBar(SnackBar(
                                                      backgroundColor:
                                                          Colors.green,
                                                      //duration: Duration(seconds: 240),
                                                      behavior: SnackBarBehavior
                                                          .fixed,
                                                      content:
                                                          Text("Uploaded.")));
                                            } else {
                                              _scaffoldKeyReg.currentState
                                                    .hideCurrentSnackBar();
                                              _scaffoldKeyReg.currentState
                                                  .showSnackBar(SnackBar(
                                                      backgroundColor:
                                                          Colors.red,
                                                      //duration: Duration(seconds: 240),
                                                      behavior: SnackBarBehavior
                                                          .fixed,
                                                      content: Text(
                                                          "Upload failed try again.")));
                                              print("chalna mare");
                                               setState(() {
                                              _imageFile = null;
                                            });
                                            }
                                           
                                            //_showSnack();
                                          },
                                          child: (_imageFile == null)
                                              ? Icon(
                                                  Icons.image,
                                                  size: 50,
                                                )
                                              : CircleAvatar(
                                                backgroundColor: whiteColor,
                                                backgroundImage: FileImage(_imageFile,scale: 1),
                                                radius: 50,
                                                  // child: Image.file(
                                                  //   _imageFile,
                                                  //   width: 150.0,
                                                  //   height: 150.0,
                                                  // ),
                                              ),
                                        )
                                      : Container(),
                                  (_imageFile == null && phoneAuth)
                                      ? Text("Pick profile")
                                      : Container(),
                                  phoneAuth
                                      ? SizedBox(height: 20)
                                      : Container(),
                                  phoneAuth
                                      ? Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: TextFieldIcon(
                                                controllerName:
                                                    appState.fullNameReg,
                                                showIcon: true,
                                                iconPrefix:
                                                    Icon(Icons.account_circle),
                                                label: "Full Name",
                                                validate: (value) {
                                                  if (value == null) {
                                                    return "Required";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  phoneAuth
                                      ? SizedBox(height: 20)
                                      : Container(),
                                  phoneAuth
                                      ? Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: TextFieldIcon(
                                                controllerName:
                                                    appState.userNameReg,
                                                showIcon: true,
                                                iconPrefix: Icon(Icons
                                                    .perm_contact_calendar),
                                                label: "Username",
                                                validate: (value) {
                                                  if (value == null) {
                                                    return "Required";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  phoneAuth
                                      ? SizedBox(height: 20)
                                      : Container(),
                                  phoneAuth
                                      ? Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: TextFieldIcon(
                                                controllerName:
                                                    appState.emailReg,
                                                showIcon: true,
                                                iconPrefix: Icon(Icons.email),
                                                label: "Email Address",
                                                validate: (value) {
                                                  if (value == null) {
                                                    return "Required";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  (!facebookAuth || widget.userData.fbSignIn.birthDate == null)
                                      ? SizedBox(height: 30)
                                      : Container(),
                                  (!facebookAuth || widget.userData.fbSignIn.birthDate == null)
                                      ? Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: DateTimeField(
                                                controller:
                                                    appState.birthDateReg,
                                                format:
                                                    DateFormat("yyyy-MM-dd"),
                                                decoration: InputDecoration(
                                                    prefixIcon:
                                                        Icon(Icons.cake),
                                                    hintText: "Birthday"),
                                                onShowPicker:
                                                    (context, currentValue) {
                                                  return showDatePicker(
                                                    context: context,
                                                    firstDate: DateTime(1900),
                                                    initialDate: currentValue ??
                                                        DateTime(1996),
                                                    lastDate: DateTime(2100),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container(),
                                  SizedBox(height: 30),
                                  Visibility(
                                    child: Center(
                                      child: Text(
                                        "Something went wrong... try again.",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    visible:
                                        (isSuccess != null && !(isSuccess)),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }
          }

          return children;
        });
  }

  // _showSnack() {
  //   _scaffoldKey.currentState.showSnackBar(SnackBar(
  //     content: Text("Image Uploading"),
  //   ));
  // }
}
