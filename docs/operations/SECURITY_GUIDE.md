# Aura Security Guide

This document outlines the security practices and measures implemented in the Aura application, covering both the Flutter frontend and the FastAPI backend. It details authentication, data protection, secure communication, and dependency management to ensure user data safety and application integrity.

It is designed to align with the architectural principles in `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf` and the compliance requirements outlined in `Güvenlik ve Privacy Compliance.pdf`. It also considers scalability aspects mentioned in `Push Notification ve Engagement.pdf`.

## 1. Overview

Security is a fundamental aspect of the Aura application, protecting user privacy and ensuring trust. This guide defines the core security principles and the specific mechanisms employed to safeguard data in transit, at rest, and during processing.

This strategy aligns with the architectural decisions in `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf` and the compliance requirements outlined in `Güvenlik ve Privacy Compliance.pdf`.

## 2. Core Security Principles

*   **Defense in Depth:** Implement security measures at every layer (network, application, data).
*   **Principle of Least Privilege:** Components and services should operate with the minimum necessary permissions.
*   **Secure by Default:** Security configurations should be secure out-of-the-box, requiring explicit action to weaken them.
*   **Fail Securely:** The application should handle errors and failures in a way that does not compromise security.
*   **Data Minimization:** Collect and store only the data that is absolutely necessary.

## 3. Authentication & Authorization

### 3.1. User Authentication (Supabase Auth)

*   **Provider:** Aura relies on Supabase Authentication for user sign-up, login, password reset, and session management. This offloads core authentication security to a managed, well-audited service.
*   **Supported Methods:** Email/Password, potentially OAuth (Google, Apple) in the future.
*   **Tokens:** Supabase issues JWT (JSON Web Tokens) upon successful login. These tokens contain user identity and claims.

### 3.2. Frontend (Flutter) - Token Management

*   **Storage:** Store the Supabase JWT securely. Use `flutter_secure_storage` to persist the token on the device. This encrypts the token at rest using platform-specific secure keystores (Android Keystore, iOS Keychain). Avoid storing tokens in `shared_preferences` or plain text files.
    *   *Reference:* `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf` pg 2 mentions using `flutter_secure_storage`.
*   **Usage:** The Supabase Flutter SDK (`supabase_flutter`) typically manages the token lifecycle (storage, refresh, attachment to requests) automatically. Ensure it's configured correctly.
*   **Transmission:** The Supabase SDK automatically attaches the JWT to requests made to Supabase services (Database, Storage, Functions).

### 3.3. Backend (FastAPI) - JWT Validation

*   **Verification:** The FastAPI backend must validate the JWT received from the Flutter frontend for every protected endpoint.
*   **Library:** Use a robust JWT library like `jose` (or `PyJWT`) in Python.
*   **Process:**
    1.  Extract the JWT from the `Authorization: Bearer <token>` header of incoming HTTP requests.
    2.  Use the Supabase project's `JWT_SECRET` (stored securely as an environment variable in FastAPI) to verify the token's signature.
    3.  Check the token's expiration (`exp` claim).
    4.  Decode the token to extract user information (e.g., `sub` for user ID).
    5.  If validation fails, return a `401 Unauthorized` or `403 Forbidden` response.
*   **Authorization:** After validating the JWT, use the extracted user ID to determine if the user is authorized to perform the requested action on the specific resource (e.g., can user X modify item Y?). This often involves checking user roles/claims within the JWT or querying the database for permissions.

### 3.4. Session Management & Token Refresh

*   **Automatic Refresh:** The Supabase Flutter SDK handles automatic token refresh using refresh tokens. When the access token expires, the SDK will attempt to use the refresh token to get a new one silently.
*   **Considerations:** While automatic refresh is convenient, be mindful of long-lived sessions. Ensure that session duration aligns with your application's risk profile. The Supabase `authStateChanges` stream can be listened to in Flutter to react to login/logout/refresh events and update the UI accordingly.

### 3.5. API Communication Security

*   **HTTPS/TLS:** All communication between the Flutter app and Supabase, as well as between the Flutter app and the FastAPI backend, *must* occur over HTTPS (TLS). This encrypts data in transit. Ensure the backend is configured to enforce HTTPS.
*   **Certificate Pinning (Advanced):** For highly sensitive applications, consider implementing certificate pinning on the Flutter side to prevent man-in-the-middle attacks by trusting only specific certificates or Certificate Authorities. This adds complexity and maintenance overhead. See section 9.1 for details.

