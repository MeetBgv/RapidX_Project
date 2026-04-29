import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/dp_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newrapidx/providers/delivery_partner_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:newrapidx/api_constants.dart';

import 'order_notification_overlay.dart';
import 'dp_navigation_page.dart';
import '../Wallet/walletPageDP.dart';
import '../Profile/helpBottomSheetDP.dart';

class HomePageDP extends ConsumerStatefulWidget {
  final VoidCallback? onHistoryTap;
  final VoidCallback? onSettingsTap;
  const HomePageDP({Key? key, this.onHistoryTap, this.onSettingsTap}) : super(key: key);

  @override
  ConsumerState<HomePageDP> createState() => _HomePageDPState();
}

class _HomePageDPState extends ConsumerState<HomePageDP> {
  // ─── Online/Offline ─────────────────────────────────────────────────
  bool _isOnline = false;
  Timer? _pollingTimer;
  Timer? _locationTimer;

  // ─── Active Order ────────────────────────────────────────────────────
  Map<String, dynamic>? _activeOrder;
  bool _isLoadingOrder = false;

  // ─── Pending notification shown ──────────────────────────────────────
  bool _showingNotification = false;
  bool _isAccepting = false; // New flag to prevent duplicate dialogs during acceptance
  bool _isUpdatingStatus = false; // New debouncer for status updates

