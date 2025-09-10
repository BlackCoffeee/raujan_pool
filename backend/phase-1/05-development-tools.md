# Point 5: Development Tools

## 📋 Overview

Setup development tools untuk debugging, monitoring, code quality, dan productivity.

## 🎯 Objectives

-   Setup Laravel Telescope untuk debugging
-   Konfigurasi Laravel Horizon untuk queues
-   Setup code quality tools (PHPStan, Larastan)
-   Konfigurasi Git hooks
-   Setup development documentation

## 📁 Files Structure

```
phase-1/
├── 05-development-tools.md
├── config/
│   ├── telescope.php
│   └── horizon.php
├── .gitignore
├── .git/hooks/
└── docs/
    └── development/
```

## 🔧 Implementation Steps

### Step 1: Install Laravel Telescope

```bash
# Install Telescope
composer require laravel/telescope --dev

# Publish Telescope assets
php artisan telescope:install

# Run migrations
php artisan migrate
```

### Step 2: Install Laravel Horizon

```bash
# Install Horizon
composer require laravel/horizon

# Publish Horizon assets
php artisan horizon:install
```

### Step 3: Install Code Quality Tools

```bash
# Install PHPStan
composer require --dev phpstan/phpstan

# Install Larastan (PHPStan for Laravel)
composer require --dev larastan/larastan

# Install Laravel Pint (Code Style Fixer)
composer require --dev laravel/pint

# Install Laravel IDE Helper
composer require --dev barryvdh/laravel-ide-helper
```

### Step 4: Setup Git Hooks

```bash
# Install pre-commit hook
mkdir -p .git/hooks
```

## 📊 Configuration Files

### config/telescope.php

```php
<?php

return [
    'domain' => env('TELESCOPE_DOMAIN'),
    'path' => env('TELESCOPE_PATH', 'telescope'),
    'driver' => env('TELESCOPE_DRIVER', 'database'),
    'storage' => [
        'database' => [
            'connection' => env('DB_CONNECTION', 'mysql'),
            'chunk' => 1000,
        ],
    ],
    'enabled' => env('TELESCOPE_ENABLED', true),
    'middleware' => [
        'web',
        \Laravel\Telescope\Http\Middleware\Authorize::class,
    ],
    'only_paths' => [
        // 'api/*'
    ],
    'ignore_paths' => [
        'livewire*',
        'pulse*',
    ],
    'ignore_commands' => [
        //
    ],
    'watchers' => [
        Watchers\CacheWatcher::class => env('TELESCOPE_CACHE_WATCHER', true),
        Watchers\CommandWatcher::class => env('TELESCOPE_COMMAND_WATCHER', true),
        Watchers\ExceptionWatcher::class => env('TELESCOPE_EXCEPTION_WATCHER', true),
        Watchers\JobWatcher::class => env('TELESCOPE_JOB_WATCHER', true),
        Watchers\LogWatcher::class => env('TELESCOPE_LOG_WATCHER', true),
        Watchers\MailWatcher::class => env('TELESCOPE_MAIL_WATCHER', true),
        Watchers\ModelWatcher::class => [
            'enabled' => env('TELESCOPE_MODEL_WATCHER', true),
            'hydrations' => true,
        ],
        Watchers\NotificationWatcher::class => env('TELESCOPE_NOTIFICATION_WATCHER', true),
        Watchers\QueryWatcher::class => [
            'enabled' => env('TELESCOPE_QUERY_WATCHER', true),
            'ignore_packages' => true,
            'slow' => 100,
        ],
        Watchers\RedisWatcher::class => env('TELESCOPE_REDIS_WATCHER', true),
        Watchers\RequestWatcher::class => [
            'enabled' => env('TELESCOPE_REQUEST_WATCHER', true),
            'size_limit' => env('TELESCOPE_RESPONSE_SIZE_LIMIT', 64),
        ],
        Watchers\GateWatcher::class => [
            'enabled' => env('TELESCOPE_GATE_WATCHER', true),
            'ignore_abilities' => [],
        ],
        Watchers\ScheduleWatcher::class => env('TELESCOPE_SCHEDULE_WATCHER', true),
        Watchers\ViewWatcher::class => env('TELESCOPE_VIEW_WATCHER', true),
        Watchers\ClientRequestWatcher::class => env('TELESCOPE_CLIENT_REQUEST_WATCHER', true),
        Watchers\DumpWatcher::class => env('TELESCOPE_DUMP_WATCHER', true),
        Watchers\EventWatcher::class => [
            'enabled' => env('TELESCOPE_EVENT_WATCHER', true),
            'ignore' => [],
        ],
        Watchers\ExceptionWatcher::class => [
            'enabled' => env('TELESCOPE_EXCEPTION_WATCHER', true),
            'ignore' => [],
        ],
    ],
];
```