## 4. Data Protection

### 4.1. Data in Transit

*   **Encryption:** As stated in `Güvenlik ve Privacy Compliance.pdf` pg 2, all network traffic is encrypted using TLS. This is handled by the underlying infrastructure (HTTPS for web requests, secure connections for Supabase client).
*   **API Keys:** Never hardcode API keys, Supabase URL/keys, or the FastAPI `JWT_SECRET` in the source code. Use environment variables. For Flutter, use build-time variables (`--dart-define`) or secure storage for runtime secrets if absolutely necessary (preferably managed by the backend).

### 4.2. Data at Rest

*   **Supabase Database:** Data stored in the Supabase PostgreSQL database is managed by Supabase. Check Supabase's documentation for their encryption practices at rest.
*   **Supabase Storage:** Files stored in Supabase Storage are managed by Supabase. Check Supabase's documentation for their encryption practices at rest.
*   **FastAPI Server:** Data processed or temporarily stored by the FastAPI backend should be handled securely. If the backend connects directly to the database, ensure the connection is secure.
*   **Local Device Storage (Flutter):**
    *   **Sensitive Data:** Any sensitive user data stored locally (e.g., cached personal information beyond standard app data, although this is minimized by the offline strategy in `OFFLINE_STRATEGY.md`) *must* be encrypted. Use platform-level encryption or libraries like `flutter_secure_storage` (which uses platform keystores) for key-value data.
    *   **Local Database (e.g., SQLite):** If the local database (`drift`/`floor`) in `OFFLINE_STRATEGY.md` stores any data that could be sensitive or user-identifiable, consider encrypting the database file itself or the data within it. See section 9.2 for options.

## 5. Secure Coding Practices

### 5.1. Input Validation

*   **Rigorously validate and sanitize all inputs**, especially data received from API requests (in FastAPI) or user forms (in Flutter). Use Pydantic models in FastAPI and appropriate validation in Flutter forms. This prevents injection attacks (SQL, NoSQL, command).

### 5.2. Dependency Management

*   **Keep all dependencies (Flutter/Dart packages, Python libraries) up-to-date.** Regularly audit dependencies for known vulnerabilities using tools like `pub outdated`/`pub audit` for Dart and `pip-audit` or `safety` for Python. `Kod Kalitesi ve Statik Analiz.pdf` pg 1 mentions `pub outdated`.

### 5.3. Error Handling

*   **Avoid exposing sensitive internal information** (stack traces, file paths, database details) in error messages sent to the client (Flutter app or end-user). Log errors securely on the backend (FastAPI) with appropriate detail for developers, but return generic error messages to the frontend. See `Error Handling ve User Experience.pdf`.
*   **Graceful Degradation:** Ensure the application degrades gracefully under stress or attack. For example, if a non-critical service is overwhelmed, temporarily disable it or fall back to a simpler mode rather than crashing the entire application. This ties into resilience principles like the "Kill‑Switch" mentioned in `AURA PROJESİ - NİHAİ TASARIM VE STRATEJİ DÖKÜMANI (V3.0 - Tam Metin).docx`.

### 5.4. Secure Storage of Secrets

*   **Never commit secrets** (API keys, passwords, JWT secrets) to the version control system (Git). Use environment variables and secure secret management systems (like those provided by your deployment platform or cloud provider). Codemagic's environment variable management is relevant here (`CI_CD Süreci.pdf`).

### 5.5. API Security (FastAPI)

*   **Rate Limiting:** Implement rate limiting on API endpoints, especially authentication-related ones (login, signup, password reset), to prevent brute-force attacks and abuse. This is crucial for maintaining service availability, especially under high load scenarios like mass push notifications.
    *   **Tool:** Use libraries like `slowapi` for FastAPI.
    *   **Example Configuration:**
        ```python
        from slowapi import Limiter, _rate_limit_exceeded_handler
        from slowapi.util import get_remote_address
        from slowapi.errors import RateLimitExceeded

        # In your FastAPI app setup
        limiter = Limiter(key_func=get_remote_address)
        app.state.limiter = limiter
        app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

        # On a specific route
        @app.post("/login")
        @limiter.limit("5/minute") # Max 5 requests per minute per IP
        async def login(request: Request, user_credentials: UserLogin):
            # ... login logic ...
        ```
    *   **Scalability Note:** As noted in `Push Notification ve Engagement.pdf`, backend services for features like push notifications might need horizontal scaling. Rate limiting must be designed to work correctly in a scaled-out environment. This often involves using a shared store (like Redis) for `slowapi` to track request counts across all instances, ensuring the limit is global, not per-instance. Failure to do so can render rate limiting ineffective under load.
