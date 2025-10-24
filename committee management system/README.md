# Committee Payment App

A comprehensive Flutter application for managing committee payments and memberships. This app allows users to create committees, invite members, track payments, and manage committee cycles.

## Features

### 🔐 Authentication
- **Sign Up**: Create new user accounts with email, phone, and password
- **Sign In**: Secure login with email and password
- **Session Management**: Persistent login sessions
- **Profile Management**: Update user profile information

### 👥 Committee Management
- **Create Committees**: Users can create new committees with:
  - Committee name and description
  - Total amount and maximum members
  - Start and end dates
  - Automatic creator membership
- **Browse Committees**: View all available committees
- **Join Committees**: Request to join committees or accept invitations
- **Committee Details**: View detailed information about committees

### 💰 Payment System
- **Payment Tracking**: Track payments made by each member
- **Receipt Upload**: Take photos of payment receipts
- **Payment Verification**: Committee creators can verify payments
- **Progress Tracking**: Visual progress bars showing payment status
- **Payment History**: View all payment transactions

### 📱 User Interface
- **Modern Design**: Clean, intuitive Material Design 3 interface
- **Bottom Navigation**: Easy navigation between main sections
- **Responsive Layout**: Works on different screen sizes
- **Real-time Updates**: Live data updates and refresh capabilities

### 🗄️ Data Management
- **SQLite Database**: Local database for storing all app data
- **CRUD Operations**: Complete Create, Read, Update, Delete functionality
- **Data Models**: Structured data models for users, committees, and payments

## App Structure

### Main Pages
1. **Browse Committees** - View and join available committees
2. **My Committees** - Manage joined committees and payments
3. **Create Committee** - Create new committees
4. **Settings** - User profile and app settings

### Database Schema
- **Users**: User account information
- **Committees**: Committee details and settings
- **Committee Members**: Member relationships and status
- **Payments**: Payment transactions and verification

## Getting Started

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation
1. Clone the repository
2. Navigate to the project directory
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

### Dependencies
- `sqflite`: SQLite database operations
- `path`: File path utilities
- `flutter_svg`: SVG image support
- `image_picker`: Camera and gallery access
- `provider`: State management
- `intl`: Internationalization and date formatting
- `shared_preferences`: Local storage
- `http`: HTTP requests
- `uuid`: Unique identifier generation

## Usage

### Creating a Committee
1. Sign up or sign in to your account
2. Navigate to "Create" tab
3. Fill in committee details:
   - Name and description
   - Total amount
   - Maximum number of members
   - Start and end dates
4. Tap "Create Committee"

### Joining a Committee
1. Go to "Browse" tab
2. Find a committee you want to join
3. Tap "Request to Join"
4. Wait for approval from the committee creator

### Making Payments
1. Go to "My Committees" tab
2. Select a committee
3. Tap "View Details & Pay"
4. Enter payment amount and description
5. Take a photo of your receipt
6. Submit payment for verification

### Managing Committees
- View payment progress and member status
- Track remaining payments and deadlines
- Monitor committee timeline and milestones

## Future Enhancements

### Planned Features
- **Winner Selection**: Random winner selection for completed committees
- **Payment Verification**: Advanced payment verification system
- **Member Invitations**: Direct member invitation system
- **Committee Analytics**: Detailed statistics and reporting
- **Offline Support**: Enhanced offline functionality
- **Backup & Sync**: Cloud backup and synchronization

### Technical Improvements
- **Security**: Password hashing and encryption
- **Performance**: Database optimization and caching
- **Testing**: Unit and integration tests
- **Documentation**: API documentation and user guides
- **Internationalization**: Multi-language support

## Architecture

The app follows a clean architecture pattern with:
- **Models**: Data structures and business logic
- **Services**: Business logic and external integrations
- **Pages**: UI components and user interactions
- **Database**: Data persistence layer
- **Providers**: State management and data flow

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact the development team or create an issue in the repository.

---

**Committee Payment App** - Making committee management simple and efficient! 🚀