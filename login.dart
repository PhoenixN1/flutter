import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme_manager.dart';
import 'dashboard.dart';
import 'utilisateur.dart';

class AuthService {
  static const String baseUrl = 'http://192.168.1.230/my_app';

  Future<Map<String, dynamic>> inscription(Utilisateur utilisateur) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/inscription.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(utilisateur.toJson()),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Erreur lors de l\'inscription',
        };
      }
    } catch (e) {
      print('Erreur inscription: $e');
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }

  Future<Map<String, dynamic>> connexion(
    String email,
    String motDePasse,
  ) async {
    try {
      print('Tentative de connexion pour: $email');

      final response = await http.post(
        Uri.parse('$baseUrl/connexion.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'mot_de_passe': motDePasse}),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = json.decode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        return {
          'success': true,
          'data': responseData['data'], // ← Accès correct aux données
        };
      } else {
        return {
          'success': false,
          'message':
              responseData['message'] ?? 'Email ou mot de passe incorrect',
        };
      }
    } catch (e) {
      print('Erreur connexion: $e');
      return {'success': false, 'message': 'Erreur de connexion: $e'};
    }
  }
}

class InscriptionPage extends StatefulWidget {
  const InscriptionPage({Key? key}) : super(key: key);

  @override
  State<InscriptionPage> createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _carteNationaleController = TextEditingController();
  final _motDePasseController = TextEditingController();
  final _confirmMotDePasseController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _carteNationaleController.dispose();
    _motDePasseController.dispose();
    _confirmMotDePasseController.dispose();
    super.dispose();
  }

  Future<void> _handleInscription() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final utilisateur = Utilisateur(
        nom: _nomController.text.trim(),
        email: _emailController.text.trim(),
        telephone: _telephoneController.text.trim(),
        numeroCarteNationale: _carteNationaleController.text.trim(),
        motDePasse: _motDePasseController.text,
        role: 'user',
        actif: true,
      );

      final result = await _authService.inscription(utilisateur);

      setState(() => _isLoading = false);

      if (result['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Inscription réussie!'),
              backgroundColor: ThemeManager().successColor,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ConnexionPage()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Erreur lors de l\'inscription',
              ),
              backgroundColor: ThemeManager().errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager();

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.person_add_rounded,
                  size: 80,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Créer un compte',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Remplissez vos informations',
                  style: TextStyle(fontSize: 16, color: theme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  controller: _nomController,
                  label: 'Nom complet',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _telephoneController,
                  label: 'Téléphone',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre téléphone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _carteNationaleController,
                  label: 'Numéro de carte nationale',
                  icon: Icons.credit_card,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre numéro de carte';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _motDePasseController,
                  label: 'Mot de passe',
                  icon: Icons.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: theme.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un mot de passe';
                    }
                    if (value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmMotDePasseController,
                  label: 'Confirmer le mot de passe',
                  icon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: theme.textSecondary,
                    ),
                    onPressed: () => setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez confirmer votre mot de passe';
                    }
                    if (value != _motDePasseController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleInscription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'S\'inscrire',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vous avez déjà un compte? ',
                      style: TextStyle(color: theme.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ConnexionPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Se connecter',
                        style: TextStyle(
                          color: theme.primaryColor,
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = ThemeManager();

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: theme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textSecondary),
        prefixIcon: Icon(icon, color: theme.textSecondary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: theme.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.errorColor, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}

class ConnexionPage extends StatefulWidget {
  const ConnexionPage({Key? key}) : super(key: key);

  @override
  State<ConnexionPage> createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _motDePasseController = TextEditingController();
  String? jwtToken;

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _handleConnexion() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final result = await _authService.connexion(
        _emailController.text.trim(),
        _motDePasseController.text,
      );

      setState(() => _isLoading = false);

      print('Résultat connexion: $result');

      if (result['success'] == true) {
        try {
          final userData = result['data']; 
          jwtToken = userData['token'];

          print('User data: $userData');

          final loggedInUser = Utilisateur(
            id: userData['id'],
            nom: userData['nom'],
            email: userData['email'],
            telephone: userData['telephone'],
            numeroCarteNationale: userData['numero_carte_nationale'],
            motDePasse: '',
            role: userData['role'],
            actif: userData['actif'] == 1,
            dateCreation: DateTime.parse(userData['date_creation']),
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Connexion réussie!'),
                backgroundColor: ThemeManager().successColor,
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardPage(loggedInUser: loggedInUser),
              ),
            );
          }
        } catch (e) {
          print('Erreur parsing user data: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors de la récupération des données: $e'),
                backgroundColor: ThemeManager().errorColor,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Email ou mot de passe incorrect',
              ),
              backgroundColor: ThemeManager().errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeManager();

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Icon(
                  Icons.lock_open_rounded,
                  size: 80,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  'Bienvenue',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Connectez-vous à votre compte',
                  style: TextStyle(fontSize: 16, color: theme.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60),
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre email';
                    }
                    if (!RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value)) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _motDePasseController,
                  label: 'Mot de passe',
                  icon: Icons.lock,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: theme.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Mot de passe oublié?',
                      style: TextStyle(color: theme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleConnexion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Se connecter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Vous n\'avez pas de compte? ',
                      style: TextStyle(color: theme.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InscriptionPage(),
                          ),
                        );
                      },
                      child: Text(
                        'S\'inscrire',
                        style: TextStyle(
                          color: theme.primaryColor,
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
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    final theme = ThemeManager();

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: TextStyle(color: theme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: theme.textSecondary),
        prefixIcon: Icon(icon, color: theme.textSecondary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: theme.surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.errorColor, width: 2),
        ),
      ),
      validator: validator,
    );
  }
}
