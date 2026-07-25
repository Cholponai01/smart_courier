import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_courier/features/auth/domain/entities/user.dart';
import 'package:smart_courier/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:smart_courier/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.user, super.key});

  final User user;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l10n.profileTitle, style: textTheme.headlineSmall),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(
              l10n.signedInAs(user.email),
              style: textTheme.bodyLarge,
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          key: const Key('profile_logout_button'),
          onPressed: () {
            context.read<AuthBloc>().add(const LogoutRequested());
          },
          icon: const Icon(Icons.logout),
          label: Text(l10n.logout),
        ),
      ],
    );
  }
}
