class SpecialistDetectionService {
  // Map of specialist keywords to standardized specialization names
  static const Map<String, String> _specialistKeywords = {
    // Cardiology
    'cardiologist': 'Cardiologist',
    'heart doctor': 'Cardiologist',
    'cardiac': 'Cardiologist',
    'cardiology': 'Cardiologist',
    
    // Dermatology
    'dermatologist': 'Dermatologist',
    'skin doctor': 'Dermatologist',
    'dermatology': 'Dermatologist',
    
    // Neurology
    'neurologist': 'Neurologist',
    'brain doctor': 'Neurologist',
    'neurology': 'Neurologist',
    'neuro': 'Neurologist',
    
    // Orthopedics
    'orthopedic': 'Orthopedic Surgeon',
    'orthopedist': 'Orthopedic Surgeon',
    'bone doctor': 'Orthopedic Surgeon',
    'joint doctor': 'Orthopedic Surgeon',
    'orthopedic surgeon': 'Orthopedic Surgeon',
    
    // Pediatrics
    'pediatrician': 'Pediatrician',
    'child doctor': 'Pediatrician',
    'pediatric': 'Pediatrician',
    'kids doctor': 'Pediatrician',
    
    // Gynecology
    'gynecologist': 'Gynecologist',
    'gyno': 'Gynecologist',
    'women doctor': 'Gynecologist',
    'gynecology': 'Gynecologist',
    
    // General Medicine
    'general physician': 'General Physician',
    'family doctor': 'General Physician',
    'gp': 'General Physician',
    
    // Psychiatry
    'psychiatrist': 'Psychiatrist',
    'mental health': 'Psychiatrist',
    'psychology': 'Psychiatrist',
    
    // Ophthalmology
    'eye doctor': 'Ophthalmologist',
    'ophthalmologist': 'Ophthalmologist',
    'eye specialist': 'Ophthalmologist',
    
    // ENT
    'ent': 'ENT Specialist',
    'ear nose throat': 'ENT Specialist',
    'throat doctor': 'ENT Specialist',
    
    // Nepali translations
    'मुटुको डाक्टर': 'Cardiologist',
    'छालाको डाक्टर': 'Dermatologist',
    'दिमागको डाक्टर': 'Neurologist',
    'हड्डीको डाक्टर': 'Orthopedic Surgeon',
    'बच्चाको डाक्टर': 'Pediatrician',
    'महिलाको डाक्टर': 'Gynecologist',
    'आँखाको डाक्टर': 'Ophthalmologist',
    
    // Romanized Nepali
    'mutuko doctor': 'Cardiologist',
    'chhala ko doctor': 'Dermatologist',
    'dimag ko doctor': 'Neurologist',
    'haddi ko doctor': 'Orthopedic Surgeon',
    'bachha ko doctor': 'Pediatrician',
    'mahila ko doctor': 'Gynecologist',
    'aankha ko doctor': 'Ophthalmologist',
  };

  /// Detects if the AI response mentions any specialist
  /// Returns the standardized specialization name if found, null otherwise
  static String? detectSpecialist(String aiResponse) {
    final lowercaseResponse = aiResponse.toLowerCase();
    
    for (final entry in _specialistKeywords.entries) {
      if (lowercaseResponse.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    
    return null;
  }

  /// Gets all possible specialist variations for a given specialization
  static List<String> getSpecialistVariations(String specialization) {
    return _specialistKeywords.entries
        .where((entry) => entry.value == specialization)
        .map((entry) => entry.key)
        .toList();
  }

  /// Gets all supported specializations
  static List<String> getAllSpecializations() {
    return _specialistKeywords.values.toSet().toList();
  }

  /// Checks if a text contains any medical specialist mention
  static bool containsSpecialistMention(String text) {
    return detectSpecialist(text) != null;
  }

  /// Extracts specialist recommendation with context
  static Map<String, String>? extractSpecialistRecommendation(String aiResponse) {
    final specialist = detectSpecialist(aiResponse);
    if (specialist == null) return null;

    // Find the sentence containing the specialist mention
    final sentences = aiResponse.split(RegExp(r'[.!?]'));
    String? context;
    
    for (final sentence in sentences) {
      if (detectSpecialist(sentence) != null) {
        context = sentence.trim();
        break;
      }
    }

    return {
      'specialist': specialist,
      'context': context ?? aiResponse,
    };
  }
}
