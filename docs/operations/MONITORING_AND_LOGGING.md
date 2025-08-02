# Aura Monitoring and Logging Strategy

This document outlines the monitoring, logging, and error tracking strategy for the Aura application. It covers the tools used (Sentry, Firebase Crashlytics), logging practices, and how to achieve distributed tracing for better debugging across services.

## 1. Overview

Effective monitoring and logging are essential for understanding application behavior, diagnosing issues quickly, and ensuring a reliable user experience for Aura. This strategy focuses on:

*   **Crash/Error Reporting:** Using tools like Sentry and Firebase Crashlytics to capture and analyze application crashes and unhandled exceptions.
*   **Structured Logging:** Implementing consistent, structured logging on both client (Flutter) and server (FastAPI) to record events, debug information, and user actions.
*   **Distributed Tracing:** Linking requests as they flow through different services (Flutter UI -> FastAPI -> Supabase) using unique identifiers (`X-Request-ID`) to get a complete picture of a user action or system event.
*   **Performance Monitoring:** Tracking key performance indicators (KPIs) like API response times, startup times (Flutter), and database query performance. (See `Monitoring ve Business Metrics.pdf`)

This guide ensures alignment with the architectural decisions outlined in `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf` and the operational excellence goals in `CI_CD_GUIDE.md`.

## 2. Tooling

### 2.1. Error Tracking

Based on the analysis in `Aura Projesi_ Teknoloji ve Tasarım Seçimi_.pdf`, a dual approach is recommended for error tracking during the initial phase, with potential consolidation or expansion based on needs.

*   **Firebase Crashlytics:** Used primarily for capturing native crashes and unhandled exceptions in the Flutter application. It integrates seamlessly with Firebase and provides detailed crash reports.
*   **Sentry:** Used for capturing errors and exceptions in both the Flutter application (Dart code) and the FastAPI backend (Python code). Sentry offers advanced features like breadcrumbs, context, and distributed tracing support, making it powerful for diagnosing complex issues. `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf` pg 2 shows an example `main.dart` setup using both.

### 2.2. Logging

*   **Flutter (Dart):** Use the standard `logging` package or a more feature-rich alternative like `logger`. Logs should be structured (e.g., JSON) in production for easier parsing and analysis.
*   **FastAPI (Python):** Use the standard `logging` module from Python's standard library. Configure handlers and formatters for structured output (e.g., JSON). Libraries like `structlog` can enhance this.
*   **Log Aggregation/Viewing:** Logs can be viewed directly in platform consoles (e.g., Android Logcat, Xcode Console, Cloud Run/Firebase logs) during development.
    *   **For Production Analysis:** Integrating with a centralized logging solution is recommended. Options include:
        *   **Sentry (Performance/Large Scale):** Sentry can ingest logs (Issues vs. Performance Transactions) and is useful for correlating errors with structured logs, especially if already used for error tracking.
        *   **Google Cloud Logging (GCP):** If deployed on GCP, Cloud Logging provides powerful querying and visualization tools.
        *   **ELK Stack (Self-Managed/Advanced):** For complex log analysis, searching, and dashboarding needs, the ELK Stack (Elasticsearch, Logstash, Kibana) is a robust solution.
        *   **AWS CloudWatch (AWS):** If deployed on AWS, CloudWatch is the native logging solution.

### 2.3. Performance Monitoring

*   **Flutter:** Tools like Firebase Performance Monitoring or Sentry Performance Monitoring can track app startup time, screen load times, and custom traces. (See `Performans Optimizasyonu ve Bellek Yönetimi.pdf`)
*   **FastAPI:** Sentry Performance Monitoring or custom metrics exposed via Prometheus endpoints can monitor API endpoint response times and database query performance. (See `Monitoring ve Business Metrics.pdf`)

## 3. Implementation Details

### 3.1. Flutter Application

#### 3.1.1. Initialization

*   Initialize both Sentry and Firebase Crashlytics in `main.dart`, ideally wrapped in a `runZonedGuarded` or using platform-specific error handlers to catch errors as early as possible. (See `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf` pg 2).
*   Configure Sentry to capture `FlutterError` and `PlatformDispatcher.instance.onError`.
*   Ensure DSNs (Data Source Names) for Sentry and Firebase are securely managed (e.g., via environment variables or build configurations, not hardcoded).

#### 3.1.2. Structured Logging

*   Use a logging library (`logger`, `logging`) to create structured log messages.
*   **Log Levels:** Use standard levels appropriately:
    *   `DEBUG`: Fine-grained informational events for diagnosing problems. Not typically enabled in production.
    *   `INFO`: General operational events (e.g., "User logged in", "API request started").
    *   `WARNING`: Potentially harmful situations (e.g., deprecated API usage).
    *   `ERROR`: Error events that might still allow the application to continue running (e.g., failed API call, handled exception).
    *   `SEVERE`/`CRITICAL`: Very severe error events that will likely lead the application to abort (e.g., unhandled exceptions, crashes - though these are often caught by Crashlytics/Sentry).
