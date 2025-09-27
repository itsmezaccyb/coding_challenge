import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/pokemon_model.dart';

class PokemonService {
  static const String baseUrl = 'https://pokeapi.co/api/v2';
  static const int pokemonLimit = 20;
  
  // HTTP client with optimized settings
  static final http.Client _client = http.Client();
  
  // Connection timeout
  static const Duration _timeout = Duration(seconds: 10);
  
  // Batch fetch Pokemon details concurrently
  static Future<List<Pokemon>> fetchPokemonBatch(List<PokemonListItem> pokemonItems) async {
    final List<Future<Pokemon?>> futures = pokemonItems.map((item) async {
      try {
        return await fetchPokemonById(item.id);
      } catch (e) {
        return null; // Return null for failed requests
      }
    }).toList();
    
    final results = await Future.wait(futures);
    return results.where((pokemon) => pokemon != null).cast<Pokemon>().toList();
  }

  // Fetch Pokemon list with pagination
  static Future<PokemonListResponse> fetchPokemonList({
    int offset = 0,
    int limit = pokemonLimit,
  }) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/pokemon?offset=$offset&limit=$limit'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PokemonListResponse.fromJson(data);
      } else {
        throw Exception('Failed to load Pokemon list: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Pokemon list: $e');
    }
  }

  // Fetch detailed Pokemon data by ID
  static Future<Pokemon> fetchPokemonById(int id) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/pokemon/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Pokemon.fromJson(data);
      } else {
        throw Exception('Failed to load Pokemon: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Pokemon: $e');
    }
  }

  // Fetch detailed Pokemon data by name
  static Future<Pokemon> fetchPokemonByName(String name) async {
    try {
      final response = await _client
          .get(
            Uri.parse('$baseUrl/pokemon/${name.toLowerCase()}'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Pokemon.fromJson(data);
      } else {
        throw Exception('Failed to load Pokemon: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Pokemon: $e');
    }
  }

  // Search Pokemon by name (supports partial matching)
  static Future<List<Pokemon>> searchPokemon(String query) async {
    if (query.isEmpty) return [];
    
    try {
      // First, get a list of all Pokemon to search through
      // We'll search through the first few hundred Pokemon for performance
      final List<Pokemon> searchResults = [];
      final int maxSearchRange = 500; // Limit search to first 500 Pokemon
      int offset = 0;
      const int batchSize = 50;

      while (offset < maxSearchRange) {
        final listResponse = await fetchPokemonList(
          offset: offset,
          limit: batchSize,
        );

        // Filter Pokemon that match the search query
        final matchingPokemon = listResponse.results
            .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        // Fetch detailed data for matching Pokemon using batch loading
        if (matchingPokemon.isNotEmpty) {
          final detailedPokemon = await fetchPokemonBatch(matchingPokemon);
          searchResults.addAll(detailedPokemon);
        }

        // If we found enough results or no more Pokemon, break
        if (searchResults.length >= 20 || listResponse.results.isEmpty) {
          break;
        }

        offset += batchSize;
      }

      return searchResults;
    } catch (e) {
      throw Exception('Error searching Pokemon: $e');
    }
  }

  // Get Pokemon by type (optional feature for future enhancement)
  static Future<List<Pokemon>> fetchPokemonByType(String type) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/type/${type.toLowerCase()}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> pokemonList = data['pokemon'] ?? [];
        
        final List<Pokemon> pokemon = [];
        
        // Fetch detailed data for first 20 Pokemon of this type
        for (int i = 0; i < pokemonList.length && i < 20; i++) {
          final pokemonData = pokemonList[i]['pokemon'];
          final pokemonName = pokemonData['name'];
          
          try {
            final detailedPokemon = await fetchPokemonByName(pokemonName);
            pokemon.add(detailedPokemon);
          } catch (e) {
            // Skip Pokemon that fail to load
            continue;
          }
        }
        
        return pokemon;
      } else {
        throw Exception('Failed to load Pokemon by type: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching Pokemon by type: $e');
    }
  }
}
