import 'package:flutter/material.dart';
import '../../models/user_models.dart';

class ClientRecordsScreen extends StatefulWidget {
  final ClientUser? clientUser;

  const ClientRecordsScreen({super.key, this.clientUser});

  @override
  State<ClientRecordsScreen> createState() => _ClientRecordsScreenState();
}

class _ClientRecordsScreenState extends State<ClientRecordsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMedicalHistoryTab(),
                _buildPrescriptionsTab(),
                _buildLabResultsTab(),
                _buildAppointmentHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Color(0xFF1F2937),
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Health Records',
        style: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Color(0xFF1F2937), size: 22),
          onPressed: () {
            // Implement search functionality
            _showSearchDialog();
          },
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: const Color(0xFF667EEA),
        indicatorWeight: 3,
        labelColor: const Color(0xFF667EEA),
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'Medical History'),
          Tab(text: 'Prescriptions'),
          Tab(text: 'Lab Results'),
          Tab(text: 'Appointments'),
        ],
      ),
    );
  }

  Widget _buildMedicalHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Recent Medical Records', Icons.medical_services),
          const SizedBox(height: 12),
          _buildMedicalRecordCard(
            date: 'Dec 15, 2024',
            doctor: 'Dr. Sarah Johnson',
            hospital: 'City General Hospital',
            diagnosis: 'Routine Health Checkup',
            notes: 'All vital signs normal. Blood pressure: 120/80 mmHg',
            type: 'Checkup',
          ),
          const SizedBox(height: 12),
          _buildMedicalRecordCard(
            date: 'Nov 28, 2024',
            doctor: 'Dr. Michael Chen',
            hospital: 'Metro Medical Center',
            diagnosis: 'Seasonal Allergies',
            notes: 'Prescribed antihistamines. Follow-up in 2 weeks.',
            type: 'Treatment',
          ),
          const SizedBox(height: 12),
          _buildMedicalRecordCard(
            date: 'Oct 10, 2024',
            doctor: 'Dr. Emily Davis',
            hospital: 'Wellness Clinic',
            diagnosis: 'Annual Physical Exam',
            notes: 'Recommended dietary changes and regular exercise.',
            type: 'Checkup',
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Active Prescriptions', Icons.medication),
          const SizedBox(height: 12),
          _buildPrescriptionCard(
            medication: 'Amoxicillin 500mg',
            doctor: 'Dr. Michael Chen',
            dosage: '1 tablet twice daily',
            duration: '7 days',
            startDate: 'Nov 28, 2024',
            isActive: true,
          ),
          const SizedBox(height: 12),
          _buildPrescriptionCard(
            medication: 'Vitamin D3 1000 IU',
            doctor: 'Dr. Sarah Johnson',
            dosage: '1 tablet daily',
            duration: '30 days',
            startDate: 'Dec 15, 2024',
            isActive: true,
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Past Prescriptions', Icons.history),
          const SizedBox(height: 12),
          _buildPrescriptionCard(
            medication: 'Ibuprofen 400mg',
            doctor: 'Dr. Emily Davis',
            dosage: '1 tablet as needed',
            duration: '5 days',
            startDate: 'Oct 10, 2024',
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildLabResultsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Recent Lab Results', Icons.science),
          const SizedBox(height: 12),
          _buildLabResultCard(
            testName: 'Complete Blood Count (CBC)',
            date: 'Dec 10, 2024',
            hospital: 'City General Hospital',
            status: 'Normal',
            results: {
              'Hemoglobin': '14.2 g/dL',
              'White Blood Cells': '7,200/μL',
              'Platelets': '250,000/μL',
            },
          ),
          const SizedBox(height: 12),
          _buildLabResultCard(
            testName: 'Lipid Profile',
            date: 'Nov 20, 2024',
            hospital: 'Metro Medical Center',
            status: 'Attention Required',
            results: {
              'Total Cholesterol': '220 mg/dL',
              'HDL Cholesterol': '45 mg/dL',
              'LDL Cholesterol': '140 mg/dL',
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Upcoming Appointments', Icons.calendar_today),
          const SizedBox(height: 12),
          _buildAppointmentCard(
            doctor: 'Dr. Sarah Johnson',
            specialty: 'General Medicine',
            hospital: 'City General Hospital',
            date: 'Dec 22, 2024',
            time: '10:00 AM',
            status: 'Confirmed',
            isUpcoming: true,
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Past Appointments', Icons.history),
          const SizedBox(height: 12),
          _buildAppointmentCard(
            doctor: 'Dr. Michael Chen',
            specialty: 'Allergy & Immunology',
            hospital: 'Metro Medical Center',
            date: 'Nov 28, 2024',
            time: '2:30 PM',
            status: 'Completed',
            isUpcoming: false,
          ),
          const SizedBox(height: 12),
          _buildAppointmentCard(
            doctor: 'Dr. Emily Davis',
            specialty: 'Internal Medicine',
            hospital: 'Wellness Clinic',
            date: 'Oct 10, 2024',
            time: '11:15 AM',
            status: 'Completed',
            isUpcoming: false,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF667EEA), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalRecordCard({
    required String date,
    required String doctor,
    required String hospital,
    required String diagnosis,
    required String notes,
    required String type,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      type == 'Checkup'
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        type == 'Checkup'
                            ? const Color(0xFF10B981)
                            : const Color(0xFF3B82F6),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            diagnosis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(
                doctor,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(
                hospital,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              notes,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF374151),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard({
    required String medication,
    required String doctor,
    required String dosage,
    required String duration,
    required String startDate,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            isActive
                ? Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                )
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : const Color(0xFF6B7280).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.medication,
                  color:
                      isActive
                          ? const Color(0xFF10B981)
                          : const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'Prescribed by $doctor',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : const Color(0xFF6B7280).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isActive ? 'Active' : 'Completed',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        isActive
                            ? const Color(0xFF10B981)
                            : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildPrescriptionDetail('Dosage', dosage)),
              Expanded(child: _buildPrescriptionDetail('Duration', duration)),
            ],
          ),
          const SizedBox(height: 8),
          _buildPrescriptionDetail('Start Date', startDate),
        ],
      ),
    );
  }

  Widget _buildPrescriptionDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLabResultCard({
    required String testName,
    required String date,
    required String hospital,
    required String status,
    required Map<String, String> results,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.science,
                  color: Color(0xFF3B82F6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      hospital,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      status == 'Normal'
                          ? const Color(0xFF10B981).withValues(alpha: 0.1)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color:
                        status == 'Normal'
                            ? const Color(0xFF10B981)
                            : const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            date,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children:
                  results.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF374151),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF1F2937),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard({
    required String doctor,
    required String specialty,
    required String hospital,
    required String date,
    required String time,
    required String status,
    required bool isUpcoming,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border:
            isUpcoming
                ? Border.all(
                  color: const Color(0xFF667EEA).withValues(alpha: 0.3),
                )
                : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isUpcoming
                          ? const Color(0xFF667EEA).withValues(alpha: 0.1)
                          : const Color(0xFF10B981).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isUpcoming ? Icons.schedule : Icons.check_circle,
                  color:
                      isUpcoming
                          ? const Color(0xFF667EEA)
                          : const Color(0xFF10B981),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      specialty,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 4),
              Text(
                hospital,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 4),
              Text(
                '$date at $time',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF667EEA);
      case 'completed':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Search Records'),
            content: const TextField(
              decoration: InputDecoration(
                hintText: 'Search by doctor, hospital, or diagnosis...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Implement search functionality
                },
                child: const Text('Search'),
              ),
            ],
          ),
    );
  }
}
