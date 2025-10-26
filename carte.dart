import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app/users/login.dart';

import 'dashboard.dart';
import 'rapport.dart';
import 'suivi.dart';
import 'profil.dart';
// import 'logout.dart';
import 'theme_manager.dart'; 
import 'utilisateur.dart';

class CartePage extends StatefulWidget {
  final Utilisateur loggedInUser;
  const CartePage({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  State<CartePage> createState() => _CartePageState();
}

class _CartePageState extends State<CartePage> with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  LatLng? _currentPosition;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ThemeManager _themeManager; 

    Utilisateur? loggedInUser;
  bool isLoading = true;

  Color get backgroundColor => _themeManager.backgroundColor;
  Color get surfaceColor => _themeManager.surfaceColor;
  Color get primaryColor => _themeManager.primaryColor;
  Color get textPrimary => _themeManager.textPrimary;
  Color get textSecondary => _themeManager.textSecondary;

  @override
  void initState() {
    super.initState();
    _themeManager = ThemeManager(); 
    _themeManager.addListener(() {
      setState(() {}); 
    });

    _getCurrentLocation();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _mapController.move(_currentPosition!, 15);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        title: Text(
          "Carte Interactive",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _themeManager
                  .toggleTheme(); 
            },
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: FaIcon(
                _themeManager.isDarkMode
                    ? FontAwesomeIcons.sun
                    : FontAwesomeIcons.moon,
                key: ValueKey(_themeManager.isDarkMode),
                color: Colors.white,
                size: 20,
              ),
            ),
            tooltip: _themeManager.isDarkMode ? 'Mode Clair' : 'Mode Sombre',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildMapContent(),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: surfaceColor,
      child: Column(
        children: [
          _buildDrawerHeader(),
          Expanded(child: _buildNavigationMenu()),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryColor.withOpacity(0.1), surfaceColor],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FaIcon(
              FontAwesomeIcons.shieldAlt,
              color: primaryColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "CityGuard",
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Roboto',
                  ),
                ),
                Text(
                  "Surveillance Urbaine",
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationMenu() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        _buildDrawerItem(
          FontAwesomeIcons.tachometerAlt,
          "Dashboard",
           DashboardPage(loggedInUser: widget.loggedInUser),
          false,
        ),
        _buildDrawerItem(
          FontAwesomeIcons.fileAlt,
          "Rapports",
           RapportPage(loggedInUser: widget.loggedInUser),
          false,
        ),
        _buildDrawerItem(
          FontAwesomeIcons.mapMarkedAlt,
          "Carte",
           CartePage(loggedInUser: widget.loggedInUser),
          true,
        ),
        _buildDrawerItem(
          FontAwesomeIcons.chartLine,
          "Suivi",
          SuiviPage(loggedInUser: widget.loggedInUser),
          false,
        ),
        _buildDrawerItem(
          FontAwesomeIcons.userCircle,
          "Profil",
           ProfilPage(loggedInUser: widget.loggedInUser),
          false,
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Divider(
            color: const Color(0xFF0F3460),
            thickness: 1,
            height: 32,
          ),
        ),
        _buildDrawerItem(
          FontAwesomeIcons.signOutAlt,
          "Logout",
          const ConnexionPage(),
          false,
        ),
      ],
    );
  }

  Widget _buildDrawerItem(
    IconData icon,
    String title,
    Widget page,
    bool isActive,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pop(context); 
            if (title == "Logout") {
              _handleLogout();
            } else if (!isActive) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => page),
              );
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isActive
                  ? primaryColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(color: primaryColor.withOpacity(0.3), width: 1)
                  : null,
            ),
            child: Row(
              children: [
                FaIcon(
                  icon,
                  color: isActive ? primaryColor : textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isActive ? primaryColor : textPrimary,
                      fontSize: 16,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontFamily: 'Roboto',
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

  Widget _buildMapContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                children: [
                  TileLayer(
                    urlTemplate:
                        "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                    userAgentPackageName: 'com.example.my_app',
                  ),
                  if (_currentPosition != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentPosition!,
                          width: 25,
                          height: 25,
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: Column(
                  children: [
                    FloatingActionButton(
                      backgroundColor: primaryColor,
                      heroTag: "location",
                      onPressed: () {
                        if (_currentPosition != null) {
                          _mapController.move(_currentPosition!, 18);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  FaIcon(
                                    FontAwesomeIcons.mapMarkerAlt,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text("Position actuelle localisée"),
                                ],
                              ),
                              backgroundColor: primaryColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: const Icon(Icons.my_location, color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton(
                      backgroundColor: surfaceColor,
                      heroTag: "zoom_in",
                      mini: true,
                      onPressed: () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                        );
                      },
                      child: FaIcon(
                        FontAwesomeIcons.plus,
                        color: primaryColor,
                        size: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    FloatingActionButton(
                      backgroundColor: surfaceColor,
                      heroTag: "zoom_out",
                      mini: true,
                      onPressed: () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1,
                        );
                      },
                      child: FaIcon(
                        FontAwesomeIcons.minus,
                        color: primaryColor,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surfaceColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: FaIcon(
                          FontAwesomeIcons.mapMarkedAlt,
                          color: primaryColor,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Surveillance en temps réel",
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
    );
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        title: Text("Déconnexion", style: TextStyle(color: textPrimary)),
        content: Text(
          "Êtes-vous sûr de vouloir vous déconnecter ?",
          style: TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Annuler", style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ConnexionPage()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text(
              "Déconnecter",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
