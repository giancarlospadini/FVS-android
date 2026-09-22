import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/saint.dart';
import '../services/saints_service.dart';
import '../widgets/quote_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final SaintsService _saintsService = SaintsService();
  List<Saint> _favoriteSaints = [];
  Set<String> _favoriteKeys = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    await _saintsService.loadSaints();
    final prefs = await SharedPreferences.getInstance();
    final favsJson = prefs.getString('favorites') ?? '[]';
    final List<dynamic> favsList = json.decode(favsJson);
    _favoriteKeys = favsList.map((e) => e.toString()).toSet();

    _favoriteSaints = _favoriteKeys.map((key) {
      final parts = key.split('-');
      return _saintsService.getSaintByDate(int.parse(parts[0]), int.parse(parts[1]));
    }).toList();

    _favoriteSaints.sort((a, b) {
      if (a.month != b.month) return a.month.compareTo(b.month);
      return a.day.compareTo(b.day);
    });

    setState(() => _isLoading = false);
  }

  Future<void> _removeFavorite(Saint saint) async {
    final key = saint.dateKey;
    setState(() {
      _favoriteKeys.remove(key);
      _favoriteSaints.removeWhere((s) => s.dateKey == key);
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorites', json.encode(_favoriteKeys.toList()));
  }

  final _months = const [
    '', 'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
    'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
  ];

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFC9A84C);
    const darkBlue = Color(0xFF1A237E);
    const parchment = Color(0xFFF5F0E8);

    return Scaffold(
      backgroundColor: parchment,
      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        title: Text(
          'Preferiti',
          style: GoogleFonts.playfairDisplay(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: gold))
          : _favoriteSaints.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: gold.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'Nessun preferito salvato',
                        style: GoogleFonts.lora(
                          fontSize: 18,
                          color: darkBlue.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tocca il cuore su una citazione\nper salvarla qui',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lora(
                          fontSize: 14,
                          color: darkBlue.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _favoriteSaints.length,
                  itemBuilder: (context, index) {
                    final saint = _favoriteSaints[index];
                    return Dismissible(
                      key: Key(saint.dateKey),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _removeFavorite(saint),
                      child: GestureDetector(
                        onTap: () => _showFullQuote(context, saint),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: gold.withValues(alpha: 0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: darkBlue.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: gold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${saint.day}',
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: darkBlue,
                                      ),
                                    ),
                                    Text(
                                      _months[saint.month].substring(0, 3),
                                      style: GoogleFonts.lora(
                                        fontSize: 10,
                                        color: gold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      saint.saint,
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: darkBlue,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      saint.quote,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.lora(
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                        color: darkBlue.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.favorite, color: Colors.red.shade400, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _showFullQuote(BuildContext context, Saint saint) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5F0E8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: QuoteCard(
                saint: saint,
                isFavorite: true,
                onFavoriteToggle: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}
