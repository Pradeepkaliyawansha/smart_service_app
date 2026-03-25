import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

const _addonIcons = [
  '📷',
  '🎥',
  '🚁',
  '✏️',
  '🎨',
  '🎤',
  '💡',
  '🔊',
  '🖨️',
  '📦',
  '🚚',
  '⚙️',
  '🌐',
  '📊',
  '🐟',
  '🌿',
];

class AdminAddAddonScreen extends ConsumerStatefulWidget {
  final String serviceId;
  const AdminAddAddonScreen({super.key, required this.serviceId});

  @override
  ConsumerState<AdminAddAddonScreen> createState() =>
      _AdminAddAddonScreenState();
}

class _AdminAddAddonScreenState extends ConsumerState<AdminAddAddonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String _selectedIcon = '⚙️';
  bool _isPopular = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final api = ref.read(apiServiceProvider);
      await api.createAddon({
        'serviceId': widget.serviceId,
        'name': _nameCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'price': double.parse(_priceCtrl.text),
        'icon': _selectedIcon,
        'isPopular': _isPopular,
      });
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add-on created successfully ✅')),
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
                    'New Add-on',
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

                      // Icon picker
                      const Text(
                        'Pick an Icon',
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _addonIcons.map((icon) {
                          final isSelected = _selectedIcon == icon;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedIcon = icon),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primary.withOpacity(0.2)
                                    : AppTheme.cardBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary
                                      : AppTheme.divider,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  icon,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      AppTextField(
                        controller: _nameCtrl,
                        label: 'Add-on name',
                        prefixIcon: Icons.label_outline,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _descCtrl,
                        label: 'Description',
                        prefixIcon: Icons.description_outlined,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      AppTextField(
                        controller: _priceCtrl,
                        label: 'Price (Rs.)',
                        keyboardType: TextInputType.number,
                        prefixIcon: Icons.attach_money_rounded,
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Required';
                          if (double.tryParse(v) == null)
                            return 'Invalid number';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 18)),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mark as Popular',
                                    style: TextStyle(
                                      fontFamily: 'Syne',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Show as "Most Chosen" option',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _isPopular,
                              onChanged: (v) => setState(() => _isPopular = v),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      AppButton(
                        label: 'Create Add-on',
                        isLoading: _isLoading,
                        onPressed: _submit,
                        icon: Icons.add_rounded,
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
