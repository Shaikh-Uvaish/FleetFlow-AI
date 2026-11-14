import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

// Colors used only on the dark screens.
const _bg = Color(0xFF111827); // page background
const _card = Color(0xFF171A17); // card background
const _line = Color(0xFF26364A); // borders and dividers
const _text = Color(0xFFF7F8F4); // main text
const _muted = Color(0xFF94A3B8); // grey text
const _green = Color(0xFF22C55E);
const _red = Color(0xFFEF4444);
const _orange = AppColors.warning;

// Font for numbers and IDs.
const _mono = TextStyle(fontFamily: 'monospace');

// ---------- small helpers used many times ----------

// Rounded card box with a border.
BoxDecoration _cardBox({Color border = _line, double radius = 12}) {
  return BoxDecoration(
    color: _card,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border),
  );
}

// Small grey label like "SCHEDULED WINDOW".
Widget _smallLabel(String text) {
  return Text(
    text,
    style: const TextStyle(fontSize: 10, letterSpacing: 0.5, color: _muted),
  );
}

// Small colored tag like ORIGIN, FINAL, CRITICAL.
Widget _tag(String text, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withAlpha(25),
      borderRadius: BorderRadius.circular(4),
      border: Border.all(color: color.withAlpha(150)),
    ),
    child: Text(
      text,
      style: _mono.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
      ),
    ),
  );
}

/// Trip Details screen: route, rig, cold-chain rules, and the
/// Accept / Decline buttons.
///
/// TODO(api): all values are demo data. Accept and Decline must call the
/// backend once the endpoints exist.
class TripDetailsScreen extends StatefulWidget {
  const TripDetailsScreen({super.key});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  Timer? _timer;
  int _secondsLeft = 18 * 60 + 45; // time left to accept: 18:45

  // Reasons shown when the driver declines: [title, description]
  final _declineReasons = const [
    [
      'HOS / Drive Time Limitation',
      'Insufficient rest window before 11h 45m run',
    ],
    [
      'Equipment Mismatch / Malfunction',
      'Reefer unable to guarantee -20.0°F cryo stability',
    ],
    [
      'Personal / Medical Emergency',
      'Driver unable to report to Chicago Hub CHI-02',
    ],
  ];

  @override
  void initState() {
    super.initState();
    // Counts down once per second until 00:00.
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Shows the time as mm:ss, for example 18:45
  String get _countdown {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _accept() {
    // TODO(api): send "accept" to the backend, then open the Trip Confirmed screen.
    _showMessage('Trip accepted. Backend is not connected yet.');
  }

  void _confirmDecline() {
    // TODO(api): send the decline reason to the backend.
    _showMessage('Decline recorded. Backend is not connected yet.');
  }

  @override
  Widget build(BuildContext context) {
    // Dark theme for this screen only.
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      children: [
                        _buildIdRow(),
                        const SizedBox(height: 12),
                        _buildAcceptanceBanner(),
                        const SizedBox(height: 12),
                        _buildPayloadRow(),
                        const SizedBox(height: 16),
                        _buildRouteCard(),
                        const SizedBox(height: 16),
                        _buildRigCard(),
                        const SizedBox(height: 16),
                        _buildColdChainCard(),
                        const SizedBox(height: 14),
                        _buildLockoutPill(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomButtons(),
        ),
      ),
    );
  }

  // ---------- top part ----------

  // Back on the left, title in the middle, share and support on the right.
  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back, color: AppColors.lime),
                  SizedBox(width: 8),
                  Text(
                    'Back',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Trip Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                Text(
                  'FLEETFLOW AI DISPATCH',
                  style: _mono.copyWith(
                    fontSize: 9,
                    letterSpacing: 1,
                    color: _muted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 90,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _showMessage('Share is coming soon.'),
                  icon: const Icon(Icons.share_outlined, size: 22),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _showMessage('Support is coming soon.'),
                  icon: const Icon(Icons.support_agent,
                      size: 24, color: AppColors.lime),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SHP-88420 • TRP-4092 ........ ● URGENT
  Widget _buildIdRow() {
    return Row(
      children: [
        _idChip('SHP-88420'),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('•', style: TextStyle(color: _muted)),
        ),
        _idChip('TRP-4092'),
        const Spacer(),
        const CircleAvatar(radius: 4, backgroundColor: _orange),
        const SizedBox(width: 6),
        Text(
          'URGENT',
          style: _mono.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _orange,
          ),
        ),
      ],
    );
  }

  Widget _idChip(String id) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: _cardBox(radius: 4),
      child: Text(
        id,
        style: _mono.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    );
  }

