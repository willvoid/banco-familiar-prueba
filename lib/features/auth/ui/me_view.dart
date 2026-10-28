import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/user_profile.dart';
import 'me_view_model.dart';

class MeView extends StatelessWidget {
  const MeView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MeViewModel>();
    final profile = viewModel.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('My accounts')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (viewModel.isLoading)
              const Center(child: CircularProgressIndicator()),
            if (viewModel.errorMessage != null)
              Text(
                viewModel.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            if (profile != null) Expanded(child: _ProfileContent(profile)),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: viewModel.isLoading ? null : viewModel.load,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent(this.profile);

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      children: [
        Text(profile.name, style: textTheme.headlineSmall),
        Text('Document: ${profile.document}'),
        const SizedBox(height: 16),
        if (profile.accounts.isEmpty) const Text('No accounts'),
        for (final account in profile.accounts) _AccountCard(account),
      ],
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard(this.account);

  final BankAccount account;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        title: Text('Account ${account.number}'),
        subtitle: Text(
          'Available: ${_formatAmount(account.availableBalance)}\n'
          'Balance: ${_formatAmount(account.balance)}',
        ),
        isThreeLine: true,
        trailing: Text(
          account.status,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: account.isActive ? colors.primary : colors.error,
          ),
        ),
      ),
    );
  }
}

/// Groups thousands with dots: 5000000 -> 5.000.000. The currency is unknown.
String _formatAmount(num value) {
  final fixed = value is int ? value.toString() : value.toStringAsFixed(2);
  final parts = fixed.split('.');
  final integer = parts[0].replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return parts.length > 1 ? '$integer,${parts[1]}' : integer;
}
