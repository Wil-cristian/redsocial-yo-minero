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

### Technical Implementations
- **Frontend**: Flutter Web 3.32.0.
- **Backend**: Supabase (PostgreSQL, Auth, Realtime).
- **Deployment**: Replit.
- **Authentication**: Supabase-based authentication with user registration (individual, worker, company types), login, and session persistence. Includes `SupabaseAuthService` for managing user sessions and profiles.
- **Data Repositories**: Implemented with a Repository Pattern, using abstract interfaces (e.g., `ServiceRepository`, `GroupRepository`, `ProductRepository`, `PostRepository`, `FavoriteRepository`, `MessagingRepository`, `MetricsRepository`) backed by Supabase implementations.
- **Real-time Features**: Supabase Realtime is used for instant messaging and conversation updates, including automatic message read receipts and refreshing.
- **Professional Profiles**: Expanded user profiles with fields like phone, profession, company, job title, website, location (JSONB), birth date, experience level, specializations, and interests. Optimized indexing for search.
- **Messaging Optimization**: Implemented pagination with infinite scroll for conversations, real-time user search with debouncing, and concurrency control.
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
- **User Management**: Comprehensive user profile editing, including newly added professional fields.

### System Design Choices
- **Database Schema**: PostgreSQL on Supabase, with tables for `users`, `services`, `groups`, `group_members`, `products`, `posts`, `favorites`, `conversations`, `messages`, `projects`, and `transactions`.
- **Database Functions & Triggers**: RPC functions (`increment_group_members`, `decrement_group_members`) and triggers (`update_conversation_on_message`, `update_updated_at`) are used for data integrity and real-time updates.

## External Dependencies
- **Supabase**: Used as the primary backend for database (PostgreSQL), authentication, and real-time functionalities.
- **Flutter Web**: Frontend framework.
- **get_it**: Dependency injection library for Flutter.