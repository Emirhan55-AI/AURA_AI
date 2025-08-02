# Aura CI/CD Guide

This document describes the Continuous Integration (CI) and Continuous Deployment (CD) processes for the Aura application. It covers the setup, workflows, and tools used to automate building, testing, and deploying both the Flutter frontend and the FastAPI backend services.

## 1. Overview

Continuous Integration and Continuous Deployment are critical for maintaining code quality, enabling rapid iteration, and ensuring reliable releases for Aura. This process is managed using **Codemagic**, a CI/CD platform well-suited for Flutter projects and capable of handling multi-repository or monorepo setups. See `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf` for the rationale behind the chosen tools and architecture.

The primary goals are:
*   Automate testing (unit, widget, integration) on every code change (Pull Request, merge to `main`).
*   Automate building and packaging for iOS (IPA) and Android (AAB).
*   Automate deployment of the Flutter app to distribution channels (e.g., Firebase App Distribution, TestFlight).
*   Automate building and deploying the FastAPI backend (e.g., to a cloud provider using Docker).
*   Provide fast feedback to developers.
*   Ensure a consistent and reproducible build environment. (See `Dokümantasyon ve Onboarding.pdf` for ensuring local environments match CI).

## 2. Core Concepts

*   **Monorepo:** The project structure (as defined in `ARCHITECTURE.md`) places the Flutter app (`apps/flutter_app`) and FastAPI service (`apps/fastapi_service`) within a single repository. The CI/CD configuration must handle this structure.
*   **Workflows:** Codemagic uses `workflows` defined in `codemagic.yaml` (or the UI, but file-based config is preferred for version control) to define distinct CI/CD processes (e.g., one for Flutter, one for FastAPI).
*   **Triggers:** Workflows are automatically triggered by events like `git push` to specific branches (e.g., `main`) or by creating tags, or by opening/ updating a Pull Request.
*   **Artifacts:** Build outputs (like `.aab`, `.ipa`, Docker images, test reports) are stored and can be downloaded or used in subsequent steps.

## 3. Tooling & Configuration

*   **Platform:** Codemagic
*   **Configuration File:** `codemagic.yaml` (Located at the root of the monorepo)
*   **Secrets Management:** Sensitive information like API keys, signing credentials, and Supabase/Firebase secrets are stored securely in Codemagic's environment variable settings, not in the `codemagic.yaml` file. They are referenced in the YAML using `$VAR_NAME`.
*   **Caching:** Codemagic's caching mechanisms are used to speed up builds by reusing dependencies (e.g., Flutter pub cache, Python pip cache) and build artifacts where appropriate.

## 4. Flutter App CI/CD Workflow

This workflow handles the Flutter application located in `apps/flutter_app/`.

### 4.1. Workflow Trigger

*   **On Pull Request:** Run on PR creation/update to `main` branch for quick feedback.
*   **On Push to `main`:** Run after merge to `main` for integration testing and potential deployment to a staging environment.
*   **On Tag (e.g., `v*.*.*`):** Run for release builds to be deployed to production distribution channels.

### 4.2. Workflow Steps (`apps/flutter_app/codemagic.yaml` section example)

1.  **Checkout Code:** Pull the latest code from the repository.
2.  **Setup Environment:**
    *   Install Flutter SDK (specify the version used in `apps/flutter_app/.tool-versions` or `fvm` config).
    *   Set up environment variables (e.g., `GOOGLE_SERVICE_INFO_PLIST`, `GOOGLE_SERVICES_JSON` for Firebase, Supabase URL/Anon Key).
3.  **Install Dependencies:**
    *   Run `flutter pub get` in the `apps/flutter_app` directory.
    *   (If using `melos` for monorepo): Run `melos bootstrap`.
4.  **(Conditional - PRs & `main` push) Run Tests:**
    *   Run unit tests: `flutter test` (in `apps/flutter_app`).
    *   Run widget tests: `flutter test test/widget` (in `apps/flutter_app`).
    *   Run integration tests: `flutter test integration_test` (in `apps/flutter_app`).
    *   Generate and upload coverage reports (e.g., to Codecov).
5.  **Build:**
    *   **Android:** `flutter build appbundle --release` (in `apps/flutter_app`). This generates `build/app/outputs/bundle/release/app-release.aab`.
    *   **iOS:** `flutter build ipa --release` (in `apps/flutter_app`). This generates `build/ios/ipa/*.ipa`.