*   **Log Format:** In production, prefer structured formats like JSON. Include relevant context (e.g., `userId`, `screenName`, `requestId`).
    *   *Example:*
        ```json
        {
          "timestamp": "2023-10-27T10:00:00Z",
          "level": "INFO",
          "logger": "WardrobeRepository",
          "message": "Fetching clothing items",
          "userId": "user-123",
          "page": 1,
          "requestId": "req-a1b2c3d4"
        }
        ```

#### 3.1.3. Distributed Tracing (`X-Request-ID`)

*   Generate a unique `X-Request-ID` (e.g., UUID v4) at the start of significant user-initiated actions or API request chains (e.g., when `WardrobeController` starts loading items, or when `StyleAssistantController` sends a message).
*   Attach this `X-Request-ID` to all subsequent internal logs related to that action.
*   Include the `X-Request-ID` in the headers of all outgoing HTTP requests to the FastAPI backend (e.g., using a `Dio` interceptor as shown in `API Katmanı.pdf`).
    *   *Example (Dio Interceptor snippet):*
        ```dart
        // Inside your Dio interceptor's onRequest method
        options.headers['X-Request-ID'] = generatedRequestId;
        ```
*   This allows correlating frontend logs with backend logs and Supabase actions for a complete trace.

#### 3.1.4. Error Reporting

*   Both Sentry and Firebase Crashlytics will automatically capture unhandled exceptions and crashes.
*   For *handled* errors that you want to report (e.g., a gracefully handled API failure that you still want to track), manually capture them using the respective SDKs:
    *   Sentry: `Sentry.captureException(error, stackTrace: stackTrace);` or `Sentry.captureMessage("User failed to load wardrobe", level: SentryLevel.warning);`
    *   Firebase Crashlytics: `FirebaseCrashlytics.instance.recordError(error, stackTrace);`
*   Add context to error reports using features like Sentry's `Sentry.configureScope` or Crashlytics' `setCustomKey`.

#### 3.1.5. Breadcrumbs (Sentry)

*   Sentry's breadcrumbs feature automatically records UI interactions, navigation events, and HTTP requests, providing valuable context when an error occurs. This is often enabled by default in Sentry's Flutter SDK.
*   **Manual Breadcrumbs:** You can also add custom breadcrumbs to record specific application states or user actions that are crucial for debugging.
    *   *Example:* Recording a user's path before a crash.
        ```dart
        import 'package:sentry_flutter/sentry_flutter.dart';

        // When navigating to a new screen
        Sentry.addBreadcrumb(
          Breadcrumb(
            category: "navigation",
            message: "Navigated to WardrobeHomeScreen",
            level: SentryLevel.info,
            data: {"userId": currentUserId}, // Optional extra data
          ),
        );

        // When a user performs a key action
        void onAddClothingItemPressed() {
          Sentry.addBreadcrumb(
            Breadcrumb(
              category: "user.action",
              message: "User pressed 'Add Clothing Item' button",
              level: SentryLevel.info,
            ),
          );
          // ... proceed with the action
        }

        // When an API call is made
        void fetchWardrobeItems() async {
          Sentry.addBreadcrumb(
            Breadcrumb(
              category: "http",
              message: "Fetching wardrobe items from API",
              level: SentryLevel.info,
              data: {"endpoint": "/api/v1/wardrobe/items"},
            ),
          );
          try {
            // ... API call logic
          } catch (error, stackTrace) {
            // The breadcrumbs above will be included in this error report
            Sentry.captureException(error, stackTrace: stackTrace);
          }
        }
        ```
    *   This creates a detailed trail of events leading up to an error, making it much easier to understand the context in which the problem occurred.

### 3.2. FastAPI Backend

#### 3.2.1. Initialization

*   Initialize Sentry SDK in the FastAPI application's entry point (`main.py` or an `app/main.py` setup function).
*   Configure Sentry to integrate with the FastAPI framework (e.g., using `sentry_sdk.init(..., integrations=[StarletteIntegration(), FastApiIntegration()])`).

#### 3.2.2. Structured Logging