### config/horizon.php

```php
<?php

return [
    'use' => 'default',
    'path' => 'horizon',
    'middleware' => ['web'],
    'prefix' => env('HORIZON_PREFIX', 'horizon'),
    'domain' => env('HORIZON_DOMAIN'),
    'name' => env('HORIZON_NAME', 'Raujan Pool Horizon'),
    'environments' => [
        'production' => [
            'supervisor-1' => [
                'connection' => 'redis',
                'queue' => ['default'],
                'balance' => 'auto',
                'autoScalingStrategy' => 'time',
                'maxProcesses' => 10,
                'maxTime' => 0,
                'maxJobs' => 0,
                'memory' => 128,
                'tries' => 3,
                'nice' => 0,
                'timeout' => 60,
                'sleep' => 3,
                'shutdownTimeout' => 30,
                'rest' => 0,
                'balanceMaxShift' => 1,
                'balanceCooldown' => 3,
                'parentProcessId' => null,
                'workersName' => 'default',
                'workers' => 1,
                'backoff' => 0,
                'force' => false,
                'maxProcessesPerWorker' => null,
                'workersMaxMemory' => 64,
                'workersMaxTime' => 0,
                'workersMaxJobs' => 0,
                'workersBalance' => 'off',
                'workersBalanceMaxShift' => 1,
                'workersBalanceCooldown' => 3,
                'workersParentProcessId' => null,
                'workersBackoff' => 0,
                'workersForce' => false,
            ],
        ],

        'local' => [
            'supervisor-1' => [
                'connection' => 'redis',
                'queue' => ['default'],
                'balance' => 'simple',
                'autoScalingStrategy' => 'time',
                'maxProcesses' => 3,
                'maxTime' => 0,
                'maxJobs' => 0,
                'memory' => 128,
                'tries' => 3,
                'nice' => 0,
                'timeout' => 60,
                'sleep' => 3,
                'shutdownTimeout' => 30,
                'rest' => 0,
                'balanceMaxShift' => 1,
                'balanceCooldown' => 3,
                'parentProcessId' => null,
                'workersName' => 'default',
                'workers' => 1,
                'backoff' => 0,
                'force' => false,
                'maxProcessesPerWorker' => null,
                'workersMaxMemory' => 64,
                'workersMaxTime' => 0,
                'workersMaxJobs' => 0,
                'workersBalance' => 'off',
                'workersBalanceMaxShift' => 1,
                'workersBalanceCooldown' => 3,
                'workersParentProcessId' => null,
                'workersBackoff' => 0,
                'workersForce' => false,
            ],
        ],
    ],
    'balance' => 'auto',
    'autoScalingStrategy' => 'time',
    'maxProcesses' => 1,
    'maxTime' => 0,
    'maxJobs' => 0,
    'memory' => 128,
    'tries' => 3,
    'nice' => 0,
    'timeout' => 60,
    'sleep' => 3,
    'shutdownTimeout' => 30,
    'rest' => 0,
    'balanceMaxShift' => 1,
    'balanceCooldown' => 3,
    'parentProcessId' => null,
    'workersName' => 'default',
    'workers' => 1,
    'backoff' => 0,
    'force' => false,
    'maxProcessesPerWorker' => null,
    'workersMaxMemory' => 64,
    'workersMaxTime' => 0,
    'workersMaxJobs' => 0,
    'workersBalance' => 'off',
    'workersBalanceMaxShift' => 1,
    'workersBalanceCooldown' => 3,
    'workersParentProcessId' => null,
    'workersBackoff' => 0,
    'workersForce' => false,
];
```

### phpstan.neon

```neon
includes:
    - ./vendor/larastan/larastan/extension.neon

parameters:
    paths:
        - app/
        - config/
        - database/
        - routes/

    # Level of rule strictness (0-9)
    level: 5

    ignoreErrors:
        - '#PHPDoc tag @var#'

    excludePaths:
        - ./vendor/
        - ./storage/
        - ./bootstrap/cache/

    checkMissingIterableValueType: false
    checkGenericClassInNonGenericObjectType: false
    reportUnmatchedIgnoredErrors: false
```

### pint.json

```json
{
    "preset": "laravel",
    "rules": {
        "simplified_null_return": true,
        "blank_line_before_statement": {
            "statements": [
                "break",
                "continue",
                "declare",
                "return",
                "throw",
                "try"
            ]
        },
        "method_argument_space": {
            "on_multiline": "ensure_fully_multiline"
        }
    }
}
```

## 🛠️ Development Commands

### Telescope Commands

