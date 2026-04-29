import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/dp_theme.dart';

/// Full-screen incoming-order popup shown over the DP home screen.
/// Auto-dismisses after [timeoutSeconds] seconds if not responded to.
class OrderNotificationOverlay extends StatefulWidget {
  final Map<String, dynamic> order;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final int timeoutSeconds;

  const OrderNotificationOverlay({
    super.key,
    required this.order,
    required this.onAccept,
    required this.onDecline,
    this.timeoutSeconds = 30,
  });

  @override
  State<OrderNotificationOverlay> createState() =>
      _OrderNotificationOverlayState();
}

class _OrderNotificationOverlayState
    extends State<OrderNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late int _remaining;
  Timer? _countdownTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _remaining = widget.timeoutSeconds;

    // Pulse animation for the bell icon
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.15).animate(_pulseController);

    // Countdown
    _countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _remaining--);
        if (_remaining <= 0) {
          timer.cancel();
          widget.onDecline(); // Auto-decline when timer expires
        }
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final senderName = order['sender_name'] ?? 'Unknown';
    final senderAddress = order['sender_address'] ?? '';
    final senderCity = order['sender_city'] ?? '';
    final receiverName = order['receiver_name'] ?? 'Unknown';
    final receiverAddress = order['receiver_address'] ?? '';
    final receiverCity = order['receiver_city'] ?? '';
    final amount = order['order_amount'];
    final orderId = order['order_id']?.toString() ?? '';

    return Material(
      color: Colors.black.withValues(alpha: 0.65),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: DPColors.deepBlue.withValues(alpha: 0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 12),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Header ───────────────────────────────────
                  Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: DPColors.deepBlue,
                      borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28.r)),
                    ),
                    child: Row(
                      children: [
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.notifications_active_rounded,
                              color: Colors.white,
                              size: 24.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New Order!',
                                style: GoogleFonts.baloo2(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Order #${orderId.length > 6 ? orderId.substring(0, 6) : orderId}',
                                style: GoogleFonts.baloo2(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Countdown ring
                        _CountdownRing(remaining: _remaining, total: widget.timeoutSeconds),
                      ],
                    ),
                  ),

                  // ─── Body ─────────────────────────────────────
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Earnings
                        if (amount != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: (order['payment_method']?.toString().toLowerCase() == 'online')
                                      ? DPColors.successGreen.withOpacity(0.1)
                                      : DPColors.warningOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  (order['payment_method']?.toString().toLowerCase() == 'online')
                                      ? 'Prepaid'
                                      : 'Collect: ₹${(double.tryParse(amount.toString()) ?? 0.0).toStringAsFixed(0)}',
                                  style: GoogleFonts.baloo2(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: (order['payment_method']?.toString().toLowerCase() == 'online')
                                        ? DPColors.successGreen
                                        : DPColors.warningOrange,
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: DPColors.successGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Text(
                                  'Earn: ₹${(double.tryParse(order['dp_share']?.toString() ?? '') ?? ((double.tryParse(amount.toString()) ?? 0.0) * 0.8)).toStringAsFixed(0)}',
                                  style: GoogleFonts.baloo2(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: DPColors.successGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        SizedBox(height: 20.h),

                        // Pickup
                        _locationRow(
                          isPickup: true,
                          name: senderName,
                          address: '$senderAddress, $senderCity',
                        ),

                        Padding(
                          padding: EdgeInsets.only(left: 11.w),
                          child: Container(
                            height: 28.h,
                            width: 2.w,
                            color: DPColors.greyLight,
                          ),
                        ),

                        // Drop
                        _locationRow(
                          isPickup: false,
                          name: receiverName,
                          address: '$receiverAddress, $receiverCity',
                        ),

                        SizedBox(height: 24.h),

                        // Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: widget.onDecline,
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  side: BorderSide(
                                      color: DPColors.DropRed, width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                child: Text(
                                  'Decline',
                                  style: GoogleFonts.baloo2(
                                    color: DPColors.DropRed,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: widget.onAccept,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: DPColors.deepBlue,
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                child: Text(
                                  'Accept Order',
                                  style: GoogleFonts.baloo2(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _locationRow({
    required bool isPickup,
    required String name,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24.w,
          height: 24.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isPickup ? DPColors.PickUpGreen : DPColors.DropRed,
              width: 5.w,
            ),
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPickup ? 'PICKUP' : 'DROP',
                style: GoogleFonts.baloo2(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                  color: DPColors.greyMedium,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                name,
                style: GoogleFonts.baloo2(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: DPColors.black,
                ),
              ),
              if (address.trim() != ',' && address.trim().isNotEmpty)
                Text(
                  address,
                  style: GoogleFonts.baloo2(
                    fontSize: 12.sp,
                    color: DPColors.greyDark,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small circular countdown indicator
class _CountdownRing extends StatelessWidget {
  final int remaining;
  final int total;

  const _CountdownRing({required this.remaining, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = remaining / total;
    return SizedBox(
      width: 44.w,
      height: 44.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.4 ? Colors.white : Colors.orangeAccent,
            ),
          ),
          Text(
            '$remaining',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
