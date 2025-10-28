// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'utilisateur.dart';

// import 'dashboard.dart';
// import 'rapport.dart';
// import 'carte.dart';
// import 'suivi.dart';
// import 'profil.dart';
// import 'login.dart';

// class LogoutPage extends StatelessWidget {
//   final Utilisateur loggedInUser;
  
//   const LogoutPage({Key? key, required this.loggedInUser}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1A1A2E),
//       appBar: AppBar(
//         title: const Text("Logout", style: TextStyle(color: Colors.white)),
//         backgroundColor: const Color(0xFFE94560),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       drawer: Drawer(
//         child: Container(
//           color: const Color(0xFF16213E),
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               Container(
//                 height: 120,
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
//                   ),
//                 ),
//                 alignment: Alignment.center,
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: const [
//                     FaIcon(
//                       FontAwesomeIcons.shieldAlt,
//                       color: Color(0xFFE94560),
//                       size: 28,
//                     ),
//                     SizedBox(width: 10),
//                     Text(
//                       "CityGuard",
//                       style: TextStyle(
//                         color: Color(0xFFE94560),
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               buildDrawerItem(
//                 context,
//                 FontAwesomeIcons.fileAlt,
//                 "Rapports",
//                  RapportPage(loggedInUser: widget.loggedInUser),
//                 false,
//               ),
//               buildDrawerItem(
//                 context,
//                 FontAwesomeIcons.mapMarkedAlt,
//                 "Carte",
//                  CartePage(loggedInUser: widget.loggedInUser),
//                 false,
//               ),
//               buildDrawerItem(
//                 context,
//                 FontAwesomeIcons.chartLine,
//                 "Suivi",
//                 SuiviPage(loggedInUser: loggedInUser),
//                 false,
//               ),
//               buildDrawerItem(context, FontAwesomeIcons.userCircle, "Profil", ProfilPage(loggedInUser: widget.loggedInUser), false),
//               const Divider(color: Color(0xFF0F3460), thickness: 1, height: 32),
//               buildDrawerItem(
//                 context,
//                 FontAwesomeIcons.signOutAlt,
//                 "Logout",
//                 const ConnexionPage(),
//                 false,
//               ),
//             ],
//           ),
//         ),
//       ),

//       body: const Center(
//         child: Text(
//           "Logout",
//           style: TextStyle(fontSize: 24, color: Colors.white),
//         ),
//       ),
//     );
//   }

//   Widget buildDrawerItem(
//     BuildContext context,
//     IconData icon,
//     String title,
//     Widget page,
//     bool isActive,
//   ) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           borderRadius: BorderRadius.circular(12),
//           onTap: () {
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => page),
//             );
//           },
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             decoration: BoxDecoration(
//               color: isActive
//                   ? const Color(0xFF0F3460).withOpacity(0.3)
//                   : Colors.transparent,
//               borderRadius: BorderRadius.circular(12),
//               border: isActive
//                   ? Border.all(color: const Color(0xFFE94560), width: 1)
//                   : null,
//             ),
//             child: Row(
//               children: [
//                 FaIcon(
//                   icon,
//                   color: isActive ? const Color(0xFFE94560) : Colors.white,
//                   size: 20,
//                 ),
//                 const SizedBox(width: 16),
//                 Text(
//                   title,
//                   style: TextStyle(
//                     color: isActive ? const Color(0xFFE94560) : Colors.white,
//                     fontSize: 16,
//                     fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
