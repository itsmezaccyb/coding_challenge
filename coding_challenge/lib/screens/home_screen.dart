import 'dart:async';
import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../widgets/team_card.dart';
import 'team_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;
  
  List<Team> _allTeams = [];
  List<Team> _filteredTeams = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _itemsPerPage = 10;

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
    super.dispose();
  }

  void _loadInitialData() {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _allTeams = Team.getMockTeams();
        _filteredTeams = List.from(_allTeams);
        _isLoading = false;
      });
    });
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredTeams = List.from(_allTeams);
      } else {
        _filteredTeams = _allTeams
            .where((team) =>
                team.name.toLowerCase().contains(query.toLowerCase()) ||
                team.country.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
      _currentPage = 1;
      _hasMore = true;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreTeams();
    }
  }

  void _loadMoreTeams() {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call delay
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        // In a real app, this would fetch more data from API
        // For now, we'll just simulate loading more teams
        final startIndex = _currentPage * _itemsPerPage;
        final endIndex = startIndex + _itemsPerPage;
        
        if (startIndex < _allTeams.length) {
          final newTeams = _allTeams.sublist(
            startIndex,
            endIndex > _allTeams.length ? _allTeams.length : endIndex,
          );
          _filteredTeams.addAll(newTeams);
          _currentPage++;
        } else {
          _hasMore = false;
        }
        _isLoading = false;
      });
    });
  }

  void _onTeamTap(Team team) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamDetailScreen(team: team),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Football Teams'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search teams...',
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
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: _isLoading && _filteredTeams.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _filteredTeams.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No teams found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
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
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: _filteredTeams.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _filteredTeams.length) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      
                      final team = _filteredTeams[index];
                      return TeamCard(
                        team: team,
                        onTap: () => _onTeamTap(team),
                      );
                    },
                  ),
                ),
    );
  }
}
