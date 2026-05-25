# StackUsersTest (StackOverflow Users)

An iOS application that displays a list of top Stack Overflow users with simulated follow/unfollow functionality.

## Overview

This project demonstrates a clean, scalable iOS architecture that fetches and displays Stack Overflow users from the Stack Exchange API. By default only first 20 users are displayed.

## Features

- **Users List**: Efficiently loads Stack Overflow users with official API
- **Follow System**: Track your favorite users with persistent follow/unfollow functionality
- **Cached Images**: Optimized image loading with built-in caching
- **Pull-to-Refresh**: Refresh the user list with a simple pull gesture
- **Error Handling**: Graceful error states with user-friendly messages

## Project Structure

```
StackUsersTest/
├── Application/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── AppConstants.swift
├── Coordinators/
│   ├── Coordinator.swift          # Protocol for navigation coordination
│   └── AppCoordinator.swift       # Main app coordinator
├── Data Layer/
│   ├── Network/
│   │   ├── APIClient.swift             # Protocol for API communication
│   │   ├── URLSessionAPIClient.swift   # APICLient Implementation
│   │   ├── APIEndpoint.swift           # API endpoint definitions
│   │   └── APIError.swift
│   ├── DTOs/
│   │   └── UserDTO.swift            # Data Transfer Objects
│   └── Repositories/
│       └── AppUsersRepository.swift # Implementation of UsersRepository
├── Domain Layer/
│   ├── Models/
│   │   ├── User.swift             # Core domain model
│   │   └── UserPage.swift         # Helper model to parse API response     
│   └── Protocols/
│       ├── UsersRepository.swift  # Repository protocol
│       ├── FollowService.swift    # Follow service protocol
│       └── ImageService.swift     # Image loading protocol
├── Services/
│   ├── DefaultsFollowService.swift # UserDefaults-based follow storage
│   └── CachedImageService.swift    # Image caching service
├── Presentation/
│   ├── UsersList/
│   │   ├── UserListItem.swift         # Helper model for UI State
│   │   ├── UsersListViewController.swift
│   │   ├── UsersListViewModel.swift
│   │   └── UsersListCell.swift
└── Tests/
    ├── UsersListViewModelTests.swift
    └── DefaultsFollowServiceTests.swift
```

## Architecture

The project follows a clean MVVM+C architecture pattern with clear separation of concerns:

### Layers

1. **Presentation Layer** (UI + ViewModels)
   - Uses UIKit for UI implementation
   - ViewModels use Swift's `@Observable` macro for reactive updates
   - ViewControllers are thin and delegate business logic to ViewModels

2. **Domain Layer** (Business Logic + Protocols)
   - Contains core business models (`User`, `UserPage`)
   - Defines protocols for repositories and services
   - Platform-agnostic and reusable
   - (Can be extended by UseCases with business logic in future)

3. **Data Layer** (API + Repositories)
   - Generic `APIClient` protocol for network abstraction
   - Repository pattern for data access
   - DTOs (Data Transfer Objects) for API responses

### Key Design Patterns

#### Coordinator Pattern
Navigation logic is extracted into `Coordinator` classes, making it easy to:
- Add new screens without modifying existing ViewControllers
- Maintain a clear navigation flow
- Support deep linking in the future

#### Repository Pattern
Data access is abstracted through protocols (`UsersRepository`, `FollowService`), enabling:
- Easy testing with mock implementations
- Swapping data sources without changing business logic
- Clear separation between data and presentation layers

#### Protocol-Oriented Design
Heavy use of protocols throughout the app allows for:
- Better testability (dependency injection with mocks)
- Flexibility in implementation
- Clear contracts between components

## Technical Details

### UIKit with SwiftUI-Ready Architecture
While the UI is built with **UIKit**, the architecture is designed to support a future migration to **SwiftUI**:
- ViewModels use Swift's `@Observable` macro (compatible with SwiftUI)
- Business logic is decoupled from UIKit-specific code
- Protocol-based design allows easy view layer replacement

### Universal Network Layer
The network layer is designed to be flexible and extensible:
- Generic `APIClient` protocol works with any `Decodable` type
- `APIEndpoint` enum makes it easy to add new endpoints
- Easy to customize with interceptors, authentication, or different base URLs
- Can integrate additional APIs without major refactoring

### No Separate Use Cases Layer
For this project, business logic remains in the ViewModels rather than separate UseCases:
- The app has minimal business logic (fetch, display, follow/unfollow)
- Adding a UseCases layer would be over-engineering for current requirements
- Can be extracted later if business logic grows more complex

### Image Caching
Custom `CachedImageService` with `NSCache`:
- Automatic memory management
- Prevents redundant network requests
- Simple and efficient for this use case

## Installation Requirements

### System Requirements
- **macOS**: 13.0 or later
- **Xcode**: 15.0 or later
- **iOS Deployment Target**: 17.0 or later
- **Swift**: 5.9 or later

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd StackUsersTest
   ```

2. **Open the project**
   ```bash
   open StackUsersTest.xcodeproj
   ```
   Or simply double-click `StackUsersTest.xcodeproj` in Finder

3. **Build and Run**
   - Select a simulator or connected device with iOS 17+
   - Press `Cmd + R` or click the Run button
   - No additional dependencies or setup required

### No External Dependencies
This project uses only native iOS frameworks:
- **Foundation** - Core functionality
- **UIKit** - User interface
- **Observation** - Reactive property updates
- **XCTest** - Unit tests

No package managers (CocoaPods, SPM, Carthage) or third-party libraries required!

## API Integration

The app uses the **Stack Exchange API v2.3**:
- Endpoint: `https://api.stackexchange.com/2.2/users`
- Parameters: 
  - `page`: Page number for pagination
  - `pagesize`: Number of users per page
  - `site`: stackoverflow
  - `order`: desc
  - `sort`: reputation

Rate limits and quotas are managed by the Stack Exchange API.

## Testing

The project includes unit tests for critical components:

```bash
# Run tests in Xcode
Cmd + U
```

**Test Coverage:**
- `UsersListViewModelTests`: ViewModel logic and state management
- `DefaultsFollowServiceTests`: Follow/unfollow functionality

Tests use **XCTest** framework with `@Test` and `@Suite` macros.

### Mock Implementations
- `MockUsersRepository`: For testing without network calls
- `MockFollowService`: For testing follow functionality

## Future Enhancements

Possible improvements to consider:

- [ ] Add user detail screen (profile, badges, recent activity)
- [ ] Search functionality for users
- [ ] Implement UseCases layer if business logic grows
- [ ] Add network monitoring and offline support
- [ ] SwiftUI migration with minimal architectural changes
- [ ] Dark mode optimizations
- [ ] Accessibility improvements (VoiceOver, Dynamic Type)
- [ ] Add more comprehensive error handling
- [ ] Implement analytics tracking

## License

This is a test project for demonstration purposes.

## Author

Created by Oleksii Maidanyk on May 25, 2026
