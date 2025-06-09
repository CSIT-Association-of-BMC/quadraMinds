import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'doctor_detail_screen.dart';
import '../../services/doctor_service.dart';

class DoctorClientScreen extends StatefulWidget {
  const DoctorClientScreen({super.key});

  @override
  State<DoctorClientScreen> createState() => _DoctorClientScreenState();
}

class _DoctorClientScreenState extends State<DoctorClientScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedSpecialty = 'All';
  String _searchQuery = '';
  String _sortBy = 'rating'; // rating, experience, name, fees
  bool _showFavoritesOnly = false;
  Set<String> _favoriteDoctors = {};
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
      final favorites = prefs.getStringList('favorite_doctors') ?? [];
      setState(() {
        _favoriteDoctors = favorites.toSet();
      });
    } catch (e) {
      // Handle SharedPreferences error gracefully
      setState(() {
        _favoriteDoctors = {};
      });
    }
  }

  Future<void> _toggleFavorite(String doctorName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        if (_favoriteDoctors.contains(doctorName)) {
          _favoriteDoctors.remove(doctorName);
        } else {
          _favoriteDoctors.add(doctorName);
        }
      });
      await prefs.setStringList('favorite_doctors', _favoriteDoctors.toList());
    } catch (e) {
      // Handle SharedPreferences error gracefully
      setState(() {
        if (_favoriteDoctors.contains(doctorName)) {
          _favoriteDoctors.remove(doctorName);
        } else {
          _favoriteDoctors.add(doctorName);
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

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sort Doctors'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Rating'),
                value: 'rating',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Experience'),
                value: 'experience',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Name'),
                value: 'name',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Consultation Fees'),
                value: 'fees',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() {
                    _sortBy = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getSortLabel() {
    switch (_sortBy) {
      case 'rating':
        return 'Rating';
      case 'experience':
        return 'Experience';
      case 'name':
        return 'Name';
      case 'fees':
        return 'Fees';
      default:
        return 'Sort';
    }
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Advanced Filters',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterSection('Sort By', _buildSortOptions()),
                      const SizedBox(height: 20),
                      _buildFilterSection(
                        'Availability',
                        _buildAvailabilityFilter(),
                      ),
                      const SizedBox(height: 20),
                      _buildFilterSection(
                        'Experience',
                        _buildExperienceFilter(),
                      ),
                      const SizedBox(height: 20),
                      _buildFilterSection(
                        'Consultation Fee',
                        _buildFeeFilter(),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedSpecialty = 'All';
                            _sortBy = 'rating';
                            _showFavoritesOnly = false;
                            _searchQuery = '';
                            _searchController.clear();
                          });
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF1E40AF)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(color: Color(0xFF1E40AF)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E40AF),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildSortOptions() {
    final sortOptions = [
      {'label': 'Rating', 'value': 'rating'},
      {'label': 'Experience', 'value': 'experience'},
      {'label': 'Name', 'value': 'name'},
      {'label': 'Consultation Fees', 'value': 'fees'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          sortOptions.map((option) {
            final isSelected = _sortBy == option['value'];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _sortBy = option['value'] as String;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF1E40AF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFF1E40AF)
                            : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Text(
                  option['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildAvailabilityFilter() {
    return Row(
      children: [
        Checkbox(
          value: _showFavoritesOnly,
          onChanged: (value) {
            setState(() {
              _showFavoritesOnly = value ?? false;
            });
          },
          activeColor: const Color(0xFF1E40AF),
        ),
        const Text(
          'Show only favorites',
          style: TextStyle(color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildExperienceFilter() {
    return const Text(
      'Experience filter coming soon...',
      style: TextStyle(color: Color(0xFF6B7280), fontStyle: FontStyle.italic),
    );
  }

  Widget _buildFeeFilter() {
    return const Text(
      'Fee range filter coming soon...',
      style: TextStyle(color: Color(0xFF6B7280), fontStyle: FontStyle.italic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Doctor data
  List<DoctorInfo> get _doctors => [
    DoctorInfo(
      name: 'Dr. Rajesh Sharma',
      specialization: 'Cardiologist',
      qualifications: ['MBBS', 'MD Cardiology', 'FACC'],
      rating: 4.8,
      reviewCount: 245,
      experience: 15,
      hospital: 'Tribhuvan University Teaching Hospital',
      consultationFee: 1500,
      contactNumber: '+977-1-4412303',
      isAvailable: true,
      availableSlots: ['9:00 AM', '11:00 AM', '2:00 PM', '4:00 PM'],
      imageUrl: null,
      about:
          'Experienced cardiologist specializing in interventional cardiology and heart disease prevention.',
    ),
    DoctorInfo(
      name: 'Dr. Sunita Thapa',
      specialization: 'Pediatrician',
      qualifications: ['MBBS', 'MD Pediatrics', 'IAP Fellowship'],
      rating: 4.9,
      reviewCount: 189,
      experience: 12,
      hospital: 'Grande International Hospital',
      consultationFee: 1200,
      contactNumber: '+977-1-5159266',
      isAvailable: true,
      availableSlots: ['10:00 AM', '1:00 PM', '3:00 PM', '5:00 PM'],
      imageUrl: null,
      about:
          'Dedicated pediatrician with expertise in child development and pediatric emergency care.',
    ),
    DoctorInfo(
      name: 'Dr. Amit Poudel',
      specialization: 'Orthopedic Surgeon',
      qualifications: ['MBBS', 'MS Orthopedics', 'AO Fellowship'],
      rating: 4.7,
      reviewCount: 156,
      experience: 18,
      hospital: 'Norvic International Hospital',
      consultationFee: 2000,
      contactNumber: '+977-1-4258554',
      isAvailable: false,
      availableSlots: ['9:00 AM', '2:00 PM'],
      imageUrl: null,
      about:
          'Expert orthopedic surgeon specializing in joint replacement and sports medicine.',
    ),
    DoctorInfo(
      name: 'Dr. Priya Maharjan',
      specialization: 'Dermatologist',
      qualifications: ['MBBS', 'MD Dermatology', 'IADVL'],
      rating: 4.6,
      reviewCount: 203,
      experience: 10,
      hospital: 'Patan Hospital',
      consultationFee: 1000,
      contactNumber: '+977-1-5522266',
      isAvailable: true,
      availableSlots: ['11:00 AM', '1:00 PM', '4:00 PM'],
      imageUrl: null,
      about:
          'Skilled dermatologist focusing on cosmetic dermatology and skin cancer treatment.',
    ),
    DoctorInfo(
      name: 'Dr. Krishna Bahadur',
      specialization: 'Neurologist',
      qualifications: ['MBBS', 'DM Neurology', 'European Fellowship'],
      rating: 4.9,
      reviewCount: 134,
      experience: 20,
      hospital: 'Bir Hospital',
      consultationFee: 2500,
      contactNumber: '+977-1-4221119',
      isAvailable: true,
      availableSlots: ['10:00 AM', '3:00 PM'],
      imageUrl: null,
      about:
          'Renowned neurologist with expertise in stroke management and epilepsy treatment.',
    ),
    DoctorInfo(
      name: 'Dr. Sita Gurung',
      specialization: 'Gynecologist',
      qualifications: ['MBBS', 'MD Gynecology', 'FIGO Certification'],
      rating: 4.8,
      reviewCount: 278,
      experience: 14,
      hospital: 'Nepal Medical College',
      consultationFee: 1300,
      contactNumber: '+977-1-4911008',
      isAvailable: true,
      availableSlots: ['9:00 AM', '12:00 PM', '3:00 PM', '5:00 PM'],
      imageUrl: null,
      about:
          'Experienced gynecologist specializing in high-risk pregnancies and minimally invasive surgery.',
    ),
  ];

  List<DoctorInfo> get _filteredDoctors {
    List<DoctorInfo> filtered = _doctors;

    // Filter by specialty
    if (_selectedSpecialty != 'All') {
      filtered =
          filtered
              .where((doctor) => doctor.specialization == _selectedSpecialty)
              .toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (doctor) =>
                    doctor.name.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    doctor.specialization.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    doctor.hospital.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
              .toList();
    }

    // Filter by favorites
    if (_showFavoritesOnly) {
      filtered =
          filtered
              .where((doctor) => _favoriteDoctors.contains(doctor.name))
              .toList();
    }

    // Sort doctors
    switch (_sortBy) {
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'experience':
        filtered.sort((a, b) => b.experience.compareTo(a.experience));
        break;
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'fees':
        filtered.sort((a, b) => a.consultationFee.compareTo(b.consultationFee));
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
          children: [_buildHeader(), Expanded(child: _buildDoctorList())],
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
                  'Find Doctors',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showAdvancedFilters(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showFavoritesOnly = !_showFavoritesOnly;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
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
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEnhancedSearchBar(),
          const SizedBox(height: 12),
          _buildQuickFilters(),
        ],
      ),
    );
  }

  Widget _buildEnhancedSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search doctors, specializations, hospitals...',
                hintStyle: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 14,
                ),
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
          ),
          Container(height: 40, width: 1, color: const Color(0xFFE5E7EB)),
          GestureDetector(
            onTap: () => _showSortDialog(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort, color: Color(0xFF6B7280), size: 18),
                  const SizedBox(width: 4),
                  Text(
                    _getSortLabel(),
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    final quickFilters = [
      {'label': 'All', 'value': 'All', 'icon': Icons.medical_services},
      {'label': 'Cardiology', 'value': 'Cardiologist', 'icon': Icons.favorite},
      {
        'label': 'Pediatrics',
        'value': 'Pediatrician',
        'icon': Icons.child_care,
      },
      {
        'label': 'Orthopedic',
        'value': 'Orthopedic Surgeon',
        'icon': Icons.accessibility,
      },
      {'label': 'Dermatology', 'value': 'Dermatologist', 'icon': Icons.face},
      {'label': 'Neurology', 'value': 'Neurologist', 'icon': Icons.psychology},
      {
        'label': 'Gynecology',
        'value': 'Gynecologist',
        'icon': Icons.pregnant_woman,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            quickFilters.map((filter) {
              final isSelected = _selectedSpecialty == filter['value'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedSpecialty = filter['value'] as String;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color:
                          isSelected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        filter['icon'] as IconData,
                        size: 16,
                        color:
                            isSelected ? const Color(0xFF1E40AF) : Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        filter['label'] as String,
                        style: TextStyle(
                          color:
                              isSelected
                                  ? const Color(0xFF1E40AF)
                                  : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildDoctorList() {
    final filteredDoctors = _filteredDoctors;

    if (filteredDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No doctors found',
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
      itemCount: filteredDoctors.length,
      itemBuilder: (context, index) {
        return _buildDoctorCard(filteredDoctors[index]);
      },
    );
  }

  Widget _buildDoctorCard(DoctorInfo doctor) {
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
          // Doctor header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 16,
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
                        fontSize: 14,
                        color: Color(0xFF1E40AF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.local_hospital_outlined,
                          size: 12,
                          color: Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            doctor.hospital,
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
                    onTap: () => _toggleFavorite(doctor.name),
                    child: Icon(
                      _favoriteDoctors.contains(doctor.name)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          _favoriteDoctors.contains(doctor.name)
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
                          doctor.isAvailable
                              ? const Color(0xFF10B981).withValues(alpha: 0.1)
                              : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      doctor.isAvailable ? 'Available' : 'Busy',
                      style: TextStyle(
                        fontSize: 9,
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
            ],
          ),
          const SizedBox(height: 10),

          // Qualifications
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                ...doctor.qualifications.take(3).map((qual) {
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
                      qual,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  );
                }),
                if (doctor.qualifications.length > 3)
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
                      '+${doctor.qualifications.length - 3}',
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

          const SizedBox(height: 10),

          // Rating, experience, and fees
          Row(
            children: [
              // Rating
              Row(
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(width: 2),
                  Text(
                    '(${doctor.reviewCount})',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),

              // Experience
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.work_outline,
                    color: Color(0xFF6B7280),
                    size: 12,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${doctor.experience}y exp',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Consultation fee
              Text(
                'Rs. ${doctor.consultationFee}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E40AF),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Action buttons
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
                            (context) => DoctorDetailScreen(doctor: doctor),
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
                      'View Profile',
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
                onTap: () => _makePhoneCall(doctor.contactNumber),
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
                onTap: () {
                  // Show appointment booking dialog
                  _showAppointmentDialog(doctor);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF10B981),
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

  void _showAppointmentDialog(DoctorInfo doctor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Book Appointment with ${doctor.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Available Slots:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ...doctor.availableSlots.map(
                (slot) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('• $slot'),
                ),
              ),
              const SizedBox(height: 16),
              Text('Consultation Fee: Rs. ${doctor.consultationFee}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Appointment request sent to ${doctor.name}'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E40AF),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

// Doctor Info Model
class DoctorInfo {
  final String name;
  final String specialization;
  final List<String> qualifications;
  final double rating;
  final int reviewCount;
  final int experience;
  final String hospital;
  final int consultationFee;
  final String contactNumber;
  final bool isAvailable;
  final List<String> availableSlots;
  final String? imageUrl;
  final String about;

  DoctorInfo({
    required this.name,
    required this.specialization,
    required this.qualifications,
    required this.rating,
    required this.reviewCount,
    required this.experience,
    required this.hospital,
    required this.consultationFee,
    required this.contactNumber,
    required this.isAvailable,
    required this.availableSlots,
    this.imageUrl,
    required this.about,
  });
}
