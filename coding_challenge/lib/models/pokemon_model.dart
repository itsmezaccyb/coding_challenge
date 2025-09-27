class Pokemon {
  final int id;
  final String name;
  final String imageUrl;
  final int height;
  final int weight;
  final List<String> types;
  final List<String> abilities;
  final int baseExperience;
  final Map<String, int> stats;

  Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.height,
    required this.weight,
    required this.types,
    required this.abilities,
    required this.baseExperience,
    required this.stats,
  });

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // Parse types
    List<String> types = [];
    if (json['types'] != null) {
      types = (json['types'] as List)
          .map((type) => type['type']['name'] as String)
          .toList();
    }

    // Parse abilities
    List<String> abilities = [];
    if (json['abilities'] != null) {
      abilities = (json['abilities'] as List)
          .map((ability) => ability['ability']['name'] as String)
          .toList();
    }

    // Parse stats
    Map<String, int> stats = {};
    if (json['stats'] != null) {
      for (var stat in json['stats']) {
        String statName = stat['stat']['name'];
        int statValue = stat['base_stat'];
        stats[statName] = statValue;
      }
    }

    return Pokemon(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Pokemon',
      imageUrl: json['sprites']?['other']?['official-artwork']?['front_default'] ?? 
                json['sprites']?['front_default'] ?? '',
      height: json['height'] ?? 0,
      weight: json['weight'] ?? 0,
      types: types,
      abilities: abilities,
      baseExperience: json['base_experience'] ?? 0,
      stats: stats,
    );
  }

  String get primaryType => types.isNotEmpty ? types.first : 'unknown';
  
  String get capitalizedName => name.split(' ').map((word) => 
    word[0].toUpperCase() + word.substring(1)).join(' ');

  String get typesDisplay => types.map((type) => 
    type[0].toUpperCase() + type.substring(1)).join(', ');

  String get abilitiesDisplay => abilities.take(3).map((ability) => 
    ability[0].toUpperCase() + ability.substring(1)).join(', ');

  // Helper method to get Pokemon type color
  String get typeColor {
    switch (primaryType.toLowerCase()) {
      case 'fire':
        return '#FF6B6B';
      case 'water':
        return '#4ECDC4';
      case 'grass':
        return '#45B7D1';
      case 'electric':
        return '#FFE66D';
      case 'psychic':
        return '#A8E6CF';
      case 'ice':
        return '#B4E7CE';
      case 'dragon':
        return '#C7CEEA';
      case 'dark':
        return '#8B5A83';
      case 'fairy':
        return '#FFB6C1';
      case 'fighting':
        return '#FFB347';
      case 'flying':
        return '#87CEEB';
      case 'poison':
        return '#DDA0DD';
      case 'ground':
        return '#DEB887';
      case 'rock':
        return '#BC9A6A';
      case 'bug':
        return '#98FB98';
      case 'ghost':
        return '#D3D3D3';
      case 'steel':
        return '#C0C0C0';
      case 'normal':
        return '#F5F5DC';
      default:
        return '#E0E0E0';
    }
  }
}

class PokemonListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<PokemonListItem> results;

  PokemonListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    return PokemonListResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((item) => PokemonListItem.fromJson(item))
          .toList(),
    );
  }
}

class PokemonListItem {
  final String name;
  final String url;

  PokemonListItem({
    required this.name,
    required this.url,
  });

  factory PokemonListItem.fromJson(Map<String, dynamic> json) {
    return PokemonListItem(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }

  int get id {
    // Extract ID from URL like "https://pokeapi.co/api/v2/pokemon/1/"
    final parts = url.split('/');
    return int.tryParse(parts[parts.length - 2]) ?? 0;
  }
}