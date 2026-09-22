import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/saint.dart';

class QuoteCard extends StatefulWidget {
  final Saint saint;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const QuoteCard({
    super.key,
    required this.saint,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> with SingleTickerProviderStateMixin {
  bool _prayerExpanded = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _togglePrayer() {
    setState(() {
      _prayerExpanded = !_prayerExpanded;
      if (_prayerExpanded) {
        _animController.forward();
      } else {
        _animController.reverse();
      }
    });
  }

  void _shareQuote() {
    final text = '✝️ ${widget.saint.saint}\n\n'
        '«${widget.saint.quote}»\n\n'
        '— ${widget.saint.attribution}\n\n'
        '📱 La Sfida della Fede - App quotidiana dei Santi';
    SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFC9A84C);
    const darkBlue = Color(0xFF1A237E);
    const parchment = Color(0xFFF5F0E8);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: parchment,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cross icon
              Icon(
                Icons.church,
                color: gold,
                size: 40,
              ),
              const SizedBox(height: 16),

              // Decorative divider
              _buildDivider(gold),
              const SizedBox(height: 20),

              // Saint name
              Text(
                widget.saint.saint,
                textAlign: TextAlign.center,
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: gold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Quote
              Text(
                '«${widget.saint.quote}»',
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  color: darkBlue,
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 16),

              // Attribution
              Text(
                '— ${widget.saint.attribution}',
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(
                  fontSize: 14,
                  color: darkBlue.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),

              // Decorative divider
              _buildDivider(gold),
              const SizedBox(height: 16),

              // Prayer section (expandable)
              GestureDetector(
                onTap: _togglePrayer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: gold,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Preghiera',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: gold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _prayerExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: gold,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),

              // Prayer text
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: gold.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: gold.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      widget.saint.prayer,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lora(
                        fontSize: 15,
                        color: darkBlue.withValues(alpha: 0.85),
                        height: 1.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                crossFadeState: _prayerExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),

              const SizedBox(height: 20),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Favorite button
                  _buildActionButton(
                    icon: widget.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: widget.isFavorite ? Colors.red : gold,
                    onTap: widget.onFavoriteToggle,
                    label: 'Preferito',
                  ),
                  const SizedBox(width: 32),
                  // Share button
                  _buildActionButton(
                    icon: Icons.share,
                    color: gold,
                    onTap: _shareQuote,
                    label: 'Condividi',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(width: 40, height: 1, color: color.withValues(alpha: 0.4)),
        const SizedBox(width: 8),
        Icon(Icons.star, color: color.withValues(alpha: 0.6), size: 12),
        const SizedBox(width: 8),
        Container(width: 40, height: 1, color: color.withValues(alpha: 0.4)),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required String label,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(icon, key: ValueKey(icon), color: color, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lora(
              fontSize: 11,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
