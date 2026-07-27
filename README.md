# Matcha

**A collaborative full-stack application under active development.**

Matcha is being built as a production-inspired engineering project focused on frontend architecture, authentication, API design, databases, testing, security, and containerized development.

> **Project status:** Early development. The repository currently contains the initial project structure and a runnable frontend foundation. Product features and backend integration are still in progress.

## Current focus

The current development phase is focused on establishing a reliable foundation before implementing the complete product experience.

* Frontend development environment
* Reusable UI architecture
* Type-safe forms and validation
* Automated frontend testing
* API mocking
* Docker-based workflows
* Backend and database foundations
* Authentication architecture

## What currently exists

### Frontend foundation

The frontend currently includes:

* React and TypeScript
* Vite development and production builds
* React Router
* Tailwind CSS
* shadcn and Radix UI foundations
* React Hook Form
* Zod validation
* TanStack Query
* Mock Service Worker
* Vitest
* React Testing Library
* Accessibility linting
* ESLint and Prettier
* Strict CI-oriented quality checks

### Containerized development

The frontend can be run through Docker Compose without requiring a local Node.js or pnpm installation.

The Docker workflow currently provides:

* A frontend development container
* Source-code mounting for local development
* Persistent pnpm and `node_modules` volumes
* Vite exposed on port `5173`
* Separate Docker development and production stages

### Repository structure

The repository was scaffolded with separate areas for:

```text
matcha/
├── frontend/
├── backend/
├── socket/
├── nginx/
├── postgres/
├── redis/
├── docs/
├── compose.yml
└── Makefile
```

Some service directories are currently placeholders and will be implemented incrementally.

## Planned engineering areas

The project is intended to cover:

* Account registration and authentication
* Secure session management
* Email verification and password recovery
* User profiles and onboarding
* PostgreSQL persistence
* REST API integration
* Real-time communication
* Redis-backed application services
* Input validation and user-safe errors
* Unit, integration, and end-to-end testing
* Accessibility
* Docker-based local and production workflows
* CI/CD and deployment

These areas represent the project direction and should not be interpreted as completed features.

## Design direction

Product wireframes have been created to explore the intended user experience.

They guide the future interface for areas such as:

* Registration and onboarding
* Profile creation
* Discovery
* Matching
* Messaging
* Account settings

The wireframes are design references only and do not represent the current implementation.

## Technology

### Frontend

* React
* TypeScript
* Vite
* React Router
* Tailwind CSS
* shadcn
* Radix UI
* React Hook Form
* Zod
* TanStack Query

### Testing and quality

* Vitest
* React Testing Library
* Testing Library User Event
* Mock Service Worker
* ESLint
* `eslint-plugin-jsx-a11y`
* Prettier
* TypeScript strict checks

### Planned full-stack foundation

* Python
* Flask
* PostgreSQL
* Redis
* Docker
* Docker Compose
* Nginx
* Real-time communication service

## Getting started

### Requirements

Only Docker and Docker Compose are required for the current frontend workflow.

### Run the frontend

From the repository root:

```bash
docker compose up --build frontend
```

The application will be available at:

```text
http://localhost:5173
```

### Stop the application

```bash
docker compose down
```

## Frontend development

Run the following commands from the `frontend` directory when working inside an environment with pnpm installed.

### Install dependencies

```bash
pnpm install
```

### Start development server

```bash
pnpm dev
```

### Type checking

```bash
pnpm typecheck
```

### Linting

```bash
pnpm lint
```

### Formatting check

```bash
pnpm format:check
```

### Tests

```bash
pnpm test
```

Run the test suite once:

```bash
pnpm test:run
```

### Complete frontend quality check

```bash
pnpm check:ci
```

This runs:

1. Type checking
2. ESLint
3. Prettier validation
4. Frontend tests

## Development approach

Matcha is being developed incrementally through GitHub issues, feature branches, and pull requests.

The current approach prioritizes:

* Small, reviewable changes
* Reproducible development environments
* Clear separation of services
* Automated quality checks
* Testable feature boundaries
* Documentation of technical decisions
* Honest tracking of completed and planned work

## Project status

| Area                     | Status                      |
| ------------------------ | --------------------------- |
| Repository structure     | Initial scaffold complete   |
| Frontend container       | Available                   |
| Vite React application   | Available                   |
| TypeScript and linting   | Available                   |
| Frontend test foundation | Available                   |
| API mocking foundation   | Available                   |
| Product UI               | In progress                 |
| Authentication           | In progress                 |
| Backend API              | Planned / early development |
| PostgreSQL integration   | Planned / early development |
| Redis integration        | Planned                     |
| Real-time features       | Planned                     |
| Deployment               | Planned                     |

## Collaboration

This is a collaborative project developed as part of the 42 Barcelona curriculum.

The repository is under active development, and its architecture, documentation, and implementation will continue to evolve as the team completes each project milestone.
