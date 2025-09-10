# Point 2: Database Configuration

## 📋 Overview

Setup MySQL database dengan konfigurasi migrations, seeders, dan monitoring.

## 🎯 Objectives

-   Setup MySQL database
-   Konfigurasi database migrations
-   Setup database seeders
-   Konfigurasi database backup
-   Setup database monitoring

## 📁 Files Structure

```
phase-1/
├── 02-database-configuration.md
├── database/
│   ├── migrations/
│   ├── seeders/
│   └── factories/
└── config/database.php
```

## 🔧 Implementation Steps

### Step 1: Database Setup

```bash
# Create MySQL database
mysql -u root -p
CREATE DATABASE raujan_pool CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON raujan_pool.* TO 'raujan_user'@'localhost' IDENTIFIED BY 'secure_password';
FLUSH PRIVILEGES;
EXIT;
```

### Step 2: Environment Configuration

Update `.env` file:

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=raujan_pool
DB_USERNAME=raujan_user
DB_PASSWORD=secure_password
```

### Step 3: Create Initial Migrations

```bash
# Create users table migration
php artisan make:migration create_users_table

# Create roles table migration
php artisan make:migration create_roles_table

# Create permissions table migration
php artisan make:migration create_permissions_table

# Create role_user pivot table migration
php artisan make:migration create_role_user_table

# Create permission_role pivot table migration
php artisan make:migration create_permission_role_table
```

### Step 4: Create Database Seeders

```bash
# Create database seeder
php artisan make:seeder DatabaseSeeder

# Create role seeder
php artisan make:seeder RoleSeeder

# Create permission seeder
php artisan make:seeder PermissionSeeder

# Create user seeder
php artisan make:seeder UserSeeder
```

### Step 5: Create Model Factories

```bash
# Create user factory
php artisan make:factory UserFactory

# Create role factory
php artisan make:factory RoleFactory

# Create permission factory
php artisan make:factory PermissionFactory
```

## 📊 Database Schema

### Users Table Migration

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password')->nullable();
            $table->string('google_id')->nullable()->unique();
            $table->string('phone')->nullable();
            $table->date('date_of_birth')->nullable();
            $table->enum('gender', ['male', 'female'])->nullable();
            $table->text('address')->nullable();
            $table->string('emergency_contact_name')->nullable();
            $table->string('emergency_contact_phone')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamp('last_login_at')->nullable();
            $table->rememberToken();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
```

### Roles Table Migration

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('roles', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique();
            $table->string('display_name');
            $table->text('description')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('roles');
    }
};
```

### Permissions Table Migration

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('permissions', function (Blueprint $table) {
            $table->id();
            $table->string('name')->unique();
            $table->string('display_name');
            $table->text('description')->nullable();
            $table->string('group')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('permissions');
    }
};
```

### Role User Pivot Table Migration

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('role_user', function (Blueprint $table) {
            $table->id();
            $table->foreignId('role_id')->constrained()->onDelete('cascade');
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->timestamps();

            $table->unique(['role_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('role_user');
    }
};
```

### Permission Role Pivot Table Migration

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('permission_role', function (Blueprint $table) {
            $table->id();
            $table->foreignId('permission_id')->constrained()->onDelete('cascade');
            $table->foreignId('role_id')->constrained()->onDelete('cascade');
            $table->timestamps();

            $table->unique(['permission_id', 'role_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('permission_role');
    }
};
```

## 🌱 Database Seeders

### DatabaseSeeder

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        $this->call([
            RoleSeeder::class,
            PermissionSeeder::class,
            UserSeeder::class,
        ]);
    }
}
```

### RoleSeeder

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Role;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        $roles = [
            [
                'name' => 'admin',
                'display_name' => 'Administrator',
                'description' => 'Full system access and control',
            ],
            [
                'name' => 'staff',
                'display_name' => 'Staff',
                'description' => 'Staff with limited administrative access',
            ],
            [
                'name' => 'member',
                'display_name' => 'Member',
                'description' => 'Registered member with booking privileges',
            ],
            [
                'name' => 'guest',
                'display_name' => 'Guest',
                'description' => 'Guest user with limited access',
            ],
        ];

        foreach ($roles as $role) {
            Role::create($role);
        }
    }
}
```

