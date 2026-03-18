# Contributing to clawdOS

Thank you for your interest in contributing to clawdOS! This document provides guidelines and instructions for contributing.

## Getting Started

1. **Fork** the repository on GitHub.
2. **Clone** your fork locally:
   ```bash
   git clone https://github.com/<your-username>/clawdOS.git
   cd clawdOS
   ```
3. **Create a branch** for your change:
   ```bash
   git checkout -b feature/my-change
   ```
4. **Make your changes**, then run checks:
   ```bash
   make lint
   make test
   ```
5. **Commit** with a clear message and **push** your branch:
   ```bash
   git commit -m "Add feature X"
   git push origin feature/my-change
   ```
6. **Open a Pull Request** against the `main` branch.

## Before Submitting

- Run `make lint` — all shell scripts must pass shellcheck with zero warnings.
- Run `make test` — all tests must pass.
- Ensure your commits are logically organized (squash fixups if needed).

## Code Style

- **ShellCheck-clean** — All `.sh` files and scripts must pass shellcheck.
- **POSIX-compatible where possible** — Prefer POSIX shell constructs unless bash-specific features are needed.
- **Indentation** — 2 spaces for shell scripts and YAML; tabs for Makefiles.
- **Naming** — Use `snake_case` for variables and functions in shell scripts.

## Issue Templates

Issue templates are available when opening a new issue on GitHub. Please use the appropriate template for bug reports, feature requests, or questions.

## Code of Conduct

Be respectful, constructive, and collaborative. We are all here to build something useful together.
