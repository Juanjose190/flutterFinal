# schedules_flutter

Fully buildable Flutter app connecting to Supabase with English/Spanish localization, theme switching, CRUD for Teachers/Subjects/Classrooms, Schedules view with filters, and AI schedule generation via Gemini Flash 2.5.

## Prerequisites
- Flutter SDK installed
- Android Studio/Xcode (for mobile), or Chrome (for web)
- Supabase project created

## Environment Setup
1. Create a `.env` file at the project root based on `.env.example`:
```
SUPABASE_URL=your_url
SUPABASE_ANON_KEY=your_anon
SUPABASE_SERVICE_KEY=your_service_key
GEMINI_API_KEY=your_gemini_key
```
2. The app loads `.env` at startup. If `SUPABASE_URL` and `SUPABASE_ANON_KEY` are missing, the app still runs but Supabase operations will fail gracefully.

## Supabase Schema
1. Import `Supa.sql` into your Supabase project to create tables and view.
2. Configure Row Level Security and policies according to your needs.

## Localization
- English and Spanish `.arb` files are under `lib/l10n/`.
- `l10n.yaml` config is included; Flutter generates localizations at build time.
- Default language is English. Use Settings screen to switch.

## Themes
- Light: Orange + White
- Dark: Black + Orange
- Toggle in Settings.

## Authentication
- Email + password login UI is provided. User creation and SQL auth policies are handled manually by you.
- After successful login, you’ll see the dashboard.

## Features
- Dashboard: header area and tiles for Teachers, Subjects, Classrooms, Schedules.
- CRUD screens: list, create, edit, delete.
- Classrooms support marking as special.
- Schedules view: filter by teacher, subject, classroom, date.
- AI Generate: use Gemini to propose schedules; save accepted schedules to Supabase.

## Run & Build
```
flutter pub get
flutter run
```
For web preview:
```
flutter run -d web-server --web-port 5500
```
For Android Studio, open the project and run on an emulator/device.

### Debug Banner
- The Flutter debug banner has been disabled via `debugShowCheckedModeBanner: false` in `lib/main.dart`.
- To re-enable, set it to `true` in `MaterialApp.router`.

### Search
- A dedicated Search screen provides real-time, debounced (300ms) queries across Teachers, Classrooms, Subjects, and Schedules.
- Includes filter chips, loading/error/empty states, keyboard navigation (↑/↓ and Enter), and local history persistence via `shared_preferences`.

## Project Structure (Clean Architecture)
- `lib/core`: theme and router
- `lib/domain`: entities and repository interfaces
- `lib/data`: Supabase service and repository implementations
- `lib/presentation`: BLoCs/Cubits and UI pages
- `lib/l10n`: localization files

## Environment Notes
- Do not commit `.env` with real keys. Use `.env.example` for reference.
- Service key is not used in the mobile app runtime; keep it server-side.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
