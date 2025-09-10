# Development Guide

## Getting Started

1. Clone the repository
2. Install dependencies: `composer install`
3. Copy environment file: `cp .env.example .env`
4. Generate application key: `php artisan key:generate`
5. Run migrations: `php artisan migrate --seed`
6. Start development server: `php artisan serve`

## Development Tools

### Laravel Telescope

- URL: `http://localhost:8000/telescope`
- Used for debugging and monitoring application requests, queries, jobs, etc.

### Laravel Horizon

- URL: `http://localhost:8000/horizon`
- Used for monitoring and managing queue jobs

### Code Quality Tools

- PHPStan: Static analysis tool
- Laravel Pint: Code style fixer
- Laravel IDE Helper: IDE support

## Git Workflow

1. Create feature branch from `develop`
2. Make changes and commit with proper message format
3. Run pre-commit hooks (automatically)
4. Push to remote repository
5. Create pull request to `develop`

## Commit Message Format

```
type(scope): description

Types:

- feat: New feature
- fix: Bug fix
- docs: Documentation changes
- style: Code style changes
- refactor: Code refactoring
- test: Adding or updating tests
- chore: Maintenance tasks
- perf: Performance improvements
- ci: CI/CD changes
- build: Build system changes
- revert: Revert previous commit

Examples:

- feat(auth): add Google OAuth integration
- fix(booking): resolve date validation issue
- docs(api): update authentication documentation
```