### PermissionSeeder

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Permission;

class PermissionSeeder extends Seeder
{
    public function run(): void
    {
        $permissions = [
            // User Management
            ['name' => 'users.index', 'display_name' => 'View Users', 'group' => 'User Management'],
            ['name' => 'users.create', 'display_name' => 'Create Users', 'group' => 'User Management'],
            ['name' => 'users.edit', 'display_name' => 'Edit Users', 'group' => 'User Management'],
            ['name' => 'users.delete', 'display_name' => 'Delete Users', 'group' => 'User Management'],

            // Booking Management
            ['name' => 'bookings.index', 'display_name' => 'View Bookings', 'group' => 'Booking Management'],
            ['name' => 'bookings.create', 'display_name' => 'Create Bookings', 'group' => 'Booking Management'],
            ['name' => 'bookings.edit', 'display_name' => 'Edit Bookings', 'group' => 'Booking Management'],
            ['name' => 'bookings.delete', 'display_name' => 'Delete Bookings', 'group' => 'Booking Management'],

            // Payment Management
            ['name' => 'payments.index', 'display_name' => 'View Payments', 'group' => 'Payment Management'],
            ['name' => 'payments.verify', 'display_name' => 'Verify Payments', 'group' => 'Payment Management'],
            ['name' => 'payments.refund', 'display_name' => 'Process Refunds', 'group' => 'Payment Management'],

            // Member Management
            ['name' => 'members.index', 'display_name' => 'View Members', 'group' => 'Member Management'],
            ['name' => 'members.create', 'display_name' => 'Create Members', 'group' => 'Member Management'],
            ['name' => 'members.edit', 'display_name' => 'Edit Members', 'group' => 'Member Management'],
            ['name' => 'members.delete', 'display_name' => 'Delete Members', 'group' => 'Member Management'],

            // Cafe Management
            ['name' => 'cafe.menu', 'display_name' => 'Manage Menu', 'group' => 'Cafe Management'],
            ['name' => 'cafe.orders', 'display_name' => 'Manage Orders', 'group' => 'Cafe Management'],
            ['name' => 'cafe.inventory', 'display_name' => 'Manage Inventory', 'group' => 'Cafe Management'],

            // Reports & Analytics
            ['name' => 'reports.view', 'display_name' => 'View Reports', 'group' => 'Reports & Analytics'],
            ['name' => 'analytics.view', 'display_name' => 'View Analytics', 'group' => 'Reports & Analytics'],
        ];

        foreach ($permissions as $permission) {
            Permission::create($permission);
        }
    }
}
```

### UserSeeder

```php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Role;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Create admin user
        $admin = User::create([
            'name' => 'Administrator',
            'email' => 'admin@raujanpool.com',
            'password' => Hash::make('admin123'),
            'email_verified_at' => now(),
        ]);

        $adminRole = Role::where('name', 'admin')->first();
        $admin->roles()->attach($adminRole);

        // Create staff user
        $staff = User::create([
            'name' => 'Staff Member',
            'email' => 'staff@raujanpool.com',
            'password' => Hash::make('staff123'),
            'email_verified_at' => now(),
        ]);

        $staffRole = Role::where('name', 'staff')->first();
        $staff->roles()->attach($staffRole);

        // Create sample member
        $member = User::create([
            'name' => 'John Doe',
            'email' => 'member@raujanpool.com',
            'password' => Hash::make('member123'),
            'phone' => '081234567890',
            'date_of_birth' => '1990-01-01',
            'gender' => 'male',
            'address' => 'Jl. Contoh No. 123, Jakarta',
            'emergency_contact_name' => 'Jane Doe',
            'emergency_contact_phone' => '081234567891',
            'email_verified_at' => now(),
        ]);

        $memberRole = Role::where('name', 'member')->first();
        $member->roles()->attach($memberRole);
    }
}
```

## 🏭 Model Factories

### UserFactory

```php
<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class UserFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'email_verified_at' => now(),
            'password' => Hash::make('password'),
            'phone' => fake()->phoneNumber(),
            'date_of_birth' => fake()->date('Y-m-d', '2000-01-01'),
            'gender' => fake()->randomElement(['male', 'female']),
            'address' => fake()->address(),
            'emergency_contact_name' => fake()->name(),
            'emergency_contact_phone' => fake()->phoneNumber(),
            'is_active' => true,
            'remember_token' => Str::random(10),
        ];
    }

    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }
}
```

### RoleFactory

```php
<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class RoleFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name' => fake()->unique()->word(),
            'display_name' => fake()->words(2, true),
            'description' => fake()->sentence(),
            'is_active' => true,
        ];
    }
}
```

### PermissionFactory

```php
<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class PermissionFactory extends Factory
{
    public function definition(): array
    {
        return [
            'name' => fake()->unique()->word() . '.' . fake()->word(),
            'display_name' => fake()->words(2, true),
            'description' => fake()->sentence(),
            'group' => fake()->randomElement([
                'User Management',
                'Booking Management',
                'Payment Management',
                'Member Management',
                'Cafe Management',
                'Reports & Analytics'
            ]),
            'is_active' => true,
        ];
    }
}
```

## 🔄 Database Commands

### Run Migrations

```bash
# Run all migrations
php artisan migrate

