import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_app/users/login.dart';
import 'utilisateur.dart';

import 'dashboard.dart';
import 'carte.dart';
import 'suivi.dart';
import 'profil.dart';
import 'theme_manager.dart';
import 'CreationRapport.dart';

class RapportPage extends StatefulWidget {
  final Utilisateur loggedInUser;
  const RapportPage({Key? key, required this.loggedInUser}) : super(key: key);

  @override
  State<RapportPage> createState() => _RapportPageState();
}

class _RapportPageState extends State<RapportPage>
    with TickerProviderStateMixin {
  String selectedFilter = 'Tous';
  String selectedSortBy = 'Date';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ThemeManager _themeManager;
  Utilisateur? loggedInUser;
  List<Map<String, dynamic>> rapports = [];
  bool isLoading = true;

  Color get backgroundColor => _themeManager.backgroundColor;
  Color get surfaceColor => _themeManager.surfaceColor;
  Color get primaryColor => _themeManager.primaryColor;
  Color get textPrimary => _themeManager.textPrimary;
  Color get textSecondary => _themeManager.textSecondary;
  Color get successColor => _themeManager.successColor;
  Color get warningColor => _themeManager.warningColor;
  Color get errorColor => _themeManager.errorColor;

  @override
  @override
  void initState() {
    super.initState();
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

    fetchRapports();
  }

  Future<void> fetchRapports() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://192.168.8.178/my_app/rapport.php'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          rapports = data.map((e) => e as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    } catch (e) {
      print('Erreur fetchRapports: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filteredRapports {
    List<Map<String, dynamic>> filtered = rapports;

    if (selectedFilter != 'Tous') {
      String filterStatus = selectedFilter.toUpperCase();
      if (selectedFilter == 'En attente') filterStatus = 'EN ATTENTE';
      if (selectedFilter == 'En cours') filterStatus = 'EN COURS';
      if (selectedFilter == 'Résolu') filterStatus = 'RESOLU';

      filtered = filtered
          .where((rapport) => rapport['statut'] == filterStatus)
          .toList();
    }

    filtered.sort((a, b) {
      switch (selectedSortBy) {
        case 'Date':
          return b['date'].compareTo(a['date']);
        case 'Priorité':
          return a['priority'].compareTo(b['priority']);
        case 'Statut':
          return a['statut'].compareTo(b['statut']);
        default:
          return 0;
      }
    });

    return filtered;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'EN ATTENTE':
        return warningColor;
      case 'EN COURS':
        return primaryColor;
      case 'RESOLU':
        return successColor;
      default:
        return warningColor;
    }
  }

  Color getUrgencyColor(String urgency) {
    switch (urgency) {
      case 'HAUTE':
        return errorColor;
      case 'MOYENNE':
        return warningColor;
      case 'BASSE':
        return successColor;
      default:
        return warningColor;
    }
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
          "Mes Rapports",
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
          true,
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

  Widget _buildScrollableContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsOverview(),
            const SizedBox(height: 24),
            _buildFiltersAndSort(),
            const SizedBox(height: 24),
            _buildAddReportButton(),
            const SizedBox(height: 24),
            _buildRapportsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    int totalReports = rapports.length;
    int enAttente = rapports.where((r) => r['statut'] == 'EN ATTENTE').length;
    int enCours = rapports.where((r) => r['statut'] == 'EN COURS').length;
    int resolus = rapports.where((r) => r['statut'] == 'RESOLU').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Total",
                  totalReports.toString(),
                  primaryColor,
                  FontAwesomeIcons.fileAlt,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "En Attente",
                  enAttente.toString(),
                  warningColor,
                  FontAwesomeIcons.clock,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "En Cours",
                  enCours.toString(),
                  primaryColor,
                  FontAwesomeIcons.spinner,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  "Résolus",
                  resolus.toString(),
                  successColor,
                  FontAwesomeIcons.checkCircle,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "Total",
                      totalReports.toString(),
                      primaryColor,
                      FontAwesomeIcons.fileAlt,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      "En Attente",
                      enAttente.toString(),
                      warningColor,
                      FontAwesomeIcons.clock,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      "En Cours",
                      enCours.toString(),
                      primaryColor,
                      FontAwesomeIcons.spinner,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      "Résolus",
                      resolus.toString(),
                      successColor,
                      FontAwesomeIcons.checkCircle,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: FaIcon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: TextStyle(
              color: textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndSort() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: FaIcon(
                  FontAwesomeIcons.filter,
                  color: primaryColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "Filtres et Tri",
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Tous'),
              _buildFilterChip('En attente'),
              _buildFilterChip('En cours'),
              _buildFilterChip('Résolu'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                "Trier par :",
                style: TextStyle(color: textSecondary, fontSize: 14),
              ),
              const SizedBox(width: 12),
              DropdownButton<String>(
                value: selectedSortBy,
                underline: Container(),
                dropdownColor: surfaceColor,
                style: TextStyle(color: textPrimary),
                items: ['Date', 'Priorité', 'Statut'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedSortBy = newValue!;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          selectedFilter = selected ? label : 'Tous';
        });
      },
      backgroundColor: surfaceColor,
      selectedColor: primaryColor,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? primaryColor : textSecondary.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  Widget _buildAddReportButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SignalementForm(loggedInUser: widget.loggedInUser)),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(FontAwesomeIcons.plus, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Text(
              'Nouveau Rapport',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRapportsList() {
    final filtered = filteredRapports;

    if (filtered.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            FaIcon(
              FontAwesomeIcons.searchMinus,
              color: textSecondary,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun rapport trouvé',
              style: TextStyle(
                color: textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez de modifier vos filtres',
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return Column(
      children: filtered.map((rapport) => _buildRapportCard(rapport)).toList(),
    );
  }

  Widget _buildRapportCard(Map<String, dynamic> rapport) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        border: rapport['urgence'] == 'HAUTE'
            ? Border.all(color: errorColor.withOpacity(0.3), width: 2)
            : null,
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
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: FaIcon(
                    FontAwesomeIcons.fileAlt,
                    color: primaryColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rapport['titre'],
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        rapport['nom'],
                        style: TextStyle(color: textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: getUrgencyColor(rapport['urgence']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    rapport['urgence'],
                    style: TextStyle(
                      color: getUrgencyColor(rapport['urgence']),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(FontAwesomeIcons.calendar, 'Date', rapport['date']),
            const SizedBox(height: 8),
            _buildInfoRow(
              FontAwesomeIcons.mapMarkerAlt,
              'Lieu',
              rapport['lieu'],
            ),
            const SizedBox(height: 8),
            _buildInfoRow(FontAwesomeIcons.tag, 'Type', rapport['categorie']),
            const SizedBox(height: 8),
            _buildInfoRow(
              FontAwesomeIcons.user,
              'Assigné à',
              rapport['assignedTo'],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: textSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                rapport['description'],
                style: TextStyle(color: textPrimary, fontSize: 14, height: 1.4),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (rapport['fichiers'] != null && rapport['fichiers'] > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FaIcon(
                          FontAwesomeIcons.paperclip,
                          color: primaryColor,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${rapport['fichiers']} fichier(s)',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: getStatusColor(rapport['statut']),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    rapport['statut'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showRapportDetails(rapport),
                  icon: FaIcon(
                    FontAwesomeIcons.eye,
                    color: textSecondary,
                    size: 16,
                  ),
                  tooltip: 'Voir détails',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        FaIcon(icon, size: 14, color: textSecondary),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            '$label :',
            style: TextStyle(
              color: textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: textPrimary, fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _showRapportDetails(Map<String, dynamic> rapport) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: FaIcon(
                      FontAwesomeIcons.eye,
                      color: primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Détails du Rapport',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: FaIcon(
                      FontAwesomeIcons.times,
                      color: textSecondary,
                      size: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('ID', rapport['id']),
                      _buildDetailRow('Titre', rapport['titre']),
                      _buildDetailRow('Type', rapport['type']),
                      _buildDetailRow('Date', rapport['date']),
                      _buildDetailRow('Lieu', rapport['lieu']),
                      _buildDetailRow('Assigné à', rapport['assignedTo']),
                      const SizedBox(height: 16),
                      Text(
                        'Description :',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          rapport['description'],
                          style: TextStyle(color: textPrimary, height: 1.4),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(rapport['statut']),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              rapport['statut'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: getUrgencyColor(
                                rapport['urgence'],
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              rapport['urgence'],
                              style: TextStyle(
                                color: getUrgencyColor(rapport['urgence']),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label :',
              style: TextStyle(
                color: textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: textPrimary, fontSize: 14),
            ),
          ),
        ],
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
