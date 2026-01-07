# Setup Instructions

## Prerequisites
- Flutter SDK installed
- Dart SDK installed

## Steps to Run the Project

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate code files (REQUIRED):**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
   
   This will generate:
   - Freezed files (`.freezed.dart`)
   - JSON serialization files (`.g.dart`)
   - Injectable dependency injection files (`injection.config.dart`)
   - Retrofit API client files

3. **Update API Configuration:**
   - Open `lib/core/constants/api_constants.dart`
   - Update the `baseUrl` with your API endpoint
   - Open `lib/core/network/dio_client.dart`
   - Update the `baseUrl` in `BaseOptions`

4. **Run the app:**
   ```bash
   flutter run
   ```

## Important Notes

- **You MUST run build_runner** before the app will compile. The generated files are required for:
  - Freezed unions (Failure, Result, entities)
  - JSON serialization (models)
  - Dependency injection (Injectable)
  - API client (Retrofit)

- If you encounter errors about missing generated files, run build_runner again.

- To watch for changes and auto-generate:
  ```bash
  flutter pub run build_runner watch
  ```

## Troubleshooting

If you see errors about:
- Missing `.freezed.dart` files → Run build_runner
- Missing `.g.dart` files → Run build_runner
- Missing `injection.config.dart` → Run build_runner
- `GetIt` not finding dependencies → Run build_runner and check `injection.config.dart` was generated