  // Orange banner with the countdown to accept the trip.
  Widget _buildAcceptanceBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _orange.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _orange.withAlpha(150), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _orange, width: 2),
            ),
            child: const Icon(Icons.timer_outlined, color: _orange),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Driver Acceptance',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 2),
                Text(
                  'Requires cab confirmation',
                  style: TextStyle(fontSize: 12, color: _muted),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _countdown,
                style: _mono.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _orange,
                ),
              ),
              Text(
                'MINUTES LEFT',
                style: _mono.copyWith(fontSize: 9, color: _muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPayloadRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: _cardBox(radius: 8),
      child: const Row(
        children: [
          Text(
            'Payload Protocol',
            style: TextStyle(fontSize: 13, color: _muted),
          ),
          Spacer(),
          Icon(Icons.ac_unit, size: 16, color: AppColors.lime),
          SizedBox(width: 6),
          Text(
            'Urgent • Pharma Cold Chain',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.lime,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- route card ----------

  Widget _buildRouteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(),
      child: Column(
        children: [
          _buildMetrics(),
          const SizedBox(height: 16),
          _buildMiniMap(),
          const SizedBox(height: 12),
          _buildHosPill(),
          const SizedBox(height: 18),
          // Stop 1: pickup
          _timelineItem(
            marker: _numberMarker('1', AppColors.lime),
            lineColor: AppColors.lime,
            content: _buildPickup(),
          ),
          // Waypoint: fuel stop
          _timelineItem(
            marker: const SizedBox(
              width: 24,
              height: 24,
              child: Center(
                child: CircleAvatar(radius: 6, backgroundColor: _orange),
              ),
            ),
            lineColor: _line,
            content: _buildWaypoint(),
          ),
          // Stop 2: delivery
          _timelineItem(
            marker: _numberMarker('2', AppColors.lime),
            content: _buildDelivery(),
          ),
        ],
      ),
    );
  }

  // Total distance, estimated run and corridor.
  Widget _buildMetrics() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'TOTAL DISTANCE',
                style: TextStyle(fontSize: 11, color: _muted),
              ),
              const SizedBox(height: 4),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '718 ',
                      style: _mono.copyWith(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.lime,
                      ),
                    ),
                    TextSpan(
                      text: 'Miles',
                      style: _mono.copyWith(fontSize: 12, color: _muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ESTIMATED RUN',
                style: TextStyle(fontSize: 11, color: _muted),
              ),
              const SizedBox(height: 4),
              Text(
                '11h 45m',
                style: _mono.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CORRIDOR',
              style: TextStyle(fontSize: 11, color: _muted),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: _cardBox(radius: 4),
              child: Text(
                'I-65 S',
                style: _mono.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Small route line: CHI-02 ---- fuel stop ---- CHI-ATL
  Widget _buildMiniMap() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _mapNode('CHI-02', 'Depot 14B', AppColors.lime, filled: true),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(height: 2, color: _line),
                        // green part of the line (done so far)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: 0.5,
                            child: Container(height: 2, color: AppColors.lime),
                          ),
                        ),
                        const CircleAvatar(radius: 4, backgroundColor: _orange),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'IND Fuel #34',
                    style: _mono.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _mapNode('CHI-ATL', 'MedHub G3', _muted),
        ],
      ),
    );
  }

  Widget _mapNode(String code, String sub, Color color, {bool filled = false}) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: filled
              ? Center(child: CircleAvatar(radius: 4, backgroundColor: color))
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          code,
          style: _mono.copyWith(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        Text(sub, style: const TextStyle(fontSize: 9, color: _muted)),
      ],
    );
  }

  // "✓ HOS Compliant Route ........ Speed Cap: 68 MPH"
  Widget _buildHosPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 18, color: _green),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'HOS Compliant Route',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            'Speed Cap: 68 MPH',
            style: _mono.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.lime,
            ),
          ),
        ],
      ),
    );
  }

  // One row of the route: a marker on the left and the content on the right.
  // lineColor draws a vertical line down to the next row.
  Widget _timelineItem({
    required Widget marker,
    required Widget content,
    Color? lineColor,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                marker,
                if (lineColor != null)
                  Expanded(child: Container(width: 2, color: lineColor)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: lineColor != null ? 18 : 0),
              child: content,
            ),
          ),
        ],
      ),
    );
  }

  Widget _numberMarker(String number, Color color) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _bg,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        number,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildPickup() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                'Pickup: Chicago O’Hare Air Logistics',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 8),
            _tag('ORIGIN', AppColors.lime),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Dock Door 14B • 10500 Cargo Way, Chicago IL',
          style: TextStyle(fontSize: 12, color: _muted),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _infoBox(
                  label: 'SCHEDULED WINDOW',
                  main: Text(
                    'Today 10:30 - 11:30 AM',
                    style: _mono.copyWith(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  sub: 'CST (Firm Window)',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoBox(
                  label: 'TERMINAL OPS',
                  main: _phoneRow('(312) 555-0144'),
                  sub: 'Gate Code: 8810',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaypoint() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Waypoint: Indianapolis Staging Stop #34',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 2),
              Text(
                'I-65 Exit 109 • Pilot Flying J Cryo Station',
                style: TextStyle(fontSize: 12, color: _muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'MANDATORY\nFUEL',
          textAlign: TextAlign.right,
          style: _mono.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: _orange,
          ),
        ),
      ],
    );
  }

  Widget _buildDelivery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                'Delivery: Atlanta Southeast MedHub',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 8),
            _tag('FINAL', _muted),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Gate 3 Cold Terminal • 4200 Logistics Blvd, Atlanta GA',
          style: TextStyle(fontSize: 12, color: _muted),
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _infoBox(
                  label: 'DELIVERY WINDOW',
                  main: Text(
                    'Tomorrow 06:15 - 07:30',
                    style: _mono.copyWith(
                        fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  sub: 'EST (Priority Slot)',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _infoBox(
                  label: 'RECEIVING SUPV',
                  main: _phoneRow('(404) 555-8921'),
                  sub: 'Security Guarded',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Small box with a label, a main line and a small note.
  Widget _infoBox({
    required String label,
    required Widget main,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _smallLabel(label),
          const SizedBox(height: 4),
          main,
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(fontSize: 11, color: _muted)),
        ],
      ),
    );
  }

  Widget _phoneRow(String number) {
    return Row(
      children: [
        const Icon(Icons.call, size: 16, color: AppColors.lime),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            number,
            style: _mono.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.lime,
            ),
          ),
        ),
      ],
    );
  }

  // ---------- rig card ----------

  Widget _buildRigCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_outlined,
                  color: AppColors.lime, size: 30),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Assigned Rig & Trailer',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              const CircleAvatar(radius: 3, backgroundColor: _green),
              const SizedBox(width: 6),
              Text(
                'Pre-Trip\nInspected',
                style: _mono.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: _line),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _rigBox(
                    label: 'TRACTOR UNIT',
                    big: '#9410',
                    line1: '2024 Freightliner Cascadia',
                    line2: 'Auto • 450 HP • DEF 92%',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _rigBox(
                    label: 'REEFER TRAILER',
                    big: '#TR-882',
                    line1: "53' Utility Cryo-Spec",
                    line2: 'Set-point: -20.0°F',
                    line2Color: AppColors.lime,
                    accent: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Payload weight box
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _line),
            ),
            child: Row(
              children: [
                Expanded(
                    child: _payloadItem('PAYLOAD WEIGHT', '36,400 lbs', _text)),
                Container(width: 1, height: 30, color: _line),
                Expanded(
                    child: _payloadItem('LEGAL CAPACITY', '44,000 lbs', _text)),
                Container(width: 1, height: 30, color: _line),
                Expanded(
                  child: _payloadItem(
                      'MARGIN SAFE', '+7,600 lbs', AppColors.lime),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tractor / trailer box. accent adds a green bar on the left.
  Widget _rigBox({
    required String label,
    required String big,
    required String line1,
    required String line2,
    Color line2Color = _muted,
    bool accent = false,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: _bg,
          border: Border.all(color: _line),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (accent) Container(width: 3, color: AppColors.lime),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(fontSize: 11, color: _muted)),
                    const SizedBox(height: 4),
                    Text(
                      big,
                      style: _mono.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(line1, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      line2,
                      style: _mono.copyWith(
                        fontSize: 10,
                        fontWeight:
                            accent ? FontWeight.w700 : FontWeight.normal,
                        color: line2Color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _payloadItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: _muted)),
        const SizedBox(height: 4),
        Text(
          value,
          style: _mono.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ---------- cold chain card ----------

  Widget _buildColdChainCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(border: _red.withAlpha(100)),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: _red, size: 28),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Special Cold-Chain Protocols',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              _tag('CRITICAL', _red),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _line),
            ),
            child: Column(
              children: [
                _protocolRow(
                  Icons.thermostat,
                  AppColors.lime,
                  'Continuous Reefer Run Mode',
                  'Cycle-Sentry is strictly prohibited. Temperature variance '
                      'must not exceed ±1.5°F. Pre-cool trailer to -20°F '
                      'before loading.',
                ),
                const SizedBox(height: 12),
                Container(height: 1, color: _line),
                const SizedBox(height: 12),
                _protocolRow(
                  Icons.lock_outline,
                  _orange,
                  'Tamper-Evident Electronic Seal #ES-99014',
                  'Do not break electronic door seal until Atlanta dock agent '
                      'signs bill of lading and registers digital signature.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const CircleAvatar(radius: 3, backgroundColor: _green),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Real-time BLE Sensor Feed Active',
                  style: TextStyle(fontSize: 12, color: _muted),
                ),
              ),
              Text(
                'Core: -20.2°F OK',
                style: _mono.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _protocolRow(IconData icon, Color color, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style:
                    const TextStyle(fontSize: 12, height: 1.4, color: _muted),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLockoutPill() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _line),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_outlined, size: 16, color: _muted),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Active Fleet Lockout: 1 Trip Assignment per Driver',
                style: TextStyle(fontSize: 11, color: _muted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- bottom buttons ----------

  // Accept and Decline stay at the bottom of the screen.
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(top: BorderSide(color: _line)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _accept,
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
                      'Accept Trip Assignment',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _showDeclineSheet,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _red,
                  backgroundColor: _red.withAlpha(15),
                  side: BorderSide(color: _red.withAlpha(150)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.close, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Decline Trip',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Popup from the bottom: the driver must pick a reason to decline.
  void _showDeclineSheet() {
    int? selected; // which reason is picked (null = none yet)

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // This popup sits outside the dark theme, so the
                    // text colors are set directly.
                    const Text(
                      'Decline Assignment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Requires immediate reason logging for dispatch review.',
                      style: TextStyle(fontSize: 13, color: _muted),
                    ),
                    const SizedBox(height: 16),
                    for (var i = 0; i < _declineReasons.length; i++)
                      GestureDetector(
                        onTap: () => setSheetState(() => selected = i),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _bg,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selected == i ? _red : _line,
                              width: selected == i ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected == i
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: selected == i ? _red : _muted,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _declineReasons[i][0],
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: _text,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _declineReasons[i][1],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: _muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _text,
                              side: const BorderSide(color: _line),
                              minimumSize: const Size(0, 48),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            // Disabled until a reason is picked.
                            onPressed: selected == null
                                ? null
                                : () {
                                    Navigator.pop(sheetContext);
                                    _confirmDecline();
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: _red,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, 48),
                            ),
                            child: const Text('Confirm Decline'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}