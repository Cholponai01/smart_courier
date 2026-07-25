import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_courier/features/auth/presentation/validators/auth_validators.dart';
import 'package:smart_courier/features/auth/presentation/widgets/auth_form_field.dart';
import 'package:smart_courier/features/auth/presentation/widgets/auth_password_field.dart';
import 'package:smart_courier/l10n/app_localizations.dart';
import 'package:smart_courier/widgets/loading_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();
  final _confirmPasswordFieldKey = GlobalKey<AuthPasswordFieldState>();
  PhoneNumber? _phone;
  var _phoneE164 = '';
  var _validateConfirmOnSubmit = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_revalidateConfirmPassword);
  }

  @override
  void dispose() {
    _passwordController.removeListener(_revalidateConfirmPassword);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _revalidateConfirmPassword() {
    _confirmPasswordFieldKey.currentState?.validate();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;

    setState(() => _validateConfirmOnSubmit = true);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final phoneError = AuthValidators.validateIntlPhoneStrict(
      _phone,
      requiredMessage: l10n.phoneRequired,
      invalidMessage: l10n.phoneInvalid,
    );
    if (phoneError != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(phoneError)));
      return;
    }

    context.read<AuthBloc>().add(
      RegisterRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneE164,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createAccount, style: textTheme.titleMedium),
      ),
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
                    fieldKey: const Key('register_name_field'),
                    controller: _nameController,
                    focusNode: _nameFocusNode,
                    labelText: l10n.name,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_phoneFocusNode),
                    validator: (value) => AuthValidators.validateRequired(
                      value,
                      l10n.nameRequired,
                    ),
                  ),
                  const SizedBox(height: 16),
                  IntlPhoneField(
                    key: const Key('register_phone_field'),
                    focusNode: _phoneFocusNode,
                    decoration: InputDecoration(labelText: l10n.phone),
                    textInputAction: TextInputAction.next,
                    onChanged: (phone) {
                      _phone = phone;
                      try {
                        _phoneE164 = phone.completeNumber;
                      } catch (_) {
                        _phoneE164 = '';
                      }
                    },
                    onSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(_emailFocusNode),
                    validator: (phone) =>
                        AuthValidators.validateIntlPhoneLenient(
                          phone,
                          requiredMessage: l10n.phoneRequired,
                        ),
                  ),
                  const SizedBox(height: 16),
                  AuthFormField(
                    fieldKey: const Key('register_email_field'),
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
                    fieldKey: const Key('register_password_field'),
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    labelText: l10n.password,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => FocusScope.of(
                      context,
                    ).requestFocus(_confirmPasswordFocusNode),
                    validator: (value) =>
                        AuthValidators.validateRegisterPassword(
                          value,
                          requiredMessage: l10n.passwordRequired,
                          weakMessage: l10n.weakPassword,
                        ),
                  ),
                  const SizedBox(height: 16),
                  AuthPasswordField(
                    key: _confirmPasswordFieldKey,
                    fieldKey: const Key('register_confirm_password_field'),
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocusNode,
                    labelText: l10n.confirmPassword,
                    autofillHints: const [AutofillHints.newPassword],
                    textInputAction: TextInputAction.done,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    onChanged: (_) => _revalidateConfirmPassword(),
                    onFieldSubmitted: (_) => _submit(),
                    validator: (value) {
                      final mismatch =
                          AuthValidators.validateConfirmPasswordLive(
                            value,
                            password: _passwordController.text,
                            mismatchMessage: l10n.passwordsDoNotMatch,
                          );
                      if (mismatch != null) {
                        return mismatch;
                      }
                      if (_validateConfirmOnSubmit) {
                        return AuthValidators.validateConfirmPassword(
                          value,
                          password: _passwordController.text,
                          requiredMessage: l10n.confirmPasswordRequired,
                          mismatchMessage: l10n.passwordsDoNotMatch,
                        );
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  LoadingButton(
                    buttonKey: const Key('register_submit_button'),
                    label: l10n.register,
                    isLoading: isLoading,
                    onPressed: _submit,
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
