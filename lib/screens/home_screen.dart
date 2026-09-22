import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/saint.dart';
import '../services/saints_service.dart';
import '../services/ad_service.dart';
import '../widgets/quote_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SaintsService _saintsService = SaintsService();
  final AdService _adService = AdService();
  late PageController _pageController;
  int _currentIndex = 0;
  Set<String> _favorites = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _saintsService.loadSaints();
    await _loadFavorites();
    _currentIndex = _saintsService.getTodayIndex();
    _pageController = PageController(initialPage: _currentIndex);
    setState(() => _isLoading = false);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favsJson = prefs.getString('favorites') ?? '[]';
    final List<dynamic> favsList = json.decode(favsJson);
    _favorites = favsList.map((e) => e.toString()).toSet();
  }

  Future<void> _toggleFavorite(Saint saint) async {
    final key = saint.dateKey;
    setState(() {
      if (_favorites.contains(key)) {
        _favorites.remove(key);
      } else {
        _favorites.add(key);
      }
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('favorites', json.encode(_favorites.toList()));
  }

  String _getItalianDate(int month, int day) {
    final months = [
      '', 'Gennaio', 'Febbraio', 'Marzo', 'Aprile', 'Maggio', 'Giugno',
      'Luglio', 'Agosto', 'Settembre', 'Ottobre', 'Novembre', 'Dicembre'
    ];
    return '$day ${months[month]}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F0E8),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFC9A84C)),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF283593),
              Color(0xFFF5F0E8),
            ],
            stops: [0.0, 0.15, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.white),
                      onPressed: () => Navigator.pushNamed(context, '/favorites'),
                    ),
                    Column(
                      children: [
                        Text(
                          'La Sfida della Fede',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getItalianDate(
                            _saintsService.getSaintByIndex(_currentIndex).month,
                            _saintsService.getSaintByIndex(_currentIndex).day,
                          ),
                          style: GoogleFonts.lora(
                            fontSize: 14,
                            color: const Color(0xFFC9A84C),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      onPressed: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
              ),

              // Quote cards - swipeable
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _saintsService.totalSaints,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                    _adService.onSwipe();
                  },
                  itemBuilder: (context, index) {
                    final saint = _saintsService.getSaintByIndex(index);
                    return Center(
                      child: QuoteCard(
                        saint: saint,
                        isFavorite: _favorites.contains(saint.dateKey),
                        onFavoriteToggle: () => _toggleFavorite(saint),
                      ),
                    );
                  },
                ),
              ),

              // Navigation arrows
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Color(0xFF1A237E)),
                      iconSize: 32,
                      onPressed: () {
                        if (_currentIndex > 0) {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                    GestureDetector(
                      onTap: () {
                        final todayIndex = _saintsService.getTodayIndex();
                        _pageController.animateToPage(
                          todayIndex,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Text(
                        'Oggi',
                        style: GoogleFonts.lora(
                          fontSize: 14,
                          color: const Color(0xFF1A237E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Color(0xFF1A237E)),
                      iconSize: 32,
                      onPressed: () {
                        if (_currentIndex < _saintsService.totalSaints - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Banner Ad
              if (_adService.isBannerLoaded && _adService.bannerAd != null)
                Container(
                  width: _adService.bannerAd!.size.width.toDouble(),
                  height: _adService.bannerAd!.size.height.toDouble(),
                  alignment: Alignment.center,
                  child: AdWidget(ad: _adService.bannerAd!),
                )
              else
                const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
