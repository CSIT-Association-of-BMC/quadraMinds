import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/user_models.dart';
import '../../../models/appointment_models.dart';
import '../../../utils/page_transitions.dart';

class HospitalAppointmentsScreen extends StatefulWidget {
  final HospitalUser? hospitalUser;

  const HospitalAppointmentsScreen({super.key, this.hospitalUser});

  @override
  State<HospitalAppointmentsScreen> createState() =>
      _HospitalAppointmentsScreenState();
}

class _HospitalAppointmentsScreenState extends State<HospitalAppointmentsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Pending',
    'Confirmed',
    'Completed',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    super.dispose();
  }

  // Dummy appointment data
  List<AppointmentBooking> get _dummyAppointments => [
    AppointmentBooking(
      id: '1',
      hospitalName:
          widget.hospitalUser?.hospitalName ?? 'Lumbini Medical College',
      hospitalLocation: 'Palpa Road, Butwal',
      patientName: 'Rajesh Kumar Sharma',
      phoneNumber: '+977-9841234567',
      appointmentDate: DateTime.now().add(const Duration(days: 1)),
      timeSlot: '10:00 AM - 10:30 AM',
      doctorName: 'Dr. Sita Devi Poudel',
      consultationFee: 800.0,
      bookingFee: 50.0,
      totalAmount: 850.0,
      status: AppointmentStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    AppointmentBooking(
      id: '2',
      hospitalName:
          widget.hospitalUser?.hospitalName ?? 'Lumbini Medical College',
      hospitalLocation: 'Palpa Road, Butwal',
      patientName: 'Maya Gurung',
      phoneNumber: '+977-9876543210',
      appointmentDate: DateTime.now().add(const Duration(days: 2)),
      timeSlot: '2:00 PM - 2:30 PM',
      doctorName: 'Dr. Ram Bahadur Thapa',
      consultationFee: 1000.0,
      bookingFee: 50.0,
      totalAmount: 1050.0,
      status: AppointmentStatus.confirmed,
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AppointmentBooking(
      id: '3',
      hospitalName:
          widget.hospitalUser?.hospitalName ?? 'Lumbini Medical College',
      hospitalLocation: 'Palpa Road, Butwal',
      patientName: 'Arjun Bahadur Magar',
      phoneNumber: '+977-9812345678',
      appointmentDate: DateTime.now().subtract(const Duration(days: 1)),
      timeSlot: '11:00 AM - 11:30 AM',
      doctorName: 'Dr. Kamala Devi Shrestha',
      consultationFee: 600.0,
      bookingFee: 50.0,
      totalAmount: 650.0,
      status: AppointmentStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    AppointmentBooking(
      id: '4',
      hospitalName:
          widget.hospitalUser?.hospitalName ?? 'Lumbini Medical College',
      hospitalLocation: 'Palpa Road, Butwal',
      patientName: 'Sunita Rai',
      phoneNumber: '+977-9823456789',
      appointmentDate: DateTime.now().add(const Duration(days: 3)),
      timeSlot: '9:00 AM - 9:30 AM',
      doctorName: 'Dr. Bishnu Prasad Adhikari',
      consultationFee: 1200.0,
      bookingFee: 50.0,
      totalAmount: 1250.0,
      status: AppointmentStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    AppointmentBooking(
      id: '5',
      hospitalName:
          widget.hospitalUser?.hospitalName ?? 'Lumbini Medical College',
      hospitalLocation: 'Palpa Road, Butwal',
      patientName: 'Dipak Oli',
      phoneNumber: '+977-9834567890',
      appointmentDate: DateTime.now().add(const Duration(days: 1)),
      timeSlot: '4:00 PM - 4:30 PM',
      doctorName: 'Dr. Gita Sharma',
      consultationFee: 900.0,
      bookingFee: 50.0,
      totalAmount: 950.0,
      status: AppointmentStatus.cancelled,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  List<AppointmentBooking> get _filteredAppointments {
    if (_selectedFilter == 'All') {
      return _dummyAppointments;
    }
    return _dummyAppointments.where((appointment) {
      return appointment.status.toString().split('.').last.toLowerCase() ==
          _selectedFilter.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            _buildFilterSection(),
            _buildStatsCards(),
            Expanded(child: _buildAppointmentsList()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Hospital Appointments',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // TODO: Implement search functionality
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: () {
            // TODO: Implement advanced filter
          },
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children:
              _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient:
                          isSelected
                              ? const LinearGradient(
                                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              )
                              : null,
                      color: isSelected ? null : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isSelected
                                ? const Color(0xFF667EEA)
                                : Colors.grey[300]!,
                      ),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF667EEA,
                                  ).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : null,
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalAppointments = _dummyAppointments.length;
    final pendingCount =
        _dummyAppointments
            .where((a) => a.status == AppointmentStatus.pending)
            .length;
    final confirmedCount =
        _dummyAppointments
            .where((a) => a.status == AppointmentStatus.confirmed)
            .length;
    final completedCount =
        _dummyAppointments
            .where((a) => a.status == AppointmentStatus.completed)
            .length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Total',
              totalAppointments.toString(),
              const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Pending',
              pendingCount.toString(),
              const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Confirmed',
              confirmedCount.toString(),
              const Color(0xFF10B981),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Completed',
              completedCount.toString(),
              const Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.white, Color(0xFFFAFBFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentsList() {
    final filteredAppointments = _filteredAppointments;

    if (filteredAppointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Appointments will appear here when clients book them',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredAppointments.length,
      itemBuilder: (context, index) {
        final appointment = filteredAppointments[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  Widget _buildAppointmentCard(AppointmentBooking appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(appointment.status).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appointment #${appointment.id}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusText(appointment.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(Icons.person, 'Patient', appointment.patientName),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.phone, 'Phone', appointment.phoneNumber),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.medical_services,
                  'Doctor',
                  appointment.doctorName ?? 'Not assigned',
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Date',
                  DateFormat(
                    'MMM dd, yyyy',
                  ).format(appointment.appointmentDate),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(Icons.access_time, 'Time', appointment.timeSlot),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.attach_money,
                  'Total Amount',
                  'Rs. ${appointment.totalAmount.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'View Details',
                        const Color(0xFF3B82F6),
                        () => _viewAppointmentDetails(appointment),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        _getActionButtonText(appointment.status),
                        _getStatusColor(appointment.status),
                        () => _updateAppointmentStatus(appointment),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return const Color(0xFFF59E0B);
      case AppointmentStatus.confirmed:
        return const Color(0xFF10B981);
      case AppointmentStatus.completed:
        return const Color(0xFF8B5CF6);
      case AppointmentStatus.cancelled:
        return const Color(0xFFEF4444);
    }
  }

  String _getStatusText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _getActionButtonText(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.pending:
        return 'Confirm';
      case AppointmentStatus.confirmed:
        return 'Complete';
      case AppointmentStatus.completed:
        return 'View Report';
      case AppointmentStatus.cancelled:
        return 'Reschedule';
    }
  }

  void _viewAppointmentDetails(AppointmentBooking appointment) {
    // TODO: Navigate to appointment details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${appointment.patientName}')),
    );
  }

  void _updateAppointmentStatus(AppointmentBooking appointment) {
    // TODO: Implement status update logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Updating status for ${appointment.patientName}')),
    );
  }
}