6.  **(Conditional - Tag/Release) Deploy:**
    *   **Android:** Upload the `.aab` to Google Play Console (internal testing track, or a specified track).
    *   **iOS:** Upload the `.ipa` to App Store Connect and submit to TestFlight (or a specified group). (Requires proper Apple Developer account setup in Codemagic).
7.  **Post-Build:**
    *   Save build artifacts (`.aab`, `.ipa`, test reports) for download.
    *   Send notifications on failure/success (e.g., to Slack, Discord).

### 4.3. Key Considerations

*   **Code Signing (iOS):** Properly configure iOS code signing certificates and provisioning profiles in Codemagic. Use Codemagic's integrations with App Store Connect for automatic profile management if possible.
*   **Google Play Service Account:** For Android deployment, a Google Play Service Account key (`.json`) needs to be added to Codemagic.
*   **Environment Specific Builds:** Use Flutter's build flavors or environment variables (passed via `--dart-define`) to manage different configurations (dev, staging, prod) for API endpoints, analytics keys, etc.

## 5. FastAPI Backend CI/CD Workflow

This workflow handles the FastAPI service located in `apps/fastapi_service/`.

### 5.1. Workflow Trigger

*   **On Pull Request:** Run on PR creation/update to `main` branch that touches files within `apps/fastapi_service/` (using `changeset` conditions in `codemagic.yaml`).
*   **On Push to `main`:** Run after merge to `main` for integration testing and potential deployment to a staging environment.
*   **On Tag (e.g., `v*.*.*-api`):** Run for release builds to be deployed to production.

### 5.2. Workflow Steps (`apps/fastapi_service/codemagic.yaml` section example)

1.  **Checkout Code:** Pull the latest code from the repository.
2.  **Setup Environment:**
    *   Install Python (specify the version, e.g., 3.9+).
    *   Set up environment variables (e.g., `SUPABASE_URL`, `SUPABASE_JWT_SECRET`, `FASTAPI_ENV`).
3.  **Install Dependencies:**
    *   Run `pip install -r apps/fastapi_service/requirements.txt`.
4.  **(Conditional - PRs & `main` push) Run Tests:**
    *   Run unit and integration tests: `cd apps/fastapi_service && python -m pytest tests/`.
    *   (Optional) Run linting: `cd apps/fastapi_service && flake8 .` or `ruff check .`.
5.  **Build (Containerize):**
    *   Build a Docker image: `cd apps/fastapi_service && docker build -t aura-fastapi:$CM_COMMIT .`. The `$CM_COMMIT` variable is a Codemagic built-in for the commit hash.
6.  **(Conditional - Tag/Release) Deploy:**
    *   Tag the Docker image for the registry: `docker tag aura-fastapi:$CM_COMMIT gcr.io/your-project-id/aura-fastapi:$CM_TAG` (or your registry).
    *   Push the image to a container registry (e.g., Google Container Registry, Docker Hub): `docker push gcr.io/your-project-id/aura-fastapi:$CM_TAG`.
    *   Deploy the image to the hosting platform (e.g., Google Cloud Run, Render, Heroku). This might involve:
        *   Using platform-specific CLI tools (authenticated via Codemagic secrets).
        *   Updating a deployment configuration file (YAML, Terraform) and applying it.
        *   Triggering a deployment webhook.
7.  **Post-Build:**
    *   Save relevant artifacts (test reports, Docker image info).
    *   Send notifications on failure/success.

### 5.3. Key Considerations

*   **Dockerfile:** Ensure `apps/fastapi_service/Dockerfile` is correctly configured for the application.
*   **Cloud Provider Integration:** Specific steps for deployment will depend on the chosen cloud provider (GCP, AWS, Azure, Render, etc.). Codemagic needs the necessary credentials/configurations to interact with these services.
*   **Database Migrations:** If the backend update includes database schema changes, the deployment process must include a safe way to run migrations. This is often a separate, carefully orchestrated step.

## 6. `codemagic.yaml` Structure (Conceptual Example)

This shows how the two workflows might be structured within a single `codemagic.yaml` file at the root of the monorepo. See `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf` pg 65 for a basic structure reference.

