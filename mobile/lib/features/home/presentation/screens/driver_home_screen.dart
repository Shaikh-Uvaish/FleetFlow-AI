import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../trips/presentation/screens/trip_details_screen.dart';

// Extra colors used only on this screen.
const _greenBg = Color(0xFFECFDF5);
const _greenBorder = Color(0xFFA7F3D0);
const _greenText = Color(0xFF065F46);
const _paleGrey = Color(0xFFF8FAFC);
const _lineGrey = Color(0xFFCBD5E1);

// Font for numbers and IDs.
const _mono = TextStyle(fontFamily: 'monospace');

// White box with a border.
BoxDecoration _box({
  Color color = Colors.white,
  Color border = AppColors.border,
  double radius = 12,
}) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border),
  );
}

/// Driver Home screen (light design).
///
/// TODO(api): every value on this screen is demo data. Later it will come
/// from the backend (driver, hours of service, trips, activity).
class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final int _tab = 0; // selected bottom tab (0 = Home)

  final _tabLabels = ['Home', 'My Trips', 'Alerts', 'Profile'];
  final _tabIcons = [
    Icons.local_shipping_outlined,
    Icons.route_outlined,
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

  void _openTripDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const TripDetailsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    _buildStatCards(),
                    const SizedBox(height: 16),
                    _buildTripCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Upcoming Assignment', 'Next in queue'),
                    const SizedBox(height: 12),
                    _buildUpcomingCard(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Today’s Activity', '2 events synced'),
                    const SizedBox(height: 12),
                    _buildActivityCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------- header (white area at the top) ----------

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogoRow(),
          const SizedBox(height: 18),
          _buildGreeting(),
          const SizedBox(height: 16),
          _buildDrivingWindow(),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(radius: 3, backgroundColor: AppColors.success),
                  SizedBox(width: 6),
                  Text(
                    'Geotab ELD Paired',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ),
              Text(
                'GPS RTK ±1.2m Active',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11.5,
                  color: AppColors.slate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Logo and name on the left, support button and avatar on the right.
  Widget _buildLogoRow() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.local_shipping_outlined,
              color: AppColors.lime, size: 22),
        ),
        const SizedBox(width: 10),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FleetFlow AI',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              Text(
                'Enterprise Logistics OS',
                style: TextStyle(fontSize: 12.5, color: AppColors.slate),
              ),
            ],
          ),
        ),
        // Support button
        InkWell(
          onTap: () => _showMessage('Support is coming soon.'),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 38,
            height: 38,
            decoration: _box(radius: 10),
            child: const Icon(Icons.support_agent,
                size: 20, color: AppColors.charcoal),
          ),
        ),
        const SizedBox(width: 10),
        // Avatar with the green "online" dot.
        // TODO(api): show the driver's real photo here.
        Stack(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.charcoal,
              child: Text(
                'RM',
                style: TextStyle(
                  color: AppColors.lime,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // "Good morning, Ray" and the On Duty pill.
  Widget _buildGreeting() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_greeting()}, Ray 👋',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  style: const TextStyle(fontSize: 14, color: AppColors.slate),
                  children: [
                    const TextSpan(text: 'Driver Ray Morales • '),
                    TextSpan(
                      text: '#DRV-441',
                      style: _mono.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _greenBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _greenBorder),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(radius: 3.5, backgroundColor: AppColors.success),
              SizedBox(width: 6),
              Text(
                'On Duty',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _greenText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // "Remaining Driving Window" with the progress bar.
  Widget _buildDrivingWindow() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.schedule, size: 18, color: AppColors.slate),
            const SizedBox(width: 6),
            const Text(
              'Remaining Driving Window',
              style: TextStyle(fontSize: 13.5, color: AppColors.slate),
            ),
            const Spacer(),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '6h 14m ',
                    style: _mono.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  TextSpan(
                    text: '/ 11h HOS',
                    style: _mono.copyWith(
                        fontSize: 12, color: AppColors.slate),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: const LinearProgressIndicator(
            value: 0.57,
            minHeight: 6,
            color: AppColors.charcoal,
            backgroundColor: AppColors.border,
          ),
        ),
      ],
    );
  }

  // ---------- stat cards ----------

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            label: 'Assigned',
            number: '1',
            sub: const Text(
              'Immediate',
              style: TextStyle(fontSize: 12.5, color: AppColors.error),
            ),
            showDot: true,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            label: 'Completed',
            number: '2',
            sub: const Row(
              children: [
                Icon(Icons.check, size: 14, color: AppColors.success),
                SizedBox(width: 3),
                Text(
                  'Today',
                  style: TextStyle(fontSize: 12.5, color: AppColors.success),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            label: 'Pending',
            number: '3',
            sub: const Text(
              'PTI • Fuel • WIM',
              style: TextStyle(fontSize: 11.5, color: AppColors.slate),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String label,
    required String number,
    required Widget sub,
    bool showDot = false, // red dot in the corner
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _box(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: AppColors.slate),
              ),
              if (showDot)
                const CircleAvatar(radius: 4, backgroundColor: AppColors.error),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            number,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          sub,
        ],
      ),
    );
  }

  // ---------- current trip card ----------

  Widget _buildTripCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: reefer tag and trip number
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.ac_unit, size: 14, color: AppColors.error),
                    SizedBox(width: 6),
                    Text(
                      'High Priority Reefer',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#TRP-4092',
                  style: _mono.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Manifest #SHP-88420',
                style: TextStyle(fontSize: 14, color: AppColors.slate),
              ),
              Row(
                children: [
                  Icon(Icons.verified_outlined,
                      size: 16, color: AppColors.success),
                  SizedBox(width: 4),
                  Text(
                    'Ready for Hook',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Pickup
          _buildStop(
            marker: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.charcoal, width: 4),
              ),
            ),
            label: 'PICKUP POINT',
            name: 'Chicago O’Hare Air Cargo Hub',
            detail: 'Depot CHI-02 • Bay 14B',
            timeIcon: Icons.calendar_today_outlined,
            time: 'Today 10:30 AM CST',
            showLine: true,
          ),
          // Destination
          _buildStop(
            marker: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: AppColors.lime,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.charcoal, width: 2),
              ),
            ),
            label: 'DESTINATION DOCK',
            name: 'Atlanta Southeast MedHub',
            detail: 'Cold Storage Dock 4',
            timeIcon: Icons.event_available_outlined,
            time: 'Tomorrow 06:15 AM EST',
          ),
          const SizedBox(height: 16),
          // Distance, transit, reefer boxes
          Row(
            children: [
              Expanded(child: _tripStat('Distance', '718', unit: ' mi')),
              const SizedBox(width: 8),
              Expanded(child: _tripStat('Est. Transit', '11h 45m')),
              const SizedBox(width: 8),
              Expanded(child: _tripStat('Reefer Set', '-20.0°F', green: true)),
            ],
          ),
          const SizedBox(height: 10),
          // Rig box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: _box(color: _paleGrey, radius: 8),
            child: Row(
              children: [
                const Icon(Icons.rv_hookup_outlined,
                    size: 20, color: AppColors.slate),
                const SizedBox(width: 10),
                const Text(
                  'Cascadia #9410',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: AppColors.slate)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "53' Utility #TR-882",
                    overflow: TextOverflow.ellipsis,
                    style: _mono.copyWith(
                        fontSize: 12, color: AppColors.slate),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _openTripDetails,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.lime,
                foregroundColor: AppColors.charcoal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Trip Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // One stop: a marker on the left and the place details on the right.
  Widget _buildStop({
    required Widget marker,
    required String label,
    required String name,
    required String detail,
    required IconData timeIcon,
    required String time,
    bool showLine = false, // line down to the next stop
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                const SizedBox(height: 2),
                marker,
                if (showLine)
                  Expanded(
                    child: Center(
                      child: Container(width: 2, color: _lineGrey),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: showLine ? 18 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      letterSpacing: 0.5,
                      color: AppColors.slate,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style:
                        const TextStyle(fontSize: 14, color: AppColors.slate),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(timeIcon, size: 16, color: AppColors.ink),
                      const SizedBox(width: 6),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // One of the three boxes: Distance, Est. Transit, Reefer Set.
  Widget _tripStat(
    String label,
    String value, {
    String unit = '',
    bool green = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: _box(
        color: green ? _greenBg : _paleGrey,
        border: green ? _greenBorder : AppColors.border,
        radius: 8,
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: green ? _greenText : AppColors.slate,
            ),
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: _mono.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: green ? AppColors.success : AppColors.ink,
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: _mono.copyWith(fontSize: 11, color: AppColors.slate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- upcoming and activity ----------

  // Title on the left, small grey text on the right.
  Widget _buildSectionTitle(String title, String note) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        Text(
          note,
          style: _mono.copyWith(fontSize: 12.5, color: AppColors.slate),
        ),
      ],
    );
  }

  Widget _buildUpcomingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _box(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '#TRP-4098',
                      style: _mono.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF9C3),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: const Text(
                        'TENTATIVE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Atlanta, GA → Charlotte, NC',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Departs Tomorrow 14:00 PM EST • Dry Van',
                  style: TextStyle(fontSize: 13.5, color: AppColors.slate),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: _box(radius: 8),
            child: const Icon(Icons.chevron_right, color: AppColors.ink),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard() {
    return Container(
      decoration: _box(),
      child: Column(
        children: [
          _activityRow(
            icon: Icons.fact_check_outlined,
            iconBg: _greenBg,
            iconBorder: _greenBorder,
            iconColor: AppColors.success,
            title: 'Pre-trip DVIR checklist logged',
            time: '07:15 AM',
            body: '12 vehicle inspection points passed • Brake pads & tires '
                'certified',
          ),
          const Divider(height: 1, color: AppColors.border),
          _activityRow(
            icon: Icons.sync,
            iconBg: const Color(0xFFEFF6FF),
            iconBorder: const Color(0xFFBFDBFE),
            iconColor: const Color(0xFF2563EB),
            title: 'Geotab ELD synchronized',
            time: '09:30 AM',
            body: 'Certified log sync • FMCSA compliant status transmitted',
          ),
        ],
      ),
    );
  }

  Widget _activityRow({
    required IconData icon,
    required Color iconBg,
    required Color iconBorder,
    required Color iconColor,
    required String title,
    required String time,
    required String body,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: iconBorder),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: _mono.copyWith(
                          fontSize: 12, color: AppColors.slate),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.slate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- bottom tabs ----------

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
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
    final color = selected ? AppColors.charcoal : AppColors.slate;
    final icon = Icon(_tabIcons[index], size: 26, color: color);

    Widget iconWidget = icon;
    if (index == 0) {
      // small green dot next to the Home icon
      iconWidget = Badge(
        smallSize: 7,
        backgroundColor: AppColors.success,
        child: icon,
      );
    } else if (index == 1) {
      // "My Trips" badge with the number 1
      iconWidget = Badge(
        label: const Text('1'),
        backgroundColor: AppColors.success,
        child: icon,
      );
    }

    return InkWell(
      onTap: () => _onTabTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(height: 4),
          Text(
            _tabLabels[index],
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}