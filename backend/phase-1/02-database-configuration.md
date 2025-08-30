# Point 2: Database Configuration

## 📋 Overview

Setup MySQL database dengan konfigurasi migrations, seeders, dan monitoring.

## 🎯 Objectives

- Setup MySQL database
- Konfigurasi database migrations
- Setup database seeders
- Konfigurasi database backup
- Setup database monitoring

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

## ✅ Success Criteria

- [ ] MySQL database berhasil dibuat
- [ ] Database connection berfungsi
- [ ] Migrations berhasil dijalankan
- [ ] Seeders berhasil dijalankan
- [ ] Model factories berfungsi
- [ ] Database backup script terkonfigurasi
- [ ] Database monitoring command berfungsi
- [ ] Database performance optimal

## 📚 Documentation

- [Laravel Database Documentation](https://laravel.com/docs/11.x/database)
- [Laravel Migrations Documentation](https://laravel.com/docs/11.x/migrations)
- [Laravel Seeders Documentation](https://laravel.com/docs/11.x/seeding)
- [Laravel Factories Documentation](https://laravel.com/docs/11.x/eloquent-factories)
