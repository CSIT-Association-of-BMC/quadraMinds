import 'package:flutter/material.dart';
import '../hospital/hospital_screen.dart';
import 'book_appointment_dialog.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedCity = 'All';
  String _searchQuery = '';
  final String _sortBy = 'distance';
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Hospital data for appointment booking (reusing from hospital_screen.dart)
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
  ];

  List<HospitalInfo> get _filteredHospitals {
    List<HospitalInfo> filtered = _hospitals;

    // Filter by city
    if (_selectedCity != 'All') {
      filtered =
          filtered.where((hospital) => hospital.city == _selectedCity).toList();
    }

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

  void _showBookingDialog(HospitalInfo hospital) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BookAppointmentDialog(hospital: hospital);
      },
    );
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
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2E7D32), // Healthcare green
            Color(0xFF388E3C), // Slightly lighter green
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
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
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Book Appointment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSearchBar(),
          const SizedBox(height: 12),
          _buildCityFilter(),
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
          hintText: 'Search hospitals for appointment...',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF6B7280),
            size: 20,
          ),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    child: const Icon(
                      Icons.clear,
                      color: Color(0xFF6B7280),
                      size: 18,
                    ),
                  )
                  : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCityFilter() {
    final cities = ['All', 'Butwal', 'Kathmandu'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            cities.map((city) {
              final isSelected = _selectedCity == city;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCity = city;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    city,
                    style: TextStyle(
                      color:
                          isSelected ? const Color(0xFF2E7D32) : Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
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
      padding: const EdgeInsets.all(16),
      itemCount: filteredHospitals.length,
      itemBuilder: (context, index) {
        return _buildHospitalCard(filteredHospitals[index]);
      },
    );
  }

  Widget _buildHospitalCard(HospitalInfo hospital) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hospital header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            hospital.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      hospital.isAvailable
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  hospital.isAvailable ? 'Available' : 'Busy',
                  style: TextStyle(
                    fontSize: 10,
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
          const SizedBox(height: 10),

          // Specializations
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                hospital.specializations.take(3).map((spec) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      spec,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  );
                }).toList(),
          ),

          const SizedBox(height: 10),

          // Rating and distance
          Row(
            children: [
              // Rating
              Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFFFBBF24), size: 14),
                  const SizedBox(width: 3),
                  Text(
                    hospital.rating.toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Distance
              Row(
                children: [
                  const Icon(
                    Icons.directions_walk,
                    color: Color(0xFF6B7280),
                    size: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    hospital.distance,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Book Appointment button
              GestureDetector(
                onTap: () => _showBookingDialog(hospital),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Book Appointment',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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
