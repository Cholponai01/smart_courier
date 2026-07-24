import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_courier/l10n/app_localizations.dart';
import 'package:smart_courier/widgets/app_text_field.dart';
import 'package:smart_courier/widgets/loading_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    context.read<AuthBloc>().add(
      RegisterRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
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
                  AppTextField(
                    fieldKey: const Key('register_name_field'),
                    controller: _nameController,
                    labelText: l10n.name,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) =>
                        AppTextField.validateRequired(value, l10n.nameRequired),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    fieldKey: const Key('register_phone_field'),
                    controller: _phoneController,
                    labelText: l10n.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) => AppTextField.validateRequired(
                      value,
                      l10n.phoneRequired,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    fieldKey: const Key('register_email_field'),
                    controller: _emailController,
                    labelText: l10n.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => AppTextField.validateRequired(
                      value,
                      l10n.emailRequired,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    fieldKey: const Key('register_password_field'),
                    controller: _passwordController,
                    labelText: l10n.password,
                    obscureText: true,
                    validator: (value) => AppTextField.validateRequired(
                      value,
                      l10n.passwordRequired,
                    ),
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
