# Aura Testing Strategy

This document outlines the testing strategy for the Aura application, covering both the Flutter frontend and the FastAPI backend. It defines the types of tests, tools used, scope, and best practices to ensure code quality, reliability, and maintainability.

## 1. Overview

A comprehensive testing approach is crucial for a complex application like Aura. This strategy encompasses unit tests, integration tests, widget tests (for Flutter), and end-to-end (E2E) tests. The goal is to catch bugs early, ensure features work as intended, and prevent regressions.

Testing is an integral part of the development lifecycle and is enforced through CI/CD pipelines (as described in `CI_CD_GUIDE.md`) to maintain code quality standards. See `Kod Kalitesi ve Statik Analiz.pdf` for related static analysis practices.

## 2. Testing Principles

*   **Test Pyramid:** Adhere to the testing pyramid: a strong base of fast, isolated unit tests, a smaller layer of integration tests, and a minimal layer of slower, broader E2E tests.
*   **Automated:** Tests should be automated and run as part of the CI/CD process (`CI_CD_GUIDE.md`).
*   **Reliable:** Tests should produce consistent results. Flaky tests undermine confidence.
*   **Fast Feedback:** Tests, especially unit and widget tests, should run quickly to provide rapid feedback to developers.
*   **Maintainable:** Tests should be easy to read, understand, and update alongside the codebase.
*   **Coverage Goals:**
    *   **Overall:** Aim for >70% line coverage.
    *   **Core/Critical Modules (e.g., auth, wardrobe, AI services):** Aim for >85% line coverage.
    *   **Tools & Measurement:**
        *   **Flutter:** Use `flutter test --coverage`. This generates a `coverage/lcov.info` file. Tools like `genhtml` (part of `lcov` package) can convert this into an HTML report for easy visualization (`genhtml coverage/lcov.info -o coverage/html`).
        *   **FastAPI (Python):** Use `pytest` with the `pytest-cov` plugin. Example command: `pytest --cov=app --cov-report=term-missing --cov-report=html`. This provides terminal output and an HTML report in `htmlcov/`.
*   **Mutation Testing (Advanced):** To ensure tests are not just present but *effective*, consider mutation testing tools. These tools introduce small, breaking changes (mutants) into the code and run the tests. If tests pass, the mutant survived, indicating a potential weakness in the test suite.
    *   **Python:** Tools like `mutmut` can be used.
    *   **Dart/Flutter:** Tools like `muter` are available. This is recommended for mature codebases aiming for the highest quality assurance.

## 3. Flutter Frontend Testing

The Flutter frontend will utilize the standard Flutter testing pyramid.

### 3.1. Unit Tests

*   **Purpose:** Test individual functions, methods, and classes in isolation. This includes testing logic within Riverpod `Notifier`s/`AsyncNotifier`s, utility functions, and business logic in the `domain` and `application` layers.
*   **Tools:** `test` package (standard Flutter testing library).
*   **Scope:**
    *   Pure functions (e.g., helper functions in `utils/`).
    *   Business logic within `application` layer use-cases.
    *   State logic within Riverpod Notifiers (e.g., verifying state transitions in `WardrobeNotifier`).
    *   Data transformation logic (e.g., mapping Supabase JSON to Dart models).
*   **Mocking:** Use `mockito` or `mocktail` to mock dependencies like repositories, API clients (`dio`, `graphql_flutter`), and Supabase client to isolate the unit under test. Generate mocks using `build_runner`.
    *   *Example:* Mock `WardrobeRepository` to test `GetFilteredClothingItemsUseCase` without making real network calls.

### 3.2. Widget Tests

