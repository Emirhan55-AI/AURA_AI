# Aura Architectural Decision Log (ADR Log)

This log records the significant architectural decisions made for the Aura project. Each entry summarizes the context, the decision, and the rationale behind it. This helps current and future developers understand the "why" behind the architecture.

For the ADR template and more details, see `Dokümantasyon ve Onboarding.pdf`.

## Table of Contents

*   [ADR-001: Monorepo Structure](#adr-001-monorepo-structure)
*   [ADR-002: Frontend Framework](#adr-002-frontend-framework)
*   [ADR-003: State Management (Frontend)](#adr-003-state-management-frontend)
*   [ADR-004: Backend Services Strategy](#adr-004-backend-services-strategy)
*   [ADR-005: Primary Database and Authentication](#adr-005-primary-database-and-authentication)
*   [ADR-006: API Communication Strategy (Polyglot API)](#adr-006-api-communication-strategy-polyglot-api)
*   [ADR-007: Styling and UI Framework](#adr-007-styling-and-ui-framework)
*   [ADR-008: Error Tracking and Monitoring](#adr-008-error-tracking-and-monitoring)
*   [ADR-009: Offline-First Approach](#adr-009-offline-first-approach)

---

## ADR-001: Monorepo Structure

*   **Status:** Accepted
*   **Context:** The project consists of a Flutter mobile application and a Python FastAPI backend service. Managing these in separate repositories could lead to versioning mismatches and complex dependency management.
*   **Decision:** Adopt a monorepo structure using `melos` for tooling.
*   **Rationale:**
    *   Simplifies dependency management across the Flutter app and FastAPI service.
    *   Eases local development and testing of integrated features.
    *   Provides a single source of truth for the entire project, improving developer onboarding (as described in `Dokümantasyon ve Onboarding.pdf`).
    *   Aligns with the "Küçük Ekip Paradoksu" strategy to maximize productivity with a small team (as discussed in `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf`).
*   **Considered Alternatives:**
    *   **Multi-repo:** Increases complexity for cross-cutting changes and releases but provides isolation.
    *   **Monorepo without tooling:** Possible but harder to manage without tools like `melos`.

---

## ADR-002: Frontend Framework

*   **Status:** Accepted
*   **Context:** Need a cross-platform mobile framework that delivers high performance, rich UI/UX, and fits the project's technical and design requirements.
*   **Decision:** Use **Flutter** for the mobile frontend.
*   **Rationale:**
    *   Provides a single codebase for iOS and Android.
    *   Offers high performance and smooth animations (Impeller support).
    *   Strong alignment with the targeted Material 3 design system (`Flutter ile Aura İçin Kişisel ve Sıcak Material 3 UIUX Rehberi.pdf`, `Tasarım Anlayışı.docx`).
    *   Backed by Google with a growing community.
    *   Integrates well with Supabase and supports the required state management solutions.
*   **Considered Alternatives:**
    *   **React Native:** Popular but potentially less consistent performance compared to Flutter's native compilation.
    *   **Native (iOS/Android):** Higher development cost and maintenance effort for two separate codebases.

---

## ADR-003: State Management (Frontend)

*   **Status:** Accepted
*   **Context:** Managing complex application state and asynchronous data flow efficiently in Flutter.
*   **Decision:** Use **Riverpod v2** as the primary state management solution.
*   **Rationale:**
    *   Compile-time safety reduces runtime errors.
    *   Excellent testability for business logic and UI states.
    *   Supports complex async scenarios with `AsyncNotifierProvider`.
    *   Code generation (`@riverpod`) reduces boilerplate and improves type safety.
    *   Aligns with modern Flutter best practices.
*   **Considered Alternatives:**
    *   **Provider:** Older, less compile-time safe.
    *   **Bloc/Cubit:** More boilerplate, steeper learning curve for the team.
    *   **GetX:** Less type-safe, can lead to tightly coupled code if not used carefully.

---

## ADR-004: Backend Services Strategy

*   **Status:** Accepted
*   **Context:** Need backend logic for AI processing, complex recommendations, and operations that Supabase alone cannot efficiently handle.
*   **Decision:** Implement a **Hybrid Backend Architecture** using **Supabase** for core services (Auth, DB, Storage, Realtime) and a custom **FastAPI** service for specialized logic.
*   **Rationale:**
    *   **Supabase:** Provides managed, scalable services (Auth, Postgres DB, Storage, Realtime) reducing operational overhead ("Küçük Ekip Paradoksu" - `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf`, `Aura Projesi_ Teknoloji ve Tasarım Seçimi_.pdf`).
    *   **FastAPI:** Offers high performance, ease of development, strong typing with Python, and excellent support for building APIs and integrating with AI models. It's perfect for custom, compute-intensive tasks.
    *   This hybrid approach leverages the strengths of managed services and custom development.
*   **Considered Alternatives:**
    *   **Full Custom Backend (e.g., Node.js/Express, Django):** Higher development and maintenance effort for standard features already provided by Supabase.
    *   **Serverless Functions (only):** Might become complex and less performant for heavy logic or AI processing.

---

## ADR-005: Primary Database and Authentication

*   **Status:** Accepted
*   **Context:** Need a robust, scalable database and secure, easy-to-integrate authentication system.
*   **Decision:** Use **Supabase** for both the primary database (PostgreSQL) and Authentication.
*   **Rationale:**
    *   PostgreSQL is a powerful, reliable, and well-understood relational database.
    *   Supabase provides a comprehensive, managed Auth solution with various providers (Email, OAuth).
    *   Tight integration between Supabase Auth and Database simplifies development (Row Level Security).
    *   Reduces infrastructure management overhead, fitting the "Küçük Ekip Paradoksu".
*   **Considered Alternatives:**
    *   **Firebase Auth + Firestore:** NoSQL approach, different querying capabilities.
    *   **Custom Auth + Self-managed Postgres:** Significantly higher operational complexity.

---

## ADR-006: API Communication Strategy (Polyglot API)

*   **Status:** Accepted
*   **Context:** Different operations require different communication methods for optimal efficiency and functionality (e.g., complex queries, simple actions, real-time updates).
*   **Decision:** Implement a **Polyglot API Strategy**:
    *   **GraphQL (Supabase):** For complex, nested data reads (e.g., social feeds).
    *   **REST (Supabase & FastAPI):** For simple actions, commands, and write operations.
    *   **WebSocket (Supabase Realtime):** For real-time data updates (e.g., notifications, chat messages).
*   **Rationale:**
    *   Uses the most appropriate protocol for each specific task, optimizing performance and developer experience.
    *   Supabase natively supports all three, making integration seamless.
    *   Aligns with the "fit-for-purpose" principle described in `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf`.
*   **Considered Alternatives:**
    *   **Pure REST:** Might be inefficient for complex, related data fetching.
    *   **Pure GraphQL:** Might be overkill for simple commands and less suitable for real-time actions without specific setup.

---

## ADR-007: Styling and UI Framework

*   **Status:** Accepted
*   **Context:** Need a consistent, modern, and customizable design system that supports the "sıcak, samimi, evrensel" (warm, personal, universal) UI/UX vision.
*   **Decision:** Adopt **Material 3** as the core design language, customized for Aura's personality.
*   **Rationale:**
    *   Provides a mature, well-documented, and widely supported design system.
    *   Offers theming capabilities to create a unique, "personal" look and feel.
    *   Supported natively by Flutter, ensuring ease of implementation and performance (`Flutter ile Aura İçin Kişisel ve Sıcak Material 3 UIUX Rehberi.pdf`, `Tasarım Anlayışı.docx`).
    *   Balances "speed" (using a managed system) with "personalization" (`Aura Projesi_ Teknoloji ve Tasarım Seçimi_.pdf`).
*   **Considered Alternatives:**
    *   **Custom Design System from Scratch:** High initial cost and ongoing maintenance.
    *   **Cupertino (iOS-style):** Less suitable for a cross-platform app aiming for a unique identity.

---

## ADR-008: Error Tracking and Monitoring

*   **Status:** Accepted (Initial Phase)
*   **Context:** Need visibility into application crashes and errors for stability and user experience.
*   **Decision:** Start with a dual approach using **Sentry** and **Firebase Crashlytics** for error tracking.
*   **Rationale:**
    *   Both are mature, feature-rich platforms.
    *   Provides redundancy and potentially broader error capture initially.
    *   Sentry offers advanced features like breadcrumbs and distributed tracing, beneficial for complex debugging.
    *   Firebase Crashlytics integrates well with Firebase ecosystem if used elsewhere.
    *   Allows evaluation of which tool better fits long-term needs (`Aura Projesi_ Teknoloji ve Tasarım Seçimi_.pdf` suggests this approach).
*   **Considered Alternatives:**
    *   **Single Tool (only Sentry or only Crashlytics):** Less initial comparison.
    *   **No Error Tracking:** Not viable for a production application.

---

## ADR-009: Offline-First Approach

*   **Status:** Accepted
*   **Context:** Ensure a seamless user experience even with intermittent or no network connectivity, especially for core features like viewing the wardrobe.
*   **Decision:** Implement an **Offline-First** strategy with local data persistence and synchronization.
*   **Rationale:**
    *   Improves user experience by allowing core app functions without a network connection.
    *   Increases app reliability and perceived performance.
    *   Strategy involves local database storage (e.g., SQLite via `drift`/`floor`), Riverpod memory cache, and a sync queue for background reconciliation (`Offline-first ve Cache Stratejileri .pdf`, `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf`).
*   **Considered Alternatives:**
    *   **Online-Only:** Poor user experience in unreliable network conditions.
    *   **Basic Caching Only:** Doesn't allow for data modification offline.