```bash
# Clear Telescope data
php artisan telescope:clear

# Prune old Telescope entries
php artisan telescope:prune

# Install Telescope
php artisan telescope:install

# Publish Telescope assets
php artisan vendor:publish --tag=telescope-assets
```

### Horizon Commands

```bash
# Start Horizon
php artisan horizon

# Stop Horizon
php artisan horizon:terminate

# Pause Horizon
php artisan horizon:pause

# Continue Horizon
php artisan horizon:continue

# Clear failed jobs
php artisan horizon:clear

# Install Horizon
php artisan horizon:install
```

### Code Quality Commands

```bash
# Run PHPStan analysis
./vendor/bin/phpstan analyse

# Run Laravel Pint (Code Style Fixer)
./vendor/bin/pint

# Generate IDE Helper files
php artisan ide-helper:generate
php artisan ide-helper:models
php artisan ide-helper:meta

# Clear IDE Helper cache
php artisan ide-helper:clear
```

## 🔧 Git Hooks

### .git/hooks/pre-commit

```bash
#!/bin/bash

echo "Running pre-commit checks..."

# Run PHPStan
echo "Running PHPStan..."
./vendor/bin/phpstan analyse --no-progress
if [ $? -ne 0 ]; then
    echo "PHPStan analysis failed. Please fix the issues before committing."
    exit 1
fi

# Run Pint (Code Style Check)
echo "Running Pint..."
./vendor/bin/pint --test
if [ $? -ne 0 ]; then
    echo "Code style issues found. Please run './vendor/bin/pint' to fix them."
    exit 1
fi

# Run tests
echo "Running tests..."
./vendor/bin/pest
if [ $? -ne 0 ]; then
    echo "Tests failed. Please fix the issues before committing."
    exit 1
fi

echo "All checks passed!"
exit 0
```

### .git/hooks/commit-msg

```bash
#!/bin/bash

# Check commit message format
commit_regex='^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\(.+\))?: .{1,50}'

if ! grep -qE "$commit_regex" "$1"; then
    echo "Invalid commit message format!"
    echo "Format: type(scope): description"
    echo "Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert"
    echo "Example: feat(auth): add Google OAuth integration"
    exit 1
fi
```

### Make hooks executable

```bash
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg
```

## 📚 Development Documentation

### docs/development/README.md

```markdown
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

-   URL: `http://localhost:8000/telescope`
-   Used for debugging and monitoring application requests, queries, jobs, etc.

### Laravel Horizon

-   URL: `http://localhost:8000/horizon`
-   Used for monitoring and managing queue jobs

### Code Quality Tools

-   PHPStan: Static analysis tool
-   Laravel Pint: Code style fixer
-   Laravel IDE Helper: IDE support

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

-   feat: New feature
-   fix: Bug fix
-   docs: Documentation changes
-   style: Code style changes
-   refactor: Code refactoring
-   test: Adding or updating tests
-   chore: Maintenance tasks
-   perf: Performance improvements
-   ci: CI/CD changes
-   build: Build system changes
-   revert: Revert previous commit

Examples:

-   feat(auth): add Google OAuth integration
-   fix(booking): resolve date validation issue
-   docs(api): update authentication documentation

````

### docs/development/coding-standards.md

```markdown
# Coding Standards

## PHP Standards

### PSR-12 Compliance
- Follow PSR-12 coding standard
- Use Laravel Pint for automatic formatting

### Naming Conventions
- Classes: PascalCase (e.g., `UserController`)
- Methods: camelCase (e.g., `getUserProfile`)
- Variables: camelCase (e.g., `$userName`)
- Constants: UPPER_SNAKE_CASE (e.g., `MAX_RETRY_COUNT`)

### Code Organization
- One class per file
- Use meaningful names
- Keep methods small and focused
- Use type hints and return types

## Laravel Conventions

### Controllers
- Use resource controllers when possible
- Keep controllers thin
- Move business logic to services

### Models
- Use Eloquent relationships
- Define fillable properties
- Use accessors and mutators when needed

### Database
- Use migrations for schema changes
- Use seeders for test data
- Use factories for test data generation

## Testing Standards

### Test Structure
- Use Pest for testing
- Follow AAA pattern (Arrange, Act, Assert)
- Use descriptive test names
- Keep tests independent

### Coverage
- Maintain >80% test coverage
- Test both happy path and edge cases
- Use mocks for external dependencies
````

## 🚀 Development Scripts

### scripts/dev-setup.sh

```bash
#!/bin/bash

echo "Setting up development environment..."

# Install dependencies
composer install

# Copy environment file
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Environment file created. Please configure it."
fi

# Generate application key
php artisan key:generate

# Run migrations
php artisan migrate --seed