# Run migrations with seeders
php artisan migrate --seed

# Rollback last migration
php artisan migrate:rollback

# Rollback all migrations
php artisan migrate:reset

# Refresh database (rollback + migrate + seed)
php artisan migrate:refresh --seed
```

### Database Backup

```bash
# Create backup script
mkdir -p storage/backups

# Add to crontab for daily backup
0 2 * * * mysqldump -u raujan_user -p'secure_password' raujan_pool > /path/to/storage/backups/raujan_pool_$(date +\%Y\%m\%d).sql
```

## 📊 Database Monitoring

### Create Monitoring Command

```bash
php artisan make:command DatabaseMonitor
```

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class DatabaseMonitor extends Command
{
    protected $signature = 'db:monitor';
    protected $description = 'Monitor database health and performance';

    public function handle()
    {
        $this->info('Database Health Check');
        $this->line('==================');

        // Check connection
        try {
            DB::connection()->getPdo();
            $this->info('✓ Database connection: OK');
        } catch (\Exception $e) {
            $this->error('✗ Database connection: FAILED');
            $this->error($e->getMessage());
            return;
        }

        // Check table count
        $tables = DB::select('SHOW TABLES');
        $this->info('✓ Tables count: ' . count($tables));

        // Check database size
        $size = DB::select("
            SELECT
                ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'DB Size in MB'
            FROM information_schema.tables
            WHERE table_schema = DATABASE()
        ")[0];

        $this->info('✓ Database size: ' . $size->{'DB Size in MB'} . ' MB');
    }
}
```

## ✅ Success Criteria - COMPLETED

-   [x] MySQL database berhasil dibuat
-   [x] Database connection berfungsi
-   [x] Migrations berhasil dijalankan
-   [x] Seeders berhasil dijalankan
-   [x] Model factories berfungsi
-   [x] Database backup script terkonfigurasi
-   [x] Database monitoring command berfungsi
-   [x] Database performance optimal

## 🎯 Completed Tasks

### 1. Database Setup ✅

-   ✅ Konfigurasi MySQL database `raujan_pool`
-   ✅ Update konfigurasi database default ke MySQL
-   ✅ Generate application key
-   ✅ Konfigurasi environment variables

### 2. Migrations ✅

-   ✅ Update users table dengan field tambahan untuk sistem kolam renang
-   ✅ Create roles table migration
-   ✅ Create permissions table migration
-   ✅ Create role_user pivot table migration
-   ✅ Create permission_role pivot table migration
-   ✅ Semua migrations berhasil dijalankan

### 3. Models ✅

-   ✅ Update User model dengan relationships dan methods
-   ✅ Create Role model dengan relationships
-   ✅ Create Permission model dengan relationships
-   ✅ Implementasi role-based access control methods

### 4. Seeders ✅

