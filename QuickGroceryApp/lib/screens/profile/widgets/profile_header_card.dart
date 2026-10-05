import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models.dart';

/// Header card displaying customer avatar, name, email, and role with edit action.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.onEditName,
  });

  final CustomerProfile? profile;
  final VoidCallback onEditName;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.paleGreen,
                child: Icon(
                  Icons.person,
                  color: AppColors.emeraldPrimary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile?.name.isEmpty ?? true
                          ? 'Unnamed Customer'
                          : profile!.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      profile?.email ?? '',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Edit name',
                onPressed: onEditName,
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          const Divider(height: 24),
          Text(
            'Role: ${profile?.role ?? "customer"}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ),
  );
}
