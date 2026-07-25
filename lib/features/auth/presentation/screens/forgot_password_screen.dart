import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_courier/core/di/injection.dart';
import 'package:smart_courier/core/router/app_routes.dart';
import 'package:smart_courier/features/auth/presentation/cubit/forgot_password_cubit.dart';
import 'package:smart_courier/features/auth/presentation/validators/auth_validators.dart';
import 'package:smart_courier/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:smart_courier/l10n/app_localizations.dart';
import 'package:smart_courier/widgets/loading_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _emailFocusNode = FocusNode();
  var _resetLinkSent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _resetLinkSent &&
        mounted &&
        context.mounted) {
      context.go(AppRoutes.loginAfterPasswordReset());
    }
  }

  void _submit(ForgotPasswordCubit cubit) {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    cubit.submit(email: _emailController.text.trim());
  }

  void _markResetLinkSent() {
    if (_resetLinkSent) {
      return;
    }
    setState(() => _resetLinkSent = true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => sl<ForgotPasswordCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.forgotPasswordTitle, style: textTheme.titleMedium),
        ),
        body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
          listener: (context, state) {
            if (state is ForgotPasswordSubmitted) {
              _markResetLinkSent();
            }
            if (state is ForgotPasswordError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is ForgotPasswordSubmitted) {
              return _PasswordResetSentView(
                onBackToSignIn: () => context.go(AppRoutes.login),
              );
            }

            final cubit = context.read<ForgotPasswordCubit>();
            final isLoading = state is ForgotPasswordLoading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.forgotPasswordDescription,
                      style: textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    AuthFormField(
                      fieldKey: const Key('forgot_password_email_field'),
                      controller: _emailController,
                      focusNode: _emailFocusNode,
                      labelText: l10n.email,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(cubit),
                      validator: (value) => AuthValidators.validateEmail(
                        value,
                        requiredMessage: l10n.emailRequired,
                        invalidMessage: l10n.invalidEmailFormat,
                      ),
                    ),
                    const SizedBox(height: 24),
                    LoadingButton(
                      buttonKey: const Key('forgot_password_submit_button'),
                      label: l10n.sendResetLink,
                      isLoading: isLoading,
                      onPressed: () => _submit(cubit),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PasswordResetSentView extends StatelessWidget {
  const _PasswordResetSentView({required this.onBackToSignIn});

  final VoidCallback onBackToSignIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.mark_email_read_outlined,
            size: 56,
            color: colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.passwordResetCheckEmailTitle,
            style: textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.passwordResetSent,
            style: textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.passwordResetNextSteps,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          FilledButton(
            key: const Key('forgot_password_back_to_sign_in_button'),
            onPressed: onBackToSignIn,
            child: Text(l10n.backToSignIn),
          ),
        ],
      ),
    );
  }
}
