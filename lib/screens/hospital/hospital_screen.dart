import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hospital_detail_screen.dart';

class HospitalScreen extends StatefulWidget {
  const HospitalScreen({super.key});

  @override
  State<HospitalScreen> createState() => _HospitalScreenState();
}

class _HospitalScreenState extends State<HospitalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _searchQuery = '';
  String _sortBy = 'distance'; // distance, rating, name
  bool _showFavoritesOnly = false;
  Set<String> _favoriteHospitals = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    // Load favorites after a short delay to ensure the widget is fully initialized
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _loadFavorites();
      }
    });
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('favorite_hospitals') ?? [];
      setState(() {
        _favoriteHospitals = favorites.toSet();
      });
    } catch (e) {
      // Handle SharedPreferences error gracefully
      // Initialize with empty set if SharedPreferences fails
      setState(() {
        _favoriteHospitals = {};
      });
    }
  }

  Future<void> _toggleFavorite(String hospitalName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        if (_favoriteHospitals.contains(hospitalName)) {
          _favoriteHospitals.remove(hospitalName);
        } else {
          _favoriteHospitals.add(hospitalName);
        }
      });
      await prefs.setStringList(
        'favorite_hospitals',
        _favoriteHospitals.toList(),
      );
    } catch (e) {
      // Handle SharedPreferences error gracefully
      // Just update the UI state without persistence
      setState(() {
        if (_favoriteHospitals.contains(hospitalName)) {
          _favoriteHospitals.remove(hospitalName);
        } else {
          _favoriteHospitals.add(hospitalName);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorites will not be saved permanently'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch phone dialer')),
        );
      }
    }
  }

  Future<void> _openDirections(String location) async {
    try {
      // Create a Google Maps URL for directions
      final encodedLocation = Uri.encodeComponent(location);
      final mapsUrl =
          'https://www.google.com/maps/search/?api=1&query=$encodedLocation';
      final uri = Uri.parse(mapsUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not launch maps';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not open maps')));
      }
    }
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Filter & Sort Hospitals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Distance (Nearest first)'),
                value: 'distance',
                groupValue: _sortBy,
                activeColor: const Color(0xFF1E40AF),
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Rating (Highest first)'),
                value: 'rating',
                groupValue: _sortBy,
                activeColor: const Color(0xFF1E40AF),
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Name (A-Z)'),
                value: 'name',
                groupValue: _sortBy,
                activeColor: const Color(0xFF1E40AF),
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFF1E40AF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Hospital data for Butwal and Kathmandu
  List<HospitalInfo> get _hospitals => [
    // Butwal Hospitals
    HospitalInfo(
      name: 'Butwal Hospital',
      specializations: ['General Medicine', 'Surgery', 'Pediatrics'],
      location: 'Butwal, Rupandehi',
      rating: 4.5,
      distance: '2.5 km',
      isAvailable: true,
      city: 'Butwal',
      contactNumber: '+977-71-540123',
      emergencyAvailable: true,
    ),
    HospitalInfo(
      name: 'Lumbini Medical College',
      specializations: ['Cardiology', 'Neurology', 'Orthopedics'],
      location: 'Palpa Road, Butwal',
      rating: 4.7,
      distance: '3.2 km',
      isAvailable: true,
      city: 'Butwal',
      contactNumber: '+977-71-540456',
      emergencyAvailable: true,
    ),
    HospitalInfo(
      name: 'Crimson Hospital',
      specializations: ['Emergency Care', 'ICU', 'General Surgery'],
      location: 'Traffic Chowk, Butwal',
      rating: 4.3,
      distance: '1.8 km',
      isAvailable: true,
      city: 'Butwal',
      contactNumber: '+977-71-540789',
      emergencyAvailable: true,
    ),
    HospitalInfo(
      name: 'Siddhartha Hospital',
      specializations: ['Maternity', 'Gynecology', 'Pediatrics'],
      location: 'Golpark, Butwal',
      rating: 4.4,
      distance: '4.1 km',
      isAvailable: false,
      city: 'Butwal',
      contactNumber: '+977-71-541012',
      emergencyAvailable: false,
    ),

    // Kathmandu Hospitals
    HospitalInfo(
      name: 'Tribhuvan University Teaching Hospital',
      specializations: ['All Specialties', 'Research', 'Emergency'],
      location: 'Maharajgunj, Kathmandu',
      rating: 4.8,
      distance: '5.2 km',
      isAvailable: true,
      city: 'Kathmandu',
      contactNumber: '+977-1-4412303',
      emergencyAvailable: true,
    ),
    HospitalInfo(
      name: 'Bir Hospital',
      specializations: ['General Medicine', 'Surgery', 'Emergency'],
      location: 'Mahaboudha, Kathmandu',
      rating: 4.2,
      distance: '3.8 km',
      isAvailable: true,
      city: 'Kathmandu',
      contactNumber: '+977-1-4221119',
      emergencyAvailable: true,
    ),
    HospitalInfo(
      name: 'Grande International Hospital',
      specializations: ['Cardiology', 'Oncology', 'Neurosurgery'],
      location: 'Dhapasi, Kathmandu',
      rating: 4.9,
      distance: '8.5 km',
      isAvailable: true,
      city: 'Kathmandu',
      contactNumber: '+977-1-5159266',
      emergencyAvailable: true,
    ),
    HospitalInfo(
      name: 'Nepal Medical College',
      specializations: ['Teaching Hospital', 'All Departments'],
      location: 'Jorpati, Kathmandu',
      rating: 4.6,
      distance: '12.3 km',
      isAvailable: true,
      city: 'Kathmandu',
      contactNumber: '+977-1-4911008',
      emergencyAvailable: true,
    ),
    HospitalInfo(
      name: 'Patan Hospital',
      specializations: ['General Medicine', 'Pediatrics', 'Surgery'],
      location: 'Lagankhel, Lalitpur',
      rating: 4.4,
      distance: '6.7 km',
      isAvailable: false,
      city: 'Kathmandu',
      contactNumber: '+977-1-5522266',
      emergencyAvailable: false,
    ),
    HospitalInfo(
      name: 'Norvic International Hospital',
      specializations: ['Cardiology', 'Orthopedics', 'Gastroenterology'],
      location: 'Thapathali, Kathmandu',
      rating: 4.7,
      distance: '4.9 km',
      isAvailable: true,
      city: 'Kathmandu',
      contactNumber: '+977-1-4258554',
      emergencyAvailable: true,
    ),
  ];

  List<HospitalInfo> get _filteredHospitals {
    List<HospitalInfo> filtered = _hospitals;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (hospital) =>
                    hospital.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    hospital.specializations.any(
                      (spec) => spec.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                    ) ||
                    hospital.location.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    // Filter by favorites
    if (_showFavoritesOnly) {
      filtered =
          filtered
              .where((hospital) => _favoriteHospitals.contains(hospital.name))
              .toList();
    }

    // Sort hospitals
    switch (_sortBy) {
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'distance':
      default:
        filtered.sort((a, b) {
          final aDistance = double.tryParse(a.distance.split(' ')[0]) ?? 0;
          final bDistance = double.tryParse(b.distance.split(' ')[0]) ?? 0;
          return aDistance.compareTo(bDistance);
        });
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [_buildHeader(), Expanded(child: _buildHospitalList())],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: 20,
        right: 20,
        bottom: 24,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E40AF), // Modern blue
            Color(0xFF3B82F6), // Lighter blue
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E40AF).withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with back button and title
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'Hospitals',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Only favorites button in header now
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showFavoritesOnly = !_showFavoritesOnly;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        _showFavoritesOnly
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.favorite,
                    color:
                        _showFavoritesOnly
                            ? const Color(0xFF1E40AF)
                            : Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search hospitals, specializations...',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF6B7280),
            size: 20,
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filter icon in search bar
              GestureDetector(
                onTap: () => _showSortDialog(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons
                        .tune, // Changed from Icons.sort to Icons.tune (filter icon)
                    color: Color(0xFF1E40AF),
                    size: 16,
                  ),
                ),
              ),
              // Clear button (only show when there's text)
              if (_searchQuery.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    margin: const EdgeInsets.only(right: 8),
                    child: const Icon(
                      Icons.clear,
                      color: Color(0xFF6B7280),
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildHospitalList() {
    final filteredHospitals = _filteredHospitals;

    if (filteredHospitals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_hospital_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hospitals found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filter',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: filteredHospitals.length,
      itemBuilder: (context, index) {
        return _buildHospitalCard(filteredHospitals[index]);
      },
    );
  }

  Widget _buildHospitalCard(HospitalInfo hospital) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hospital header - more compact
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hospital.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            hospital.location,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _toggleFavorite(hospital.name),
                    child: Icon(
                      _favoriteHospitals.contains(hospital.name)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          _favoriteHospitals.contains(hospital.name)
                              ? Colors.red
                              : const Color(0xFF6B7280),
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          hospital.isAvailable
                              ? const Color(0xFF10B981).withValues(alpha: 0.1)
                              : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      hospital.isAvailable ? 'Open' : 'Closed',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color:
                            hospital.isAvailable
                                ? const Color(0xFF10B981)
                                : const Color(0xFFF59E0B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Specializations - more compact
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...hospital.specializations.take(2).map((spec) {
                  return Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      spec,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  );
                }),
                if (hospital.specializations.length > 2)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B7280).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+${hospital.specializations.length - 2}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Rating, distance, and emergency - single row
          Row(
            children: [
              // Rating
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Color(0xFFFBBF24), size: 12),
                  const SizedBox(width: 2),
                  Text(
                    hospital.rating.toString(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),

              // Distance
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.directions_walk,
                    color: Color(0xFF6B7280),
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    hospital.distance,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Emergency badge
              if (hospital.emergencyAvailable)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.emergency, size: 8, color: Color(0xFFDC2626)),
                      SizedBox(width: 2),
                      Text(
                        '24/7',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Action buttons - more compact
          Row(
            children: [
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                HospitalDetailScreen(hospital: hospital),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E40AF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'View Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _makePhoneCall(hospital.contactNumber),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.phone,
                    color: Color(0xFF1E40AF),
                    size: 14,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _openDirections(hospital.location),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.directions,
                    color: Color(0xFF1E40AF),
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Hospital Info Model
class HospitalInfo {
  final String name;
  final List<String> specializations;
  final String location;
  final double rating;
  final String distance;
  final String? imageUrl;
  final bool isAvailable;
  final String city;
  final String contactNumber;
  final bool emergencyAvailable;

  HospitalInfo({
    required this.name,
    required this.specializations,
    required this.location,
    required this.rating,
    required this.distance,
    this.imageUrl,
    required this.isAvailable,
    required this.city,
    required this.contactNumber,
    required this.emergencyAvailable,
  });
}
