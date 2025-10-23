import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
// import 'users/dashboard.dart';
import 'admins/dashboard.dart';
import 'users/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CityGuard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      debugShowCheckedModeBanner: false,
      home: MainPage(),
      routes: {
        '/users': (context) => InscriptionPage(),
        '/admin': (context) => DashboardAdmin(),
      },
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromRGBO(26, 26, 46, 1),
              Color(0xFF16213e),
            ],
          ),
        ),
        child: Stack(
          children: [
            
            ...List.generate(100, (index) => Positioned(
              left: (index * 47) % MediaQuery.of(context).size.width,
              top: (index * 94) % MediaQuery.of(context).size.height,
              child: Container(
                width: 2,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
            )),
            
            SafeArea(
              child: Padding(
                padding: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    Padding(
                      padding: EdgeInsets.only(top: 0, bottom: 0),
                      child: Text(
                        'CityGuard',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB0B3C7),
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    SizedBox(height: 100),
                    
                    Container(
                      width: double.infinity,
                      height: 250,
                      margin: EdgeInsets.only(bottom: 20),
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Color(0xFF2C3050),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFF00ADB5),
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/admin'),
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.userTie, 
                                  color: Color(0xFF00ADB5),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Admin',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF00ADB5),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Gestion des rapports, utilisateurs, et statistiques.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    
                    Container(
                      width: double.infinity,
                      height: 250,
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Color(0xFF16213e),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Color(0xFFe94560),
                          width: 2,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, '/users'),
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.users, 
                                  color: Color(0xFFe94560),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'User',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFe94560),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Soumettre un rapport, voir l\'état et la carte des incidents.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
