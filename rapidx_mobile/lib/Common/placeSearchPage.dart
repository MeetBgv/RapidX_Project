import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:newrapidx/services/nominatim_service.dart';

/// Full-screen place search page with autocomplete.
///
/// Returns a [Map] with keys: lat, lng, displayName
/// when the user taps a search result.
class PlaceSearchPage extends StatefulWidget {
  const PlaceSearchPage({super.key});

  @override
  State<PlaceSearchPage> createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<NominatimPlace> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    NominatimService.cancelSearch();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().length < 3) {
      setState(() {
        _results = [];
        _isSearching = false;
        _hasSearched = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    NominatimService.debouncedSearch(query, (results) {
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
          _hasSearched = true;
        });
      }
    });
  }

  void _selectPlace(NominatimPlace place) {
    Navigator.pop(context, {
      'lat': place.lat,
      'lng': place.lng,
      'displayName': place.displayName,
      'address': place.address,
      'city': place.city,
      'state': place.state,
      'pincode': place.pincode,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: const Color(0xff234C6A), size: 24.sp),
        ),
        title: Text(
          "Search Place",
          style: GoogleFonts.baloo2(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xff234C6A),
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: _buildSearchBar(),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 8.h),
          Expanded(child: _buildResultsList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xffF2F2F2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        onChanged: _onSearchChanged,
        style: GoogleFonts.baloo2(
          fontSize: 14.sp,
          color: Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: "Search for area, street, locality...",
          hintStyle: GoogleFonts.baloo2(
            fontSize: 14.sp,
            color: Colors.grey.shade400,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: const Color(0xff234C6A),
            size: 22.sp,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  child: Icon(
                    Icons.close,
                    color: Colors.grey.shade400,
                    size: 20.sp,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xff56A3A6),
              strokeWidth: 2.5,
            ),
            SizedBox(height: 12.h),
            Text(
              "Searching...",
              style: GoogleFonts.baloo2(
                fontSize: 14.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    if (_hasSearched && _results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 48.sp,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 12.h),
            Text(
              "No places found",
              style: GoogleFonts.baloo2(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Try searching with a different term",
              style: GoogleFonts.baloo2(
                fontSize: 13.sp,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      );
    }

    if (!_hasSearched && _results.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 40.h),
            Icon(
              Icons.travel_explore,
              size: 56.sp,
              color: const Color(0xff56A3A6).withValues(alpha: 0.4),
            ),
            SizedBox(height: 16.h),
            Text(
              "Search for a location",
              style: GoogleFonts.baloo2(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Type at least 3 characters to search",
              style: GoogleFonts.baloo2(
                fontSize: 13.sp,
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: _results.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: Colors.grey.shade100,
      ),
      itemBuilder: (context, index) {
        final place = _results[index];
        return _buildPlaceItem(place);
      },
    );
  }

  Widget _buildPlaceItem(NominatimPlace place) {
    final parts = place.displayName.split(', ');
    final primary = parts.isNotEmpty ? parts.first : place.displayName;
    final secondary =
        parts.length > 1 ? parts.sublist(1).join(', ') : '';

    return InkWell(
      onTap: () => _selectPlace(place),
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xff234C6A).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.location_on_outlined,
                color: const Color(0xff234C6A),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    primary,
                    style: GoogleFonts.baloo2(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (secondary.isNotEmpty)
                    Text(
                      secondary,
                      style: GoogleFonts.baloo2(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.north_east,
              color: Colors.grey.shade300,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }
}