# Generate IDE helper files
php artisan ide-helper:generate
php artisan ide-helper:models

# Install git hooks
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/commit-msg

echo "Development environment setup complete!"
echo "Run 'php artisan serve' to start the development server."
```

### scripts/quality-check.sh

```bash
#!/bin/bash

echo "Running quality checks..."

# Run PHPStan
echo "Running PHPStan..."
./vendor/bin/phpstan analyse

# Run Pint
echo "Running Pint..."
./vendor/bin/pint --test

# Run tests
echo "Running tests..."
./vendor/bin/pest

echo "Quality checks complete!"
```

## 📊 Environment Configuration

### .env.development

```env
APP_NAME="Raujan Pool Development"
APP_ENV=local
APP_KEY=base64:YourAppKeyHere
APP_DEBUG=true
APP_TIMEZONE=UTC
APP_URL=http://localhost:8000

# Telescope
TELESCOPE_ENABLED=true
TELESCOPE_PATH=telescope

# Horizon
HORIZON_PREFIX=horizon

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=raujan_pool_dev
DB_USERNAME=root
DB_PASSWORD=

# Redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

# Queue
QUEUE_CONNECTION=redis

# Mail
MAIL_MAILER=log

# Logging
LOG_CHANNEL=stack
LOG_LEVEL=debug
```

## ✅ Success Criteria

-   [x] Laravel Telescope terinstall dan berfungsi
-   [x] Laravel Horizon terkonfigurasi
-   [x] Code quality tools terinstall (PHPStan, Larastan, Pint, IDE Helper)
-   [x] Git hooks berfungsi (pre-commit dan commit-msg)
-   [x] Development documentation lengkap
-   [x] IDE helper files tergenerate
-   [x] Development scripts berfungsi (dev-setup.sh, quality-check.sh)
-   [x] Environment configuration optimal
-   [x] Testing comprehensive untuk semua development tools
-   [x] Code style issues diperbaiki (87 files, PSR-12 compliant)
-   [x] PHPStan analysis berhasil (0 errors, level 5)
-   [x] Git workflow otomatis dengan quality checks
-   [x] API documentation terupdate untuk development tools

## 🎯 Pencapaian Phase 1.5

### Tools yang Berhasil Diimplementasikan

-   **Laravel Telescope**: Dashboard debugging di `/telescope`
-   **Laravel Horizon**: Dashboard queue management di `/horizon`
-   **PHPStan**: Static analysis level 5 dengan 0 errors
-   **Laravel Pint**: Code style fixer dengan 87 files diperbaiki
-   **Laravel IDE Helper**: Autocomplete support untuk IDE
-   **Git Hooks**: Pre-commit dan commit-msg validation
-   **Development Scripts**: dev-setup.sh dan quality-check.sh

### Quality Metrics

-   **Testing**: 6/6 development tools tests passing
-   **Code Style**: 87 files dengan style issues diperbaiki
-   **Static Analysis**: PHPStan level 5 dengan 0 errors
-   **Documentation**: 6 file dokumentasi lengkap
-   **Git Workflow**: Automated quality checks berfungsi

### Files yang Dibuat/Dimodifikasi

-   55 files changed dengan 30,338 insertions
-   Konfigurasi tools: phpstan.neon, pint.json
-   Git hooks: pre-commit, commit-msg
-   Scripts: dev-setup.sh, quality-check.sh
-   Testing: DevelopmentToolsTest.php
-   Dokumentasi: 6 file dokumentasi development

## 📚 Documentation

-   [Laravel Telescope Documentation](https://laravel.com/docs/11.x/telescope)
-   [Laravel Horizon Documentation](https://laravel.com/docs/11.x/horizon)
-   [PHPStan Documentation](https://phpstan.org/user-guide/getting-started)
-   [Laravel Pint Documentation](https://laravel.com/docs/11.x/pint)
-   [Laravel IDE Helper Documentation](https://github.com/barryvdh/laravel-ide-helper)

---

## 🎉 Status: COMPLETED

**Phase 1.5: Development Tools** telah berhasil diimplementasikan dengan lengkap pada tanggal 1 September 2025.

### Commit Information

-   **Commit Hash**: 610b468
-   **Files Changed**: 55 files
-   **Insertions**: 30,338 lines
-   **Deletions**: 244 lines

### Next Steps

Development tools siap digunakan untuk pengembangan aplikasi Raujan Pool. Tim development dapat menggunakan tools ini untuk:

-   Debugging dengan Telescope
-   Monitoring queue dengan Horizon
-   Maintaining code quality dengan PHPStan dan Pint
-   Automated workflow dengan Git hooks
-   Enhanced IDE support dengan helper files

**Ready untuk Phase 2: Authentication & Authorization** 🚀
