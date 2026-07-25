import 'package:flutter/material.dart';
import 'package:smart_courier/l10n/app_localizations.dart';

class AuthPasswordField extends StatefulWidget {
  const AuthPasswordField({
    required this.controller,
    required this.labelText,
    this.fieldKey,
    this.validator,
    this.autofillHints,
    this.textInputAction,
    this.focusNode,
    this.onFieldSubmitted,
    this.onChanged,
    this.autovalidateMode = AutovalidateMode.disabled,
    super.key,
  });

  final TextEditingController controller;
  final String labelText;
  final Key? fieldKey;
  final FormFieldValidator<String>? validator;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final AutovalidateMode autovalidateMode;

  @override
  State<AuthPasswordField> createState() => AuthPasswordFieldState();
}

class AuthPasswordFieldState extends State<AuthPasswordField> {
  final _formFieldKey = GlobalKey<FormFieldState<String>>();
  var _obscureText = true;

  void validate() {
    _formFieldKey.currentState?.validate();
  }

  void _toggleVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final visibilityLabel = _obscureText
        ? l10n.showPassword
        : l10n.hidePassword;

    return TextFormField(
      key: widget.fieldKey ?? _formFieldKey,
      controller: widget.controller,
      obscureText: _obscureText,
      autofillHints: widget.autofillHints,
      textInputAction: widget.textInputAction,
      focusNode: widget.focusNode,
      autovalidateMode: widget.autovalidateMode,
      onFieldSubmitted: widget.onFieldSubmitted,
      onChanged: widget.onChanged,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.labelText,
        suffixIcon: Semantics(
          label: visibilityLabel,
          button: true,
          child: IconButton(
            tooltip: visibilityLabel,
            onPressed: _toggleVisibility,
            icon: Icon(
              !_obscureText
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
      ),
      validator: widget.validator,
    );
  }
}
