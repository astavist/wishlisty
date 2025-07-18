# WishLink - Social Gift Sharing Platform

WishLink is a modern Flutter application that allows users to create wishlists, share them with friends, and discover gift ideas through social interactions. Built with Flutter and Firebase, it provides a seamless social experience for gift planning and sharing.

## ✨ Features

### 🔐 Authentication
- **Email/Password Login & Registration** with form validation
- **Google Sign-In** integration for quick access
- **Forgot Password** functionality with email reset
- **Social Authentication** support (Google, Apple, Facebook)

### 🎁 Wish Management
- **Create Wishes** with images, descriptions, prices, and product links
- **Secret Pinning System** - Save friends' wishes without them knowing
- **Categories & Priority Levels** for organized wishlists
- **Public/Private** wish settings
- **Interactive Feed** with like, comment, and pin functionality

### 👥 Social Features
- **Friend System** with requests and management
- **Real-time Activity Feed** showing friends' wishes
- **Search & Discovery** to find and add friends
- **Notifications** for friend activities and interactions

### 🛡️ Privacy & Security
- **Secret Gift Planning** - Pinned wishes are hidden from owners
- **Privacy Controls** for wish visibility
- **Secure Authentication** with Firebase
- **Data Protection** with proper access controls

## 🏗️ Architecture

### 📱 Flutter Architecture
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_model.dart
│   ├── wish_model.dart
│   └── notification_model.dart
├── providers/                # State management (Provider)
│   ├── auth_provider.dart
│   ├── wish_provider.dart
│   └── user_provider.dart
├── services/                 # Business logic & API calls
│   ├── auth_service.dart
│   └── firestore_service.dart
├── screens/                  # UI screens
│   ├── auth/                 # Authentication screens
│   ├── home/                 # Home feed
│   ├── wish/                 # Wish management
│   ├── profile/              # User profile
│   ├── friends/              # Friend management
│   └── notifications/        # Notifications
├── widgets/                  # Reusable UI components
│   ├── common/               # Shared widgets
│   └── home/                 # Home-specific widgets
└── utils/                    # Utilities & constants
    ├── app_colors.dart
    └── app_routes.dart
```

### 🔥 Firebase Backend
- **Authentication** - User management with multiple sign-in methods
- **Firestore** - Real-time database for users, wishes, and interactions
- **Storage** - Image storage for user profiles and wish photos
- **Security Rules** - Proper data access controls

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK
- Firebase project setup
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/wishlink.git
cd wishlink
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Firebase Setup**
   - Create a new Firebase project
   - Enable Authentication (Email/Password, Google)
   - Set up Firestore Database
   - Enable Firebase Storage
   - Add your platform-specific config files:
     - `android/app/google-services.json`
     - `ios/Runner/GoogleService-Info.plist`

4. **Run the application**
```bash
flutter run
```

## 📊 Database Structure

### Users Collection
```json
{
  "users": {
    "userId": {
      "email": "user@example.com",
      "displayName": "John Doe",
      "photoURL": "https://...",
      "bio": "User bio",
      "friends": ["friendId1", "friendId2"],
      "friendRequests": ["userId1"],
      "sentRequests": ["userId2"],
      "createdAt": "timestamp",
      "lastSeen": "timestamp",
      "notificationSettings": {
        "mentions": true,
        "wishLists": true,
        "comments": true
      }
    }
  }
}
```

### Wishes Collection
```json
{
  "wishes": {
    "wishId": {
      "userId": "ownerId",
      "title": "Wish title",
      "description": "Description",
      "imageUrl": "https://...",
      "productUrl": "https://...",
      "price": 99.99,
      "currency": "USD",
      "category": "Electronics",
      "priority": 3,
      "isPublic": true,
      "likes": ["userId1", "userId2"],
      "comments": [
        {
          "id": "commentId",
          "userId": "commenterId",
          "content": "Great choice!",
          "createdAt": "timestamp"
        }
      ],
      "pins": [
        {
          "userId": "pinnerId",
          "pinnedAt": "timestamp",
          "note": "Secret note for gift planning"
        }
      ],
      "createdAt": "timestamp",
      "updatedAt": "timestamp"
    }
  }
}
```

## 🎨 UI/UX Design

### Design System
- **Primary Color**: Blue (#4A90E2)
- **Typography**: Poppins font family
- **Modern Cards**: Rounded corners, subtle shadows
- **Consistent Spacing**: 8px grid system
- **Responsive Design**: Optimized for mobile devices

### Key Screens
1. **Splash Screen** - Animated logo with authentication check
2. **Authentication Flow** - Login, signup, forgot password
3. **Home Feed** - Friend activity with interactive cards
4. **Add Wish** - Complete form with image picker
5. **Profile** - User info with settings and actions
6. **Friends** - Tabbed interface for friends, requests, and search
7. **Notifications** - Categorized notifications with read states

## 🔧 Key Features Implementation

### Secret Pinning System ⭐
The core feature that allows users to secretly save friends' wishes for gift planning:

```dart
// Pin a wish (hidden from owner)
Future<bool> pinWish(String wishId, String userId, {String? note}) async {
  // Only friends can pin, not the wish owner
  if (wish.userId == userId) return false;
  
  WishPin pin = WishPin(
    userId: userId,
    pinnedAt: DateTime.now(),
    note: note, // Private note for gift planning
  );
  
  // Add to pins array, hidden from wish owner
  await firestore.collection('wishes').doc(wishId).update({
    'pins': FieldValue.arrayUnion([pin.toMap()]),
  });
}

