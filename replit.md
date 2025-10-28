# YoMinero - Mining Social Network

## Overview

YoMinero is a Flutter-based mobile and web application serving as a social network platform specifically designed for the mining industry. The application features a comprehensive role-based access control system for employees, supporting different user types including companies, individual miners, and employees with varying permission levels. The platform enables social interactions (posts, likes), marketplace functionality (products and services), and specialized dashboards tailored to different user roles (CEO, Technical staff, Individual miners).

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Frontend Architecture

**Framework:** Flutter (cross-platform mobile and web)
- **Rationale:** Enables single codebase deployment across iOS, Android, and Web platforms
- **Architecture Pattern:** Feature-based modular architecture with clean separation of concerns
- **Layer Structure:**
  - `core/`: Contains theme configuration, routing, authentication, and dependency injection (simple locator pattern)
  - `features/`: Domain-specific modules (posts, products, services) with data and domain layers
  - `shared/models`: Shared data models exported via barrel files for reusability

**State Management:** Not explicitly defined in repository, appears to use simple state management patterns

**UI/UX Design System:**
- Custom metallic color palette with gradients (gold, emerald, platinum, bronze)
- Semantic color tokens defined in `AppColors` (primary, surface, success, info)
- Orange-gold-wood theme scheme ("Cofre Dorado" - Golden Chest)
- Primary colors: Vibrant orange (#FF8C00), Warm gold (#FFB800)
- Uses gradient decorations for realistic metallic effects rather than flat colors

**Routing:** Centralized routing system in core module

### Backend Architecture

**Development Approach:** In-memory repository implementations for rapid development
- **Rationale:** Allows fast prototyping and testing without external dependencies
- **Migration Path:** Designed to be replaced with remote APIs or SQLite as application scales

**Authentication System:**
- Multi-user type support: Company, Individual, Employee
- Role-based access control (RBAC) for employees
- Password change requirement on first login for employees
- Predefined test accounts for different roles (CEO, Technician, Individual, Company)

**Employee Role System:**
- 8 predefined roles with different dashboard access levels
- CEO/Director General: Full access to all features (Metrics, Employees, Projects, Finances, Resources, Messages)
- Technical Staff: Limited access (Tasks, Reporting, Training, Profile)
- Department-based organization

### Data Storage Solutions

**Current Implementation:** In-memory repositories (development)

**Planned Integration:** Supabase (PostgreSQL-based)
- **Database Schema:** 7+ main tables including users, posts, products, services, groups
- **Features:**
  - Row Level Security (RLS) configured
  - Automatic triggers for likes and timestamp updates
  - Indexed for performance optimization
  - 8 predefined employee roles in database

**Schema Structure:**
- Users table with type differentiation (company/individual/employee)
- Social features (posts with likes tracking)
- Marketplace (products, services)
- Group management
- Employee roles and departments

### External Dependencies

**Core Framework:**
- Flutter SDK (Dart)
- Cross-platform compilation targets: dart2js for web, native compilation for mobile

**Third-Party Packages:**
- `cupertino_icons`: iOS-style icons
- `flutter_dotenv`: Environment variable management
- `get_it`: Simple service locator for dependency injection
- `supabase_flutter`: Supabase client for Flutter (authentication and database integration)

**Supabase Integration:**
- Authentication provider
- PostgreSQL database backend
- Requires configuration via `.env` file (not committed to version control)
- Setup includes SQL schema migration script
- API credentials: SUPABASE_URL and SUPABASE_ANON_KEY

**Development Dependencies:**
- `flutter_lints`: Dart linting rules
- `flutter_test`: Testing framework

**Platform Support:**
- Web (CanvasKit renderer)
- Windows (CMake build system)
- Mobile platforms (iOS/Android via Flutter)

**Build Tools:**
- CMake for Windows builds
- Flutter build system for cross-platform compilation
- Service worker for PWA functionality on web

**Testing Approach:**
- Example test: `test/post_repository_test.dart` validates unique likes logic
- Focus on domain logic validation