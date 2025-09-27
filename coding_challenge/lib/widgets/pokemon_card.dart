import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon_model.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback onTap;

  const PokemonCard({
    super.key,
    required this.pokemon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.black, width: 2),
      ),
      color: _getTypeColor(pokemon.primaryType),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // Pokemon Image - takes up most of the width
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                color: _getTypeColor(pokemon.primaryType).withValues(alpha: 0.1),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: CachedNetworkImage(
                    imageUrl: pokemon.imageUrl,
                    fit: BoxFit.contain,
                    // Optimized caching settings
                    memCacheWidth: 400, // Limit memory cache size
                    memCacheHeight: 400,
                    maxWidthDiskCache: 800, // Limit disk cache size
                    maxHeightDiskCache: 800,
                    placeholder: (context, url) => Container(
                      color: _getTypeColor(pokemon.primaryType).withValues(alpha: 0.1),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: _getTypeColor(pokemon.primaryType).withValues(alpha: 0.1),
                      child: const Icon(
                        Icons.pets,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Pokemon Name
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    pokemon.capitalizedName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Courier',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return const Color(0xFFFF8A80); // More pronounced red
      case 'water':
        return const Color(0xFF81D4FA); // More pronounced blue
      case 'grass':
        return const Color(0xFFA5D6A7); // More pronounced green
      case 'electric':
        return const Color(0xFFFFF9C4); // Light yellow
      case 'psychic':
        return const Color(0xFFE1BEE7); // Light purple
      case 'ice':
        return const Color(0xFFE0F2F1); // Light cyan
      case 'dragon':
        return const Color(0xFFB39DDB); // Light indigo
      case 'dark':
        return const Color(0xFFBCAAA4); // Light brown
      case 'fairy':
        return const Color(0xFFF8BBD9); // Light pink
      case 'fighting':
        return const Color(0xFFFFCC80); // Light orange
      case 'flying':
        return const Color(0xFFB3E5FC); // Light sky blue
      case 'poison':
        return const Color(0xFFCE93D8); // Light violet
      case 'ground':
        return const Color(0xFFD7CCC8); // Light beige
      case 'rock':
        return const Color(0xFFA1887F); // Light brown
      case 'bug':
        return const Color(0xFFC8E6C9); // Light green
      case 'ghost':
        return const Color(0xFFE1BEE7); // Light lavender
      case 'steel':
        return const Color(0xFFCFD8DC); // Light grey
      case 'normal':
        return const Color(0xFFF5F5F5); // Light grey
      default:
        return const Color(0xFFF5F5F5); // Default light grey
    }
  }
}
