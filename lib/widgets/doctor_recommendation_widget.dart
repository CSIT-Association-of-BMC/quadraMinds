import 'package:flutter/material.dart';
import '../services/doctor_service.dart';
import '../screens/client_doctor/doctor_detail_screen.dart';

class DoctorRecommendationWidget extends StatelessWidget {
  final String specialization;
  final String context;

  const DoctorRecommendationWidget({
    super.key,
    required this.specialization,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    final doctorService = DoctorService();
    doctorService.initialize();
    
    // Get doctors by specialization
    final allDoctors = doctorService.getActiveDoctors();
    final specialistDoctors = allDoctors
        .where((doctor) => doctor.specialization.toLowerCase().contains(specialization.toLowerCase()))
        .toList();

    if (specialistDoctors.isEmpty) {
      return _buildNoSpecialistsFound();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF667EEA).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_hospital,
                color: const Color(0xFF667EEA),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Recommended $specialization${specialistDoctors.length > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...specialistDoctors.take(3).map((doctor) => _buildDoctorCard(context, doctor)),
          if (specialistDoctors.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () => _showAllDoctors(context, specialistDoctors),
                child: Text(
                  'View all ${specialistDoctors.length} ${specialization.toLowerCase()}s',
                  style: const TextStyle(
                    color: Color(0xFF667EEA),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoSpecialistsFound() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFFF59E0B),
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No $specialization currently available. Please check back later.',
              style: const TextStyle(
                color: Color(0xFF92400E),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, DoctorInfo doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        onTap: () => _navigateToDoctorDetail(context, doctor),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFF667EEA).withValues(alpha: 0.1),
              child: Text(
                doctor.name.split(' ').map((n) => n[0]).take(2).join(),
                style: const TextStyle(
                  color: Color(0xFF667EEA),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doctor.hospital,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                        color: Colors.amber[600],
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${doctor.rating}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${doctor.experience} yrs',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Rs. ${doctor.consultationFee}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: const Color(0xFF6B7280),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDoctorDetail(BuildContext context, DoctorInfo doctor) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorDetailScreen(doctor: doctor),
      ),
    );
  }

  void _showAllDoctors(BuildContext context, List<DoctorInfo> doctors) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                  Text(
                    'All ${specialization}s',
                    style: const TextStyle(
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
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  return _buildDoctorCard(context, doctors[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
