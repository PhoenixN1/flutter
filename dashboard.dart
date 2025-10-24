import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app/users/utilisateur.dart';

import 'rapport.dart';
import 'package:my_app/users/login.dart';
import 'carte.dart';
import 'suivi.dart';
import 'profil.dart';


import 'theme_manager.dart';

class DashboardStat {
  final String title;
  final String count;
  final String subtitle;
  final Color color;
  final IconData icon;
  final double? percentage;

  DashboardStat({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.color,
    required this.icon,
    this.percentage,
  });
}

class RecentReport {
  final String title;
  final String location;
  final String time;
  final IconData icon;
  final Color color;
  final String status;
  final bool isUrgent;

  RecentReport({
    required this.title,
    required this.location,
    required this.time,
    required this.icon,
    required this.color,
    required this.status,
    this.isUrgent = false,
  });
}

class DashboardPage extends StatefulWidget {
  final Utilisateur loggedInUser;
  const DashboardPage({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  int selectedIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ThemeManager _themeManager;

  bool isLoading = true;

@override
@override
void initState() {
  super.initState();

  // user = widget.loggedInUser;

  _themeManager = ThemeManager();
  _themeManager.addListener(() {
    setState(() {});
  });

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

  Color get backgroundColor => _themeManager.backgroundColor;
  Color get surfaceColor => _themeManager.surfaceColor;
  Color get primaryColor => _themeManager.primaryColor;
  Color get textPrimary => _themeManager.textPrimary;
  Color get textSecondary => _themeManager.textSecondary;
  Color get successColor => _themeManager.successColor;
  Color get warningColor => _themeManager.warningColor;
  Color get errorColor => _themeManager.errorColor;

  List<DashboardStat> get stats => [
    DashboardStat(
      title: "Signalements Résolus",
      count: "147",
      subtitle: "+12 aujourd'hui",
      color: successColor,
      icon: FontAwesomeIcons.checkCircle,
      percentage: 8.2,
    ),
    DashboardStat(
      title: "En Cours",
      count: "23",
      subtitle: "5 prioritaires",
      color: warningColor,
      icon: FontAwesomeIcons.spinner,
      percentage: -2.1,
    ),
    DashboardStat(
      title: "Cas Critiques",
      count: "8",
      subtitle: "Action immédiate",
      color: errorColor,
      icon: FontAwesomeIcons.exclamationTriangle,
      percentage: 15.3,
    ),
    DashboardStat(
      title: "En Attente",
      count: "12",
      subtitle: "Assignation requise",
      color: textSecondary,
      icon: FontAwesomeIcons.clock,
    ),
  ];

  List<RecentReport> get recentReports => [
    RecentReport(
      title: "Urgence - Fuite d'eau majeure",
      location: "Avenue Mohammed V, Casablanca",
      time: "Il y a 15 minutes",
      icon: FontAwesomeIcons.tint,
      color: errorColor,
      status: "CRITIQUE",
      isUrgent: true,
    ),
    RecentReport(
      title: "Éclairage public défaillant",
      location: "Rue de la Paix, Rabat",
      time: "Il y a 2 heures",
      icon: FontAwesomeIcons.lightbulb,
      color: warningColor,
      status: "EN COURS",
    ),
    RecentReport(
      title: "Nettoyage effectué",
      location: "Place Hassan II, Fès",
      time: "Il y a 4 heures",
      icon: FontAwesomeIcons.broom,
      color: successColor,
      status: "RÉSOLU",
    ),
  ];

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
          "Tableau de Bord",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Roboto',
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _themeManager.toggleTheme();
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
      body: _buildScrollableContent(),
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
                const SizedBox(height: 8),
                
                  Text(
                    "${widget.loggedInUser.nom} - ${widget.loggedInUser.role}",
                    style: TextStyle(
                      color: textPrimary,
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
          true,
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
          false,
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
          ConnexionPage(),
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

  Widget _buildScrollableContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsGrid(),
            const SizedBox(height: 32),
            _buildRecentReportsSection(),
            const SizedBox(height: 32),
            _buildQuickActionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth > 800
            ? 4
            : constraints.maxWidth > 500
            ? 2
            : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) {
            return _buildStatCard(stats[index]);
          },
        );
      },
    );
  }

  Widget _buildStatCard(DashboardStat stat) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: stat.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FaIcon(stat.icon, color: stat.color, size: 20),
                ),
                const Spacer(),
                if (stat.percentage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: stat.percentage! >= 0
                          ? successColor.withOpacity(0.1)
                          : errorColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          stat.percentage! >= 0
                              ? FontAwesomeIcons.arrowUp
                              : FontAwesomeIcons.arrowDown,
                          size: 10,
                          color: stat.percentage! >= 0
                              ? successColor
                              : errorColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "${stat.percentage!.abs()}%",
                          style: TextStyle(
                            color: stat.percentage! >= 0
                                ? successColor
                                : errorColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              stat.count,
              style: TextStyle(
                color: textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat.title,
              style: TextStyle(
                color: textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              stat.subtitle,
              style: TextStyle(
                color: stat.color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Rapports Récents",
              style: TextStyle(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  RapportPage(loggedInUser: widget.loggedInUser)),
                );
              },
              icon: FaIcon(FontAwesomeIcons.eye, size: 16, color: primaryColor),
              label: Text("Voir Tout", style: TextStyle(color: primaryColor)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...recentReports.map((report) => _buildReportCard(report)),
      ],
    );
  }

  Widget _buildReportCard(RecentReport report) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: report.isUrgent
            ? Border.all(color: errorColor.withOpacity(0.3), width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: report.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FaIcon(report.icon, color: report.color, size: 18),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          report.title,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: report.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          report.status,
                          style: TextStyle(
                            color: report.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.mapMarkerAlt,
                        size: 12,
                        color: textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          report.location,
                          style: TextStyle(color: textSecondary, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.time,
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (report.isUrgent)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: FaIcon(
                  FontAwesomeIcons.exclamation,
                  color: errorColor,
                  size: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Actions Rapides",
          style: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                "Nouveau Rapport",
                FontAwesomeIcons.plus,
                primaryColor,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>  RapportPage(loggedInUser: widget.loggedInUser),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionButton(
                "Carte Urgences",
                FontAwesomeIcons.mapMarkedAlt,
                successColor,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  CartePage(loggedInUser: widget.loggedInUser)),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ConnexionPage()),
    );
  }
}
