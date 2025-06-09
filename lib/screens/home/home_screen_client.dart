import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../models/user_models.dart';
import '../hospital/hospital_screen.dart';
import '../appointment/your_appointment.dart';
import '../profile_client/profile_client_screen.dart';
import '../client_doctor/doctor_client.dart';
import '../client_doctor/doctor_detail_screen.dart';
import '../client_records/client_records_screen.dart';
import '../../utils/page_transitions.dart';
import '../../widgets/hospital_doctor_selection_card.dart';

class HomeScreenClient extends StatefulWidget {
  final ClientUser? clientUser;

  const HomeScreenClient({super.key, this.clientUser});

  @override
  State<HomeScreenClient> createState() => _HomeScreenClientState();
}

class _HomeScreenClientState extends State<HomeScreenClient>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _selectedBottomIndex = 0;

  // Location related variables
  String _currentLocation = 'Location';
  bool _isLoadingLocation = false;

  // Carousel related variables
  int _currentCarouselIndex = 0;
  PageController? _pageController;
  Timer? _carouselTimer;
  bool _isUserInteracting = false;

  // For unlimited circular carousel
  static const int _carouselItemCount = 4; // Actual number of carousel items
  late List<Map<String, dynamic>> _infiniteCarouselItems;

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

    // Initialize infinite carousel items (duplicate items for seamless scrolling)
    _initializeInfiniteCarousel();

    // Initialize PageController for unlimited circular carousel
    _pageController = PageController(
      viewportFraction: 0.85,
      initialPage: _carouselItemCount, // Start from the first "real" item
    );

    _animationController.forward();
    _getCurrentLocation(); // Get location on startup
    _startCarouselTimer(); // Start automatic swiping
  }

  @override
  void dispose() {
    _animationController.dispose();
    _carouselTimer?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  // Get current location using GPS
  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoadingLocation = true;
      });

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentLocation = 'Location services disabled';
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentLocation = 'Location permission denied';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _currentLocation = 'Location permission denied permanently';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String locationName = '';

        if (place.locality != null && place.locality!.isNotEmpty) {
          locationName = place.locality!; // City name
        } else if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          locationName = place.subAdministrativeArea!; // District/County
        } else if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          locationName = place.administrativeArea!; // State/Province
        } else {
          locationName = 'Current Location';
        }

        setState(() {
          _currentLocation = locationName;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      setState(() {
        _currentLocation = 'Unable to get location';
        _isLoadingLocation = false;
      });
    }
  }

  String _getDisplayLocation() {
    // Prioritize GPS location over user's registered address
    if (_currentLocation != 'Location') {
      return _currentLocation;
    }

    // Fallback to user's registered address
    if (widget.clientUser?.address != null &&
        widget.clientUser!.address!.isNotEmpty) {
      final address = widget.clientUser!.address!;
      final parts = address.split(',');
      if (parts.length > 1) {
        return parts.last.trim();
      }
      return address.length > 20 ? '${address.substring(0, 20)}...' : address;
    }
    return 'Location';
  }

  String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Morning';
    } else if (hour < 17) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }

  String _getGreetingName() {
    debugPrint('HomeScreenClient: Getting greeting name...');

    if (widget.clientUser != null) {
      final firstName = widget.clientUser!.firstName.trim();
      final lastName = widget.clientUser!.lastName.trim();
      final email = widget.clientUser!.email.trim();

      debugPrint(
        'HomeScreenClient: User data - firstName: "$firstName", lastName: "$lastName", email: "$email"',
      );

      // If we have a first name, use it
      if (firstName.isNotEmpty) {
        debugPrint('HomeScreenClient: Using firstName: $firstName');
        return 'Mr. $firstName';
      }

      // If we have a last name but no first name, use last name
      if (lastName.isNotEmpty) {
        debugPrint('HomeScreenClient: Using lastName: $lastName');
        return 'Mr. $lastName';
      }

      // If we have an email, extract name from email with better logic
      if (email.isNotEmpty) {
        debugPrint('HomeScreenClient: Extracting name from email: $email');
        final emailParts = email.split('@');
        if (emailParts.isNotEmpty) {
          final emailName = emailParts[0];

          // Try to split by common separators and use the first meaningful part
          final nameParts = emailName.split(RegExp(r'[._-]'));
          String nameToUse = nameParts.isNotEmpty ? nameParts[0] : emailName;

          // Remove numbers and special characters, keep only letters
          nameToUse = nameToUse.replaceAll(RegExp(r'[^a-zA-Z]'), '');

          if (nameToUse.isNotEmpty) {
            final capitalizedName =
                nameToUse[0].toUpperCase() +
                nameToUse.substring(1).toLowerCase();
            debugPrint(
              'HomeScreenClient: Using extracted name from email: $capitalizedName',
            );
            return 'Mr. $capitalizedName';
          }
        }
      }

      debugPrint('HomeScreenClient: No valid name found, using UID fallback');
      // Last resort: use part of UID if available
      if (widget.clientUser!.uid != null &&
          widget.clientUser!.uid!.isNotEmpty) {
        final uidPart = widget.clientUser!.uid!.substring(0, 4).toUpperCase();
        return 'Mr. User$uidPart';
      }
    }

    // Default fallback
    debugPrint('HomeScreenClient: Using default fallback: Guest');
    return 'Mr. Guest';
  }

  // Initialize infinite carousel with duplicated items for seamless scrolling
  void _initializeInfiniteCarousel() {
    final originalItems = [
      {
        'title': 'Emergency Care 24/7',
        'subtitle': 'Immediate medical assistance available round the clock',
        'icon': Icons.emergency,
        'color': const Color(0xFFDC2626),
        'backgroundColor': const Color(0xFFFEF2F2),
      },
      {
        'title': 'Book Lab Tests',
        'subtitle': 'Schedule your health checkups and diagnostic tests',
        'icon': Icons.science,
        'color': const Color(0xFF7C3AED),
        'backgroundColor': const Color(0xFFF5F3FF),
      },
      {
        'title': 'Find Nearby Pharmacy',
        'subtitle': 'Locate pharmacies and order medicines online',
        'icon': Icons.local_pharmacy,
        'color': const Color(0xFF4ECDC4),
        'backgroundColor': const Color(0xFFF0FDFC),
      },
      {
        'title': 'Ambulance Service',
        'subtitle': 'Quick ambulance booking for medical emergencies',
        'icon': Icons.local_hospital,
        'color': const Color(0xFFEA580C),
        'backgroundColor': const Color(0xFFFFF7ED),
      },
    ];

    // Create infinite list: [last, ...original, first] for seamless scrolling
    _infiniteCarouselItems = [
      ...originalItems.sublist(
        originalItems.length - 1,
      ), // Last item at beginning
      ...originalItems, // Original items
      ...originalItems.sublist(0, 1), // First item at end
    ];
  }

  // Carousel timer methods
  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!_isUserInteracting &&
          _pageController != null &&
          _pageController!.hasClients) {
        final currentPage = _pageController!.page?.round() ?? 1;
        final nextPage = currentPage + 1;

        // Check if we need to handle the infinite loop
        if (nextPage >= _infiniteCarouselItems.length) {
          // Jump to the beginning (after the duplicate last item)
          _pageController!.jumpToPage(1);
        } else {
          _pageController!.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  void _stopCarouselTimer() {
    _carouselTimer?.cancel();
  }

  void _restartCarouselTimer() {
    _stopCarouselTimer();
    Timer(const Duration(seconds: 2), () {
      if (!_isUserInteracting) {
        _startCarouselTimer();
      }
    });
  }

  void _onCarouselInteractionStart() {
    _isUserInteracting = true;
    _stopCarouselTimer();
  }

  void _onCarouselInteractionEnd() {
    _isUserInteracting = false;
    _restartCarouselTimer();
  }

  // Handle page changes and implement seamless infinite scrolling
  void _handlePageChanged(int index) {
    // Update the current index for dot indicators
    if (index == 0) {
      // If we're at the duplicate last item (index 0), jump to the real last item
      setState(() {
        _currentCarouselIndex = _carouselItemCount - 1;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController != null && _pageController!.hasClients) {
          _pageController!.jumpToPage(_carouselItemCount);
        }
      });
    } else if (index == _infiniteCarouselItems.length - 1) {
      // If we're at the duplicate first item (last index), jump to the real first item
      setState(() {
        _currentCarouselIndex = 0;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController != null && _pageController!.hasClients) {
          _pageController!.jumpToPage(1);
        }
      });
    } else {
      // Normal case: update the index
      setState(() {
        _currentCarouselIndex = (index - 1) % _carouselItemCount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Enhanced Professional Header
            Container(
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
                    Color(0xFF667EEA), // Modern blue
                    Color(0xFF764BA2), // Purple accent
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Top row with greeting and location
                  Row(
                    children: [
                      // Left side - Enhanced Greeting
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Good ${_getTimeOfDay()},',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _getGreetingName(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Right side - Enhanced Location
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: _getCurrentLocation,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 3),
                                    Icon(
                                      _isLoadingLocation
                                          ? Icons.refresh
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                _isLoadingLocation
                                    ? const Text(
                                      'Locating...',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      textAlign: TextAlign.end,
                                    )
                                    : Text(
                                      _getDisplayLocation(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                      textAlign: TextAlign.end,
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Main Content with Professional Design
            Expanded(
              child: Container(
                color: const Color(0xFFF5F7FA),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCarouselSlider(),
                      const SizedBox(height: 16),
                      _buildBookAppointmentCard(),
                      const SizedBox(height: 16),
                      HospitalDoctorSelectionCard(
                        onHospitalTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HospitalScreen(),
                            ),
                          );
                        },
                        onDoctorTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DoctorClientScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildAvailableDoctorsSection(),
                      const SizedBox(height: 80), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // Carousel Slider
  Widget _buildCarouselSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Healthcare Services',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 85,
          child: GestureDetector(
            onPanStart: (_) => _onCarouselInteractionStart(),
            onPanEnd: (_) => _onCarouselInteractionEnd(),
            onTapDown: (_) => _onCarouselInteractionStart(),
            onTapUp: (_) => _onCarouselInteractionEnd(),
            onTapCancel: () => _onCarouselInteractionEnd(),
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                _handlePageChanged(index);
              },
              itemCount: _infiniteCarouselItems.length,
              itemBuilder: (context, index) {
                final item = _infiniteCarouselItems[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: _buildCarouselCard(
                    item['title'],
                    item['subtitle'],
                    item['icon'],
                    item['color'],
                    item['backgroundColor'],
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_carouselItemCount, (index) {
            return Container(
              width: 6.0,
              height: 6.0,
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    _currentCarouselIndex == index
                        ? const Color(0xFF667EEA)
                        : const Color(0xFFE5E7EB),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCarouselCard(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    Color backgroundColor,
  ) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: iconColor.withValues(alpha: 0.3)),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: iconColor,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Learn More',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward, color: iconColor, size: 9),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Book appointment card
  Widget _buildBookAppointmentCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Enhanced illustration
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stay update with your',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const Text(
                  'Appointment',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const YourAppointment(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Check',
                          style: TextStyle(
                            color: Color(0xFF667EEA),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          color: Color(0xFF667EEA),
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Available doctors section
  Widget _buildAvailableDoctorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Doctors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
                letterSpacing: 0.3,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF667EEA).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'View All',
                style: TextStyle(
                  color: Color(0xFF667EEA),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        const Text(
          'Top-rated doctors available today',
          style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildEnhancedDoctorCard(
                _getHomeDoctorData('Dr. Anish Chaudhary'),
              ),
              const SizedBox(width: 12),
              _buildEnhancedDoctorCard(
                _getHomeDoctorData('Dr. Shishir Gautam'),
              ),
              const SizedBox(width: 12),
              _buildEnhancedDoctorCard(_getHomeDoctorData('Dipesh Pandey')),
            ],
          ),
        ),
      ],
    );
  }

  // Get doctor data for home screen display
  DoctorInfo _getHomeDoctorData(String doctorName) {
    switch (doctorName) {
      case 'Dr. Anish Chaudhary':
        return DoctorInfo(
          name: 'Dr. Anish Chaudhary',
          specialization: 'Cardiologist',
          qualifications: ['MBBS', 'MD Cardiology', 'FACC'],
          rating: 4.9,
          reviewCount: 150,
          experience: 12,
          hospital: 'Tribhuvan University Teaching Hospital',
          consultationFee: 1500,
          contactNumber: '+977-1-4412303',
          isAvailable: true,
          availableSlots: ['8:00 AM', '10:00 AM', '1:00 PM', '2:00 PM'],
          about:
              'Experienced cardiologist specializing in interventional cardiology and heart disease prevention with over 12 years of practice.',
        );
      case 'Dr. Shishir Gautam':
        return DoctorInfo(
          name: 'Dr. Shishir Gautam',
          specialization: 'General Medicine',
          qualifications: ['MBBS', 'MD Internal Medicine'],
          rating: 4.8,
          reviewCount: 200,
          experience: 10,
          hospital: 'Grande International Hospital',
          consultationFee: 1200,
          contactNumber: '+977-1-5159266',
          isAvailable: true,
          availableSlots: ['9:00 AM', '11:00 AM', '3:00 PM', '5:00 PM'],
          about:
              'General medicine specialist with expertise in comprehensive healthcare and preventive medicine.',
        );
      case 'Dipesh Pandey':
        return DoctorInfo(
          name: 'Dipesh Pandey',
          specialization: 'Pediatrician',
          qualifications: ['MBBS', 'MD Pediatrics'],
          rating: 4.7,
          reviewCount: 120,
          experience: 8,
          hospital: 'Norvic International Hospital',
          consultationFee: 1000,
          contactNumber: '+977-1-4258554',
          isAvailable: false,
          availableSlots: ['10:00 AM', '2:00 PM', '4:00 PM'],
          about:
              'Dedicated pediatrician specializing in child healthcare and development with focus on preventive care.',
        );
      default:
        throw Exception('Doctor not found: $doctorName');
    }
  }

  Widget _buildEnhancedDoctorCard(DoctorInfo doctor) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DoctorDetailScreen(doctor: doctor),
          ),
        );
      },
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor avatar and status
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color:
                        doctor.isAvailable
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    doctor.isAvailable ? 'Available' : 'Busy',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color:
                          doctor.isAvailable
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Doctor info
            Text(
              doctor.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              doctor.specialization,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            // Rating and patients
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFBBF24), size: 12),
                const SizedBox(width: 2),
                Text(
                  doctor.rating.toString(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${doctor.reviewCount}+ patients',
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF6B7280),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // Time slots
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Color(0xFF6B7280),
                  size: 12,
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    doctor.availableSlots.isNotEmpty
                        ? '${doctor.availableSlots.first} - ${doctor.availableSlots.last}'
                        : 'No slots available',
                    style: const TextStyle(
                      fontSize: 9,
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
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.only(
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBottomNavItem(Icons.home_filled, 'Home', 0),
          _buildBottomNavItem(Icons.biotech, 'Lab Tests', 1),
          // Enhanced Emergency button
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDC2626), Color(0xFFB91C1C)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDC2626).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.emergency, color: Colors.white, size: 18),
          ),
          _buildBottomNavItem(Icons.receipt_long, 'Records', 3),
          _buildBottomNavItem(Icons.person, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem(IconData? icon, String label, int index) {
    final isSelected = index == _selectedBottomIndex;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          // Lab Tests tab
          _showLabTestOptions();
        } else if (index == 3) {
          // Records tab
          if (widget.clientUser != null) {
            Navigator.push(
              context,
              FadeSlidePageRoute(
                child: ClientRecordsScreen(clientUser: widget.clientUser!),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please log in to view your records'),
                backgroundColor: Color(0xFFDC2626),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else if (index == 4) {
          // Profile tab
          if (widget.clientUser != null) {
            Navigator.push(
              context,
              FadeSlidePageRoute(
                child: ProfileClientScreen(clientUser: widget.clientUser!),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please log in to view your profile'),
                backgroundColor: Color(0xFFDC2626),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          setState(() {
            _selectedBottomIndex = index;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? const Color(0xFF667EEA).withValues(alpha: 0.1)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color:
                      isSelected
                          ? const Color(0xFF667EEA)
                          : const Color(0xFF9CA3AF),
                  size: 18,
                ),
              ),
            if (icon != null) const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected
                        ? const Color(0xFF667EEA)
                        : const Color(0xFF9CA3AF),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show lab test options dialog
  void _showLabTestOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Lab Tests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLabTestOption(
                'Blood Test',
                'Complete blood count and analysis',
                Icons.bloodtype,
                const Color(0xFFDC2626),
              ),
              const SizedBox(height: 12),
              _buildLabTestOption(
                'Urine Test',
                'Comprehensive urine analysis',
                Icons.science,
                const Color(0xFF7C3AED),
              ),
              const SizedBox(height: 12),
              _buildLabTestOption(
                'X-Ray',
                'Digital X-ray imaging',
                Icons.medical_services,
                const Color(0xFF059669),
              ),
              const SizedBox(height: 12),
              _buildLabTestOption(
                'ECG',
                'Electrocardiogram test',
                Icons.monitor_heart,
                const Color(0xFFEA580C),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFF667EEA),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLabTestOption(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title booking feature coming soon!'),
            backgroundColor: color,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