*   **Purpose:** Test individual widgets in isolation to ensure they render correctly based on their input and respond to user interactions as expected. This is crucial for UI components listed in `COMPONENT_LIST.md`. Responsive behavior should also be tested (see `Flutter ile Aura İçin Kişisel ve Sıcak Material 3 UIUX Rehberi.pdf`).
*   **Tools:** `flutter_test` package (included with Flutter SDK).
*   **Scope:**
    *   Custom widgets (e.g., `ClothingItemCard`, `PrimaryButton`, `EmptyStateWidget`).
    *   Screen widgets (e.g., parts of `WardrobeHomeScreen`) to verify UI state changes (loading, error, empty) and interaction handling. See `Error Handling ve User Experience.pdf` for error state testing.
    *   UI logic that depends on state (e.g., showing a list in grid vs. list view based on a provider's state).
*   **Techniques:**
    *   Use `WidgetTester` to interact with widgets, pump the widget tree, and make assertions about the rendered output.
    *   Mock Riverpod providers using `ProviderScope overrides` for isolated testing.
    *   Test responsive behavior by pumping widgets with different `MediaQuery` sizes (e.g., `pumpWidget(MediaQuery(data: MediaQueryData(size: Size(400, 800)), child: myWidget))`). See `Flutter Tasarım Sistemi (Material 3 + Atomic Design + Monorepo).pdf`.
    *   Golden tests can be used for pixel-perfect UI verification, especially for complex layouts or components that must look exactly right (e.g., `EmptyStateWidget` designs). (See `Flutter Tasarım Sistemi (Material 3 + Atomic Design + Monorepo).pdf`).

### 3.3. Integration Tests (Flutter)

*   **Purpose:** Test the interaction between multiple units or layers within the Flutter app. This often involves testing how the UI (Presentation Layer) interacts with the Application/Domain layers and mocked Data layer.
*   **Tools:** `integration_test` package (included with Flutter SDK).
*   **Scope:**
    *   Testing a complete feature flow using mocked repositories (e.g., adding an item via `AddClothingItemScreen` -> `AddClothingItemController` -> mocked `WardrobeRepository`).
    *   Verifying navigation flows between screens.
    *   Testing complex state interactions that span multiple widgets or providers.
*   **Note:** These are distinct from pure backend integration tests or full E2E tests.

### 3.4. End-to-End (E2E) Tests (Future Consideration)

*   **Purpose:** Test the complete user journey through the real application, interacting with the actual backend services (Supabase, FastAPI). This provides the highest confidence but is also the slowest and most brittle.
*   **Tools:** Tools like `Patrol`, `flutter_gherkin`, or cloud-based solutions (Firebase Test Lab, AWS Device Farm) can be considered for E2E testing.
*   **Scope:**
    *   Critical user flows like Login -> Add Item -> View Item in Wardrobe.
    *   Complex scenarios involving real-time features (if applicable in a testable way).
*   **Test Environment Preparation:**
    *   Use a dedicated *staging* environment for E2E tests. This includes a separate Supabase project and potentially a staging FastAPI instance.
    *   Configure the Flutter app for E2E tests using specific environment variables (e.g., `.env.e2e`) that point to the staging backend URLs.
    *   *Example (using `Patrol` concept):* When running Patrol E2E tests, the app should be configured via `.env.e2e` to connect to the staging backend.
*   **Considerations:** Due to complexity and execution time, E2E tests are typically run less frequently (e.g., nightly builds, pre-release) rather than on every commit. They require a stable test environment.

## 4. FastAPI Backend Testing

The FastAPI backend will follow standard Python testing practices.

### 4.1. Unit Tests

*   **Purpose:** Test individual functions and methods within services, utils, and core modules in isolation.
*   **Tools:** `pytest` (standard Python testing framework), `pytest-mock` for mocking.
*   **Scope:**
    *   Functions in `services/` (e.g., logic inside `recommendation_service.py`).
    *   Utility functions in `utils/`.
    *   Input validation logic in Pydantic `schemas`.
*   **Mocking:** Use `unittest.mock` or `pytest-mock` to mock external dependencies like Supabase client, AI service SDKs, or database connections. This ensures tests are fast and focused.

### 4.2. Integration Tests

*   **Purpose:** Test the interaction between different parts of the backend, and its integration with external systems (like Supabase REST API or Database).
*   **Tools:** `pytest`, potentially `httpx` for testing API endpoints directly, `TestClient` from `fastapi.testclient` for testing the FastAPI app internally.
*   **Scope:**
    *   Testing API endpoints (`/api/v1/ai/analyze-clothing-item`) with mocked or real (test instance of) Supabase and AI services to verify request/response flow and error handling.
    *   Testing service layer logic (`ai_service.py`) with mocked external calls but real internal logic flow.
    *   Database interaction tests (if using direct DB access): Test queries, data models, and transactions against a test database instance. Use fixtures to set up and tear down test data.
*   **Test Environment:** Use a dedicated test database (e.g., a separate Supabase project or a local Postgres instance) and environment variables to isolate test data and avoid affecting production.

### 4.3. Contract Testing (Optional/Advanced)

*   **Purpose:** Ensure the backend API contracts (request/response formats) are adhered to, especially if multiple clients or services consume the API.
*   **Tools:** Tools like `Pact` can be used for consumer-driven contract testing.

## 5. Test Data Management

*   **Factories:** Use libraries like `factory_boy` (Python) or custom factory functions (Dart) to generate consistent and realistic test data objects.
*   **Fixtures:** Use `pytest` fixtures (Python) or setup/teardown methods (Dart) to manage test state and data, especially for integration tests requiring database setup.
*   **Test Database:** For backend integration tests involving the database, use a dedicated test database instance that can be easily reset or seeded.

## 6. Continuous Integration (CI) and Testing

*   **Pipeline Integration:** As defined in `CI_CD_GUIDE.md`, automated tests (unit, widget, integration) are run on every pull request and commit to the main branch.
*   **Fast Feedback:** Configure CI to run faster tests (unit, widget) first. Fail fast if these basic checks don't pass.
*   **Reporting:** CI pipelines should generate and display test reports, including pass/fail status and coverage reports. Tools like Codecov can integrate with GitHub/Codemagic to track coverage trends.
*   **Onboarding:** The `Dokümantasyon ve Onboarding.pdf` document emphasizes that the onboarding process should allow new developers to run tests locally easily (`make test` or equivalent command) to verify their setup. This implies tests should be runnable and pass in a standard development environment.

## 7. Best Practices

*   **Write Testable Code:** Design code with testing in mind (e.g., dependency injection, single responsibility).
*   **Descriptive Test Names:** Use clear and descriptive names for test functions that explain the scenario and expected outcome.
    *   *Example:* `test_clothing_card_displays_correct_title_when_item_has_name()` (Dart/Flutter convention often uses `snake_case` for test function names).
*   **Arrange-Act-Assert (AAA):** Structure tests clearly using the AAA pattern.
*   **Avoid Testing Implementation Details:** Focus on testing *what* the code does, not *how* it does it, where possible. This makes tests less brittle.
*   **Mock External Dependencies:** Isolate the code under test by mocking network calls, databases, file systems, and third-party services.
*   **Keep Tests Independent:** Each test should be able to run independently of others.
*   **Regular Review:** Regularly review and update tests as the application evolves.


