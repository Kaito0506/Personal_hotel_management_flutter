
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_hotel/Models/Tenants.dart';
import 'package:my_hotel/Style//myStyle.dart';
import 'package:intl/intl.dart';
import 'package:my_hotel/main.dart';
import 'package:my_hotel/Database/Services.dart';

class Addtenant extends StatefulWidget {
  final room ;
  const Addtenant({super.key, this.room});

  @override
  State<Addtenant> createState() => _AddtenantState();
}

class _AddtenantState extends State<Addtenant> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameCtl = TextEditingController();
  TextEditingController phoneCtl = TextEditingController();
  TextEditingController dobCtl = TextEditingController();
  TextEditingController startDateCtl = TextEditingController();
  TextEditingController cccdCtl = TextEditingController();
  bool _isLoading = false;

  final Service _service = Service();
  ////////////function to choose date


  @override
  Widget build(BuildContext context) {
    final room = widget.room;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: styles.mainColor,
        title: Text("Thêm người thuê", style: styles.titleStyle,),
        centerTitle: true,
      ),
      ///////////////////////////////BODY
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text("${room['roomName']}", style: styles.titleStyle,),
                ),
                Text(
                  "Họ và tên: ",
                  style: styles.normalStyle_bold,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: nameCtl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Họ và tên",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hãy nhập tên người thuê';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text(
                  "Ngày sinh: ",
                  style: styles.normalStyle_bold,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: dobCtl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Ngày sinh",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  readOnly: true,
                  onTap: (){
                    setState(() async {
                      dobCtl.text = await  _service.selectDate(context);
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nhập ngày sinh';
                    }
                    return null;
                  },
                ),
                Text(
                  "Căn cước công dân: ",
                  style: styles.normalStyle_bold,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: cccdCtl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "CCCD",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.credit_card),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hãy nhập cccd';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text(
                  "Số điện thoại: ",
                  style: styles.normalStyle_bold,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: phoneCtl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Số điện thoại",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Hãy nhập số điện thoại';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                Text(
                  "Ngày bắt đầu: ",
                  style: styles.normalStyle_bold,
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: startDateCtl,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Ngày bắt đầu",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  readOnly: true,
                  onTap: () {
                    setState(() async {
                      startDateCtl.text = await  _service.selectDate(context);
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nhập ngày bắt đầu';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : Center(
                  child: ElevatedButton(
                    onPressed: () async{

                      if (_formKey.currentState!.validate()) {
                        final newTenant = Tenant(
                          name: nameCtl.text,
                          dob: dobCtl.text,
                          cccd: cccdCtl.text,
                          phone: phoneCtl.text,
                          startDate: startDateCtl.text,
                          endDate: null,
                        );
                        setState(() {
                          _isLoading = true;
                        });
                        await _service.addTenant(context, room['roomId'], newTenant);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.app_registration_outlined, color: Colors.white,),
                        Text(
                          "Thêm",
                          style: styles.normalStyle_bold.copyWith(color: Colors.white),
                        )
                      ],
                    ),
                  ),
                ),
          
              ],
            ),
          ),
        ),
      ),
    );
  }
}
