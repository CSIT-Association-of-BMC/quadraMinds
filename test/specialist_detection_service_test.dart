import 'package:flutter_test/flutter_test.dart';
import 'package:swasthya_setu/services/specialist_detection_service.dart';

void main() {
  group('SpecialistDetectionService Tests', () {
    test('should detect cardiologist mentions', () {
      expect(
        SpecialistDetectionService.detectSpecialist('You should consult a cardiologist'),
        equals('Cardiologist'),
      );
      
      expect(
        SpecialistDetectionService.detectSpecialist('Visit a heart doctor immediately'),
        equals('Cardiologist'),
      );
      
      expect(
        SpecialistDetectionService.detectSpecialist('मुटुको डाक्टर देखाउनुस्'),
        equals('Cardiologist'),
      );
    });

    test('should detect dermatologist mentions', () {
      expect(
        SpecialistDetectionService.detectSpecialist('See a dermatologist for skin issues'),
        equals('Dermatologist'),
      );
      
      expect(
        SpecialistDetectionService.detectSpecialist('छालाको डाक्टर देखाउनुस्'),
        equals('Dermatologist'),
      );
    });

    test('should detect neurologist mentions', () {
      expect(
        SpecialistDetectionService.detectSpecialist('Consult a neurologist for headaches'),
        equals('Neurologist'),
      );
      
      expect(
        SpecialistDetectionService.detectSpecialist('दिमागको डाक्टर देखाउनुस्'),
        equals('Neurologist'),
      );
    });

    test('should return null for non-specialist text', () {
      expect(
        SpecialistDetectionService.detectSpecialist('Take rest and drink water'),
        isNull,
      );
      
      expect(
        SpecialistDetectionService.detectSpecialist('This is just normal text'),
        isNull,
      );
    });

    test('should extract specialist recommendation with context', () {
      final result = SpecialistDetectionService.extractSpecialistRecommendation(
        'You have chest pain. Consult a cardiologist immediately. Take care.',
      );
      
      expect(result, isNotNull);
      expect(result!['specialist'], equals('Cardiologist'));
      expect(result['context'], contains('cardiologist'));
    });

    test('should check if text contains specialist mention', () {
      expect(
        SpecialistDetectionService.containsSpecialistMention('See a dermatologist'),
        isTrue,
      );
      
      expect(
        SpecialistDetectionService.containsSpecialistMention('Just rest well'),
        isFalse,
      );
    });

    test('should get all specializations', () {
      final specializations = SpecialistDetectionService.getAllSpecializations();
      expect(specializations, contains('Cardiologist'));
      expect(specializations, contains('Dermatologist'));
      expect(specializations, contains('Neurologist'));
    });
  });
}
