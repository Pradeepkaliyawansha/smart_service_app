import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../../config/app_theme.dart';
import '../../models/service_model.dart';
import '../../models/addon_model.dart';
import '../../models/price_calculation_model.dart';
import '../../providers/package_builder_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';

class PackageSummaryScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> bookingData;

  const PackageSummaryScreen({super.key, required this.bookingData});

  @override
  ConsumerState<PackageSummaryScreen> createState() =>
      _PackageSummaryScreenState();
}

class _PackageSummaryScreenState extends ConsumerState<PackageSummaryScreen> {
  final _notesCtrl = TextEditingController();
  DateTime? _eventDate;

  late ServiceModel _service;
  late List<AddonModel> _addons;
  late int _duration;
  late PriceCalculation _pricing;

  @override
  void initState() {
    super.initState();
    _service = widget.bookingData['service'] as ServiceModel;
    _addons = widget.bookingData['selectedAddons'] as List<AddonModel>;
    _duration = widget.bookingData['durationHours'] as int;
    _pricing = widget.bookingData['pricing'] as PriceCalculation;
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppTheme.primary,
            surface: AppTheme.cardBg,
            onSurface: AppTheme.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (date != null) setState(() => _eventDate = date);
  }

  Future<void> _submitBooking() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final data = {
      'userId': user.id,
      'serviceId': _service.id,
      'serviceName': _service.name,
      'selectedAddonIds': _addons.map((a) => a.id).toList(),
      'selectedAddonNames': _addons.map((a) => a.name).toList(),
      'durationHours': _duration,
      'basePrice': _pricing.basePrice + _pricing.durationCost,
      'addonsTotal': _pricing.addonsCost,
      'discountAmount': _pricing.discountAmount,
      'totalPrice': _pricing.totalPrice,
      'packageName': '${_service.name} Package',
      'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      'eventDate': _eventDate?.toIso8601String(),
    };

    final success = await ref
        .read(bookingSubmitProvider.notifier)
        .submitBooking(data);

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.cardBg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const Text('🎉', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 16),
              const Text(
                'Booking Submitted!',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your booking request has been sent. We\'ll confirm shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    context.go('/my-bookings');
                  },
                  child: const Text('View My Bookings'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingSubmitProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header ──────────────────────────────────────────────────────
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
                    'Booking Summary',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Service Info ──────────────────────────────────────
                    FadeInDown(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primary.withOpacity(0.15),
                              AppTheme.primary.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _service.categoryIcon,
                              style: const TextStyle(fontSize: 36),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _service.name,
                                    style: const TextStyle(
                                      fontFamily: 'Syne',
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_duration hours · ${_addons.length} add-on(s)',
                                    style: const TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Selected Add-ons ──────────────────────────────────
                    if (_addons.isNotEmpty) ...[
                      const Text(
                        'Selected Add-ons',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _addons
                            .map(
                              (a) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 7,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.cardBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppTheme.divider),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      a.icon,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      a.name,
                                      style: const TextStyle(
                                        fontFamily: 'DMSans',
                                        fontSize: 13,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ─── Event Date ────────────────────────────────────────
                    const Text(
                      'Event Date (optional)',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _eventDate != null
                                ? AppTheme.primary
                                : AppTheme.divider,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              color: AppTheme.primary,
                              size: 18,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _eventDate != null
                                  ? '${_eventDate!.day}/${_eventDate!.month}/${_eventDate!.year}'
                                  : 'Select event date',
                              style: TextStyle(
                                fontFamily: 'DMSans',
                                fontSize: 14,
                                color: _eventDate != null
                                    ? AppTheme.textPrimary
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Notes ─────────────────────────────────────────────
                    const Text(
                      'Notes (optional)',
                      style: TextStyle(
                        fontFamily: 'Syne',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontFamily: 'DMSans',
                      ),
                      decoration: InputDecoration(
                        hintText: 'Any special requirements...',
                        hintStyle: const TextStyle(color: AppTheme.textMuted),
                        filled: true,
                        fillColor: AppTheme.cardBg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ─── Price Summary ─────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Column(
                        children: [
                          _priceRow(
                            'Service base',
                            'Rs. ${_pricing.basePrice.toStringAsFixed(0)}',
                          ),
                          _priceRow(
                            'Duration (${_duration}h)',
                            'Rs. ${_pricing.durationCost.toStringAsFixed(0)}',
                          ),
                          if (_addons.isNotEmpty)
                            _priceRow(
                              'Add-ons (${_addons.length})',
                              'Rs. ${_pricing.addonsCost.toStringAsFixed(0)}',
                            ),
                          if (_pricing.hasDiscount) ...[
                            const Divider(color: AppTheme.divider, height: 20),
                            _priceRow(
                              'Subtotal',
                              'Rs. ${_pricing.subtotal.toStringAsFixed(0)}',
                            ),
                            _priceRow(
                              '${((_pricing.discountRate) * 100).toInt()}% discount',
                              '- Rs. ${_pricing.discountAmount.toStringAsFixed(0)}',
                              valueColor: AppTheme.success,
                            ),
                          ],
                          const Divider(color: AppTheme.divider, height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontFamily: 'Syne',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Rs. ${_pricing.totalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontFamily: 'Syne',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (bookingState.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          bookingState.error!,
                          style: const TextStyle(
                            color: AppTheme.error,
                            fontFamily: 'DMSans',
                          ),
                        ),
                      ),

                    AppButton(
                      label: 'Confirm Booking',
                      isLoading: bookingState.isLoading,
                      onPressed: _submitBooking,
                      icon: Icons.check_circle_outline_rounded,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'DMSans',
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'DMSans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
