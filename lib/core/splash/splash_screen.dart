import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_courier/core/theme/colors.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_courier/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const authCheckTimeout = Duration(seconds: 8);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timeoutTimer;
  var _timedOut = false;

  @override
  void initState() {
    super.initState();
    _startTimeoutTimer();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  void _startTimeoutTimer() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(SplashScreen.authCheckTimeout, () {
      if (!mounted) {
        return;
      }
      final state = context.read<AuthBloc>().state;
      if (state is AuthInitial || state is AuthChecking) {
        setState(() => _timedOut = true);
      }
    });
  }

  void _retry() {
    setState(() => _timedOut = false);
    _startTimeoutTimer();
    context.read<AuthBloc>().add(const AuthCheckRequested());
  }

  void _onAuthStateChanged(AuthState state) {
    if (state is! AuthInitial && state is! AuthChecking) {
      _timeoutTimer?.cancel();
      if (_timedOut) {
        setState(() => _timedOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _onAuthStateChanged(state),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: _timedOut
              ? _ConnectionFallback(
                  title: l10n.splashConnectionIssueTitle,
                  message: l10n.splashConnectionIssueMessage,
                  retryLabel: l10n.retry,
                  onRetry: _retry,
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/splash/logo.png',
                        width: 96,
                        height: 96,
                      ),
                      const SizedBox(height: 24),
                      Text(l10n.appTitle, style: textTheme.headlineSmall),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _ConnectionFallback extends StatelessWidget {
  const _ConnectionFallback({
    required this.title,
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String title;
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_outlined, size: 56, color: colorScheme.error),
          const SizedBox(height: 24),
          Text(
            title,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton(
            key: const Key('splash_retry_button'),
            onPressed: onRetry,
            child: Text(retryLabel),
          ),
        ],
      ),
    );
  }
}
