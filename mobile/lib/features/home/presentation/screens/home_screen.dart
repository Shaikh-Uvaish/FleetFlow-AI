import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

// Colors used only on this dark screen.
const _bg = Color(0xFF111827); // page background
const _card = Color(0xFF171A17); // card background
const _line = Color(0xFF26364A); // borders and dividers
const _text = Color(0xFFF7F8F4); // main text
const _muted = Color(0xFF94A3B8); // grey text
const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);

// Font for numbers and IDs.
const _mono = TextStyle(fontFamily: 'monospace');

// Rounded card box with a border.
BoxDecoration _cardBox({
  Color border = _line,
  double width = 1,
  double radius = 12,
}) {
  return BoxDecoration(
    color: _card,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border, width: width),
  );
}

/// Driver Home screen.
///
/// TODO(api): every value on this screen is demo data. Later it will come
/// from the backend (driver, hours of service, trips, activity log).
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0; // selected bottom tab (0 = Home)

  final _tabLabels = ['Home', 'My Trips', 'Alerts', 'Profile'];
  final _tabIcons = [
    Icons.local_shipping_outlined,
    Icons.alt_route,
    Icons.notifications_none,
    Icons.person_outline,
  ];

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // Only Home exists for now. The other tabs show a message.
  void _onTabTap(int index) {
    if (index == 0) return;
    _showMessage('${_tabLabels[index]} is coming soon.');
  }

  @override
  Widget build(BuildContext context) {
    // Dark theme for this screen only: light text on a dark background.
    final base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        scaffoldBackgroundColor: _bg,
        textTheme: base.textTheme.apply(bodyColor: _text, displayColor: _text),
      ),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light, // white status bar icons
        child: Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(),
                _buildStatusStrip(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                    child: Column(
                      children: [
                        _buildGreetingCard(),
                        const SizedBox(height: 16),
                        _buildStatCards(),
                        const SizedBox(height: 16),
                        _buildActiveTripCard(),
                        const SizedBox(height: 24),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'UPCOMING & LOG ACTIVITY',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildUpcomingCard(),
                        const SizedBox(height: 12),
                        _buildLogCard(),
                        const SizedBox(height: 20),
                        _buildFooterPill(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(),
        ),
      ),
    );
  }

  // Logo on the left, support icon on the right.
  Widget _buildTopBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined,
              color: AppColors.lime, size: 30),
          const SizedBox(width: 14),
          const Text(
            'FleetFlow AI',
            style: TextStyle(
              color: AppColors.lime,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => _showMessage('Support is coming soon.'),
            icon: const Icon(Icons.support_agent, color: _muted, size: 28),
          ),
        ],
      ),
    );
  }

  // Thin bar: "Geotab ELD Paired • Live Sync OK" and "5G High-Band".
  Widget _buildStatusStrip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF16233A),
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 4, backgroundColor: AppColors.lime),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Geotab ELD Paired',
                    style: _mono.copyWith(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(
                    text: '  •  Live Sync OK',
                    style: TextStyle(fontSize: 13, color: _muted),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '5G High-Band',
            style: _mono.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.lime,
            ),
          ),
        ],
      ),
    );
  }

  // "Good morning, Ray" with the On Duty pill and the hours-left bar.
  Widget _buildGreetingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_greeting()}, Ray 👋',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 13.5, color: _muted),
                        children: [
                          const TextSpan(text: 'Driver Ray Morales  •  '),
                          TextSpan(
                            text: 'DRV-441',
                            style: _mono.copyWith(
                              color: AppColors.slate,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // "On Duty" pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.lime.withAlpha(30),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.lime, width: 1.5),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(radius: 4, backgroundColor: _green),
                    SizedBox(width: 6),
                    Text(
                      'On Duty',
                      style: TextStyle(
                        color: AppColors.lime,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: _line),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.schedule, color: AppColors.lime, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Drive Remaining:',
                style: TextStyle(fontSize: 14, color: _muted),
              ),
              const Spacer(),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '6h 14m',
                      style: _mono.copyWith(
                        color: AppColors.lime,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: ' / 11h HOS',
                      style: _mono.copyWith(color: _muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar: 6h 14m left of 11h
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.57,
              minHeight: 8,
              color: AppColors.lime,
              backgroundColor: _bg,
            ),
          ),
        ],
      ),
    );
  }

  // The three small cards: Assigned, Completed, Pending.
  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            number: '1',
            title: 'Assigned Trip',
            sub: 'URGENT',
            subColor: _red,
            icon: const CircleAvatar(radius: 4, backgroundColor: _red),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            number: '2',
            title: 'Completed',
            sub: 'Today',
            icon: const Icon(Icons.check_circle_outline,
                color: _green, size: 18),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            number: '3',
            title: 'Pending',
            sub: 'PTI, Fuel, Scale',
            numberColor: AppColors.warning,
            icon: const Icon(Icons.pending_actions,
                color: AppColors.warning, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String number,
    required String title,
    required String sub,
    required Widget icon,
    Color numberColor = _text,
    Color subColor = _muted,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardBox(radius: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                number,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: numberColor,
                ),
              ),
              icon,
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: subColor,
            ),
          ),
        ],
      ),
    );
  }

  // The big green-bordered card with the current trip.
  Widget _buildActiveTripCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(border: AppColors.lime, width: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined,
                      size: 18, color: _muted),
                  const SizedBox(width: 8),
                  Text(
                    '#TRP-4092',
                    style: _mono.copyWith(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              // "High Value Reefer" pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _red.withAlpha(25),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: _red.withAlpha(150)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.ac_unit, size: 14, color: _red),
                    SizedBox(width: 6),
                    Text(
                      'High Value Reefer',
                      style: TextStyle(
                        color: _red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              style: _mono.copyWith(fontSize: 13, color: _muted),
              children: [
                const TextSpan(text: 'Shipment ID: '),
                TextSpan(
                  text: '#SHP-88420',
                  style: _mono.copyWith(
                    color: _text,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _buildStop(
            color: AppColors.lime,
            label: 'PICKUP • TODAY 10:30 AM CST',
            name: 'Chicago O’Hare Air Cargo Hub',
            detail: 'Depot Hub CHI-02 • Bay 14B',
            showLine: true,
          ),
          _buildStop(
            color: AppColors.warning,
            label: 'DELIVERY • TOMORROW 06:15 AM EST',
            name: 'Atlanta Southeast MedHub',
            detail: 'Cold Storage Dock, Bay 4',
          ),
          const SizedBox(height: 18),
          // Distance / Transit / Temperature box
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _line),
            ),
            child: Row(
              children: [
                Expanded(child: _tripStat('Distance', '718 mi', _text)),
                Container(width: 1, height: 36, color: _line),
                Expanded(child: _tripStat('Est. Transit', '11h 45m', _text)),
                Container(width: 1, height: 36, color: _line),
                Expanded(
                    child: _tripStat('Reefer Temp', '-20°F', AppColors.lime)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Rig box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF172131),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _line),
            ),
            child: Row(
              children: [
                const Icon(Icons.rv_hookup_outlined, size: 20, color: _muted),
                const SizedBox(width: 10),
                const Text(
                  'Assigned\nRig:',
                  style: TextStyle(fontSize: 13, color: _muted),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Cascadia #9410 + 53' Reefer #TR-882",
                    style: _mono.copyWith(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () => _showMessage('Trip details is coming soon.'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.lime,
                foregroundColor: AppColors.charcoal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Trip Details',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // One stop on the route: a colored dot, a label, the place and details.
  Widget _buildStop({
    required Color color,
    required String label,
    required String name,
    required String detail,
    bool showLine = false, // draws the line down to the next stop
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: _bg,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Center(
                    child: CircleAvatar(radius: 4, backgroundColor: color),
                  ),
                ),
                if (showLine) Expanded(child: Container(width: 2, color: _line)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showLine ? 20 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      letterSpacing: 0.5,
                      color: _muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: const TextStyle(fontSize: 13, color: _muted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // One column of the Distance / Transit / Temp box.
  Widget _tripStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: _muted)),
        const SizedBox(height: 2),
        Text(
          value,
          style: _mono.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // Next trip card with the "Tentative Hold" tag.
  Widget _buildUpcomingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '#TRP-4098',
                style: _mono.copyWith(
                  color: AppColors.lime,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _line,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  'Tentative Hold',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Atlanta, GA → Charlotte, NC',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Departs Tomorrow 14:00 PM EST',
                      style: TextStyle(fontSize: 13, color: _muted),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: _text),
            ],
          ),
        ],
      ),
    );
  }

  // Recent activity: inspection logged and ELD synced.
  Widget _buildLogCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(),
      child: Column(
        children: [
          _logRow(
            Icons.check_circle_outline,
            _green,
            'Pre-trip DVIR checklist logged',
            'Today 07:15 AM • 12 Vehicle Inspection Points Passed',
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: _line),
          const SizedBox(height: 12),
          _logRow(
            Icons.sync,
            AppColors.lime,
            'Geotab ELD synchronized',
            'Today 09:30 AM • Certified Log Sync',
          ),
        ],
      ),
    );
  }

  Widget _logRow(IconData icon, Color color, String title, String sub) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(sub, style: const TextStyle(fontSize: 14, color: _muted)),
            ],
          ),
        ),
      ],
    );
  }

  // Small pill at the bottom of the page.
  Widget _buildFooterPill() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(radius: 3, backgroundColor: _green),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'GPS RTK: ±1.2m • FMCSA 49 CFR § 395 Verified',
                overflow: TextOverflow.ellipsis,
                style: _mono.copyWith(fontSize: 11, color: _muted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Bottom tabs: Home, My Trips, Alerts, Profile.
  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              for (var i = 0; i < _tabLabels.length; i++)
                Expanded(child: _buildTab(i)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index) {
    final selected = index == _tab;
    final color = selected ? AppColors.lime : _muted;
    final icon = Icon(_tabIcons[index], color: color);

    return InkWell(
      onTap: () => _onTabTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // "My Trips" has a small badge with the number 1
          index == 1
              ? Badge(
                  label: const Text('1'),
                  backgroundColor: AppColors.lime,
                  textColor: AppColors.charcoal,
                  child: icon,
                )
              : icon,
          const SizedBox(height: 4),
          Text(
            _tabLabels[index],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(
            height: 6,
            child: selected
                ? const CircleAvatar(radius: 2, backgroundColor: AppColors.lime)
                : null,
          ),
        ],
      ),
    );
  }
}