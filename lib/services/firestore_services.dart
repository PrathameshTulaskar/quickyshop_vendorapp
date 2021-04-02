import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickyshop_vendorapp/models/deliveryBoy.dart';
import 'package:quickyshop_vendorapp/models/megaHomepage.dart';
import 'package:quickyshop_vendorapp/models/product.dart';
import 'package:quickyshop_vendorapp/models/supermarketDetail.dart';


class FirestoreService {
  FirebaseFirestore _db = FirebaseFirestore.instance;
  // Geoflutterfire geo = Geoflutterfire();
  Future<bool> addProductService(
      String productName,
      String productQty,
      String productPrice,
      String productCategory,
      String supermarketId,
      String productWeight,
      String productUnits,
      String url, String sellPrice , bool prodStatus) async {
        
    return _db
        .collection(
            "grocery/products/productList/$supermarketId/supermarketProducts")
        .add({
      'productName': "$productName",
      'price': int.parse(sellPrice),
      'originalPrice' : int.parse(productPrice),
      'stockAvailable': int.parse(productQty),
      'productWeight' : double.parse(productWeight),
      'weightType' : productUnits,
      'productImg': url,
      'supermarketId' : supermarketId,
      'featureProduct' : false,
      'productStatus' : prodStatus,
      'productCategory' : productCategory,
      'statusReason' : "Approval Pending",
      'productState' : 'active',
    }).then((value) {
      print("data add success");
      return true;
    }).catchError((onError) {
      print("error while adding products :$onError");
      return false;
    });
  }

  // add supermarket to database
  // Future<bool> addSupermarketService(
  //     String vendorId,
  //     String supermarketName,
  //     String supermarketUrl,
  //     String supermarketLocation,
  //     String pinCode,
  //     String landMark,
  //     GeoPoint supermarketLoc) async {
  //       var supermarketLocationPoint = GeoFirePoint(
  //         supermarketLoc.latitude,supermarketLoc.longitude
  //       );
  //   return _db.collection("grocery/supermarkets/supermarketList").add({
  //     'vendor': vendorId,
  //     'supermarketName': supermarketName,
  //     'locality': supermarketLocation,
  //     'subscription': false,
  //     'available': true,
  //     'imgUrl': supermarketUrl,
  //     'location': supermarketLocationPoint.data,
  //     'supermarketPincode': pinCode,
  //     'landmark': landMark,
  //     'totalOrders':0
  //   }).then((value) {
  //     print("data add success");
  //     return true;
  //   }).catchError((onError) {
  //     print("error while adding products :$onError");
  //     return false;
  //   });
  // }
  //Add Featured Product List
  Future<bool> addFeaturedProduct(String productId, bool setValue ,String superMarketID) async{
    
    try{
      await _db
        .collection("grocery/products/productList/$superMarketID/supermarketProducts")
        .doc(productId)
        .set({
      'featureProduct': setValue,
    });
    return true;
  
    }
    catch(error){
       print("add featured product Service : $error");
       return false;
    }
    
  }
  //Check if Featured List exist
  Future<bool> checkFeaturedExist(String supermarketId) async{
   print(supermarketId);
   try{
     var response =  await _db.collection("grocery/products/featuredProductList").doc(supermarketId).get();
     if(response != null){
        print(response);
        return true;
      }
      else{
        return false;
      }
   }
   catch(error){
     print("error : $error");
     return false;
   }
   
   
  }
  //Update Product List
  Future<bool> updateProducts(String marketId, String price, String stock,
     String sellingPrice, String productId) {
    return _db
        .collection("grocery/products/productList/$marketId/supermarketProducts")
        .doc(productId)
        .set({
      'price': int.parse(sellingPrice),
      'stockAvailable': int.parse(stock),
      'originalPrice': int.parse(price)
    }).then((value) {
      print("data Updated Successfully");
      return true;
    }).catchError((onError) {
      print("error while updating products :$onError");
      return false;
    });
  }

  //Fetch Categories
  Future<List<String>> fetchCategoriesService() async {
    var response = await _db
        .collection("grocery/products/categoryList")
        .doc("categoryNameList")
        .get();
    return List<String>.from(response.data()['categories']);
  }

  //Fetch Homepage Slider
  Future<List<String>> fetchHomepageSlider() async {
    var response =
        await _db.collection("customerslides").doc("slides").get();
    return List<String>.from(response.data()['urls']);
  }

