# Development Scripts Documentation

## Overview

Dokumentasi ini menjelaskan script-script development yang tersedia untuk memudahkan development workflow.

## Available Scripts

### 1. Development Setup Script

**File:** `scripts/dev-setup.sh`

**Description:** Script untuk setup awal development environment.

**Usage:**
```bash
./scripts/dev-setup.sh
```

**What it does:**
- Install dependencies dengan `composer install`
- Copy environment file dari `.env.example` ke `.env`
- Generate application key
- Run database migrations dan seeders
- Generate IDE helper files
- Setup Git hooks permissions

**Example:**
```bash
chmod +x scripts/dev-setup.sh
./scripts/dev-setup.sh
```

### 2. Quality Check Script

**File:** `scripts/quality-check.sh`

**Description:** Script untuk menjalankan semua quality checks.

**Usage:**
```bash
./scripts/quality-check.sh
```

**What it does:**
- Run PHPStan static analysis
- Run Laravel Pint code style check
- Run Pest tests

**Example:**
```bash
chmod +x scripts/quality-check.sh
./scripts/quality-check.sh
```

### 3. Existing Test Scripts

#### Quick Test Script
**File:** `scripts/test-quick.sh`

**Description:** Menjalankan test suite dengan cepat.

**Usage:**
```bash
./scripts/test-quick.sh
```

#### API Test Script
**File:** `scripts/test-api.sh`

**Description:** Menjalankan API tests.

**Usage:**
```bash
./scripts/test-api.sh
```

#### RBAC Test Script
**File:** `scripts/test-rbac-api.sh`

**Description:** Menjalankan RBAC API tests.

**Usage:**
```bash
./scripts/test-rbac-api.sh
```

#### Coverage Test Script
**File:** `scripts/test-coverage.sh`

**Description:** Menjalankan test dengan coverage report.

**Usage:**
```bash
./scripts/test-coverage.sh
```

## Git Hooks

### Pre-commit Hook

**File:** `.git/hooks/pre-commit`

**Description:** Hook yang dijalankan sebelum commit untuk memastikan code quality.

**What it does:**
- Run PHPStan analysis
- Run Pint code style check
- Run Pest tests

**Usage:** Otomatis dijalankan saat `git commit`

### Commit Message Hook

**File:** `.git/hooks/commit-msg`

**Description:** Hook untuk validasi format commit message.

**Format yang diterima:**
```
type(scope): description

Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert
```

**Examples:**
- `feat(auth): add Google OAuth integration`
- `fix(booking): resolve date validation issue`
- `docs(api): update authentication documentation`

## Code Quality Tools

### PHPStan

**Configuration:** `phpstan.neon`

**Usage:**
```bash
./vendor/bin/phpstan analyse
```

**Level:** 5 (moderate strictness)

### Laravel Pint

**Configuration:** `pint.json`

**Usage:**
```bash
# Check code style
./vendor/bin/pint --test

# Fix code style
./vendor/bin/pint
```

### Laravel IDE Helper

**Usage:**
```bash
# Generate helper files
php artisan ide-helper:generate
php artisan ide-helper:models
php artisan ide-helper:meta

# Clear cache
php artisan ide-helper:clear
```

## Development Workflow

### 1. Initial Setup

```bash
# Clone repository
git clone <repository-url>
cd raujan_pool_backend

# Run setup script
./scripts/dev-setup.sh

# Configure environment
cp .env.example .env
# Edit .env with your configuration

# Start development server
php artisan serve
```

### 2. Daily Development

```bash
# Pull latest changes
git pull origin main

# Run quality checks
./scripts/quality-check.sh

# Make changes and commit
git add .
git commit -m "feat(feature): add new feature"

# Push changes
git push origin feature-branch
```

### 3. Before Deployment

```bash
# Run all tests
./scripts/test-coverage.sh

# Run quality checks
./scripts/quality-check.sh

# Check for any linting issues
./vendor/bin/pint --test
```

## Troubleshooting

### Script Permission Issues

```bash
# Make scripts executable
chmod +x scripts/*.sh
chmod +x .git/hooks/*
```

### Git Hooks Not Working

```bash
# Check if hooks are executable
ls -la .git/hooks/

# Make hooks executable
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg
```

### Quality Check Failures

1. **PHPStan Errors:**
   - Fix type hints and return types
   - Add proper PHPDoc comments
   - Check configuration in `phpstan.neon`

2. **Pint Style Issues:**
   - Run `./vendor/bin/pint` to auto-fix
   - Check configuration in `pint.json`

3. **Test Failures:**
   - Check test files for syntax errors
   - Ensure database is properly configured
   - Run individual test files to isolate issues

## Best Practices

1. **Always run quality checks before committing**
2. **Use descriptive commit messages**
3. **Keep scripts up to date with project changes**
4. **Document any new scripts added**
5. **Test scripts in different environments**
6. **Use version control for all scripts**