*   Configure Python's `logging` module with appropriate formatters (e.g., JSON) and handlers.
*   Use standard log levels (`DEBUG`, `INFO`, `WARNING`, `ERROR`, `CRITICAL`).
*   Include relevant context in log records, especially the `X-Request-ID` received from the Flutter frontend.
*   A middleware can be used to extract the `X-Request-ID` from incoming requests and add it to the logging context (e.g., using `structlog`'s contextvars or standard `logging` filters/contexts).

#### 3.2.3. Distributed Tracing (`X-Request-ID`)

*   Middleware: Implement a middleware to intercept incoming requests.
*   Extract `X-Request-ID`: Read the `X-Request-ID` header from the incoming request.
*   Propagate Context: Store this ID in the request context (e.g., using `starlette.requests.Request.state` or `contextvars`) so it's accessible throughout the request lifecycle.
*   Include in Logs: Ensure all log messages generated during the processing of this request include the `X-Request-ID`.
*   Propagate to Supabase: If making direct database calls or Supabase REST API calls, consider including the `X-Request-ID` in custom fields or comments where possible for ultimate traceability (though this might be complex).

#### 3.2.4. Error Reporting

*   Sentry will automatically capture unhandled exceptions within request handlers.
*   For handled errors, manually send them to Sentry: `sentry_sdk.capture_exception(e)` or `sentry_sdk.capture_message("Failed to process recommendation", level="warning")`.
*   Ensure exceptions are logged appropriately before or alongside being sent to Sentry.

## 4. Local Development & Testing

To prevent pollution of error tracking dashboards and ensure tests run in isolation:

*   **Local Development:**
    *   Use dummy or development-specific DSNs for Sentry and Firebase Crashlytics.
    *   Consider disabling crash reporting in local debug builds by configuring the SDKs accordingly (e.g., `Sentry.close()` or `FirebaseCrashlytics.setCrashlyticsCollectionEnabled(false)` based on a build flag or environment variable like `IS_DEBUG_MODE`).
*   **Testing (Unit/Widget/Integration):**
    *   Mock Sentry and Firebase Crashlytics SDKs using libraries like `mocktail` to prevent actual network calls during tests.
    *   *Example (using `mocktail`):*
        ```dart
        // In your test file
        import 'package:mocktail/mocktail.dart';
        import 'package:sentry_flutter/sentry_flutter.dart';

        class MockSentry extends Mock implements Sentry {}

        void main() {
          late MockSentry mockSentry;

          setUp(() {
            mockSentry = MockSentry();
            // Register fallback values for any methods that need them
            registerFallbackValue(Breadcrumb(level: SentryLevel.info, message: 'test')));
            registerFallbackValue(
                SentryEvent(level: SentryLevel.error, message: SentryMessage('test'))));
          });

          test('MyNotifier handles error and reports to Sentry', () async {
            when(() => mockSentry.captureException(any(), stackTrace: any(named: 'stackTrace')))
                .thenAnswer((_) async {});
            
            // Inject the mock into your system under test
            // e.g., via a dependency injection mechanism or by overriding the Sentry static methods (less ideal)
            
            // Perform the action that triggers the error
            
            // Verify the mock was called
            verify(() => mockSentry.captureException(any(), stackTrace: any(named: 'stackTrace'))).called(1);
          });
        }
        ```
*   **CI Environment:**
    *   Similar to local development, use environment variables to disable or configure Sentry/Firebase for test runs within the CI pipeline (e.g., `SENTRY_DRY_RUN=true` or `DISABLE_CRASH_REPORTING=true`).

## 5. Best Practices

*   **Consistent `X-Request-ID`:** Ensure the `X-Request-ID` is consistently generated, passed, and logged across all tiers (Flutter -> FastAPI -> Supabase if possible).
*   **Sanitize Logs:** Never log sensitive user data (PII), passwords, or tokens. Use placeholders or hash sensitive values if logging is absolutely necessary for debugging.
*   **Manage Log Volume:** Be mindful of log volume, especially at `DEBUG` and `INFO` levels in production. Excessive logging can impact performance and increase costs.
*   **Use Breadcrumbs (Sentry):** Utilize Sentry's automatic breadcrumbs and add manual ones for key user actions and state changes to provide rich context for error diagnosis.
*   **Monitor Key Metrics:** Define and monitor key performance and business metrics as outlined in `Monitoring ve Business Metrics.pdf`. Use tools like Sentry Performance Monitoring or custom dashboards.
*   **Alerting:** Configure alerts in Sentry/Crashlytics/Cloud Monitoring for critical errors, high error rates, or performance degradation to ensure prompt response.
*   **Retention Policies:** Define log and error report retention policies based on compliance requirements and storage costs.

## 6. Integration with Other Systems

*   **CI/CD (`CI_CD_GUIDE.md`):** Ensure monitoring tools are correctly configured in CI/CD environments. Tests might mock Sentry calls to prevent test pollution.
*   **Onboarding (`Dokümantasyon ve Onboarding.pdf`):** The setup process for local development should include configuring monitoring tools (e.g., using dummy DSNs or disabling them in dev mode).
*   **Security (`Güvenlik ve Privacy Compliance.pdf`):** Ensure logging and error reporting practices comply with data privacy regulations. Avoid logging PII.

