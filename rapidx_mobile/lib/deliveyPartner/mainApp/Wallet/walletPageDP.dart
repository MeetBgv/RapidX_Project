import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../theme/dp_theme.dart';
import 'package:newrapidx/api_constants.dart';
import 'package:intl/intl.dart';

class WalletPageDP extends StatefulWidget {
  const WalletPageDP({Key? key}) : super(key: key);

  @override
  _WalletPageDPState createState() => _WalletPageDPState();
}

class _WalletPageDPState extends State<WalletPageDP> {
  bool _isLoading = true;
  double _cashInHand = 0.0;
  double _unpaidOnline = 0.0;
  double _lifetimeEarnings = 0.0;
  List<dynamic> _history = [];
  Timer? _pollingTimer;
  String _selectedTimeframe = 'all'; // all, 7d, 1m, 1y

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        debugPrint('[Wallet] Syncing real-time payout data...');
        _fetchWalletData(showLoading: false);
      }
    });
  }

  Future<void> _fetchWalletData({bool showLoading = true}) async {
    if (showLoading) setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';

      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/delivery-partner/wallet?timeframe=$_selectedTimeframe&t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200 && mounted) {
        final data = json.decode(res.body);
        final stats = data['stats'];
        setState(() {
          if (stats != null) {
            _cashInHand = double.tryParse(stats['cash_in_hand']?.toString() ?? '0') ?? 0.0;
            _unpaidOnline = double.tryParse(stats['unpaid_online_earnings']?.toString() ?? '0') ?? 0.0;
            _lifetimeEarnings = double.tryParse(stats['lifetime_earnings']?.toString() ?? '0') ?? 0.0;
          } else {
            _cashInHand = 0.0;
            _unpaidOnline = 0.0;
            _lifetimeEarnings = 0.0;
          }
          _history = data['history'] ?? [];
        });
      } else {
        debugPrint('Wallet API Error: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      debugPrint('Error fetching wallet: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showHandoverDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Handover Cash to Admin', style: DPTheme.h3),
        content: Text(
          'Please visit the hub and handover ₹${_cashInHand.toStringAsFixed(0)} to the admin. '
          'Once the admin confirms receipt, this balance will be cleared and your earnings will be updated.',
          style: DPTheme.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Understood', style: TextStyle(color: DPColors.deepBlue, fontWeight: FontWeight.bold)),
          ),
        ],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DPColors.background,
      appBar: AppBar(
        title: Text('Financial Wallet', style: DPTheme.h2.copyWith(color: DPColors.white)),
        backgroundColor: DPColors.deepBlue,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white, size: 20.sp),
            onPressed: () => _fetchWalletData(),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: DPColors.deepBlue))
          : RefreshIndicator(
              onRefresh: _fetchWalletData,
              color: DPColors.deepBlue,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [


                    // Main Stats Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildSmallStatCard(
                            _selectedTimeframe == 'all' ? 'Lifetime Earnings' : 'Earnings (${_getTimeframeLabel()})',
                            '₹${_lifetimeEarnings.toStringAsFixed(0)}',
                            Icons.trending_up,
                            DPColors.successGreen,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Cash in Hand Card
                    _buildBalanceCard(
                      title: 'Cash In Hand (Offline)',
                      amount: _cashInHand,
                      subtitle: 'Collected cash to deposit with Admin',
                      icon: Icons.payments_outlined,
                      color: DPColors.warningOrange,
                      actionBtn: _cashInHand > 0
                          ? GestureDetector(
                              onTap: _showHandoverDialog,
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: DPColors.warningOrange.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.info_outline, color: DPColors.warningOrange, size: 20.sp),
                              ),
                            )
                          : null,
                    ),
                    SizedBox(height: 16.h),

                    // Pending Card
                    _buildBalanceCard(
                      title: 'Awaiting Settlement',
                      amount: _unpaidOnline,
                      subtitle: 'Earnings to be transferred by Admin',
                      icon: Icons.account_balance_outlined,
                      color: DPColors.deepBlue,
                      isPending: true,
                    ),
                    SizedBox(height: 32.h),
                    
                        Row(
                          children: [
                            Text('Recent Activity', style: DPTheme.h2.copyWith(fontSize: 16.sp)),
                            SizedBox(width: 8.w),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedTimeframe,
                                icon: Icon(Icons.keyboard_arrow_down_rounded, color: DPColors.greyMedium, size: 18.sp),
                                style: DPTheme.bodySmall.copyWith(color: DPColors.deepBlue, fontWeight: FontWeight.bold, fontSize: 12.sp),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() => _selectedTimeframe = newValue);
                                    _fetchWalletData();
                                  }
                                },
                                items: [
                                  DropdownMenuItem(value: '7d', child: Text('7 Days')),
                                  DropdownMenuItem(value: '1m', child: Text('Month')),
                                  DropdownMenuItem(value: '1y', child: Text('Year')),
                                  DropdownMenuItem(value: 'all', child: Text('Total')),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_history.isNotEmpty)
                          Text('All Stats', style: DPTheme.bodySmall.copyWith(color: DPColors.greyMedium, fontSize: 10.sp)),

                    SizedBox(height: 12.h),
                    
                    if (_history.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _history.length,
                        separatorBuilder: (c, i) => SizedBox(height: 12.h),
                        itemBuilder: (c, i) {
                          final item = _history[i];
                          return _buildHistoryItem(item);
                        },
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getTimeframeLabel() {
    switch (_selectedTimeframe) {
      case '7d': return 'Last 7 Days';
      case '1m': return 'Last Month';
      case '1y': return 'Last Year';
      default: return 'Lifetime';
    }
  }


  Widget _buildSmallStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16.sp),
              SizedBox(width: 8.w),
              Text(title, style: DPTheme.bodySmall.copyWith(color: DPColors.greyMedium, fontSize: 11.sp)),
            ],
          ),
          SizedBox(height: 8.h),
          Text(value, style: DPTheme.h2.copyWith(color: DPColors.deepBlue, fontSize: 18.sp)),
        ],
      ),
    );
  }

  Widget _buildBalanceCard({
    required String title,
    required double amount,
    required String subtitle,
    required IconData icon,
    required Color color,
    Widget? actionBtn,
    bool isPending = false,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: DPTheme.h3.copyWith(fontSize: 13.sp, color: DPColors.greyMedium)),
                SizedBox(height: 4.h),
                Text('₹${amount.toStringAsFixed(0)}', style: DPTheme.h2.copyWith(fontSize: 22.sp, color: color)),
                SizedBox(height: 4.h),
                Text(subtitle, style: DPTheme.bodySmall.copyWith(fontSize: 10.sp, letterSpacing: 0)),
              ],
            ),
          ),
          if (actionBtn != null) actionBtn,
        ],
      ),
    );
  }

  Widget _buildHistoryItem(dynamic item) {
    final status = item['status'];
    final isCash = item['payment_method'] == 'cash';
    final amount = double.tryParse(item['dp_share']?.toString() ?? '0') ?? 0.0;
    final date = DateTime.tryParse(item['created_at'].toString()) ?? DateTime.now();

    String statusText = 'Unknown';
    Color statusColor = DPColors.greyMedium;
    IconData statusIcon = Icons.help_outline;

    if (status == 'paid') {
      statusText = 'Settled';
      statusColor = DPColors.successGreen;
      statusIcon = Icons.check_circle_outline;
    } else if (status == 'cash_pending') {
      statusText = 'Awaiting Deposit';
      statusColor = DPColors.warningOrange;
      statusIcon = Icons.hourglass_empty;
    } else if (status == 'awaiting_payout') {
      statusText = 'Processing...';
      statusColor = DPColors.deepBlue;
      statusIcon = Icons.sync;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: DPColors.greyExtraLight.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(isCash ? Icons.money : Icons.credit_card, color: statusColor, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Order #${item['order_id'].toString().length > 7 ? item['order_id'].toString().substring(0, 7) : item['order_id']}', style: DPTheme.h3.copyWith(fontSize: 13.sp)),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 2.h,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(!isCash ? 'Online' : 'Cash', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: !isCash ? const Color(0xFF0369A1) : const Color(0xFFD97706))),
                    Text(DateFormat('dd MMM, hh:mm a').format(date), style: TextStyle(fontSize: 10.sp, color: DPColors.greyMedium)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹${amount.toStringAsFixed(0)}', style: DPTheme.h3.copyWith(fontSize: 15.sp, color: DPColors.black)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 10.sp, color: statusColor),
                  SizedBox(width: 4.w),
                  Text(statusText, style: TextStyle(fontSize: 10.sp, color: statusColor, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      child: Column(
        children: [
          Icon(Icons.history, size: 48.sp, color: DPColors.greyExtraLight),
          SizedBox(height: 12.h),
          Text('No recent transactions found', style: DPTheme.bodySmall.copyWith(color: DPColors.greyMedium)),
        ],
      ),
    );
  }
}
