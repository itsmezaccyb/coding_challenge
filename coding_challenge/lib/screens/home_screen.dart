import 'dart:async';
import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../services/pokemon_service.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  Timer? _scrollThrottleTimer;
  
  List<Pokemon> _allPokemon = [];
  List<Pokemon> _filteredPokemon = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentOffset = 0;
  final int _itemsPerPage = 5;
  bool _isSearching = false;
  
  // Memory management: keep only last 200 Pokemon in memory
  static const int _maxPokemonInMemory = 200;
  
  // Memory management: trim list if it gets too large
  void _manageMemory() {
    if (_allPokemon.length > _maxPokemonInMemory) {
      // Keep only the most recent Pokemon
      final startIndex = _allPokemon.length - _maxPokemonInMemory;
      _allPokemon = _allPokemon.sublist(startIndex);
      _filteredPokemon = List.from(_allPokemon);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounceTimer?.cancel();
    _scrollThrottleTimer?.cancel();
    super.dispose();
  }

  void _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final pokemonList = await PokemonService.fetchPokemonList(
        offset: _currentOffset,
        limit: _itemsPerPage,
      );
      
      // Use batch loading for better performance
      final detailedPokemon = await PokemonService.fetchPokemonBatch(pokemonList.results);
      
      setState(() {
        _allPokemon = detailedPokemon;
        _filteredPokemon = List.from(_allPokemon);
        _isLoading = false;
        _currentOffset = _itemsPerPage;
        _hasMore = pokemonList.next != null;
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load Pokemon: $e');
    }
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredPokemon = List.from(_allPokemon);
        _isSearching = false;
        _hasMore = true;
        _currentOffset = _allPokemon.length;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
    });

    try {
      final searchResults = await PokemonService.searchPokemon(query);
      setState(() {
        _filteredPokemon = searchResults;
        _isSearching = false;
        _isLoading = false;
        _hasMore = false; // No infinite scroll during search
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
        _isLoading = false;
      });
      _showErrorSnackBar('Search failed: $e');
    }
  }

  void _onScroll() {
    if (_isSearching) return; // Don't load more during search
    
    // Throttle scroll events to improve performance
    _scrollThrottleTimer?.cancel();
    _scrollThrottleTimer = Timer(const Duration(milliseconds: 25), () {
      final currentPosition = _scrollController.position.pixels;
      // Calculate actual card height based on screen width and aspect ratio
      final screenWidth = MediaQuery.of(context).size.width;
      final cardHeight = (screenWidth - 16) / 1.2; // Account for padding and aspect ratio
      final currentItemIndex = (currentPosition / cardHeight).floor();
      
      // Load more when user is 20 items away from the end of loaded data
      if (currentItemIndex >= _allPokemon.length - 20 && _hasMore && !_isLoading) {
        _loadMorePokemon();
      }
    });
  }

  void _loadMorePokemon() async {
    if (_isLoading || !_hasMore || _isSearching) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Load multiple batches for better performance
      final List<Pokemon> allNewPokemon = [];
      
      for (int i = 0; i < 3; i++) { // Load 3 batches at once (15 Pokemon total)
        if (!_hasMore) break;
        
        final pokemonList = await PokemonService.fetchPokemonList(
          offset: _currentOffset + (i * _itemsPerPage),
          limit: _itemsPerPage,
        );
        
        if (pokemonList.results.isEmpty) {
          _hasMore = false;
          break;
        }
        
        final newPokemon = await PokemonService.fetchPokemonBatch(pokemonList.results);
        allNewPokemon.addAll(newPokemon);
        
        if (pokemonList.next == null) {
          _hasMore = false;
          break;
        }
      }
      
      setState(() {
        _allPokemon.addAll(allNewPokemon);
        _filteredPokemon = List.from(_allPokemon);
        _currentOffset += allNewPokemon.length;
        _isLoading = false;
      });
      
      // Manage memory after adding new Pokemon
      _manageMemory();
      
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load more Pokemon: $e');
    }
  }

  void _onPokemonTap(Pokemon pokemon) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PokemonDetailScreen(pokemon: pokemon),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        toolbarHeight: 0, // Remove the default app bar height
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(88),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search Pokémon...',
                hintStyle: const TextStyle(
                  fontFamily: 'Courier',
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: _isLoading && _filteredPokemon.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : _filteredPokemon.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No Pokémon found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    _loadInitialData();
                  },
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _filteredPokemon.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _filteredPokemon.length) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.black,
                          ),
                        );
                      }
                      
                      final pokemon = _filteredPokemon[index];
                      return PokemonCard(
                        pokemon: pokemon,
                        onTap: () => _onPokemonTap(pokemon),
                      );
                    },
                  ),
                ),
    );
  }
}
