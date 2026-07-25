import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_courier/features/auth/presentation/cubit/resend_email_verification_cubit.dart';
import 'package:smart_courier/l10n/app_localizations.dart';

class EmailVerificationBanner extends StatefulWidget {
  const EmailVerificationBanner({required this.onDismiss, super.key});

  final VoidCallback onDismiss;

  @override
  State<EmailVerificationBanner> createState() =>
      _EmailVerificationBannerState();
}

class _EmailVerificationBannerState extends State<EmailVerificationBanner> {
  static const _cooldownDuration = Duration(seconds: 30);

  Timer? _cooldownTimer;
  var _cooldownSeconds = 0;

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _cooldownSeconds = _cooldownDuration.inSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        setState(() => _cooldownSeconds = 0);
        return;
      }
      setState(() => _cooldownSeconds -= 1);
    });
  }

  void _handleResend() {
    if (_cooldownSeconds > 0) {
      return;
    }
    context.read<ResendEmailVerificationCubit>().resend();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<
      ResendEmailVerificationCubit,
      ResendEmailVerificationState
    >(
      listener: (context, state) {
        if (state is ResendEmailVerificationSent) {
          _startCooldown();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(l10n.verificationEmailSent)));
        }
        if (state is ResendEmailVerificationError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is ResendEmailVerificationLoading;
        final canResend = _cooldownSeconds == 0 && !isLoading;
        final resendLabel = _cooldownSeconds > 0
            ? l10n.resendVerificationCooldown(_cooldownSeconds)
            : l10n.resendVerificationEmail;

        return Material(
          color: colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.mark_email_unread_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.verifyEmailBanner,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  key: const Key('email_verification_resend_button'),
                  onPressed: canResend ? _handleResend : null,
                  child: isLoading
                      ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary,
                          ),
                        )
                      : Text(resendLabel),
                ),
                Semantics(
                  label: l10n.dismissEmailVerificationBanner,
                  button: true,
                  child: IconButton(
                    key: const Key('email_verification_dismiss_button'),
                    tooltip: l10n.dismissEmailVerificationBanner,
                    onPressed: widget.onDismiss,
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
