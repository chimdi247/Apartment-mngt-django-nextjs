#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

echo "PostgreSQL is available"

# Ensure static directory exists (no chown!)
mkdir -p /app/staticfiles

# Run migrations
python manage.py migrate --no-input

# Collect static files
python manage.py collectstatic --no-input

# Start server
exec python manage.py runserver 0.0.0.0:8000