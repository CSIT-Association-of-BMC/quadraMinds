# Hospital Main Module

This folder contains all hospital-related screens and functionality for the Swasthya Setu application.

## Folder Structure

```
hospital_main/
├── README.md                          # This documentation file
├── home/                              # Hospital home screens
│   └── home_screen_hospital.dart      # Main hospital dashboard
├── appointments/                      # Hospital appointment management (future)
├── patients/                          # Patient management screens (future)
├── staff/                            # Staff management screens (future)
├── reports/                          # Hospital reports and analytics (future)
├── profile/                          # Hospital profile management (future)
└── settings/                         # Hospital settings screens (future)
```

## Current Implementation

### Home Screen (`home/home_screen_hospital.dart`)
- **Purpose**: Main dashboard for hospital users
- **Features**:
  - Welcome section with hospital name
  - Dashboard statistics (patients, appointments, revenue)
  - Quick action buttons for key functions
  - Recent activity feed
  - Bottom navigation bar
  - Profile menu with logout functionality

- **Key Components**:
  - Stats cards showing key metrics
  - Quick action buttons for navigation
  - Activity timeline
  - Professional Material Design theme
  - Fade animations for smooth UX

## Navigation Flow

1. **Login** → Hospital users are authenticated and redirected to `HomeScreenHospital`
2. **Dashboard** → Central hub with overview and quick actions
3. **Future Modules** → Will be organized in respective subfolders

## Design Principles

- **Consistent Theming**: Uses blue color scheme (`#1E40AF`, `#3B82F6`) for hospital branding
- **Material Design**: Follows Material Design 3 guidelines
- **Responsive Layout**: Adapts to different screen sizes
- **Accessibility**: Proper contrast ratios and touch targets
- **Animation**: Smooth fade transitions for better UX

## Future Development

The following modules are planned for implementation:

1. **Appointments Management** (`appointments/`)
   - View and manage hospital appointments
   - Schedule management
   - Patient appointment history

2. **Patient Management** (`patients/`)
   - Patient records and history
   - Medical records management
   - Patient communication

3. **Staff Management** (`staff/`)
   - Doctor and staff profiles
   - Schedule management
   - Role-based access control

4. **Reports & Analytics** (`reports/`)
   - Hospital performance metrics
   - Financial reports
   - Patient statistics

5. **Profile Management** (`profile/`)
   - Hospital profile editing
   - Contact information
   - Specializations management

6. **Settings** (`settings/`)
   - Hospital preferences
   - Notification settings
   - System configuration

## Usage

To navigate to the hospital home screen:

```dart
Navigator.pushAndRemoveUntil(
  context,
  FadeSlidePageRoute(
    child: HomeScreenHospital(hospitalUser: hospitalUser),
  ),
  (route) => false,
);
```

## Dependencies

- `flutter/material.dart` - Material Design components
- `../../../models/user_models.dart` - HospitalUser model
- `../../../services/auth_service.dart` - Authentication services
- `../../../utils/page_transitions.dart` - Custom page transitions

## Notes

- All hospital-related functionality should be placed within this `hospital_main` folder
- Follow the established naming conventions and folder structure
- Maintain consistency with the existing design system
- Use the HospitalUser model for user data management
