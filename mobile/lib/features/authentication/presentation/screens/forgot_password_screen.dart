import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Reset Driver Password screen.
/// Shows the form first. After "Send Reset Instructions" the green
/// success card appears under it.
///
/// TODO(api): call the real reset-password endpoint once the backend has it.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();

  // TODO(api): load the terminal list from the backend.
  final _terminals = [
    'Chicago Terminal Hub 02 (Midwest)',
    'Indianapolis Gateway Depot 01',
    'Detroit Freight Yard 03',
    'Columbus Cross-Dock 04',
  ];
  late String _terminal = _terminals.first;

  bool _loading = false; // true while "sending"
  bool _sent = false; // true after sending, shows the success card

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _sent = false;
    });

    // TODO(api): send the request to the backend. For now we just wait a moment.
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // White rounded card used for the sections.
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: [
                    _buildHeaderCard(),
                    const SizedBox(height: 16),
                    _buildFormCard(),
                    if (_sent) ...[
                      const SizedBox(height: 16),
                      _buildSuccessCard(),
                    ],
                    const SizedBox(height: 16),
                    _buildSupportCard(),
                    const SizedBox(height: 12),
                    _buildTroubleshooterLink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // "< Driver Login" on the left and the FLEET-GATEWAY pill on the right.
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: AppColors.ink),
                SizedBox(width: 8),
                Text(
                  'Driver Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.border),
            ),
            child: const Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: AppColors.lime),
                SizedBox(width: 6),
                Text(
                  'FLEET-GATEWAY',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
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

  // Key icon, "BYPASS PROTOCOL" pill, title and description.
  Widget _buildHeaderCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.charcoal,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.key, color: AppColors.lime, size: 28),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lock_reset, size: 16, color: AppColors.slate),
                    SizedBox(width: 6),
                    Text(
                      'BYPASS PROTOCOL',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Reset Driver Password',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter your registered driver phone number, CDL email, or Driver '
            'ID. We’ll send an instant security reset link or temporary PIN '
            'to get you back on route.',
            style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.slate),
          ),
        ],
      ),
    );
  }

  // The form: driver ID, terminal dropdown and the green button.
  Widget _buildFormCard() {
    return _card(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phone Number, CDL Email, or Driver ID',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _idController,
              validator: (value) {
                if (value == null || value.trim().length < 3) {
                  return 'Enter your phone, email or Driver ID';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'e.g. +1 (555) 019-2834 or DRV-441',
                contentPadding: EdgeInsets.symmetric(vertical: 18),
                prefixIcon: Icon(Icons.badge_outlined, color: AppColors.ink),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Assigned Terminal Verification',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _terminal,
              isExpanded: true,
              icon: const Icon(Icons.unfold_more, color: AppColors.ink),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 18),
                prefixIcon: Icon(Icons.storefront_outlined),
              ),
              items: [
                for (final t in _terminals)
                  DropdownMenuItem(
                    value: t,
                    child: Text(
                      'Assigned Terminal: $t',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _terminal = value);
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _loading ? null : _send,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.lime,
                  foregroundColor: AppColors.charcoal,
                  disabledBackgroundColor: AppColors.lime.withAlpha(180),
                  side: const BorderSide(color: Color(0xFF84CC16)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _loading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.charcoal,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Dispatching Security Token...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Send Reset Instructions',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 10),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Green card shown after the instructions are sent.
  Widget _buildSuccessCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.success.withAlpha(100),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(height: 4, color: AppColors.success), // green top line
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFDCFCE7),
                        child: Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 22,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reset Instructions Sent!',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Security dispatch dispatched via encrypted SMS '
                              'channel',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.slate,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Grey box with the bypass details
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.offWhite,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.sms_outlined,
                                size: 16, color: AppColors.success),
                            SizedBox(width: 8),
                            Text(
                              'Temporary Cab Bypass Active',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            style: TextStyle(fontSize: 13, height: 1.4),
                            children: [
                              TextSpan(
                                text: 'Temporary cab bypass code sent to your '
                                    'registered contact. Link expires in ',
                              ),
                              TextSpan(
                                text: '15 minutes',
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.error,
                                ),
                              ),
                              TextSpan(text: '.'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStep(
                    '1',
                    const TextSpan(
                      children: [
                        TextSpan(text: 'Check your SMS messages for the '),
                        TextSpan(
                          text: '6-digit unlock PIN',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.lime,
                            decorationThickness: 2,
                          ),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildStep(
                    '2',
                    const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Use the PIN to authenticate and set a new '
                              'password on your ',
                        ),
                        TextSpan(
                          text: 'ELD tablet',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, size: 20),
                      label: const Text('Back to Driver Sign In'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // One numbered step: a dark square with the number, then the text.
  Widget _buildStep(String number, TextSpan text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: AppColors.lime,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink,
                ),
                children: [text],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Dark card with the dispatch phone number.
  Widget _buildSupportCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.charcoal,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.support_agent, color: AppColors.warning),
              SizedBox(width: 8),
              Text(
                'IMMEDIATE DISPATCH LOCKOUT?',
                style: TextStyle(
                  color: AppColors.warning,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // TODO(config): hub name and phone number come from the backend later.
          const Text.rich(
            TextSpan(
              style: TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: Color(0xFFCBD5E1),
              ),
              children: [
                TextSpan(
                  text: 'Stuck during safety pre-trip inspection? Contact ',
                ),
                TextSpan(
                  text: 'Chicago Hub Fleet Support',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: ' at '),
                TextSpan(
                  text: '(312) 555-0100',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    color: AppColors.lime,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' for biometric bypass or terminal supervisor '
                      'authorization.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(height: 1, color: const Color(0xFF262F3D)),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(Icons.verified_outlined, size: 16, color: AppColors.lime),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Zero-Trust Carrier Authentication',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    color: AppColors.slate,
                  ),
                ),
              ),
              Text(
                'FMCSA 49 CFR § 395',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshooterLink() {
    return InkWell(
      onTap: () => _showMessage('Troubleshooter is coming soon.'),
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.help_center_outlined, size: 18, color: AppColors.slate),
            SizedBox(width: 6),
            Flexible(
              child: Text(
                'ELD Hardware & Bluetooth Pairing Troubleshooter',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}