  //Fetch Supermarkets by Vendor ID
  Future<List<SupermarketDetails>> fetchSupermarketByVendor(String vendorId) async {
    List<SupermarketDetails> finalOutput = [];
    var response = await _db
        .collection("grocery/supermarkets/supermarketList")
        .where('vendor', isEqualTo: vendorId)
        .get();
    response.docs.forEach((element) {
      var mappedData = {
        'supermarketId': element.id,
        'supermarket': element.data()['supermarketName'],
        'supermarketImage' : element.data()['imgUrl'],
        'visiblity' : element.data()['available'],
        'subscription': element.data()['subscription'],
        'reason' : element.data()['reasonToHold'],
        'vendorAccId': element.data()['vendorAccId']
      };
      finalOutput.add(SupermarketDetails.fromJson(mappedData));
    });
    return finalOutput;
  }

  //Fetch Products by category
  Future<List<Product>> fetchProductByCategory(
      String supermarketId, String categoryName) async {
    var response = await _db
        .collection("grocery/products/productList/$supermarketId/supermarketProducts").where("productCategory",isEqualTo: categoryName)
        .get();
    List<Map<String, dynamic>> listProducts = [];
    response.docs.forEach((element) {
      String productId = element.id;
      Map<String, dynamic> moreData = element.data();
      Map<String, dynamic> productIdMap = {'productId': productId};
      Map<String, dynamic> mergedMap = {};
      mergedMap.addAll(moreData);
      mergedMap.addAll(productIdMap);
      //print(mergedMap);
      listProducts.add(mergedMap);
    });
    return listProducts.map((e) => Product.fromJson(e)).toList();
  }

  //Delete Product
  Future<bool> deleteProduct(
      String supermarketId, String productId , String state) async {
        try{
        await _db.collection("grocery/products/productList/$supermarketId/supermarketProducts")
        .doc(productId)
        .set({
          'productState' : state,
          'productStatus' : false
        });
        return true;
        }catch(e){
          print("error while archive product appState :$e");
          return false;
        }
  }

  //Fetch Products From Our Products
  Future<List<Product>> ourProductsServices(String categoryName) async {
    var response = await _db
        .collection("grocery/products/productList/ourProducts/$categoryName")
        .get();
    List<Map<String, dynamic>> listProducts = [];
    response.docs.forEach((element) {
      String productId = element.id;
      Map<String, dynamic> moreData = element.data();
      Map<String, dynamic> productIdMap = {'productId': productId};
      Map<String, dynamic> mergedMap = {};
      mergedMap.addAll(moreData);
      mergedMap.addAll(productIdMap);
      //print(mergedMap);
      listProducts.add(mergedMap);
    });
    return listProducts.map((e) => Product.fromJson(e)).toList();
    //return response.documents.map((e) => Product.fromJson(e.data)).toList();
  }

  //Update Supermarket Visiblity
  Future<bool> updateSupermarketVisiblityService(String superMarketId , bool setVisiblity) async{
    try{
      _db
        .collection("grocery/supermarkets/supermarketList")
        .doc(superMarketId)
        .set({
         'available': setVisiblity
    });
      print("in service, visiblity set to : $setVisiblity");
      return true;
    }
    catch(error){
      print("Update not done: $error");
      return false;
    }
  }
  Stream<List<Product>> fetchLowStockById(String supermarketId){
    var response = _db.collection("grocery/products/productList/$supermarketId/supermarketProducts").where("stockAvailable",isLessThan: 11).snapshots();
    //List<Map<String, dynamic>> listProducts = [];
    print("low stock called from firebase service !!!!!!!!!!!!!!!!!!!!!!!!!!");
    var data = response.map((event) => event.docs.map((e) {
      String productId = e.id;
      Map<String, dynamic> moreData = e.data();
      Map<String, dynamic> productIdMap = {'productId': productId};
      Map<String, dynamic> mergedMap = {};
      mergedMap.addAll(moreData);
      mergedMap.addAll(productIdMap);
      //print(mergedMap);
      //listProducts.add(mergedMap);
      return mergedMap;
    }).toList());
    return  data.map((e) => e.map((e) => Product.fromJson(e)).toList());
  }
  //Update order Status for delivery
  Future<bool> updateOrderStatusToDelivery(Timestamp orderPacked,String accountId,String vendorId,String orderId, String orderStatus, String deliveryBoyId , String deliveryBoyName) async {
    try{
      print(orderId);
       _db
        .collection("grocery/orders/orderList")
        .doc(orderId)
        .set({
         'orderStatus': orderStatus,
         'deliveryBoyId': deliveryBoyId,
         'vendorId': vendorId,
         'vendorAccId':accountId,
         'orderPacked':orderPacked
    });
    var getRaf = _db.collection("grocery/vendors/vendorList").doc(vendorId);
    _db.runTransaction((Transaction transaction) async {
      var value =  await transaction.get(getRaf);
     var newVal = value.data()['totalOrders'] + 1;
     transaction.update(getRaf, {'totalOrders': newVal});
     print(newVal);
    });
    return true;
        }
    catch(error){
      print("while update delivery status: $error");
      return false;
    }
  }
  Future<void> cancelOrderService(String documentId,String cancelReason)async{
    try{
      await _db.collection("grocery/orders/orderList").doc(documentId).set({
        'cancelOrder' : true,
        'cancelReason' : cancelReason,
        'orderStatus' : 'Order Cancelled'
      });
    }catch(e){
      print("order cancel FIREBASE SERVICE: $e");
    }
  }
  //Assigned Delivery Boy
  Stream<DocumentSnapshot> fetchDeliveryBoy(String supermarketId) {
    var response = _db.collection("grocery/delivery/deliveryBoys").where("supermarketIds", arrayContains: supermarketId).snapshots();
    return response.map((event) => event.docs.first);
  }
  //Fetch Vendor Details
  Future<VendorMegaData> fetchVendorDetails(String vendorId)async{
    try{
      print("vendorId : $vendorId");
      var response = await _db.collection("grocery/vendors/vendorList").doc(vendorId).get();
      return VendorMegaData.fromJson(response.data());
    }catch(e){
      print("error while fetching vendor details : $e");
      return null;
    }
    
  //  var response = _db.collection("/grocery/vendors/vendorList").document(vendorId).snapshots();
  //   return response.map((event) {
  //     print("vendor data : ${event.data}");
  //     return VendorMegaData.fromJson(event.data);
  //   });
  
  }

