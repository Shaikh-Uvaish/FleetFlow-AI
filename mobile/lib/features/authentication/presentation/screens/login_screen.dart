import 'package:flutter/material.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import 'otp_verification_screen.dart';

/// Driver Sign In screen (matches the Stitch design).
///
/// TODO(api): replace the debug sign-in in [_submit] with a LoginCubit once the
/// login endpoint is confirmed with the backend.
/// TODO(nav): wire Forgot PIN, SMS code and Badge/QR once those screens exist.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _pinController = TextEditingController();

  bool _obscurePin = true;
  bool _rememberDevice = true;
  bool _identifierValid = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // ---------- validation ----------

  String? _validateIdentifier(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Enter your phone number or email';
    if (v.contains('@')) {
      return _emailRegex.hasMatch(v) ? null : 'Enter a valid email address';
    }
    final digits = v.replaceAll(RegExp(r'[\s\-().+]'), '');
    return RegExp(r'^\d{10,15}$').hasMatch(digits)
        ? null
        : 'Enter a valid phone number';
  }

  String? _validatePin(String? value) {
    if (value == null || value.isEmpty) return 'Enter your PIN or password';
    if (value.length < 4) return 'Must be at least 4 characters';
    return null;
  }

  // ---------- actions ----------

  void _submit() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    // TODO(api): call the login API (LoginCubit) once the endpoint is confirmed.
    _showMessage('Details look good. Sign-in API is not connected yet.');
  }

  void _comingSoon(String feature) => _showMessage('$feature is coming soon.');

  
  void _startSmsSignIn() {
    final value = _identifierController.text.trim();
    final isPhone =
        value.isNotEmpty &&
        !value.contains('@') &&
        _validateIdentifier(value) == null;

    if (!isPhone) {
      _showMessage(
        'Enter your registered phone number above to get an SMS code.',
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OtpVerificationScreen(
          maskedPhone: maskPhoneNumber(value),
          // TODO(api): comes from the backend. Demo value so the screen matches the design.
          assignedUnit: 'Driver Ray Morales (#DRV-904)',
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _Header(onSupportTap: () => _comingSoon('Support chat')),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 20),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: _VersionBadge(),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Driver Sign In',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Enter your registered commercial phone number or '
                            'driver email to access your active loads and ELD '
                            'dispatch.',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.5,
                              color: AppColors.slate,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _buildForm(),
                          const SizedBox(height: 20),
                          _buildSignInButton(),
                          const SizedBox(height: 28),
                          const _OrDivider(),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _QuickSignInButton(
                                  icon: Icons.sms_outlined,
                                  label: 'One-Time SMS Code',
                                  onTap: _startSmsSignIn,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _QuickSignInButton(
                                  icon: Icons.qr_code_scanner_rounded,
                                  label: 'Terminal Badge / QR',
                                  onTap: () =>
                                      _comingSoon('Badge / QR sign-in'),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const SizedBox(height: 24),
                          _HelpCard(onTap: () => _comingSoon('Dispatch call')),
                          const SizedBox(height: 16),
                          const _ComplianceFooter(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Driver Phone Number or Email'),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _identifierController,
            validator: _validateIdentifier,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            autocorrect: false,
            onChanged: (value) {
              final valid = _validateIdentifier(value) == null;
              if (valid != _identifierValid) {
                setState(() => _identifierValid = valid);
              }
            },
            style: const TextStyle(fontSize: 18, color: AppColors.ink),
            decoration: InputDecoration(
              hintText: '+1 (555) 000-0000',
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
              prefixIcon: const Icon(
                Icons.badge_outlined,
                color: AppColors.slate,
              ),
              suffixIcon: _identifierValid
                  ? const Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.success,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          const _FieldLabel('Driver Security PIN / Password'),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: _pinController,
            validator: _validatePin,
            obscureText: _obscurePin,
            obscuringCharacter: '•',
            enableSuggestions: false,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _submit(),
            style: const TextStyle(fontSize: 18, color: AppColors.ink),
            decoration: InputDecoration(
              hintText: 'Enter PIN or password',
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.slate,
              ),
              suffixIcon: IconButton(
                tooltip: _obscurePin ? 'Show PIN' : 'Hide PIN',
                icon: Icon(
                  _obscurePin
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppColors.slate,
                ),
                onPressed: () => setState(() => _obscurePin = !_obscurePin),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _rememberDevice,
                  onChanged: (v) =>
                      setState(() => _rememberDevice = v ?? false),
                  activeColor: AppColors.lime,
                  checkColor: AppColors.charcoal,
                  side: const BorderSide(color: AppColors.charcoal, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () =>
                      setState(() => _rememberDevice = !_rememberDevice),
                  child: const Text(
                    'Remember this cab device',
                    style: TextStyle(fontSize: 15, color: AppColors.ink),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _comingSoon('Forgot PIN'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 36),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Forgot PIN?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.slate,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      height: 62,
      child: FilledButton(
        onPressed: _submit,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.lime,
          foregroundColor: AppColors.charcoal,
          elevation: 0,
          side: const BorderSide(color: Color(0xFF84CC16)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radius),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Sign In to Cab Console',
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
            ),
            SizedBox(width: 12),
            Icon(Icons.arrow_forward_rounded, size: 24),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Private widgets. When the OTP and Forgot Password screens are built, move
// _Header, _HelpCard and _ComplianceFooter into core/widgets so they can be
// reused.
// =============================================================================

class _Header extends StatelessWidget {
  const _Header({required this.onSupportTap});

  final VoidCallback onSupportTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.offWhite,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.charcoal,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              color: AppColors.lime,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FleetFlow AI',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: AppColors.ink,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'DRIVER CAB COMPANION',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: AppColors.slate,
                  ),
                ),
              ],
            ),
          ),
          Tooltip(
            message: 'Contact support',
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              ),
              child: InkWell(
                customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                onTap: onSupportTap,
                child: const SizedBox(
                  width: 52,
                  height: 52,
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: AppColors.charcoal,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VersionBadge extends StatelessWidget {
  const _VersionBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.lime.withAlpha(60),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lime.withAlpha(160)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'CAB CONSOLE v4.8',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: AppColors.charcoal,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        // The line takes two parts of the width, the text takes one part.
        Expanded(flex: 2, child: Divider(height: 1, color: AppColors.border)),
        SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: Text(
            'OR QUICK SIGN IN WITH',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: AppColors.slate,
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickSignInButton extends StatelessWidget {
  const _QuickSignInButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.radius);
    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 68),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.charcoal, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.radiusLg);
    return Material(
      color: Colors.white,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_in_talk_outlined,
                  color: AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need cab assistance or locked out?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.4,
                          color: AppColors.slate,
                        ),
                        children: [
                          TextSpan(text: 'Call Dispatch Command at '),
                          TextSpan(
                            text: '1-800-555-FLEET',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(text: ' or tap for 24/7 Roadside.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComplianceFooter extends StatelessWidget {
  const _ComplianceFooter();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.verified_user_outlined, size: 18, color: AppColors.success),
        SizedBox(width: 8),
        Flexible(
          child: Text(
            'FMCSA Certified Electronic Logging Device (ELD) & HOS Compliant',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppColors.slate),
          ),
        ),
      ],
    );
  }
}