```yaml
# codemagic.yaml
workflows:
  flutter-app-workflow:
    name: Flutter App Pipeline
    # Define triggering conditions (branches, tags, PRs)
    triggering:
      events:
        - pull_request
        - push
        - tag
      branch_patterns:
        - pattern: main
          include: true
          source: true
      tag_patterns:
        - pattern: 'v*.*.*'
    # Define environment, scripts, and artifacts for Flutter
    environment:
      flutter: stable # or specific version
      vars:
        # Environment variables for Flutter (Firebase keys, etc.)
        SUPABASE_URL: $SUPABASE_URL # From Codemagic secrets
        SUPABASE_ANON_KEY: $SUPABASE_ANON_KEY
    scripts:
      - name: Setup and Test Flutter
        script: |
          cd apps/flutter_app
          flutter pub get
          # Conditional test run based on trigger type if needed
          flutter test
      - name: Build Flutter Release
        script: |
          cd apps/flutter_app
          flutter build appbundle --release
          flutter build ipa --release
    artifacts:
      - apps/flutter_app/build/**/outputs/**/*.aab
      - apps/flutter_app/build/ios/ipa/*.ipa
    # Define deployment steps for Flutter (conditional on tag)
    publishing:
      google_play:
         # ... (config for Google Play)
      app_store_connect:
         # ... (config for ASC)
      
  fastapi-service-workflow:
    name: FastAPI Service Pipeline
    # Define triggering conditions, only for changes in fastapi_service dir
    triggering:
      events:
        - pull_request
        - push
        - tag
      branch_patterns:
        - pattern: main
          include: true
          source: true
      tag_patterns:
        - pattern: '*-api' # Tags ending with -api for backend releases
      # Only trigger if files in apps/fastapi_service changed
      when:
        changeset:
          includes:
            - 'apps/fastapi_service/**'
    # Define environment, scripts, and artifacts for FastAPI
    environment:
      python: 3.9 # or specific version
      vars:
        # Environment variables for FastAPI
        SUPABASE_URL: $SUPABASE_URL
        SUPABASE_JWT_SECRET: $SUPABASE_JWT_SECRET
        FASTAPI_ENV: staging # Default, can be overridden
    scripts:
      - name: Setup and Test FastAPI
        script: |
          cd apps/fastapi_service
          pip install -r requirements.txt
          python -m pytest tests/
      - name: Build FastAPI Docker Image
        script: |
          cd apps/fastapi_service
          docker build -t aura-fastapi:$CM_COMMIT .
          # Tag and push logic for releases would go here or in publishing
    artifacts:
      - docker-images/aura-fastapi-$CM_COMMIT.tar # If saving image locally
    # Define deployment steps for FastAPI (conditional on tag)
    publishing:
      scripts:
        - name: Deploy to Cloud (Example for GCR + Run)
          script: |
            # Authenticate to cloud provider using secrets
            # Tag image
            # Push image
            # Deploy using gcloud/cli or update config
            # This is highly dependent on the chosen cloud provider

```

## 7. Monitoring & Feedback

*   **Build Status:** Developers can monitor build status directly on the Pull Request (if integrated) or on the Codemagic dashboard.
*   **Notifications:** Configure Codemagic to send notifications (email, Slack, etc.) on build success/failure.
*   **Test Reports:** Test results and coverage reports should be viewable within the Codemagic UI or integrated tools (like Codecov).
*   **Onboarding (`Dokümantasyon ve Onboarding.pdf`):** The CI process itself validates the `onboarding` documentation. If a step like `make setup` or `make test` fails in CI, it indicates the documentation or the process is broken and needs fixing. This ensures documentation stays accurate.

## 8. Best Practices

*   **Keep `codemagic.yaml` in Version Control:** This ensures the CI/CD definition evolves with the codebase.
*   **Use `changeset` for Efficiency:** In a monorepo, use `changeset` conditions to ensure only relevant workflows run for a given change. (See `Hibrit Mimari Uygulama Rehberi Taslağı_.pdf` pg 65 example).
*   **Fail Fast:** Configure CI to run quick checks (linting, unit tests) first. If these fail, stop the pipeline early.
*   **Secure Secrets:** Never commit secrets to the repository. Use Codemagic's secure environment variable management.
*   **Automate Deployments Cautiously:** Automate deployments to staging environments. Consider manual approval steps for production deployments.
*   **Regular Review:** Periodically review and update the CI/CD configuration as the project and tools evolve.
