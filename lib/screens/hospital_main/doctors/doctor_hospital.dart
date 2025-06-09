import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'doctor_detail_hospital.dart';
import 'add_doctor_screen.dart';
import '../../../services/doctor_service.dart';

class DoctorHospitalScreen extends StatefulWidget {
  const DoctorHospitalScreen({super.key});

  @override
  State<DoctorHospitalScreen> createState() => _DoctorHospitalScreenState();
}

class _DoctorHospitalScreenState extends State<DoctorHospitalScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSpecialty = 'All';
  String _sortBy = 'name';
  bool _showFilterPanel = false;
  Set<String> _favoriteDoctors = {};

  // Doctor service instance
  final DoctorService _doctorService = DoctorService();
  List<DoctorInfo> _doctors = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadFavorites();
    _initializeDoctorService();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteDoctors = prefs.getStringList('favorite_doctors')?.toSet() ?? {};
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_doctors', _favoriteDoctors.toList());
  }

  // Initialize doctors data for hospital management
  void _initializeDoctorService() {
    _doctorService.initialize();
    _doctors = _doctorService.getAllDoctors();

    // Listen for changes in doctor data
    _doctorService.addListener((doctors) {
      if (mounted) {
        setState(() {
          _doctors = doctors;
        });
      }
    });
  }

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
                    doctor.department.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    doctor.employeeId.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ),
              )
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
      case 'department':
        filtered.sort((a, b) => a.department.compareTo(b.department));
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
      floatingActionButton: _buildAddDoctorFAB(),
    );
  }

  Widget _buildAddDoctorFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddDoctorScreen()),
          );
        },
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Doctor',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
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
                  'Doctors Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showFilterPanel = !_showFilterPanel;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.filter_list,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 16),
          _buildQuickFilters(),
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
            color: Colors.black.withValues(alpha: 0.1),
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
                hintText: 'Search doctors, departments, employee ID...',
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
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: quickFilters.length,
        itemBuilder: (context, index) {
          final filter = quickFilters[index];
          final isSelected = _selectedSpecialty == filter['value'];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSpecialty = filter['value'] as String;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient:
                      isSelected
                          ? const LinearGradient(
                            colors: [Colors.white, Color(0xFFF8FAFC)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                          : null,
                  color:
                      isSelected ? null : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected
                            ? const Color(0xFF667EEA)
                            : Colors.white.withValues(alpha: 0.3),
                  ),
                  boxShadow:
                      isSelected
                          ? [
                            BoxShadow(
                              color: const Color(
                                0xFF667EEA,
                              ).withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      filter['icon'] as IconData,
                      size: 16,
                      color:
                          isSelected ? const Color(0xFF667EEA) : Colors.white,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      filter['label'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isSelected ? const Color(0xFF667EEA) : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
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
              'Try adjusting your search or filters',
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
        children: [
          Row(
            children: [
              // Doctor Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF667EEA).withValues(alpha: 0.1),
                      const Color(0xFF764BA2).withValues(alpha: 0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                  ),
                ),
                child:
                    doctor.imageUrl != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(25),
                          child: Image.network(
                            doctor.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: Color(0xFF667EEA),
                                size: 24,
                              );
                            },
                          ),
                        )
                        : const Icon(
                          Icons.person,
                          color: Color(0xFF667EEA),
                          size: 24,
                        ),
              ),
              const SizedBox(width: 12),

              // Doctor Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color:
                                doctor.isAvailable
                                    ? const Color(0xFF3B82F6)
                                    : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.specialization,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF667EEA),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ID: ${doctor.employeeId} • ${doctor.department}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Stats Row
          Row(
            children: [
              _buildStatItem(Icons.star, '${doctor.rating}', Colors.amber),
              const SizedBox(width: 16),
              _buildStatItem(
                Icons.work,
                '${doctor.experience}y',
                const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                Icons.people,
                '${doctor.reviewCount}',
                const Color(0xFF10B981),
              ),
              const Spacer(),
              Text(
                doctor.isAvailable ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                      doctor.isAvailable ? const Color(0xFF3B82F6) : Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

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
                            (context) =>
                                DoctorDetailHospitalScreen(doctor: doctor),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
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
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _showDoctorActions(doctor);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'Manage',
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showDoctorActions(DoctorInfo doctor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Manage ${doctor.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Icon(
                    doctor.isAvailable ? Icons.toggle_on : Icons.toggle_off,
                    color:
                        doctor.isAvailable
                            ? const Color(0xFF3B82F6)
                            : Colors.red,
                    size: 28,
                  ),
                  title: Text(
                    doctor.isAvailable ? 'Set Inactive' : 'Set Active',
                  ),
                  subtitle: Text(
                    doctor.isAvailable
                        ? 'Doctor is currently active'
                        : 'Doctor is currently inactive',
                    style: TextStyle(
                      color:
                          doctor.isAvailable
                              ? const Color(0xFF3B82F6)
                              : Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _toggleDoctorStatus(doctor);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit, color: Color(0xFF3B82F6)),
                  title: const Text('Edit Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Edit ${doctor.name} profile')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.schedule, color: Color(0xFF10B981)),
                  title: const Text('Manage Schedule'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Manage ${doctor.name} schedule')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.assignment,
                    color: Color(0xFFF59E0B),
                  ),
                  title: const Text('View Assignments'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('View ${doctor.name} assignments'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Doctor'),
                  onTap: () {
                    Navigator.pop(context);
                    _showRemoveConfirmation(doctor);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  void _toggleDoctorStatus(DoctorInfo doctor) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              doctor.isAvailable ? 'Set Doctor Inactive' : 'Set Doctor Active',
            ),
            content: Text(
              doctor.isAvailable
                  ? 'Are you sure you want to set ${doctor.name} as inactive? Patients won\'t be able to book appointments.'
                  : 'Are you sure you want to set ${doctor.name} as active? Patients will be able to book appointments.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  // Use the service to toggle status
                  final success = await _doctorService.toggleDoctorStatus(
                    doctor.employeeId,
                  );

                  navigator.pop();

                  if (success) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          '${doctor.name} is now ${!doctor.isAvailable ? 'Active' : 'Inactive'}',
                        ),
                        backgroundColor:
                            !doctor.isAvailable
                                ? const Color(0xFF3B82F6)
                                : Colors.red,
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update doctor status'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor:
                      doctor.isAvailable ? Colors.red : const Color(0xFF3B82F6),
                ),
                child: Text(doctor.isAvailable ? 'Set Inactive' : 'Set Active'),
              ),
            ],
          ),
    );
  }

  void _showRemoveConfirmation(DoctorInfo doctor) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Remove Doctor'),
            content: Text(
              'Are you sure you want to remove ${doctor.name} from the hospital?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${doctor.name} removed successfully'),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }
}
