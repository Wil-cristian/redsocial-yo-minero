# YoMinero - Red Social para la Industria Minera

## Overview
YoMinero is a specialized social platform designed for professionals, companies, and workers in the mining industry. Its primary purpose is to facilitate connections, knowledge sharing, service provision and discovery, and group management within the mining sector. The platform aims to be the central hub for industry networking and collaboration.

## User Preferences
I want iterative development. Ask before making major changes. I prefer detailed explanations.

## System Architecture

### UI/UX Decisions
The application features a comprehensive UI for various functionalities, including:
- **Service Management**: Pages for displaying and managing services.
- **Product Marketplace**: Pages for showcasing and interacting with products.
- **Group Management**: Functionality for creating, joining, and managing groups.
- **Company Metrics Dashboard**: Real-time analytics and metrics display.
- **User Profiles**: Expanded professional profiles with various fields.
- **Real-time Messaging**: UI for conversations and chat.
- **Radial Menu Navigation**: Global floating radial menu for quick access to all major features. Desktop/tablet shows full 360° circular menu, mobile devices show 120° arc fallback. Features professional-grade animations (expand, rotate, pulse, hover effects) and adaptive positioning. See `RADIAL_MENU_GUIDE.md` for technical details.

### Technical Implementations
- **Frontend**: Flutter Web 3.32.0.
- **Backend**: Supabase (PostgreSQL, Auth, Realtime).
- **Deployment**: Replit.
- **Authentication**: Supabase-based authentication with user registration (individual, worker, company types), login, and session persistence. Includes `SupabaseAuthService` for managing user sessions and profiles.
- **Data Repositories**: Implemented with a Repository Pattern, using abstract interfaces (e.g., `ServiceRepository`, `GroupRepository`, `ProductRepository`, `PostRepository`, `FavoriteRepository`, `MessagingRepository`, `MetricsRepository`, `NotificationsRepository`) backed by Supabase implementations.
- **Real-time Features**: Supabase Realtime is used for instant messaging, conversation updates, and push notifications, including automatic message read receipts and refreshing.
- **Professional Profiles**: Expanded user profiles with fields like phone, profession, company, job title, website, location (JSONB), birth date, experience level, specializations, and interests. Optimized indexing for search.
- **Messaging Optimization**: Implemented pagination with infinite scroll for conversations, real-time user search with debouncing (300ms), and concurrency control via versioning system.
- **Error Handling**: Comprehensive typed exception system with `AppException` hierarchy: `DatabaseException`, `NetworkException`, `AuthException`, `ValidationException`, and `NotFoundException`. All repositories use consistent try-catch patterns with descriptive Spanish error messages.
- **UI Components**: Reusable widgets including `SkeletonLoader` with shimmer animation, `ErrorView`, `EmptyView`, `CachedImage` with lazy loading and placeholder support, `RadialMenu` with adaptive layouts, and `FloatingRadialButton` with responsive positioning.
- **Theming**: Dark Mode support via `ThemeProvider` with system-level persistence and smooth theme transitions.
- **Color System**: Unified color system (`AppColorsUnified`) centralizes all colors in a single location. Features multi-layer orange gradients (5-7 layers) for premium non-flat appearance, organized by modules (Home, Products, Services, Groups, Company, Employees, etc.). All 204 hardcoded colors migrated to centralized tokens with automatic import management. Includes context extension for quick access (`context.colorOrange`, `context.gradientOrange`).
- **Pull-to-Refresh**: Implemented across major pages (products, services, groups, posts) for improved data freshness.
- **Dependency Injection**: `get_it` is used for managing dependencies like `SupabaseAuthService` and various repository implementations.
- **Design Patterns**: Employs the Repository Pattern for data access and the Singleton Pattern for core services like `SupabaseAuthService` and the Supabase client.

### Feature Specifications
- **Core Functionalities**:
    - **Services**: CRUD operations, search by category and tags.
    - **Groups**: Create, join, leave groups, manage members, and track member counts.
    - **Products**: Full marketplace functionality with CRUD, search, and vendor information.
    - **Posts**: Social feed with author information.
    - **Favorites**: Mark/unmark products and services, retrieve by type.
    - **Messaging**: Real-time chat with conversation management, message sending/receiving, and automatic updates.
    - **Metrics**: Track projects (planning, in_progress, completed) and financial transactions (income, expenses) with period-based analytics.
    - **Notifications**: Real-time push notifications system with Supabase Realtime subscriptions. Secure RLS policies with SECURITY DEFINER function for system-generated notifications. Support for message notifications with automatic trigger on new messages. Users can view, mark as read, and delete notifications.
    - **Global Navigation**: Floating radial menu accessible from all screens with adaptive layouts (full circle on desktop/tablet, arc fallback on mobile) and professional animations.
- **User Management**: Comprehensive user profile editing, including newly added professional fields.

### System Design Choices
- **Database Schema**: PostgreSQL on Supabase, with tables for `users`, `services`, `groups`, `group_members`, `products`, `posts`, `favorites`, `conversations`, `messages`, `projects`, `transactions`, and `notifications`.
- **Database Functions & Triggers**: 
    - RPC functions: `increment_group_members`, `decrement_group_members`
    - SECURITY DEFINER function: `create_notification(UUID, TEXT, TEXT, TEXT, JSONB, TEXT)` - restricted to triggers only (EXECUTE revoked from PUBLIC/anon/authenticated)
    - Triggers: `update_conversation_on_message`, `update_updated_at`, `trigger_notify_new_message` (automatically creates notifications for new messages)
- **Security**: Row Level Security (RLS) enabled on all tables with strict policies. Notifications use special SECURITY DEFINER pattern to allow system-generated notifications while preventing client abuse.

## External Dependencies
- **Supabase**: Used as the primary backend for database (PostgreSQL), authentication, and real-time functionalities.
- **Flutter Web**: Frontend framework.
- **get_it**: Dependency injection library for Flutter.