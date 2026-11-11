import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';

// Hides most of the phone number.
// Example: "+1 (555) 019-2834" becomes "+1 (555) •••-2834"
String maskPhoneNumber(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 10) return phone;

  final last4 = digits.substring(digits.length - 4);
  final area = digits.substring(digits.length - 10, digits.length - 7);
  final country = digits.length > 10
      ? '+${digits.substring(0, digits.length - 10)} '
      : '';
  return '$country($area) •••-$last4';
}

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.maskedPhone,
    this.assignedUnit,
  });

  final String maskedPhone; // already masked, like "+1 (555) •••-2834"
  final String? assignedUnit; // optional, hidden when null

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  // One controller and one focus node for each of the 6 boxes.
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _secondsLeft = 60;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Counts down once per second until it reaches 0.
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
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  // Called every time a box changes.
  void _onDigitChanged(int index, String value) {
    setState(() {
      _error = null;
    });
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus(); // jump to the next box
    }
    if (value.isNotEmpty && index == 5) {
      FocusScope.of(context).unfocus(); // last box filled, close keyboard
    }
  }

  void _verify() {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      setState(() {
        _error = 'Enter all 6 digits of the code.';
      });
      return;
    }
    FocusScope.of(context).unfocus();
    // TODO(api): send the code to the backend to verify it.
    _showMessage('Code entered. Verification API is not connected yet.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildShieldIcon(),
                    const SizedBox(height: 22),
                    const Text(
                      'Verify Your Identity',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'We sent a 6-digit verification code to your registered '
                      'cab mobile terminal:',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: AppColors.slate,
                      ),
                    ),
                    const SizedBox(height: 22),
                    _buildIdentityCard(),
                    const SizedBox(height: 26),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CAB TERMINAL PASSCODE',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        Text(
                          'Auto-fill Active',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.slate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildCodeBoxes(),
                    const SizedBox(height: 14),
                    _buildHintOrError(),
                    const SizedBox(height: 20),
                    _buildResendCard(),
                    const SizedBox(height: 20),
                    _buildVerifyButton(),
                    const SizedBox(height: 20),
                    _buildSafetyNotice(),
                    const SizedBox(height: 14),
                    _buildFooter(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Top bar: "Back to Login" on the left, "Help" on the right.
  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            child: const Row(
              children: [
                Icon(Icons.arrow_back, color: AppColors.ink),
                SizedBox(width: 12),
                Text(
                  'Back to Login',
                  style: TextStyle(fontSize: 18, color: AppColors.ink),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showMessage('Help is coming soon.'),
            child: const Row(
              children: [
                Icon(Icons.headset_mic_outlined,
                    size: 22, color: AppColors.slate),
                SizedBox(width: 6),
                Text(
                  'Help',
                  style: TextStyle(fontSize: 16, color: AppColors.slate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Dark square with a white shield and a small green check.
  Widget _buildShieldIcon() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.charcoal,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.security, color: Colors.white, size: 34),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF84CC16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.check, color: Colors.white, size: 14),
          ),
        ),
      ],
    );
  }

  // White card with the masked phone number.
  Widget _buildIdentityCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.terminal, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      widget.maskedPhone,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    // "SMS Dispatched" green pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.lime.withAlpha(60),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.lime),
                      ),
                      child: const Text(
                        'SMS Dispatched',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                if (widget.assignedUnit != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Assigned Unit: ${widget.assignedUnit}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.slate,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // "Change" goes back to the login screen to fix the number.
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Change',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0284C7),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // The 6 boxes for the code.
  Widget _buildCodeBoxes() {
    return Row(
      spacing: 8,
      children: List.generate(6, (index) => Expanded(child: _buildDigitBox(index))),
    );
  }

  Widget _buildDigitBox(int index) {
    final hasDigit = _controllers[index].text.isNotEmpty;

    return TextField(
      controller: _controllers[index],
      focusNode: _focusNodes[index],
      autofocus: index == 0,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // numbers only
        LengthLimitingTextInputFormatter(1), // one digit per box
      ],
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
      // Tapping a box selects its digit, so typing replaces it.
      onTap: () {
        _controllers[index].selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controllers[index].text.length,
        );
      },
      onChanged: (value) => _onDigitChanged(index, value),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        filled: true,
        fillColor: hasDigit ? Colors.white : const Color(0xFFF1F5F9),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasDigit ? AppColors.charcoal : AppColors.border,
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lime, width: 2),
        ),
      ),
    );
  }

  // Shows the red error if there is one, otherwise the gloves hint.
  Widget _buildHintOrError() {
    if (_error != null) {
      return Row(
        children: [
          const Icon(Icons.error_outline, size: 18, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(fontSize: 14, color: AppColors.error),
            ),
          ),
        ],
      );
    }
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.touch_app_outlined, size: 18, color: AppColors.slate),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Tap to modify any earlier digit with work gloves or stylus',
            style: TextStyle(fontSize: 14, color: AppColors.slate),
          ),
        ),
      ],
    );
  }

  // "Didn't receive the SMS code?" card with timer and call button.
  Widget _buildResendCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Didn’t receive the SMS code?',
                  style: TextStyle(fontSize: 16, color: AppColors.ink),
                ),
              ),
              // Timer while counting, "Resend code" when it reaches 0.
              if (_secondsLeft == 0)
                TextButton(
                  onPressed: () => _showMessage('Resend is not connected yet.'),
                  child: const Text('Resend code'),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '00:${_secondsLeft.toString().padLeft(2, '0')}s',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _showMessage('Voice call is coming soon.'),
              icon: const Icon(Icons.phone_in_talk_outlined),
              label: const Text('Call My Cab Phone Instead'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                backgroundColor: const Color(0xFFF8FAFC),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Big green button.
  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 62,
      child: FilledButton(
        onPressed: _verify,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lime,
          foregroundColor: AppColors.charcoal,
          side: const BorderSide(color: Color(0xFF84CC16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                'Verify & Continue to Dispatch',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(width: 12),
            Icon(Icons.arrow_forward),
          ],
        ),
      ),
    );
  }

  // Red safety notice.
  Widget _buildSafetyNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: AppColors.error),
          SizedBox(width: 12),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.4,
                  color: Color(0xFF7F1D1D),
                ),
                children: [
                  TextSpan(
                    text: 'FMCSA Safety Notice: ',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text: 'Never enter OTP credentials while operating a '
                        'commercial motor vehicle. Bring cab to a complete '
                        'stop in a safe staging area.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dispatch phone number at the bottom.
  Widget _buildFooter() {
    return Center(
      child: GestureDetector(
        onTap: () => _showMessage('Calling is coming soon.'),
        child: const Text.rich(
          TextSpan(
            style: TextStyle(fontSize: 14, color: AppColors.slate),
            children: [
              TextSpan(text: 'Terminal Hub CHI-02 Dispatch: '),
              TextSpan(
                text: '(312) 555-0100',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}