  // ─── Summary Metrics & Filtering ────────────────────────────────────
  String _selectedTimeframe = '7d'; // Default to 7 days
  int _totalOrders = 0;
  double _totalEarnings = 0.0;
  double _pendingEarnings = 0.0;
  bool _isSummaryLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchActiveOrder(); // Always load any existing active order on open
    _fetchTodaySummary(); // Load real time data
  }

  Future<void> _fetchTodaySummary({bool showLoading = false}) async {
    if (showLoading) setState(() => _isSummaryLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/delivery-partner-orders?timeframe=$_selectedTimeframe&t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (!mounted) return;
      if (res.statusCode == 200) {
        final List<dynamic> orders = json.decode(res.body);
        int total = 0;
        double earnings = 0;
        double pending = 0;
        
        for (var order in orders) {
          try {
            final statusId = int.tryParse(order['delivery_status_id']?.toString() ?? '0') ?? 0;
            final amount = double.tryParse(order['order_amount']?.toString() ?? '0') ?? 0.0;
            
            // Critical: dp_share must be parsed from string safely
            final dpShareRaw = order['dp_share']?.toString();
            final dpShare = (dpShareRaw != null && dpShareRaw != 'null') 
                ? (double.tryParse(dpShareRaw) ?? (amount * 0.8))
                : (amount * 0.8);
            
            if (statusId == 37) { // Delivered
              total++;
              earnings += dpShare;
            } else if (statusId >= 33 && statusId < 37) { // Active/Pending
              pending += dpShare;
            }
          } catch (itemError) {
            debugPrint('Error parsing order summary item: $itemError');
          }
        }
        
        if (mounted) {
          setState(() {
            _totalOrders = total;
            _totalEarnings = earnings;
            _pendingEarnings = pending;
          });
        }
      }
    } catch (e) {
      debugPrint('Fetch summary error: $e');
    } finally {
      if (mounted) setState(() => _isSummaryLoading = false);
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }

  // ─── Online toggle ───────────────────────────────────────────────────
  void _toggleOnline() {
    setState(() => _isOnline = !_isOnline);
    if (_isOnline) {
      _startPolling();
      _startLocationUpdates();
    } else {
      _pollingTimer?.cancel();
      _locationTimer?.cancel();
    }
  }

  // ─── Poll for pending orders ─────────────────────────────────────────
  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted) return;
      _checkForNewOrder();
      _fetchTodaySummary();
    });
    // Also check immediately
    _checkForNewOrder();
  }

  // ─── Location Updates ───────────────────────────────────────────────
  void _startLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!mounted || !_isOnline) return;
      _updateLiveLocation();
    });
    // Initial update
    _updateLiveLocation();
  }

  Future<void> _updateLiveLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/location'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'lat': position.latitude,
          'lng': position.longitude,
        }),
      );
    } catch (e) {
      debugPrint('Location update error: $e');
    }
  }

  String? _notifiedOrderId;

  Future<void> _checkForNewOrder() async {
    if (_activeOrder != null || _isAccepting) return;
    try {
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/orders/pending'),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        final List<dynamic> orders = json.decode(res.body);
        
        // If we are showing a notification, check if that order is still available
        if (_showingNotification && _notifiedOrderId != null) {
          final isStillPending = orders.any((o) => o['order_id'].toString() == _notifiedOrderId);
          if (!isStillPending) {
            debugPrint('Order $_notifiedOrderId taken by someone else! Popping out notification.');
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              _showingNotification = false;
              _notifiedOrderId = null;
            });
          }
          return;
        }

        // Only show new notification if not already showing one
        if (!_showingNotification && orders.isNotEmpty) {
          _showOrderNotification(orders.first as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('Pending orders poll error: $e');
    }
  }

  // ─── Show notification overlay ────────────────────────────────────────
  void _showOrderNotification(Map<String, dynamic> order) {
    if (_showingNotification || !mounted) return;
    
    final orderIdStr = order['order_id'].toString();
    setState(() {
      _showingNotification = true;
      _notifiedOrderId = orderIdStr;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (_) => OrderNotificationOverlay(
        order: order,
        timeoutSeconds: 30,
        onAccept: () {
          Navigator.of(context, rootNavigator: true).pop(); // Correct pop
          setState(() {
            _showingNotification = false;
            _notifiedOrderId = null;
          });
          _acceptOrder(orderIdStr);
        },
        onDecline: () {
          Navigator.of(context, rootNavigator: true).pop(); // Correct pop
          setState(() {
            _showingNotification = false;
            _notifiedOrderId = null;
          });
        },
      ),
    );
  }

  // ─── Accept order ─────────────────────────────────────────────────────
  Future<void> _acceptOrder(String orderId) async {
    if (_isAccepting) return;
    setState(() => _isAccepting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/orders/$orderId/accept'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (!mounted) return;
      
      if (res.statusCode == 200) {
        final accepted = json.decode(res.body) as Map<String, dynamic>;
        setState(() {
          _activeOrder = accepted;
          _isLoadingOrder = false;
        });
        // REFRESH SUMMARY: Important to show updated earnings/counts immediately!
        _fetchTodaySummary(); 
        _showSnack('Order accepted successfully!');
      } else if (res.statusCode == 409) {
        _showSnack('Order already taken by another partner.');
        _fetchActiveOrder(); // Sync state to see if there's any other active order
      } else {
        debugPrint('Accept order failed with code ${res.statusCode}: ${res.body}');
        _showSnack('Failed to accept order. Error: ${res.statusCode}');
      }
    } catch (e) {
      debugPrint('Accept order error: $e');
      _showSnack('Network error while accepting order.');
    } finally {
      if (mounted) {
        setState(() => _isAccepting = false);
      }
    }
  }

  // ─── Fetch current active order ───────────────────────────────────────
  Future<void> _fetchActiveOrder() async {
    setState(() => _isLoadingOrder = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/orders/active'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        final body = res.body;
        if (body != 'null' && body.isNotEmpty) {
          final data = json.decode(body);
          if (data != null) {
            setState(() => _activeOrder = data as Map<String, dynamic>);
            
            // Show recovery toast if it was a cold start (not just a background refresh)
            if (data['delivery_status_id'] != 37) { // If not delivered
              _showSnack('Recovered active delivery session.');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Fetch active order error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingOrder = false);
    }
  }

  // ─── Update order status ──────────────────────────────────────────────
  Future<void> _updateStatus(String statusName) async {
    if (_activeOrder == null || _isUpdatingStatus) return;
    setState(() => _isUpdatingStatus = true);
    
    final orderId = _activeOrder!['order_id'].toString();
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      final res = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/orders/$orderId/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': statusName}),
      );
      if (!mounted) return;
      if (res.statusCode == 200) {
        if (statusName == 'Delivered') {
          setState(() => _activeOrder = null);
          _showSnack('Order delivered! Great job 🎉');
        } else {
          final updated = json.decode(res.body) as Map<String, dynamic>;
          setState(() => _activeOrder = updated);
        }
      }
    } catch (e) {
      debugPrint('Update status error: $e');
    } finally {
      if (mounted) setState(() => _isUpdatingStatus = false);
    }
  }

  void _confirmPickupAndCash(String nextStatusName) {
    if (_activeOrder == null) return;
    final order = _activeOrder!;
    final isOnline = (order['payment_method']?.toString().toLowerCase() ?? 'cash') == 'online';
    final amount = double.tryParse(order['order_amount']?.toString() ?? '0') ?? 0.0;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        title: Row(
          children: [
            Icon(
              isOnline ? Icons.verified_user_rounded : Icons.payments_rounded,
              color: isOnline ? DPColors.successGreen : DPColors.warningOrange,
              size: 26.sp,
            ),
            SizedBox(width: 12.w),
            Text(isOnline ? 'Confirm Pickup' : 'Collect Cash', style: DPTheme.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isOnline 
                ? 'This order is PREPAID.'
                : 'This is a CASH order.',
              style: DPTheme.body.copyWith(
                fontWeight: FontWeight.bold,
                color: isOnline ? DPColors.successGreen : DPColors.warningOrange,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              isOnline 
                ? 'Confirm that you have picked up the parcel from the sender. No cash collection is required.'
                : 'Please collect ₹${amount.toStringAsFixed(0)} from the sender before starting the delivery.',
              style: DPTheme.body.copyWith(color: DPColors.greyDark),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Back', style: TextStyle(color: DPColors.greyMedium)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _updateStatus(nextStatusName);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isOnline ? DPColors.successGreen : DPColors.warningOrange,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
            ),
            child: Text(
              isOnline ? 'Confirm Pickup' : 'Cash Collected', 
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message,
          style: GoogleFonts.baloo2(color: Colors.white)),
      backgroundColor: DPColors.deepBlue,
    ));
  }

  // ─── Navigate to sender ───────────────────────────────────────────────
  Future<void> _navigateToSender() async {
    final order = _activeOrder!;
    final sLat = double.tryParse(order['sender_lat']?.toString() ?? '');
    final sLng = double.tryParse(order['sender_lng']?.toString() ?? '');
    if (sLat == null || sLng == null) {
      _showSnack('Sender coordinates not available for navigation.');
      return;
    }
    // Fetch live location as origin
    LatLng origin;
    try {
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      origin = LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      origin = LatLng(sLat - 0.01, sLng - 0.01);
    }
    if (!mounted) return;
    final rLat = double.tryParse(order['receiver_lat']?.toString() ?? '');
    final rLng = double.tryParse(order['receiver_lng']?.toString() ?? '');
    if (rLat == null || rLng == null) {
       _showSnack('Receiver coordinates not available for navigation.');
       return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DpNavigationPage(
          partnerLocation: origin,
          senderLocation: LatLng(sLat, sLng),
          receiverLocation: LatLng(rLat, rLng),
          senderLabel: '${order['sender_name']}, ${order['sender_city']}',
          receiverLabel: '${order['receiver_name']}, ${order['receiver_city']}',
          isPickupMode: true,
        ),
      ),
    );
  }

  // ─── Navigate to receiver (from sender coords if available) ───────────
  void _navigateToReceiver() {
    final order = _activeOrder!;
    final sLat = double.tryParse(order['sender_lat']?.toString() ?? '');
    final sLng = double.tryParse(order['sender_lng']?.toString() ?? '');
    final rLat = double.tryParse(order['receiver_lat']?.toString() ?? '');
    final rLng = double.tryParse(order['receiver_lng']?.toString() ?? '');
    if (rLat == null || rLng == null) {
      _showSnack('Receiver coordinates not available for navigation.');
      return;
    }
    final origin = (sLat != null && sLng != null)
        ? LatLng(sLat, sLng)
        : LatLng(rLat - 0.01, rLng - 0.01);
    // Get current location for live partner location
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((pos) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DpNavigationPage(
            partnerLocation: LatLng(pos.latitude, pos.longitude),
            senderLocation: (sLat != null && sLng != null) ? LatLng(sLat, sLng) : LatLng(pos.latitude, pos.longitude),
            receiverLocation: LatLng(rLat, rLng),
            senderLabel: order['sender_name'] ?? 'Pickup',
            receiverLabel: order['receiver_name'] ?? 'Drop-off',
            isPickupMode: false,
          ),
        ),
      );
    }).catchError((_) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DpNavigationPage(
            partnerLocation: origin, // Using the already calculated origin
            senderLocation: (sLat != null && sLng != null) ? LatLng(sLat, sLng) : origin,
            receiverLocation: LatLng(rLat, rLng),
            senderLabel: order['sender_name'] ?? 'Pickup',
            receiverLabel: order['receiver_name'] ?? 'Drop-off',
            isPickupMode: false,
          ),
        ),
      );
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DPColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchActiveOrder,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader().animate().fade(duration: 400.ms).slideY(
                    begin: -0.1, end: 0, duration: 400.ms),

                SizedBox(height: 24.h),
                _buildTodaySummary().animate().fade(
                    duration: 400.ms, delay: 100.ms),
                SizedBox(height: 20.h),
                Text(
                  'Active Order',
                  style: DPTheme.h2.copyWith(
                      fontSize: 18.sp, fontWeight: FontWeight.w700),
                ).animate().fade(duration: 400.ms, delay: 200.ms),
                SizedBox(height: 16.h),
                _buildActiveOrderSection()
                    .animate()
                    .fade(duration: 400.ms, delay: 300.ms)
                    .slideY(begin: 0.1, end: 0, duration: 400.ms),
                SizedBox(height: 32.h),
                _buildQuickActionRow()
                    .animate()
                    .fade(duration: 400.ms, delay: 400.ms),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final dpState = ref.watch(deliveryPartnerProvider);
    final displayName =
        dpState.name.isNotEmpty ? dpState.name : 'Delivery Partner';
    final displayVehicle = dpState.vehicleNumber.isNotEmpty
        ? dpState.vehicleNumber
        : dpState.vehicleType.isNotEmpty
            ? dpState.vehicleType
            : 'Two Wheeler';

    return Row(
      children: [
        Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DPColors.greyExtraLight,
            image: dpState.profilePicturePath.isNotEmpty
                ? DecorationImage(
                    image: FileImage(File(dpState.profilePicturePath)),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: dpState.profilePicturePath.isEmpty
              ? Icon(
                  Icons.person,
                  size: 28.sp,
                  color: DPColors.greyMedium,
                )
              : null,
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayName, style: DPTheme.h3.copyWith(fontSize: 18.sp)),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(Icons.two_wheeler,
                      size: 16.sp, color: DPColors.greyMedium),
                  SizedBox(width: 6.w),
                  Text(displayVehicle,
                      style: DPTheme.bodySmall.copyWith(fontSize: 13.sp)),
                ],
              ),
            ],
          ),
        ),
        InkWell(
          onTap: _toggleOnline,
          borderRadius: BorderRadius.circular(30.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: _isOnline
                  ? DPColors.successGreen
                  : DPColors.DropRed.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(
                color:
                    _isOnline ? DPColors.successGreen : DPColors.transparent,
                width: 1,
              ),
              boxShadow: _isOnline
                  ? [
                      BoxShadow(
                        color: DPColors.successGreen.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(
                    color: _isOnline ? Colors.white : DPColors.greyMedium,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: _isOnline ? Colors.white : DPColors.greyDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  String _getTimeframeLabel() {
    switch (_selectedTimeframe) {
      case '7d': return '7 Days';
      case '1m': return 'Month';
      case '1y': return 'Year';
      default: return 'Lifetime';
    }
  }

  Widget _buildTodaySummary() {
    if (_isSummaryLoading) {
      return SizedBox(
        height: 70.h,
        child: const Center(child: CircularProgressIndicator(color: DPColors.deepBlue)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_getTimeframeLabel()} Summary',
              style: DPTheme.bodySmall.copyWith(color: DPColors.greyMedium, fontWeight: FontWeight.w600),
            ),
            Icon(Icons.query_stats_rounded, size: 14.sp, color: DPColors.greyMedium),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(child: _summaryCard('Earnings', '₹ ${_totalEarnings.toStringAsFixed(0)}', Icons.account_balance_wallet_outlined, DPColors.deepBlue)),
            SizedBox(width: 16.w),
            Expanded(child: _summaryCard('Orders', '$_totalOrders', Icons.check_circle_outline, DPColors.teal)),
          ],
        ),
      ],
    );
  }

  Widget _summaryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: DPColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border:
            Border.all(color: DPColors.greyLight.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE0E0E0).withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 12.h),
          Text(value,
              style: DPTheme.h2.copyWith(
                  fontSize: 18.sp,
                  color: DPColors.black,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Text(title,
              style: DPTheme.bodySmall.copyWith(
                  fontSize: 11.sp, color: DPColors.greyMedium)),
        ],
      ),
    );
  }

  Widget _buildActiveOrderSection() {
    if (_isLoadingOrder) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activeOrder == null) {
      return _buildNoActiveOrder();
    }

    return _buildActiveOrderCard();
  }

  Widget _buildNoActiveOrder() {
    return Container(
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: DPColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_rounded,
              size: 48.sp, color: DPColors.greyLight),
          SizedBox(height: 12.h),
          Text('No active order',
              style: DPTheme.h3.copyWith(
                  color: DPColors.greyDark, fontSize: 15.sp)),
          SizedBox(height: 6.h),
          Text(
            _isOnline
                ? 'Waiting for new orders…'
                : 'Go online to receive orders',
            style: DPTheme.bodySmall.copyWith(color: DPColors.greyMedium),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderCard() {
    final order = _activeOrder!;
    final statusId = order['delivery_status_id'] as int? ?? 33;

    // Map status_id → step (for stepper display)
    // 33=Assigned, 34=Picked Up, 35=In Transit, 37=Delivered
    int currentStep;
    String nextStatusName;
    String nextStatusLabel;
    if (statusId == 33) {
      currentStep = 0;
      nextStatusName = 'Picked Up';
      nextStatusLabel = 'Mark Picked Up';
    } else if (statusId == 34) {
      currentStep = 1;
      nextStatusName = 'In Transit';
      nextStatusLabel = 'Start Delivery';
    } else if (statusId == 35) {
      currentStep = 2;
      nextStatusName = 'Delivered';
      nextStatusLabel = 'Mark Delivered';
    } else {
      currentStep = 3;
      nextStatusName = '';
      nextStatusLabel = 'Completed';
    }

    final isCompleted = statusId == 37;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: DPColors.deepBlue.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.inventory_2_outlined,
                          size: 18.sp, color: DPColors.deepBlue),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order['order_id'].toString().substring(0, 6)}',
                          style: DPTheme.h3.copyWith(fontSize: 14.sp),
                        ),
                        Text(order['urgency'] ?? 'Normal',
                            style: DPTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: (order['payment_method']?.toString().toLowerCase() == 'online')
                        ? DPColors.successGreen.withOpacity(0.12)
                        : DPColors.warningOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Text(
                         '₹${(double.tryParse(order['order_amount']?.toString() ?? '0') ?? 0.0).toStringAsFixed(0)}',
                         style: TextStyle(
                           color: (order['payment_method']?.toString().toLowerCase() == 'online')
                               ? DPColors.successGreen
                               : DPColors.warningOrange,
                           fontWeight: FontWeight.bold,
                           fontSize: 14.sp,
                         ),
                       ),
                       SizedBox(height: 2.h),
                        Text(
                          (order['payment_method']?.toString().toLowerCase() == 'online') ? 'PREPAID' : 'CASH',
                          style: TextStyle(
                             color: (order['payment_method']?.toString().toLowerCase() == 'online') ? DPColors.successGreen : DPColors.warningOrange,
                             fontSize: 9.sp, 
                             fontWeight: FontWeight.w900,
                             letterSpacing: 0.8,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Divider(color: DPColors.greyExtraLight, thickness: 1),
                SizedBox(height: 16.h),

                // Pickup
                _buildLocationRow(
                  isPickup: true,
                  name: order['sender_name'] ?? '',
                  address:
                      '${order['sender_address'] ?? ''}, ${order['sender_city'] ?? ''}',
                  onNavigate: _navigateToSender,
                ),
                Container(
                  margin: EdgeInsets.only(left: 11.w),
                  height: 28.h,
                  width: 2.w,
                  color: DPColors.greyLight.withOpacity(0.5),
                ),
                // Drop
                _buildLocationRow(
                  isPickup: false,
                  name: order['receiver_name'] ?? '',
                  address:
                      '${order['receiver_address'] ?? ''}, ${order['receiver_city'] ?? ''}',
                  onNavigate: _navigateToReceiver,
                ),

                SizedBox(height: 24.h),

                // Status stepper
                _buildStatusStepper(currentStep),

                SizedBox(height: 24.h),

                // Action button
                if (!isCompleted)
                  SizedBox(
                    width: double.infinity,
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (statusId == 33) {
                          _confirmPickupAndCash(nextStatusName);
                        } else {
                          _updateStatus(nextStatusName);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DPColors.deepBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        nextStatusLabel,
                        style: DPTheme.buttonText.copyWith(fontSize: 16.sp),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Order Delivered!',
                          style: GoogleFonts.baloo2(
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required bool isPickup,
    required String name,
    required String address,
    required VoidCallback onNavigate,
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
              width: 6.w,
            ),
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPickup ? 'PICKUP' : 'DROP',
                style: GoogleFonts.inter(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: DPColors.greyMedium,
                    letterSpacing: 1.0),
              ),
              SizedBox(height: 2.h),
              Text(name,
                  style: DPTheme.h3.copyWith(fontSize: 15.sp)),
              SizedBox(height: 2.h),
              Text(
                address,
                style: DPTheme.body.copyWith(
                    color: DPColors.greyDark, height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  _actionButton(
                      Icons.near_me_outlined, 'Navigate', onNavigate),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionButton(
      IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: DPColors.background,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: DPColors.deepBlue),
            SizedBox(width: 8.w),
            Text(
              label,
              style: DPTheme.bodySmall.copyWith(
                color: DPColors.deepBlue,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStepper(int currentStep) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Row(
        children: [
          _stepItem(0, 'Assigned', currentStep),
          _line(0, currentStep),
          _stepItem(1, 'Picked', currentStep),
          _line(1, currentStep),
          _stepItem(2, 'Transit', currentStep),
          _line(2, currentStep),
          _stepItem(3, 'Delivered', currentStep),
        ],
      ),
    );
  }

  Widget _stepItem(int index, String label, int currentStep) {
    final passed = currentStep >= index;
    final active = currentStep == index;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 20.w,
          height: 20.w,
          decoration: BoxDecoration(
            color: passed ? DPColors.successGreen : DPColors.greyLight,
            shape: BoxShape.circle,
            border: active
                ? Border.all(
                    color: DPColors.deepBlue.withOpacity(0.3),
                    width: 4)
                : null,
          ),
          child: passed
              ? Icon(Icons.check, size: 12.sp, color: Colors.white)
              : null,
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: passed ? DPColors.black : DPColors.greyMedium,
            fontWeight:
                passed ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _line(int index, int currentStep) {
    return Expanded(
      child: Container(
        height: 2.h,
        margin: EdgeInsets.only(bottom: 20.h),
        color: currentStep > index
            ? DPColors.successGreen
            : DPColors.greyLight.withOpacity(0.5),
      ),
    );
  }

  Widget _buildQuickActionRow() {
    final items = [
      (_quickActionItem(
          Icons.history_rounded, 'History', widget.onHistoryTap ?? () {})),
      (_quickActionItem(Icons.headset_mic_outlined, 'Support', () {
         showHelpSupportBottomSheetDP(context);
      })),
      (_quickActionItem(
          Icons.account_balance_wallet_outlined, 'Wallet', () {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => const WalletPageDP()),
             );
          })),
      (_quickActionItem(Icons.settings_outlined, 'Settings', widget.onSettingsTap ?? () {})),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items,
    );
  }

  Widget _quickActionItem(
      IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: DPColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    offset: const Offset(0, 4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child:
                  Icon(icon, color: DPColors.deepBlue, size: 22.sp),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: DPTheme.bodySmall.copyWith(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
