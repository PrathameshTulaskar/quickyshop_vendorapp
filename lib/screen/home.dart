import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_formfield/dropdown_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:getflutter/components/carousel/gf_carousel.dart';
import 'package:quickyshop_vendorapp/models/megaHomepage.dart';
//import 'package:quickyshop_vendorapp/models/supermarketDetail.dart';
import 'package:quickyshop_vendorapp/providers/appstate.dart';
import 'package:quickyshop_vendorapp/screen/addproduct.dart';
import 'package:quickyshop_vendorapp/widgets/colors.dart';
import 'package:quickyshop_vendorapp/widgets/customWidgets.dart';
import 'package:provider/provider.dart';
import '../util/themedata.dart';
import 'package:quickyshop_vendorapp/widgets/widgets.dart';

import 'Signup/signup_screen.dart';

class Homepage extends StatefulWidget {
  Homepage({Key key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String name;
  @override
  void initState() { 
    super.initState();
    Provider.of<AppState>(context, listen: false).fetchUserDetails();
  }
  @override
  Widget build(BuildContext context) {
    String unitsSelected;
    final appState = Provider.of<AppState>(context);
    final userDetails = Provider.of<User>(context);
    VendorMegaData vendor;
    vendor = appState.vendorData;
    if(vendor != null){
      setState(() {
        name = vendor.vendorName ?? "";
      });
    }
  
    return 
    //appState.vendorData == null ? SignUpScreen() : 
    Selector<AppState,VendorMegaData>(
      builder: (context,value,child){
        return value == null ? SignUpScreen() : 
        SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: TitleTextBuilder(
              sendText: "Welcome ${value.vendorName}",
            ),
             automaticallyImplyLeading: false,
            //leading: Container(),
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.notifications,
                    color: Colors.white,
                  ),
                  onPressed: null)
            ],
          ),
          body: Container(
            width: fullWidth(context),
            // decoration: backgroundDecoration,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                //RaisedButton(child: Text("okokokok"),onPressed: () => Navigator.pushNamed(context, '/welcomePage')),
                SizedBox(height: 25),
                appState.supermarketlist.length == 0 ? Text("No supermarket registered.") :
                Text(
                   "Your Total Profit chart for ${appState.supermarketlist.length.toString()} outlets is below",
                   style: TextStyle(color: Colors.blueGrey[700], fontSize: 14.5),
                  //sendColor: Colors.orange[300],
                ),
                SizedBox(height: 25),
                Container(
                  width: 330,
                  height: 97,
                  decoration: new BoxDecoration(
                    color: Colors.white,
                    border: new Border.all(width: 5.0, style: BorderStyle.none),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      new BoxShadow(
                        color: Colors.black26,
                        offset: new Offset(20.0, 10.0),
                        blurRadius: 20.0,
                      )
                    ],
                  ),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection("grocery/vendors/vendorList").doc(appState.vendorId).snapshots(),
                    builder: (context, snapshot) {
                      var children;
                      
                      switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        children = Container(
                          width: fullWidth(context),
                          height: fullHeight(context),
                          child: Center(child: CircularProgressIndicator()));
                      break;
                    default:
                    if (snapshot.hasError)
                        children = [Text('Error: ${snapshot.error}')];
                      else {
                        var response = VendorMegaData.fromJson(snapshot.data.data());
                        children = Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Total Order",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              SizedBox(height: 10),
                              Text(
                                response != null ? response.totalOrders.toString() : "",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(fontSize: 15),
                              )
                            ],
                          ),
                          
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Sale",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: <Widget>[
                                  Text("\u20b9" , style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(fontSize: 15),), 
                                  Text( response != null ? response.totalSales.toString() : "" , style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(fontSize: 15),)
                                  ],
                              )
                            ],
                          ),
                          
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Delivered",
                                style: Theme.of(context).textTheme.bodyText1,
                              ),
                              SizedBox(height: 10),
                              Text(
                                 response != null ? response.totalDeliveries.toString() : "",
                                style: Theme.of(context)
                                    .textTheme
                                    .subtitle1
                                    .copyWith(fontSize: 15),
                              )
                            ],
                          ),
                          
                        ],
                      );
                      }  
                    }
                    return children;
                    }
                  ),
                ),
                SizedBox(height: 10),
                CarouselSlider(
                  // enlargeMainPage: true,
                  items: appState.homepageSlideUrls.length == 0
                      ? [
                          Center(
                            child: CircularProgressIndicator(),
                          )
                        ]
                      : appState.homepageSlideUrls.map(
                          (urls) {
                            return Container(
                              margin: EdgeInsets.all(5.0),
                              child: ElevatedButton(
                            // style:ElevatedButton.styleFrom( padding: EdgeInsets.all(5),)
                                child: ClipRRect(
                                  
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  child: Image.network(
                                    urls,
                                    fit: BoxFit.cover,
                                    width: 1000.0,
                                    height: 300,
                                  ),
                                ),
                                onPressed: () => print("hello"),
                         
                                // materialTapTargetSize:
                                //     MaterialTapTargetSize.shrinkWrap,
                               
                                // style: Material,
                              ),
                            );
                          },
                        ).toList(),
                        options:CarouselOptions(
                          height:200,
                          aspectRatio:16/9,
                          viewportFraction:0.8,
                          initialPage:0,
                          enableInfiniteScroll:true,
                          reverse:false,
                          autoPlay:true,
                          autoPlayInterval:Duration(seconds:3),
                          autoPlayAnimationDuration:Duration(milliseconds:800),
                          autoPlayCurve:Curves.fastOutSlowIn,
                          enlargeCenterPage:true,
                          scrollDirection:Axis.horizontal,

                        ),
                  // onPageChanged: (index) {
                  //   print("slider change: $index");
                  // },
                ),
                //SizedBox(height:50),
                // Container(
                //   width: 300,
                //   height: 100,
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: <Widget>[
                //      Expanded(
                //                           child: DropDownFormField(
                //                     filled: false,
                //                     value: appState.setSupermarketID,
                //                     onSaved: (value) {

                //                       appState.setSupermarketIdOnHome(value);
                //                       setState(() {
                //                         unitsSelected = value;
                //                       });
                //                       print("onSaved: $value");
                //                      // print(appState.productUnits.text);
                //                     },
                //                     onChanged: (value) {
                //                       appState.setSupermarketIdOnHome(value);
                //                       setState(() {
                //                         unitsSelected = value;
                //                       });
                //                       print("on changed : ${appState.setSupermarketID}");

                //                       //print(appState.productUnits.text);
                //                     },
                //                     titleText: "Select Your Super Market",
                //                     hintText: "Select Super Market",
                //                     dataSource: appState.supermarketlist,
                //                     textField: 'display',
                //                     valueField: 'value',
                //                   ),
                //      ),
                //     ],
                //   ),
                // ),
                //SizedBox(height: 50),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.97,
                  height: 97,
                  decoration: new BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      border: new Border.all(width: 5.0, style: BorderStyle.none),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      boxShadow: [
                        new BoxShadow(
                          color: Colors.black26,
                          offset: new Offset(20.0, 10.0),
                          blurRadius: 20.0,
                        )
                      ],
                  ),
                  child: InkWell(
                      onTap: (){
                          Navigator.pushNamed(context, '/supermarketlist');
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Icon(Icons.store , color: whiteColor,),
                          Text("VIEW OUTLETS" , style: TextStyle(color: whiteColor, fontWeight:FontWeight.bold),),
                          Icon(Icons.arrow_forward_ios , color: whiteColor,)
                        ],
                      ),
                  ),
                      ),
                    )
                  ],
                ),
                //SizedBox(height: 50),

                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: <Widget>[
                //     homeMenuItem("Add", "Product",
                //         Icon(Icons.add, color: white), context, () {
                //        Navigator.push(context, MaterialPageRoute(builder: (context) => Addproduct(
                //             finalSupermarketID: appState.setSupermarketID ?? "",
                //           )));
                //     }),
                //     homeMenuItem(
                //         "Quick",
                //         "Add",
                //         Icon(Icons.signal_cellular_4_bar, color: white),
                //         context, () {
                //       Navigator.pushNamed(context, '/categorylistforstep2');
                //     }),
                //   ],
                // ),
                //SizedBox(height: 20),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   children: <Widget>[
                //     homeMenuItem(
                //         "Order",
                //         "Status",
                //         Icon(Icons.settings_backup_restore, color: white),
                //         context, () {
                //       print("hrllo");
                //     }),
                //     homeMenuItem(
                //         "My", "Store", Icon(Icons.store, color: white), context,
                //         () {
                //       Navigator.pushNamed(context, '/supermarketlist');
                //     }),
                //   ],
                // ),
               // SizedBox(height: 25),
                // Container(
                //   width: 340,
                //   height: 100,
                //   decoration: new BoxDecoration(
                //     color: Colors.white,
                //     border: new Border.all(width: 5.0, style: BorderStyle.none),
                //     borderRadius: BorderRadius.all(Radius.circular(10)),
                //     boxShadow: [
                //       new BoxShadow(
                //         color: Colors.black26,
                //         offset: new Offset(20.0, 10.0),
                //         blurRadius: 20.0,
                //       )
                //     ],
                //   ),
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: <Widget>[
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: <Widget>[
                //           Text("Orders Placed Today:"),
                //           Text("500")
                //         ],
                //       ),
                //       SizedBox(height: 20),
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: <Widget>[
                //           Text("Orders Delivered Today:"),
                //           Text("100")
                //         ],
                //       )
                //     ],
                //   ),
                // ),
              //  SizedBox(height: 25),
              ],
            ),
          ),
        ),
      );
      },
      selector: (buildContext,appstate) => appstate.vendorData,
    );
  }
}