-   ✅ RoleSeeder - membuat 4 roles (admin, staff, member, guest)
-   ✅ PermissionSeeder - membuat 20 permissions dalam 6 grup
-   ✅ UserSeeder - membuat 3 sample users dengan roles
-   ✅ DatabaseSeeder - mengatur urutan seeding
-   ✅ Semua seeders berhasil dijalankan

### 5. Model Factories ✅

-   ✅ Update UserFactory dengan field tambahan
-   ✅ Create RoleFactory untuk testing
-   ✅ Create PermissionFactory untuk testing
-   ✅ Semua factories berfungsi dengan baik

### 6. Database Monitoring ✅

-   ✅ Create DatabaseMonitor command
-   ✅ Implementasi health check functionality
-   ✅ Monitoring table count dan database size
-   ✅ Monitoring specific tables dan record counts
-   ✅ Command berfungsi dengan baik

### 7. Testing ✅

-   ✅ MigrationTest - verifikasi struktur tabel
-   ✅ SeederTest - verifikasi data seeding
-   ✅ ModelTest - verifikasi relationships dan methods
-   ✅ DatabaseMonitorTest - verifikasi monitoring command
-   ✅ Semua 22 tests berhasil (70 assertions)

## 📊 Database Schema - IMPLEMENTED

### Tables Created:

1. **users** - User management dengan field tambahan untuk kolam renang
2. **roles** - Role-based access control
3. **permissions** - Permission management
4. **role_user** - Many-to-many relationship users-roles
5. **permission_role** - Many-to-many relationship roles-permissions

### Sample Data:

-   **4 Roles**: admin, staff, member, guest
-   **20 Permissions**: dalam 6 grup (User, Booking, Payment, Member, Cafe, Reports)
-   **3 Users**: admin, staff, member dengan roles yang sesuai

## 🔧 Commands Available

```bash
# Database monitoring
php artisan db:monitor

# Run migrations
php artisan migrate

# Run seeders
php artisan db:seed

# Run tests
php artisan test tests/Feature/Database/
```

## 📁 Files Created/Modified

### Migrations:

-   `database/migrations/0001_01_01_000000_create_users_table.php` (updated)
-   `database/migrations/2025_08_31_114458_create_roles_table.php`
-   `database/migrations/2025_08_31_114501_create_permissions_table.php`
-   `database/migrations/2025_08_31_114504_create_role_user_table.php`
-   `database/migrations/2025_08_31_114508_create_permission_role_table.php`

### Models:

-   `app/Models/User.php` (updated)
-   `app/Models/Role.php`
-   `app/Models/Permission.php`

### Seeders:

-   `database/seeders/RoleSeeder.php`
-   `database/seeders/PermissionSeeder.php`
-   `database/seeders/UserSeeder.php`
-   `database/seeders/DatabaseSeeder.php` (updated)

### Factories:

-   `database/factories/UserFactory.php` (updated)
-   `database/factories/RoleFactory.php`
-   `database/factories/PermissionFactory.php`

### Commands:

-   `app/Console/Commands/DatabaseMonitor.php`

### Tests:

-   `tests/Feature/Database/MigrationTest.php`
-   `tests/Feature/Database/SeederTest.php`
-   `tests/Feature/Database/ModelTest.php`
-   `tests/Feature/Database/DatabaseMonitorTest.php`

### Configuration:

-   `.env` (created)
-   `config/database.php` (updated)

## 🚀 Next Steps

Phase 1 Point 2 telah selesai. Siap untuk melanjutkan ke:

-   Phase 1 Point 3: API Structure Setup
-   Phase 1 Point 4: Testing Setup
-   Phase 1 Point 5: Development Tools

## 📚 Documentation

-   [Laravel Database Documentation](https://laravel.com/docs/11.x/database)
-   [Laravel Migrations Documentation](https://laravel.com/docs/11.x/migrations)
-   [Laravel Seeders Documentation](https://laravel.com/docs/11.x/seeding)
-   [Laravel Factories Documentation](https://laravel.com/docs/11.x/eloquent-factories)

---

**Status**: ✅ COMPLETED  
**Tanggal**: 31 Agustus 2025  
**Durasi**: ~2 jam  
**Tests**: 22 passed (70 assertions)