*   **Other Measures:** Consider CAPTCHA for highly sensitive or public-facing endpoints if necessary.

## 6. Third-Party Libraries & Services

*   **Vetting:** Before adding a new third-party library (pub.dev package or PyPI library), evaluate its:
    *   Popularity and community support.
    *   Maintenance status (recent updates, open issues).
    *   Security history (check for known vulnerabilities).
    *   Licensing terms.
*   **Minimization:** Use only the libraries that are necessary. Each dependency increases the potential attack surface.
*   **Monitoring:** Regularly review and update third-party dependencies to patch vulnerabilities.

## 7. Monitoring & Logging

*   **Security Logging:** Log security-relevant events on the backend (FastAPI), such as failed login attempts, authorization failures, and potential injection attempts. Ensure logs do not contain sensitive user data (PII, passwords, full tokens). `MONITORING_AND_LOGGING.md` details logging practices.
*   **Monitoring:** Use tools like Sentry (mentioned in `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf` and `Monitoring ve Business Metrics.pdf`) to monitor for errors that might indicate security issues or application problems that could be exploited.

## 8. Privacy Compliance

*   **Data Handling:** Ensure data collection, processing, and storage comply with relevant regulations (e.g., GDPR, KVKK - as mentioned in `Güvenlik ve Privacy Compliance.pdf`). This includes obtaining proper consent, providing data access/deletion rights, and minimizing data collection.
*   **User Consent:** Clearly inform users about data usage, especially for features like analytics or crash reporting (Sentry, Firebase Crashlytics).

## 9. Advanced Security Topics

### 9.1. Certificate Pinning (Flutter - Advanced)

*   **Purpose:** To defend against man-in-the-middle (MITM) attacks by ensuring the app only trusts specific server certificates or Certificate Authorities (CAs).
*   **Implementation:**
    1.  **Obtain Server Certificate:** Get the public certificate (`.crt` or `.pem`) from your backend server or the CA.
    2.  **Add to App Bundle:** Include the certificate file in your Flutter app's assets.
    3.  **Configure HTTP Client:** Use `HttpClient` from `dart:io` and set a custom `SecurityContext`.
    *   *Example (Conceptual):*
        ```dart
        import 'dart:io';
        import 'package:flutter/services.dart' show rootBundle;

        Future<HttpClient> createPinnedHttpClient() async {
          final sslContext = SecurityContext(withTrustedRoots: false); // Only trust our pinned cert
          
          // Load the certificate from assets
          final certData = await rootBundle.load('assets/certs/your_backend_cert.pem');
          final certString = String.fromCharCodes(certData.toList());
          
          sslContext.setTrustedCertificatesBytes(certData.buffer.asUint8List());
          
          final client = HttpClient(context: sslContext);
          return client;
        }

        // Use this client for your custom API calls (not Supabase, as its SDK handles this)
        // For Dio:
        // final dio = Dio();
        // dio.httpClientAdapter = Http2Adapter(ConnectionManager(onClientCreate: (uri, client) {
        //   client.badCertificateCallback = ... // Handle pinning logic here if needed
        // })); 
        ```
*   **Note:** This is complex and makes certificate rotation harder. Only use if the risk justifies the complexity.

### 9.2. Local Database Encryption (Flutter)

*   **Challenge:** Standard SQLite wrappers like `drift` or `floor` do not provide built-in database-level encryption.
*   **Options:**
    *   **SQLCipher:** A SQLite extension that provides transparent 256-bit AES encryption. Integrating SQLCipher with Flutter can be challenging.
        *   **Potential Approach:** Use `sqflite_common_ffi` combined with a SQLCipher-enabled SQLite library (like `sqlite3_flutter_libs` with SQLCipher support, if available/configurable) and `drift`. This requires significant setup and might not be straightforward.
    *   **Application-Level Encryption:** Encrypt sensitive data fields *before* storing them in the local database using libraries like `encrypt`. This is often simpler and more portable.
        *   **Recommendation:** For most use cases, encrypting sensitive fields at the application level using `encrypt` and storing the encryption key securely in `flutter_secure_storage` is a practical and effective solution.
    *   **Minimize Sensitive Local Data:** Adhere to the data minimization principle. Store as little sensitive data locally as possible.

