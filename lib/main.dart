// Rick and Morty Explorer en Flutter Web
// ✅ Buscador + Diseño Retro Futurista + Filtros + Deploy Ready + Test Ready + Banner Animado + Fuente Retro

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const RickAndMortyApp());
}

class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rick and Morty Explorer',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.tealAccent,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF1F1B24),
        textTheme: const TextTheme(bodyLarge: TextStyle(color: Colors.white70)),
        useMaterial3: true,
        fontFamily: 'Orbitron',
      ),
      home: const CharactersPage(),
    );
  }
}

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key});

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage>
    with SingleTickerProviderStateMixin {
  List characters = [];
  int page = 1;
  bool isLoading = false;
  String searchQuery = '';
  String selectedStatus = '';
  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  bool showBanner = true;
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    fetchCharacters();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    scrollController.addListener(() {
      if (scrollController.offset > 180 && showBanner) {
        _controller.forward();
        setState(() => showBanner = false);
      } else if (scrollController.offset <= 180 && !showBanner) {
        _controller.reverse();
        setState(() => showBanner = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    scrollController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchCharacters({bool reset = false}) async {
    setState(() {
      isLoading = true;
    });

    if (reset) {
      characters.clear();
      page = 1;
    }

    final queryParams = {
      'page': '$page',
      if (searchQuery.isNotEmpty) 'name': searchQuery,
      if (selectedStatus.isNotEmpty) 'status': selectedStatus.toLowerCase(),
    };
    final uri = Uri.https(
      'rickandmortyapi.com',
      '/api/character/',
      queryParams,
    );
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        characters.addAll(data['results']);
        page++;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontraron personajes')),
      );
    }
  }

  void onSearch(String value) {
    setState(() {
      searchQuery = value;
    });
    fetchCharacters(reset: true);
  }

  void onStatusFilterChanged(String? value) {
    setState(() {
      selectedStatus = value ?? '';
    });
    fetchCharacters(reset: true);
  }

  void clearFilters() {
    setState(() {
      selectedStatus = '';
      searchQuery = '';
      searchController.clear();
    });
    fetchCharacters(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            floating: false,
            flexibleSpace: FlexibleSpaceBar(
              title: FadeTransition(
                opacity: _opacityAnimation,
                child: const Text('🚀 Rick and Morty Explorer'),
              ),
              centerTitle: true,
              background: Image.asset(
                'assets/banner_rickmorty.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    onSubmitted: onSearch,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nombre...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.tealAccent,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white38),
                        onPressed: clearFilters,
                      ),
                      filled: true,
                      fillColor: Colors.black54,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedStatus.isEmpty ? null : selectedStatus,
                    dropdownColor: Colors.black,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Filtrar por estado',
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.black54,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: ['Alive', 'Dead', 'Unknown']
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                    onChanged: onStatusFilterChanged,
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(10),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                childAspectRatio: 0.55,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final character = characters[index];
                return CharacterCard(character: character);
              }, childCount: characters.length),
            ),
          ),
          if (isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          SliverToBoxAdapter(
            child: Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : fetchCharacters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Cargar más'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CharacterCard extends StatelessWidget {
  final dynamic character;

  const CharacterCard({super.key, required this.character});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
      shadowColor: Colors.tealAccent.withOpacity(0.3),
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  character['image'],
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                character['name'],
                style: const TextStyle(
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  Chip(
                    label: Text(character['status']),
                    backgroundColor: Colors.deepPurple,
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  Chip(
                    label: Text(character['species']),
                    backgroundColor: Colors.indigo,
                    labelStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    character['location']['name'],
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
