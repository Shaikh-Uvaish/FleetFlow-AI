import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import 'trip_details_screen.dart';

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

// Rounded card box with a border.
BoxDecoration _cardBox({Color border = _line, double radius = 12}) {
  return BoxDecoration(
    color: _card,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border),
  );
}

// Small capital label like "DESTINATION".
Widget _label(String text) {
  return Text(
    text,
    style: const TextStyle(fontSize: 12, letterSpacing: 0.5, color: _muted),
  );
}

/// Trip Confirmed screen: shown after the driver accepts a trip.
/// It has the pre-departure checklist and the Start Inspection button.
///
/// TODO(api): all values are demo data. The checklist state must be saved
/// to the backend, and items 3 and 4 should complete by themselves when the
/// inspection and the gate scan are done.
class TripAcceptanceScreen extends StatefulWidget {
  const TripAcceptanceScreen({super.key});

  @override
  State<TripAcceptanceScreen> createState() => _TripAcceptanceScreenState();
}

class _TripAcceptanceScreenState extends State<TripAcceptanceScreen> {
  // Which checklist items are done. Item 1 is already signed.
  final List<bool> _done = [true, false, false, false];

  int get _doneCount => _done.where((d) => d).length;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: Column(
                      children: [
                        _buildHeroCard(),
                        const SizedBox(height: 16),
                        _buildShipmentCard(),
                        const SizedBox(height: 20),
                        _buildChecklistHeader(),
                        const SizedBox(height: 12),
                        _buildChecklist(),
                        const SizedBox(height: 16),
                        _buildComplianceNotice(),
                        const SizedBox(height: 20),
                        _buildButtons(),
                        const SizedBox(height: 16),
                        _buildDispatcherLink(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // X on the left, title in the middle, support icon on the right.
  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: _bg,
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 26),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Trip Confirmed',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showMessage('Support is coming soon.'),
            icon: const Icon(Icons.support_agent,
                size: 26, color: AppColors.lime),
          ),
        ],
      ),
    );
  }

  // "Trip Assignment Accepted!" card with the LOCKED tag.
  Widget _buildHeroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.lime,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline,
                size: 30, color: AppColors.charcoal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        'Trip Assignment Accepted!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.lime,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // LOCKED tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.lime.withAlpha(30),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.lime),
                      ),
                      child: const Text(
                        'LOCKED',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.lime,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    style:
                        const TextStyle(fontSize: 13, height: 1.4, color: _muted),
                    children: [
                      const TextSpan(text: 'Trip '),
                      TextSpan(
                        text: '#TRP-4092',
                        style: _mono.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _text,
                        ),
                      ),
                      const TextSpan(text: ' is locked to your driver profile ('),
                      const TextSpan(
                        text: 'Ray Morales, #DRV-441',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _text,
                        ),
                      ),
                      const TextSpan(
                        text: '). Dispatch and ELD have been notified.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Shipment ID, pickup deadline, destination and route.
  Widget _buildShipmentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _cardBox(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_shipping_outlined,
                      size: 28, color: AppColors.lime),
                  const SizedBox(width: 10),
                  Text(
                    '#SHP-88420',
                    style: _mono.copyWith(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              // Truck name pill
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1D36),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _line),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.directions_bus, size: 16, color: _muted),
                    SizedBox(width: 8),
                    Text(
                      'Cascadia #9410',
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: _line),
          const SizedBox(height: 14),
          _buildPickupDeadline(),
          const SizedBox(height: 16),
          _buildDestination(),
        ],
      ),
    );
  }

  Widget _buildPickupDeadline() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16233A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.schedule, size: 18, color: _orange),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'PICKUP WINDOW DEADLINE',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _orange,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Today by 10:30 AM CST',
                  style: _mono.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _orange.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '42 min\nremaining',
                  textAlign: TextAlign.right,
                  style: _mono.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _orange,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'to arrive at gate',
                style: TextStyle(fontSize: 12, color: _muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Icons with a line on the left, destination and route on the right.
  Widget _buildDestination() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const Icon(Icons.location_on, size: 24, color: AppColors.lime),
                Expanded(
                  child: Center(child: Container(width: 2, color: _line)),
                ),
                const Icon(Icons.alt_route, size: 18, color: _muted),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _label('DESTINATION'),
                const SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        'Atlanta Southeast MedHub Cold Terminal',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '718 mi',
                      style: _mono.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.lime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _label('ROUTE CORRIDOR'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'I-65 S / I-24 E',
                      style: _mono.copyWith(
                          fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _line,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Optimal Weather',
                        style: TextStyle(fontSize: 10, color: _muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- checklist ----------

  Widget _buildChecklistHeader() {
    return Row(
      children: [
        const Icon(Icons.fact_check_outlined, size: 26),
        const SizedBox(width: 10),
        const Expanded(
          child: Text(
            'Pre-Departure Driver Checklist',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        Text(
          '$_doneCount of 4\nCompleted',
          textAlign: TextAlign.right,
          style: _mono.copyWith(fontSize: 12, color: _muted),
        ),
      ],
    );
  }

  Widget _buildChecklist() {
    return Column(
      children: [
        _checkItem(
          index: 0,
          title: 'Review Dispatch & Cold-Chain Handling Notes',
          subtitle: _subRow(
            'Completed & Signed',
            color: _green,
            leading: const Icon(Icons.verified_outlined, size: 14, color: _green),
          ),
        ),
        const SizedBox(height: 10),
        _checkItem(
          index: 1,
          title: 'Verify Vehicle & Trailer Connection (Unit #9410 + Trailer '
              '#TR-882)',
          subtitle: _subRow(
            'Pending hookup confirmation',
            leading: const CircleAvatar(radius: 3, backgroundColor: _orange),
          ),
        ),
        const SizedBox(height: 10),
        _checkItem(
          index: 2,
          title: 'Conduct Pre-Trip DVIR Inspection',
          subtitle: _subRow(
            'Tires, Brakes, Air Lines & Reefer Fuel Level (Min 85%)',
          ),
          tag: _fmcsaTag(),
          focused: true,
        ),
        const SizedBox(height: 10),
        _checkItem(
          index: 3,
          title: 'Arrive at Chicago Cargo Hub Gate 14B & Scan In',
          subtitle: _subRow(
            'Barcode auto-staged in app',
            leading: const Icon(Icons.qr_code_scanner,
                size: 14, color: AppColors.lime),
          ),
        ),
      ],
    );
  }

  // One checklist row. Tap it to tick or untick (except the first one).
  Widget _checkItem({
    required int index,
    required String title,
    required Widget subtitle,
    Widget? tag,
    bool focused = false,
  }) {
    final done = _done[index];
    final canTap = index != 0; // the first item is already signed

    Color borderColor = _line;
    if (done) {
      borderColor = _green.withAlpha(100);
    } else if (focused) {
      borderColor = AppColors.lime.withAlpha(200);
    }

    return GestureDetector(
      onTap: canTap
          ? () => setState(() {
                _done[index] = !_done[index];
              })
          : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: _cardBox(border: borderColor, radius: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The tick box
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: done ? _green : _bg,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: done
                      ? _green
                      : (focused ? AppColors.lime : _muted),
                  width: 2,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: done ? _muted : _text,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  subtitle,
                ],
              ),
            ),
            if (tag != null) ...[
              const SizedBox(width: 8),
              tag,
            ],
          ],
        ),
      ),
    );
  }

  // Small line under a checklist title, with an optional icon in front.
  Widget _subRow(String text, {Widget? leading, Color color = _muted}) {
    return Row(
      children: [
        if (leading != null) ...[
          leading,
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 12, color: color)),
        ),
      ],
    );
  }

  // Red "FMCSA REQ" tag.
  Widget _fmcsaTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: _red.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _red),
      ),
      child: const Text(
        'FMCSA\nREQ',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: _red,
        ),
      ),
    );
  }

  // ---------- bottom part ----------

  Widget _buildComplianceNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2B3D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _line),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, size: 22, color: _orange),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FMCSA 49 CFR Part 396 Compliance',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    style: TextStyle(fontSize: 12, height: 1.4, color: _muted),
                    children: [
                      TextSpan(text: 'ELD logging will switch automatically to '),
                      TextSpan(
                        text: '“On Duty - Not Driving”',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: _text,
                        ),
                      ),
                      TextSpan(text: ' during inspection.'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            onPressed: () => _showMessage('Pre-Trip Inspection is coming soon.'),
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
                  'Start Pre-Trip Inspection',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            // Opens the Trip Details screen we built before.
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TripDetailsScreen()),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0F1D36),
              foregroundColor: _text,
              side: const BorderSide(color: _line),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_outlined, size: 20, color: _muted),
                SizedBox(width: 10),
                Text(
                  'View Full Trip Details & Waypoints',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDispatcherLink() {
    return Center(
      child: GestureDetector(
        onTap: () => _showMessage('Calling is coming soon.'),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.call_outlined, size: 18, color: _muted),
            SizedBox(width: 8),
            Flexible(
              child: Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 12.5),
                  children: [
                    TextSpan(
                      text: 'Need to contact Dispatcher Elena Rostova? ',
                    ),
                    TextSpan(
                      text: 'Tap to Call',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
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
}