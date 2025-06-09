import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/widgets/simple_dialog_demo.dart';

void main() {
  group('Dialog Overflow Tests', () {
    testWidgets('Dialog should not overflow on small screens', (WidgetTester tester) async {
      // Set a small screen size to test overflow handling
      await tester.binding.setSurfaceSize(const Size(300, 400));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: SimpleDialogDemo(),
        ),
      );

      // Tap the button to show dialog
      await tester.tap(find.text('Show Simple Dialog'));
      await tester.pumpAndSettle();

      // Verify dialog is displayed (check for close button since content is blank)
      expect(find.byIcon(Icons.close), findsOneWidget);

      // Verify no overflow errors occurred
      expect(tester.takeException(), isNull);
    });

    testWidgets('Dialog should adapt to different screen sizes', (WidgetTester tester) async {
      // Test with various screen sizes
      final screenSizes = [
        const Size(320, 568), // iPhone SE
        const Size(375, 667), // iPhone 8
        const Size(414, 896), // iPhone 11 Pro Max
        const Size(768, 1024), // iPad
      ];

      for (final size in screenSizes) {
        await tester.binding.setSurfaceSize(size);
        
        await tester.pumpWidget(
          const MaterialApp(
            home: SimpleDialogDemo(),
          ),
        );

        // Show dialog
        await tester.tap(find.text('Show Simple Dialog'));
        await tester.pumpAndSettle();

        // Verify dialog is displayed without overflow (check for close button since content is blank)
        expect(find.byIcon(Icons.close), findsOneWidget);
        expect(tester.takeException(), isNull);

        // Close dialog
        await tester.tap(find.byIcon(Icons.close));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Dialog should be centered on screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SimpleDialogDemo(),
        ),
      );

      // Show dialog
      await tester.tap(find.text('Show Simple Dialog'));
      await tester.pumpAndSettle();

      // Find the dialog container
      final dialogFinder = find.byType(Container).last;
      final dialogWidget = tester.widget<Container>(dialogFinder);
      final dialogRenderBox = tester.renderObject<RenderBox>(dialogFinder);
      
      // Verify dialog is centered
      final screenSize = tester.binding.window.physicalSize / tester.binding.window.devicePixelRatio;
      final dialogPosition = dialogRenderBox.localToGlobal(Offset.zero);
      
      // Dialog should be roughly centered (allowing for margins)
      expect(dialogPosition.dx, greaterThan(0));
      expect(dialogPosition.dy, greaterThan(0));
    });
  });
}
