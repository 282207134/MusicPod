import '../l10n/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/catalog.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) => GestureDetector(
      onTap: () => AppScope.of(context).go(AppScreen.signup),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: bounds.maxHeight * .12,
            left: (bounds.maxWidth - 790) / 2,
            width: 790,
            height: bounds.maxHeight * .7,
            child: Image.asset('assets/images/art-77.png', fit: BoxFit.cover),
          ),
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              width: 162,
              height: 302,
            ),
          ),
        ],
      ),
    ),
  );
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key, this.otp = false});
  final bool otp;
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final field = TextEditingController();
  String? error;
  @override
  void dispose() {
    field.dispose();
    super.dispose();
  }

  void submit() {
    final c = AppScope.of(context);
    final valid = widget.otp
        ? field.text == '1234'
        : RegExp(r'^\d{7,15}$').hasMatch(field.text);
    if (!valid) {
      setState(
        () => error = widget.otp
            ? 'Enter the demo PIN: 1234'
            : 'Enter a valid phone number (7–15 digits).',
      );
      return;
    }
    if (widget.otp) {
      c.finishSignup();
    } else {
      c.phone = field.text;
      c.go(AppScreen.otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = AppScope.of(context);
    return LayoutBuilder(
      builder: (context, bounds) => Stack(
        children: [
          Positioned(
            left: -295,
            bottom: -295,
            width: 590,
            height: 590,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .035),
              ),
              child: Padding(
                padding: const EdgeInsets.all(110),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: .035),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(95),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: .035),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(46, bounds.maxHeight * .23, 46, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: context.tr('Signup on ')),
                      TextSpan(
                        text: 'MUSIC POD',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  style: TextStyle(fontSize: 27),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.otp
                      ? context.tr(
                          'Thanks. Please enter the 4 digit verification PIN sent to {phone}',
                          {'phone': c.phone.isEmpty ? '8493856738' : c.phone},
                        )
                      : context.tr(
                          'Enjoy HD Music Streaming & Podcast with Offline playback',
                        ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: muted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 58),
                TextField(
                  key: ValueKey(widget.otp ? 'otp-field' : 'phone-field'),
                  controller: field,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(widget.otp ? 4 : 15),
                  ],
                  obscureText: widget.otp,
                  obscuringCharacter: '●',
                  onSubmitted: (_) => submit(),
                  decoration: InputDecoration(
                    hintText: context.tr(
                      widget.otp
                          ? 'Enter verification PIN'
                          : 'Enter phone number',
                    ),
                    hintStyle: const TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                    errorText: error == null ? null : context.tr(error!),
                  ),
                ),
                const SizedBox(height: 55),
                GradientButton(
                  widget.otp ? 'Verify PIN' : 'Send Verification PIN',
                  onTap: submit,
                ),
                if (widget.otp) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        context.tr('Didn’t get Pin?'),
                        style: TextStyle(fontSize: 14, color: muted),
                      ),
                      TextButton(
                        onPressed: () =>
                            message(context, 'Demo verification PIN: 1234'),
                        child: Text(
                          context.tr('Send Again'),
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  Center(
                    child: Text(
                      context.tr('Demo PIN: 1234'),
                      style: TextStyle(fontSize: 12, color: muted),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 25, left: 18),
              child: IconButton(
                tooltip: context.tr('App language'),
                icon: const Icon(Icons.language),
                onPressed: () => c.go(AppScreen.language),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 25, right: 18),
              child: TextButton(
                onPressed: c.finishSignup,
                child: Text(
                  context.tr('Skip'),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
