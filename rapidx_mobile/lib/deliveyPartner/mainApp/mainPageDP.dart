import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newrapidx/api_constants.dart';
import 'package:newrapidx/providers/delivery_partner_riverpod.dart';

import 'Home/homepageDP.dart';
import 'Orders/ordersPageDP.dart';
import 'Wallet/walletPageDP.dart';
import 'Profile/profilePageDP.dart';

class mainPageDP extends ConsumerStatefulWidget {
  @override
  ConsumerState<mainPageDP> createState() => _mainPageDPState();
}

class _mainPageDPState extends ConsumerState<mainPageDP> {
  int _currentIndex = 0;
  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      HomePageDP(
        onHistoryTap: () => setState(() => _currentIndex = 1),
        onSettingsTap: () => setState(() => _currentIndex = 3),
      ),
      const OrdersPage(),
      const WalletPageDP(),
      const ProfilePageDP(),
    ]);
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      
      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/delivery-partners/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200 && mounted) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        ref.read(deliveryPartnerProvider.notifier).setAllData(data);
      }
    } catch (e) {
      debugPrint('Failed to fetch DP profile in mainPageDP: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: const Color(0xFF0F4C75), // DPColors.deepBlue
        unselectedItemColor: Colors.grey, // 👈 normal item color
        backgroundColor: Colors.white, // 👈 bar background
        type: BottomNavigationBarType.fixed, // To prevent shifting items
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: 'Wallet'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
