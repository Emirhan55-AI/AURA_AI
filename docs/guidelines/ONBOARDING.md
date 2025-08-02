# Aura Developer Onboarding Guide

This document provides a step-by-step guide for new developers to set up their local development environment for the Aura project and understand its basic structure. The goal is to get a new developer productive as quickly as possible (ideally within 1-2 hours).

## Table of Contents

1.  [Prerequisites](#1-prerequisites)
2.  [Cloning the Repository](#2-cloning-the-repository)
3.  [Environment Setup](#3-environment-setup)
    *   [3.1. Flutter Environment](#31-flutter-environment)
    *   [3.2. FastAPI Environment](#32-fastapi-environment)
    *   [3.3. Supabase CLI (Optional but Recommended)](#33-supabase-cli-optional-but-recommended)
    *   [3.4. Environment Variables](#34-environment-variables)
4.  [Installing Dependencies](#4-installing-dependencies)
5.  [Running the Applications Locally](#5-running-the-applications-locally)
    *   [5.1. Running the Flutter App](#51-running-the-flutter-app)
    *   [5.2. Running the FastAPI Backend](#52-running-the-fastapi-backend)
6.  [Running Tests](#6-running-tests)
7.  [Understanding the Project Structure](#7-understanding-the-project-structure)
    *   [7.1. Monorepo Layout](#71-monorepo-layout)
    *   [7.2. Flutter App Structure (`apps/flutter_app`)](#72-flutter-app-structure-appsflutter_app)
    *   [7.3. FastAPI Backend Structure (`apps/fastapi_service`)](#73-fastapi-backend-structure-appsfastapi_service)
8.  [Making Your First Contribution](#8-making-your-first-contribution)
9.  [Useful Resources & Documentation](#9-useful-resources--documentation)
10. [Troubleshooting](#10-troubleshooting)

## 1. Prerequisites

Before you begin, ensure you have the following installed on your system:

*   **Git:** For version control. [https://git-scm.com/](https://git-scm.com/)
*   **Dart SDK & Flutter:** The Flutter framework. [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
    *   *Note:* Aura uses a specific Flutter version. Check `apps/flutter_app/.tool-versions` or `apps/flutter_app/flutter_launcher.yaml` (if used) or consult the team for the exact version. Consider using `fvm` (Flutter Version Management) if multiple Flutter projects are managed.
*   **Python 3.9+:** For the FastAPI backend. [https://www.python.org/downloads/](https://www.python.org/downloads/)
*   **Docker (Optional but Recommended):** For containerizing the FastAPI backend and running Supabase locally. [https://docs.docker.com/get-docker/](https://docs.docker.com/get-docker/)
*   **IDE/Editor:**
    *   **Recommended for Flutter:** Android Studio/IntelliJ IDEA with Flutter/Dart plugins, or VS Code with Flutter/Dart extensions.
    *   **Recommended for FastAPI:** VS Code with Python extensions, or PyCharm.

## 2. Cloning the Repository

Clone the main Aura repository to your local machine:

```bash
# Clone the repository from the remote source
git clone https://github.com/your-organization/aura.git
# Navigate into the project directory
cd aura
```

## 3. Environment Setup

### 3.1. Flutter Environment

1.  **Verify Installation:** Ensure Flutter is correctly installed and added to your PATH.
    ```bash
    # Check the installed Flutter version
    flutter --version
    ```
2.  **Get Flutter Dependencies:** Navigate to the Flutter app directory and fetch dependencies.
    ```bash
    # Change directory to the Flutter app
    cd apps/flutter_app
    # Fetch and get Flutter packages
    flutter pub get
    ```
3.  **(If using `fvm`):** Install the correct Flutter version.
    ```bash
    # In apps/flutter_app directory
    # Install the Flutter version specified in .fvmrc or .tool-versions
    fvm install
    # Set the local Flutter version for this project
    fvm use
    ```

### 3.2. FastAPI Environment

1.  **Create Virtual Environment (Recommended):** It's good practice to isolate Python dependencies.
    ```bash
    # Navigate to the backend directory from apps/flutter_app
    cd ../fastapi_service
    # Create a virtual environment named 'venv'
    python -m venv venv
    # Activate the virtual environment
    # On Windows:
    # venv\Scripts\activate
    # On macOS/Linux:
    # Activate the virtual environment for Python isolation
    source venv/bin/activate
    ```
2.  **Install Python Dependencies:**
    ```bash
    # Ensure you are in the activated virtual environment and apps/fastapi_service directory
    # Install required Python packages from requirements.txt
    pip install -r requirements.txt
    ```

### 3.3. Supabase CLI (Optional but Recommended)

The Supabase CLI is useful for local development and interacting with your Supabase project.

1.  **Install Supabase CLI:** Follow the instructions for your OS: [https://supabase.com/docs/guides/cli/getting-started](https://supabase.com/docs/guides/cli/getting-started)
2.  **Login (if needed for specific CLI commands):**
    ```bash
    # Log in to your Supabase account (may be required for some remote operations)
    supabase login
    ```
3.  **(Optional) Start Local Supabase:** For local development without needing the cloud Supabase project.
    ```bash
    # Start the local Supabase stack (Postgres, Auth, Storage, etc.)
    # This requires Docker to be running
    supabase start
    ```

### 3.4. Environment Variables

The applications require specific environment variables to connect to services like Supabase.

1.  **Locate `.env.example`:** Find the `.env.example` file in the root of the monorepo or within `apps/flutter_app` and `apps/fastapi_service`.
2.  **Copy and Configure:** Copy `.env.example` to `.env` in the same directory and fill in the required values (Supabase URL, Anon Key, JWT Secret for FastAPI, etc.). You will need to obtain these from your project lead or the project's secure secret store (e.g., Codemagic environment variables - see `CI_CD_GUIDE.md`).
    *   **Flutter App (`.env` in `apps/flutter_app`):** Typically needs `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
        *   *Note:* Flutter does not load `.env` files natively. If the project uses `flutter_dotenv`, ensure it's initialized early in `main.dart` to load these variables.
    *   **FastAPI Backend (`.env` in `apps/fastapi_service`):** Typically needs `SUPABASE_URL` and `SUPABASE_JWT_SECRET`.

## 4. Installing Dependencies

We use `melos` to manage dependencies and run commands across the monorepo.

1.  **Install Melos (if not already installed globally):**
    ```bash
    # Activate melos globally using Dart pub
    dart pub global activate melos
    ```
2.  **Bootstrap the Workspace:** This installs dependencies for all packages/apps defined in `melos.yaml`.
    ```bash
    # Run this in the root of the monorepo to set up all dependencies
    melos bootstrap
    ```

## 5. Running the Applications Locally

### 5.1. Running the Flutter App

1.  **Ensure Environment Variables are Set:** Double-check your `.env` file in `apps/flutter_app`.
2.  **Connect a Device or Start an Emulator/Simulator.**
3.  **Run the App:**
    ```bash
    # Make sure you are in the apps/flutter_app directory
    # Run the Flutter application on the connected device/emulator
    flutter run
    ```
    *   **(If using `fvm`):**
        ```bash
        # Run using the Flutter version managed by fvm
        fvm flutter run
        ```

### 5.2. Running the FastAPI Backend

1.  **Ensure Virtual Environment is Activated:** You should see the `(venv)` prefix in your terminal.
2.  **Ensure Environment Variables are Set:** Double-check your `.env` file in `apps/fastapi_service`.
3.  **Run the Development Server:**
    ```bash
    # Make sure you are in the apps/fastapi_service directory and venv is activated
    # Start the FastAPI development server with auto-reload
    uvicorn main:app --reload
    ```
    *   This will start the FastAPI server, usually on `http://127.0.0.1:8000`. You can access the auto-generated API docs at `http://127.0.0.1:8000/docs`.

## 6. Running Tests

Testing is a crucial part of development. See `TESTING_STRATEGY.md` for a full overview.

*   **Flutter Tests:**
    ```bash
    # In apps/flutter_app directory
    # Run unit and widget tests
    flutter test
    # flutter test integration_test # Runs integration tests (if set up)
    ```
*   **FastAPI Tests:**
    ```bash
    # In apps/fastapi_service directory, with venv activated
    # Run unit and integration tests for the backend using pytest
    python -m pytest tests/
    ```

## 7. Understanding the Project Structure

### 7.1. Monorepo Layout

The project follows a monorepo structure managed by `melos` (as defined in `ARCHITECTURE.md`).

```
aura/ (project root)
├── apps/
│   ├── flutter_app/        # The main Flutter mobile application
│   └── fastapi_service/    # The Python FastAPI backend service
├── packages/               # (Optional) Shared code packages (if used)
│   └── ...                 # (e.g., shared_models, ui_kit)
├── docs/                   # Project documentation files (.md guides)
├── melos.yaml              # Melos configuration for the monorepo
├── .gitignore
├── README.md
└── ...
```

### 7.2. Flutter App Structure (`apps/flutter_app`)

Follows a Feature-First Clean Architecture approach (as detailed in `ARCHITECTURE.md`).

```
apps/flutter_app/
├── lib/
│   ├── core/              # Core functionalities, shared utilities, base classes
│   │   ├── domain/        # Core business logic, entities, base repositories
│   │   ├── data/          # Core data sources, base API clients
│   │   └── presentation/  # Core presentation logic (e.g., base widgets, themes)
│   ├── features/          # Application features/modules
│   │   ├── auth/          # Authentication feature
│   │   │   ├── presentation/
│   │   │   ├── application/
│   │   │   ├── domain/
│   │   │   └── data/
│   │   ├── wardrobe/      # Wardrobe management feature
│   │   │   ├── presentation/
│   │   │   ├── application/
│   │   │   ├── domain/
│   │   │   └── data/
│   │   └── ...            # Other features (e.g., style_assistant, swap_market)
│   ├── shared/            # Widgets and models shared across features
│   └── main.dart          # Application entry point
├── test/                  # Unit and widget tests
├── integration_test/      # Integration tests
├── pubspec.yaml           # Flutter dependencies
├── .env                   # Local environment variables (not committed)
└── ...
```

### 7.3. FastAPI Backend Structure (`apps/fastapi_service`)

Follows a standard Python project structure.

```
apps/fastapi_service/
├── app/
│   ├── api/               # API route definitions (v1, v2, etc.)
│   │   └── v1/
│   │       ├── routes/    # Individual route files (e.g., items.py, recommendations.py)
│   │       └── api.py     # Main API router
│   ├── core/              # Core configurations, security, logging
│   ├── models/            # Data models (if using ORM)
│   ├── schemas/           # Pydantic models for request/response validation
│   ├── services/          # Business logic implementation (e.g., ai_service.py)
│   └── main.py            # FastAPI application entry point
├── tests/                 # Unit and integration tests for the backend
├── requirements.txt       # Python dependencies
├── .env                   # Local environment variables (not committed)
└── ...
```

## 8. Making Your First Contribution

1.  **Choose an Issue:** Pick an issue from the project's issue tracker (e.g., GitHub Issues) or consult with the team.
2.  **Create a Branch:** Create a new branch for your work, following the project's branching strategy (e.g., `feature/issue-123-short-description`).
    ```bash
    # Create and switch to a new branch for your feature or fix
    git checkout -b feature/issue-123-add-user-profile
    ```
3.  **Make Changes:** Implement your feature or fix the bug.
4.  **Run Tests:** Ensure all relevant tests pass.
    ```bash
    # Run Flutter tests
    # Change to the Flutter app directory and run tests
    cd apps/flutter_app && flutter test
    # Run FastAPI tests (in fastapi_service dir with venv activated)
    # Navigate to the backend directory and run tests
    cd ../fastapi_service && python -m pytest tests/
    ```
5.  **Commit Changes:** Write clear, concise commit messages following the project's convention (e.g., Conventional Commits).
    ```bash
    # Stage all changes
    git add .
    # Commit with a descriptive message
    git commit -m "feat(profile): add user profile screen"
    ```
6.  **Push Branch & Create Pull Request:** Push your branch to the remote repository and open a Pull Request (PR) for review.
    ```bash
    # Push the new branch to the remote origin
    git push origin feature/issue-123-add-user-profile
    ```
    *   Follow the PR template if one exists.
7.  **Address Feedback:** Participate in the code review process and make necessary changes.
8.  **Merge:** Once approved, your PR will be merged into the main branch.

## 9. Useful Resources & Documentation

*   **Main README:** `README.md` (in the project root) - General project overview and quick start.
*   **Architecture:** `docs/ARCHITECTURE.md` - Overall system design.
*   **State Management:** `docs/STATE_MANAGEMENT.md` - How state is managed in the Flutter app.
*   **API Integration:** `docs/API_INTEGRATION.md` - Details on API communication strategies.
*   **Database Schema:** `docs/DATABASE_SCHEMA.md` - Structure of the Supabase database.
*   **Backend Services:** `docs/BACKEND_SERVICES.md` - Details of the FastAPI backend.
*   **Testing Strategy:** `docs/TESTING_STRATEGY.md` - How testing is approached.
*   **CI/CD Guide:** `docs/CI_CD_GUIDE.md` - Continuous integration and deployment setup.
*   **Monitoring & Logging:** `docs/MONITORING_AND_LOGGING.md` - How the app is monitored.
*   **Component List:** `docs/COMPONENT_LIST.md` - List of shared UI components.
*   **Style Guide:** `docs/STYLE_GUIDE.md` - UI/UX design principles and code style.
*   **Other Guides:** Explore the `docs/` directory for more specific guides.

## 10. Troubleshooting

*   **Dependency Issues:** Run `melos bootstrap` again. Ensure you are using the correct Flutter/Python versions.
*   **Environment Variables Not Loaded:** Double-check the `.env` file paths and contents. Ensure the app is restarted after changes. For Flutter, verify `flutter_dotenv` setup.
*   **Flutter Build Failures:** Run `flutter clean` in the `apps/flutter_app` directory and then `flutter pub get`.
*   **FastAPI Errors:** Check the terminal output for specific error messages. Ensure all environment variables are set correctly and dependencies are installed.
*   **General Help:** Reach out to the team on the designated communication channel (e.g., Slack, Discord).