// Get pins (filtered based on user)
List<WishPin> getPinsForUser(String currentUserId) {
  if (currentUserId == userId) {
    return []; // Hide pins from wish owner
  }
  return pins; // Show to everyone else
}
```

### Real-time Updates
Using Firestore streams for live data synchronization:

```dart
Stream<List<WishModel>> getFriendsWishes(List<String> friendIds) {
  return firestore
      .collection('wishes')
      .where('userId', whereIn: friendIds)
      .where('isPublic', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => 
          WishModel.fromFirestore(doc)).toList());
}
```

## 🧪 Testing

### Running Tests
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widgets/
```

### Test Coverage
- **Unit Tests**: Models, services, providers
- **Widget Tests**: Custom widgets and screens
- **Integration Tests**: Complete user flows

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.15.3
  cloud_firestore: ^4.13.6
  firebase_storage: ^11.5.6
  
  # State Management
  provider: ^6.1.1
  
  # UI/UX
  google_fonts: ^6.1.0
  cached_network_image: ^3.3.0
  image_picker: ^1.0.4
  url_launcher: ^6.2.2
  
  # Social Auth
  google_sign_in: ^6.1.6
```

## 🚀 Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Firebase Hosting (Web)
```bash
flutter build web
firebase deploy --only hosting
```

## 🛣️ Roadmap

### Phase 1 - Core Features ✅
- [x] Authentication system
- [x] Basic wish management
- [x] Friend system
- [x] Secret pinning functionality
- [x] Home feed with interactions

### Phase 2 - Enhanced Features 🔄
- [ ] Push notifications
- [ ] Image upload to Firebase Storage
- [ ] Advanced search and filters
- [ ] Wishlist collections
- [ ] Gift purchasing tracking

### Phase 3 - Social Features 📅
- [ ] Group wishlists
- [ ] Gift suggestions AI
- [ ] Social sharing to external platforms
- [ ] Gift reminders and occasions
- [ ] Collaborative gift planning

### Phase 4 - Monetization 💰
- [ ] Premium features
- [ ] Affiliate partnerships
- [ ] Gift cards integration
- [ ] Business accounts

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart style guidelines
- Write tests for new features
- Update documentation for API changes
- Use semantic commit messages

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Firebase** for backend services
- **Material Design** for UI guidelines
- **Community** for open-source packages

## 📞 Support

For support, email support@wishlink.app or join our Discord community.

---

**Built with ❤️ using Flutter & Firebase** 