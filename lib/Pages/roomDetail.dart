import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_hotel/Database/Services.dart';
import 'package:my_hotel/Models/Utilities.dart';
import 'package:my_hotel/Pages/addTenant.dart';
import 'package:my_hotel/Pages/calculator.dart';
import 'package:my_hotel/Style/myStyle.dart';
import 'package:my_hotel/main.dart';

class Roomdetail extends StatefulWidget {
  final Map<String, dynamic>? room;

  const Roomdetail({super.key, this.room});

  @override
  State<Roomdetail> createState() => _RoomdetailState();
}

class _RoomdetailState extends State<Roomdetail> {
  bool _isLoading = false;
  final Service _service = Service();
  late String water, electric;
  final _formkey = GlobalKey<FormState>();
  final waterCtl = TextEditingController();
  final elecCtl = TextEditingController();
  List<Map<String, dynamic>> utilitiesList = [];

  @override
  void initState() {
    super.initState();
    fetchUtilities();
  }

  // Function to fetch utilities
  Future<void> fetchUtilities() async {
    setState(() {
      _isLoading = true;
    });
    if (widget.room?['roomId'] != null) {
      List<Map<String, dynamic>> uts = await _service.getUtilities(widget.room!['roomId']);
      setState(() {
        utilitiesList = uts;
      });
      for(var i in uts){
        print('${i['readTime']}');
      }
    }
    _isLoading = false;
  }
  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final test = room?['utilities'];
    for (var t in test){
      print(t['readTime'].toString());
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${room?['roomName']}',
          style: styles.titleStyle,
        ),
        backgroundColor: styles.mainColor,
        centerTitle: true,
        actions: [
          !room?['isOccupied']
              ? IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Addtenant(room: room)));
              if (result == true) {
                // Reload the data if tenant was added
                setState(() {});
              }
            },
            icon: Icon(
              Icons.add,
              size: 50,
            ),
          )
              : Text(' '),
        ],
      ),
      /////////////////BODY

      body: SingleChildScrollView(
        child: Column(
          children: [
            room?['isOccupied']
                ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(
                        Icons.person,
                        size: 120.0,
                      ),
                    ),
                    Row(children: [
                      Text(
                        'Nguời thuê: ',
                        style: styles.normalStyle_bold,
                      ),
                      Text(
                        '${room?['currentTenant'].name}',
                        style: styles.normalStyle,
                      )
                    ]),
                    SizedBox(
                      height: 10,
                    ),
                    ////////////////////////////////////////////////////
                    Row(children: [
                      Text(
                        'Ngày sinh: ',
                        style: styles.normalStyle_bold,
                      ),
                      Text(
                        '${room?['currentTenant']?.dob}',
                        style: styles.normalStyle,
                      )
                    ]),

                    SizedBox(
                      height: 10,
                    ),
                    ////////////////////////////////////////////////////
                    Row(children: [
                      Text(
                        'CCCD: ',
                        style: styles.normalStyle_bold,
                      ),
                      Text(
                        '${room?['currentTenant']?.cccd}',
                        style: styles.normalStyle,
                      )
                    ]),
                    SizedBox(
                      height: 10,
                    ),
                    ////////////////////////////////////////////////////
                    Row(children: [
                      Text(
                        'SĐT: ',
                        style: styles.normalStyle_bold,
                      ),
                      Text(
                        '${room?['currentTenant']?.phone}',
                        style: styles.normalStyle,
                      )
                    ]),
                    SizedBox(
                      height: 10,
                    ),
                    Row(children: [
                      Text(
                        'Vào ngày: ',
                        style: styles.normalStyle_bold,
                      ),
                      Text(
                        '${room?['currentTenant']?.startDate}',
                        style: styles.normalStyle,
                      )
                    ]),
                    //SizedBox(height: 10,),
                    ////////////////////////////////////////////////////

                    ////////////////// SHow điện nước
                  ],
                ),
              ),
            )
                :
            ////  IF THE ROOM IS CURRENTLY EMPTY
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Center(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/exc.png',
                        height: 100,
                        width: 100,
                      ),
                      Text(
                        'Hiện tại phòng đang trống',
                        style: styles.normalStyle_bold,
                      ),
                    ],
                  )),
            ),

            //////////////////////////////////////////SHOW THE LIST UTILITIES
            SizedBox(
              height: 30,
            ),
            Row(children: [
              Text(
                'Điện & nước: ',
                style: styles.normalStyle_bold,
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext bContext) {
                        return AlertDialog(
                          title: Center(
                              child: Text(
                                'Ghi điện nước',
                                style: styles.titleStyle,
                              )),
                          content: Form(
                            key: _formkey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Chỉ số điện',
                                  style: styles.normalStyle_bold,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  controller: elecCtl,
                                  onChanged: (String value) {
                                    electric = value;
                                  },
                                  decoration: InputDecoration(
                                      label: Text(
                                        'Điện',
                                        style: styles.normalStyle,
                                      ),
                                      border: OutlineInputBorder(),
                                      icon: Icon(
                                        Icons.electric_bolt,
                                        color: Colors.yellow,
                                      )),
                                  autofocus: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Hãy nhập chỉ số điện';
                                    }
                                  },
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                /////////////////////////
                                Text(
                                  'Chỉ số nước',
                                  style: styles.normalStyle_bold,
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                TextFormField(
                                  controller: waterCtl,
                                  onChanged: (String value) {
                                    water = value;
                                  },
                                  decoration: InputDecoration(
                                      label: Text(
                                        'Nước',
                                        style: styles.normalStyle,
                                      ),
                                      border: OutlineInputBorder(),
                                      icon: Icon(
                                        Icons.water_drop_outlined,
                                        color: Colors.blue,
                                      )),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Hãy nhập chỉ số nước';
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Icon(Icons.cancel)),
                            _isLoading
                                ? CircularProgressIndicator()
                                : ElevatedButton(
                                onPressed: () async {
                                  await _service.addUtility(context,
                                      room?['roomId'], int.parse(water), int.parse(electric));
                                  await fetchUtilities(); // Reload utilities after adding
                                  Navigator.of(context).pop();
                                },
                                child: Icon(Icons.check)),
                          ],
                        );
                      });
                },
                child: Text(
                  "Ghi điện & nước",
                  style: styles.normalStyle_bold,
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white),
              ),
            ]),
            Container(
              height: room?['isOccupied'] ? 400 : 700,
              child: SingleChildScrollView(
                child: ExpansionPanelList(
                  expansionCallback: (int index, bool isExpanded) {
                    setState(() {
                      utilitiesList[index]['isExpanded'] =
                      !utilitiesList[index]['isExpanded'];
                    });
                  },
                  children: utilitiesList.map<ExpansionPanel>((final utility) {
                    return ExpansionPanel(
                      headerBuilder:
                          (BuildContext context, bool isExpanded) {
                        return Container(
                          decoration: BoxDecoration(
                            color: !utility['rentPaid']
                                ? Colors.red[100]
                                : Colors.green[100], // Background color for header
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: ListTile(
                            title: Row(
                              children: [
                                utility['rentPaid']
                                    ? Icon(Icons.check)
                                    : Icon(Icons.cancel),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  utility['id'],
                                  style: styles.normalStyle_italic
                                      .copyWith(fontWeight: FontWeight.bold), // Text style
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      body: Container(
                        padding: EdgeInsets.all(10.0), // Padding inside the body
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color for body
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Điện: ${utility['electricity'].toString()} kWh",
                              style: styles.normalStyle,
                            ),
                            Text("Nước: ${utility['water'].toString()} Khối",
                                style: styles.normalStyle),
                            if (utility['readTime'] != null)
                              Text(
                                "Ngày ghi: ${utility['readTime'].toString()}",
                                style: styles.normalStyle,
                              ),
                          ],
                        ),
                      ),
                      isExpanded: utility['isExpanded'],
                    );
                  }).toList(),
                ),
              ),
            ),

            SizedBox(
              height: 10,
            ),
            room?['isOccupied']
                ? Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext bContext) {
                            return AlertDialog(
                              title: Text(
                                'Xác nhận',
                                style: styles.normalStyle_bold,
                              ),
                              content: Text(
                                'Bạn có chắc muốn trả phòng',
                                style: styles.normalStyle,
                              ),
                              actions: [
                                ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Icon(Icons.cancel)),
                                _isLoading
                                    ? CircularProgressIndicator()
                                    : ElevatedButton(
                                    onPressed: () {
                                      _service.leaveRoom(
                                          context, room?['roomId']);
                                      Navigator.of(context).pop();
                                    },
                                    child: Icon(Icons.check)),
                              ],
                            );
                          });
                    },
                    child: Text(
                      "Trả phòng",
                      style: styles.normalStyle_bold,
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CashPage(room: room)));
                    },
                    child: Text(
                      "Thu tiền",
                      style: styles.normalStyle_bold,
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white),
                  )
                ],
              ),
            )
                : Text('')
          ],
        ),
      ),
    );
  }
}
