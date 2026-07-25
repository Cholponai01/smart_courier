import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_courier/core/router/app_routes.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_courier/features/auth/presentation/validators/auth_validators.dart';
import 'package:smart_courier/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:smart_courier/features/auth/presentation/widgets/auth_password_field.dart';
import 'package:smart_courier/l10n/app_localizations.dart';
import 'package:smart_courier/widgets/loading_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  var _passwordResetHintShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _maybeShowPasswordResetHint(),
    );
  }

  void _maybeShowPasswordResetHint() {
    if (_passwordResetHintShown || !mounted) {
      return;
    }

    final router = GoRouter.maybeOf(context);
    if (router == null) {
      return;
    }

    final queryParams = router.state.uri.queryParameters;
    if (queryParams[AppRoutes.passwordResetQueryParam] != '1') {
      return;
    }

    _passwordResetHintShown = true;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.signInWithNewPassword)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      LoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.signIn, style: textTheme.titleMedium)),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthFormField(
                    fieldKey: const Key('login_email_field'),
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    labelText: l10n.email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_passwordFocusNode),
                    validator: (value) => AuthValidators.validateEmail(
                      value,
                      requiredMessage: l10n.emailRequired,
                      invalidMessage: l10n.invalidEmailFormat,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AuthPasswordField(
                    fieldKey: const Key('login_password_field'),
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    labelText: l10n.password,
                    autofillHints: const [AutofillHints.password],
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) => AuthValidators.validateRequired(
                      value,
                      l10n.passwordRequired,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      key: const Key('login_forgot_password_link'),
                      onPressed: isLoading
                          ? null
                          : () => context.push(AppRoutes.forgotPassword),
                      child: Text(
                        l10n.forgotPassword,
                        style: textTheme.bodyLarge,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LoadingButton(
                    buttonKey: const Key('login_submit_button'),
                    label: l10n.login,
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    key: const Key('login_register_link'),
                    onPressed: isLoading
                        ? null
                        : () => context.push(AppRoutes.register),
                    child: Text(
                      l10n.createAnAccount,
                      style: textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
