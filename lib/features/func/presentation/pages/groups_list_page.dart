import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:resq/core/theme/app_theme.dart';
import 'package:resq/features/auth/presentation/providers/auth_provider.dart';
import 'package:resq/features/func/domain/entities/group.dart';
import 'package:resq/features/func/presentation/providers/group_provider.dart';
import 'package:resq/features/func/presentation/widgets/appbar.dart';

class GroupsListPage extends ConsumerWidget {
  const GroupsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupState = ref.watch(groupProvider);
    final authState = ref.watch(authStateProvider);
    final currentUserId = authState.user?.id;
    
    // Filter groups to only show groups where current user is a member
    final userGroups = currentUserId != null
        ? groupState.groups.where((group) => group.memberIds.contains(currentUserId)).toList()
        : <Group>[];

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppbarWidget(
        title: 'My Groups',
        icon: Icons.close,
        onTap: () => context.go('/chatsetting'),
      ),
      body: groupState.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primary,
              ),
            )
          : userGroups.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primary.withOpacity(0.1),
                                AppTheme.secendory.withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.group_outlined,
                            size: 80,
                            color: AppTheme.primary.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'No groups yet',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Create a group to start chatting with friends',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: userGroups.length,
                  itemBuilder: (context, index) {
                    final group = userGroups[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.borderLight,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.secendory],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.group_rounded,
                            color: AppTheme.white,
                            size: 32,
                          ),
                        ),
                        title: Text(
                          group.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              '${group.memberIds.length} members',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            if (group.description != null && group.description!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  group.description!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: AppTheme.textSecondary,
                        ),
                        onTap: () {
                          context.go('/group/${group.id}');
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

