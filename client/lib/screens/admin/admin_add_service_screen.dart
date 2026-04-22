import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../providers/services_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

const _categories = [
  'photography',
  'videography',
  'aquaculture',
  'event',
  'construction',
  'custom',
];

class AdminAddServiceScreen extends ConsumerStatefulWidget {
  const AdminAddServiceScreen({super.key});

  @override
  ConsumerState<AdminAddServiceScreen> createState() =>
      _AdminAddServiceScreenState();
}

class _AdminAddServiceScreenState extends ConsumerState<AdminAddServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _basePriceCtrl = TextEditingController();
  final _perHourCtrl = TextEditingController();
  final _minHoursCtrl = TextEditingController(text: '1');
  final _maxHoursCtrl = TextEditingController(text: '24');
  String _category = 'photography';
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _basePriceCtrl.dispose();
    _perHourCtrl.dispose();
    _minHoursCtrl.dispose();
    _maxHoursCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await ref.read(servicesProvider.notifier).createService({
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'basePrice': double.parse(_basePriceCtrl.text),
        'pricePerHour': double.parse(_perHourCtrl.text),
        'category': _category,
        'minHours': int.parse(_minHoursCtrl.text),
        'maxHours': int.parse(_maxHoursCtrl.text),
        'tags': [_category],
        'isActive': true,
      });
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service created successfully ✅')),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppTheme.textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'New Service',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: AppTheme.error,
                              fontFamily: 'DMSans',
                            ),
                          ),
                        ),

                      AppTextField(
                        controller: _nameCtrl,
                        label: 'Service name',
                        prefixIcon: Icons.label_outline,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _descCtrl,
                        label: 'Description',
                        prefixIcon: Icons.description_outlined,
                        maxLines: 3,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),

                      // Category picker
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _categories.map((cat) {
                          final selected = _category == cat;
                          return GestureDetector(
                            onTap: () => setState(() => _category = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppTheme.primary
                                    : AppTheme.cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? AppTheme.primary
                                      : AppTheme.divider,
                                ),
                              ),
                              child: Text(
                                cat[0].toUpperCase() + cat.substring(1),
                                style: TextStyle(
                                  fontFamily: 'Syne',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppTheme.background
                                      : AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _basePriceCtrl,
                              label: 'Base Price (Rs.)',
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.attach_money_rounded,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                if (double.tryParse(v) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _perHourCtrl,
                              label: 'Per Hour (Rs.)',
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.timer_outlined,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                if (double.tryParse(v) == null) {
                                  return 'Invalid';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: _minHoursCtrl,
                              label: 'Min Hours',
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.hourglass_bottom_rounded,
                              validator: (v) => int.tryParse(v ?? '') == null
                                  ? 'Invalid'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: _maxHoursCtrl,
                              label: 'Max Hours',
                              keyboardType: TextInputType.number,
                              prefixIcon: Icons.hourglass_top_rounded,
                              validator: (v) => int.tryParse(v ?? '') == null
                                  ? 'Invalid'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      AppButton(
                        label: 'Create Service',
                        isLoading: _isLoading,
                        onPressed: _submit,
                        icon: Icons.add_business_rounded,
                      ),
                    ],
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
