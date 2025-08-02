# Aura Application Architecture

This document defines the overall technical architecture, layers, core components, and data flow of the Aura application. Its purpose is to help developers understand the "big picture" of the project and maintain consistency when adding new features.

## 1. Architectural Principles

This architecture is based on the following fundamental principles:

1.  **Developer Productivity:** Enable a small team to rapidly deliver value.
2.  **Sustainability:** The codebase should be easy to maintain and extend over the long term.
3.  **Fit-for-Purpose:** Rather than sticking to a single solution, choose the most appropriate technology for the nature of each problem.
4.  **Testability & Decoupling:** Layers and components should be as independent as possible from each other and easy to test.

## 2. Overview and System Architecture

Aura is a mobile application designed to digitize users' wardrobes, create personal style DNA, and offer unique clothing and combination suggestions based on that DNA. To support this complex functionality, the project is built on a **Hybrid Architecture**.

![Aura System Architecture](./images/system_architecture.png)
*Figure 1: Aura System Architecture Diagram (This image should be located at `docs/images/system_architecture.png`.)*

*   **Frontend:** A mobile application developed using Google's Flutter framework, adhering to the Material 3 design system.
*   **Backend (Core Operations):** The Supabase platform is used for core needs such as authentication (Auth), relational database (Database), file storage (Storage), and real-time data flow (Realtime).
*   **Backend (Specialized Business Logic & AI):** The Python-based FastAPI framework is used for complex business rules, AI integrations (e.g., running a `ResNet`-based model to classify images received from the user and feeding the results to the recommendation engine), and customized services.
*   **API Layer:** A **Polyglot API** approach is adopted based on different needs:
    *   **GraphQL:** Used for complex and nested data reads (e.g., social feeds) via Supabase.
    *   **REST:** Used for simple write operations and actions (e.g., updating user settings, likes) via both Supabase and FastAPI.
    *   **WebSocket:** Used for real-time notifications and chat, requiring synchronization, via Supabase Realtime.
        *   *Example Scenario:* When a user shares a new combination, followers instantly receive a notification via WebSocket.
*   **Monorepo Structure:** The project utilizes a Monorepo approach for better codebase manageability and development efficiency, managed with tools like `melos`.

## 3. Flutter Application Architecture

The Flutter side is based on **Clean Architecture** principles to ensure sustainability, testability, and scalability. This architecture isolates the application from business rules, UI, and the outside world (data sources, framework).

### 3.1. Layers

The application is divided into the following core layers:

1.  **Presentation Layer:**
    *   **Responsibility:** UI components (Widgets), handling user interactions, and reflecting state to the UI.
    *   **Flutter Components:** `Widgets`, `StatefulWidget`/`State`, Riverpod `Consumer`, navigation with `GoRouter`.

2.  **Application Layer:**
    *   **Responsibility:** Application-specific business rules, definition of use-cases (user scenarios), and orchestration. It directs requests from the UI layer to the business layer.
    *   **Example:** `WardrobeController` (Application) calls `GetFilteredClothingItemsUseCase` (Domain). The Use Case applies business logic and requests data through the `WardrobeRepository` interface (Domain).
    *   **Flutter Components:** Riverpod `Notifier`/`AsyncNotifier`, `Provider`, abstractions of services (Repository Interfaces).

3.  **Domain Layer (Business Layer):**
    *   **Responsibility:** The core business rules of the application, entities, and abstractions independent of business logic. This layer is completely independent of other layers.
    *   **Flutter Components:** Dart classes (Entities, Value Objects), abstract repository interfaces, abstract definitions of use-cases.

4.  **Data Layer:**
    *   **Responsibility:** Communication with external data sources (Supabase, FastAPI, local cache), fetching, transforming, and storing data.
    *   **Flutter Components:** Concrete implementations of repositories, API clients (`graphql_flutter`, `dio`), local cache mechanisms (`shared_preferences`, `hive`).

### 3.2. State Management

The project uses **Riverpod v2** for state management. Riverpod is ideal for managing application state in a predictable and testable way.

*   **`Provider`**: Used for injecting simple values or services.
*   **`StateProvider`**: Used for simple, mutable UI states.
*   **`StateNotifierProvider` / `AsyncNotifierProvider`**: Used to manage more complex states and asynchronous operations. For example, managing a screen's data loading, error, and success states.
*   **`.autoDispose`**: The default for automatically cleaning up unused providers. Helps prevent memory leaks.
*   **`@Riverpod(keepAlive: true)`**: Used for global and persistent states (e.g., authentication status, theme preference).
*   *For detailed usage and example scenarios, see [STATE_MANAGEMENT.md](./STATE_MANAGEMENT.md).*

### 3.3. Folder Structure

The project uses a **Feature-First** folder structure. This means each feature (e.g., `auth`, `wardrobe`, `combinations`) contains its own files and sub-layers (`presentation`, `application`, `domain`, `data`).

The project also adopts a **Monorepo** approach.

project_root/
├── apps/
│ ├── flutter_app/
│ │ ├── lib/
│ │ │ ├── core/
│ │ │ ├── features/
│ │ │ ├── shared/
│ │ │ └── main.dart
│ │ └── ...
│ └── fastapi_service/
│ ├── main.py
│ ├── api/
│ ├── core/
│ └── ...
├── packages/
│ ├── ui_kit/
│ └── shared_models/
├── docs/
│ ├── ARCHITECTURE.md <-- (This file)
│ ├── STYLE_GUIDE.md
│ └── ... (Other .md files)
├── .gitignore
├── README.md
└── melos.yaml


## 4. Backend Architecture

### 4.1. Supabase

Supabase is a managed Backend-as-a-Service (BaaS) solution used for the project's core CRUD operations, authentication, file storage, and real-time updates.

*   **Auth:** User registration, login, password reset.
*   **Database:** PostgreSQL-based relational database. Tables and RLS (Row Level Security) rules will be detailed in the `DATABASE_SCHEMA.md` file.
*   **Storage:** Storage of user clothing images and other files.
*   **Realtime:** Instantly sending database changes (e.g., new notifications) to clients via WebSocket.

### 4.2. FastAPI

FastAPI is a high-performance Python web framework that hosts specialized business logic and AI integrations where Supabase falls short.

*   **Services:** Operations such as AI model-based clothing tagging, style analysis, and complex recommendation algorithms are performed here.
*   **Authentication:** Requests to FastAPI services are protected by the JWT token obtained from Supabase. The token is verified on the FastAPI side using `PyJWT` or a similar library.

## 5. API Communication

*   **GraphQL (Supabase):** Used for complex data queries. Integrated in Flutter using the `graphql_flutter` package.
*   **REST (Supabase & FastAPI):** Used for simple actions and write operations. An API client is created in Flutter using the `dio` package.
*   **WebSocket (Supabase Realtime):** Used for real-time notifications. In Flutter, the `RealtimeChannel` structure provided by the `supabase_flutter` package is used.

## 6. Operational Excellence

*   **CI/CD:** Automated build, test, and deployment processes are carried out using `Codemagic`. Details are in the `CI_CD_GUIDE.md` file.
*   **Monitoring & Logging:** Crash and error monitoring is done using `Sentry` and `Firebase Crashlytics`. Detailed logging and distributed tracing use `X-Request-ID` headers. Details are in the `MONITORING_AND_LOGGING.md` file.




