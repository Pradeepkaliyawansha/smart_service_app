import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/app_theme.dart';
import '../../providers/services_provider.dart';
import '../../models/service_model.dart';

class AdminServicesScreen extends ConsumerWidget {
  const AdminServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(servicesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Services',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.push('/admin/add-service'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color: AppTheme.background,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Add',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontWeight: FontWeight.w700,
                              color: AppTheme.background,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primary),
                    )
                  : state.services.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🛠️', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 12),
                          const Text(
                            'No services yet',
                            style: TextStyle(
                              fontFamily: 'Syne',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => context.push('/admin/add-service'),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Create First Service'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: state.services.length,
                      itemBuilder: (ctx, i) => FadeInUp(
                        delay: Duration(milliseconds: i * 50),
                        child: _AdminServiceCard(
                          service: state.services[i],
                          onAddAddon: () => context.push(
                            '/admin/add-addon/${state.services[i].id}',
                          ),
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: ctx,
                              builder: (c) => AlertDialog(
                                backgroundColor: AppTheme.cardBg,
                                title: const Text(
                                  'Delete Service?',
                                  style: TextStyle(
                                    fontFamily: 'Syne',
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                content: const Text(
                                  'This action cannot be undone.',
                                  style: TextStyle(
                                    fontFamily: 'DMSans',
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(c, false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(c, true),
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: AppTheme.error),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              ref
                                  .read(servicesProvider.notifier)
                                  .deleteService(state.services[i].id);
                            }
                          },
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onAddAddon;
  final VoidCallback onDelete;

  const _AdminServiceCard({
    required this.service,
    required this.onAddAddon,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(service.categoryIcon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.name,
                      style: const TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      service.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppTheme.error,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _chip('Base: Rs.${service.basePrice.toStringAsFixed(0)}'),
              const SizedBox(width: 8),
              _chip('Rs.${service.pricePerHour.toStringAsFixed(0)}/hr'),
              const SizedBox(width: 8),
              _chip('${service.addons.length} add-ons'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: service.isActive
                      ? AppTheme.success.withOpacity(0.15)
                      : AppTheme.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  service.isActive ? 'ACTIVE' : 'INACTIVE',
                  style: TextStyle(
                    fontFamily: 'Syne',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: service.isActive ? AppTheme.success : AppTheme.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: onAddAddon,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: AppTheme.primary, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Add Add-on',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 11,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
