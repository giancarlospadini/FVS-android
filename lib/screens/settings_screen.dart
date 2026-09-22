import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = true;
  int _notifHour = 8;
  int _notifMinute = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _notificationsEnabled = await _notificationService.isEnabled();
    _notifHour = await _notificationService.getHour();
    _notifMinute = await _notificationService.getMinute();
    setState(() => _isLoading = false);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _notifHour, minute: _notifMinute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1A237E),
              secondary: Color(0xFFC9A84C),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _notifHour = time.hour;
        _notifMinute = time.minute;
      });
      await _notificationService.setTime(time.hour, time.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFC9A84C);
    const darkBlue = Color(0xFF1A237E);
    const parchment = Color(0xFFF5F0E8);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: parchment,
        body: Center(child: CircularProgressIndicator(color: gold)),
      );
    }

    return Scaffold(
      backgroundColor: parchment,
      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        title: Text(
          'Impostazioni',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Notifications section
          _buildSectionHeader('Notifiche', gold),
          const SizedBox(height: 8),
          _buildCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Promemoria quotidiano',
                    style: GoogleFonts.lora(
                      fontSize: 16,
                      color: darkBlue,
                    ),
                  ),
                  subtitle: Text(
                    'Ricevi il santo del giorno ogni mattina',
                    style: GoogleFonts.lora(
                      fontSize: 13,
                      color: darkBlue.withValues(alpha: 0.6),
                    ),
                  ),
                  value: _notificationsEnabled,
                  activeColor: gold,
                  onChanged: (value) async {
                    setState(() => _notificationsEnabled = value);
                    await _notificationService.setEnabled(value);
                  },
                ),
                if (_notificationsEnabled) ...[
                  const Divider(),
                  ListTile(
                    title: Text(
                      'Orario notifica',
                      style: GoogleFonts.lora(fontSize: 16, color: darkBlue),
                    ),
                    trailing: GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_notifHour.toString().padLeft(2, '0')}:${_notifMinute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: darkBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About section
          _buildSectionHeader('Informazioni', gold),
          const SizedBox(height: 8),
          _buildCard(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.church, color: gold),
                  title: Text(
                    'La Sfida della Fede',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: darkBlue,
                    ),
                  ),
                  subtitle: Text(
                    'Versione 1.0.0',
                    style: GoogleFonts.lora(
                      fontSize: 13,
                      color: darkBlue.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Un\'app per la meditazione quotidiana attraverso le parole dei santi della Chiesa Cattolica. '
                    'Ogni giorno una nuova citazione per ispirare la tua fede.',
                    style: GoogleFonts.lora(
                      fontSize: 14,
                      color: darkBlue.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.info_outline, color: gold),
                  title: Text(
                    '366 santi e citazioni',
                    style: GoogleFonts.lora(fontSize: 14, color: darkBlue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.playfairDisplay(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
