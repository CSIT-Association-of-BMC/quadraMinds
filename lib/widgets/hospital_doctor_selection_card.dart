import 'package:flutter/material.dart';

class HospitalDoctorSelectionCard extends StatelessWidget {
  final VoidCallback? onHospitalTap;
  final VoidCallback? onDoctorTap;

  const HospitalDoctorSelectionCard({
    super.key,
    this.onHospitalTap,
    this.onDoctorTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Available Services Header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(
            'Available Services',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Service Cards Container
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
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
              // Hospital Section
              Expanded(
                child: GestureDetector(
                  onTap: onHospitalTap,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF0FDF4), // Light green background
                          Color(0xFFE6FFFA), // Very light mint
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                      border: Border.all(
                        color: const Color(0xFF2E7D32).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF2E7D32), Color(0xFF388E3C)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF2E7D32,
                                ).withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.local_hospital,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Hospital',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Find nearby hospitals',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Divider
              Container(
                width: 2,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF2E7D32), Color(0xFF0EA5E9)],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),

              // Doctor Section
              Expanded(
                child: GestureDetector(
                  onTap: onDoctorTap,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF0F9FF), // Light blue background
                          Color(0xFFEFF6FF), // Very light blue
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      border: Border.all(
                        color: const Color(0xFF0EA5E9).withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF0EA5E9), Color(0xFF0284C7)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFF0EA5E9,
                                ).withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.medical_services,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Doctor',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Consult with doctors',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF0284C7),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
