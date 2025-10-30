class Utilisateur {
  final int? id;
  final String nom;
  final String email;
  final String telephone;
  final String numeroCarteNationale;
  final String motDePasse;
  final String role;
  final bool actif;
  final DateTime? dateCreation;

  Utilisateur({
    this.id,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.numeroCarteNationale,
    required this.motDePasse,
    required this.role,
    required this.actif,
    this.dateCreation,
  });

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'numero_carte_nationale': numeroCarteNationale,
      'mot_de_passe': motDePasse,
      'role': role,
      'actif': actif ? 1 : 0,
    };
  }

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      id: json['id'] ?? 0,
      nom: json['nom'] ?? 'Inconnu',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      numeroCarteNationale: json['numero_carte_nationale'] ?? '',
      motDePasse: '',
      role: json['role'] ?? 'user',
      actif: (json['actif'] ?? 1) == 1,
      dateCreation: DateTime.tryParse(json['date_creation'] ?? ''),
    );
  }
}
