# Aura Contribution Guide

Thank you for your interest in contributing to Aura! This document outlines the guidelines and processes for contributing code, documentation, and other improvements to the project. Following these guidelines helps ensure high-quality contributions and a smooth collaboration experience for everyone involved.

This guide complements the onboarding process described in `ONBOARDING.md` and the coding practices in `Kod Kalitesi ve Statik Analiz.pdf`.

## Table of Contents

1.  [Code of Conduct](#1-code-of-conduct)
2.  [Getting Started](#2-getting-started)
3.  [How to Contribute](#3-how-to-contribute)
    *   [Reporting Bugs](#reporting-bugs)
    *   [Suggesting Enhancements](#suggesting-enhancements)
    *   [Working on Issues](#working-on-issues)
4.  [Development Workflow](#4-development-workflow)
    *   [Branching Strategy](#branching-strategy)
    *   [Coding Standards](#coding-standards)
    *   [Documentation](#documentation)
    *   [Testing](#testing)
5.  [Submitting Changes (Pull Requests)](#5-submitting-changes-pull-requests)
    *   [Pull Request Process](#pull-request-process)
    *   [Code Review Guidelines](#code-review-guidelines)
6.  [Community](#6-community)

## 1. Code of Conduct

Please note that this project is released with a Contributor Code of Conduct (TBD - link to actual CODE_OF_CONDUCT.md if exists, or state it's expected to be respectful and professional). By participating in this project, you agree to abide by its terms.

## 2. Getting Started

Before you start contributing, please make sure you have:

1.  **Read the Onboarding Guide:** Familiarize yourself with the project structure and setup by reading `docs/ONBOARDING.md`. This will get you up and running quickly.
2.  **Set Up Your Environment:** Follow the steps in `ONBOARDING.md` to configure your local development environment.
3.  **Understand the Architecture:** Review `docs/ARCHITECTURE.md` to grasp the overall design and structure of the application (Flutter Clean Architecture, FastAPI, Supabase integration).

## 3. How to Contribute

There are many ways to contribute to Aura:

### Reporting Bugs

*   **Check Existing Issues:** Before submitting a new bug report, please search the existing issues on GitHub to see if the problem has already been reported.
*   **Use the Bug Report Template:** If you find a new bug, create a new issue using the "Bug Report" template (if available). Provide as much detail as possible, including:
    *   Steps to reproduce the bug.
    *   Expected behavior.
    *   Actual behavior.
    *   Screenshots or logs, if applicable.
    *   Your environment (OS, Flutter version, device/emulator, etc.).

### Suggesting Enhancements

*   **Check Existing Issues:** Search for existing feature requests or enhancements.
*   **Use the Feature Request Template:** If your idea is new, create an issue using the "Feature Request" template. Clearly describe the proposed feature, its benefits, and any potential implementation ideas.

### Working on Issues

*   **Find an Issue:** Look through the GitHub issues for ones labeled `good first issue`, `help wanted`, or `bug`. Comment on the issue to let others know you are working on it.
*   **Create an Issue (if needed):** If you want to work on something not yet tracked by an issue, please create one first to discuss the approach and get approval.

## 4. Development Workflow

### Branching Strategy

*   **Main Branch (`main`):** This branch contains the production-ready code. Direct commits are restricted.
*   **Feature Branches:** For any new feature or bug fix, create a new branch from `main`.
    *   **Naming Convention:** Use a descriptive name, ideally prefixed with the issue number (if applicable). Examples:
        *   `feature/123-add-social-sharing`
        *   `bugfix/456-fix-crash-on-login`
        *   `improvement/update-readme`

### Coding Standards

*   **Follow the Style Guide:** Adhere to the coding conventions outlined in `docs/STYLE_GUIDE.md` for UI/UX and general code style.
*   **Language Specific Standards:**
    *   **Dart (Flutter):** Follow common Dart style guides. Use `dart format` for formatting. Refer to `Kod Kalitesi ve Statik Analiz.pdf` for linting rules (likely using `flutter_lints` or similar).
    *   **Python (FastAPI):** Follow PEP 8 style guide. Use a formatter like `black` and a linter like `flake8` or `ruff`. Refer to `Kod Kalitesi ve Statik Analiz.pdf`.
*   **Clean Code Principles:** Write readable, maintainable, and well-structured code. This includes meaningful variable/function names, clear comments where necessary, and adherence to the project's architectural patterns (e.g., Clean Architecture layers in Flutter).

### Documentation

*   **Inline Comments:** Add comments to explain complex logic or non-obvious parts of the code.
*   **Docstrings/Documentation Comments:** Write docstrings for public classes, functions, and methods explaining their purpose, arguments, and return values.
*   **Updating Guides:** If your changes affect how the application works or is used, update the relevant documentation in the `docs/` directory accordingly.

### Testing

*   **Write Tests:** Contribute to the project's test coverage. Write unit, widget (Flutter), and integration tests as appropriate for your changes. See `docs/TESTING_STRATEGY.md`.
*   **Run Tests:** Before submitting a pull request, ensure all existing tests pass and your new tests are included and passing.
    *   **Flutter:** `cd apps/flutter_app && flutter test`
    *   **FastAPI:** `cd apps/fastapi_service && python -m pytest tests/`

## 5. Submitting Changes (Pull Requests)

### Pull Request Process

1.  **Ensure Your Branch is Up-to-Date:** Rebase your feature branch on the latest `main` to minimize merge conflicts.
    ```bash
    git fetch origin
    git checkout feature/your-feature-branch
    git rebase origin/main
    ```
2.  **Run Checks and Tests:** Make sure your code is formatted, linted, and all tests pass.
    *   **Flutter:** `cd apps/flutter_app && flutter format . && flutter analyze && flutter test`
    *   **FastAPI:** `cd apps/fastapi_service && black . && flake8 . && python -m pytest tests/` (Adjust commands based on project setup)
3.  **Push Your Branch:**
    ```bash
    git push origin feature/your-feature-branch
    ```
4.  **Open a Pull Request (PR):**
    *   Go to the repository on GitHub and open a new pull request from your branch to `main`.
    *   **Title:** Use a clear and concise title.
    *   **Description:** Provide a detailed description of the changes, including:
        *   The issue being addressed (link to the GitHub issue if applicable).
        *   A summary of the changes made.
        *   How the changes were tested.
        *   Any specific feedback you'd like from reviewers.
    *   **Link the Issue:** If applicable, link the PR to the relevant GitHub issue.
5.  **Follow the PR Template:** Use the provided PR template if one exists.

### Code Review Guidelines

*   **Responsiveness:** Be prepared to address feedback from reviewers promptly.
*   **Respect:** Maintain a respectful and constructive tone in all review comments.
*   **Review Checklist (For Reviewers - Internal Guide):**
    *   **Correctness:** Does the code work as intended and solve the problem?
    *   **Clarity:** Is the code easy to read and understand? Are there sufficient comments/docstrings?
    *   **Maintainability:** Does the code follow project standards and architectural patterns (e.g., `ARCHITECTURE.md`)?
    *   **Test Coverage:** Are there adequate tests for the new/changed functionality (`TESTING_STRATEGY.md`)?
    *   **Performance:** Are there any obvious performance bottlenecks introduced?
    *   **Security:** Are there any potential security vulnerabilities?
    *   **Documentation:** Are relevant documentation files updated?
*   **Approval:** PRs typically require approval from at least one other developer before merging.
*   **Merging:** Once approved and all CI checks pass, the PR can be merged into `main`. The project maintainers will usually handle the merge.

## 6. Community

*   **Communication:** Engage with the community and team through the designated channels (e.g., Slack, Discord, GitHub Discussions - specify if these exist).
*   **Feedback:** Constructive feedback is always welcome, both on contributions and the project itself.

We appreciate your contributions to making Aura better!

