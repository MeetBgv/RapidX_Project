import 'dart:async';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:newrapidx/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:dotlottie_loader/dotlottie_loader.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:flutter/services.dart';
import '../../../services/location_service.dart';
import '../ordersApp/ordesApp.dart';
import '../profileApp/profileApp.dart';
import '../ordersApp/UI/placeOrderBottomSheet.dart';
import 'walletPage.dart';
import '../profileApp/helpBottomSheet.dart';

class homeApp extends StatefulWidget {
  const homeApp({super.key});

  @override
  State<homeApp> createState() => _homeAppState();
}

class _homeAppState extends State<homeApp> {
  int currentIndex = 0;
  int ordersInitialIndex = 0;
  final GlobalKey<ordersAppState> _ordersKey = GlobalKey<ordersAppState>();

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      HomeContent(onNavigate: _navigateToTab),
      ordersApp(key: _ordersKey, initialIndex: ordersInitialIndex),
      profileApp(),
    ];
    _checkActiveOrdersOnStartup();
  }

  Future<void> _checkActiveOrdersOnStartup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token') ?? '';
      if (token.isEmpty) return;

      final res = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/customer-orders?t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = json.decode(res.body);
        bool hasActiveOrder = data.any((item) => item['is_complete'] != true);
        
        if (hasActiveOrder && mounted) {
          // Switch to orders tab automatically
          _navigateToTab(1, 0);
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recovered active order session.'),
              backgroundColor: Color(0xff56A3A6),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error checking active orders on startup: $e");
    }
  }

  void _navigateToTab(int tabIndex, int subTabIndex) {
    setState(() {
      currentIndex = tabIndex;
      if (tabIndex == 1) {
        ordersInitialIndex = subTabIndex;
        _ordersKey.currentState?.setTab(subTabIndex);
      }
    });
  }

  Future<bool> _showExitDialog() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: Text(
              "Quit Application",
              style: GoogleFonts.baloo2(
                fontWeight: FontWeight.bold,
                color: const Color(0xff234C6A),
              ),
            ),
            content: Text(
              "Do you want to quit the application?",
              style: GoogleFonts.baloo2(color: Colors.grey.shade700),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  "No",
                  style: GoogleFonts.baloo2(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => SystemNavigator.pop(),
                child: Text(
                  "Yes",
                  style: GoogleFonts.baloo2(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitDialog();
        if (shouldPop && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        body: IndexedStack(index: currentIndex, children: pages),
        bottomNavigationBar: BottomAppBar(
          color: const Color(0xffF2F2F2),
          child: SizedBox(
            height: 60.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Home
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = 0;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.home_outlined,
                        color: currentIndex == 0
                            ? const Color(0xffDE9325)
                            : Colors.grey,
                      ),
                      Text(
                        "Home",
                        style: GoogleFonts.baloo2(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: currentIndex == 0
                              ? const Color(0xffDE9325)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Orders
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = 1;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delivery_dining_outlined,
                        color: currentIndex == 1
                            ? const Color(0xffDE9325)
                            : Colors.grey,
                      ),
                      Text(
                        "Orders",
                        style: GoogleFonts.baloo2(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: currentIndex == 1
                              ? const Color(0xffDE9325)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // Profile
                GestureDetector(
                  onTap: () {
                    setState(() {
                      currentIndex = 2;
                    });
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_2_outlined,
                        color: currentIndex == 2
                            ? const Color(0xffDE9325)
                            : Colors.grey,
                      ),
                      Text(
                        "Profile",
                        style: GoogleFonts.baloo2(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: currentIndex == 2
                              ? const Color(0xffDE9325)
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- HOME CONTENT ----------------

class HomeContent extends StatefulWidget {
  final Function(int tabIndex, int subTabIndex)? onNavigate;
  const HomeContent({super.key, this.onNavigate});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with TickerProviderStateMixin {
  late final AnimationController _lottieController1;
  late final AnimationController _lottieController2;
  late final AnimationController _lottieController3;

  final PageController _pageController = PageController(viewportFraction: 1.0);
  Timer? _autoSlideTimer;
  int _currentPage = 0;
  static const int _cardCount = 3;
  String _currentAddress = "Fetching location...";

  @override
  void initState() {
    super.initState();
    _lottieController1 = AnimationController(vsync: this);
    _lottieController2 = AnimationController(vsync: this);
    _lottieController3 = AnimationController(vsync: this);

    _startAutoSlide();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    try {
      final pos = await LocationService.getCurrentLocation();
      final res = await LocationService.reverseGeocode(
        pos.latitude,
        pos.longitude,
      );
      if (mounted) {
        setState(() {
          _currentAddress = "${res['displayName']}";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentAddress = "Unable to detect location";
        });
      }
    }
  }

  void _startAutoSlide() {
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    _lottieController1.dispose();
    _lottieController2.dispose();
    _lottieController3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Total height calculation:
    // AppBar(60) + TopGap(20) + Slider(140) + Gap(5) + Dots(6) + Gap(5) = 236
    final double headerHeight = 236.h;

    return SafeArea(
      child: Stack(
        children: [
          // ── Layer 1: Fixed Lottie Slider & Dots (Background) ──
          Positioned(
            top: 60.h, // Starts below the App Bar
            left: 0.w,
            right: 0.w,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20.h),
                SizedBox(
                  height: 140.h,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final actualIndex = index % _cardCount;
                      final cards = [
                        _buildLottieCard(
                          text1: "Packed with Care.",
                          text2: "Delivered with Trust.",
                          text3:
                              "We focus on quality packing to prevent damage.",
                          lottieUrl:
                              "https://lottie.host/b219fdbe-48d3-49b3-b46a-907a5b07c35f/yevNIK7FcZ.lottie",
                          controller: _lottieController1,
                          animationOnRight: true,
                        ),
                        _buildLottieCard(
                          text1: "From Door to Door,",
                          text2: "No Detours.",
                          text3:
                              "We avoid delays by following the most direct delivery path..",
                          lottieUrl:
                              "https://lottie.host/a512f615-4632-4011-a409-812e443b34db/9vcXZtWLBv.lottie",
                          controller: _lottieController2,
                          animationOnRight: true,
                          durationMultiplier: 0.8,
                        ),
                        _buildLottieCard(
                          text1: "Straight to You,",
                          text2: "Less to Pay.",
                          text3:
                              "We deliver directly to you so you don’t have to pay extra.",
                          lottieUrl:
                              "https://lottie.host/63468a02-2fbd-4be5-8078-873f7e734835/du18MnL4wW.lottie",
                          controller: _lottieController3,
                          animationOnRight: true,
                          durationMultiplier: 0.8,
                        ),
                      ];
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6.w),
                        child: cards[actualIndex],
                      );
                    },
                  ),
                ),
                SizedBox(height: 5.h),
                // Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_cardCount, (index) {
                    final isActive = (_currentPage % _cardCount) == index;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      width: isActive ? 16.w : 6.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.grey.shade600
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // ── Layer 2: Scrollable Content (Grey Container) ──
          SingleChildScrollView(
            child: Column(
              children: [
                // Transparent spacer to push the grey container down initially
                // and reveal the fixed slider behind it.
                SizedBox(height: headerHeight),

                // ── Glassmorphic Container ──
                Stack(
                  children: [
                    // Shadow Caster: Short container to limit shadow to the top area

                    // Container(
                    //   height: 10.h
                    //       .h, // Reduced height to limit the shadow to the top area only
                    //   width: double.infinity,
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadius.only(
                    //       topLeft: Radius.circular(20.r),
                    //       topRight: Radius.circular(20.r),
                    //     ),
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Color(0x26000000),
                    //         blurRadius: 8.r,
                    //         offset: Offset(0, -9),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Doodle Content(main container )
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.r),
                          topRight: Radius.circular(20.r),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.r),
                                topRight: Radius.circular(20.r),
                              ),
                              child: Opacity(
                                opacity: 0.1,
                                child: Image.asset(
                                  "assets/images/homeDoodle.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 24.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildGreetingSection()
                                    .animate()
                                    .fade(duration: 500.ms)
                                    .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      duration: 500.ms,
                                    ),
                                SizedBox(height: 20.h),
                                _buildLocationCard()
                                    .animate()
                                    .fade(duration: 500.ms, delay: 100.ms)
                                    .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      duration: 500.ms,
                                      delay: 100.ms,
                                    ),
                                SizedBox(height: 24.h),
                                _buildQuickActions()
                                    .animate()
                                    .fade(duration: 500.ms, delay: 200.ms)
                                    .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      duration: 500.ms,
                                      delay: 200.ms,
                                    ),
                                SizedBox(height: 24.h),
                                _buildServicesSection()
                                    .animate()
                                    .fade(duration: 500.ms, delay: 300.ms)
                                    .slideY(
                                      begin: 0.2,
                                      end: 0,
                                      duration: 500.ms,
                                      delay: 300.ms,
                                    ),
                                SizedBox(height: 24.h),
                                _buildPromoBanner()
                                    .animate()
                                    .fade(duration: 500.ms, delay: 400.ms)
                                    .scale(
                                      begin: const Offset(0.9, 0.9),
                                      delay: 400.ms,
                                    ),
                                SizedBox(
                                  height: 40.h,
                                ), // Bottom padding for scroll
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Layer 3: Fixed App Bar ──
          Positioned(
            top: 0.h,
            left: 0.w,
            right: 0.w,
            child: Container(
              height: 60.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 8.r,
                    offset: Offset(0, 9),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    height: 40.h,
                    child: Image.asset("assets/images/rapidXlogo.png"),
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      SizedBox(height: 15.h),
                      Padding(
                        padding: EdgeInsets.only(right: 10.w),
                        child: Text(
                          "",
                          style: GoogleFonts.baloo2(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xffDE9325),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: EdgeInsets.only(right: 10.w),
                      //   child: Row(
                      //     children: [
                      //       Icon(Icons.location_on, size: 10.sp),
                      //       Text(
                      //         "Current location",
                      //         style: GoogleFonts.baloo2(
                      //           fontSize: 10.sp,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLottieCard({
    required String text1,
    required String text2,
    required String text3,
    required String lottieUrl,
    required AnimationController controller,
    required bool animationOnRight,
    double durationMultiplier = 1.2,
  }) {
    final textWidget = Expanded(
      child: Column(
        crossAxisAlignment: animationOnRight
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text1,
            style: GoogleFonts.baloo2(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.3.h,
            ),
          ),
          Text(
            text2,
            style: GoogleFonts.baloo2(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              height: 1.3.h,
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            text3,
            style: GoogleFonts.baloo2(
              fontSize: 10.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
              height: 1.2.h,
            ),
          ),
        ],
      ),
    );

    final animationWidget = SizedBox(
      width: 90.w,
      height: 90.h,
      child: DotLottieLoader.fromNetwork(
        lottieUrl,
        frameBuilder: (BuildContext context, DotLottie? dotlottie) {
          if (dotlottie != null && dotlottie.animations.entries.isNotEmpty) {
            return Lottie.memory(
              dotlottie.animations.entries.first.value,
              controller: controller,
              frameRate: FrameRate.composition,
              onLoaded: (composition) {
                controller
                  ..duration = Duration(
                    milliseconds:
                        (composition.duration.inMilliseconds *
                                durationMultiplier)
                            .round(),
                  )
                  ..repeat();
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: animationOnRight
            ? [textWidget, SizedBox(width: 12.w), animationWidget]
            : [animationWidget, SizedBox(width: 12.w), textWidget],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  void _showOrderBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const PlaceOrderContent(),
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hey, ${_getGreeting()}! 👋",
          style: GoogleFonts.baloo2(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xff234C6A),
          ),
        ),
        Text(
          "Where would you like to send today?",
          style: GoogleFonts.baloo2(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {
        'icon': Icons.local_shipping_outlined,
        'label': 'Send Parcel',
        'color': const Color(0xff56A3A6),
      },
      {
        'icon': Icons.history_outlined,
        'label': 'History',
        'color': const Color(0xffDE9325),
      },
      {
        'icon': Icons.account_balance_wallet_outlined,
        'label': 'Wallet',
        'color': const Color(0xff234C6A),
      },
      {
        'icon': Icons.support_agent_outlined,
        'label': 'Support',
        'color': Colors.redAccent,
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions.map((action) {
        return Column(
          children: [
            InkWell(
              onTap: () {
                if (action['label'] == 'Send Parcel') {
                  _showOrderBottomSheet();
                } else if (action['label'] == 'History') {
                  widget.onNavigate?.call(1, 1);
                } else if (action['label'] == 'Wallet') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WalletPage()),
                  );
                } else if (action['label'] == 'Support') {
                  showHelpSupportBottomSheet(context);
                }
              },
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: (action['color'] as Color).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  action['icon'] as IconData,
                  color: action['color'] as Color,
                  size: 28.sp,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              action['label'] as String,
              style: GoogleFonts.baloo2(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Our Services",
          style: GoogleFonts.baloo2(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xff234C6A),
          ),
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _serviceItem("Express", "lightning", Icons.bolt, Colors.amber),
              _serviceItem(
                "Documents",
                "paper",
                Icons.description,
                Colors.blue,
              ),
              _serviceItem("Fragile", "glass", Icons.wine_bar, Colors.purple),
              _serviceItem("Heavy", "truck", Icons.vibration, Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _serviceItem(String title, String tag, IconData icon, Color color) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24.sp),
          SizedBox(height: 8.h),
          Text(
            title,
            style: GoogleFonts.baloo2(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      width: double.infinity,
      height: 100.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff234C6A), Color(0xff56A3A6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -10,
            child: Opacity(
              opacity: 0.2,
              child: Icon(Icons.local_offer, size: 100.sp, color: Colors.white),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Get 20% OFF",
                  style: GoogleFonts.baloo2(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "On your first 3 deliveries!",
                  style: GoogleFonts.baloo2(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xff56A3A6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.my_location,
                  color: const Color(0xff56A3A6),
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Current Location",
                      style: GoogleFonts.baloo2(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      _currentAddress,
                      style: GoogleFonts.baloo2(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 45.h,
            child: ElevatedButton(
              onPressed: _showOrderBottomSheet,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff56A3A6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                elevation: 0,
              ),
              child: Text(
                "Send Now",
                style: GoogleFonts.baloo2(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
