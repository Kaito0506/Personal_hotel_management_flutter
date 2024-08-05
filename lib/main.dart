import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_hotel/Style/myStyle.dart';
import 'Database/Services.dart';
import 'package:my_hotel/Pages/roomDetail.dart';

import 'Models/Tenants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MaterialApp(
    home: MainPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  final Service _services = Service();

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _navigateToRoomDetail(Map<String, dynamic> room) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Roomdetail(room: room)),
    );
    if (result == true) {
      setState(() {}); // Refresh the main page after returning from RoomDetail
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Trang chủ',
          style: styles.titleStyle,
        ),
        backgroundColor: styles.mainColor,
        centerTitle: true,
        // no back arow hear
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph_outlined),
            label: 'Thống kê',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: styles.mainColor,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Add your onPressed code here!
        },
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _services.getRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final rooms = snapshot.data!;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.8,
              ),
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                final tenant = room['currentTenant'] as Tenant?;

                return GestureDetector(
                  onTap: () => _navigateToRoomDetail(room),
                  child: Card(
                    color: room['isOccupied'] ? Colors.grey : Colors.orange,
                    child: Column(
                      children: [
                        SizedBox(height: 40),
                        ListTile(
                          title: Center(
                            child: Text(
                              '${room['roomName']}',
                              style: styles.titleStyle,
                            ),
                          ),
                          subtitle: Center(
                            child: Text(
                              '${room['tenantName']}',
                              style: styles.normalStyle,
                            ),
                          ),
                        ),
                        if (room['isOccupied'] && tenant != null)
                          Column(
                            children: [
                              Text("Vào: ${tenant.startDate}", style: styles.normalStyle),
                              Text("SĐT: ${tenant.phone}", style: styles.normalStyle),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
