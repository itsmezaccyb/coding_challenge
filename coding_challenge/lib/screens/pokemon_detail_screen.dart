import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon_model.dart';

class PokemonDetailScreen extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonDetailScreen({
    super.key,
    required this.pokemon,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon.capitalizedName),
        backgroundColor: _getTypeColor(pokemon.primaryType),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Pokemon Image Section
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _getTypeColor(pokemon.primaryType).withValues(alpha: 0.3),
                    Colors.white,
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Pokemon Image
                    Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withValues(alpha: 0.3),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: pokemon.imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          errorWidget: (context, url, error) => const Icon(
                            Icons.pets,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Pokemon Name and ID
                    Text(
                      pokemon.capitalizedName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '#${pokemon.id.toString().padLeft(3, '0')}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    
                    // Pokemon Types
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: pokemon.types.map((type) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(type),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            type[0].toUpperCase() + type.substring(1),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            // Pokemon Information Cards
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Basic Info Card
                  _buildInfoCard(
                    'Basic Information',
                    [
                      _buildInfoRow('Height', '${pokemon.height / 10} m'),
                      _buildInfoRow('Weight', '${pokemon.weight / 10} kg'),
                      _buildInfoRow('Base Experience', pokemon.baseExperience.toString()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Abilities Card
                  _buildInfoCard(
                    'Abilities',
                    pokemon.abilities.map((ability) => 
                      _buildInfoRow(
                        ability[0].toUpperCase() + ability.substring(1),
                        '',
                      )
                    ).toList(),
                  ),
                  const SizedBox(height: 16),
                  
                  // Stats Card
                  _buildInfoCard(
                    'Base Stats',
                    pokemon.stats.entries.map((entry) {
                      String statName = entry.key.replaceAll('-', ' ');
                      statName = statName.split(' ').map((word) => 
                        word[0].toUpperCase() + word.substring(1)).join(' ');
                      return _buildInfoRow(statName, entry.value.toString());
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children.map((child) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: child,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (value.isNotEmpty)
            Expanded(
              flex: 1,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.end,
              ),
            ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return const Color(0xFFFF6B6B);
      case 'water':
        return const Color(0xFF4ECDC4);
      case 'grass':
        return const Color(0xFF45B7D1);
      case 'electric':
        return const Color(0xFFFFE66D);
      case 'psychic':
        return const Color(0xFFA8E6CF);
      case 'ice':
        return const Color(0xFFB4E7CE);
      case 'dragon':
        return const Color(0xFFC7CEEA);
      case 'dark':
        return const Color(0xFF8B5A83);
      case 'fairy':
        return const Color(0xFFFFB6C1);
      case 'fighting':
        return const Color(0xFFFFB347);
      case 'flying':
        return const Color(0xFF87CEEB);
      case 'poison':
        return const Color(0xFFDDA0DD);
      case 'ground':
        return const Color(0xFFDEB887);
      case 'rock':
        return const Color(0xFFBC9A6A);
      case 'bug':
        return const Color(0xFF98FB98);
      case 'ghost':
        return const Color(0xFFD3D3D3);
      case 'steel':
        return const Color(0xFFC0C0C0);
      case 'normal':
        return const Color(0xFFF5F5DC);
      default:
        return const Color(0xFFE0E0E0);
    }
  }
}
