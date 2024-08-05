import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_hotel/Models/Tenants.dart';

import '../main.dart';

class Service {
  FirebaseFirestore database = FirebaseFirestore.instance;
  // Fetch all rooms with tenant information and utilities data, this funtions is used for sub-collection tenants
  // Future<List<Map<String, dynamic>>> getRooms() async {
  //   QuerySnapshot roomSnapshot = await database.collection('rooms').get();
  //   List<Map<String, dynamic>> roomList = [];
  //
  //   for (var room in roomSnapshot.docs) {
  //     var roomData = room.data() as Map<String, dynamic>;
  //     DocumentReference? tenantRef = roomData['currentTenant'];
  //     bool isOccupied = roomData['isOccupied'] ?? false;
  //     String currentTenant = "Còn trống";
  //     if(isOccupied){
  //       QuerySnapshot tenantSnapshot = await database
  //           .collection('rooms')
  //           .doc(room.id)
  //           .collection('tenants').get();
  //       if (tenantSnapshot.docs.isNotEmpty) {
  //         var tenantData = tenantSnapshot.docs.first.data() as Map<String, dynamic>;
  //         currentTenant = tenantData['name'];
  //         print("hello");
  //       }
  //     }
  //     roomList.add({
  //       'roomId': room.id,
  //       'roomName': roomData['roomName'],
  //       'tenantName': currentTenant,
  //       'isOccupied': isOccupied,
  //     });
  //   }
  //
  //   return roomList;
  // }
  // this function for tenst collect in root level
  Future<List<Map<String, dynamic>>> getRooms() async {
    QuerySnapshot roomSnapshot = await database.collection('rooms').orderBy('roomName').get();
    List<Map<String, dynamic>> roomList = [];
    for (var room in roomSnapshot.docs) {
      var roomData = room.data() as Map<String, dynamic>;
      DocumentReference? tenantRef = roomData['currentTenant'];
      bool isOccupied = roomData['isOccupied'] ?? false;
      String currentTenantName = "Còn trống";
      Tenant? tenant;

      if (tenantRef != null) {
        try {
          DocumentSnapshot tenantDoc = await tenantRef.get();
          if (tenantDoc.exists) {
            var tenantData = tenantDoc.data() as Map<String, dynamic>;
            currentTenantName = tenantData['name'];
            tenant = Tenant(
              name: tenantData['name'],
              dob: tenantData['dob'],
              cccd: tenantData['cccd'],
              phone: tenantData['phone'],
              startDate: tenantData['startDate'],
              endDate: tenantData['endDate'],
            );
          } else {
            print("Tenant document does not exist for reference: $tenantRef");
          }
        } catch (e) {
          print("Error fetching tenant document: $e");
        }
      } else {
        print("Tenant reference is null for room: ${room.id}");
      }

      List<Map<String, dynamic>> uts = await getUtilities(room.id);
      roomList.add({
        'roomId': room.id,
        'roomName': roomData['roomName'],
        'tenantName': currentTenantName,
        'isOccupied': isOccupied,
        'currentTenant': tenant,
        'utilities': uts
      });
    }
    return roomList;
  }


  // Fetch utilities data for a specific room
  Future<List<Map<String, dynamic>>> getUtilities(String roomId) async {
    //print("qquery utilities of room: ${roomId}");
    QuerySnapshot utilitiesSnapshot = await database
        .collection('rooms')
        .doc(roomId)
        .collection('utilities')
        .get();

    List<Map<String, dynamic>> utilitiesList = [];

    for (var utility in utilitiesSnapshot.docs) {
      var utilityData = utility.data() as Map<String, dynamic>;
      utilitiesList.add({
        'id': utility.id,
        'electricity': utilityData['electricity'],
        'water': utilityData['water'],
        'isExpanded': false,
        'rentPaid': utilityData['rentPaid'],
        'readTime': utilityData['readTime']
      });
    }
    utilitiesList = utilitiesList.reversed.toList();
    return utilitiesList;
  }


  /////////////////////////////////////////////
  Future<String> selectDate(BuildContext context) async{
    DateTime? pickedDate = await showDatePicker(
        context: context,
        firstDate: DateTime(1930),
        lastDate: DateTime(2030),
        initialDate: DateTime.now()
    );
    if(pickedDate != null){
      return DateFormat('dd-MM-yyy').format(pickedDate);
    }else{
      return DateFormat('dd-MM-yyy').format(DateTime.now());
    }
  }
/////////////Funtion to ADD new Tennant
  Future<void> addTenant(BuildContext context, String roomId, Tenant t) async{
    try{
      QuerySnapshot oldTenant = await FirebaseFirestore
          .instance
          .collection('tenants')
          .where('cccd', isEqualTo: t.cccd).get();
      DocumentReference tenRef ;
      if(oldTenant.docs.isNotEmpty){
        print('This tenant already exists in database');
        tenRef = oldTenant.docs.first.reference;
        await tenRef.update({
          'startDate': t.startDate,
          'endDate' : null,
          'roomId': "/rooms/$roomId",
        });
      }else{
        tenRef = await FirebaseFirestore.instance.collection('tenants')
            .add({
          'name': t.name,
          'dob': t.dob,
          'cccd': t.cccd,
          'phone': t.phone,
          'startDate': t.startDate,
          'endDate': t.endDate,
          'roomId': "/rooms/$roomId",
        });
        print("Add new tenant successfully");
      }

      ///// update roomstatus
      await updateRoomStatus(roomId, tenRef);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MainPage()));
    }catch(e){
      print("Error while adding new tenant $e");
    }
  }
/////////  FUNCTION UPDATE ROOM STATUS
  Future<void> updateRoomStatus(String roomId, DocumentReference tent) async{
    try{
      await database.collection('rooms')
          .doc(roomId).update({
        'isOccupied': true,
        'currentTenant': tent
      });
      print("Update room status successfully");
    }catch(e){
      print("Error while updating room status $e");
    }
  }
  /////////////////////////////////
  Future<void> leaveRoom(BuildContext context, String roomId) async{
    try{
      await FirebaseFirestore.instance.collection('rooms').doc(roomId).update(
          {
            'currentTenant': null,
            'isOccupied': false,
          }
      );
      print("Return room successfully");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MainPage()));
    }catch(e){
      print('Error while return room $e');
    }
  }

/////////////
  Future<Map<String, dynamic>> getPrices() async{
    QuerySnapshot snap = await database.collection('prices').get();
    Map<String, dynamic> prices;
    prices = snap.docs.first.data() as Map<String, dynamic>;
    return prices;
  }

  //////////////////////


  Future<void> addUtility (BuildContext context, String roomId, int water, int electric) async{
    String time = DateFormat('dd-MM-yyyy').format(DateTime.now()).substring(3,10);
      try{
        await database.collection('rooms')
            .doc(roomId)
            .collection('utilities')
            .doc(time).set({
              'water': water,
              'electricity': electric,
              'readTime' : DateFormat('dd-MM-yyyy').format(DateTime.now()),
              'rentPaid': false
            });
        print("Writing successfully");
      }catch(e){
        print("this month has been read");
        print('$e');
      }
  }








}
////////////////////////////



