# QSO Log - Amateur Radio Logging App

A production-grade iPhone/iPad app for amateur (ham) radio operators to log QSOs quickly, view statistics, and export/import logs. Built with Swift 5.9+, SwiftUI, Core Data with CloudKit sync, and MVVM architecture.

## Features

### 🚀 Fast QSO Logging
- **Quick Log Entry**: Log QSOs in under 5 seconds with minimal required fields
- **Smart Defaults**: Pre-filled fields based on station profiles and recent activity
- **Haptic Feedback**: Tactile confirmation for successful QSO saves
- **Save & New**: Rapid consecutive logging workflow

### 📊 Comprehensive Log Management
- **Browse & Search**: Filter by band, mode, date range, callsign, DXCC, grid
- **Advanced Filtering**: Multiple filter combinations with real-time results
- **Swipe Actions**: Quick edit, duplicate, delete, and QSL status updates
- **Detailed Views**: Complete QSO information with edit capabilities

### 📈 Analytics & Statistics
- **Activity Overview**: Daily/weekly QSO counts and trends
- **Band & Mode Analysis**: Visual charts showing usage patterns
- **QSL Tracking**: Sent/received statistics with completion rates
- **DXCC Progress**: Track entities worked and confirmed
- **Performance Metrics**: Unique callsigns, streaks, and achievements

### 🔄 Import/Export
- **ADIF Support**: Full ADIF v3.x import/export compatibility
- **Duplicate Handling**: Smart conflict resolution for imported QSOs
- **Multiple Formats**: ADIF and CSV export options
- **Share Integration**: Export to Files, Drive, Email, or other apps

### 🏠 Station Profiles
- **Multiple Stations**: Save configurations for home, portable, mobile setups
- **Smart Defaults**: Auto-fill band, mode, power, and equipment
- **Equipment Tracking**: Rig, antenna, and operator information
- **Profile Switching**: Quick station selection during logging

### ☁️ Cloud Sync & Privacy
- **iCloud Integration**: Automatic sync across devices
- **Offline-First**: Full functionality without internet connection
- **Local-Only Option**: Keep data strictly on device if preferred
- **Privacy Focused**: No tracking, no third-party analytics

## Architecture

### Technology Stack
- **Swift 5.9+**: Latest Swift language features
- **SwiftUI**: Modern declarative UI framework
- **Core Data**: Robust data persistence with CloudKit integration
- **MVVM**: Clean separation of concerns
- **CloudKit**: Seamless iCloud synchronization

### Data Model
- **QSO Entity**: Complete QSO information with all standard fields
- **StationProfile Entity**: Station configurations and defaults
- **AppSettings Entity**: User preferences and app configuration

### Key Components
- **QSOViewModel**: Main business logic and data management
- **ADIFService**: Import/export functionality
- **PersistenceController**: Core Data and CloudKit management
- **BandModeCatalog**: Standard amateur radio bands and modes

## Installation & Setup

### Requirements
- iOS 17.0+ / iPadOS 17.0+
- Xcode 15.0+
- Apple Developer Account (for CloudKit)

### Build Instructions
1. Clone the repository
2. Open `RadioApp.xcodeproj` in Xcode
3. Configure your Team ID in project settings
4. Update CloudKit container identifier in `Persistence.swift`
5. Build and run on device or simulator

### CloudKit Setup
1. Enable CloudKit in your Apple Developer account
2. Create a CloudKit container
3. Update the container identifier in the code
4. Configure entitlements for CloudKit access

## Usage Guide

### Quick QSO Logging
1. Tap the "Log QSO" button on the home screen
2. Enter the callsign (auto-uppercase)
3. Select band and mode from pickers
4. Adjust RST reports if needed
5. Set power output
6. Choose station profile
7. Tap "Save & New" for rapid logging

### Browsing Logs
1. Navigate to the Browse tab
2. Use search bar for callsign, grid, or DXCC
3. Apply filters using the filter chips
4. Swipe on QSOs for quick actions
5. Tap QSOs for detailed view and editing

### Analytics
1. View the Analytics tab for statistics
2. Scroll through different chart types
3. Pull to refresh for latest data
4. Tap charts for detailed breakdowns

### Station Management
1. Go to Settings → Station Profiles
2. Add new stations with equipment details
3. Set default values for quick logging
4. Mark one station as default

### Import/Export
1. Settings → Import/Export
2. Export ADIF files for backup or sharing
3. Import ADIF files from other logging software
4. Handle duplicates during import

## Data Fields

### Required QSO Fields
- **Callsign**: Station callsign (auto-uppercase)
- **Date/Time**: QSO timestamp
- **Band**: Operating frequency band
- **Mode**: Operating mode (SSB, CW, FT8, etc.)

### Optional QSO Fields
- **Frequency**: Exact frequency in MHz
- **RST Reports**: Signal reports sent/received
- **Power**: Transmitter power in watts
- **Grid Square**: Maidenhead grid locator
- **DXCC**: Country/entity
- **QTH**: Location description
- **Equipment**: Rig, antenna, operator
- **Contest**: Contest name and serial numbers
- **QSL**: Confirmation status and method
- **Notes**: Additional information

## Privacy & Security

### Data Protection
- All data stored locally on device
- Optional iCloud sync to private database
- No data collection or tracking
- No third-party analytics
- Local-only mode available

### CloudKit Security
- Private database for user data
- End-to-end encryption
- Apple's privacy standards compliance
- User controls sync preferences

## Future Enhancements

### Planned Features
- **Callsign Lookup**: Integration with HamQTH/QRZ APIs
- **LoTW/eQSL Sync**: Automatic status updates
- **Contest Mode**: Specialized contest logging
- **Grid Mapping**: Visual map of QSOs by location
- **Advanced Analytics**: More detailed statistics and trends
- **Custom Fields**: User-defined additional fields
- **Backup/Restore**: Enhanced data management

### Monetization
- **Free Version**: Core functionality with ads
- **Pro Version** (₹399): 
  - Unlimited station profiles
  - Advanced analytics
  - Contest helpers
  - Custom export presets
  - Priority support

## Contributing

### Development Guidelines
- Follow Swift style guidelines
- Use SwiftUI best practices
- Maintain MVVM architecture
- Add unit tests for new features
- Document public APIs

### Testing
- Test on multiple device sizes
- Verify CloudKit sync functionality
- Test offline scenarios
- Validate ADIF import/export
- Performance testing with large datasets

## Support

### Documentation
- In-app help and tutorials
- User guide in Settings
- Online documentation
- Video tutorials

### Contact
- In-app feedback form
- Email support
- Community forums
- Bug reporting system

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Amateur radio community for feedback and testing
- ADIF specification maintainers
- SwiftUI and Core Data documentation teams
- Open source contributors and libraries

---

**QSO Log** - Making amateur radio logging fast, efficient, and enjoyable since 2024.
