# Environment Setup

## Development Environment Configuration

### Required Environment Variables

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

# Google OAuth
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GOOGLE_REDIRECT_URI=http://localhost:8000/auth/google/callback
```

## Setup Instructions

1. Copy `.env.example` to `.env`
2. Generate application key: `php artisan key:generate`
3. Configure database credentials
4. Configure Redis if using queue
5. Configure Google OAuth credentials
6. Run migrations: `php artisan migrate --seed`

## Development Tools URLs

- **Telescope**: `http://localhost:8000/telescope`
- **Horizon**: `http://localhost:8000/horizon`
- **API Documentation**: `http://localhost:8000/api/documentation`