### 9.3. Audit Trails

*   **Purpose:** To track "who did what, when" for critical operations (e.g., deleting user data, changing permissions, making purchases).
*   **Implementation:**
    *   **Database Table:** Create a dedicated table in your Supabase database (e.g., `audit_logs`).
        ```sql
        -- Example audit_logs table structure
        CREATE TABLE audit_logs (
            id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
            user_id UUID REFERENCES auth.users(id), -- User who performed the action
            action TEXT NOT NULL, -- e.g., 'delete_item', 'update_profile'
            resource_type TEXT, -- e.g., 'clothing_item', 'user_profile'
            resource_id UUID, -- ID of the affected resource
            details JSONB, -- Optional: Additional context/details about the action
            ip_address INET, -- Optional: IP of the request (captured by backend)
            user_agent TEXT, -- Optional: Client info
            created_at TIMESTAMPTZ DEFAULT NOW()
        );
        ```
    *   **Logging:** In your FastAPI backend (or Supabase Edge Functions for specific actions), whenever a critical action occurs, insert a record into the `audit_logs` table.
    *   **Benefits:** Crucial for security investigations, compliance audits, and understanding user behavior for high-stakes actions.

### 9.4. Threat Modeling Examples

Understanding potential threats helps in designing effective defenses. Here are common scenarios for Aura:

*   **Threat:** An attacker gains access to a user's device and steals the Supabase JWT from insecure storage.
    *   **Impact:** Attacker can impersonate the user and access/modify their data until the token expires or is revoked.
    *   **Mitigation:** Use `flutter_secure_storage` (Risk Level: High -> Mitigated). Implement short-lived access tokens and rely on refresh tokens.
*   **Threat:** An attacker performs a brute-force attack on the login endpoint.
    *   **Impact:** Could lead to account takeover if successful, or service disruption.
    *   **Mitigation:** Implement rate limiting (Risk Level: High -> Mitigated). Use CAPTCHA for repeated failures.
*   **Threat:** An attacker intercepts network traffic (e.g., on public Wi-Fi).
    *   **Impact:** Sensitive data (tokens, user info) can be stolen.
    *   **Mitigation:** Enforce HTTPS/TLS for all communications (Risk Level: Critical -> Mitigated). Consider Certificate Pinning for high-risk apps.
*   **Threat:** Sensitive data in the local database (SQLite) is accessed if the device is compromised.
    *   **Impact:** User's wardrobe, combinations, personal style data exposed.
    *   **Mitigation:** Encrypt sensitive local data (Risk Level: High -> Mitigated). Minimize the amount of sensitive data stored locally.
*   **Threat:** A vulnerability in a third-party library is exploited.
    *   **Impact:** Could lead to arbitrary code execution, data theft, or app compromise.
    *   **Mitigation:** Vet dependencies carefully, keep them updated, and monitor for vulnerabilities (Risk Level: High -> Mitigated).

### 9.5. Secret Rotation

Rotating secrets like the Supabase `JWT_SECRET` is crucial for long-term security.

*   **Strategy:**
    1.  **Dual Key Support (Preferred):** Modify your FastAPI backend to accept *either* the old JWT secret or the new one for a period.
        ```python
        # In your JWT validation logic
        def verify_jwt(token: str):
            # Try verifying with the NEW secret first
            try:
                payload = jwt.decode(token, NEW_JWT_SECRET, algorithms=["HS256"])
                return payload
            except jwt.InvalidSignatureError:
                # If that fails, try the OLD secret
                try:
                    payload = jwt.decode(token, OLD_JWT_SECRET, algorithms=["HS256"])
                    # Optionally, trigger a background task to re-issue a token with the new secret
                    return payload
                except jwt.InvalidSignatureError:
                    raise HTTPException(status_code=401, detail="Invalid token")
        ```
    2.  **Deployment:** Deploy the updated backend code that supports both secrets.
    3.  **Switch Secrets:** Update the Supabase project's `JWT_SECRET` to the new value via the Supabase dashboard/console.
    4.  **Cleanup:** After a grace period (longer than the maximum token lifetime), remove support for the old secret from the backend code and redeploy.
*   **Benefits:** Allows secret changes without application downtime or forcing all users to log out immediately.
*   **Operational Risk:** Ensures long-term secret hygiene.