 //Featured Products ****
 Stream<List<Product>> fetchFeaturedProducts(String category, String supermarketId) {
   print("in stream: $category : $supermarketId");
    var response =  _db.collection("grocery/products/productList/$supermarketId/supermarketProducts").where('featureProduct', isEqualTo: true).where('productCategory' , isEqualTo: '$category').snapshots();
    return response.map((event) => event.docs.map((e){
      //  String id = e.documentID;
        Map<String,dynamic> data = e.data();
        Map<String,dynamic> idCollect = {'productId' : e.id};
        Map<String, dynamic> mergedMap = {};
        mergedMap.addAll(data);
        
        mergedMap.addAll(idCollect);
        return Product.fromJson(mergedMap);

    }).toList());
 }

 Future<bool> userDetailStore(String userId,String userName,String fullName,String email,String contactNumber,String profileUrl,DateTime birthDate) async{
    try{
      print(birthDate);
      var customerBirth = Timestamp.fromDate(birthDate);
      await _db.collection("grocery/vendors/vendorList").doc(userId).set({
        'userName' : userName,
        'fullName' : fullName,
        'email' : email,
        'contactNumber' : contactNumber,
        'profileUrl' : profileUrl,
        'birthDate' : customerBirth,
        'totalOrders': 0,
        'totalSales': 0,
        'totalDeliveries':0
      });
      return true;
    }catch(e){
      print("firebase service userDetailStore error :$e");
      return false;
    }
 }

 //fetch order history
   Future<QuerySnapshot> fetchOrders(String supermarketId,DocumentSnapshot lastDocument,bool fetchMore)async{ 
     //,DocumentSnapshot lastDocument
    var response;
    try{
      print("in service file to fetch orders:");
      print("in service file to fetch orders DOCUMENT SNAPSHOP: $lastDocument");
      print("in service file to fetch orders FETch More : $fetchMore");
      if(fetchMore){
       // print("true");
        response = await _db.collection("grocery/orders/orderList").where("supermarketId",isEqualTo: supermarketId).where("orderStatus", whereIn: ["Ready For Pickup","Order Packed","Order Delivered", "Order Cancelled", "Delivered", "Cancelled", "Customer not available"]).orderBy("orderPlacedDate",descending: true).startAfterDocument(lastDocument).limit(5).get();     
      }else{
        response = await _db.collection("grocery/orders/orderList").where("supermarketId",isEqualTo: supermarketId).where("orderStatus", whereIn: ["Ready For Pickup","Order Packed","Order Delivered", "Order Cancelled", "Delivered", "Cancelled", "Customer not available"]).orderBy("orderPlacedDate",descending: true).limit(10).get();  
        
      }
     print("customer orders fetchedfrom firebase service: $response");
      return response;
    }catch(e){
      print("error while fetching orders : $e");
      return null;
    }
  }
}
