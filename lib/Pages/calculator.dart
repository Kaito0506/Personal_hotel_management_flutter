import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_hotel/Style/myStyle.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:my_hotel/Database/Services.dart';

class CashPage extends StatefulWidget {
  final Map<String, dynamic>? room;
  const CashPage({super.key, required this.room});

  @override
  State<CashPage> createState() => _CashPageState();
}

class _CashPageState extends State<CashPage> {
  final _service = Service();

  @override
  Widget build(BuildContext context) {
    final room = widget.room;
    final utilitiesList = room?['utilities'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Thu tiền', style: styles.titleStyle),
        centerTitle: true,
        backgroundColor: styles.mainColor,
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _service.getPrices(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('No data available'));
            }

            final pricesList = snapshot.data!;
            final rentPrice = pricesList['rentPrice'] ?? 0;
            final electricPrice = pricesList['electricPrice'] ?? 0;
            final waterPrice = pricesList['waterPrice'] ?? 0;

            return Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Phòng: ', style: styles.normalStyle_bold),
                      Text('${room?['roomName']}'.substring(6, 8), style: styles.normalStyle),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Người thuê: ', style: styles.normalStyle_bold),
                      Text('${room?['currentTenant'].name}', style: styles.normalStyle),
                    ],
                  ),
                  Row(
                    children: [
                      Text('Giá phòng: ', style: styles.normalStyle_bold),
                      Text('${rentPrice.toString()}', style: styles.normalStyle),
                      Text(' đ', style: styles.normalStyle),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Giá điện: ', style: styles.normalStyle_bold),
                      Text('${electricPrice.toString()}', style: styles.normalStyle),
                      Text(' đ/kWh', style: styles.normalStyle),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Text('Giá nước: ', style: styles.normalStyle_bold),
                      Text('${waterPrice.toString()}', style: styles.normalStyle),
                      Text(' đ/khối', style: styles.normalStyle),
                    ],
                  ),
                  SizedBox(height: 10),
                  Container(
                    child: SingleChildScrollView(
                      child: ExpansionPanelList(
                        children: utilitiesList.map<ExpansionPanel>((final utility) {
                          final electricityCost = utility['electricity'] * electricPrice;
                          final waterCost = utility['water'] * waterPrice;
                          final totalCost = electricityCost + waterCost + rentPrice;

                          return ExpansionPanel(
                            headerBuilder: (BuildContext context, bool isExpanded) {
                              return Container(
                                child: ListTile(
                                  title: Text('${utility['id']}', style: styles.normalStyle_bold),
                                ),
                              );
                            },
                            body: Container(
                              child: Column(
                                children: [
                                  Text(
                                    "Điện: ${utility['electricity'].toString()} x ${electricPrice.toString()} = ${electricityCost.toString()} đ",
                                    style: styles.normalStyle,
                                  ),
                                  Text(
                                    "Nước: ${utility['water'].toString()} x ${waterPrice.toString()} = ${waterCost.toString()} đ",
                                    style: styles.normalStyle,
                                  ),
                                  Text(
                                    "Phòng: ${rentPrice.toString()} đ",
                                    style: styles.normalStyle,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "Tổng cộng: ${totalCost.toString()} đ",
                                    style: styles.normalStyle_bold,
                                  ),
                                  SizedBox(height: 15,),
                                  Center(
                                    child: ElevatedButton(
                                        onPressed: (){},
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.payments_outlined),
                                            Text('Thanh toán', style: styles.normalStyle_bold,)
                                          ],
                                        ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                        foregroundColor: Colors.white
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            isExpanded: true,
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  if (utilitiesList != null) ...[
                    SizedBox(height: 20),
                    Text('Utilities:', style: styles.normalStyle_bold),
                    for (var utility in utilitiesList)
                      for (var entry in utility.entries)
                        Text('${entry.key}: ${entry.value}', style: styles.normalStyle),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
