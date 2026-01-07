# Clean Architecture Implementation

This project follows Clean Architecture principles with proper separation of concerns.

## Project Structure

```
lib/
├── core/                    # Core functionality shared across features
│   ├── constants/          # App-wide constants
│   ├── di/                 # Dependency injection setup
│   ├── error/              # Error handling (exceptions, failures)
│   ├── network/             # Network layer (Dio, Retrofit)
│   ├── storage/             # Local storage (Hive)
│   ├── theme/               # App theme and colors
│   └── utils/               # Utility classes (Result type)
│
├── features/                # Feature modules
│   └── auth/               # Authentication feature
│       ├── data/           # Data layer
│       │   ├── datasources/  # Remote and local data sources
│       │   ├── models/       # Data models (with JSON serialization)
│       │   └── repositories/ # Repository implementations
│       ├── domain/         # Domain layer (business logic)
│       │   ├── entities/     # Domain entities
│       │   ├── repositories/ # Repository interfaces
│       │   └── usecases/     # Use cases
│       └── presentation/   # Presentation layer
│           └── providers/    # Riverpod providers
│
└── presentation/            # Shared presentation components
    ├── pages/              # App pages
    ├── routes/             # Navigation routes
    └── widgets/            # Reusable widgets
```

## Technologies Used

- **Dio + Retrofit**: Network layer for API calls
- **Hive**: Local storage for caching
- **GetIt + Injectable**: Dependency injection
- **Riverpod**: State management
- **Freezed**: Immutable data classes and unions
- **JSON Serializable**: JSON serialization
- **GoRouter**: Navigation

## Setup Instructions

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate code (Freezed, JSON, Injectable, Retrofit):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Update API base URL:**
   - Edit `lib/core/constants/api_constants.dart`
   - Edit `lib/core/network/dio_client.dart`

4. **Run the app:**
   ```bash
   flutter run
   ```

## Architecture Layers

### Domain Layer
- **Entities**: Pure business objects
- **Repositories**: Interfaces defining data operations
- **Use Cases**: Business logic operations

### Data Layer
- **Models**: Data transfer objects with JSON serialization
- **Data Sources**: Remote (API) and Local (Hive) implementations
- **Repository Implementations**: Concrete implementations of domain repositories

### Presentation Layer
- **Providers**: Riverpod state management
- **Pages**: UI screens
- **Widgets**: Reusable UI components

## Error Handling

The project uses a comprehensive error handling system:

- **Exceptions**: Thrown in data layer
- **Failures**: Returned in domain layer (using Result type)
- **Error Handler**: Converts exceptions to failures

## Dependency Injection

All dependencies are registered using Injectable and GetIt. After running build_runner, the `injection.config.dart` file will be generated automatically.

## State Management

Riverpod is used for state management:
- `loginProvider`: Handles login state
- `registerProvider`: Handles registration state
- `authStateProvider`: Manages authentication state

## Next Steps

1. Run `flutter pub run build_runner build --delete-conflicting-outputs` to generate all required files
2. Update the API base URL in `lib/core/constants/api_constants.dart`
3. Implement additional features following the same pattern
4. Add unit tests for use cases and repositories
5. Add integration tests for the complete flow

